<?php
/**
 * Liste des départements
 * HR Management System
 */

$pageTitle = 'Départements';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/header.php';

$departments = $pdo->query("
    SELECT d.*, COUNT(e.id) as employee_count 
    FROM departments d 
    LEFT JOIN employees e ON e.department_id = d.id AND e.status = 'active'
    GROUP BY d.id
")->fetchAll();
?>

<h4 class="mb-4">Départements</h4>

<div class="row">
    <?php foreach ($departments as $dept): ?>
    <div class="col-md-4 mb-3">
        <div class="card department-card">
            <div class="card-body">
                <h5 class="card-title"><?= htmlspecialchars($dept['name']) ?></h5>
                <p class="card-text text-muted"><?= htmlspecialchars($dept['description'] ?? '') ?></p>
                <p class="mb-0"><span class="badge bg-primary"><?= $dept['employee_count'] ?> employé(s)</span></p>
                <a href="<?= BASE_URL ?>/employees/list.php?department=<?= urlencode($dept['name']) ?>" class="btn btn-sm btn-outline-primary mt-2">
                    Voir les employés
                </a>
            </div>
        </div>
    </div>
    <?php endforeach; ?>
</div>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>
