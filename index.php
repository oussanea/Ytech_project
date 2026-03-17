<?php
/**
 * Redirection vers le tableau de bord ou la page de connexion
 * HR Management System
 */

require_once __DIR__ . '/config/app.php';

if (isset($_SESSION['user_id'])) {
    header('Location: ' . BASE_URL . '/dashboard.php');
} else {
    header('Location: ' . BASE_URL . '/login.php');
}
exit;
