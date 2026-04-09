---
id: modelisation-roles
title: Modélisation des rôles
sidebar_label: "👥 Modélisation des rôles"
sidebar_position: 2
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

# 👥 Modélisation des rôles (RBAC)

## Approche RBAC

L'infrastructure Y-Tech utilise un modèle **RBAC — Role-Based Access Control** : les droits d'accès sont attribués à des rôles, et chaque utilisateur ou service se voit assigner un rôle selon sa fonction.

Chaque rôle correspond directement à un **VLAN OPNsense**, ce qui ancre le contrôle d'accès logiciel dans la segmentation réseau physique.

## Définition des rôles

| Rôle | VLAN | Réseau | Description |
|------|------|--------|-------------|
| **ADMIN** | VLAN50 | 192.168.50.0/24 | Administrateurs système — accès total |
| **USERS** | VLAN40 | 192.168.40.0/24 | Utilisateurs métier — accès applications uniquement |
| **APP** | VLAN20 | 192.168.20.0/24 | Serveurs applicatifs — accès DB uniquement |
| **DMZ** | VLAN10 | 192.168.10.0/24 | Services exposés — accès DB uniquement |
| **MGMT** | VLAN30 | 192.168.30.0/24 | Outils de monitoring — accès admin uniquement |
| **BACKUP** | VLAN60 | 192.168.60.0/24 | Serveur de sauvegarde — accès SSH serveurs |
| **DB** | VLAN25 | 192.168.25.0/24 | Base de données — isolé, aucun accès sortant |
| **VPN** | WG_YTECH | 10.10.0.0/24 | Accès distant — droits APP + MGMT |

## Matrice des droits d'accès

<Tabs>
  <TabItem value="vlan" label="Par VLAN" default>

| Rôle source ↓ / Cible → | DMZ | APP | DB | MGMT | USERS | ADMIN | BACKUP | Internet |
|--------------------------|-----|-----|----|------|-------|-------|--------|----------|
| **ADMIN** | ✅ | ✅ | ✅ | ✅ | ✅ | — | ✅ | ✅ |
| **USERS** | ❌ | ✅ APP_PORTS | ❌ | ❌ | — | ❌ | ❌ | ✅ |
| **APP** | ❌ | — | ✅ 3306 | ❌ | ❌ | ❌ | ❌ | ❌ |
| **DMZ** | — | ❌ | ✅ 3306 | ❌ | ❌ | ❌ | ❌ | ❌ |
| **MGMT** | ❌ | ❌ | ❌ | — | ❌ | ❌ | ❌ | ❌ |
| **BACKUP** | ❌ | ✅ SSH | ✅ SSH | ✅ SSH | ❌ | ❌ | — | ❌ |
| **DB** | ❌ | ❌ | — | ❌ | ❌ | ❌ | ❌ | ❌ |
| **VPN** | ❌ | ✅ APP_PORTS | ❌ | ✅ MGMT_PORTS | ❌ | ✅ (sara) | ❌ | ✅ |

  </TabItem>
  <TabItem value="services" label="Par service">

| Service | Port | Accès autorisé | Accès refusé |
|---------|------|----------------|--------------|
| HR App (Laravel) | 8443 | ADMIN, USERS, VPN | DB, BACKUP |
| Chatbot YtechBot | 8501 | ADMIN, USERS, VPN | DB, BACKUP |
| Ollama LLM | 11434 | ADMIN, USERS, VPN | DB, BACKUP |
| Bitwarden | 8444 | ADMIN, VPN | USERS, DB |
| Grafana | 3000 | ADMIN, VPN | USERS, DB |
| Nessus | 8834 | ADMIN uniquement | Tous les autres |
| MySQL | 3306 | APP, DMZ uniquement | Tous les autres |
| SSH (bastion) | 22 | ADMIN, VPN | USERS |

  </TabItem>
</Tabs>

## Hiérarchie des rôles

```
                    ┌─────────────┐
                    │    ADMIN    │  Accès total
                    │  VLAN50     │
                    └──────┬──────┘
                           │ délègue
          ┌────────────────┼────────────────┐
          ▼                ▼                ▼
   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
   │    USERS    │  │    MGMT     │  │   BACKUP    │
   │  VLAN40     │  │  VLAN30     │  │  VLAN60     │
   │  (apps)     │  │ (monitoring)│  │  (SSH srv)  │
   └─────────────┘  └─────────────┘  └─────────────┘
          │                                │
          │ peut accéder                   │ peut accéder
          ▼                                ▼
   ┌─────────────┐                  ┌─────────────┐
   │     APP     │                  │     DB      │
   │  VLAN20     │──── MySQL ──────▶│  VLAN25     │
   │  (serveurs) │                  │  (isolée)   │
   └─────────────┘                  └─────────────┘
```

## Attribution des rôles — Équipe Y-Tech

| Membre | Rôle | VLAN | Accès VPN |
|--------|------|------|-----------|
| Administrateur (toi) | ADMIN | VLAN50 + LAN | 10.10.0.2 (sara) — full access |
| Collègue équipe | USERS | VLAN40 | 10.10.0.3 (chaima) |
| Serveurs Laravel/RH | APP | VLAN20 | — |
| Serveur MySQL | DB | VLAN25 | — |
| Zabbix/Wazuh/Grafana | MGMT | VLAN30 | — |

:::info RBAC vs ABAC
Le modèle RBAC est plus simple à gérer en environnement PME. Pour un environnement plus granulaire (conditions sur l'heure, le lieu, le contexte), on passerait à ABAC (Attribute-Based Access Control) — une évolution possible décrite dans les perspectives.
:::
