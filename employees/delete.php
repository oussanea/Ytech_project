<?php
/**
 * Supprimer un employé (IT Admin uniquement)
 * HR Management System
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/auth.php';

if (!canDeleteEmployee()) {
    header('Location: index.php');
    exit;
}

$id         = (int) ($_GET['id'] ?? 0);
$department = $_GET['department'] ?? '';

if ($id) {
    $stmt = $pdo->prepare("DELETE FROM employees WHERE id = ?");
    $stmt->execute([$id]);
}

header('Location: list.php?department=' . urlencode($department));
exit;
