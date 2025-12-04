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

# Show help
help:
	@echo "Available commands:"
	@echo "  make install      - Create cluster and install ArgoCD"
	@echo "  make clean        - Delete the cluster"
	@echo "  make re           - Reinstall everything"
	@echo "  make info         - Show ArgoCD password and URLs"
	@echo "  make port-forward - Forward port 8080 to ArgoCD server"
	@echo "  make help         - Show this help message"

.PHONY: all install clean re info port-forward help
