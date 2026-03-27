<?php
/**
 * Modifier un utilisateur
 * HR Management System - IT Admin uniquement
 */

$pageTitle = 'Modifier utilisateur';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/auth.php';

if (!hasRole(ROLE_IT_ADMIN)) {
    header('Location: ' . BASE_URL . '/dashboard.php');
    exit;
}

$id = (int) ($_GET['id'] ?? 0);
if (!$id) {
    header('Location: ' . BASE_URL . '/users/index.php');
    exit;
}

$stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
$stmt->execute([$id]);
$user = $stmt->fetch();

if (!$user) {
    header('Location: ' . BASE_URL . '/users/index.php?error=' . urlencode('Utilisateur introuvable.'));
    exit;
}

$errors = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username  = trim($_POST['username'] ?? '');
    $full_name = trim($_POST['full_name'] ?? '');
    $role      = $_POST['role'] ?? 'HR';
    $password  = $_POST['password'] ?? '';
    $passwordConfirm = $_POST['password_confirm'] ?? '';

    if (empty($username)) {
        $errors[] = "Le nom d'utilisateur est requis.";
    } elseif (!preg_match('/^[a-zA-Z0-9_]{3,50}$/', $username)) {
        $errors[] = "Le nom d'utilisateur doit contenir 3-50 caractères alphanumériques ou underscore.";
    }

    if (empty($full_name)) {
        $errors[] = "Le nom complet est requis.";
    }

    if (!in_array($role, ['CEO', 'HR', 'IT Admin'])) {
        $errors[] = "Rôle invalide.";
    }

    if (!empty($password)) {
        if (strlen($password) < 6) {
            $errors[] = "Le mot de passe doit contenir au moins 6 caractères.";
        }
        if ($password !== $passwordConfirm) {
            $errors[] = "Les mots de passe ne correspondent pas.";
        }
    }

    if (empty($errors)) {
        // Vérifier unicité username (sauf pour lui-même)
        $stmt2 = $pdo->prepare("SELECT id FROM users WHERE username = ? AND id != ?");
        $stmt2->execute([$username, $id]);
        if ($stmt2->fetch()) {
            $errors[] = "Ce nom d'utilisateur est déjà utilisé.";
        }
    }

    if (empty($errors)) {
        if (!empty($password)) {
            $hashed = password_hash($password, PASSWORD_DEFAULT);
            $stmt3  = $pdo->prepare("UPDATE users SET username=?, full_name=?, role=?, password=? WHERE id=?");
            $stmt3->execute([$username, $full_name, $role, $hashed, $id]);
        } else {
            $stmt3 = $pdo->prepare("UPDATE users SET username=?, full_name=?, role=? WHERE id=?");
            $stmt3->execute([$username, $full_name, $role, $id]);
        }

        header('Location: ' . BASE_URL . '/users/index.php?success=' . urlencode('Utilisateur mis à jour avec succès.'));
        exit;
    }

    // Keep posted values on error
    $user['username']  = $username;
    $user['full_name'] = $full_name;
    $user['role']      = $role;
}

require_once __DIR__ . '/../includes/header.php';
?>

<div class="mb-4">
    <a href="<?= BASE_URL ?>/users/index.php" class="btn btn-outline-secondary btn-sm">
        <i class="bi bi-arrow-left"></i> Retour
    </a>
</div>

<div class="card mx-auto" style="max-width: 560px;">
    <div class="card-header">
        <h5 class="mb-0"><i class="bi bi-pencil-square"></i> Modifier l'utilisateur</h5>
    </div>
    <div class="card-body">

        <?php if (!empty($errors)): ?>
        <div class="alert alert-danger">
            <ul class="mb-0 ps-3">
                <?php foreach ($errors as $e): ?>
                <li><?= htmlspecialchars($e) ?></li>
                <?php endforeach; ?>
            </ul>
        </div>
        <?php endif; ?>

        <form method="POST" autocomplete="off">

            <div class="mb-3">
                <label class="form-label fw-semibold">Nom d'utilisateur <span class="text-danger">*</span></label>
                <input type="text" name="username" class="form-control"
                       value="<?= htmlspecialchars($user['username']) ?>" required>
            </div>

            <div class="mb-3">
                <label class="form-label fw-semibold">Nom complet <span class="text-danger">*</span></label>
                <input type="text" name="full_name" class="form-control"
                       value="<?= htmlspecialchars($user['full_name']) ?>" required>
            </div>

            <div class="mb-3">
                <label class="form-label fw-semibold">Rôle <span class="text-danger">*</span></label>
                <select name="role" class="form-select" required
                    <?= $user['id'] == $_SESSION['user_id'] ? 'disabled' : '' ?>>
                    <option value="HR"       <?= $user['role'] === 'HR'       ? 'selected' : '' ?>>RH (HR)</option>
                    <option value="IT Admin" <?= $user['role'] === 'IT Admin' ? 'selected' : '' ?>>Administrateur IT</option>
                    <option value="CEO"      <?= $user['role'] === 'CEO'      ? 'selected' : '' ?>>Directeur Général (CEO)</option>
                </select>
                <?php if ($user['id'] == $_SESSION['user_id']): ?>
                <input type="hidden" name="role" value="<?= htmlspecialchars($user['role']) ?>">
                <div class="form-text text-warning"><i class="bi bi-info-circle"></i> Vous ne pouvez pas changer votre propre rôle.</div>
                <?php endif; ?>
            </div>

            <hr>
            <p class="text-muted small mb-3"><i class="bi bi-lock"></i> Laissez vide pour conserver le mot de passe actuel.</p>

            <div class="mb-3">
                <label class="form-label fw-semibold">Nouveau mot de passe</label>
                <div class="input-group">
                    <input type="password" name="password" id="password" class="form-control"
                           placeholder="Min. 6 caractères">
                    <button type="button" class="btn btn-outline-secondary" id="togglePass">
                        <i class="bi bi-eye"></i>
                    </button>
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label fw-semibold">Confirmer le nouveau mot de passe</label>
                <div class="input-group">
                    <input type="password" name="password_confirm" id="password_confirm" class="form-control"
                           placeholder="Répétez le mot de passe">
                    <button type="button" class="btn btn-outline-secondary" id="togglePassConfirm">
                        <i class="bi bi-eye"></i>
                    </button>
                </div>
            </div>

            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-check-lg"></i> Enregistrer
                </button>
                <a href="<?= BASE_URL ?>/users/index.php" class="btn btn-outline-secondary">Annuler</a>
            </div>

        </form>
    </div>
</div>

<script>
function toggleVisibility(inputId, btnId) {
    const input = document.getElementById(inputId);
    const btn   = document.getElementById(btnId);
    btn.addEventListener('click', function () {
        const isPass = input.type === 'password';
        input.type   = isPass ? 'text' : 'password';
        btn.innerHTML = isPass ? '<i class="bi bi-eye-slash"></i>' : '<i class="bi bi-eye"></i>';
    });
}
toggleVisibility('password', 'togglePass');
toggleVisibility('password_confirm', 'togglePassConfirm');
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>
