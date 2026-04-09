---
id: vision-globale
title: Vision Globale de l'Architecture
sidebar_position: 1
---

### Stratégie de Défense en Profondeur

![Vision globale architecture](./schema-final.png)

Pour transformer l'infrastructure vulnérable de **Ytech Solutions** en un environnement résilient, nous avons adopté une stratégie de **défense en profondeur**. Cette approche consiste à superposer plusieurs couches de sécurité indépendantes, garantissant que la défaillance d'un seul contrôle n'entraîne pas la compromission totale du système.

#### 🛡️ Principes Fondateurs
L'architecture cible est construite sur trois piliers technologiques et méthodologiques qui répondent directement aux menaces identifiées :

1.  **Isolation (Segmentation VLAN)** : Le passage d'un réseau plat à une segmentation en **7 zones étanches** (VLANs) permet de confiner les menaces et d'empêcher la propagation latérale de malwares.
2.  **Contrôle Strict (Deny by Default)** : Toute communication non explicitement autorisée est **bloquée par défaut** au niveau du firewall OPNSense et des ACL Cisco .
3.  **Zéro Confiance (Zero Trust)** : L'accès aux ressources internes n'est plus accordé par défaut. Chaque utilisateur et chaque machine doit être authentifié et autorisé via **Headscale/Tailscale**, même à l'intérieur du réseau.

#### 📈 Alignement ISO/IEC 27001
Cette vision globale assure la conformité de l'entreprise aux standards internationaux en protégeant les trois piliers de la triade **CIA**:
*   **Confidentialité** : Assurée par le chiffrement TLS 1.3 et la segmentation stricte.
*   **Intégrité** : Garantie par la centralisation des logs dans Wazuh et le contrôle d'accès RBAC.
*   **Disponibilité** : Maintenue via le failover ISP sur OPNSense et le monitoring Zabbix.

#### 💶 Valeur Business
Le passage à cette architecture permet de réduire l'impact financier d'un incident de sécurité de **80 à 90%**. En utilisant exclusivement des solutions **Open Source** (OPNSense, Zabbix, Wazuh, Headscale), Ytech Solutions réalise une économie annuelle de **34 892 €** en frais de licences par rapport à une infrastructure propriétaire équivalente.

> **Note de conception** : Bien que simulée via **Cisco Packet Tracer** et VirtualBox pour ce projet, cette architecture est conçue pour être déployée sur du matériel professionnel réel (Switches Cisco Catalyst 2960, serveurs Dell PowerEdge).
