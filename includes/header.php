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
    <div class="d-flex">
        <!-- Sidebar -->
        <nav class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <h5 class="text-white"><?= APP_NAME ?></h5>
            </div>
            <ul class="list-unstyled components">
                <li>
                    <a href="<?= BASE_URL ?>/dashboard.php"><i class="bi bi-speedometer2"></i> Tableau de bord</a>
                </li>
                <li>
                    <a href="<?= BASE_URL ?>/employees/index.php"><i class="bi bi-people"></i> Employés</a>
                </li>
                <!--
                <li>
                    <a href="<?= BASE_URL ?>/absences/mark.php"><i class="bi bi-calendar-x"></i> Absences</a>
                </li>
                -->
                
            </ul>
            <div class="sidebar-footer">
                <a href="<?= BASE_URL ?>/logout.php" class="text-danger"><i class="bi bi-box-arrow-right"></i> Déconnexion</a>
            </div>
        </nav>

        <!-- Main content area -->
        <div class="main-content">
            <!-- Top navbar -->
            <nav class="navbar navbar-expand-lg navbar-light bg-light top-navbar">
                <div class="container-fluid">
                    <button type="button" id="sidebarCollapse" class="btn btn-outline-secondary">
                        <i class="bi bi-list"></i>
                    </button>
                    <span class="navbar-brand mb-0 ms-3"><?= $pageTitle ?? APP_NAME ?></span>
                    <div class="ms-auto d-flex align-items-center">
                        <span class="me-3"><i class="bi bi-person-circle"></i> <?= htmlspecialchars($_SESSION['user_name'] ?? '') ?></span>
                        <span class="badge bg-secondary"><?= htmlspecialchars($_SESSION['user_role'] ?? '') ?></span>
                        <a href="<?= BASE_URL ?>/logout.php" class="btn btn-outline-danger btn-sm ms-2">Déconnexion</a>
                    </div>
                </div>
            </nav>

            <!-- Page content -->
            <div class="content-wrapper p-4">
