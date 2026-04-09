---
id: controle-acces
title: Contrôle d'accès — Synthèse
sidebar_label: "✅ Contrôle d'accès"
sidebar_position: 8
---

# ✅ Contrôle d'accès — Synthèse

## Vue d'ensemble des mécanismes

L'infrastructure Y-Tech implémente un contrôle d'accès en **4 couches complémentaires**. Chaque couche ajoute un niveau de défense indépendant.

```
┌─────────────────────────────────────────────────────────┐
│                  COUCHE 4 — BASTION SSH                  │
│   Point d'entrée SSH unique — ProxyJump — auth.log      │
├─────────────────────────────────────────────────────────┤
│              COUCHE 3 — VPN WIREGUARD                    │
│   Tunnel chiffré — Accès distant contrôlé — Peers       │
├─────────────────────────────────────────────────────────┤
│           COUCHE 2 — RÈGLES FIREWALL OPNSENSE            │
│   Filtrage par interface — Aliases — Moindre privilège  │
├─────────────────────────────────────────────────────────┤
│            COUCHE 1 — SEGMENTATION VLAN                  │
│   7 VLANs isolés — LAN tagué — Tags 802.1Q              │
└─────────────────────────────────────────────────────────┘
```

## Couche 1 — Segmentation VLAN

| Mécanisme | Description | Implémentation |
|-----------|-------------|----------------|
| **VLANs 802.1Q** | Isolation réseau physique | 7 VLANs sur em1 (LAN) |
| **Sous-réseaux dédiés** | Chaque zone a son /24 | 192.168.10-60.0/24 |
| **Passerelle OPNsense** | Tout le trafic inter-VLAN passe par le firewall | IP .1 sur chaque VLAN |

**Ce que ça bloque :** Un hôte dans VLAN40 ne peut pas communiquer avec VLAN25 au niveau réseau — même si les règles firewall étaient absentes.

## Couche 2 — Règles Firewall

| Mécanisme | Description | Implémentation |
|-----------|-------------|----------------|
| **Aliases** | Objets nommés réutilisables | 14 aliases hôtes + ports |
| **Règles LAN** | Contrôle accès réseau principal | 8 règles ordonnées |
| **Règles inter-VLAN** | Isolation entre zones | Rules par VLAN |
| **Default deny** | Tout ce qui n'est pas permis est bloqué | Dernière règle BLOCK ALL |

**Ce que ça bloque :** Même si deux hôtes sont dans des VLANs adjacents, les flux non autorisés sont refusés au niveau du firewall.

## Couche 3 — VPN WireGuard

| Mécanisme | Description | Implémentation |
|-----------|-------------|----------------|
| **Authentification** | Clés publiques/privées | Paire de clés par peer |
| **Chiffrement** | ChaCha20-Poly1305 | Intégré WireGuard |
| **Autorisation** | Règles firewall WG_YTECH | 7 règles dédiées |
| **Isolation** | DB et Backup inaccessibles depuis VPN | Règles BLOCK explicites |

**Ce que ça apporte :** Les accès distants sont aussi sécurisés que les accès locaux — avec le même niveau de contrôle firewall.

## Couche 4 — Bastion SSH

| Mécanisme | Description | Implémentation |
|-----------|-------------|----------------|
| **Point unique** | Seule porte d'entrée SSH | VM Ubuntu 192.168.1.20 |
| **ProxyJump** | Rebond transparent vers serveurs | `-J bastion` / SSH config |
| **Authentification** | Clés SSH uniquement | Pas de mot de passe |
| **Journalisation** | Chaque accès loggé | `/var/log/auth.log` |
| **Isolation** | Accessible uniquement depuis ADMIN + VPN | Règles OPNsense |

**Ce que ça apporte :** Surface d'attaque SSH réduite à une seule machine, auditée et surveillée.

## Scénarios de défense

### Scénario 1 — Credential utilisateur compromis

```
Attaquant obtient le mot de passe d'un compte USERS
    │
    ▼
Tente de se connecter à la DB directement
    │
    ▼
❌ Bloqué — Règle BLOCK USERS → DB (couche 2)
❌ Bloqué — Isolation VLAN40 (couche 1)
```

### Scénario 2 — Serveur APP compromis

```
Attaquant compromet le serveur Laravel (VLAN20_APP)
    │
    ▼
Tente un reverse shell vers Internet
    │
    ▼
❌ Bloqué — VLAN20_APP : BLOCK ALL except DB:3306 (couche 2)

Tente de pivoter vers MGMT
    │
    ▼
❌ Bloqué — Pas de règle APP → MGMT (couche 2)
```

### Scénario 3 — Scan réseau depuis Internet

```
Attaquant scanne l'IP WAN 192.168.9.50
    │
    ▼
Détecté par Suricata (ET SCAN alert)
    │
    ▼
Seul le port 51820 UDP (WireGuard) est exposé
    │
    ▼
Connexion WireGuard nécessite une clé valide
❌ Aucune autre surface d'attaque exposée
```

## Bilan de conformité

| Principe | Appliqué | Mécanisme |
|----------|----------|-----------|
| Moindre privilège | ✅ | Règles firewall par rôle |
| Défense en profondeur | ✅ | 4 couches indépendantes |
| Séparation des zones | ✅ | 7 VLANs distincts |
| Accès distant sécurisé | ✅ | WireGuard + bastion |
| Traçabilité | ✅ | OPNsense logs + auth.log + Suricata |
| Point d'entrée unique SSH | ✅ | Bastion jump host |
| Isolation de la DB | ✅ | VLAN25 + BLOCK ALL out |

:::success Posture de sécurité
La combinaison VLAN + Firewall + VPN + Bastion permet d'atteindre une posture de sécurité proche du modèle **Zero Trust** : personne n'est implicitement de confiance, chaque accès est vérifié et tracé.
:::
