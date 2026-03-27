<?php
/**
 * Ajouter un employé
 * HR Management System
 */

$pageTitle = 'Ajouter un employé';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/auth.php';

if (!canAddEmployee()) {
    header('Location: index.php');
    exit;
}

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
    header('Location: index.php');
    exit;
}

$departmentId = $dept['id'];
$departments  = $pdo->query("SELECT * FROM departments ORDER BY name")->fetchAll();
$message      = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name     = trim($_POST['name'] ?? '');
    $deptId   = (int) ($_POST['department_id'] ?? $departmentId);
    $position = trim($_POST['position'] ?? '');
    $phone    = trim($_POST['phone'] ?? '');
    $salary   = $_POST['salary'] ?? '';
    $address  = trim($_POST['address'] ?? '');
    $status   = $_POST['status'] ?? 'active';

    // HR ne peut pas changer le département
    if (hasRole(ROLE_HR)) {
        $deptId = $departmentId;
    }

    if (!in_array($status, ['active', 'inactive'])) {
        $status = 'active';
    }

    $salaryVal = is_numeric($salary) ? (float) $salary : null;

    if (empty($name) || empty($position)) {
        $message = '<div class="alert alert-danger">Nom et poste sont requis.</div>';
    } else {
        $stmt = $pdo->prepare(
            "INSERT INTO employees (name, department_id, position, phone, salary, address, status)
             VALUES (?, ?, ?, ?, ?, ?, ?)"
        );
        $stmt->execute([$name, $deptId, $position, $phone, $salaryVal, $address, $status]);

        $deptStmt = $pdo->prepare("SELECT name FROM departments WHERE id = ?");
        $deptStmt->execute([$deptId]);
        $redirectDept = $deptStmt->fetch()['name'];

        header('Location: list.php?department=' . urlencode($redirectDept));
        exit;
    }
}

require_once __DIR__ . '/../includes/header.php';
?>

<div class="mb-4">
    <a href="list.php?department=<?= urlencode($department) ?>" class="btn btn-outline-secondary btn-sm">
        <i class="bi bi-arrow-left"></i> Retour
    </a>
</div>

<div class="card mx-auto" style="max-width: 600px;">
    <div class="card-header">
        <h5 class="mb-0">Nouvel employé — <?= htmlspecialchars($department) ?></h5>
    </div>
    <div class="card-body">
        <?= $message ?>
        <form method="POST">
            <div class="mb-3">
                <label class="form-label fw-semibold">Nom <span class="text-danger">*</span></label>
                <input type="text" name="name" class="form-control" required
                       value="<?= htmlspecialchars($_POST['name'] ?? '') ?>">
            </div>
            <div class="mb-3">
                <label class="form-label fw-semibold">Département</label>
                <select name="department_id" class="form-select" <?= hasRole(ROLE_HR) ? 'disabled' : '' ?>>
                    <?php foreach ($departments as $d): ?>
                    <option value="<?= $d['id'] ?>" <?= $d['id'] == $departmentId ? 'selected' : '' ?>>
                        <?= htmlspecialchars($d['name']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
                <?php if (hasRole(ROLE_HR)): ?>
                <input type="hidden" name="department_id" value="<?= $departmentId ?>">
                <?php endif; ?>
            </div>
            <div class="mb-3">
                <label class="form-label fw-semibold">Poste <span class="text-danger">*</span></label>
                <input type="text" name="position" class="form-control" required
                       value="<?= htmlspecialchars($_POST['position'] ?? '') ?>">
            </div>
            <div class="mb-3">
                <label class="form-label fw-semibold">Téléphone</label>
                <input type="text" name="phone" class="form-control"
                       value="<?= htmlspecialchars($_POST['phone'] ?? '') ?>">
            </div>
            <div class="mb-3">
                <label class="form-label fw-semibold">Salaire (MAD)</label>
                <input type="number" name="salary" class="form-control" min="0" step="0.01"
                       value="<?= htmlspecialchars($_POST['salary'] ?? '') ?>">
            </div>
            <div class="mb-3">
                <label class="form-label fw-semibold">Adresse</label>
                <textarea name="address" class="form-control" rows="2"><?= htmlspecialchars($_POST['address'] ?? '') ?></textarea>
            </div>
            <div class="mb-4">
                <label class="form-label fw-semibold">Statut</label>
                <select name="status" class="form-select">
                    <option value="active"   <?= ($_POST['status'] ?? '') === 'active'   ? 'selected' : '' ?>>Actif</option>
                    <option value="inactive" <?= ($_POST['status'] ?? '') === 'inactive' ? 'selected' : '' ?>>Inactif</option>
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
