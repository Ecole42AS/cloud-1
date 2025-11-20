# 🔧 Ansible - Introduction et Test de Connectivité

## 📁 Structure du dossier

```
ansible/
├── ansible.cfg         # Configuration globale Ansible
├── inventory.ini       # Inventaire des serveurs cibles
├── playbook.yml        # Playbook de test (ping)
└── README.md          # Ce fichier
```

## 📝 Description

Cette phase met en place l'infrastructure Ansible de base pour automatiser la configuration de la VM Azure.

### Fichiers créés

1. **`inventory.ini`** : Définit les serveurs cibles
   - Groupe `[wordpress_servers]` contenant la VM Azure
   - Variables de connexion SSH

2. **`playbook.yml`** : Playbook minimal de test
   - Test de connectivité (ping)
   - Collecte d'informations système
   - Vérification de Python

3. **`ansible.cfg`** : Configuration Ansible
   - Inventaire par défaut
   - Paramètres SSH
   - Options de verbosité

## 🚀 Prérequis

### Sur ta machine locale

1. **Installer Ansible**

```bash
# Sur macOS
brew install ansible

# Sur Ubuntu/Debian
sudo apt update
sudo apt install ansible

# Vérifier l'installation
ansible --version
```

2. **Configurer l'accès SSH**

Assure-toi que tu peux te connecter à ta VM sans mot de passe :

```bash
# Tester la connexion SSH
ssh ubuntu@51.103.220.239

# Si besoin, copier ta clé SSH publique sur la VM
ssh-copy-id ubuntu@51.103.220.239
```

3. **Mettre à jour `inventory.ini`**

Édite le fichier `inventory.ini` et remplace :
- `51.103.220.239` par l'IP publique réelle de ta VM
- `ubuntu` par ton utilisateur SSH si différent

## 🧪 Validation et Tests

### Test 1 : Vérifier l'inventaire

```bash
# Se placer dans le dossier ansible/
cd ansible/

# Lister tous les hôtes de l'inventaire
ansible all --list-hosts
```

**Résultat attendu :**
```
  hosts (1):
    cloud1-vm
```

### Test 2 : Ping simple (module ad-hoc)

```bash
# Ping tous les serveurs
ansible all -m ping

# Ou spécifiquement le groupe wordpress_servers
ansible wordpress_servers -m ping
```

**Résultat attendu :**
```yaml
cloud1-vm | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Test 3 : Exécuter le playbook

```bash
# Lancer le playbook complet
ansible-playbook playbook.yml
```

**Résultat attendu :**
```yaml
PLAY [Test de connectivité avec les serveurs WordPress] ***********************

TASK [Gathering Facts] *********************************************************
ok: [cloud1-vm]

TASK [Ping tous les serveurs du groupe] ****************************************
ok: [cloud1-vm]

TASK [Afficher la distribution du système] *************************************
ok: [cloud1-vm] => 
  msg: 'Serveur cloud1-vm - OS: Ubuntu 20.04'

TASK [Vérifier la version de Python sur le serveur] ****************************
ok: [cloud1-vm]

TASK [Afficher la version de Python] *******************************************
ok: [cloud1-vm] => 
  msg: Python 3.8.10

PLAY RECAP *********************************************************************
cloud1-vm                  : ok=5    changed=0    unreachable=0    failed=0
```

### Test 4 : Commandes utiles pour le debug

```bash
# Mode verbeux (voir les détails de connexion)
ansible all -m ping -v

# Mode très verbeux (debug complet)
ansible all -m ping -vvv

# Vérifier les facts (informations système)
ansible all -m setup

# Exécuter une commande shell sur le serveur
ansible all -m command -a "uptime"
ansible all -m command -a "docker --version"
```

## 🔍 Troubleshooting

### Problème : "Permission denied (publickey)"

**Solution :** Configure ton accès SSH

```bash
# Copier ta clé SSH sur la VM
ssh-copy-id ubuntu@IP_DE_TA_VM

# Ou spécifier la clé dans inventory.ini
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### Problème : "Host key verification failed"

**Solution :** Désactiver la vérification (déjà fait dans `ansible.cfg`)

```bash
# Ou ajouter manuellement la clé SSH
ssh-keyscan IP_DE_TA_VM >> ~/.ssh/known_hosts
```

### Problème : "Failed to connect to the host via ssh"

**Vérifications :**

1. La VM est bien démarrée sur Azure
2. L'IP dans `inventory.ini` est correcte
3. Le port SSH (22) est ouvert dans les règles Azure NSG
4. Tu peux te connecter manuellement : `ssh ubuntu@IP_DE_TA_VM`

### Problème : Python non trouvé

**Solution :** Sur Ubuntu 20.04, Python 3 est installé par défaut. Vérifie :

```bash
# Sur la VM
python3 --version

# Si Python 3 manque (rare)
sudo apt update
sudo apt install python3
```

## 📚 Commandes Ansible de référence

### Commandes ad-hoc (sans playbook)

```bash
# Ping
ansible all -m ping

# Exécuter une commande shell
ansible all -m command -a "commande"
ansible all -m shell -a "commande | avec | pipes"

# Copier un fichier
ansible all -m copy -a "src=/local/file dest=/remote/file"

# Installer un package
ansible all -m apt -a "name=package state=present" --become

# Redémarrer un service
ansible all -m service -a "name=docker state=restarted" --become
```

### Commandes playbook

```bash
# Exécuter un playbook
ansible-playbook playbook.yml

# Mode dry-run (simulation, pas d'exécution réelle)
ansible-playbook playbook.yml --check

# Mode diff (affiche les changements)
ansible-playbook playbook.yml --diff

# Limiter à un serveur spécifique
ansible-playbook playbook.yml --limit cloud1-vm

# Mode verbeux
ansible-playbook playbook.yml -v   # ou -vv, -vvv, -vvvv
```

## ✅ Validation Phase 5 Complète

✔️ Ansible installé sur ta machine locale  
✔️ Structure `ansible/` créée avec tous les fichiers  
✔️ Inventaire configuré avec l'IP de ta VM  
✔️ Accès SSH sans mot de passe fonctionnel  
✔️ `ansible all -m ping` retourne "SUCCESS"  
✔️ `ansible-playbook playbook.yml` s'exécute sans erreur  

## 🎯 Prochaines étapes

**Phase 6 :** Création d'un rôle Ansible pour installer Docker automatiquement sur la VM.

---

## 📖 Ressources

- [Documentation Ansible](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Module ping](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ping_module.html)
