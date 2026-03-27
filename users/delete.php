<?php
/**
 * Supprimer un utilisateur
 * HR Management System - IT Admin uniquement
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/auth.php';

if (!hasRole(ROLE_IT_ADMIN)) {
    header('Location: ' . BASE_URL . '/dashboard.php');
    exit;
}

$id = (int) ($_GET['id'] ?? 0);

if (!$id) {
    header('Location: ' . BASE_URL . '/users/index.php');
    exit;
}

// Empêcher de se supprimer soi-même
if ($id === (int) $_SESSION['user_id']) {
    header('Location: ' . BASE_URL . '/users/index.php?error=' . urlencode('Vous ne pouvez pas supprimer votre propre compte.'));
    exit;
}

$stmt = $pdo->prepare("SELECT id FROM users WHERE id = ?");
$stmt->execute([$id]);
if (!$stmt->fetch()) {
    header('Location: ' . BASE_URL . '/users/index.php?error=' . urlencode('Utilisateur introuvable.'));
    exit;
}

$stmt = $pdo->prepare("DELETE FROM users WHERE id = ?");
$stmt->execute([$id]);

header('Location: ' . BASE_URL . '/users/index.php?success=' . urlencode('Utilisateur supprimé avec succès.'));
exit;
