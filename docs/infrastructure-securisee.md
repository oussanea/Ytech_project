---
id: infrastructure-securisee
title: Infrastructure Réseau Sécurisée
sidebar_label: Infrastructure Sécurisée
---

# Infrastructure Réseau Sécurisée — Ytech Solutions

> Configuration complète étape par étape — GNS3 / Packet Tracer

---

## Vue d'ensemble de l'architecture

L'infrastructure finale repose sur une **segmentation réseau en 6 VLANs** avec un double firewall :
- **OPNsense** (firewall périmétrique + routeur inter-VLAN)
- **Cisco 2960-24TT** (Core Switch + switches de distribution)

![Diagramme infrastructure sécurisée](./img/infa_correcte.png)

### Tableau des VLANs

| VLAN | Nom | Réseau | Contenu |
|------|-----|--------|---------|
| 10 | DMZ | 192.168.10.0/24 | Web Server — Nginx + Laravel + WAF |
| 20 | APP | 192.168.20.0/24 | App Server — CRUD RH + Ollama |
| 25 | DB | 192.168.25.0/24 | DB Server — MariaDB |
| 30 | MONITORING | 192.168.30.0/24 | Zabbix + Headscale + Nessus + Wazuh + Bitwarden + Grafana |
| 40 | EMPLOYEES | 192.168.40.0/24 | 24 PCs Windows employés |
| 50 | IT-ADMINS | 192.168.50.0/24 | Bastion SSH + PC IT Admins |
| 60 | BACKUP | 192.168.60.0/24 | Backup Server — rsync + rclone |

### Sous-interfaces Router-on-a-Stick (OPNsense)

| Sous-interface | VLAN | Gateway |
|----------------|------|---------|
| G0/2.10 | VLAN 10 — DMZ | 192.168.10.1/24 |
| G0/2.20 | VLAN 20 — APP | 192.168.20.1/24 |
| G0/2.25 | VLAN 25 — DB | 192.168.25.1/24 |
| G0/2.30 | VLAN 30 — MONITORING | 192.168.30.1/24 |
| G0/2.40 | VLAN 40 — EMPLOYEES | 192.168.40.1/24 |
| G0/2.50 | VLAN 50 — IT-ADMINS | 192.168.50.1/24 |
| G0/2.60 | VLAN 60 — BACKUP | 192.168.60.1/24 |

---

## Étape 1 — Configuration OPNsense (Routeur/Firewall)

### 1.1 Interfaces physiques

Configuration des interfaces WAN (ISP1 et ISP2) et du lien trunk vers le Core Switch.

![Configuration OPNsense — interfaces physiques](./img/1.png)

```cisco
Router>enable
Router#configure terminal
Router(config)#hostname OPNSENSE

! Interface WAN 1 — ISP Principal
OPNSENSE(config)#interface GigabitEthernet0/0
OPNSENSE(config-if)#description ISP1-Principal
OPNSENSE(config-if)#ip address dhcp
OPNSENSE(config-if)#ip nat outside
OPNSENSE(config-if)#duplex auto
OPNSENSE(config-if)#speed auto
OPNSENSE(config-if)#no shutdown

! Interface WAN 2 — ISP Backup
OPNSENSE(config)#interface GigabitEthernet0/1
OPNSENSE(config-if)#description ISP2-Backup
OPNSENSE(config-if)#ip address dhcp
OPNSENSE(config-if)#ip nat outside
OPNSENSE(config-if)#duplex auto
OPNSENSE(config-if)#speed auto
OPNSENSE(config-if)#no shutdown

! Interface vers Core Switch — TRUNK 802.1Q
OPNSENSE(config)#interface GigabitEthernet0/2
OPNSENSE(config-if)#description TRUNK-vers-CoreSwitch
OPNSENSE(config-if)#no ip address
OPNSENSE(config-if)#duplex auto
OPNSENSE(config-if)#speed auto
OPNSENSE(config-if)#no shutdown
```

---

### 1.2 Sous-interfaces VLAN 10 à VLAN 25

Création des sous-interfaces pour le routage inter-VLAN (Router-on-a-Stick).

![Configuration sous-interfaces VLAN 10/20/25](./img/2.png)

```cisco
! VLAN 10 — DMZ
OPNSENSE(config-if)#interface GigabitEthernet0/2.10
OPNSENSE(config-subif)#description VLAN10-DMZ
OPNSENSE(config-subif)#encapsulation dot1Q 10
OPNSENSE(config-subif)#ip address 192.168.10.1 255.255.255.0
OPNSENSE(config-subif)#ip nat inside
OPNSENSE(config-subif)#no shutdown

! VLAN 20 — APP
OPNSENSE(config-subif)#interface GigabitEthernet0/2.20
OPNSENSE(config-subif)#description VLAN20-APP
OPNSENSE(config-subif)#encapsulation dot1Q 20
OPNSENSE(config-subif)#ip address 192.168.20.1 255.255.255.0
OPNSENSE(config-subif)#ip nat inside
OPNSENSE(config-subif)#no shutdown

! VLAN 25 — DB
OPNSENSE(config-subif)#interface GigabitEthernet0/2.25
OPNSENSE(config-subif)#description VLAN25-DB
OPNSENSE(config-subif)#encapsulation dot1Q 25
OPNSENSE(config-subif)#ip address 192.168.25.1 255.255.255.0
OPNSENSE(config-subif)#ip nat inside
OPNSENSE(config-subif)#no shutdown
```

---

### 1.3 Sous-interfaces VLAN 30 à VLAN 50

![Configuration sous-interfaces VLAN 30/40/50](./img/3.png)

```cisco
! VLAN 30 — MONITORING
OPNSENSE(config-subif)#interface GigabitEthernet0/2.30
OPNSENSE(config-subif)#description VLAN30-MONITORING
OPNSENSE(config-subif)#encapsulation dot1Q 30
OPNSENSE(config-subif)#ip address 192.168.30.1 255.255.255.0
OPNSENSE(config-subif)#ip nat inside
OPNSENSE(config-subif)#no shutdown

! VLAN 40 — EMPLOYEES
OPNSENSE(config-subif)#interface GigabitEthernet0/2.40
OPNSENSE(config-subif)#description VLAN40-EMPLOYEES
OPNSENSE(config-subif)#encapsulation dot1Q 40
OPNSENSE(config-subif)#ip address 192.168.40.1 255.255.255.0
OPNSENSE(config-subif)#ip nat inside
OPNSENSE(config-subif)#no shutdown

! VLAN 50 — IT-ADMINS
OPNSENSE(config-subif)#interface GigabitEthernet0/2.50
OPNSENSE(config-subif)#description VLAN50-IT-ADMINS
OPNSENSE(config-subif)#encapsulation dot1Q 50
OPNSENSE(config-subif)#ip address 192.168.50.1 255.255.255.0
OPNSENSE(config-subif)#ip nat inside
OPNSENSE(config-subif)#no shutdown
```

---

### 1.4 Sous-interface VLAN 60

![Configuration sous-interface VLAN 60](./img/4.png)

```cisco
! VLAN 60 — BACKUP
OPNSENSE(config)#interface GigabitEthernet0/2.60
OPNSENSE(config-subif)#description VLAN60-BACKUP
OPNSENSE(config-subif)#encapsulation dot1Q 60
OPNSENSE(config-subif)#ip address 192.168.60.1 255.255.255.0
OPNSENSE(config-subif)#ip nat inside
OPNSENSE(config-subif)#no shutdown
```

---

### 1.5 NAT et routes par défaut

Configuration du NAT (tous VLANs vers Internet) et des routes de failover ISP.

![Configuration NAT et routes](./img/5.png)

```cisco
! ACL NAT — autoriser tous les VLANs internes vers Internet
OPNSENSE(config)#ip access-list standard NAT_ALL_VLANS
OPNSENSE(config-std-nacl)#permit 192.168.10.0 0.0.0.255
OPNSENSE(config-std-nacl)#permit 192.168.20.0 0.0.0.255
OPNSENSE(config-std-nacl)#permit 192.168.25.0 0.0.0.255
OPNSENSE(config-std-nacl)#permit 192.168.30.0 0.0.0.255
OPNSENSE(config-std-nacl)#permit 192.168.40.0 0.0.0.255
OPNSENSE(config-std-nacl)#permit 192.168.50.0 0.0.0.255
OPNSENSE(config-std-nacl)#permit 192.168.60.0 0.0.0.255

! NAT overload (PAT) sur WAN principal
OPNSENSE(config)#ip nat inside source list NAT_ALL_VLANS interface GigabitEthernet0/0 overload

! Route par défaut — WAN principal (ISP1)
OPNSENSE(config)#ip route 0.0.0.0 0.0.0.0 GigabitEthernet0/0

! Route de secours — WAN backup (ISP2) avec métrique 10
OPNSENSE(config)#ip route 0.0.0.0 0.0.0.0 GigabitEthernet0/1 10
```

---

### 1.6 ACL inter-VLAN — politique de sécurité

Définition des ACLs étendues pour isoler les VLANs et contrôler les flux autorisés.

![ACL VLAN 10 DMZ et VLAN 40 Employees — partie 1](./img/6.png)

![ACL VLAN 10 DMZ et VLAN 40 Employees — partie 2](./img/7.png)

```cisco
! === ACL VLAN 10 — DMZ ===
! La DMZ peut sortir vers Internet (80/443) mais ne peut pas
! atteindre directement les autres VLANs internes.
OPNSENSE(config)#ip access-list extended ACL_VLAN10_DMZ
OPNSENSE(config-ext-nacl)#permit tcp 192.168.10.0 0.0.0.255 any eq 80
OPNSENSE(config-ext-nacl)#permit tcp 192.168.10.0 0.0.0.255 any eq 443
OPNSENSE(config-ext-nacl)#deny ip 192.168.10.0 0.0.0.255 192.168.20.0 0.0.0.255
OPNSENSE(config-ext-nacl)#deny ip 192.168.10.0 0.0.0.255 192.168.25.0 0.0.0.255
OPNSENSE(config-ext-nacl)#deny ip 192.168.10.0 0.0.0.255 192.168.30.0 0.0.0.255
OPNSENSE(config-ext-nacl)#deny ip 192.168.10.0 0.0.0.255 192.168.40.0 0.0.0.255
OPNSENSE(config-ext-nacl)#deny ip 192.168.10.0 0.0.0.255 192.168.50.0 0.0.0.255
OPNSENSE(config-ext-nacl)#deny ip 192.168.10.0 0.0.0.255 192.168.60.0 0.0.0.255
OPNSENSE(config-ext-nacl)#permit ip any any

! === ACL VLAN 40 — EMPLOYEES ===
! Les employés peuvent accéder à l'App (80/443) et à la DMZ (443)
! mais sont bloqués vers la DB et le Backup.
OPNSENSE(config)#ip access-list extended ACL_VLAN40_EMPLOYEES
OPNSENSE(config-ext-nacl)#deny ip 192.168.40.0 0.0.0.255 192.168.25.0 0.0.0.255
OPNSENSE(config-ext-nacl)#deny ip 192.168.40.0 0.0.0.255 192.168.60.0 0.0.0.255
OPNSENSE(config-ext-nacl)#permit tcp 192.168.40.0 0.0.0.255 192.168.20.0 0.0.0.255 eq 80
OPNSENSE(config-ext-nacl)#permit tcp 192.168.40.0 0.0.0.255 192.168.20.0 0.0.0.255 eq 443
OPNSENSE(config-ext-nacl)#permit tcp 192.168.40.0 0.0.0.255 192.168.10.0 0.0.0.255 eq 443
OPNSENSE(config-ext-nacl)#permit ip any any
```

![ACL VLAN 50 IT-Admins et application des ACLs](./img/7.png)

```cisco
! === ACL VLAN 50 — IT-ADMINS ===
! Les admins ont accès SSH à tous les équipements.
OPNSENSE(config)#ip access-list extended ACL_VLAN50_ADMINS
OPNSENSE(config-ext-nacl)#permit tcp 192.168.50.0 0.0.0.255 any eq 22
OPNSENSE(config-ext-nacl)#permit ip 192.168.50.0 0.0.0.255 any

! === Application des ACLs sur les sous-interfaces ===
OPNSENSE(config-subif)#interface GigabitEthernet0/2.10
OPNSENSE(config-subif)#ip access-group ACL_VLAN10_DMZ in

OPNSENSE(config-subif)#interface GigabitEthernet0/2.40
OPNSENSE(config-subif)#ip access-group ACL_VLAN40_EMPLOYEES in

OPNSENSE(config-subif)#interface GigabitEthernet0/2.50
OPNSENSE(config-subif)#ip access-group ACL_VLAN50_ADMINS in
```

:::info Principe de moindre privilège
Chaque VLAN n'a accès qu'aux ressources strictement nécessaires à son rôle. Le VLAN DB (25) n'est jamais accessible directement depuis les employés ni depuis Internet.
:::

---

## Étape 2 — Core Switch (CORE-SWITCH)

### 2.1 Création des VLANs

Déclaration de tous les VLANs sur le Core Switch.

![Création des VLANs sur CORE-SWITCH](./img/8_CREATION_DES_VLANs.png)

```cisco
Switch(config)#hostname CORE-SWITCH

CORE-SWITCH(config)#vlan 10
CORE-SWITCH(config-vlan)#name DMZ
CORE-SWITCH(config-vlan)#vlan 20
CORE-SWITCH(config-vlan)#name APP
CORE-SWITCH(config-vlan)#vlan 25
CORE-SWITCH(config-vlan)#name DB
CORE-SWITCH(config-vlan)#vlan 30
CORE-SWITCH(config-vlan)#name MONITORING
CORE-SWITCH(config-vlan)#vlan 40
CORE-SWITCH(config-vlan)#name EMPLOYEES
CORE-SWITCH(config-vlan)#vlan 50
CORE-SWITCH(config-vlan)#name IT-ADMINS
CORE-SWITCH(config-vlan)#vlan 60
CORE-SWITCH(config-vlan)#name BACKUP
```

---

### 2.2 Ports trunk du Core Switch

Configuration des liens trunk vers OPNsense, SW2-SERVER, SW3-USERS et SW1-DMZ.

![Configuration trunk CORE-SWITCH](./img/9-TRUNK.png)

![Configuration trunk CORE-SWITCH suite](./img/10_TRUNK_.png)

```cisco
! Fa0/1 — Trunk vers OPNsense (tous VLANs)
CORE-SWITCH(config)#interface FastEthernet0/1
CORE-SWITCH(config-if)#description TRUNK-vers-OPNSENSE-Gi0-2
CORE-SWITCH(config-if)#switchport mode trunk
CORE-SWITCH(config-if)#switchport trunk allowed vlan 10,20,25,30,40,50,60
CORE-SWITCH(config-if)#no shutdown

! Fa0/2 — Trunk vers SW2-SERVER (VLANs serveurs)
CORE-SWITCH(config)#interface FastEthernet0/2
CORE-SWITCH(config-if)#description TRUNK-vers-SW2-SERVER
CORE-SWITCH(config-if)#switchport mode trunk
CORE-SWITCH(config-if)#switchport trunk allowed vlan 20,25,30,60
CORE-SWITCH(config-if)#no shutdown

! Fa0/3 — Trunk vers SW3-USERS (VLANs utilisateurs)
CORE-SWITCH(config)#interface FastEthernet0/3
CORE-SWITCH(config-if)#description TRUNK-vers-SW3-USERS
CORE-SWITCH(config-if)#switchport mode trunk
CORE-SWITCH(config-if)#switchport trunk allowed vlan 40,50
CORE-SWITCH(config-if)#no shutdown

! Fa0/4 — Trunk vers SW1-DMZ (VLAN 10 uniquement)
CORE-SWITCH(config)#interface FastEthernet0/4
CORE-SWITCH(config-if)#description TRUNK-vers-SW1-DMZ
CORE-SWITCH(config-if)#switchport mode trunk
CORE-SWITCH(config-if)#switchport trunk allowed vlan 10
CORE-SWITCH(config-if)#no shutdown

! Désactivation des ports inutilisés (sécurité)
CORE-SWITCH(config)#interface range FastEthernet0/5 - 24
CORE-SWITCH(config-if-range)#shutdown
```

:::tip Sécurité switch
Les ports non utilisés sont désactivés (`shutdown`) pour empêcher tout branchement non autorisé.
:::

---

## Étape 3 — SW1-DMZ (VLAN 10)

Switch dédié à la DMZ — héberge uniquement le Web Server public.

![Configuration SW1-DMZ](./img/11-SW_DMZ.png)

```cisco
Switch(config)#hostname SW1-DMZ

! Création VLAN 10
SW1-DMZ(config)#vlan 10
SW1-DMZ(config-vlan)#name DMZ

! Fa0/1 — Trunk vers CORE-SWITCH
SW1-DMZ(config)#interface FastEthernet0/1
SW1-DMZ(config-if)#description TRUNK-vers-CORE-SWITCH
SW1-DMZ(config-if)#switchport mode trunk
SW1-DMZ(config-if)#switchport trunk allowed vlan 10
SW1-DMZ(config-if)#no shutdown

! Fa0/2 — Access port vers Web Server (VLAN 10)
SW1-DMZ(config)#interface FastEthernet0/2
SW1-DMZ(config-if)#description Web-Server-VLAN10
SW1-DMZ(config-if)#switchport mode access
SW1-DMZ(config-if)#switchport access vlan 10
SW1-DMZ(config-if)#spanning-tree portfast
SW1-DMZ(config-if)#no shutdown

! Désactivation des ports inutilisés
SW1-DMZ(config)#interface range FastEthernet0/3 - 24
SW1-DMZ(config-if-range)#shutdown
```

**Serveur connecté sur Fa0/2 :**

| Serveur | IP | Services |
|---------|-----|---------|
| Web Server | 192.168.10.10 | Nginx + Laravel + ModSecurity WAF — HTTPS 443 |

---

## Étape 4 — SW2-SERVER (VLANs 20, 25, 30, 60)

Switch central pour tous les serveurs internes.

### 4.1 VLANs et ports serveurs

![Configuration SW2-SERVER](./img/12_SW2-SERVER.png)

```cisco
Switch(config)#hostname SW2-SERVER

! Création des VLANs
SW2-SERVER(config)#vlan 20
SW2-SERVER(config-vlan)#name APP
SW2-SERVER(config-vlan)#vlan 25
SW2-SERVER(config-vlan)#name DB
SW2-SERVER(config-vlan)#vlan 30
SW2-SERVER(config-vlan)#name MONITORING
SW2-SERVER(config-vlan)#vlan 60
SW2-SERVER(config-vlan)#name BACKUP

! Fa0/1 — Trunk vers CORE-SWITCH
SW2-SERVER(config)#interface FastEthernet0/1
SW2-SERVER(config-if)#description TRUNK-vers-CORE-SWITCH
SW2-SERVER(config-if)#switchport mode trunk
SW2-SERVER(config-if)#switchport trunk allowed vlan 20,25,30,60
SW2-SERVER(config-if)#no shutdown

! Fa0/2 — App Server (VLAN 20)
SW2-SERVER(config)#interface FastEthernet0/2
SW2-SERVER(config-if)#description App-Server-VLAN20
SW2-SERVER(config-if)#switchport mode access
SW2-SERVER(config-if)#switchport access vlan 20
SW2-SERVER(config-if)#spanning-tree portfast
SW2-SERVER(config-if)#no shutdown

! Fa0/3 — DB Server (VLAN 25)
SW2-SERVER(config)#interface FastEthernet0/3
SW2-SERVER(config-if)#description DB-Server-VLAN25
SW2-SERVER(config-if)#switchport mode access
SW2-SERVER(config-if)#switchport access vlan 25
SW2-SERVER(config-if)#spanning-tree portfast
SW2-SERVER(config-if)#no shutdown
```

### 4.2 Monitoring et Backup

![Configuration SW2-SERVER suite](./img/13_SW2-SERVER_SUITE.png)

```cisco
! Fa0/4 — Monitoring Server (VLAN 30)
SW2-SERVER(config)#interface FastEthernet0/4
SW2-SERVER(config-if)#description Monitoring-Server-VLAN30
SW2-SERVER(config-if)#switchport mode access
SW2-SERVER(config-if)#switchport access vlan 30
SW2-SERVER(config-if)#spanning-tree portfast
SW2-SERVER(config-if)#no shutdown

! Fa0/5 — Backup Server (VLAN 60)
SW2-SERVER(config)#interface FastEthernet0/5
SW2-SERVER(config-if)#description Backup-Server-VLAN60
SW2-SERVER(config-if)#switchport mode access
SW2-SERVER(config-if)#switchport access vlan 60
SW2-SERVER(config-if)#spanning-tree portfast
SW2-SERVER(config-if)#no shutdown
```

**Serveurs connectés :**

| Port | Serveur | IP | VLAN | Services |
|------|---------|-----|------|---------|
| Fa0/2 | App Server | 192.168.20.20 | 20 | CRUD RH (.10) + Ollama (.20) |
| Fa0/3 | DB Server | 192.168.25.10 | 25 | MariaDB — DB_WEB + DB_RH |
| Fa0/4 | Monitoring | 192.168.30.10 | 30 | Zabbix, Headscale, Nessus, Wazuh, Bitwarden, Grafana |
| Fa0/5 | Backup | 192.168.60.10 | 60 | rsync + cron + AES-256 |

---

## Étape 5 — SW3-USERS (VLANs 40 et 50)

Switch dédié aux postes utilisateurs et aux IT Admins.

### 5.1 VLANs et ports employés

![Configuration SW3-USERS](./img/14-__SW3-USERS.png)

```cisco
Switch(config)#hostname SW3-USERS

! Création des VLANs
SW3-USERS(config)#vlan 40
SW3-USERS(config-vlan)#name EMPLOYEES
SW3-USERS(config-vlan)#vlan 50
SW3-USERS(config-vlan)#name IT-ADMINS

! Fa0/1 — Trunk vers CORE-SWITCH
SW3-USERS(config)#interface FastEthernet0/1
SW3-USERS(config-if)#description TRUNK-vers-CORE-SWITCH
SW3-USERS(config-if)#switchport mode trunk
SW3-USERS(config-if)#switchport trunk allowed vlan 40,50
SW3-USERS(config-if)#no shutdown

! Fa0/2 — HR Department (VLAN 40)
SW3-USERS(config)#interface FastEthernet0/2
SW3-USERS(config-if)#description HR-Department-VLAN40
SW3-USERS(config-if)#switchport mode access
SW3-USERS(config-if)#switchport access vlan 40
SW3-USERS(config-if)#spanning-tree portfast
SW3-USERS(config-if)#no shutdown

! Fa0/3 — Developers (VLAN 40)
SW3-USERS(config)#interface FastEthernet0/3
SW3-USERS(config-if)#description Developers-VLAN40
SW3-USERS(config-if)#switchport mode access
SW3-USERS(config-if)#switchport access vlan 40
SW3-USERS(config-if)#spanning-tree portfast
SW3-USERS(config-if)#no shutdown
```

### 5.2 Finance, CEO, Marketing (VLAN 40)

![Configuration SW3-USERS — Finance, CEO, Marketing](./img/15_SW3-USERS.png)

```cisco
! Fa0/4 — Marketing (VLAN 40)
SW3-USERS(config)#interface FastEthernet0/4
SW3-USERS(config-if)#description Marketing-VLAN40
SW3-USERS(config-if)#switchport mode access
SW3-USERS(config-if)#switchport access vlan 40
SW3-USERS(config-if)#spanning-tree portfast
SW3-USERS(config-if)#no shutdown

! Fa0/5 — Finance (VLAN 40)
SW3-USERS(config)#interface FastEthernet0/5
SW3-USERS(config-if)#description Finance-VLAN40
SW3-USERS(config-if)#switchport mode access
SW3-USERS(config-if)#switchport access vlan 40
SW3-USERS(config-if)#spanning-tree portfast
SW3-USERS(config-if)#no shutdown

! Fa0/6 — CEO (VLAN 40)
SW3-USERS(config)#interface FastEthernet0/6
SW3-USERS(config-if)#description CEO-VLAN40
SW3-USERS(config-if)#switchport mode access
SW3-USERS(config-if)#switchport access vlan 40
SW3-USERS(config-if)#spanning-tree portfast
SW3-USERS(config-if)#no shutdown
```

### 5.3 IT Admins et Bastion SSH (VLAN 50)

![Configuration SW3-USERS — IT-Admins et Bastion](./img/15SW3-USERS_SUITE.png)

```cisco
! Fa0/7 — IT Admins PC (VLAN 50)
SW3-USERS(config)#interface FastEthernet0/7
SW3-USERS(config-if)#description IT-Admins-PC-VLAN50
SW3-USERS(config-if)#switchport mode access
SW3-USERS(config-if)#switchport access vlan 50
SW3-USERS(config-if)#spanning-tree portfast
SW3-USERS(config-if)#no shutdown

! Fa0/8 — Bastion SSH Server (VLAN 50)
SW3-USERS(config)#interface FastEthernet0/8
SW3-USERS(config-if)#description Bastion-SSH-Server-VLAN50
SW3-USERS(config-if)#switchport mode access
SW3-USERS(config-if)#switchport access vlan 50
SW3-USERS(config-if)#spanning-tree portfast
SW3-USERS(config-if)#no shutdown
```

**Postes connectés sur SW3-USERS :**

| Port | Poste | VLAN | Description |
|------|-------|------|-------------|
| Fa0/2 | HR Department PCs | 40 | Accès App CRUD RH + Web |
| Fa0/3 | Developers PCs | 40 | Accès Web App + documentation |
| Fa0/4 | Marketing PCs | 40 | Accès Web App uniquement |
| Fa0/5 | Finance PCs | 40 | Accès Web App uniquement |
| Fa0/6 | CEO PC | 40 | Accès Web App + CRUD (Read Only) |
| Fa0/7 | IT Admins PC | 50 | Accès SSH + monitoring complet |
| Fa0/8 | Bastion SSH Server | 50 | Point d'entrée SSH unique vers serveurs |

---

## Récapitulatif — Politique de sécurité inter-VLAN

```
VLAN 10 (DMZ)      → Internet : ✅ 80/443 sortant
                   → VLAN 20/25/30/40/50/60 : ❌ BLOQUÉ

VLAN 20 (APP)      → VLAN 25 (DB) port 3306 : ✅
                   → VLAN 30 (MON) Zabbix : ✅
                   → Internet direct : ❌

VLAN 25 (DB)       → Accessible uniquement depuis VLAN 20 et VLAN 10 sur 3306 ✅
                   → Internet : ❌ BLOQUÉ
                   → Tous autres VLANs : ❌ BLOQUÉ

VLAN 30 (MGMT)     → Accès admin depuis VLAN 50 : ✅
                   → Internet : ❌ BLOQUÉ

VLAN 40 (EMP.)     → VLAN 10 port 443 : ✅
                   → VLAN 20 ports 80/443 : ✅
                   → VLAN 25/60 : ❌ BLOQUÉ

VLAN 50 (ADMIN)    → SSH vers tous serveurs : ✅
                   → Accès monitoring complet : ✅

VLAN 60 (BACKUP)   → Reçoit rsync depuis tous serveurs ✅
                   → Internet : ❌ BLOQUÉ
```

---

## Vérification de la configuration

### Commandes de vérification — OPNsense

```cisco
! Vérifier les interfaces et sous-interfaces
OPNSENSE#show ip interface brief

! Vérifier les routes
OPNSENSE#show ip route

! Vérifier le NAT
OPNSENSE#show ip nat translations

! Vérifier les ACLs
OPNSENSE#show ip access-lists
OPNSENSE#show access-lists ACL_VLAN10_DMZ
OPNSENSE#show access-lists ACL_VLAN40_EMPLOYEES
```

### Commandes de vérification — Switches

```cisco
! Vérifier les VLANs
CORE-SWITCH#show vlan brief

! Vérifier les ports trunk
CORE-SWITCH#show interfaces trunk

! Vérifier un port spécifique
SW2-SERVER#show interfaces FastEthernet0/2 switchport

! Vérifier Spanning Tree
SW3-USERS#show spanning-tree vlan 40
```

### Tests de connectivité

```bash
# Depuis App Server (VLAN 20) → DB Server (VLAN 25) : doit fonctionner
ping 192.168.25.10

# Depuis poste Employé (VLAN 40) → DB Server (VLAN 25) : doit être BLOQUÉ
ping 192.168.25.10   # → Request timeout ✅ (bloqué par ACL)

# Depuis Web Server (VLAN 10) → App Server (VLAN 20) : doit être BLOQUÉ
ping 192.168.20.20   # → Request timeout ✅ (bloqué par ACL)

# Test sortie Internet depuis VLAN 40
ping 8.8.8.8         # → Succès via NAT ✅
```

---

:::note Environnement de simulation
Cette configuration a été réalisée dans **Cisco Packet Tracer** à des fins pédagogiques. En production, les mêmes règles seraient appliquées sur des équipements physiques ou dans un hyperviseur de production (Proxmox, VMware ESXi) avec des switches managés réels.
:::
