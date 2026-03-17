<?php
/**
 * Configuration base de données - PDO
 * HR Management System - Connexion MySQL
 */

$host = 'localhost';
$dbname = 'hr_system';
$username = 'root';
$password = 'sara412005';

try {
    $pdo = new PDO(
        "mysql:host=$host;dbname=$dbname;charset=utf8mb4",
        $username,
        $password,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
        ]
    );
} catch (PDOException $e) {
    die("Erreur de connexion : " . $e->getMessage());
}
