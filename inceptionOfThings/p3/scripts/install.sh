#!/bin/bash
set -e # Arrête le script immédiatement si une commande échoue

# Check and Install K3d
if ! command -v k3d &> /dev/null
then
    echo "K3d not found. Installing..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
    echo "K3d is already installed."
fi

# Check and Install kubectl
if ! command -v kubectl &> /dev/null
then
    echo "kubectl not found. Installing..."
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    echo "Downloading kubectl version: $KUBECTL_VERSION"
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
else
    echo "kubectl is already installed."
fi

# Create Cluster
# Exposing 8888 on host to 80 on loadbalancer (Traefik)
if k3d cluster list | grep -q "p3-cluster"; then
    echo "Cluster 'p3-cluster' already exists."
else
    k3d cluster create p3-cluster --api-port 6443 -p "8888:80@loadbalancer" --agents 1 --wait
fi

# Create Namespaces
if ! kubectl get namespace argocd > /dev/null 2>&1; then
    kubectl create namespace argocd
else
    echo "Namespace 'argocd' already exists."
fi

if ! kubectl get namespace dev > /dev/null 2>&1; then
    kubectl create namespace dev
else
    echo "Namespace 'dev' already exists."
fi

# Install Argo CD
echo "Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD Server to be ready
echo "Waiting for Argo CD components to be ready..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Apply the Argo CD Application Configuration
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
APP_CONF="$SCRIPT_DIR/../confs/application.yaml"

# Check if repo URL is configured
if grep -q "YOUR_USERNAME/YOUR_REPO" "$APP_CONF"; then
    echo "------------------------------------------------"
    echo "Configuring Argo CD Application..."
    REPO_URL="https://github.com/Ecole42AS/cloud-1"
    REPO_PATH="inceptionOfThings/p3/app"

    if [ -n "$REPO_URL" ]; then
        # Escape slashes for sed
        ESCAPED_REPO_URL=$(echo "$REPO_URL" | sed 's/\//\\\//g')
        sed -i "s/https:\/\/github.com\/YOUR_USERNAME\/YOUR_REPO.git/$ESCAPED_REPO_URL/g" "$APP_CONF"
        
        # Update path using | as delimiter to handle slashes in path
        sed -i "s|path: app|path: $REPO_PATH|g" "$APP_CONF"
        
        echo "Updated application.yaml with URL: $REPO_URL and Path: $REPO_PATH"
    else
        echo "No URL provided. Please update p3/confs/application.yaml manually."
    fi
fi

echo "Applying Argo CD Application..."
kubectl apply -f "$APP_CONF"

echo "------------------------------------------------"
echo "Installation Complete."
echo "------------------------------------------------"
echo "Argo CD Admin Password:"
ARGOPWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "$ARGOPWD"
echo "------------------------------------------------"
echo "To finish the setup:"
echo "1. Push the contents of 'app' to the root of your repository: $REPO_URL"
echo "   (Ensure the folder structure is: repo_root/app/deployment.yaml, etc.)"
echo ""
echo "Access your App (after sync): http://localhost:8888"
echo ""
echo "Access Argo CD UI:"
echo "1. Run: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "2. Open: https://localhost:8080"
echo "3. User: admin / Password: $ARGOPWD"
