---
id: equipe
title: Équipe
sidebar_position: 4
---

# Équipe

## Groupe 4 — JobInTech Cybersécurité Casablanca 2025

Le projet a été réalisé par une équipe de **5 membres**, chacun responsable d'un périmètre technique précis, avec des zones de collaboration entre membres.

---

## Répartition des rôles

| Membre | Rôle principal | Branche GitHub |
|---|---|---|
| **Raja JARFANI** | Chef de projet + Chatbot IA + MariaDB + Monitoring + DevOps | `feature/chatbot-ollama` / `feature/monitoring` |
| **Asmaa ELKOURTI** | Hardening Ubuntu + OPNSense + WireGuard + Suricata | `feature/hardening` |
| **Sara OUSSANEA** | App CRUD RH + Nessus + Headscale agents | `hr-crud-app-feature` |
| **Meriem ASSADI** | App Web Laravel + Wazuh SIEM + Backup | `app-ecommerce` |
| **Chaymae TARIQ** | Achitecture Améliorée + Cisco + Grafana SOC Dashboard | `feature/network` |

---

## Détail des responsabilités

### Raja JARFANI

- **Organisation et coordination** du projet sur les 5 semaines (Jira, sprints, répartition des tâches)
- Mise en place et gestion du **dépôt GitHub** (structure des branches, revues)
- Animation des points d'équipe et synchronisation entre les membres
- Développement du chatbot **YtechBot** (Streamlit + Ollama + llama3.2:1b)
- Déploiement et configuration de **MariaDB** (3 bases de données séparées)
- Mise en place du stack monitoring : **Zabbix**, **Bitwarden**, **Nessus**, **Headscale**, **Grafana**
- Coordination DevOps : Docker Compose, certificats SSL

### Asmaa  ELKOURTI
- Installation et configuration de **OPNSense** (firewall externe, NAT, failover ISP)
- Mise en place de **Suricata IDS/IPS** en mode inline
- Déploiement du **VPN WireGuard**
- **Hardening** complet des VMs Ubuntu (SSH, UFW, fail2ban, auditd)

### Sara OUSSANEA
- Développement de l'**application CRUD RH** (PHP 8.1 + Apache + Docker)
- Configuration des **agents Tailscale** sur les postes et serveurs
- Scans de vulnérabilités avec **Nessus** (avant et après sécurisation)

### Meriem ASSADI
- Développement de l'**application Web commerciale** (Laravel + Nginx)
- Déploiement du **WAF ModSecurity** avec règles OWASP CRS
- Installation et configuration de **Wazuh SIEM** (manager + agents)
- Mise en place du **serveur de backup** (règle 3-2-1, AES-256, rclone Google Drive)

### Chaymae TARIQ
- Simulation réseau avec **Cisco** (topologie VLAN complète)
- Conception et déploiement du **Grafana SOC Dashboard** (sources : Zabbix + Wazuh + Nessus + Headscale)

---

## Infrastructure physique

L'infrastructure a été simulée sur **plusieurs machines physiques** en réseau bridge :

| PC | Membre | VMs hébergées |
|---|---|---|
| PC Raja | Raja | VM1 (App+Chatbot) · VM2 (MariaDB) · VM3 (Monitoring) |
| PC Meryem | Meryem | VM Web Server · VM Wazuh · VM Backup |
| VM OPNSense | Asmaa | Firewall OPNSense |

---

## Collaboration

Les membres ont travaillé en coordination étroite, notamment pour :

- L'interconnexion des VMs en réseau bridge (même sous-réseau de classe)
- La configuration des agents Wazuh et Tailscale sur les serveurs de chacun
- La centralisation des données dans Grafana (sources multi-membres)
