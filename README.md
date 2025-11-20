# Cloud-1

Déploiement automatisé d’une stack WordPress (Docker, Nginx, MariaDB, phpMyAdmin) sur une VM Azure, avec orchestration Ansible.

## Panorama rapide

- Cible : Ubuntu 20.04 sur Azure, ports 22/80/443 ouverts.
- Conteneurs : WordPress, MariaDB, phpMyAdmin, Nginx (reverse proxy HTTPS).
- Sécurité : certificats Let’s Encrypt, base non exposée, secrets dans `.env`.
- Automatisation : Makefile pour les commandes locales, Ansible pour le déploiement distant.

## Pré-requis

- Git, Docker et docker compose installés en local.
- Accès SSH fonctionnel à la VM Azure (`ssh ubuntu@<ip>`).
- Nom de domaine pointé sur l’IP publique pour activer HTTPS.

## Démarrage rapide (local)

```bash
git clone <repo-url>
cd cloud1
cp .env.example .env   # renseigner les mots de passe et le domaine
docker compose up -d
```

Accès local :
- WordPress : http://localhost/
- phpMyAdmin : http://localhost/phpmyadmin

## Déploiement sur la VM avec Ansible

```bash
cd ansible
# mettre à jour ansible/inventory.ini avec l’IP, l’utilisateur SSH et le domaine
ansible all -m ping             # test de connexion
ansible-playbook playbook.yml   # déploiement complet
```

Ce que fait le playbook : installe Docker et docker compose sur la VM, copie `docker-compose.yml`, `.env`, `nginx.conf` et `scripts/`, lance `docker compose up -d`, génère les certificats Let’s Encrypt si besoin.

## Structure du projet

```
cloud1/
├── docker-compose.yml       # services WordPress, DB, phpMyAdmin, Nginx
├── .env                     # variables sensibles (non commité)
├── nginx/
│   └── nginx.conf           # reverse proxy + TLS
├── scripts/
│   └── init-letsencrypt.sh  # génération/renouvellement certifs
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── playbook.yml
│   └── roles/
│       └── docker_server/   # installation Docker + déploiement stack
└── Makefile                 # raccourcis Docker/Ansible
```

## Commandes utiles (Makefile)

```bash
make help          # liste des cibles
make up            # démarrer la stack Docker
make down          # arrêter
make logs          # logs agrégés
make status        # état des conteneurs
make ping          # ping Ansible des hôtes
make deploy        # ansible-playbook playbook.yml
```

## Documentation

- ansible/README.md : prise en main Ansible et commandes de test
- en.subject_cloud-1.pdf : énoncé du projet (référence)

## Dépannage express

- 502 Bad Gateway : vérifier `docker compose ps`, puis `docker compose logs wordpress` et `nginx`.
- Certificat absent : relancer `scripts/init-letsencrypt.sh <domaine> <email> --staging` si besoin.
- Connexion Ansible : tester `ansible all -m ping -vvv` et vérifier la clé SSH/`inventory.ini`.
