# Ytech Solutions — Monitoring & Sécurité 📊

Infrastructure de monitoring, sécurité et Zero Trust déployée sur **VLAN 30**.
Surveille en temps réel tous les serveurs de Ytech Solutions.

---

## Services déployés

| Service | Rôle | Port | HTTPS |
|---------|------|------|-------|
| Zabbix | Monitoring réseau & alertes | 8443 | ✅ |
| Bitwarden | Gestionnaire mots de passe | 8444 | ✅ |
| Nginx | Reverse proxy HTTPS | 443/80 | ✅ |
| Nessus | Scanner de vulnérabilités | 8834 | ✅ |
| Headscale | Zero Trust VPN (serveur) | 8085 | — |
| Headscale UI | Interface web Headscale | 9080/9443 | ✅ |
| Grafana | SOC Dashboard unifié | 3000 | ✅ |

---

## Accès

### Zabbix
```
https://192.168.56.30:8443
https://192.168.10.5:8443  (Bridge classe)
```

### Bitwarden
```
https://192.168.56.30:8444
https://192.168.10.5:8444  (Bridge classe)
```

### Nessus
```
https://192.168.56.30:8834
https://192.168.10.5:8834  (Bridge classe)
```

### Headscale API
```
http://192.168.56.30:8085/api/v1
http://192.168.10.5:8085/api/v1  (Bridge classe)
```

### Headscale UI
```
http://192.168.56.30:9080
http://192.168.10.5:9080  (Bridge classe)
```

### Grafana SOC Dashboard
```
http://192.168.56.30:3000
http://192.168.10.5:3000  (Bridge classe)
```

---

## Serveurs surveillés (Zabbix + Tailscale)

| Host | IP Host-Only | IP Bridge | Rôle | Zabbix | Tailscale |
|------|-------------|-----------|------|--------|-----------|
| App-Server | 192.168.56.20 | 192.168.9.253 | Chatbot + App CRUD RH | ✅ Vert | ✅ online |
| MariaDB-Server | 192.168.56.25 | 192.168.10.2 | Base de données | ✅ Vert | ✅ online |
| Monitoring-Server | 192.168.56.30 | 192.168.10.5 | Monitoring + Sécurité | ✅ Vert | ✅ online |
| Web-Server | — | 192.168.10.21 | App Web Laravel + WAF | ✅ Vert | ✅ online |
| Backup-Server | — | 192.168.9.251 | Backup AES-256 | ✅ Vert | ✅ online |

---

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

### Lancer Zabbix + Bitwarden + Nginx

```bash
git clone https://github.com/oussanea/Ytech_project.git
cd Ytech_project
git checkout feature/monitoring
cd zabbix
docker-compose up -d
```

### Lancer Nessus

```bash
# Télécharger depuis https://www.tenable.com/downloads/nessus
scp Nessus-*.deb raja@192.168.56.30:/home/raja/

sudo dpkg -i Nessus-*.deb
sudo systemctl start nessusd
sudo systemctl enable nessusd
sudo ufw allow 8834/tcp

# Accéder à https://192.168.56.30:8834 pour configurer
# Choisir "Register for Nessus Essentials" → code d'activation par email
```

### Lancer Headscale (Zero Trust)

```bash
mkdir ~/headscale && cd ~/headscale
# Placer config.yaml dans ~/headscale/config/

docker-compose up -d

# Lancer Headscale UI
docker run -d \
  --name headscale-ui \
  --restart unless-stopped \
  --network host \
  -e PORT=9080 \
  -e HTTP_PORT=9080 \
  -e HTTPS_PORT=9443 \
  ghcr.io/gurucomputing/headscale-ui:latest

# Créer une API key
docker exec headscale headscale apikeys create --expiration 365d

# Créer un utilisateur
docker exec headscale headscale users create ytech
```

### Connecter un agent Tailscale sur un serveur

```bash
# Sur chaque serveur à connecter
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up \
  --login-server=http://192.168.10.5:8085 \
  --hostname=<nom-serveur> \
  --force-reauth

# Sur la VM Monitoring — enregistrer le node
docker exec headscale headscale nodes register --user ytech --key <KEY>
```

### Lancer Grafana SOC Dashboard

```bash
mkdir ~/grafana && cd ~/grafana
# Placer docker-compose.yml + provisioning/

docker-compose up -d
sudo ufw allow from 192.168.9.0/24 to any port 3000
sudo ufw allow from 192.168.10.0/24 to any port 3000
sudo ufw allow from 192.168.56.0/24 to any port 3000
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

---

## Règles UFW — VM Monitoring

```bash
# Zabbix
sudo ufw allow proto tcp from 192.168.56.0/24 to any port 8443
sudo ufw allow from 192.168.9.0/24 to any port 8443
sudo ufw allow from 192.168.10.0/24 to any port 8443

# Bitwarden
sudo ufw allow from 192.168.9.0/24 to any port 8444
sudo ufw allow from 192.168.10.0/24 to any port 8444

# Nessus
sudo ufw allow from 192.168.9.0/24 to any port 8834
sudo ufw allow from 192.168.10.0/24 to any port 8834

# Headscale
sudo ufw allow from 192.168.9.0/24 to any port 8085
sudo ufw allow from 192.168.10.0/24 to any port 8085
sudo ufw allow from 192.168.9.0/24 to any port 9080
sudo ufw allow from 192.168.10.0/24 to any port 9080

# Grafana
sudo ufw allow from 192.168.9.0/24 to any port 3000
sudo ufw allow from 192.168.10.0/24 to any port 3000
sudo ufw allow from 192.168.56.0/24 to any port 3000

# Zabbix agents
sudo ufw allow from 192.168.56.0/24 to any port 10050
sudo ufw allow from 192.168.9.0/24 to any port 10050
sudo ufw allow from 192.168.10.0/24 to any port 10050

# SSH
sudo ufw allow from 192.168.56.0/24 to any port 22
sudo ufw allow from 192.168.9.0/24 to any port 22
sudo ufw allow from 192.168.10.0/24 to any port 22
```

---

## Architecture VLAN 30

```
VM3 — 192.168.56.30 (Host-Only) | 192.168.10.5 (Bridge)
└── Docker
    ├── ~/zabbix/
    │   ├── Nginx (reverse proxy TLS 1.3)
    │   │   ├── port 8443 → Zabbix
    │   │   └── port 8444 → Bitwarden
    │   ├── Zabbix Server
    │   ├── Zabbix Web
    │   ├── Zabbix DB (MySQL 8.0)
    │   └── Bitwarden (Vaultwarden)
    │
    ├── ~/headscale/
    │   ├── Headscale Server (port 8085)
    │   └── Headscale UI (port 9080/9443)
    │
    └── ~/grafana/
        └── Grafana SOC (port 3000)
            ├── Source: Zabbix (8443)
            ├── Source: Wazuh/Elasticsearch (9200)
            ├── Source: Nessus API (8834)
            └── Source: Headscale API (8085)

Nessus — installé directement (pas Docker)
    └── /opt/nessus/ — port 8834
```

---

## Grafana SOC Dashboard — Sources de données

| Source | URL | Auth |
|--------|-----|------|
| Zabbix | `https://127.0.0.1:8443/api_jsonrpc.php` | user: `grafana` |
| Wazuh | `https://IP_MERYEM:9200` | user: `admin` |
| Nessus | `https://127.0.0.1:8834` | Header: `X-ApiKeys` |
| Headscale | `http://127.0.0.1:8085` | Header: `Authorization: Bearer` |

Plugins requis :
- `alexanderzobnin-zabbix-app`
- `marcusolsson-json-datasource`

---

## Nodes Tailscale connectés

```bash
# Lister les nodes
docker exec headscale headscale nodes list

# Résultat attendu :
# app-server      100.64.0.1  online
# web-server      100.64.0.2  online
# backup-server   100.64.0.3  online
# db-server       100.64.0.4  online
# monitoring-server 100.64.0.5 online
```

---

## Historique des modifications

- ✅ Zabbix déployé avec HTTPS (TLS 1.3)
- ✅ Bitwarden déployé avec HTTPS
- ✅ Ports séparés → Zabbix:8443 / Bitwarden:8444
- ✅ 4+ agents Zabbix configurés
- ✅ Compte admin Bitwarden créé → admin@ytech.com
- ✅ Nessus Essentials installé et configuré (port 8834)
- ✅ Headscale Zero Trust Server déployé (port 8085)
- ✅ Headscale UI déployé (port 9080)
- ✅ 5 nodes Tailscale connectés (app, db, web, backup, monitoring)
- ✅ Grafana SOC Dashboard déployé (port 3000)
- ✅ Grafana connecté à Zabbix + Nessus + Headscale
- ✅ Wazuh intégration en cours (VM Meryem)
- ✅ UFW configuré — accès restreint par réseau

---

## Note déploiement

Les IPs `192.168.56.x` sont utilisées pour la simulation VirtualBox (Host-Only).
Les IPs `192.168.10.x` / `192.168.9.x` sont les IPs Bridge (réseau classe).

En production réelle sur GNS3 :

| VM | IP réelle |
|----|-----------|
| VM3 MGMT | 192.168.30.10 |
| Headscale | 192.168.30.30 |
| Grafana | 192.168.30.50 |

---

## Membres

- **Monitoring, Sécurité & DevOps** : Raja JARFANI
- **Projet** : Ytech Solutions — JobInTech Cybersécurité Casablanca 2025
- **GitHub** : [github.com/oussanea/Ytech_project](https://github.com/oussanea/Ytech_project)

---

## Licence

Projet académique — JobInTech 2025
