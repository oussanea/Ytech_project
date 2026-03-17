<?php
/**
 * Déconnexion
 * HR Management System
 */

require_once __DIR__ . '/config/app.php';

$_SESSION = [];
session_destroy();
session_start();
session_regenerate_id(true);

header('Location: ' . BASE_URL . '/login.php');
exit;
