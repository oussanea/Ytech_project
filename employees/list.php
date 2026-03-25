<?php
/**
 * Liste des employés par département
 * HR Management System
 */

$pageTitle = 'Employés';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/header.php';

$department = $_GET['department'] ?? '';

if (empty($department)) {
    header('Location: index.php');
    exit;
}

// Récupérer l'ID du département
$stmt = $pdo->prepare("SELECT id FROM departments WHERE name = ?");
$stmt->execute([$department]);
$dept = $stmt->fetch();

if (!$dept) {
    echo '<div class="alert alert-warning">Département introuvable.</div>';
    require_once __DIR__ . '/../includes/footer.php';
    exit;
}

$departmentId = $dept['id'];

// Liste des employés
$employees = $pdo->query("SELECT * FROM employees WHERE department_id = $departmentId ORDER BY name")->fetchAll();

// Absences aujourd'hui
$today = date('Y-m-d');

$stmt = $pdo->prepare("SELECT employee_id FROM absences WHERE date = ?");
$stmt->execute([$today]);
$absentToday = $stmt->fetchAll(PDO::FETCH_COLUMN);

$canAdd = canAddEmployee();
$canEdit = canEditEmployee();
$canDelete = canDeleteEmployee();
$canManageAbsences = canManageAbsences();
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <a href="index.php" class="btn btn-outline-secondary btn-sm mb-2">
            <i class="bi bi-arrow-left"></i> Retour
        </a>
        <h4>Employés - <?= htmlspecialchars($department) ?></h4>
    </div>

    <?php if ($canAdd): ?>
    <a href="create.php?department=<?= urlencode($department) ?>" class="btn btn-primary">
        <i class="bi bi-plus"></i> Ajouter employé
    </a>
    <?php endif; ?>
</div>

<?php if (empty($employees)): ?>

<div class="alert alert-info">
Aucun employé dans ce département.
</div>

<?php else: ?>

<div class="card">
<div class="card-body">

<form method="POST" action="../absences/mark.php">

<table class="table table-hover">

<thead>
<tr>

<?php if ($canManageAbsences): ?>
<th></th>
<?php endif; ?>

<th>Nom</th>
<th>Poste</th>
<th>Téléphone</th>
<th>Salaire</th>
<th>Statut</th>

<?php if ($canEdit || $canDelete): ?>
<th class="text-end">Actions</th>
<?php endif; ?>

</tr>
</thead>

<tbody>

<?php foreach ($employees as $emp): ?>

<?php
$isAbsent = in_array($emp['id'], $absentToday);
?>

<tr class="<?= $isAbsent ? 'table-danger' : '' ?>">

<?php if ($canManageAbsences): ?>
<td>
<input 
type="checkbox"
name="employee_ids[]"
value="<?= $emp['id'] ?>"
<?= $isAbsent ? 'disabled' : '' ?>
>
</td>
<?php endif; ?>

<td><?= htmlspecialchars($emp['name']) ?></td>

<td><?= htmlspecialchars($emp['position']) ?></td>

<td><?= htmlspecialchars($emp['phone']) ?></td>

<td><?= number_format($emp['salary'], 0, ',', ' ') ?> MAD</td>

<td>
<span class="badge bg-<?= $emp['status'] === 'active' ? 'success' : 'secondary' ?>">
<?= $emp['status'] === 'active' ? 'Actif' : 'Inactif' ?>
</span>
</td>

<?php if ($canEdit || $canDelete): ?>

<td class="text-end">

<?php if ($canEdit): ?>
<a href="edit.php?id=<?= $emp['id'] ?>" class="btn btn-sm btn-outline-primary">
Modifier
</a>
<?php endif; ?>

<?php if ($canDelete): ?>
<a href="delete.php?id=<?= $emp['id'] ?>&department=<?= urlencode($department) ?>"
class="btn btn-sm btn-outline-danger"
onclick="return confirm('Supprimer cet employé ?')">
Supprimer
</a>
<?php endif; ?>

<?php if ($isAbsent && $canManageAbsences): ?>
<a href="../absences/remove.php?id=<?= $emp['id'] ?>" 
class="btn btn-sm btn-warning">
Annuler absence
</a>
<?php endif; ?>

</td>

<?php endif; ?>

</tr>

<?php endforeach; ?>

</tbody>

</table>

<?php if ($canManageAbsences): ?>
<div class="mt-3">
<button type="submit" class="btn btn-warning">
Marquer absent
</button>
</div>
<?php endif; ?>

</form>

</div>
</div>

<?php endif; ?>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>