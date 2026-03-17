<?php
/**
 * Absences du jour (lien rapide)
 * HR Management System
 */

$pageTitle = 'Absences aujourd\'hui';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/header.php';

$today = date('Y-m-d');
$absentList = $pdo->prepare("
    SELECT e.name, d.name as department_name 
    FROM absences a 
    JOIN employees e ON e.id = a.employee_id 
    JOIN departments d ON d.id = e.department_id
    WHERE a.date = ?
    ORDER BY d.name, e.name
");
$absentList->execute([$today]);
$absentEmployees = $absentList->fetchAll();
?>

<h4 class="mb-4">Absences - <?= date('d/m/Y', strtotime($today)) ?></h4>

<?php if (empty($absentEmployees)): ?>
    <div class="alert alert-info">Aucune absence enregistrée pour aujourd'hui.</div>
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

<a href="mark.php" class="btn btn-primary">Marquer une absence</a>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>
