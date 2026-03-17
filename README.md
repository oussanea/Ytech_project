# Système RH - HR Management System

Application de gestion des ressources humaines en PHP/MySQL, créée pour un cours de cybersécurité.  
**L'application est volontairement simple et non sécurisée** pour permettre la démonstration de vulnérabilités (SQL Injection, XSS, CSRF).

## Prérequis

- WAMP (Windows) ou LAMP (Linux)
- PHP 7.4+
- MySQL 5.7+ ou MariaDB
- Apache avec mod_rewrite (optionnel)

## Installation

### 1. Base de données

Créer la base et importer le schéma :

```bash
mysql -u root -p < database/schema.sql
```

Ou via phpMyAdmin : créer une base `hr_system` et exécuter le contenu de `database/schema.sql`.

### 2. Configuration

Modifier si nécessaire `config/database.php` :

```php
$host = 'localhost';
$dbname = 'hr_system';
$username = 'root';
$password = '';
```

Modifier `config/app.php` si le chemin de l'application diffère :

```php
define('BASE_URL', '/RH-CRUD_appllication');
```

### 3. Accès

Ouvrir : `http://localhost/RH-CRUD_appllication/`

## Comptes de test

| Rôle    | Identifiant | Mot de passe  |
|---------|-------------|---------------|
| CEO     | ceo         | password123   |
| HR      | hr          | password123   |
| IT Admin| admin       | password123   |

## Permissions par rôle

| Action               | CEO | HR | IT Admin |
|----------------------|-----|----|----------|
| Voir dashboard       | ✓   | ✓  | ✓        |
| Voir employés        | ✓   | ✓  | ✓        |
| Ajouter employé      | ✗   | ✓  | ✓        |
| Modifier (salaire, téléphone, adresse, statut) | ✗ | ✓ | ✓ |
| Modifier (nom, département) | ✗ | ✗ | ✓ |
| Supprimer employé    | ✗   | ✗  | ✓        |
| Marquer absences     | ✗   | ✓  | ✓        |

## Structure du projet

```
RH-CRUD_appllication/
├── config/
│   ├── app.php
│   └── database.php
├── includes/
│   ├── auth.php
│   ├── header.php
│   └── footer.php
├── assets/
│   ├── css/style.css
│   └── js/app.js
├── database/
│   └── schema.sql
├── employees/
│   ├── index.php      (choisir département)
│   ├── list.php
│   ├── create.php
│   ├── edit.php
│   └── delete.php
├── absences/
│   ├── mark.php
│   └── today.php
├── departments/
│   └── index.php
├── index.php
├── login.php
├── logout.php
└── dashboard.php
```

## Départements

- Direction Générale
- Informatique (IT)
- Développement
- Ressources Humaines
- Finance / Comptabilité
- Commercial & Marketing

## Note de sécurité

Cette application contient des vulnérabilités intentionnelles pour l'apprentissage :

- **SQL Injection** : requêtes non préparées avec concaténation directe
- **XSS** : certains champs pourraient afficher du contenu non échappé
- **CSRF** : formulaires sans jetons CSRF

Ne pas utiliser en production sans corrections de sécurité.
