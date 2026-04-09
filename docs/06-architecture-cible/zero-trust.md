---
id: zero-trust
title: Architecture Zero Trust (ZTNA)
sidebar_position: 4
---

### La Fin de la Confiance Implicite

Dans l'architecture initiale de **Ytech Solutions**, le réseau était "plat" : une fois à l'intérieur du LAN, tout le monde faisait confiance à tout le monde. Pour l'architecture cible, nous avons adopté le modèle **Zero Trust Network Access (ZTNA)**. Le principe directeur est simple : **"Ne jamais faire confiance, toujours vérifier"**.

L'accès aux ressources n'est plus accordé en fonction de l'emplacement physique, mais repose sur l'identité de l'utilisateur, l'état de la machine et une authentification forte.

#### 🛠️ Le Coeur du Système : Headscale & Tailscale

Pour implémenter cette stratégie sans frais de licence, nous avons déployé une stack open source robuste et souveraine:

1.  **Headscale (Le Contrôle)** : Installé sur la VM de **Monitoring (VLAN 30)**, il s'agit de la version open source auto-hébergée du serveur de contrôle Tailscale. Il gère la base de données des nœuds, les clés de chiffrement et les politiques d'accès sans que les données ne quittent l'infrastructure de l'entreprise.
2.  **Tailscale (Les Agents)** : Des agents légers sont installés sur chaque serveur critique (Web, APP, DB, Backup) et sur les postes des administrateurs.
3.  **Le Moteur WireGuard** : Bien que transparent pour l'utilisateur, Headscale utilise le protocole **WireGuard** pour créer des tunnels chiffrés point à point (Peer-to-Peer), garantissant que même si un switch est compromis, les données restent illisibles.

#### 🌐 L'Overlay Network (Réseau Superposé)

Headscale crée un réseau virtuel sécurisé au-dessus de notre infrastructure physique. Chaque machine reçoit une adresse IP unique dans la plage réservée **100.64.0.0/10**, totalement isolée du trafic local standard.

| Machine | IP Tailscale (ZTNA) | Rôle dans le maillage |
| :--- | :--- | :--- |
| **app-server** | 100.64.0.1 | Serveur applicatif (RH + Chatbot) |
| **web-server** | 100.64.0.2 | Serveur public (DMZ) |
| **backup-server** | 100.64.0.3 | Serveur de sauvegarde |
| **db-server** | 100.64.0.4 | Serveur de base de données |
| **monitoring-server** | 100.64.0.5 | Contrôleur Headscale |
| **finance-pc** | 100.64.0.6 | Poste employé Finance |
| **hr-pc** | 100.64.0.8 | Poste employé RH |

#### 🔐 Politiques d'Accès et Authentification Forte (MFA)

Le Zero Trust applique strictement le principe du **moindre privilège**:

*   **MFA Obligatoire** : L'accès aux ressources sensibles (comme l'application CRUD RH ou la base de données) nécessite obligatoirement une authentification multi-facteur.
*   **Segmentation par Rôle** :
    *   Les **Administrateurs IT** peuvent accéder à tous les VLANs via le tunnel sécurisé.
    *   Le département **RH** peut accéder à l'application CRUD (`100.64.0.1:8443`) mais n'a aucune visibilité sur le serveur de base de données.
    *   Le **DB Server** est configuré pour n'accepter des connexions que depuis les IPs Tailscale des serveurs applicatifs, bloquant toute tentative directe.

#### 🚦 Distinction : VPN WireGuard vs Zero Trust

Il est crucial de ne pas confondre les deux solutions de sécurité déployées:
1.  **VPN WireGuard (Accès Distant)** : Configuré sur le firewall **OPNsense**, il sert exclusivement au tunnel entre l'Internet et l'entreprise pour les employés en télétravail.
2.  **Zero Trust Headscale (Sécurité Interne)** : Il sécurise les flux **entre les serveurs** et les accès administratifs internes, créant une barrière invisible même si un attaquant parvient à s'introduire dans le réseau local.

