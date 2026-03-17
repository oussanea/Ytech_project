<?php
/**
 * Tableau de bord
 * HR Management System - Vue d'ensemble
 */

$pageTitle = 'Tableau de bord';
require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/includes/header.php';

// Statistiques
$totalEmployees = $pdo->query("SELECT COUNT(*) FROM employees")->fetchColumn();
$activeEmployees = $pdo->query("SELECT COUNT(*) FROM employees WHERE status = 'active'")->fetchColumn();
$departmentsCount = $pdo->query("SELECT COUNT(*) FROM departments")->fetchColumn();

// Absences du jour
$today = date('Y-m-d');
$absencesToday = $pdo->prepare("SELECT COUNT(*) FROM absences WHERE date = ?");
$absencesToday->execute([$today]);
$absencesCount = $absencesToday->fetchColumn();

// Employés par département
$employeesByDept = $pdo->query("
    SELECT d.name, COUNT(e.id) as count 
    FROM departments d 
    LEFT JOIN employees e ON e.department_id = d.id AND e.status = 'active'
    GROUP BY d.id, d.name
")->fetchAll();

// Liste des absents aujourd'hui
$absentList = $pdo->prepare("
    SELECT e.name, d.name as department_name 
    FROM absences a 
    JOIN employees e ON e.id = a.employee_id 
    JOIN departments d ON d.id = e.department_id
    WHERE a.date = ?
");
$absentList->execute([$today]);
$absentEmployees = $absentList->fetchAll();
?>

<!-- Statistiques -->
<div class="row mb-4">
    <div class="col-md-3">
        <div class="card card-stat primary">
            <div class="card-body">
                <h6 class="text-muted">Total employés</h6>
                <h3><?= $totalEmployees ?></h3>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card card-stat success">
            <div class="card-body">
                <h6 class="text-muted">Employés actifs</h6>
                <h3><?= $activeEmployees ?></h3>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card card-stat warning">
            <div class="card-body">
                <h6 class="text-muted">Absences aujourd'hui</h6>
                <h3><?= $absencesCount ?></h3>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card card-stat info">
            <div class="card-body">
                <h6 class="text-muted">Départements</h6>
                <h3><?= $departmentsCount ?></h3>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Employés par département</h5>
            </div>
            <div class="card-body">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Département</th>
                            <th class="text-end">Nombre</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($employeesByDept as $row): ?>
                        <tr>
                            <td><?= htmlspecialchars($row['name']) ?></td>
                            <td class="text-end"><?= $row['count'] ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Absents aujourd'hui</h5>
            </div>
            <div class="card-body">
                <?php if (empty($absentEmployees)): ?>
                    <p class="text-muted mb-0">Aucune absence enregistrée pour aujourd'hui.</p>
                <?php else: ?>
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Nom</th>
                                <th>Département</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($absentEmployees as $emp): ?>
                            <tr>
                                <td><?= htmlspecialchars($emp['name']) ?></td>
                                <td><?= htmlspecialchars($emp['department_name']) ?></td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
