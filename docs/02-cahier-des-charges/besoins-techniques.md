---
id: besoins-techniques
title: Besoins techniques
sidebar_position: 2
---

# Besoins techniques

## Vue d'ensemble

Les besoins techniques définissent les contraintes d'infrastructure, de performance, de disponibilité et d'interopérabilité que le système doit respecter indépendamment des fonctionnalités métier.

---

## BT-01 — Infrastructure réseau

### Segmentation obligatoire

L'infrastructure doit être **strictement segmentée** par VLAN. Aucun équipement ne doit pouvoir communiquer librement avec un autre sans règle firewall explicite.

| VLAN | Nom | Réseau | Rôle |
|---|---|---|---|
| VLAN 10 | DMZ | `192.168.10.0/24` | Application web publique |
| VLAN 20 | APP | `192.168.20.0/24` | App CRUD RH + Chatbot |
| VLAN 25 | DB | `192.168.25.0/24` | Serveur MariaDB |
| VLAN 30 | MGMT | `192.168.30.0/24` | Monitoring + Headscale + Wazuh + Grafana |
| VLAN 40 | USERS | `192.168.40.0/24` | 24 postes employés Windows |
| VLAN 50 | ADMIN | `192.168.50.0/24` | Bastion SSH + Kali Linux |
| VLAN 60 | BACKUP | `192.168.60.0/24` | Serveur de sauvegarde |

### Double firewall

| Équipement | Rôle |
|---|---|
| **OPNSense** | Firewall périmétrique, NAT, Suricata IDS/IPS, WireGuard VPN, failover ISP |
| **Cisco ACL** | Contrôle des flux inter-VLAN sur le Core Switch |

### Haute disponibilité WAN

- Deux connexions Internet (ISP1 principal + ISP2 backup)
- Basculement automatique en cas de perte de paquets ou latence excessive (Gateway Group OPNSense)

---

## BT-02 — Serveurs et virtualisation

### Environnement de simulation

Le projet est simulé sur **VirtualBox** avec deux modes réseau par VM :

| Mode | Utilité |
|---|---|
| **Host-Only** | Communication entre VMs sur le même PC |
| **Bridged** | Communication entre VMs de PCs différents (réseau de classe) |

### VMs déployées

| VM | Services | IP Host-Only | IP Bridge |
|---|---|---|---|
| **APP Server** (Raja) | YtechBot + CRUD RH | `192.168.56.20` | `192.168.9.253` |
| **DB Server** (Raja) | MariaDB 3 bases | `192.168.56.25` | `192.168.10.2` |
| **Monitoring** (Raja) | Zabbix + Bitwarden + Nessus + Headscale + Grafana | `192.168.56.30` | `192.168.10.5` |
| **Web Server** (Meryem) | Laravel + Nginx + WAF | — | `192.168.10.21` |
| **Wazuh** (Meryem) | Wazuh SIEM | — | `192.168.9.152` |
| **Backup** (Meryem) | Rsync + AES-256 + rclone | — | `192.168.9.251` |
| **OPNSense** (Asmaa) | Firewall | — | `192.168.9.178` |

### Conteneurisation

Tous les services sont déployés via **Docker Compose** pour garantir l'isolation, la reproductibilité et la facilité de mise à jour.

```
VM1 → docker-compose.prod.yml   (YtechBot + Ollama)
VM2 → docker-compose.db.yml     (MariaDB)
VM3 → docker-compose.yml        (Zabbix + Bitwarden + Nessus + Nginx proxy)
     + headscale/docker-compose.yml
     + grafana/docker-compose.yml
```

---

## BT-03 — Sécurité des communications

### Chiffrement en transit

| Protocole | Utilisation | Version |
|---|---|---|
| TLS | Toutes les interfaces web | TLS 1.3 uniquement |
| WireGuard | VPN accès distant | UDP 51820 |
| Tailscale | Tunnels Zero Trust inter-serveurs | WireGuard sous-jacent |
| SSH | Administration des serveurs | Port 2222 (non-standard) |

### Certificats SSL

Les certificats utilisés sont **auto-signés** (environnement de simulation) :

```bash
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/ytech/ytech.key \
  -out /etc/ssl/ytech/ytech.crt \
  -subj "/C=MA/ST=Casablanca/O=Ytech Solutions/CN=<IP_VM>"
```

:::note Production
En environnement de production réel, les certificats auto-signés seraient remplacés par des certificats **Let's Encrypt** ou d'une PKI interne.
:::

---

## BT-04 — Ports exposés par serveur

### APP Server (`192.168.9.253`)

| Port | Service | Accès |
|---|---|---|
| `22` | SSH | Équipe interne |
| `8443` | HR App (HTTPS) | Réseau interne |
| `8501` | YtechBot Streamlit | Réseau interne |
| `11434` | Ollama API | Interne uniquement |

### DB Server (`192.168.10.2`)

| Port | Service | Accès autorisé |
|---|---|---|
| `22` | SSH | Équipe + Meryem |
| `3306` | MariaDB | APP Server + Web Server uniquement |

### Monitoring (`192.168.10.5`)

| Port | Service |
|---|---|
| `8443` | Zabbix (HTTPS) |
| `8444` | Bitwarden (HTTPS) |
| `8834` | Nessus |
| `8085` | Headscale API |
| `9080` | Headscale UI |
| `3000` | Grafana |
| `10050/10051` | Zabbix agent/server |

---

## BT-05 — Disponibilité et supervision

| Exigence | Solution retenue |
|---|---|
| Supervision serveurs | Zabbix + agents sur toutes les VMs |
| Détection d'intrusion | Wazuh SIEM + agents + Suricata |
| Tableau de bord SOC | Grafana (sources : Zabbix + Wazuh + Nessus + Headscale) |
| Scan de vulnérabilités | Nessus Essentials (avant et après sécurisation) |
| Uptime services | Redémarrage automatique Docker (`restart: always`) |

---

## BT-06 — Gestion du code et versioning

| Exigence | Solution |
|---|---|
| Dépôt Git | GitHub — `github.com/oussanea/Ytech_project` |
| Stratégie de branches | Une branche par membre (`feature/xxx`) |
| Fichier README | Présent à la racine du dépôt |
| Documentation | Docusaurus (présent document) |

---

## BT-07 — Sauvegarde

| Critère | Valeur |
|---|---|
| Fréquence | Quotidienne — cron à 02h00 |
| Rétention locale | 7 jours |
| Chiffrement | AES-256-CBC avec clé `/etc/backup.key` |
| Stockage distant | Google Drive via rclone |
| Règle appliquée | **3-2-1** : 3 copies, 2 supports, 1 hors site |
| Périmètre | Bases MariaDB + App Web + Configs services |
