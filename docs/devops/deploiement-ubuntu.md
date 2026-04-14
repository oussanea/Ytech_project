---
id: deploiement-ubuntu
title: Déploiement Ubuntu — Guide complet
sidebar_position: 3
---

# Déploiement Ubuntu — Guide complet

## Pourquoi documenter le déploiement ?

Un déploiement non documenté n'existe pas vraiment — si la personne qui l'a fait n'est plus là, personne ne peut le reproduire. Dans un contexte professionnel, une infrastructure non reproductible est une **dette technique** et un risque opérationnel majeur.

Ce guide permet à **n'importe quel membre de l'équipe** de reconstruire l'intégralité de l'infrastructure depuis zéro, en suivant les étapes dans l'ordre. C'est aussi la base d'une future automatisation via Ansible ou Terraform.

> 💶 **Dimension financière** : Le temps moyen pour reconstruire une infrastructure non documentée après un incident est estimé à **18,5 heures** (IBM CODB 2023). Avec ce guide, ce temps tombe à **moins de 2 heures**. Sur un coût d'ingénieur de 75€/h, c'est une économie de **1 237 €** par incident évité.

---

## Prérequis communs à toutes les VMs

### Configuration VirtualBox

Chaque VM est configurée avec **deux interfaces réseau** :

```
Adaptateur 1 : Host-Only (réseau interne VMs sur même PC)
  → Réseau : 192.168.56.0/24
  → Utilité : communication entre VM1, VM2, VM3

Adaptateur 2 : Bridge (réseau physique de classe)
  → Réseau : 192.168.9.0/24 ou 192.168.10.0/24
  → Utilité : communication entre PCs des membres
```

### OS de base

```bash
# Ubuntu 24.04 LTS Server — installation minimale
# Après installation, mise à jour complète du système

sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git net-tools ufw fail2ban auditd
```

### Configuration SSH sécurisée (toutes VMs)

```bash
# Générer une paire de clés SSH sur le poste admin
ssh-keygen -t ed25519 -C "ytechadmin@ytech.local"

# Copier la clé publique sur la VM
ssh-copy-id -i ~/.ssh/id_ed25519.pub ytechadmin@<IP_VM>

# Durcir la configuration SSH
sudo nano /etc/ssh/sshd_config
```

```ini
# /etc/ssh/sshd_config — Configuration sécurisée
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
MaxAuthTries 2
MaxSessions 3
AllowUsers ytechadmin
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding no
AllowTcpForwarding no
```

```bash
sudo systemctl restart sshd

# Tester la connexion avant de fermer la session courante !
ssh -p 2222 -i ~/.ssh/id_ed25519 ytechadmin@<IP_VM>
```

### Installation Docker (toutes VMs)

```bash
# Désinstaller les anciennes versions
sudo apt remove docker docker-engine docker.io containerd runc

# Installer les dépendances
sudo apt install -y ca-certificates curl gnupg lsb-release

# Ajouter le dépôt officiel Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installer Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

# Permettre à l'utilisateur d'utiliser Docker sans sudo
sudo usermod -aG docker ytechadmin
newgrp docker

# Vérifier
docker --version
docker compose version
```

### Génération du certificat SSL (toutes VMs)

```bash
sudo mkdir -p /etc/ssl/ytech

sudo openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/ytech/ytech.key \
  -out /etc/ssl/ytech/ytech.crt \
  -subj "/C=MA/ST=Casablanca/L=Casablanca/O=Ytech Solutions/CN=<IP_VM>"

# Vérifier le certificat
openssl x509 -in /etc/ssl/ytech/ytech.crt -text -noout | grep -E "Subject|Validity"
```

![Génération certificat SSL](./img/ssl-cert-generated.png)
*Génération du certificat SSL auto-signé sur VM1*

### Configuration fail2ban (toutes VMs)

```bash
sudo apt install -y fail2ban

sudo cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime  = 3600    # 1 heure
findtime = 600     # fenêtre de 10 minutes
maxretry = 3       # 3 tentatives max

[sshd]
enabled  = true
port     = 2222
logpath  = /var/log/auth.log
maxretry = 3

[nginx-http-auth]
enabled  = true
EOF

sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Vérifier
sudo fail2ban-client status
```

### Configuration auditd (toutes VMs)

```bash
sudo apt install -y auditd

# Règles d'audit
sudo auditctl -w /etc/passwd -p wa -k user_modification
sudo auditctl -w /etc/shadow -p wa -k password_modification
sudo auditctl -w /etc/ssh/sshd_config -p wa -k ssh_config
sudo auditctl -w /var/log/ -p rwa -k log_access
sudo auditctl -w /etc/ssl/ -p rwa -k ssl_access

sudo systemctl enable auditd
sudo systemctl start auditd
```

---

## VM1 — Déploiement APP Server

### UFW — Règles firewall VM1

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH
sudo ufw allow from 192.168.56.0/24 to any port 2222
sudo ufw allow from 192.168.9.0/24 to any port 2222

# YtechBot
sudo ufw allow from 192.168.56.0/24 to any port 8501
sudo ufw allow from 192.168.9.0/24 to any port 8501
sudo ufw allow from 192.168.10.0/24 to any port 8501

# CRUD RH
sudo ufw allow from 192.168.56.0/24 to any port 8443
sudo ufw allow from 192.168.9.0/24 to any port 8443

# Ollama (interne uniquement)
sudo ufw allow from 192.168.56.0/24 to any port 11434

# Zabbix agent
sudo ufw allow from 192.168.56.30 to any port 10050

sudo ufw enable
sudo ufw status verbose
```

### Déploiement YtechBot + Ollama

```bash
# 1. Cloner le dépôt
git clone https://github.com/oussanea/Ytech_project.git
cd Ytech_project
git checkout feature/chatbot-ollama

# 2. Lancer les containers
docker compose -f docker-compose.prod.yml up -d

# 3. Vérifier que les containers sont UP
docker ps

# 4. Télécharger le modèle IA
docker exec -it ytech-ollama ollama pull llama3.2:1b
```

![Ollama — Téléchargement du modèle llama3.2:1b](./img/ollama-pull.png)
*Téléchargement du modèle llama3.2:1b via Ollama*

```bash
# 5. Vérifier que le modèle est disponible
docker exec -it ytech-ollama ollama list

# 6. Tester le chatbot
curl -k https://192.168.56.20:8501
```

### Installation agent Zabbix — VM1

```bash
wget https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/\
zabbix-release/zabbix-release_latest_7.4+ubuntu24.04_all.deb

sudo dpkg -i zabbix-release_latest_7.4+ubuntu24.04_all.deb
sudo apt update && sudo apt install -y zabbix-agent

sudo sed -i 's/^Server=.*/Server=192.168.56.30/' \
  /etc/zabbix/zabbix_agentd.conf
sudo sed -i 's/^ServerActive=.*/ServerActive=192.168.56.30/' \
  /etc/zabbix/zabbix_agentd.conf
sudo sed -i 's/^Hostname=.*/Hostname=VM1-APP-Server/' \
  /etc/zabbix/zabbix_agentd.conf

sudo systemctl restart zabbix-agent
sudo systemctl enable zabbix-agent
```

---

## VM2 — Déploiement DB Server

### UFW — Règles firewall VM2

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH
sudo ufw allow from 192.168.56.0/24 to any port 2222
sudo ufw allow from 192.168.9.0/24 to any port 2222

# MariaDB — uniquement depuis APP Server et Web Server
sudo ufw allow from 192.168.56.20 to any port 3306
sudo ufw allow from 192.168.9.253 to any port 3306
sudo ufw allow from 192.168.10.21 to any port 3306

# Zabbix agent
sudo ufw allow from 192.168.56.30 to any port 10050

# Bloquer MariaDB depuis tout autre source
sudo ufw deny 3306

sudo ufw enable
```

### Déploiement MariaDB

```bash
cd Ytech_project
git checkout feature/chatbot-ollama

# Lancer MariaDB
docker compose -f docker-compose.db.yml up -d

# Vérifier
docker ps
docker logs ytech-mariadb

# Vérifier la création des bases
docker exec -it ytech-mariadb mariadb \
  -u root -pRootPass123! \
  -e "SHOW DATABASES; SELECT User, Host FROM mysql.user;"
```

### Installation agent Zabbix — VM2

```bash
# (mêmes étapes que VM1, avec Hostname=VM2-DB-Server)
sudo sed -i 's/^Hostname=.*/Hostname=VM2-DB-Server/' \
  /etc/zabbix/zabbix_agentd.conf
sudo systemctl restart zabbix-agent
```

---

## VM3 — Déploiement Monitoring Server

### UFW — Règles firewall VM3

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH
sudo ufw allow from 192.168.56.0/24 to any port 2222

# Zabbix Web
sudo ufw allow from 192.168.56.0/24 to any port 8443
sudo ufw allow from 192.168.9.0/24 to any port 8443

# Bitwarden
sudo ufw allow from 192.168.56.0/24 to any port 8444

# Nessus
sudo ufw allow from 192.168.56.0/24 to any port 8834

# Headscale
sudo ufw allow from 192.168.56.0/24 to any port 8085
sudo ufw allow 3478/udp    # STUN

# Grafana
sudo ufw allow from 192.168.56.0/24 to any port 3000
sudo ufw allow from 192.168.9.0/24 to any port 3000
sudo ufw allow from 192.168.10.0/24 to any port 3000

# Zabbix server (communication avec agents)
sudo ufw allow 10050/tcp
sudo ufw allow 10051/tcp

sudo ufw enable
```

### Déploiement Stack Monitoring

```bash
cd Ytech_project
git checkout feature/monitoring

# 1. Stack principale (Zabbix + Bitwarden + Nessus + Nginx)
cd zabbix
docker compose up -d

# Attendre que Zabbix soit initialisé (~2 minutes)
docker logs -f zabbix-server | grep "Zabbix Server started"

# 2. Headscale
cd ~/Ytech_project/headscale
docker compose up -d

# Créer l'utilisateur Ytech dans Headscale
docker exec ytech-headscale headscale users create ytech

# 3. Grafana
cd ~/Ytech_project/grafana
docker compose up -d

# Vérifier tous les services
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

![Tous les services UP après déploiement](./img/services-running.png)
*Tous les services opérationnels après déploiement complet VM3*

### Configuration Headscale — Enregistrement des nodes

```bash
# Générer une clé d'enregistrement
docker exec ytech-headscale headscale preauthkeys create \
  --user ytech --expiration 24h

# Sur chaque serveur à connecter (APP Server, DB Server, etc.)
sudo tailscale up \
  --login-server=http://192.168.56.30:8085 \
  --hostname=app-server \
  --force-reauth

# Vérifier les nodes connectés
docker exec ytech-headscale headscale nodes list
```

### Installation agent Zabbix — VM3

```bash
# (mêmes étapes, Hostname=VM3-MGMT)
sudo sed -i 's/^Hostname=.*/Hostname=VM3-MGMT/' \
  /etc/zabbix/zabbix_agentd.conf
sudo systemctl restart zabbix-agent
```
## VM3 — Déploiement App-ecommerce Server
### VirtualBox – Ubuntu 24.04 LTS Server
 
La machine virtuelle a été créée avec **VirtualBox** en utilisant l'image ISO Ubuntu Server 24.04.4 LTS.
 
![Création VM VirtualBox](./img/vb.PNG)
 
**Configuration de la VM :**
 
| Paramètre | Valeur |
|-----------|--------|
| Nom VM | `webserver` |
| OS | Ubuntu 24.04 (64-bit) |
| ISO | `ubuntu-24.04.4-live-server-amd64.iso` |
| Installation | Unattended (automatique) |
| IP attribuée | `192.168.10.21` |
 
---
 
##  Connexion SSH au Serveur
 
###  Vérification du statut SSH
 
Avant de se connecter depuis la machine hôte, vérifier que le service SSH est actif sur le serveur :
 
```bash
sudo systemctl status ssh
```
 
![Statut SSH](./img/enablessh.PNG)
 
> **Note :** Le service `ssh.socket` assure l'activation à la demande (*socket activation*). Le statut `inactive (dead)` pour `ssh.service` est normal — le socket prend le relais et active le service dès qu'une connexion entrante arrive sur le port 22.
 
### Activation et démarrage de SSH
 
```bash
# Activer SSH au démarrage du système
sudo systemctl enable ssh
 
# Démarrer le service immédiatement
sudo systemctl start ssh
 
# Vérifier le statut
sudo systemctl status ssh
```
 
### Récupération de l'adresse IP
 
```bash
ip a
```
 
![Adresse IP du serveur](./img/ip.PNG)
 
L'interface réseau `enp0s3` porte l'adresse **`192.168.10.21/24`**. C'est l'adresse utilisée pour toutes les connexions SSH et HTTPS.
 
###  Connexion via MobaXterm
 
La connexion SSH est établie depuis Windows avec **MobaXterm** :
 
![Configuration SSH MobaXterm](./img/ssh.PNG)
 
**Paramètres de connexion :**
 
| Champ | Valeur |
|-------|--------|
| Remote host | `192.168.10.21` |
| Username | `vboxuser` |
| Port | `22` |
| Type | SSH |
 
![Session SSH active](./img/accesssh.PNG)
 
> ✅ Connexion réussie — Ubuntu 24.04.4 LTS confirmé, mémoire : 0.36 GB / 1.92 GB, IP `192.168.10.21`
 
### Pourquoi SSH plutôt que la console directe ?
 
| Critère | Console VM | SSH (MobaXterm) |
|---------|-----------|-----------------|
| Copier/coller | ❌ Difficile | ✅ Natif |
| Transfert de fichiers | ❌ Non | ✅ SFTP intégré |
| Multi-sessions | ❌ Une seule | ✅ Plusieurs onglets |
| Chiffrement | ❌ Non | ✅ AES-256 |
| X11 Forwarding | ❌ | ✅ Activé |
 
---
 
## Mise à Jour du Système
 
Avant toute installation, mettre à jour la liste des paquets et appliquer les mises à jour :
 
```bash
sudo apt update && sudo apt upgrade -y
```
 
![Mise à jour système](./img/update.PNG)
 
**Paquets mis à jour :** `cloud-init`, `nftables`, `libnftables1`, `linux-base`, `systemd-hwe-hwdb`, `sosreport`, `software-properties-common`, etc.
 
> 💡 `apt update` rafraîchit la liste des paquets disponibles depuis les dépôts Ubuntu (`ma.archive.ubuntu.com`). `apt upgrade` installe les nouvelles versions. Le flag `-y` confirme automatiquement toutes les invites.
 
---
 
##  Installation des Dépendances (PHP, Nginx)
 
### Commande d'installation complète
 
```bash
sudo apt install nginx php-fpm php-mysql php-xml \
  php-curl php-gd php-mbstring php-zip php-intl php-bcmath \
  php-cli unzip git -y
```
 
![Installation PHP Nginx](./img/installingphpmysql.PNG)
 
> **Note :** MySQL n'est **pas** installé sur ce serveur — la base de données est hébergée sur un serveur dédié (`192.168.10.2`). L'extension `php-mysql` est nécessaire pour que PHP puisse établir la connexion PDO distante.
 
### Paquets installés et leurs rôles
 
| Paquet | Version | Rôle |
|--------|---------|------|
| `nginx` | latest | Serveur web / reverse proxy SSL |
| `php8.3-fpm` | 8.3 | PHP FastCGI Process Manager |
| `php8.3-mysql` | 8.3 | Extension PDO pour connexion MySQL distante |
| `php8.3-xml` | 8.3 | Traitement XML (requis par Laravel) |
| `php8.3-curl` | 8.3 | Requêtes HTTP vers APIs externes |
| `php8.3-gd` | 8.3 | Manipulation d'images (thumbnails, etc.) |
| `php8.3-mbstring` | 8.3 | Gestion des chaînes multi-octets (UTF-8) |
| `php8.3-zip` | 8.3 | Compression/décompression de fichiers |
| `php8.3-intl` | 8.3 | Internationalisation (formats dates, devises) |
| `php8.3-bcmath` | 8.3 | Calculs arithmétiques précis (prix, taxes) |
| `git` | 2.43.0 | Versioning et clonage du code source |
| `unzip` | latest | Décompression d'archives |
 
### Vérification et démarrage des services
 
```bash
php -v
# PHP 8.3.x (cli) — vérifier que la version est bien 8.3
 
# Vérifier les extensions chargées
php -m | grep -E "mysql|curl|gd|zip|mbstring|intl|bcmath"
 
# Activer et démarrer Nginx
sudo systemctl enable --now nginx
 
# Activer et démarrer PHP-FPM
sudo systemctl enable --now php8.3-fpm
 
# Vérifier les statuts
sudo systemctl status nginx
sudo systemctl status php8.3-fpm
```
 
![Version PHP](./img/php.PNG)
 
---
---

## Vérification finale — Checklist

Après déploiement complet, vérifier chaque point :

```bash
# ── VM1 ─────────────────────────────────────────────────
✅ docker ps → ytech-chatbot, ytech-ollama UP
✅ curl -k https://192.168.56.20:8501 → réponse 200
✅ curl http://192.168.56.20:11434/api/tags → modèle llama3.2:1b listé
✅ sudo ufw status → règles actives
✅ sudo fail2ban-client status → actif
✅ sudo systemctl status zabbix-agent → running

# ── VM2 ─────────────────────────────────────────────────
✅ docker ps → ytech-mariadb UP
✅ docker exec -it ytech-mariadb mariadb -u root -p → connexion OK
✅ SHOW DATABASES → ytech_chatbot, ytech_rh, ytech_clients présentes
✅ sudo ufw status → port 3306 restreint aux IPs autorisées

# ── VM3 ─────────────────────────────────────────────────
✅ docker ps → 8 containers UP (zabbix-db, zabbix-server, zabbix-web,
              bitwarden, nessus, nginx-proxy, headscale, grafana)
✅ curl -k https://192.168.56.30:8443 → Zabbix login OK
✅ curl -k https://192.168.56.30:8444 → Bitwarden OK
✅ curl -k https://192.168.56.30:8834 → Nessus OK
✅ curl http://192.168.56.30:3000 → Grafana OK
✅ curl http://192.168.56.30:8085/api/v1/node → Headscale API OK
✅ docker exec headscale headscale nodes list → nodes connectés
✅ Zabbix → 4 hosts en vert dans le dashboard
```

:::tip Durée totale de déploiement
Avec ce guide et Docker, le déploiement complet de l'infrastructure (VM1 + VM2 + VM3) prend environ **90 minutes** pour un membre familier avec Linux. Sans Docker et sans documentation, le même déploiement manuel prendrait **plusieurs jours**.
:::