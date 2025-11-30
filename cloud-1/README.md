# Cloud-1 Project

Déploiement automatisé d'une stack WordPress sécurisée (Docker + Nginx + Let's Encrypt) via Ansible.

## Architecture
*   **Docker** : Conteneurisation (WordPress, MySQL, Nginx).
*   **Ansible** : Orchestration modulaire (Rôles : `docker_server`, `cloud-1`, `letsencrypt_manager`).
*   **Let's Encrypt** : Certificats SSL gratuits.

## Prérequis
*   Python 3
*   Accès SSH au serveur cible (Debian/Ubuntu).

## Installation Rapide

1.  **Configurer l'inventaire** :
    ```bash
    cp ansible/inventory.ini.example ansible/inventory.ini
    # Éditer ansible/inventory.ini avec l'IP de votre serveur
    ```

2.  **Configurer les variables et secrets** :
    *   Les variables globales (domaine, email) sont dans `ansible/group_vars/all/vars.yml`.
    *   Les secrets (mots de passe) sont dans `ansible/group_vars/all/vault.yml`.

    ```bash
    # Créer le fichier de mot de passe Vault (ne pas commiter !)
    echo "votre_mot_de_passe_vault" > ansible/.vault_pass
    
    # Éditer les secrets
    make vault-decrypt
    # ... modifier ansible/group_vars/all/vault.yml ...
    make vault-encrypt
    ```

3.  **Déployer** :
    ```bash
    make deploy
    ```

## Commandes Utiles
*   `make deploy` : Déploiement complet.
*   `make init` : Force la régénération des certificats SSL.
*   `make ping` : Tester la connexion Ansible.
*   `make vault-decrypt` / `make vault-encrypt` : Gérer les secrets chiffrés.

## Déploiement Partiel (Tags)
Vous pouvez déployer uniquement certaines parties via Ansible :
*   `ansible-playbook ansible/playbook.yml --tags "docker"` (Installation Docker)
*   `ansible-playbook ansible/playbook.yml --tags "app"` (Mise à jour WordPress/Nginx)
*   `ansible-playbook ansible/playbook.yml --tags "ssl"` (Gestion Certificats)

## Sécurité
Un hook Git `pre-commit` empêche de commiter le fichier `vault.yml` s'il n'est pas chiffré.
