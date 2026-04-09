---
id: index
title: 08. Gestion des accès
sidebar_label: "🔑 Vue d'ensemble"
sidebar_position: 1
---

# 🔑 Gestion des accès

## Objectif

La gestion des accès dans l'infrastructure Y-Tech repose sur une approche **défense en profondeur** : chaque utilisateur n'accède qu'à ce dont il a besoin, via un chemin d'accès contrôlé et traçable.

## Mécanismes de contrôle en place

| Mécanisme | Outil | Responsable |
|-----------|-------|-------------|
| Segmentation réseau | OPNsense VLANs | ✅ Configuré |
| Filtrage des flux | OPNsense Firewall | ✅ Configuré |
| Accès distant sécurisé | WireGuard VPN | ✅ Configuré |
| Point d'entrée SSH unique | Bastion Ubuntu | ✅ Configuré |
| Gestion des mots de passe | Bitwarden | ✅ Configuré (Rajaa) |
| Traçabilité des accès | Logs OPNsense + Suricata | ✅ Configuré |

## Architecture d'accès globale

```
Utilisateur distant
        │
        │ WireGuard VPN (UDP 51820)
        ▼
   OPNsense Firewall
        │
        │ SSH (port 22) — Jump Host
        ▼
   ┌─────────────┐
   │   BASTION   │  VM Ubuntu — 192.168.1.20
   │  Jump Host  │  Point d'entrée SSH unique
   └──────┬──────┘
          │
          ├──▶ Serveurs APP    (ssh -J bastion app-srv)
          ├──▶ Serveurs DB     (ssh -J bastion db-srv)
          ├──▶ Serveurs MGMT   (ssh -J bastion mgmt-srv)
          └──▶ Serveurs BACKUP (ssh -J bastion backup-srv)
```

## Sections de ce chapitre

- [Modélisation des rôles](./modelisation-roles) — RBAC et matrice des droits
- [Moindre privilège](./moindre-privilege) — Application concrète sur l'infrastructure
- [Accès par département](./acces-departement) — Droits par VLAN et profil
- [Bastion SSH](./bastion-ssh) — Jump host Ubuntu — point d'entrée unique
- [Bitwarden](./bitwarden) — Gestionnaire de mots de passe (Rajaa)
- [Traçabilité](./tracabilite) — Logs OPNsense, Suricata, Bastion
- [Contrôle d'accès](./controle-acces) — Synthèse des mécanismes
