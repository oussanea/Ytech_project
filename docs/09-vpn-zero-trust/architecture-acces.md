---
id: architecture-acces
title: Architecture d’accès
sidebar_position: 3
---

# Architecture d’accès

## 🎯 Objectif

Cette architecture définit comment les utilisateurs accèdent aux différents services de l’infrastructure de manière sécurisée, en appliquant le modèle Zero Trust.

---

## 🌐 Accès aux services

L’accès aux ressources se fait via un réseau privé sécurisé (overlay network) basé sur NetBird / Headscale.

Chaque utilisateur est identifié et associé à un **tag** (rôle) :

- `tag:ceo`
- `tag:hr`
- `tag:developer`
- `tag:finance`
- `tag:commercial`
- `tag:it-admin`

---

## 🔐 Principe Zero Trust

- Aucun accès n’est autorisé par défaut  
- Chaque connexion est validée via des règles ACL  
- Les utilisateurs accèdent uniquement aux services nécessaires  

👉 Tout accès non défini est automatiquement bloqué

---

## 🔀 Flux d’accès

### Accès à l’application RH

- Accessible uniquement via HTTPS (port 8443)
- Autorisé pour :
  - CEO
  - HR
- Refusé pour :
  - Finance
  - Commercial

---

### Accès à l’IA (Ollama)

- Port : 8501  
- Accessible pour :
  - CEO
  - HR
  - Developer
  - Finance
  - Commercial

---

### Accès à l’application web

- Port : 443  
- Accessible pour :
  - Finance
  - Commercial
  - Tous les utilisateurs (selon ACL)

---

### Accès à la base de données

- Port : 3306  
- Accessible uniquement par :
  - server-app
  - server-web  

👉 Aucun accès direct utilisateur

---

## 🧩 Segmentation des accès

L’infrastructure est segmentée en plusieurs zones :

- Zone utilisateurs
- Zone applicative
- Zone base de données
- Zone monitoring

Chaque zone est isolée et communique uniquement via des règles définies.

---

## 🛡️ Sécurité appliquée

- Contrôle d’accès basé sur les rôles (RBAC)
- ACL réseau strictes
- Isolation des services critiques
- Communication chiffrée (HTTPS)

---

## ✅ Résultat

Cette architecture garantit :

- Une réduction de la surface d’attaque  
- Une isolation des données sensibles  
- Une gestion fine des accès  

👉 Implémentation concrète du modèle Zero Trust