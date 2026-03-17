<?php
/**
 * Save absences and redirect back
 * HR Management System
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/auth.php';

if (!canManageAbsences()) {
    header('Location: ../dashboard.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['employee_ids'])) {

    $today = date('Y-m-d');

    foreach ($_POST['employee_ids'] as $empId) {

        $empId = (int) $empId;

        if ($empId > 0) {

            $stmt = $pdo->prepare("
                INSERT INTO absences (employee_id, date)
                VALUES (?, ?)
            ");

            $stmt->execute([$empId, $today]);
        }
    }
}

/* Return to previous page (employees list) */
header("Location: " . $_SERVER['HTTP_REFERER']);
exit;
