
<?php
/**
 * Configuration base de données - PDO
 * HR Management System - Connexion MySQL
 * Copier ce fichier en database.php et remplir les vraies valeurs
 */

$host     = 'YOUR_DB_HOST';       // e.g. 192.168.x.x
$dbname   = 'YOUR_DB_NAME';       // e.g. hr_system
$username = 'YOUR_DB_USER';       // e.g. hruser
$password = 'YOUR_DB_PASSWORD';   // e.g. ********

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
