<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../config/app.php';

if (!canManageAbsences()) {
    header('Location: ' . BASE_URL . '/dashboard.php');
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

header('Location: ' . BASE_URL . '/employees/index.php');
exit;