# Default target
all: help

# Start the VMs
up:
	vagrant up

# Stop the VMs (halt)
down:
	vagrant halt

# Destroy the VMs (clean start)
clean:
	vagrant destroy -f

# Rebuild everything
re: clean up

# Show VM status
status:
	vagrant status

# Connect to the server
ssh:
	vagrant ssh astutzS

# Run all checks to prove the project is working
verify:
	@echo "========================================"
	@echo "1. Checking Cluster Nodes"
	@echo "========================================"
	@vagrant ssh astutzS -c "kubectl get nodes -o wide"
	@echo ""
	@echo "========================================"
	@echo "2. Checking All Resources"
	@echo "========================================"
	@vagrant ssh astutzS -c "kubectl get all"
	@echo ""
	@echo "========================================"
	@echo "3. Checking Ingress"
	@echo "========================================"
	@vagrant ssh astutzS -c "kubectl get ingress"
	@echo ""
	@echo "========================================"
	@echo "4. Testing App Access (via curl localhost with Host header)"
	@echo "========================================"
	@echo "Testing app1.com..."
	@vagrant ssh astutzS -c "curl -s -I -H 'Host: app1.com' http://192.168.56.110 | grep HTTP"
	@echo "Testing app2.com..."
	@vagrant ssh astutzS -c "curl -s -I -H 'Host: app2.com' http://192.168.56.110 | grep HTTP"
	@echo "Testing app3.com..."
	@vagrant ssh astutzS -c "curl -s -I -H 'Host: app3.com' http://192.168.56.110 | grep HTTP"

# Reload and provision the VMs
reload:
	vagrant reload --provision

# Show help
help:
	@echo "Available commands:"
	@echo "  make up      - Start the VMs"
	@echo "  make down    - Stop the VMs"
	@echo "  make clean   - Destroy the VMs"
	@echo "  make re      - Rebuild everything (clean + up)"
	@echo "  make reload  - Reload and provision the VMs"
	@echo "  make status  - Show VM status"
	@echo "  make ssh     - SSH into the server node"
	@echo "  make verify  - Run checks to validate the setup (Pods, Ingress, Curl)"
	@echo "  make help    - Show this help message"

.PHONY: all up down clean re status ssh verify reload help
