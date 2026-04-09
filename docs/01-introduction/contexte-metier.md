---
id: contexte-metier
title: Contexte métier
sidebar_position: 3
---

# Contexte métier

Le contexte métier de Ytech Solutions impose une gestion rigoureuse de la sécurité, en raison de la nature critique des services numériques proposés et des données manipulées.

## Pourquoi ce projet ?

Ytech Solutions gère des données sensibles pour le compte de ses clients PME : données personnelles, informations financières, code source d'applications web. Cette responsabilité impose un niveau de sécurité élevé.

L'infrastructure initiale présentait des **lacunes critiques** : réseau plat sans segmentation, absence de supervision, serveurs exposés directement sur le LAN, aucune politique de gestion des accès. Une compromission d'un seul poste pouvait suffire à atteindre l'ensemble des serveurs, y compris la base de données.

Ces faiblesses ont motivé la mise en place d’un audit de sécurité complet, incluant un test d’intrusion (Pentest) afin d’évaluer les risques réels et les impacts potentiels.

---

## Les données sensibles traitées

| Type de données | Sensibilité | Localisation |
|---|---|---|
| Données clients (commandes, contacts) | 🔴 Haute | Base `db_clients` |
| Données RH (salaires, contrats) | 🔴 Haute | Base `db_rh` |
| Données applicatives web | 🟡 Moyenne | Base `db_web` |
| Code source des projets clients | 🔴 Haute | GitHub / serveurs |
| Identifiants & mots de passe | 🔴 Haute | Bitwarden |

---

## Les services exposés

Ytech Solutions opère **deux applications web principales** :

### Application Web commerciale
Interface publique accessible depuis Internet, permettant la présentation des services et la prise de commande de packs web.

- Technologie : Laravel + Nginx + PHP
- Accès : Public via HTTPS
- Protection : WAF ModSecurity + TLS 1.3 + Headers sécurité

### Application CRUD Ressources Humaines
Interface interne réservée au département RH, permettant la gestion des fiches employés.

- Technologie : PHP 8.1 + Apache + MariaDB
- Accès : Interne uniquement, **jamais exposée sur Internet**
- Protection : Headscale Zero Trust + authentification applicative

---

## Les contraintes imposées

Le cahier des charges impose l'intégration des outils suivants :

| Catégorie | Outil retenu |
|---|---|
| Scanner de vulnérabilités | Nessus Essentials |
| Monitoring | Zabbix + Grafana |
| Gestionnaire de mots de passe | Bitwarden (Vaultwarden) |
| IA locale | Ollama + llama3.2:1b |
| Zero Trust Network Access | Headscale + Tailscale |
| Firewall dédié | OPNSense |
| Gestion de projet | Jira |
| Documentation | Docusaurus |

---

## Alignement ISO 27001

Le projet s'aligne sur les principes fondamentaux de la norme **ISO/IEC 27001** :

| Principe | Mesure mise en place |
|---|---|
| Confidentialité | Chiffrement TLS 1.3 + AES-256, accès restreints |
| Intégrité | Logs auditd, Wazuh SIEM, contrôle d'accès RBAC |
| Disponibilité | Double ISP failover, backup 3-2-1, monitoring Zabbix |
| Traçabilité | Logs centralisés Wazuh, auditd, fail2ban |
| Moindre privilège | VLAN segmentation, Zero Trust, rôles applicatifs |

Cet alignement permet d’assurer une approche structurée de la sécurité et de rapprocher l’infrastructure des standards professionnels utilisés en entreprise.
