---
id: mode-virtualbox-bridged
title: Limites VirtualBox (Bridged vs Host-Only)
sidebar_position: 2
---

### Problème principal : double réseau

Notre infrastructure utilise **deux interfaces réseau par VM** :

```
Host-Only  → 192.168.56.x   (communication inter-VMs)
Bridged    → 192.168.9.x / 192.168.10.x  (réseau classe)
```

:::warning Limitation critique
Le mode **Bridged** dépend du réseau WiFi de l'école. Si le réseau change (nouvelle session DHCP, changement d'IP), toutes les configurations et règles UFW doivent être mises à jour manuellement.
:::

### Problèmes rencontrés

```
Problème 1 : IP Bridged non stable
  → Les IPs 192.168.9.x peuvent changer après redémarrage
  → Solution : Assignation statique dans /etc/netplan/ sur chaque VM

Problème 2 : Isolation Host-Only
  → Les VMs Host-Only ne peuvent pas atteindre Internet directement
  → Solution : Utilisation du réseau Bridged pour les téléchargements

Problème 3 : OPNSense pas encore en gateway
  → Les VMs contactent Internet via le routeur de l'école, pas via OPNSense
  → Solution prévue : Router toutes les VMs via OPNSense (Asmaa + Raja)
```

### Tableau de routage actuel (simulation)

```
Destination     Gateway           Interface     Status
0.0.0.0/0       192.168.9.1       Bridged       ✅ Internet via école
192.168.56.0/24 —                 Host-Only     ✅ Inter-VMs
100.64.0.0/10   Headscale         Tailscale     ✅ Zero Trust VPN
```

### Tableau de routage cible (production)

```
Destination     Gateway              Interface     Status
0.0.0.0/0       OPNSense WAN         Bridged       🎯 Cible
192.168.10.0/24 OPNSense VLAN 10     VLAN          🎯 Cible
192.168.20.0/24 OPNSense VLAN 20     VLAN          🎯 Cible
...
```

---
