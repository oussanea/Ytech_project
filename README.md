# Ytech Solutions — Monitoring & Sécurité 📊

## Description
Infrastructure de monitoring et sécurité déployée sur VLAN 30.
Surveille en temps réel tous les serveurs de Ytech Solutions.

## Services déployés

| Service | Rôle | Port | HTTPS |
|---|---|---|---|
| Zabbix | Monitoring réseau | 8443 | ✅ |
| Bitwarden | Gestionnaire MDP | 8443/bitwarden | ✅ |
| Nginx | Reverse proxy HTTPS | 443/80 | ✅ |

## Accès

### Zabbix Dashboard
```
https://192.168.56.30:8443
Username : Admin
Password : zabbix
```

### Bitwarden
```
https://192.168.56.30:8443/bitwarden
```

## Serveurs surveillés

| Host | IP | Status |
|---|---|---|
| Chatbot-Ollama | 192.168.56.20 | ✅ Vert |
| MariaDB-Server | 192.168.56.25 | ✅ Vert |
| MGMT-Zabbix | 192.168.56.30 | ✅ Vert |

## Installation

### Prérequis
- Ubuntu Server 22.04
- Docker + Docker Compose
- Certificat SSL généré

### Générer le certificat SSL
```bash
sudo mkdir -p /etc/ssl/ytech
sudo openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/ytech/ytech.key \
  -out /etc/ssl/ytech/ytech.crt \
  -subj "/C=MA/ST=Casablanca/O=Ytech Solutions/CN=192.168.56.30"
```

### Lancer les services
```bash
git clone https://github.com/oussanea/Ytech_project.git
cd Ytech_project
git checkout feature/monitoring
cd zabbix
docker-compose up -d
```

### Installer Zabbix Agent sur les serveurs
```bash
wget https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.4+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_latest_7.4+ubuntu24.04_all.deb
sudo apt update
sudo apt install -y zabbix-agent

sudo nano /etc/zabbix/zabbix_agentd.conf
# Server=IP_ZABBIX_DOCKER
# ServerActive=IP_ZABBIX_DOCKER
# Hostname=NOM_SERVEUR

sudo systemctl restart zabbix-agent
sudo systemctl enable zabbix-agent
```

## Architecture VLAN 30
```
VM3 — 192.168.56.30
└── Docker
    ├── Nginx (reverse proxy HTTPS)
    ├── Zabbix Server
    ├── Zabbix Web
    ├── Zabbix DB (MySQL)
    └── Bitwarden (Vaultwarden)
```

## Note déploiement
Les IPs 192.168.56.x sont utilisées pour la simulation VirtualBox.
En production réelle sur GNS3 :
- VM3 MGMT → 192.168.30.10

## Membres
- Monitoring & DevOps : Raja JARFANI
- Projet : Ytech Solutions — JobInTech Cybersécurité Casablanca

## Licence
Projet académique — JobInTech 2025
