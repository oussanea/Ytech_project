---
id: index
title: 07. Firewall OPNsense
sidebar_label: "🔥 Vue d'ensemble"
sidebar_position: 1
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

# 🔥 Firewall OPNsense

## Vue d'ensemble

OPNsense est le pare-feu central de l'architecture Y-Tech. Il assure la **segmentation réseau**, le **filtrage des flux**, la **détection d'intrusions** et le **contrôle des accès** entre tous les segments du réseau.

## Architecture de sécurité

```
Internet (WAN)
      │
  ┌───▼────────────────────────────────────┐
  │           OPNsense Firewall             │
  │         192.168.9.50 (WAN)             │
  │         192.168.1.1  (LAN)             │
  └───┬────────────────────────────────────┘
      │
      ├── VLAN10 (DMZ)    192.168.10.0/24
      ├── VLAN20 (APP)    192.168.20.0/24
      ├── VLAN25 (DB)     192.168.25.0/24
      ├── VLAN30 (MGMT)   192.168.30.0/24
      ├── VLAN40 (USERS)  192.168.40.0/24
      ├── VLAN50 (ADMIN)  192.168.50.0/24
      └── VLAN60 (BACKUP) 192.168.60.0/24
```

## Composants configurés

| Composant | Statut | Description |
|-----------|--------|-------------|
| **Interfaces & VLANs** | ✅ Actif | 7 VLANs segmentés sur interface LAN |
| **Aliases** | ✅ Actif | 14 aliases hôtes et ports |
| **NAT** | ✅ Actif | Outbound NAT pour accès Internet |
| **Règles LAN** | ✅ Actif | 8 règles avec moindre privilège |
| **Règles inter-VLAN** | ✅ Actif | Segmentation stricte entre VLANs |
| **Suricata IDS** | ✅ Actif | Détection d'intrusions sur WAN/LAN |

## Principe de sécurité appliqué

:::info Moindre privilège
Toutes les règles firewall suivent le principe du **moindre privilège** : ce qui n'est pas explicitement autorisé est bloqué. Chaque VLAN dispose de règles spécifiques adaptées à son rôle.
:::

## Sections de ce chapitre

- [Installation](./installation) — Configuration VM et accès initial
- [Interfaces & VLANs](./interfaces-vlans) — Création et assignation des VLANs
- [Aliases](./aliases) — Objets réseau réutilisables
- [NAT](./nat) — Traduction d'adresses réseau
- [Règles Firewall](./regles-firewall) — Politique de filtrage LAN
- [Règles inter-VLAN](./regles-inter-vlan) — Segmentation entre VLANs
- [Logs & Surveillance](./logs-surveillance) — Suricata IDS et journaux
