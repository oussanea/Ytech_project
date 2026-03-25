<?php
require_once __DIR__ . '/../config/database.php';

$id = (int) ($_GET['id'] ?? 0);

if ($id > 0) {

$today = date('Y-m-d');

$stmt = $pdo->prepare("
DELETE FROM absences 
WHERE employee_id = ? AND date = ?
");

$stmt->execute([$id, $today]);

}

header("Location: " . $_SERVER['HTTP_REFERER']);
exit;