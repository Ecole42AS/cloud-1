# Makefile for Inception-of-Things p1

# Default target
all: up

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
	@echo "1. Checking Cluster Nodes (kubectl)"
	@echo "========================================"
	@vagrant ssh astutzS -c "sudo kubectl get nodes -o wide"
	@echo ""
	@echo "========================================"
	@echo "2. Checking Server IP (192.168.56.110)"
	@echo "========================================"
	@vagrant ssh astutzS -c "ip a | grep 192.168.56"
	@echo ""
	@echo "========================================"
	@echo "3. Checking K3s Service Status"
	@echo "========================================"
	@vagrant ssh astutzS -c "systemctl status k3s --no-pager | grep Active"

.PHONY: all up down clean re status ssh verify
