<?php
/**
 * Créer un utilisateur
 * HR Management System - IT Admin uniquement
 */

$pageTitle = 'Nouvel utilisateur';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/auth.php';

if (!hasRole(ROLE_IT_ADMIN)) {
    header('Location: ' . BASE_URL . '/dashboard.php');
    exit;
}

$errors  = [];
$success = '';
$data    = ['username' => '', 'full_name' => '', 'role' => 'HR'];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data['username']  = trim($_POST['username'] ?? '');
    $data['full_name'] = trim($_POST['full_name'] ?? '');
    $data['role']      = $_POST['role'] ?? 'HR';
    $password          = $_POST['password'] ?? '';
    $passwordConfirm   = $_POST['password_confirm'] ?? '';

    // Validation
    if (empty($data['username'])) {
        $errors[] = "Le nom d'utilisateur est requis.";
    } elseif (!preg_match('/^[a-zA-Z0-9_]{3,50}$/', $data['username'])) {
        $errors[] = "Le nom d'utilisateur doit contenir 3-50 caractères alphanumériques ou underscore.";
    }

    if (empty($data['full_name'])) {
        $errors[] = "Le nom complet est requis.";
    }

    if (empty($password)) {
        $errors[] = "Le mot de passe est requis.";
    } elseif (strlen($password) < 6) {
        $errors[] = "Le mot de passe doit contenir au moins 6 caractères.";
    }

    if ($password !== $passwordConfirm) {
        $errors[] = "Les mots de passe ne correspondent pas.";
    }

    if (!in_array($data['role'], ['CEO', 'HR', 'IT Admin'])) {
        $errors[] = "Rôle invalide.";
    }

    if (empty($errors)) {
        // Vérifier si le nom d'utilisateur existe déjà
        $stmt = $pdo->prepare("SELECT id FROM users WHERE username = ?");
        $stmt->execute([$data['username']]);
        if ($stmt->fetch()) {
            $errors[] = "Ce nom d'utilisateur est déjà utilisé.";
        }
    }

    if (empty($errors)) {
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        $stmt = $pdo->prepare(
            "INSERT INTO users (username, password, full_name, role) VALUES (?, ?, ?, ?)"
        );
        $stmt->execute([$data['username'], $hashedPassword, $data['full_name'], $data['role']]);

        header('Location: ' . BASE_URL . '/users/index.php?success=' . urlencode('Utilisateur créé avec succès.'));
        exit;
    }
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
        <h5 class="mb-0"><i class="bi bi-person-plus"></i> Nouvel utilisateur</h5>
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
                       value="<?= htmlspecialchars($data['username']) ?>"
                       placeholder="ex: john_doe" required autofocus>
                <div class="form-text">3-50 caractères, lettres, chiffres et underscore uniquement.</div>
            </div>

            <div class="mb-3">
                <label class="form-label fw-semibold">Nom complet <span class="text-danger">*</span></label>
                <input type="text" name="full_name" class="form-control"
                       value="<?= htmlspecialchars($data['full_name']) ?>"
                       placeholder="ex: John Doe" required>
            </div>

            <div class="mb-3">
                <label class="form-label fw-semibold">Rôle <span class="text-danger">*</span></label>
                <select name="role" class="form-select" required>
                    <option value="HR"       <?= $data['role'] === 'HR'       ? 'selected' : '' ?>>RH (HR)</option>
                    <option value="IT Admin" <?= $data['role'] === 'IT Admin' ? 'selected' : '' ?>>Administrateur IT</option>
                    <option value="CEO"      <?= $data['role'] === 'CEO'      ? 'selected' : '' ?>>Directeur Général (CEO)</option>
                </select>
            </div>

            <hr>

            <div class="mb-3">
                <label class="form-label fw-semibold">Mot de passe <span class="text-danger">*</span></label>
                <div class="input-group">
                    <input type="password" name="password" id="password" class="form-control"
                           placeholder="Min. 6 caractères" required>
                    <button type="button" class="btn btn-outline-secondary" id="togglePass">
                        <i class="bi bi-eye"></i>
                    </button>
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label fw-semibold">Confirmer le mot de passe <span class="text-danger">*</span></label>
                <div class="input-group">
                    <input type="password" name="password_confirm" id="password_confirm" class="form-control"
                           placeholder="Répétez le mot de passe" required>
                    <button type="button" class="btn btn-outline-secondary" id="togglePassConfirm">
                        <i class="bi bi-eye"></i>
                    </button>
                </div>
            </div>

            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-check-lg"></i> Créer l'utilisateur
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
