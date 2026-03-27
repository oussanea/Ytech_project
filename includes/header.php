<?php
require_once __DIR__ . '/auth.php';
requireLogin();
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($pageTitle ?? APP_NAME) ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="<?= BASE_URL ?>/assets/css/style.css" rel="stylesheet">
</head>
<body>

    <!-- Mobile overlay (closes sidebar when tapping outside) -->
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <div class="d-flex">
        <!-- Sidebar -->
        <nav class="sidebar" id="sidebar">
            <div class="sidebar-header d-flex align-items-center justify-content-between">
                <h5 class="text-white mb-0"><?= APP_NAME ?></h5>
                <button class="btn btn-sm text-white d-md-none" id="sidebarClose">
                    <i class="bi bi-x-lg"></i>
                </button>
            </div>
            <ul class="list-unstyled components">
                <li>
                    <a href="<?= BASE_URL ?>/dashboard.php"
                       class="<?= basename($_SERVER['PHP_SELF']) === 'dashboard.php' ? 'active' : '' ?>">
                        <i class="bi bi-speedometer2"></i> Tableau de bord
                    </a>
                </li>
                <li>
                    <a href="<?= BASE_URL ?>/employees/index.php"
                       class="<?= strpos($_SERVER['REQUEST_URI'], '/employees/') !== false ? 'active' : '' ?>">
                        <i class="bi bi-people"></i> Employés
                    </a>
                </li>
                <?php if (hasRole(ROLE_IT_ADMIN)): ?>
                <li>
                    <a href="<?= BASE_URL ?>/users/index.php"
                       class="<?= strpos($_SERVER['REQUEST_URI'], '/users/') !== false ? 'active' : '' ?>">
                        <i class="bi bi-person-gear"></i> Utilisateurs
                    </a>
                </li>
                <?php endif; ?>
            </ul>
            <div class="sidebar-footer">
                <div class="sidebar-user-info mb-2">
                    <small class="text-white-50 d-block"><?= htmlspecialchars($_SESSION['user_name'] ?? '') ?></small>
                    <small class="badge bg-light text-dark"><?= htmlspecialchars($_SESSION['user_role'] ?? '') ?></small>
                </div>
                <a href="<?= BASE_URL ?>/logout.php" class="text-danger">
                    <i class="bi bi-box-arrow-right"></i> Déconnexion
                </a>
            </div>
        </nav>

        <!-- Main content area -->
        <div class="main-content" id="mainContent">
            <!-- Top navbar -->
            <nav class="navbar navbar-expand-lg navbar-light bg-white top-navbar">
                <div class="container-fluid">
                    <button type="button" id="sidebarCollapse" class="btn btn-outline-secondary">
                        <i class="bi bi-list"></i>
                    </button>
                    <span class="navbar-brand mb-0 ms-3 fw-semibold"><?= htmlspecialchars($pageTitle ?? APP_NAME) ?></span>
                    <div class="ms-auto d-flex align-items-center gap-2">
                        <span class="d-none d-sm-inline text-muted small">
                            <i class="bi bi-person-circle"></i> <?= htmlspecialchars($_SESSION['user_name'] ?? '') ?>
                        </span>
                        <span class="badge bg-secondary"><?= htmlspecialchars($_SESSION['user_role'] ?? '') ?></span>
                        <a href="<?= BASE_URL ?>/logout.php" class="btn btn-outline-danger btn-sm">
                            <i class="bi bi-box-arrow-right"></i>
                        </a>
                    </div>
                </div>
            </nav>

            <!-- Page content -->
            <div class="content-wrapper p-3 p-md-4">
