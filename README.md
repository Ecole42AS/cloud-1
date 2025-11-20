# Cloud-1 : Inception dans le cloud ☁️

Projet de déploiement automatisé d'une stack WordPress avec Docker, Nginx et Ansible sur Azure.

## 🎯 Objectif

Déployer une infrastructure web complète dans le cloud (Azure) avec :
- **Automatisation** : Ansible
- **Containerisation** : Docker + docker-compose
- **Reverse Proxy** : Nginx (HTTP/HTTPS)
- **Services** : WordPress + MariaDB + phpMyAdmin
- **Sécurité** : TLS (Let's Encrypt), isolation réseau, pare-feu

## 📚 Stack Technique

| Composant | Technologie | Version |
|-----------|-------------|---------|
| **Cloud** | Azure VM | Ubuntu 20.04 LTS |
| **Orchestration** | Ansible | Latest |
| **Containers** | Docker + Compose | Latest |
| **Reverse Proxy** | Nginx | Alpine |
| **CMS** | WordPress | Latest |
| **Base de données** | MariaDB | 10.11 |
| **Admin DB** | phpMyAdmin | Latest |
| **SSL/TLS** | Let's Encrypt | Certbot |

## 📁 Structure du Projet

```
cloud1/
├── docker-compose.yml          # Configuration Docker (4 services)
├── .env                        # Variables d'environnement (secrets)
├── nginx/
│   └── nginx.conf             # Configuration reverse proxy
├── ansible/                    # Automatisation (Phase 5+)
│   ├── inventory.ini
│   ├── playbook.yml
│   └── roles/
│       └── docker_server/
├── test-phase3.sh             # Script de validation Phase 3
├── PHASE2_README.md           # Documentation Phase 2
├── PHASE3_README.md           # Documentation Phase 3
└── README.md                  # Ce fichier
```

## 🚀 Démarrage Rapide

### Phase actuelle : Phase 5 (Ansible + Makefile Professionnel)

#### 1. Cloner le projet

```bash
git clone <repo-url>
cd cloud1
```

#### 2. Utiliser le Makefile

**Voir toutes les commandes disponibles :**
```bash
make help
```

**Démarrage rapide :**
```bash
# Vérifier la configuration
make venv-info

# Tester la connexion au serveur
make ping

# Démarrer la stack WordPress
make up

# Vérifier le statut global
make status
```

#### 3. Accéder aux services

- **WordPress** : https://mywp-cloud1.duckdns.org
- **phpMyAdmin** : https://mywp-cloud1.duckdns.org/phpmyadmin

## 📖 Documentation

### Documentation principale

| Document | Description |
|----------|-------------|
| [MAKEFILE_GUIDE.md](docs/MAKEFILE_GUIDE.md) | 📘 Guide complet du Makefile (concepts, explications) |
| [MAKEFILE_SUMMARY.md](docs/MAKEFILE_SUMMARY.md) | 📝 Résumé des améliorations apportées |
| [MAKEFILE_EXAMPLES.md](docs/MAKEFILE_EXAMPLES.md) | 🎯 Exemples pratiques et cas d'usage |

### Documentation par phase

| Phase | Document | Statut |
|-------|----------|--------|
| Phase 2 | [PHASE2_COMPLETE.md](docs/PHASE2_COMPLETE.md) | ✅ Validée |
| Phase 3 | [PHASE3_COMPLETE.md](docs/PHASE3_COMPLETE.md) | ✅ Validée |
| Phase 4 | [PHASE4_COMPLETE.md](docs/PHASE4_COMPLETE.md) | ⏸️ Certificats en attente |
| Phase 5 | [PHASE5_COMPLETE.md](docs/PHASE5_COMPLETE.md) | ✅ Validée |

### Guides techniques

- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Architecture détaillée du projet
- [QUICKSTART.md](docs/QUICKSTART.md) - Guide de démarrage rapide

## 🛠️ Commandes Makefile Principales

### 🐳 Docker
```bash
make up              # Démarrer la stack
make down            # Arrêter la stack
make restart         # Redémarrer
make logs            # Voir les logs
make ps              # État des conteneurs
make status          # Statut global
```

### 🔧 Ansible (Ad-hoc)
```bash
make ping            # Tester connexion
make uptime          # Uptime des serveurs
make disk            # Espace disque
make docker-ps       # Conteneurs distants
make shell ARGS="ls" # Commande personnalisée
```

### 📜 Ansible (Playbooks)
```bash
make deploy          # Déployer
make deploy-check    # Dry-run
make deploy-diff     # Avec diffs
make syntax          # Vérifier syntaxe
```

### 🛠️ Utilitaires
```bash
make help            # Aide complète
make venv-info       # Info virtualenv
make list-hosts      # Lister serveurs
make check-ssh       # Test SSH
```

👉 **Voir `make help` pour la liste complète**

```bash
git clone <url-du-repo>
cd cloud1
```

#### 2. Configurer les variables d'environnement

```bash
# Copier le fichier exemple et l'adapter
cp .env.example .env
nano .env  # Modifier les mots de passe
```

#### 3. Démarrer la stack

```bash
docker compose up -d
```

#### 4. Configurer HTTPS (avec un nom de domaine)

```bash
# Obtenir les certificats Let's Encrypt
./init-letsencrypt.sh ton-domaine.com ton-email@example.com
```

**Sans domaine** : Sauter cette étape, la stack fonctionne en HTTP

#### 5. Vérifier le déploiement

```bash
# Voir tous les conteneurs
docker ps

# Tester HTTPS
curl -I https://ton-domaine.com/
```

#### 6. Accéder aux services

**Avec HTTPS (recommandé)** :
- **WordPress** : https://ton-domaine.com/
- **phpMyAdmin** : https://ton-domaine.com/phpmyadmin

**Sans HTTPS (développement local)** :
- **WordPress** : http://localhost/
- **phpMyAdmin** : http://localhost/phpmyadmin

## 📖 Progression du Projet

| Phase | Statut | Description |
|-------|--------|-------------|
| **Phase 0** | ⏭️ Optionnel | Préparation Azure VM + SSH |
| **Phase 1** | ⏭️ Optionnel | Installation manuelle Docker |
| **Phase 2** | ✅ **Terminée** | Stack WordPress minimal (sans Nginx) |
| **Phase 3** | ✅ **Terminée** | Ajout reverse proxy Nginx (HTTP) |
| **Phase 4** | ✅ **Terminée** | HTTPS avec Let's Encrypt |
| **Phase 5** | ⏳ À venir | Introduction Ansible |
| **Phase 6** | ⏳ À venir | Rôle Ansible : installation Docker |
| **Phase 7** | ⏳ À venir | Rôle Ansible : déploiement stack |
| **Phase 8** | ⏳ À venir | Déploiement multi-serveurs |

## 🏗️ Architecture Actuelle (Phase 4)

```
                    INTERNET
                       │
                       ▼
            ┌──────────────────┐
            │      Nginx       │ ← Reverse Proxy HTTPS
            │  Port: 80, 443   │   (TLS/SSL Let's Encrypt)
            └────────┬─────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
         ▼           ▼           ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐
   │WordPress│ │ MariaDB │ │phpMyAdmin│
   │         │ │  (DB)   │ │         │
   └─────────┘ └─────────┘ └─────────┘
         │           │           │
         └───────────┴───────────┘
              Réseau: backend
              
   ┌─────────┐
   │ Certbot │ ← Renouvellement auto certificats
   └─────────┘
```

### Points clés :
- ✅ **Nginx** : Ports 80 (HTTP→HTTPS) et 443 (HTTPS)
- ✅ **Let's Encrypt** : Certificats SSL gratuits
- ✅ **WordPress** : Accessible via `https://domaine/`
- ✅ **phpMyAdmin** : Accessible via `https://domaine/phpmyadmin`
- ✅ **MariaDB** : Isolée, aucun port exposé
- ✅ **Persistance** : Volumes Docker (`db_data`, `wp_data`)

## 🔒 Sécurité

## 🔒 Sécurité

### Phase 4 (actuelle) :
- ✅ HTTPS avec Let's Encrypt (certificats SSL/TLS)
- ✅ Redirection automatique HTTP → HTTPS
- ✅ Chiffrement TLS 1.2/1.3
- ✅ Renouvellement automatique des certificats
- ✅ Un seul port HTTP exposé (pour redirection)
- ✅ Base de données non accessible depuis Internet
- ✅ Services backend isolés sur réseau interne
- ✅ Secrets dans `.env` (non commité)

## 📝 Documentation Détaillée

- **[docs/PHASE2_README.md](./docs/PHASE2_README.md)** : Stack WordPress minimal
- **[docs/PHASE3_README.md](./docs/PHASE3_README.md)** : Reverse proxy Nginx
- **[docs/PHASE4_README.md](./docs/PHASE4_README.md)** : HTTPS avec Let's Encrypt

## 🧪 Tests

### Tester HTTPS (Phase 4)

```bash
# Test HTTPS
curl -I https://ton-domaine.com/

# Test redirection HTTP → HTTPS
curl -I http://ton-domaine.com/
```

### Tester localement (sans HTTPS)
```bash
./test-phase3.sh
```

### Tester manuellement

```bash
# Vérifier les conteneurs
docker ps

# Tester WordPress
curl -I http://localhost/

# Tester phpMyAdmin
curl -I http://localhost/phpmyadmin

# Voir les logs
docker compose logs -f nginx
docker compose logs wordpress
```

## 🛠️ Commandes Utiles

### Gestion de la stack

```bash
# Démarrer
docker compose up -d

# Arrêter
docker compose down

# Redémarrer
docker compose restart

# Voir les logs
docker compose logs -f

# Reconstruire après changement de config
docker compose up -d --force-recreate
```

### Debugging

```bash
# Logs d'un service spécifique
docker compose logs nginx
docker compose logs wordpress

# Shell dans un conteneur
docker exec -it nginx sh
docker exec -it wordpress bash

# Tester la connectivité réseau
docker exec nginx ping wordpress
docker exec nginx ping phpmyadmin
```

## 🌍 Déploiement sur Azure

### Prérequis

1. **VM Azure** : Ubuntu 20.04 LTS (1 vCPU, 2 Go RAM minimum)
2. **Ports ouverts** : 
   - Port 22 (SSH)
   - Port 80 (HTTP)
   - Port 443 (HTTPS)
3. **Nom de domaine** : Requis pour HTTPS (Let's Encrypt)
   - DuckDNS, No-IP, ou domaine acheté
   - Pointer vers l'IP publique de ta VM

### Étapes

```bash
# 1. Se connecter à la VM
ssh ubuntu@IP_DE_TA_VM

# 2. Installer Docker (si pas fait en Phase 1)
# ... (voir docs/PHASE1_README.md)

# 3. Cloner le projet
git clone <url-du-repo>
cd cloud1

# 4. Configurer .env
nano .env

# 5. Démarrer la stack
docker compose up -d

# 6. Configurer HTTPS avec ton domaine
./init-letsencrypt.sh ton-domaine.com ton-email@example.com

# 7. Vérifier
docker ps
./test-phase3.sh
```

## 🎓 Ce que tu Apprends

### Compétences techniques :
- ✅ Docker & docker-compose (multi-conteneurs)
- ✅ Nginx (reverse proxy, réécriture URL)
- ✅ Réseaux Docker (isolation, communication inter-conteneurs)
- ✅ Gestion des secrets (fichier .env)
- ⏳ HTTPS / TLS (Phase 4)
- ⏳ Ansible (Phases 5-8)

### Compétences entreprise :
- ✅ Architecture microservices
- ✅ Reverse proxy pattern
- ✅ Isolation et sécurité
- ✅ Documentation technique
- ⏳ Infrastructure as Code (Ansible)
- ⏳ Déploiement automatisé

## 🐛 Problèmes Courants

### Erreur 502 Bad Gateway

**Cause** : Nginx ne peut pas joindre WordPress/phpMyAdmin

**Solution** :
```bash
docker compose logs wordpress
docker exec nginx ping wordpress
```

### phpMyAdmin affiche "Page not found"

**Cause** : Problème de réécriture d'URL

**Solution** : Vérifier `nginx/nginx.conf`, section `location /phpmyadmin`

### WordPress redirige vers localhost:8080

**Cause** : URL en base de données (Phase 2)

**Solution** :
```bash
# Via phpMyAdmin : modifier wp_options.siteurl et wp_options.home
# Ou en SQL :
docker exec -it mariadb mysql -u wp_user -p wordpress_db -e \
  "UPDATE wp_options SET option_value='http://IP_VM' WHERE option_name IN ('siteurl','home');"
```

Voir [PHASE3_README.md](./PHASE3_README.md) pour plus de détails.

## 📞 Support

Pour toute question ou problème :
1. Consulter la documentation de la phase concernée
2. Vérifier les logs : `docker compose logs -f`
3. Lancer le script de test : `./test-phase3.sh`

## 📜 Licence

Projet pédagogique - 42 School

---

**Prochaine étape** : Phase 4 - HTTPS avec Let's Encrypt 🔒
