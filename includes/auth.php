<?php
/**
 * Fonctions d'authentification
 * HR Management System - Vérification des rôles
 */

require_once __DIR__ . '/../config/app.php';

/**
 * Vérifie si l'utilisateur est connecté
 */
function isLoggedIn() {
    return isset($_SESSION['user_id']);
}

/**
 * Vérifie le rôle de l'utilisateur
 */
function hasRole($role) {
    return isLoggedIn() && isset($_SESSION['user_role']) && $_SESSION['user_role'] === $role;
}

/**
 * Vérifie si l'utilisateur peut ajouter des employés
 */
function canAddEmployee() {
    return hasRole(ROLE_HR) || hasRole(ROLE_IT_ADMIN);
}

/**
 * Vérifie si l'utilisateur peut modifier des employés
 */
function canEditEmployee() {
    return hasRole(ROLE_HR) || hasRole(ROLE_IT_ADMIN);
}

/**
 * Vérifie si l'utilisateur peut supprimer des employés
 */
function canDeleteEmployee() {
    return hasRole(ROLE_IT_ADMIN);
}

/**
 * Vérifie si l'utilisateur peut modifier tous les champs (IT Admin uniquement)
 */
function canEditAllFields() {
    return hasRole(ROLE_IT_ADMIN);
}

/**
 * Vérifie si l'utilisateur peut gérer les absences
 */
function canManageAbsences() {
    return hasRole(ROLE_HR) || hasRole(ROLE_IT_ADMIN);
}

/**
 * Redirige vers la page de connexion si non authentifié
 */
function requireLogin() {
    if (!isLoggedIn()) {
        header('Location: ' . BASE_URL . '/login.php');
        exit;
    }
}
