-- HR Management System - Database Schema
-- Projet: système RH pour cours cybersécurité
-- Base de données: MySQL/MariaDB
-- IMPORTANT: Schéma volontairement simple pour démonstration de vulnérabilités (SQLi, XSS)

-- Créer la base de données
CREATE DATABASE IF NOT EXISTS hr_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hr_system;

-- =============================================
-- Table: users (utilisateurs du système)
-- =============================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('CEO', 'HR', 'IT Admin') NOT NULL DEFAULT 'HR',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =============================================
-- Table: departments (départements)
-- =============================================
CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB;

-- =============================================
-- Table: employees (employés)
-- =============================================
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    position VARCHAR(100) NOT NULL,
    phone VARCHAR(30),
    salary DECIMAL(10, 2),
    address TEXT,
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =============================================
-- Table: absences
-- =============================================
CREATE TABLE absences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =============================================
-- Données initiales: départements
-- =============================================
INSERT INTO departments (name, description) VALUES
('Direction Générale', 'Pilotage stratégique'),
('Informatique (IT)', 'Administration systèmes et réseaux'),
('Développement', 'Développement et maintenance applicative'),
('Ressources Humaines', 'Gestion du personnel'),
('Finance / Comptabilité', 'Gestion financière et facturation'),
('Commercial & Marketing', 'Gestion clients et activités commerciales');

-- =============================================
-- Données initiales: utilisateurs de test
-- Mot de passe pour tous: "password123"
-- IMPORTANT: En production, utiliser password_hash()
-- =============================================
INSERT INTO users (username, password, full_name, role) VALUES
('ceo', 'password123', 'Jean CEO', 'CEO'),
('hr', 'password123', 'Marie HR', 'HR'),
('admin', 'password123', 'Pierre Admin', 'IT Admin');

-- =============================================
-- Données initiales: employés exemple
-- =============================================
INSERT INTO employees (name, department_id, position, phone, salary, address, status) VALUES
('Ahmed Benali', 1, 'Directeur Général', '0612345678', 15000, 'Casablanca', 'active'),
('Sara Idrissi', 2, 'Administrateur Systèmes', '0623456789', 12000, 'Rabat', 'active'),
('Youssef Alaoui', 3, 'Développeur Senior', '0634567890', 11000, 'Fès', 'active'),
('Fatima Bennani', 4, 'Responsable RH', '0645678901', 10000, 'Marrakech', 'active'),
('Karim Tazi', 5, 'Comptable', '0656789012', 9000, 'Tanger', 'active'),
('Laila Chakir', 6, 'Commerciale', '0667890123', 8500, 'Casablanca', 'active');
