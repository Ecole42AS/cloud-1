# ===================================
# Makefile - Cloud1 WordPress Project
# Gestion Docker + Ansible
# ===================================

# =============================
# Variables de configuration
# =============================

# Configuration Docker/SSL
DOMAIN := mywp-cloud1.duckdns.org
EMAIL := alexandre.stutz@hotmail.com

# Options supplémentaires pour certbot (ex: --staging ou --force-renewal)
CERTBOT_FLAGS ?=

# Configuration Ansible
ANSIBLE_DIR := ansible
INVENTORY := $(ANSIBLE_DIR)/inventory.ini
PLAYBOOK := $(ANSIBLE_DIR)/playbook.yml

# Détection automatique du virtualenv Python
VENV_PATH := venv
ifeq ($(shell test -d $(VENV_PATH) && echo yes),yes)
    PYTHON := $(CURDIR)/$(VENV_PATH)/bin/python
    ANSIBLE := $(CURDIR)/$(VENV_PATH)/bin/ansible
    ANSIBLE_PLAYBOOK := $(CURDIR)/$(VENV_PATH)/bin/ansible-playbook
    ANSIBLE_VAULT := $(CURDIR)/$(VENV_PATH)/bin/ansible-vault
else
    PYTHON := python3
    ANSIBLE := ansible
    ANSIBLE_PLAYBOOK := ansible-playbook
    ANSIBLE_VAULT := ansible-vault
endif

# Variables pour commandes ad-hoc Ansible (valeur par défaut si non spécifiées)
HOST ?= all
ARGS ?=

# Couleurs pour l'affichage
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# =============================
# Cible par défaut
# =============================

.PHONY: help
help: ## Affiche cette aide
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║      Makefile - Cloud1 WordPress Project				   ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)🐳 DOCKER - Gestion de la stack WordPress$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z_-]+:.*?## .*docker/ {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)🔧 ANSIBLE - Commandes ad-hoc$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z_-]+:.*?## .*ansible ad-hoc/ {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)📜 ANSIBLE - Playbooks$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z_-]+:.*?## .*ansible playbook/ {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)🛠️  UTILITAIRES$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z_-]+:.*?## .*util/ {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BLUE)Exemples d'utilisation :$(NC)"
	@echo "  make init                         # Initialiser SSL pour $(DOMAIN)"
	@echo "  make up                           # Démarrer la stack WordPress"
	@echo "  make ping                         # Tester la connexion Ansible"
	@echo "  make deploy                       # Déployer avec le playbook"
	@echo "  make shell ARGS=\"uptime\"           # Exécuter une commande sur le serveur"
	@echo "  make deploy-check                 # Dry-run du déploiement"
	@echo ""

# =============================
# DOCKER - Gestion de la stack
# =============================

.PHONY: init
init: ## [ansible] Forcer l'initialisation SSL (via Ansible)
	@echo "$(GREEN)>>> Initialisation SSL forcée via Ansible$(NC)"
	@cd $(ANSIBLE_DIR) && $(ANSIBLE_PLAYBOOK) -i $(notdir $(INVENTORY)) $(notdir $(PLAYBOOK)) -e "cloud1_letsencrypt_force=true"

.PHONY: logs-nginx
logs-nginx: ## [ansible ad-hoc] Logs Nginx sur la VM (tail -50)
	@cd $(ANSIBLE_DIR) && $(ANSIBLE) -i $(notdir $(INVENTORY)) $(HOST) \
		-m shell -a "cd /opt/cloud1 && docker compose logs --tail=50 nginx"

.PHONY: logs-wordpress
logs-wordpress: ## [ansible ad-hoc] Logs WordPress sur la VM (tail -50)
	@cd $(ANSIBLE_DIR) && $(ANSIBLE) -i $(notdir $(INVENTORY)) $(HOST) \
		-m shell -a "cd /opt/cloud1 && docker compose logs --tail=50 wordpress"

.PHONY: restart-stack
restart-stack: ## [ansible ad-hoc] Redémarrer nginx + wordpress sur la VM
	@cd $(ANSIBLE_DIR) && $(ANSIBLE) -i $(notdir $(INVENTORY)) $(HOST) \
		-m shell -a "cd /opt/cloud1 && docker compose restart nginx wordpress"

.PHONY: certbot-renew
certbot-renew: ## [ansible] Renouveler les certificats (via script distant)
	@echo "$(GREEN)>>> Renouvellement des certificats sur $(HOST)$(NC)"
	@cd $(ANSIBLE_DIR) && $(ANSIBLE) $(HOST) -i $(notdir $(INVENTORY)) -m shell -a "cd /opt/cloud1 && bash scripts/init-letsencrypt.sh $(DOMAIN) $(EMAIL) --force" --become
	@echo "$(GREEN)✅ Certbot terminé$(NC)"
	@echo "$(YELLOW)Pense à recharger nginx si nécessaire : make restart-stack$(NC)"


# =============================
# ANSIBLE - Commandes ad-hoc
# =============================

.PHONY: ping
ping: ## [ansible ad-hoc] Tester la connexion Ansible (ping)
	@echo "$(GREEN)>>> Test de connectivité Ansible$(NC)"
	@cd $(ANSIBLE_DIR) && $(ANSIBLE) -i $(notdir $(INVENTORY)) $(HOST) -m ping

.PHONY: shell
shell: ## [ansible ad-hoc] Ouvrir un shell sur un hôte (HOST=cloud1-vm ARGS="commande")
	@echo "$(GREEN)>>> Ouverture shell sur $(HOST)$(NC)"
	@cd $(ANSIBLE_DIR) && $(ANSIBLE) -i $(notdir $(INVENTORY)) $(HOST) -m shell -a "$(ARGS)"

# =============================
# ANSIBLE - Playbooks
# =============================

.PHONY: deploy
deploy: ## [ansible playbook] Exécuter le playbook principal
	@echo "$(GREEN)>>> Déploiement avec Ansible$(NC)"
	@cd $(ANSIBLE_DIR) && $(ANSIBLE_PLAYBOOK) -i $(notdir $(INVENTORY)) $(notdir $(PLAYBOOK))

.PHONY: deploy-check
deploy-check: ## [ansible playbook] Dry-run du playbook (--check)
	@echo "$(BLUE)>>> Simulation du déploiement (dry-run)$(NC)"
	@cd $(ANSIBLE_DIR) && $(ANSIBLE_PLAYBOOK) -i $(notdir $(INVENTORY)) $(notdir $(PLAYBOOK)) --check

.PHONY: syntax
syntax: ## [ansible playbook] Vérifier la syntaxe du playbook
	@echo "$(BLUE)>>> Vérification de la syntaxe$(NC)"
	@cd $(ANSIBLE_DIR) && $(ANSIBLE_PLAYBOOK) -i $(notdir $(INVENTORY)) $(notdir $(PLAYBOOK)) --syntax-check
	@echo "$(GREEN)✅ Syntaxe correcte$(NC)"

.PHONY: vault-encrypt
vault-encrypt: ## [ansible ad-hoc] Chiffrer le fichier vault.yml
	@echo "$(GREEN)>>> Chiffrement de group_vars/all/vault.yml$(NC)"
	@cd $(ANSIBLE_DIR) && $(ANSIBLE_VAULT) encrypt group_vars/all/vault.yml

.PHONY: vault-decrypt
vault-decrypt: ## [ansible ad-hoc] Déchiffrer le fichier vault.yml
	@echo "$(GREEN)>>> Déchiffrement de group_vars/all/vault.yml$(NC)"
	@cd $(ANSIBLE_DIR) && $(ANSIBLE_VAULT) decrypt group_vars/all/vault.yml

# =============================
# UTILITAIRES
# =============================

.PHONY: venv-info
venv-info: ## [util] Afficher les informations sur le virtualenv
	@echo "$(BLUE)Configuration Python/Ansible :$(NC)"
	@echo "  VENV_PATH       : $(VENV_PATH)"
	@echo "  PYTHON          : $(PYTHON)"
	@echo "  ANSIBLE         : $(ANSIBLE)"
	@echo "  ANSIBLE_PLAYBOOK: $(ANSIBLE_PLAYBOOK)"
	@echo ""
	@if [ -d $(VENV_PATH) ]; then \
		echo "$(GREEN)✅ Virtualenv détecté$(NC)"; \
		$(PYTHON) --version; \
		$(ANSIBLE) --version | head -1; \
	else \
		echo "$(YELLOW)⚠️  Pas de virtualenv détecté - utilisation des commandes système$(NC)"; \
	fi

.PHONY: list-hosts
list-hosts: ## [util] Lister tous les hôtes de l'inventaire
	@echo "$(BLUE)>>> Hôtes dans l'inventaire :$(NC)"
	@cd $(ANSIBLE_DIR) && $(ANSIBLE) -i $(notdir $(INVENTORY)) all --list-hosts

.PHONY: status
status: ## [util] Afficher le statut global du projet
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║              STATUS - Cloud1 WordPress Project             ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)🐳 Docker Compose :$(NC)"
	@docker compose ps 2>/dev/null || echo "  $(YELLOW)Stack non démarrée$(NC)"
	@echo ""
	@echo "$(GREEN)🔗 Connexion Ansible :$(NC)"
	@cd $(ANSIBLE_DIR) && $(ANSIBLE) -i $(notdir $(INVENTORY)) all -m ping -o 2>/dev/null || echo "  $(RED)Connexion impossible$(NC)"
	@echo ""
	@echo "$(GREEN)🌍 URLs :$(NC)"
	@echo "  WordPress  : https://$(DOMAIN)"
	@echo "  phpMyAdmin : https://$(DOMAIN)/phpmyadmin"
	@echo ""

.PHONY: venv-create
venv-create: ## [util] Créer un venv local et installer Ansible (compatible Python 3.8+)
	@echo "$(GREEN)>>> Création du virtualenv...$(NC)"
	@python3 -m venv $(VENV_PATH)
	@echo "$(GREEN)>>> Installation d'Ansible...$(NC)"
	@$(VENV_PATH)/bin/pip install --upgrade pip
	@$(VENV_PATH)/bin/pip install "ansible-core<2.17" ansible==9.5.1
	@echo "$(GREEN)✅ Environnement prêt. Activez-le avec : source $(VENV_PATH)/bin/activate$(NC)"
	@echo "$(BLUE)Pour activer le virtualenv, exécutez :$(NC)"
	@echo "  source $(VENV_PATH)/bin/activate"
