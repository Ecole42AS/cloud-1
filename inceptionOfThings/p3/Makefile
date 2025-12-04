# Default target
all: help

# Install the environment (Cluster + ArgoCD)
install:
	bash scripts/install.sh

# Delete the cluster
clean:
	k3d cluster delete p3-cluster

# Reinstall everything
re: clean install

# Show ArgoCD Admin Password and Info
info:
	@echo "========================================"
	@echo "Argo CD Info"
	@echo "========================================"
	@echo "URL: https://localhost:8080"
	@echo "User: admin"
	@echo -n "Password: "
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo ""
	@echo "========================================"
	@echo "App Info"
	@echo "========================================"
	@echo "URL: http://localhost:8888"

# Port forward for ArgoCD UI
port-forward:
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
	@echo "Pods in 'dev' namespace"
	@echo "========================================"
	@kubectl get pods -n dev
	@echo ""
	@echo "========================================"
	@echo "Services in 'dev' namespace"
	@echo "========================================"
	@kubectl get svc -n dev

# Show current app version
version:
	@echo "========================================"
	@echo "Current deployed version"
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
	@kubectl describe application playground -n argocd | grep -A5 "Status:"

# Show help
help:
	@echo "Available commands:"
	@echo "  make install      - Create cluster and install ArgoCD"
	@echo "  make clean        - Delete the cluster"
	@echo "  make re           - Reinstall everything"
	@echo "  make info         - Show ArgoCD password and URLs"
	@echo "  make port-forward - Forward port 8080 to ArgoCD server"
	@echo "  make status       - Show all namespaces and pods"
	@echo "  make version      - Show current deployed app version"
	@echo "  make test         - Test the app endpoint"
	@echo "  make app-status   - Show ArgoCD application sync status"
	@echo "  make help         - Show this help message"

.PHONY: all install clean re info port-forward status version test app-status help
