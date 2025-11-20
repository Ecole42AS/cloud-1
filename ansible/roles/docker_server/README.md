# Rôle Ansible : docker_server

## 📝 Description

Ce rôle Ansible installe et configure Docker Engine sur Ubuntu 20.04 de manière automatisée et idempotente.

## 🎯 Fonctionnalités

- Installation de Docker Engine (version latest stable)
- Installation de docker compose (plugin v2)
- Configuration du service Docker (démarrage automatique)
- Ajout de l'utilisateur au groupe docker
- Vérification fonctionnelle de l'installation
- Déploiement de la stack Docker (`docker-compose.yml`, `.env`, `nginx/`)
- Initialisation automatique de Let's Encrypt via `scripts/init-letsencrypt.sh`

## 📋 Prérequis

- Système d'exploitation : Ubuntu 20.04 LTS
- Privilèges sudo sur le serveur cible
- Connexion SSH configurée
- Python 3.8+ sur le serveur cible

## 🚀 Utilisation

### Dans un playbook

```yaml
- name: Installation Docker
  hosts: wordpress_servers
  roles:
    - docker_server
```

### Variables disponibles

Ces variables peuvent être définies dans `inventory.ini`, `group_vars` ou lors de l'appel du rôle :

| Variable | Description | Valeur par défaut |
| --- | --- | --- |
| `cloud1_project_dir` | Dossier distant où copier la stack Docker | `/opt/cloud1` |
| `cloud1_domain` | Nom de domaine public pour Nginx / TLS | `mywp-cloud1.duckdns.org` |
| `cloud1_letsencrypt_email` | Email utilisé par Let's Encrypt | `admin@example.com` |
| `cloud1_letsencrypt_use_staging` | `true` pour utiliser l'API de staging (évite les quotas) | `true` |
| `cloud1_letsencrypt_force` | Force le script à recréer les certificats | `false` |

> ⚠️ Pense à surcharger `cloud1_domain` et `cloud1_letsencrypt_email` avant un vrai déploiement.

## 📦 Packages installés

- `docker-ce` : Docker Community Edition
- `docker-ce-cli` : Interface en ligne de commande Docker
- `containerd.io` : Runtime de conteneurs
- `docker-buildx-plugin` : Plugin pour builds multi-architectures
- `docker-compose-plugin` : Plugin docker compose v2

## ✅ Tests de validation

Le rôle effectue automatiquement les tests suivants :

1. Vérification de la version Docker
2. Vérification de la version docker compose
3. Test fonctionnel avec `hello-world`

## 🔄 Idempotence

Ce rôle est idempotent :
- Première exécution : ~10 changements (installation)
- Exécutions suivantes : ~2 changements (caches APT uniquement)

## 🏗️ Structure

```
docker_server/
└── tasks/
    └── main.yml    # Tâches principales (11 étapes)
```

## 📚 Modules Ansible utilisés

- `apt` - Gestion des packages
- `file` - Gestion des fichiers/dossiers
- `shell` - Exécution de commandes shell
- `service` - Gestion des services systemd
- `user` - Gestion des utilisateurs
- `command` - Exécution de commandes simples
- `debug` - Affichage de messages

## 🔧 Étapes d'installation

1. Mise à jour du cache APT
2. Installation des prérequis
3. Ajout de la clé GPG Docker
4. Ajout du dépôt officiel Docker
5. Installation de Docker Engine
6. Démarrage du service Docker
7. Ajout de l'utilisateur au groupe docker
8. Déploiement de la stack Docker (copie des fichiers, `docker compose up -d`)
9. Initialisation Let's Encrypt (via `scripts/init-letsencrypt.sh`)
10. Vérifications (conteneurs en ligne)
