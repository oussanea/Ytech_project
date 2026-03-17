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
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
min-height: 100vh;
display: flex;
align-items: center;
justify-content: center;
}

.login-card {
max-width: 400px;
box-shadow: 0 10px 40px rgba(0,0,0,0.2);
}
</style>

</head>

<body>

<div class="login-card card">
<div class="card-body p-5">

<div class="text-center mb-4">
<i class="bi bi-people-fill display-4 text-primary"></i>
<h3 class="mt-2"><?= APP_NAME ?></h3>
<p class="text-muted">Connectez-vous pour accéder</p>
</div>

<?php if ($error): ?>
<div class="alert alert-danger">
<?= htmlspecialchars($error) ?>
</div>
<?php endif; ?>

<form method="POST" action="">

<div class="mb-3">
<label class="form-label">Nom d'utilisateur</label>

<input
type="text"
name="username"
class="form-control"
required
autofocus
value="<?= htmlspecialchars($_POST['username'] ?? '') ?>">
</div>

<div class="mb-4">
<label class="form-label">Mot de passe</label>

<input
type="password"
name="password"
class="form-control"
required>
</div>

<button type="submit" class="btn btn-primary w-100">
Se connecter
</button>

</form>

</div>
</div>

</body>
</html>