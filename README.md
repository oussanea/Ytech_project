# 🛡️ Ytech Solutions — Projet d'Infrastructure Sécurisée

Projet réalisé dans le cadre de la formation **JobInTech Cybersécurité — Casablanca 2025**

---

## 🎯 Aperçu

Ce projet consiste à concevoir, déployer et sécuriser une **infrastructure informatique d'entreprise complète** en partant d'un environnement vulnérable.

L'objectif est de transformer un système non sécurisé en une **architecture segmentée, surveillée, résiliente et "Zero Trust"**, en s'appuyant principalement sur des **technologies open-source**.

---

## 🏢 Contexte

**Ytech Solutions** est une entreprise fictive spécialisée dans les services numériques et le développement web pour les PME.

### 🔐 Données sensibles traitées
* Données clients
* Données RH
* Informations financières
* Code source des applications
* Identifiants et données d'accès administratif

### ❌ Problématiques initiales
L'infrastructure de départ présentait des faiblesses majeures :
* Réseau plat sans aucune segmentation
* Services publics et internes mélangés
* Absence de pare-feu dédié
* Pas de surveillance (monitoring) ni de journalisation centralisée
* Contrôle d'accès insuffisant
* Absence de gestionnaire de mots de passe
* Pas de stratégie de sauvegarde sécurisée
* Risque élevé de mouvement latéral après compromission

---

## 🧠 Méthodologie

Le projet a suivi une approche structurée :

* 📊 Analyse de risques (**ISO 27005 + EBIOS RM**)
* 🏗️ Conception d'une architecture sécurisée
* 🔐 Durcissement (Hardening) de la sécurité
* 📡 Déploiement de la surveillance et de la détection
* 🌐 Zero Trust & Accès distant sécurisé
* 🧪 Pentest (Avant / Après)
* 📈 Analyse du ROI et de la valeur métier

---

## 🏗️ Architecture

### 🔗 Segmentation VLAN

L'infrastructure finale est organisée en **7 VLAN isolés** :

| VLAN | Rôle |
| :--- | :--- |
| VLAN 10 | DMZ (Web Public + WAF) |
| VLAN 20 | Applications Internes |
| VLAN 25 | Base de données |
| VLAN 30 | Monitoring / Sécurité / Zero Trust |
| VLAN 40 | Utilisateurs |
| VLAN 50 | Administration (Bastion + Kali) |
| VLAN 60 | Sauvegarde (Backup) |

Cette segmentation limite les mouvements latéraux et applique le **principe du moindre privilège**.

---

## 🔐 Composants de Sécurité Centraux

### 🔥 Pare-feu OPNsense

Un élément central du projet est le déploiement d'**OPNsense** comme pare-feu principal.

#### Rôle d'OPNsense
* Filtrage inter-VLAN
* NAT et redirection de ports
* Politique "Default Deny" (tout interdire par défaut)
* Contrôle du trafic entre DMZ, APP, DB, MGMT, USERS et BACKUP
* Intégration avec **Suricata IDS/IPS**
* Publication sécurisée du serveur web public uniquement

#### Valeur sécuritaire
OPNsense agit comme le **point d'application principal** de l'architecture :
* Internet peut uniquement accéder à l'application web en DMZ
* Les applications internes et bases de données ne sont jamais exposées directement
* Seuls les flux explicitement autorisés sont permis

---

### 🌍 DMZ

L'application web publique Laravel est isolée dans une **DMZ**.

#### Avantages
* L'exposition publique est limitée à une seule zone
* La compromission du serveur web ne donne pas d'accès direct au réseau interne
* Les services sensibles (DB, monitoring, backup, application RH) restent protégés

---

### 🛡️ Bastion SSH

L'accès administratif SSH est centralisé via un **hôte bastion** situé dans le VLAN d'administration.

#### Rôle
* Point d'entrée unique et contrôlé pour les administrateurs
* Pas d'accès SSH direct depuis des réseaux non approuvés
* Traçabilité centralisée des accès admin
* Renforcement de la sécurité des accès privilégiés

#### Contrôles de sécurité
* Clés SSH uniquement
* Utilisateurs restreints
* Journalisation des connexions
* Séparation des postes de travail utilisateurs de la production

---

### 🔑 VPN WireGuard

L'infrastructure inclut un VPN d'accès distant sécurisé utilisant **WireGuard**.

#### Pourquoi WireGuard ?
* VPN léger et moderne
* Cryptographie forte
* Intégration facile avec OPNsense
* Hautes performances pour l'accès à distance

#### Cas d'utilisation
WireGuard est utilisé pour fournir :
* Un accès distant sécurisé pour les utilisateurs autorisés
* Une connectivité chiffrée vers les services internes
* Une réduction de l'exposition par rapport à un accès ouvert traditionnel

---

### 🌐 Zero Trust avec Headscale + Tailscale

Une couche **Zero Trust Network Access (ZTNA)** a été ajoutée en utilisant **Headscale** comme contrôleur auto-hébergé et les **clients Tailscale** sur les nœuds internes.

#### Pourquoi Headscale ?
* 100% auto-hébergé
* Aucune dépendance vis-à-vis d'un plan de contrôle SaaS tiers
* Meilleure confidentialité et gouvernance
* Compatible avec les clients officiels Tailscale

#### Nœuds connectés
* app-server
* db-server
* monitoring-server
* web-server
* backup-server

#### Valeur sécuritaire
Headscale/Tailscale garantit :
* L'authentification des utilisateurs/appareils avant l'accès
* Des tunnels chiffrés entre les nœuds
* Un contrôle d'accès au niveau applicatif
* Aucune confiance implicite à l'intérieur du réseau

---

## 🛡️ Hardening (Durcissement)

### Postes de travail Windows
* Pare-feu activé
* Windows Defender actif
* Politiques de mots de passe appliquées
* UAC activé
* Journalisation des événements activée
* Mises à jour automatiques activées

### Kali Linux (Poste Admin)
* SSH sécurisé
* Pare-feu UFW
* Fail2ban
* Auditd activé
* Services inutiles désactivés

### Serveurs Ubuntu
* Hardening SSH (pas de root, clés uniquement, port personnalisé)
* Pare-feu UFW
* Mises à jour de sécurité automatiques
* Configuration selon le moindre privilège
* Transfert de logs vers Wazuh
* Audit Lynis avant/après durcissement

---

## 📊 Opérations de Sécurité & Monitoring

Le projet comprend une pile complète de surveillance et de sécurité déployée dans le VLAN de gestion.

### Composants
* 📈 **Zabbix** → surveillance de l'infrastructure en temps réel
* 🧠 **Wazuh** → SIEM / HIDS / analyse de logs
* 📊 **Grafana** → Tableau de bord SOC
* 🔎 **Nessus** → scan de vulnérabilités
* 🔐 **Bitwarden / Vaultwarden** → gestion des mots de passe
* 🌐 **Headscale** → gestion des nœuds Zero Trust

### Objectifs
* Surveiller les hôtes et les services
* Détecter les activités suspectes
* Centraliser la visibilité sur la sécurité
* Valider l'efficacité des mesures de sécurité

---

## 🤖 YtechBot (Assistant IA Interne)

YtechBot est un assistant IA interne conçu pour les employés de l'entreprise.

### Stack technique
* Streamlit
* Ollama
* LLM Local
* MariaDB
* Docker

### Fonctionnalités de sécurité
* Authentification bcrypt
* Limitation de débit (Rate limiting)
* Expiration de session
* Logs de sécurité
* Exécution 100% locale
* Aucune dépendance à une API d'IA externe

### Valeur métier
YtechBot offre des capacités d'IA sans exposer les données de l'entreprise à des fournisseurs cloud tiers.

---

## 🛍️ Applications Métier

### Application Web Publique
* Laravel + Nginx + PHP
* Hébergée en DMZ
* HTTPS uniquement
* Protégée par **WAF ModSecurity + OWASP CRS**

### Application RH Interne (CRUD)
* Interne uniquement
* Accessible via des flux internes contrôlés
* Protégée par la segmentation et le contrôle d'accès
* Séparée de l'application web publique

---

## 🗄️ Couche Base de Données

Le serveur de base de données est isolé dans son propre VLAN.

### Principes clés
* Séparation des bases de données par rôle métier
* Accès restreint par IP et utilisateur
* Aucune exposition directe à Internet
* Moindre privilège au niveau SQL

### Bases de données
* `ytech_chatbot`
* `ytech_rh`
* `ytech_clients`

Cela empêche la compromission d'une application d'exposer automatiquement toutes les données.

---

## 💾 Sauvegarde & Résilience

Une stratégie de sauvegarde dédiée a été mise en œuvre à l'aide d'un serveur de sauvegarde séparé.

### Stratégie de sauvegarde
* **Règle 3-2-1**
* Chiffrement AES-256
* Sauvegarde locale + stockage externe
* Politique de rétention
* Copie distante sécurisée
* Approche orientée vers la restauration

### Valeur sécuritaire
La couche de sauvegarde protège contre :
* Les ransomwares
* Les pannes de serveurs
* La suppression accidentelle
* La corruption de données

---

## 🧪 Résultats du Pentest

Un pentest contrôlé a été effectué avant et après le durcissement.

### ❌ Avant
* Injection SQL possible
* Force brute SSH possible
* Réseau plat permettant le mouvement latéral
* Risques d'exposition de la base de données
* Faible monitoring et traçabilité

### ✅ Après
* Le WAF bloque les attaques web
* SSH protégé et centralisé via le bastion
* Accès distant sécurisé par WireGuard et Zero Trust
* La segmentation VLAN empêche la propagation
* OPNsense bloque les flux non autorisés
* Le monitoring et le SIEM offrent une visibilité complète

👉 **Réduction estimée du risque : ~75%**

---

## ⚙️ DevOps

Le projet intègre également des pratiques de DevOps et de gestion de projet :

* Workflow GitHub multi-branches
* Déploiement via Docker Compose
* Organisation des sprints sur Jira
* Documentation technique Docusaurus

---

## 📊 Résultats

| Indicateur | Résultat |
| :--- | :--- |
| Posture de sécurité | Fortement améliorée |
| Réduction des risques | ~75% |
| Surveillance | Temps réel |
| Pare-feu | OPNsense déployé |
| VPN | WireGuard déployé |
| Zero Trust | Headscale + Tailscale déployé |
| Bastion | Accès admin SSH centralisé |
| Coût | 0 € de licences |
| Alignement | Orienté ISO 27001 |

---

## 💰 Impact Métier

* 💸 Économies significatives sur les coûts annuels grâce aux outils open-source
* 🚫 Risques financiers majeurs évités
* 🔒 Meilleur alignement avec le RGPD
* 📈 ROI (Retour sur investissement) solide
* 🏢 Architecture professionnelle réutilisable pour des clients PME

---

## 👥 Équipe

| Membre | Rôle |
| :--- | :--- |
| Raja JARFANI | Chef de projet · Monitoring · IA · Headscale · DevOps |
| Asmaa ELKOURTI| Sécurité réseau · OPNsense · WireGuard · Hardening |
| Sara OUSSANEA| Applications · Nessus · Agents |
| Meryem ASSADI| Web · WAF · Backup · Wazuh |
| Chaymae TARIQ | Architecture réseau · Grafana |

---

## 📁 Structure du Projet

```text
Ytech_project/
├── infrastructure/
├── monitoring/
├── hardening/
├── chatbot/
├── webapp/
├── pentest/
└── docs/
