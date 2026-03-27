<?php
/**
 * Modifier un employé
 * HR Management System - Restrictions selon rôle (HR vs IT Admin)
 */

$pageTitle = 'Modifier un employé';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/header.php';

if (!canEditEmployee()) {
    header('Location: index.php');
    exit;
}

$id = (int) ($_GET['id'] ?? 0);
if (!$id) {
    header('Location: index.php');
    exit;
}

$stmt = $pdo->prepare("SELECT * FROM employees WHERE id = ?");
$stmt->execute([$id]);
$employee = $stmt->fetch();

if (!$employee) {
    header('Location: index.php');
    exit;
}

$departments = $pdo->query("SELECT * FROM departments ORDER BY name")->fetchAll();
$canEditAll  = canEditAllFields();
$message     = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if ($canEditAll) {
        $name         = trim($_POST['name'] ?? $employee['name']);
        $departmentId = (int) ($_POST['department_id'] ?? $employee['department_id']);
        $position     = trim($_POST['position'] ?? $employee['position']);
    } else {
        $name         = $employee['name'];
        $departmentId = $employee['department_id'];
        $position     = $employee['position'];
    }

    $phone   = trim($_POST['phone']   ?? $employee['phone']);
    $salary  = $_POST['salary']  ?? $employee['salary'];
    $address = trim($_POST['address'] ?? $employee['address']);
    $status  = $_POST['status']  ?? $employee['status'];

    if (!in_array($status, ['active', 'inactive'])) {
        $status = 'active';
    }

    $salaryVal = is_numeric($salary) ? (float) $salary : 0;

    $stmt = $pdo->prepare(
        "UPDATE employees SET
            name = ?,
            department_id = ?,
            position = ?,
            phone = ?,
            salary = ?,
            address = ?,
            status = ?
         WHERE id = ?"
    );
    $stmt->execute([$name, $departmentId, $position, $phone, $salaryVal, $address, $status, $id]);

    $deptStmt = $pdo->prepare("SELECT name FROM departments WHERE id = ?");
    $deptStmt->execute([$departmentId]);
    $deptName = $deptStmt->fetch()['name'];

    header('Location: list.php?department=' . urlencode($deptName));
    exit;
}

$deptStmt = $pdo->prepare("SELECT name FROM departments WHERE id = ?");
$deptStmt->execute([$employee['department_id']]);
$dept       = $deptStmt->fetch();
$department = $dept['name'];
?>

<div class="mb-4">
    <a href="list.php?department=<?= urlencode($department) ?>" class="btn btn-outline-secondary btn-sm">
        <i class="bi bi-arrow-left"></i> Retour
    </a>
</div>

<div class="card mx-auto" style="max-width: 600px;">
    <div class="card-header">
        <h5 class="mb-0">Modifier l'employé</h5>
    </div>
    <div class="card-body">
        <?= $message ?>
        <form method="POST">
            <div class="mb-3">
                <label class="form-label fw-semibold">Nom</label>
                <input type="text" name="name" class="form-control"
                       value="<?= htmlspecialchars($employee['name']) ?>"
                       <?= !$canEditAll ? 'readonly' : '' ?>>
            </div>
            <div class="mb-3">
                <label class="form-label fw-semibold">Département</label>
                <select name="department_id" class="form-select" <?= !$canEditAll ? 'disabled' : '' ?>>
                    <?php foreach ($departments as $d): ?>
                    <option value="<?= $d['id'] ?>" <?= $d['id'] == $employee['department_id'] ? 'selected' : '' ?>>
                        <?= htmlspecialchars($d['name']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
                <?php if (!$canEditAll): ?>
                <input type="hidden" name="department_id" value="<?= $employee['department_id'] ?>">
                <?php endif; ?>
            </div>
            <div class="mb-3">
                <label class="form-label fw-semibold">Poste</label>
                <input type="text" name="position" class="form-control"
                       value="<?= htmlspecialchars($employee['position']) ?>"
                       <?= !$canEditAll ? 'readonly' : '' ?>>
            </div>
            <div class="mb-3">
                <label class="form-label fw-semibold">Téléphone</label>
                <input type="text" name="phone" class="form-control"
                       value="<?= htmlspecialchars($employee['phone']) ?>">
            </div>
            <div class="mb-3">
                <label class="form-label fw-semibold">Salaire (MAD)</label>
                <input type="number" name="salary" class="form-control" min="0" step="0.01"
                       value="<?= htmlspecialchars($employee['salary']) ?>">
            </div>
            <div class="mb-3">
                <label class="form-label fw-semibold">Adresse</label>
                <textarea name="address" class="form-control" rows="2"><?= htmlspecialchars($employee['address']) ?></textarea>
            </div>
            <div class="mb-4">
                <label class="form-label fw-semibold">Statut</label>
                <select name="status" class="form-select">
                    <option value="active"   <?= $employee['status'] === 'active'   ? 'selected' : '' ?>>Actif</option>
                    <option value="inactive" <?= $employee['status'] === 'inactive' ? 'selected' : '' ?>>Inactif</option>
                </select>
            </div>
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-check-lg"></i> Enregistrer
                </button>
                <a href="list.php?department=<?= urlencode($department) ?>" class="btn btn-outline-secondary">Annuler</a>
            </div>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>
