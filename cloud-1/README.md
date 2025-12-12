# Cloud-1 — Automated WordPress Stack

Fully automated deployment of a secure WordPress infrastructure using **Docker**, **Ansible**, and **Let's Encrypt**.

## Stack

| Component | Technology |
|-----------|------------|
| Orchestration | Ansible (roles-based) |
| Containers | Docker Compose |
| Web Server | Nginx (reverse proxy + SSL termination) |
| Database | MariaDB |
| SSL | Let's Encrypt (auto-renewal) |
| Secrets | Ansible Vault |

## Quick Start

```bash
# 1. Configure inventory
cp ansible/inventory.ini.example ansible/inventory.ini

# 2. Set vault password
echo "your_vault_password" > ansible/.vault_pass

# 3. Deploy
make deploy
```

## Commands

| Command | Description |
|---------|-------------|
| `make deploy` | Full deployment |
| `make deploy-check` | Dry-run |
| `make init` | Force SSL regeneration |
| `make ping` | Test SSH connectivity |
| `make vault-encrypt` | Encrypt secrets |
| `make vault-decrypt` | Decrypt secrets |

## Partial Deployment

```bash
ansible-playbook ansible/playbook.yml --tags "docker"  # Docker only
ansible-playbook ansible/playbook.yml --tags "app"     # App stack
ansible-playbook ansible/playbook.yml --tags "ssl"     # Certificates
```

## Security

A Git `pre-commit` hook prevents committing unencrypted `vault.yml` files.

## Structure

```
ansible/
├── playbook.yml
├── inventory.ini
├── group_vars/all/
│   ├── vars.yml
│   └── vault.yml (encrypted)
└── roles/
    ├── docker_server/
    ├── cloud-1/
    └── letsencrypt_manager/
```
