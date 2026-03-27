<?php
/**
 * Gestion des utilisateurs - Liste
 * HR Management System - IT Admin uniquement
 */

$pageTitle = 'Utilisateurs';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/header.php';

if (!hasRole(ROLE_IT_ADMIN)) {
    header('Location: ' . BASE_URL . '/dashboard.php');
    exit;
}

$users = $pdo->query("SELECT id, username, full_name, role, created_at FROM users ORDER BY created_at DESC")->fetchAll();

$success = $_GET['success'] ?? '';
$error   = $_GET['error'] ?? '';
?>

<?php if ($success): ?>
<div class="alert alert-success alert-dismissible fade show" role="alert">
    <?= htmlspecialchars($success) ?>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<?php endif; ?>

<?php if ($error): ?>
<div class="alert alert-danger alert-dismissible fade show" role="alert">
    <?= htmlspecialchars($error) ?>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<?php endif; ?>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <h4 class="mb-0"><i class="bi bi-person-gear"></i> Gestion des utilisateurs</h4>
    <a href="<?= BASE_URL ?>/users/create.php" class="btn btn-primary">
        <i class="bi bi-person-plus"></i> Nouvel utilisateur
    </a>
</div>

<div class="card">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
                <thead class="table-dark">
                    <tr>
                        <th>#</th>
                        <th>Nom d'utilisateur</th>
                        <th>Nom complet</th>
                        <th>Rôle</th>
                        <th>Créé le</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($users as $user): ?>
                    <tr>
                        <td><?= $user['id'] ?></td>
                        <td><code><?= htmlspecialchars($user['username']) ?></code></td>
                        <td><?= htmlspecialchars($user['full_name']) ?></td>
                        <td>
                            <?php
                            $badgeClass = match($user['role']) {
                                'CEO'      => 'bg-danger',
                                'IT Admin' => 'bg-dark',
                                'HR'       => 'bg-primary',
                                default    => 'bg-secondary'
                            };
                            ?>
                            <span class="badge <?= $badgeClass ?>"><?= htmlspecialchars($user['role']) ?></span>
                        </td>
                        <td><?= date('d/m/Y', strtotime($user['created_at'])) ?></td>
                        <td class="text-end">
                            <a href="<?= BASE_URL ?>/users/edit.php?id=<?= $user['id'] ?>"
                               class="btn btn-sm btn-outline-primary me-1">
                                <i class="bi bi-pencil"></i>
                            </a>
                            <?php if ($user['id'] != $_SESSION['user_id']): ?>
                            <a href="<?= BASE_URL ?>/users/delete.php?id=<?= $user['id'] ?>"
                               class="btn btn-sm btn-outline-danger"
                               onclick="return confirm('Supprimer cet utilisateur ?')">
                                <i class="bi bi-trash"></i>
                            </a>
                            <?php else: ?>
                            <button class="btn btn-sm btn-outline-danger" disabled title="Impossible de se supprimer soi-même">
                                <i class="bi bi-trash"></i>
                            </button>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>

                    <?php if (empty($users)): ?>
                    <tr>
                        <td colspan="6" class="text-center text-muted py-4">Aucun utilisateur trouvé.</td>
                    </tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>
