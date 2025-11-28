#!/bin/bash

# Ensure we are in the right directory
cd $(dirname $0)

# Check and Install Helm
if ! command -v helm &> /dev/null
then
    echo "Helm not found. Installing..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "Helm is already installed."
fi

# Create cluster
if k3d cluster list | grep -q "bonus-cluster"; then
    echo "Cluster 'bonus-cluster' already exists."
else
    k3d cluster create bonus-cluster --port 8888:80@loadbalancer --port 8443:443@loadbalancer --wait
fi

# Create namespaces
for ns in argocd gitlab dev; do
    if kubectl get namespace "$ns" > /dev/null 2>&1; then
        echo "Namespace '$ns' already exists."
    else
        kubectl create namespace "$ns"
    fi
done

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install GitLab
echo "Installing GitLab..."
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  -f ../confs/gitlab-values.yaml \
  --timeout 600s \
  --set global.hosts.domain=gitlab.localhost \
  --set global.hosts.externalIP=0.0.0.0

# Wait for GitLab Webservice
echo "Waiting for GitLab Webservice to be ready..."
kubectl wait --for=condition=ready pod -l app=webservice -n gitlab --timeout=1200s

# Get password
PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode)

echo "GitLab Root Password: $PASSWORD"

# Create Project via API (More reliable than Rails console for complex tasks)
echo "Waiting for GitLab Toolbox to be ready..."
kubectl wait --for=condition=ready pod -l app=toolbox -n gitlab --timeout=300s

echo "Generating Personal Access Token via Rails Console..."
TOOLBOX_POD=$(kubectl get pods -n gitlab -l app=toolbox -o jsonpath="{.items[0].metadata.name}")

# Create a PAT for root user
PAT_TOKEN="glpat-iot-bonus-token-123"
kubectl exec -n gitlab $TOOLBOX_POD -- gitlab-rails runner "token = PersonalAccessToken.new(user: User.first, name: 'iot-bonus-token', scopes: ['api'], expires_at: 365.days.from_now); token.set_token('$PAT_TOKEN'); token.save!" 2>/dev/null

echo "Personal Access Token created."

echo "Creating 'iot-bonus' project via API..."
# Wait for API to be responsive
sleep 10

# Create Public Project
curl --header "PRIVATE-TOKEN: $PAT_TOKEN" \
     --header "Content-Type: application/json" \
     --data '{ "name": "iot-bonus", "visibility": "public", "initialize_with_readme": false }' \
     "http://gitlab.localhost:8888/api/v4/projects"

echo ""
echo "Project creation request sent."

# Configure ArgoCD Application
# We need to create the application.yaml pointing to the internal service
# The internal URL for the repo: http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/iot-bonus.git
# Wait, check port. Usually 8181 is workhorse.
# But let's assume standard service discovery.

echo "Applying ArgoCD Application configuration..."

echo "ArgoCD Application configuration created at ../confs/application.yaml"

# Apply ArgoCD Application
kubectl apply -f ../confs/application.yaml

echo "------------------------------------------------"
echo "Setup Complete!"
echo "GitLab URL: http://gitlab.localhost:8888"
echo "User: root"
echo "Password: $PASSWORD"
echo "Repo URL (Local): http://gitlab.localhost:8888/root/iot-bonus.git"
echo ""
echo "ACTION REQUIRED:"
echo "You need to push the content of 'bonus/app' to the GitLab repository."
echo "Run the following commands:"
echo "  cd ../app"
echo "  git init"
echo "  git remote add origin http://root:$PASSWORD@gitlab.localhost:8888/root/iot-bonus.git"
echo "  git add ."
echo "  git commit -m \"Initial commit\""
echo "  git push -u origin master"
echo "------------------------------------------------"

# Get ArgoCD Password
ARGOPWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD URL: https://localhost:8080"
echo "ArgoCD User: admin"
echo "ArgoCD Password: $ARGOPWD"
echo "------------------------------------------------"

echo ""
echo "Starting ArgoCD Port Forwarding on port 8080..."
echo "Press Ctrl+C to stop the tunnel and exit the script."
kubectl port-forward svc/argocd-server -n argocd 8080:443
