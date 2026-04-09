---
id: nat
title: NAT — Traduction d'adresses
sidebar_label: "🔄 NAT"
sidebar_position: 5
---

# 🔄 NAT — Traduction d'adresses réseau

## Principe du NAT dans cette architecture

Le **NAT (Network Address Translation)** est utilisé dans l'architecture Y-Tech pour permettre aux machines du réseau interne d'accéder à Internet via l'adresse WAN d'OPNsense.

**Chemin :** `Firewall → NAT`

## NAT Outbound (sortant)

Le NAT Outbound est configuré pour que tout le trafic sortant vers Internet soit traduit avec l'adresse IP WAN d'OPNsense.

### Règle NAT Outbound principale

| Champ | Valeur |
|-------|--------|
| Interface | WAN |
| Protocole | any |
| Source | LAN net (192.168.1.0/24) |
| Destination | any |
| NAT Address | Interface address (192.168.9.50) |
| Description | LAN → Internet via WAN |

:::info Mode Automatic Outbound NAT
OPNsense est configuré en mode **Automatic Outbound NAT**, ce qui signifie qu'il génère automatiquement les règles NAT pour tous les réseaux internes configurés (LAN + VLANs).
:::

## NAT et les VLANs

Chaque VLAN bénéficie automatiquement du NAT Outbound via le même mécanisme :

| Réseau source | Interface NAT | Adresse publique |
|---------------|---------------|-----------------|
| 192.168.1.0/24 (LAN) | WAN | 192.168.9.50 |
| 192.168.10.0/24 (DMZ) | WAN | 192.168.9.50 |
| 192.168.20.0/24 (APP) | WAN | 192.168.9.50 |
| 192.168.40.0/24 (USERS) | WAN | 192.168.9.50 |

:::note Contexte VirtualBox
Dans l'environnement VirtualBox, l'adresse WAN 192.168.9.50 est une adresse du réseau bridged (réseau physique du laboratoire). L'accès Internet effectif dépend de la passerelle du réseau physique.
:::

## Interface NAT pour Suricata

Une interface de type **NAT VirtualBox** a été ajoutée spécifiquement à la VM OPNsense pour lui permettre de :

- Télécharger les mises à jour du système OPNsense
- Télécharger les rulesets Suricata (Emerging Threats)
- Résoudre les noms DNS externes

:::warning Restriction importante
Cette interface NAT est **uniquement** assignée à la VM OPNsense. Elle n'est pas partagée avec les autres VMs du réseau. Les autres machines utilisent le WAN bridged comme sortie Internet.
:::

## Port Forwarding (NAT entrant)

Dans la configuration actuelle du projet, aucun port forwarding depuis le WAN n'est configuré. L'accès aux services se fait exclusivement depuis le réseau interne (LAN/VLANs) ou via le VPN WireGuard.

```
// Accès externe aux services → via VPN WireGuard uniquement
WAN:51820 (UDP) → Interface WG_YTECH → Services internes
```

:::tip Sécurité
Ne pas exposer de services directement sur le WAN est une bonne pratique. L'accès distant sécurisé est assuré exclusivement via WireGuard (voir section 09. VPN).
:::
