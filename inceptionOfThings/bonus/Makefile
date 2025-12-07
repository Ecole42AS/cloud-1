# Default target
all: help

# Install the environment (Cluster + ArgoCD + GitLab)
install:
	bash scripts/install.sh

# Delete the cluster
clean:
	k3d cluster delete bonus-cluster

# Reinstall everything
re: clean install

# Show ArgoCD Admin Password and Info
info:
	@echo "========================================"
	@echo "GitLab Info"
	@echo "========================================"
	@echo "URL: http://gitlab.localhost:8888"
	@echo "User: root"
	@echo -n "Password: "
	@kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode
	@echo ""
	@echo ""
	@echo "========================================"
	@echo "Argo CD Info"
	@echo "========================================"
	@echo "URL: https://localhost:8080"
	@echo "User: admin"
	@echo -n "Password: "
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo ""
	@echo ""
	@echo "========================================"
	@echo "App Info"
	@echo "========================================"
	@echo "URL: http://localhost:8888"

# Port forward for ArgoCD UI
port-forward-argocd:
	@echo "Access ArgoCD at https://localhost:8080"
	kubectl port-forward svc/argocd-server -n argocd 8080:443

# Show status of all resources
status:
	@echo "========================================"
	@echo "Namespaces"
	@echo "========================================"
	@kubectl get ns
	@echo ""
	@echo "========================================"
	@echo "Pods in 'argocd' namespace"
	@echo "========================================"
	@kubectl get pods -n argocd
	@echo ""
	@echo "========================================"
	@echo "Pods in 'gitlab' namespace"
	@echo "========================================"
	@kubectl get pods -n gitlab
	@echo ""
	@echo "========================================"
	@echo "Pods in 'dev' namespace"
	@echo "========================================"
	@kubectl get pods -n dev
	@echo ""
	@echo "========================================"
	@echo "Services in 'dev' namespace"
	@echo "========================================"
	@kubectl get svc -n dev

# Show GitLab status
gitlab-status:
	@echo "========================================"
	@echo "GitLab Pods Status"
	@echo "========================================"
	@kubectl get pods -n gitlab
	@echo ""
	@echo "========================================"
	@echo "GitLab Services"
	@echo "========================================"
	@kubectl get svc -n gitlab

# Show current app version
version:
	@echo "========================================"
	@echo "Current deployed version (in app/deployment.yaml)"
	@echo "========================================"
	@grep -E "image:" app/deployment.yaml || true
	@echo ""
	@echo "========================================"
	@echo "App response"
	@echo "========================================"
	@curl -s http://localhost:8888/ || echo "App not reachable"

# Test the app endpoint
test:
	@curl -s http://localhost:8888/

# Show ArgoCD application status
app-status:
	@kubectl get application -n argocd
	@echo ""
	@kubectl describe application playground -n argocd 2>/dev/null | grep -A10 "Status:" || echo "Application 'playground' not found"

# Update app version from v1 to v2 (for demo during evaluation)
update-v2:
	@echo "Updating deployment to v2..."
	@sed -i 's/wil42\/playground:v1/wil42\/playground:v2/g' app/deployment.yaml
	@echo "Updated! Now push to GitLab:"
	@echo "  cd app && git add . && git commit -m 'Update to v2' && git push"

# Update app version from v2 to v1 (rollback)
update-v1:
	@echo "Updating deployment to v1..."
	@sed -i 's/wil42\/playground:v2/wil42\/playground:v1/g' app/deployment.yaml
	@echo "Updated! Now push to GitLab:"
	@echo "  cd app && git add . && git commit -m 'Rollback to v1' && git push"

# Show help
help:
	@echo "========================================"
	@echo "IoT Bonus - GitLab + ArgoCD"
	@echo "========================================"
	@echo ""
	@echo "Available commands:"
	@echo "  make install            - Create cluster, install ArgoCD and GitLab"
	@echo "  make clean              - Delete the cluster"
	@echo "  make re                 - Reinstall everything"
	@echo ""
	@echo "  make info               - Show GitLab, ArgoCD passwords and URLs"
	@echo "  make status             - Show all namespaces and pods"
	@echo "  make gitlab-status      - Show GitLab pods and services"
	@echo "  make app-status         - Show ArgoCD application sync status"
	@echo ""
	@echo "  make port-forward-argocd - Forward port 8080 to ArgoCD server"
	@echo ""
	@echo "  make version            - Show current deployed app version"
	@echo "  make test               - Test the app endpoint (curl localhost:8888)"
	@echo ""
	@echo "  make update-v2          - Update deployment.yaml to use v2"
	@echo "  make update-v1          - Rollback deployment.yaml to v1"
	@echo ""
	@echo "  make help               - Show this help message"

.PHONY: all install clean re info port-forward-argocd status gitlab-status version test app-status update-v2 update-v1 help
