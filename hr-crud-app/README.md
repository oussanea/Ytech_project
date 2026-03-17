# 🏢 Application RH - HR Management System

Application web de gestion des ressources humaines développée en **PHP / MySQL**.

Cette application fait partie du projet global de cybersécurité **Ytech Solutions**.

---

## 🎯 Objectif

Fournir un système interne permettant de :

* Gérer les employés
* Gérer les départements
* Suivre les absences
* Appliquer des rôles et permissions

---

## ⚙️ Technologies utilisées

* PHP (Vanilla)
* MySQL / MariaDB
* HTML / CSS / Bootstrap
* Apache (WAMP / LAMP)

---

## 🚀 Fonctionnalités

### 🔐 Authentification

* Connexion via login
* Sessions PHP
* Gestion des rôles (CEO, HR, IT Admin)

---

### 📊 Tableau de bord

* Total employés
* Employés actifs
* Absences du jour
* Répartition par département

---

### 👥 Gestion des employés

* Ajout d’employés
* Modification des informations
* Activation / Désactivation (pas de suppression pour HR)
* Filtrage par département

---

### 🏢 Départements

* Direction Générale
* Informatique (IT)
* Développement
* Ressources Humaines
* Finance / Comptabilité
* Commercial & Marketing

---

### 📅 Gestion des absences

* Sélection multiple
* Enregistrement des absences
* Affichage dans le dashboard

---

## 🔐 Gestion des rôles

| Action                                         | CEO | HR | IT Admin |
| ---------------------------------------------- | --- | -- | -------- |
| Voir dashboard                                 | ✅   | ✅  | ✅        |
| Voir employés                                  | ✅   | ✅  | ✅        |
| Ajouter employé                                | ❌   | ✅  | ✅        |
| Modifier (salaire, téléphone, adresse, statut) | ❌   | ✅  | ✅        |
| Modifier (nom, département)                    | ❌   | ❌  | ✅        |
| Supprimer employé                              | ❌   | ❌  | ✅        |
| Marquer absences                               | ❌   | ✅  | ✅        |

---

## ⚠️ Sécurité

### Phase 1 (initiale)

Application volontairement vulnérable :

* SQL Injection
* XSS
* Absence de CSRF

---

### Phase 2 (amélioration)

Corrections implémentées :

* password_hash() / password_verify()
* Requêtes préparées (PDO)
* htmlspecialchars() pour XSS
* Sessions sécurisées

---

## 🛠 Installation

### 1. Base de données

```bash
mysql -u root -p < database/schema.sql
```

---

### 2. Configuration

Modifier :

```php
config/database.php
```

---

### 3. Accès

```text
http://localhost/RH-CRUD_appllication/hr-crud-app/
```

---

## 🔑 Comptes de test

| Rôle     | Username | Password    |
| -------- | -------- | ----------- |
| CEO      | ceo      | password123 |
| HR       | hr       | password123 |
| IT Admin | admin    | password123 |

---

## 📁 Structure

```text
hr-crud-app/
├── config/
├── includes/
├── assets/
├── database/
├── employees/
├── absences/
├── login.php
├── dashboard.php
```

---

## 🧪 Tests de sécurité

Cette application sera utilisée pour :

* Tests SQL Injection
* Tests XSS
* Tests d’authentification
* Analyse avec Burp Suite / SQLMap

---

## ⚠️ Disclaimer

Projet académique.

❌ Ne pas utiliser en production sans sécurisation complète.
