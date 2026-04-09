---
id: exigences-securite
title: Exigences de sécurité
sidebar_position: 3
---

# Exigences de sécurité

## Vue d'ensemble

Les exigences de sécurité définissent les mesures **obligatoires** que l'infrastructure doit respecter pour garantir la confidentialité, l'intégrité et la disponibilité des données de Ytech Solutions, en conformité avec les principes ISO/IEC 27001.

:::info Principe directeur
Toute communication non explicitement autorisée est **bloquée par défaut** (deny by default). Ce principe s'applique au firewall OPNSense, aux règles inter-VLAN Cisco, et aux politiques Headscale/Tailscale.
:::

---

## ES-01 — Contrôle d'accès réseau

| Exigence | Mesure retenue | Composant |
|---|---|---|
| Isoler les zones réseau | Segmentation 7 VLANs | OPNSense + Cisco 2960 |
| Bloquer les flux non autorisés | Politique deny-by-default | OPNSense |
| Filtrer les flux inter-VLAN | ACL Cisco sur le Core Switch | Cisco 2960 |
| Détecter les intrusions | IDS/IPS inline | Suricata (OPNSense) |
| Sécuriser les accès distants | VPN chiffré | WireGuard UDP 51820 |

### Règles firewall critiques

```
✅ ALLOW : Internet → Web Server (HTTPS 443)
✅ ALLOW : Web Server → DB Server (3306, db_clients uniquement)
✅ ALLOW : App Server → DB Server (3306, db_rh uniquement)
✅ ALLOW : Tailscale ZT → APP / DB (MFA obligatoire)
✅ ALLOW : Wazuh agents → collecte logs tous serveurs

✗ BLOCK : Internet → DB Server (toujours)
✗ BLOCK : Internet → APP Server (toujours)
✗ BLOCK : Internet → MGMT / BACKUP (toujours)
✗ BLOCK : USERS → DB Server direct (toujours)
✗ BLOCK : Tout accès non listé → deny
```

---

## ES-02 — Zero Trust Network Access

L'accès aux ressources internes suit le modèle **Zero Trust** : aucun utilisateur ni serveur n'est implicitement de confiance, même à l'intérieur du réseau.

| Composant | Rôle |
|---|---|
| **Headscale** | Serveur de contrôle Zero Trust (auto-hébergé) |
| **Tailscale** | Agents sur chaque serveur et poste admin |
| **MFA** | Obligatoire pour tout accès aux ressources sensibles |

### Politiques d'accès Headscale

| Groupe | Accès autorisé |
|---|---|
| Administrateurs IT | Tous VLANs (SSH + HTTP) |
| Développeurs | APP Server uniquement |
| RH | CRUD App `.20.10` (HTTPS) |
| Tous | Bloqué vers DB Server en direct |

---

## ES-03 — Durcissement des serveurs (Hardening)

Chaque serveur Ubuntu déployé respecte les règles de durcissement suivantes :

### SSH
```ini
Port 2222                   # Port non standard
PermitRootLogin no          # Connexion root interdite
PasswordAuthentication no   # Clés SSH uniquement
MaxAuthTries 2              # 2 tentatives max
AllowUsers ytechadmin       # Utilisateur unique autorisé
ClientAliveInterval 300     # Timeout session 5 min
```

### UFW (pare-feu local)
- Politique par défaut : `deny incoming`, `allow outgoing`
- Règles explicites par service et par IP source
- Aucun port ouvert au monde entier sauf nécessité absolue

### fail2ban
- `maxretry = 3` — bannissement après 3 échecs
- `bantime = 1h` — durée de bannissement
- Surveillance SSH + services web

### auditd
- Surveillance des modifications sur `/etc/passwd`, `/etc/shadow`
- Logs complets sur `/var/log/`
- Alertes remontées vers Wazuh SIEM

---

## ES-04 — Chiffrement

| Niveau | Algorithme | Utilisation |
|---|---|---|
| Transport web | TLS 1.3 | Toutes les interfaces HTTPS |
| VPN | WireGuard (ChaCha20) | Accès distant |
| Zero Trust | WireGuard (Tailscale) | Tunnels inter-serveurs |
| Sauvegardes | AES-256-CBC | Archives chiffrées |
| Mots de passe applicatifs | bcrypt | YtechBot, CRUD RH |
| Mots de passe équipe | Coffre Bitwarden | Vaultwarden auto-hébergé |

### Headers de sécurité HTTP

Les serveurs web appliquent les headers suivants :

```http
Strict-Transport-Security: max-age=31536000
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Content-Security-Policy: default-src 'self'
```

---

## ES-05 — Protection applicative (WAF)

L'application web commerciale est protégée par **ModSecurity** avec les règles **OWASP Core Rule Set** :

| Protection | Attaques couvertes |
|---|---|
| Injection SQL | `' OR 1=1 --`, UNION-based, Blind SQLi |
| Cross-Site Scripting | XSS réfléchi, stocké, DOM-based |
| Path Traversal | `../../../etc/passwd` |
| Remote File Inclusion | Inclusion de fichiers distants |
| Scanner detection | Blocage des scanners web automatisés |

Logs d'audit : `/var/log/modsec_audit.log`

---

## ES-06 — Supervision et détection

| Outil | Rôle | Périmètre |
|---|---|---|
| **Zabbix** | Monitoring infrastructure (CPU, RAM, réseau, services) | Toutes les VMs |
| **Wazuh SIEM** | Collecte et corrélation des logs de sécurité | APP, DB, Web servers |
| **Suricata** | Détection/blocage d'intrusions réseau | Interface WAN OPNSense |
| **Nessus** | Scan de vulnérabilités | Infrastructure complète |
| **Grafana** | Tableau de bord SOC centralisé | Toutes sources |

:::tip Corrélation des événements
Grafana agrège les données de Zabbix, Wazuh et Nessus dans un seul tableau de bord SOC, permettant une vision unifiée de la posture de sécurité en temps réel.
:::

---

## ES-07 — Gestion des identités et des accès

| Exigence | Mesure |
|---|---|
| Mots de passe forts centralisés | Bitwarden (Vaultwarden auto-hébergé) |
| Séparation des comptes BDD | Un utilisateur MariaDB par application |
| Principe du moindre privilège | Droits SQL limités par base et par IP source |
| Traçabilité des accès | Logs auditd + Wazuh + fail2ban |
| Blocage brute-force applicatif | 3 tentatives → blocage 15 min (YtechBot) |
| Timeout de session | 30 minutes (YtechBot) |

---

## ES-08 — Sauvegarde et continuité

| Exigence | Mesure |
|---|---|
| Règle 3-2-1 | 3 copies, 2 supports, 1 hors site (Google Drive) |
| Chiffrement des archives | AES-256-CBC, clé `/etc/backup.key` |
| Automatisation | Cron quotidien à 02h00 |
| Rétention | 7 jours locaux, illimité sur Drive |
| Périmètre | Bases MariaDB + App Web + Configs Docker |

---

## Récapitulatif conformité ISO 27001

| Contrôle ISO 27001 | Statut | Mesure |
|---|---|---|
| A.8 — Gestion des actifs | ✅ | Inventaire VMs, services, données |
| A.9 — Contrôle d'accès | ✅ | VLAN, Zero Trust, RBAC |
| A.10 — Cryptographie | ✅ | TLS 1.3, AES-256, bcrypt |
| A.12 — Sécurité opérationnelle | ✅ | Hardening, logs, auditd |
| A.13 — Sécurité des communications | ✅ | Firewall, VPN, WAF |
| A.14 — Acquisition et développement | ✅ | GitHub, Docker, HTTPS dev |
| A.16 — Gestion des incidents | ✅ | Wazuh, Suricata, alertes Grafana |
| A.17 — Continuité d'activité | ✅ | Backup 3-2-1, failover ISP |
| A.18 — Conformité | ✅ | Documentation complète |
