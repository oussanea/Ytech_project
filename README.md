# 🏢 HR Management System

A web-based Human Resources management application built with PHP, MySQL, and Apache — containerized with Docker and served over HTTPS with a self-signed SSL certificate.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [User Roles & Permissions](#user-roles--permissions)
- [Getting Started](#getting-started)
- [Deployment with Docker](#deployment-with-docker)
- [SSL Certificate](#ssl-certificate)
- [Database](#database)
- [Screenshots](#screenshots)

---

## Overview

This system allows a company to manage its employees, departments, absences, and system users through a role-based web interface. Access is restricted based on the user's role (CEO, HR, IT Admin).

---

## Features

- 🔐 Secure login with hashed passwords (`password_hash` / `password_verify`)
- 👥 Employee management (add, edit, delete) per department
- 🏬 Department overview with employee counts
- 📅 Absence tracking per employee per day
- 📊 Dashboard with live statistics
- 👤 User management (IT Admin only) — create, edit, delete system users
- 📱 Fully responsive — works on mobile, tablet, and desktop
- 🔒 HTTPS with self-signed SSL certificate
- 🐳 Dockerized — easy to deploy anywhere

---

## Tech Stack

| Layer       | Technology          |
|-------------|---------------------|
| Backend     | PHP 8.1             |
| Database    | MySQL 8.0           |
| Frontend    | Bootstrap 5.3       |
| Icons       | Bootstrap Icons     |
| Web Server  | Apache 2.4          |
| Container   | Docker + Docker Compose |
| SSL         | OpenSSL (self-signed) |

---

## Project Structure

```
hr-app/
├── absences/
│   ├── mark.php          # Mark employee absences
│   └── remove.php        # Remove an absence
├── assets/
│   ├── css/style.css     # Custom styles + mobile responsive
│   └── js/app.js         # Sidebar toggle, mobile behavior
├── config/
│   ├── app.php           # App constants, session start, roles
│   ├── database.php      # PDO MySQL connection (mounted via Docker volume)
│   └── hr_system.sql     # Database schema
├── docker/
│   └── ssl.conf          # Apache SSL virtual host config
├── employees/
│   ├── index.php         # Choose department
│   ├── list.php          # List employees in a department
│   ├── create.php        # Add new employee
│   ├── edit.php          # Edit employee
│   └── delete.php        # Delete employee (IT Admin only)
├── includes/
│   ├── auth.php          # Authentication & role functions
│   ├── header.php        # Sidebar, navbar, HTML head
│   └── footer.php        # Scripts, closing tags
├── users/
│   ├── index.php         # List system users (IT Admin only)
│   ├── create.php        # Create new user
│   ├── edit.php          # Edit user / change password
│   └── delete.php        # Delete user
├── dashboard.php         # Main dashboard with stats
├── login.php             # Login page
├── logout.php            # Destroys session and redirects
├── index.php             # Entry point — redirects to dashboard or login
├── Dockerfile            # PHP 8.1 + Apache + SSL + extensions
└── docker-compose.yml    # Container config with ports 80 & 443
```

---

## User Roles & Permissions

| Permission                  | CEO | HR  | IT Admin |
|-----------------------------|:---:|:---:|:--------:|
| View dashboard              | ✅  | ✅  | ✅       |
| View employees              | ✅  | ✅  | ✅       |
| Add employee                | ❌  | ✅  | ✅       |
| Edit employee (basic)       | ❌  | ✅  | ✅       |
| Edit employee (all fields)  | ❌  | ❌  | ✅       |
| Delete employee             | ❌  | ❌  | ✅       |
| Mark / remove absences      | ❌  | ✅  | ✅       |
| Manage system users         | ❌  | ❌  | ✅       |

---

## Getting Started

### Prerequisites

- Docker & Docker Compose installed on the server
- MySQL server accessible on the network
- A Linux server (tested on Ubuntu 24.04)

### 1. Clone the repository

```bash
git clone https://github.com/your-username/hr-app.git
cd hr-app
```

### 2. Configure the database connection

```bash
cp config/database.example.php config/database.php
```

Edit `config/database.php` and set your MySQL credentials:

```php
$host     = 'YOUR_DB_SERVER_IP';
$dbname   = 'hr_system';
$username = 'your_db_user';
$password = 'your_db_password';
```

### 3. Import the database schema

On your MySQL server:

```sql
CREATE DATABASE hr_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Then import:

```bash
mysql -u your_user -p -h YOUR_DB_IP hr_system < config/hr_system.sql
```

---

## Deployment with Docker

```bash
# Build and start the container
docker-compose up -d --build

# Check container status
docker ps

# View logs
docker logs hr-container

# Stop the container
docker-compose down
```

The app will be available at:
- HTTP:  `http://YOUR_SERVER_IP/hr-app/`
- HTTPS: `https://YOUR_SERVER_IP/hr-app/`

> ⚠️ Since this uses a self-signed certificate, your browser will show a security warning. Click **Advanced → Proceed** to continue. This is normal for internal/dev environments.

---

## SSL Certificate

The SSL certificate is automatically generated during the Docker build using OpenSSL:

```
Country:      MA (Morocco)
State:        Casablanca-Settat
City:         Casablanca
Organization: HR System
CN:           192.168.56.10
Validity:     365 days
```

To regenerate with a different IP or domain, update the `-subj` line in the `Dockerfile`:

```dockerfile
-subj "/C=MA/ST=Casablanca-Settat/L=Casablanca/O=HR System/OU=IT/CN=YOUR_IP_OR_DOMAIN"
```

Then rebuild:

```bash
docker-compose down
docker-compose up -d --build
```

---

## Database

The database runs on a **separate MySQL server** (not inside Docker). The connection is configured in `config/database.php` which is injected into the container via a Docker volume — meaning you never need to rebuild the image just to change DB credentials.

### Tables

| Table       | Description                        |
|-------------|------------------------------------|
| `users`     | System login accounts with roles   |
| `employees` | Employee records per department    |
| `departments` | Department list                  |
| `absences`  | Daily absence records per employee |

### Default users (from initial SQL)

| Username | Password   | Role     |
|----------|------------|----------|
| CEO      | (hashed)   | CEO      |
| HR       | (hashed)   | HR       |
| IT       | (hashed)   | IT Admin |

> Passwords are stored as bcrypt hashes. Use the **Users** page (IT Admin) to create or reset accounts.

---

## Security Notes

- All database queries use **PDO prepared statements** (no SQL injection)
- Passwords are hashed with `password_hash()` using bcrypt
- Sessions are regenerated on login (`session_regenerate_id`)
- Role-based access control on every protected page
- `config/database.php` is excluded from the Docker image via volume mount — keep it out of version control

---

## .gitignore recommendation

```
config/database.php
config/app.php
*.sql
*.log
```

---

## Author

Built and maintained by the IT team.  
For issues or feature requests, open a GitHub issue or contact the IT Admin.
