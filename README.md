# Ytech Solutions — Monitoring & Sécurité 📊

## Description
Infrastructure de monitoring et sécurité déployée sur VLAN 30.
Surveille en temps réel tous les serveurs de Ytech Solutions.

## Services déployés

| Service | Rôle | Port | HTTPS |
|---|---|---|---|
| Zabbix | Monitoring réseau | 8443 | ✅ |
| Bitwarden | Gestionnaire MDP | 8444 | ✅ |
| Nginx | Reverse proxy HTTPS | 443/80 | ✅ |

## Accès

### Zabbix Dashboard
```
https://192.168.56.30:8443
```

### Bitwarden
```
https://192.168.56.30:8444
```

## Serveurs surveillés

| Host | IP | Rôle | Status |
|---|---|---|---|
| App-Server | 192.168.56.20 | Chatbot + App CRUD RH | ✅ Vert |
| MariaDB-Server | 192.168.56.25 | Base de données | ✅ Vert |
| Monitoring-Server | 192.168.56.30 | Monitoring + Sécurité | ✅ Vert |
| Web-Server | 192.168.10.21 | App Web commerciale | ✅ Vert |

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
# Server=IP_BRIDGE_VM3
# ServerActive=IP_BRIDGE_VM3
# Hostname=NOM_SERVEUR

sudo systemctl restart zabbix-agent
sudo systemctl enable zabbix-agent
sudo ufw allow 10050/tcp
```

## Architecture VLAN 30
```
VM3 — 192.168.56.30
└── Docker
    ├── Nginx (reverse proxy)
    │   ├── port 8443 → Zabbix
    │   └── port 8444 → Bitwarden
    ├── Zabbix Server
    ├── Zabbix Web
    ├── Zabbix DB (MySQL)
    └── Bitwarden (Vaultwarden)
```

## Historique des modifications
- ✅ Zabbix déployé avec HTTPS
- ✅ Bitwarden déployé avec HTTPS
- ✅ Ports séparés → Zabbix:8443 / Bitwarden:8444
- ✅ 4 agents Zabbix configurés
- ✅ Compte admin Bitwarden créé → admin@ytech.com

## Note déploiement
Les IPs 192.168.56.x sont utilisées pour la simulation VirtualBox.
En production réelle sur GNS3 :
- VM3 MGMT → 192.168.30.10

## Membres
- Monitoring & DevOps : Raja JARFANI
- Projet : Ytech Solutions — JobInTech Cybersécurité Casablanca

## Licence
Projet académique — JobInTech 2025
