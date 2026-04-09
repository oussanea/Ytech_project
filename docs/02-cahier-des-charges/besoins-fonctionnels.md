---
id: besoins-fonctionnels
title: Besoins fonctionnels
sidebar_position: 1
---

# Besoins fonctionnels

## Vue d'ensemble

Ytech Solutions a besoin d'une infrastructure hébergeant **trois services applicatifs principaux**, accessibles selon les rôles et départements de l'entreprise.

---

## BF-01 — Application Web commerciale

> **Portée** : Publique — accessible depuis Internet

L'application web principale permet à Ytech Solutions de présenter ses services et de gérer les commandes de packs web.

### Fonctionnalités requises

| ID | Fonctionnalité | Priorité |
|---|---|---|
| BF-01.1 | Présentation des services et packs de développement web | 🔴 Haute |
| BF-01.2 | Prise de contact client (formulaire) | 🔴 Haute |
| BF-01.3 | Gestion basique des commandes | 🟡 Moyenne |
| BF-01.4 | Communication chiffrée via HTTPS | 🔴 Haute |
| BF-01.5 | Protection WAF contre les attaques web (SQLi, XSS…) | 🔴 Haute |

### Stack technique

- **Backend** : Laravel + PHP 8.x
- **Serveur web** : Nginx + ModSecurity WAF (OWASP CRS)
- **Base de données** : MariaDB — base `db_clients`
- **Chiffrement** : TLS 1.3 + headers de sécurité HTTP
- **Localisation** : VLAN 10 — DMZ (`192.168.10.10`)

:::warning Isolation DMZ
L'application web est placée en DMZ et ne peut **jamais** accéder directement aux VLANs internes (RH, MGMT, BACKUP). Seule la connexion vers la base de données clients est autorisée via le firewall.
:::

---

## BF-02 — Application CRUD Ressources Humaines

> **Portée** : Interne uniquement — jamais exposée sur Internet

L'application RH est réservée au département Ressources Humaines et permet la gestion complète des fiches employés.

### Fonctionnalités requises

| ID | Fonctionnalité | Priorité |
|---|---|---|
| BF-02.1 | Ajouter un employé | 🔴 Haute |
| BF-02.2 | Modifier les informations d'un employé | 🔴 Haute |
| BF-02.3 | Supprimer un employé (admins uniquement) | 🔴 Haute |
| BF-02.4 | Consulter la liste des employés | 🔴 Haute |
| BF-02.5 | Authentification avec gestion de sessions | 🔴 Haute |
| BF-02.6 | Accès restreint par rôle (RH sans suppression, admin complet) | 🟡 Moyenne |

### Stack technique

- **Backend** : PHP 8.1 + Apache
- **Base de données** : MariaDB — base `db_rh`
- **Conteneurisation** : Docker Compose
- **Accès** : Zero Trust via Headscale/Tailscale (MFA obligatoire)
- **Localisation** : VLAN 20 — APP (`192.168.20.10`)

:::danger Accès interdit depuis Internet
Toute tentative d'accès à l'application RH depuis Internet est bloquée par OPNSense. L'accès est uniquement possible depuis le réseau interne ou via tunnel Tailscale authentifié.
:::

---

## BF-03 — Chatbot IA YtechBot

> **Portée** : Interne — employés Ytech Solutions

YtechBot est un assistant conversationnel IA local, déployé pour les employés de Ytech Solutions.

### Fonctionnalités requises

| ID | Fonctionnalité | Priorité |
|---|---|---|
| BF-03.1 | Interface web de chat (Streamlit) | 🔴 Haute |
| BF-03.2 | Authentification avec blocage après 3 tentatives (15 min) | 🔴 Haute |
| BF-03.3 | Session timeout automatique (30 min) | 🟡 Moyenne |
| BF-03.4 | Rate limiting (10 messages/minute) | 🟡 Moyenne |
| BF-03.5 | Upload de fichiers (PDF, Word, TXT) | 🟡 Moyenne |
| BF-03.6 | Historique des conversations (soft delete) | 🟢 Basse |
| BF-03.7 | Inférence IA 100% locale (pas de cloud) | 🔴 Haute |

### Stack technique

- **Interface** : Streamlit (Python)
- **Moteur IA** : Ollama + modèle `llama3.2:1b` (local)
- **Base de données** : MariaDB — base `ytech_chatbot`
- **Sécurité** : bcrypt, sanitisation des inputs, logs complets
- **Chiffrement** : HTTPS avec certificat SSL auto-signé
- **Localisation** : VLAN 20 — APP (`192.168.20.20:8501`)

---

## BF-04 — Matrice des accès utilisateurs

Le tableau suivant synthétise les droits d'accès de chaque profil sur les trois applications :

| Profil | App Web | CRUD RH | YtechBot |
|---|---|---|---|
| Directeur Général | ✅ Lecture | ✅ Lecture seule | ✅ |
| Administrateurs IT | ✅ Complet | ✅ Complet | ✅ |
| Développeurs | ✅ | ✗ | ✅ |
| Ressources Humaines | ✅ | ✅ Sans suppression | ✅ |
| Comptabilité | ✅ | ✗ | ✅ |
| Commercial / Marketing | ✅ | ✗ | ✅ |

---

## BF-05 — Gestion des données

### Bases de données

Trois bases de données **strictement séparées** sont déployées sur le serveur MariaDB (VLAN 25) :

| Base | Application | Utilisateur BDD | Accès autorisé depuis |
|---|---|---|---|
| `db_clients` | App Web Laravel | `web_user` | Web Server `.10.10` uniquement |
| `db_rh` | App CRUD RH | `rh_user` | App Server `.20.10` uniquement |
| `ytech_chatbot` | YtechBot | `chatbot` | App Server `.20.20` uniquement |

### Sauvegarde

Les trois bases font l'objet d'une **sauvegarde quotidienne automatique** à 02h00, chiffrée en AES-256 et synchronisée sur Google Drive selon la règle 3-2-1.
