<?php
/**
 * Configuration générale de l'application
 * HR Management System
 */

// Démarrer la session si pas déjà démarrée
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Constantes
define('APP_NAME', 'Système RH');
define('BASE_URL', '/RH-CRUD_appllication/hr-crud-app');

// Rôles utilisateur
define('ROLE_CEO', 'CEO');
define('ROLE_HR', 'HR');
define('ROLE_IT_ADMIN', 'IT Admin');
