---
id: acces-par-departement
title: Accès par département
sidebar_label: "🏢 Accès par département"
sidebar_position: 4
---

# 🏢 Accès par département

## Principe

Chaque département de l'entreprise Y-Tech est associé à un **VLAN dédié** avec des droits d'accès calibrés à ses besoins métier. Cette approche garantit qu'un incident dans un département ne compromet pas les autres.

## Mapping département → VLAN → Droits

### Département Ressources Humaines

| Attribut | Valeur |
|----------|--------|
| **VLAN** | VLAN40_USERS |
| **Réseau** | 192.168.40.0/24 |
| **Accès autorisés** | Application RH (HTTPS :8443), Chatbot YtechBot (:8501) |
| **Accès refusés** | Base de données directe, monitoring, administration |
| **Accès distant** | Via VPN WireGuard (peer chaima) |

```
Workflow RH :
Poste RH (VLAN40) ──▶ HR App :8443 ──▶ APP_SRV ──▶ DB MySQL
                   (autorisé)        (autorisé)
         │
         ├──✖ Connexion directe DB MySQL  (bloquée)
         └──✖ Interface Grafana/Zabbix    (bloquée)
```

---

### Département IT / Administration

| Attribut | Valeur |
|----------|--------|
| **VLAN** | VLAN50_ADMIN + LAN (192.168.1.0/24) |
| **Réseau** | 192.168.50.0/24 |
| **Accès autorisés** | Tout — accès complet à l'infrastructure |
| **Outils spécifiques** | Nessus (:8834), Grafana (:3000), Bitwarden (:8444) |
| **Accès distant** | Via VPN WireGuard (peer sara — full access) |
| **Accès SSH** | Via Bastion (jump host Ubuntu) |

```
Workflow Admin :
Poste Admin (VLAN50 / VPN sara)
    │
    ├──▶ Nessus     :8834  (scans de vulnérabilités)
    ├──▶ Grafana    :3000  (supervision)
    ├──▶ Bitwarden  :8444  (gestion mots de passe)
    ├──▶ Bastion SSH :22   (accès serveurs)
    └──▶ OPNsense Web GUI  (administration firewall)
```

---

### Département DevOps / Développeurs

| Attribut | Valeur |
|----------|--------|
| **VLAN** | VLAN20_APP (serveurs) |
| **Accès applicatifs** | Déploiement via Docker Compose, accès GitHub |
| **Accès DB** | Via l'application uniquement (port 3306 de l'APP) |
| **Accès admin** | Via VPN + Bastion pour interventions serveur |

---

### Serveur de Backup

| Attribut | Valeur |
|----------|--------|
| **VLAN** | VLAN60_BACKUP |
| **Réseau** | 192.168.60.0/24 |
| **Accès autorisés** | SSH (port 22) vers VLAN20, VLAN25, VLAN30 |
| **Accès refusés** | Internet, VLAN40 (utilisateurs), VLAN50 (admin) |
| **Rôle** | Sauvegarde automatisée — accès unidirectionnel |

---

## Tableau récapitulatif par département

| Département | VLAN | HR App | DB | Monitoring | Nessus | SSH Serveurs | Internet |
|-------------|------|--------|----|-----------|--------|--------------|---------|
| RH | 40 | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| IT / Admin | 50+LAN | ✅ | ✅ | ✅ | ✅ | ✅ via Bastion | ✅ |
| DevOps | 20 (srv) | — | ✅ app | ❌ | ❌ | ✅ via Bastion | ❌ |
| Backup | 60 | ❌ | ✅ SSH | ✅ SSH | ❌ | ✅ SSH | ❌ |
| Externe VPN | WG | ✅ | ❌ | ✅ | ❌ | — | ✅ |

## Flux autorisés — Schéma global

```
Internet
   │
   │ WireGuard VPN ──────────────────────────┐
   │                                          │
   ▼                                          ▼
OPNsense Firewall                        VPN Users
   │                                     (sara/chaima)
   ├── VLAN50_ADMIN ──────────────────▶  All services
   │
   ├── VLAN40_USERS ──────────────────▶  APP :8443, :8501
   │                         ✖──────▶  DB, MGMT, Admin
   │
   ├── VLAN20_APP   ──────────────────▶  DB :3306 only
   │                         ✖──────▶  Internet, MGMT
   │
   ├── VLAN25_DB    ──  BLOCK ALL OUT ─  (répond uniquement)
   │
   ├── VLAN30_MGMT  ─── ADMIN only ───▶  Monitoring tools
   │
   └── VLAN60_BACKUP ─── SSH only ────▶  APP, DB, MGMT
```

:::tip Évolutivité
Ce modèle est facilement extensible : l'ajout d'un nouveau département se fait en créant un nouveau VLAN avec ses règles firewall dédiées, sans toucher aux autres segments.
:::
