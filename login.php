<?php
/**
 * Page de connexion sécurisée
 * HR Management System
 */

require_once __DIR__ . '/config/app.php';
require_once __DIR__ . '/config/database.php';

// Rediriger si déjà connecté
if (isset($_SESSION['user_id'])) {
    header('Location: ' . BASE_URL . '/dashboard.php');
    exit;
}

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Nettoyage des entrées
    $username = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';

    if (empty($username) || empty($password)) {
        $error = 'Veuillez remplir tous les champs.';
    } else {

        try {

            // Prepared statement (protection SQL injection)
            $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
            $stmt->execute([$username]);

            $user = $stmt->fetch();

            // Vérification du mot de passe hashé
            if ($user && password_verify($password, $user['password'])) {

                // Sécurité session
                session_regenerate_id(true);

                $_SESSION['user_id'] = $user['id'];
                $_SESSION['user_name'] = $user['full_name'];
                $_SESSION['user_role'] = $user['role'];

                header('Location: ' . BASE_URL . '/dashboard.php');
                exit;

            } else {
                $error = 'Identifiants incorrects.';
            }

        } catch (PDOException $e) {
            $error = 'Erreur système. Veuillez réessayer.';
        }
    }
}
?>

<!DOCTYPE html>
<html lang="fr">

<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Connexion - <?= APP_NAME ?></title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
<style>
body {
    background: linear-gradient(160deg, #B39DDB 0%, #7E57C2 100%);
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
}

.login-card {
    max-width: 420px;
    width: 100%;
    border: none;
    border-radius: 20px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    background: #ffffff;
}

/* ── YTECH brand ── */
.brand-ytech {
    font-size: 1.1rem;
    font-weight: 700;
    letter-spacing: 0.45em;
    color: #B39DDB;
    font-family: 'Segoe UI', sans-serif;
    text-transform: uppercase;
    margin-bottom: 2px;
}

.brand-title {
    font-size: 2rem;
    font-weight: 700;
    letter-spacing: 0.25em;
    color: #9575CD;
    font-family: 'Segoe UI', sans-serif;
}

.brand-subtitle {
    font-size: 0.78rem;
    letter-spacing: 0.1em;
    color: #C0B4D8;
}

/* ── Form inputs ── */
.form-control {
    border-radius: 10px;
    border: 1.5px solid #E0D7F0;
    padding: 10px 14px;
    font-size: 0.92rem;
    transition: border-color 0.2s, box-shadow 0.2s;
}

.form-control:focus {
    border-color: #B39DDB;
    box-shadow: 0 0 0 3px rgba(179,157,219,0.2);
    outline: none;
}

.form-label {
    font-size: 0.88rem;
    color: #6B5E82;
    font-weight: 500;
}

/* ── Password wrapper ── */
.pw-wrapper {
    position: relative;
}

.pw-wrapper .form-control {
    padding-right: 42px;
}

.pw-toggle {
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    color: #B39DDB;
    cursor: pointer;
    font-size: 1rem;
    padding: 0;
}

/* ── Submit button ── */
.btn-login {
    background: linear-gradient(160deg, #B39DDB 0%, #9575CD 100%);
    color: #fff;
    border: none;
    border-radius: 10px;
    padding: 12px;
    font-size: 0.95rem;
    font-weight: 500;
    width: 100%;
    transition: opacity 0.2s, box-shadow 0.2s;
    letter-spacing: 0.03em;
}

.btn-login:hover {
    opacity: 0.92;
    box-shadow: 0 6px 16px rgba(149,117,205,0.4);
    color: #fff;
}

/* ── Section title ── */
.section-title {
    font-size: 1.25rem;
    font-weight: 700;
    color: #3d2e5e;
}
</style>
</head>
<body>

<div class="login-card card">
    <div class="card-body p-4 p-sm-5">

        <!-- Brand -->
        <div class="text-center mb-4">
            <div class="brand-ytech">YTECH</div>
            <div class="brand-title"><?= APP_NAME ?></div>
            <div class="brand-subtitle">Solutions Numériques</div>
        </div>

        <hr class="my-3" style="border-color:#EDE7F6;">

        <!-- Title -->
        <h5 class="section-title mb-3">🔑 Connexion</h5>

        <!-- Error -->
        <?php if ($error): ?>
        <div class="alert alert-danger py-2 small">
            <?= htmlspecialchars($error) ?>
        </div>
        <?php endif; ?>

        <!-- Form -->
        <form method="POST" action="">

            <div class="mb-3">
                <label class="form-label">👤 Nom d'utilisateur :</label>
                <input
                    type="text"
                    name="username"
                    class="form-control"
                    placeholder="Entrez votre nom d'utilisateur"
                    required
                    autofocus
                    value="<?= htmlspecialchars($_POST['username'] ?? '') ?>">
            </div>

            <div class="mb-4">
                <label class="form-label">🔒 Mot de passe :</label>
                <div class="pw-wrapper">
                    <input
                        type="password"
                        name="password"
                        id="passwordInput"
                        class="form-control"
                        placeholder="Entrez votre mot de passe"
                        required>
                    <button type="button" class="pw-toggle" onclick="togglePw()">
                        <i class="bi bi-eye" id="pwIcon"></i>
                    </button>
                </div>
            </div>

            <button type="submit" class="btn-login">
                Se connecter
            </button>

        </form>

    </div>
</div>

<script>
function togglePw() {
    const input = document.getElementById('passwordInput');
    const icon  = document.getElementById('pwIcon');
    if (input.type === 'password') {
        input.type = 'text';
        icon.className = 'bi bi-eye-slash';
    } else {
        input.type = 'password';
        icon.className = 'bi bi-eye';
    }
}
</script>
</body>
</html>
