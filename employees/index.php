<?php
/**
 * Choisir un département pour voir les employés
 * HR Management System
 */

$pageTitle = 'Employés - Choisir un département';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/header.php';

$departments = $pdo->query("SELECT * FROM departments ORDER BY name")->fetchAll();
?>

<h4 class="mb-4">Choisir un département</h4>

<div class="row">
    <?php foreach ($departments as $dept): ?>
    <div class="col-md-4 mb-3">
        <a href="list.php?department=<?= urlencode($dept['name']) ?>" class="text-decoration-none">
            <div class="card department-card h-100">
                <div class="card-body">
                    <i class="bi bi-building display-6 text-primary"></i>
                    <h5 class="card-title mt-2"><?= htmlspecialchars($dept['name']) ?></h5>
                    <p class="card-text text-muted small"><?= htmlspecialchars($dept['description'] ?? '') ?></p>
                </div>
            </div>
        </a>
    </div>
    <?php endforeach; ?>
</div>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>
