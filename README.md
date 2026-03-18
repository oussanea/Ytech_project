# YtechBot — Assistant IA Interne 🤖

## Description
YtechBot est un chatbot IA **100% local** développé pour Ytech Solutions.
Il permet aux employés de poser des questions professionnelles sans risque
de fuite de données vers des services externes (ChatGPT, Gemini...).

## Pourquoi Ollama local ?
- ✅ Données restent 100% dans l'entreprise
- ✅ Conforme ISO 27001
- ✅ Conforme RGPD
- ✅ Zéro connexion internet nécessaire

## Technologies
- **Streamlit** — Interface web
- **Ollama + llama3.2** — IA locale
- **MariaDB** — Base de données
- **Docker** — Conteneurisation
- **bcrypt** — Hashage des mots de passe

## Fonctionnalités
- 🔐 Authentification sécurisée (bcrypt + blocage 15 min)
- 💬 Historique des conversations par utilisateur
- 📎 Upload de fichiers PDF/Word/TXT
- 🛡️ Rate limiting (10 messages/minute)
- ⏱️ Session timeout (30 minutes)
- 🔒 Logs de sécurité complets
- 🗑️ Soft delete des conversations
- 🐳 Déploiement Docker

## Installation

### Méthode 1 — Environnement virtuel (développement)

**Prérequis :**
- Python 3.11+
- Ollama installé → https://ollama.com/download
- llama3.2 téléchargé → `ollama pull llama3.2:1b`
```bash
# Cloner le repo
git clone https://github.com/oussanea/Ytech_project.git
cd Ytech_project

# Créer l'environnement virtuel
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac

# Installer les dépendances
pip install -r requirements.txt

# Lancer l'application
streamlit run app.py
```

### Méthode 2 — Docker (production)

**Prérequis :**
- Docker Desktop installé → https://www.docker.com/products/docker-desktop/
```bash
# Cloner le repo
git clone https://github.com/oussanea/Ytech_project.git
cd Ytech_project

# Lancer tous les conteneurs
docker-compose up -d

# Télécharger le modèle IA
docker exec -it ytech-ollama ollama pull llama3.2:1b
```

**Accès :**
```
http://localhost:8501
```

## Structure du projet
```
Ytech_project/
├── app.py              # Interface Streamlit
├── chatbot_logic.py    # Logique Ollama
├── auth.py             # Authentification
├── history.py          # Historique conversations
├── security.py         # Logs + rate limiting
├── database.py         # MariaDB
├── file_handler.py     # Upload fichiers
├── docker-compose.yml  # Docker config
├── Dockerfile          # Build chatbot
├── requirements.txt    # Dépendances
└── .gitignore
```

## Conteneurs Docker
| Conteneur | Rôle | Port |
|---|---|---|
| ytech-mariadb | Base de données | 3306 |
| ytech-ollama | IA locale | 11434 |
| ytech-chatbot | Interface web | 8501 |

## Sécurité
- Mots de passe hashés avec **bcrypt**
- Blocage compte **15 minutes** après 3 tentatives
- **Session timeout** 30 minutes d'inactivité
- **Rate limiting** 10 messages/minute
- **Sanitisation** des inputs utilisateur
- **Logs** de toutes les actions de sécurité
- Données **100% locales** — ISO 27001

## Déploiement Ubuntu Server
```bash
# Installer Docker
sudo apt update
sudo apt install docker.io docker-compose

# Cloner et lancer
git clone https://github.com/oussanea/Ytech_project.git
cd Ytech_project
docker-compose up -d
docker exec -it ytech-ollama ollama pull llama3.2:1b
```

## Membres
- Développement & Déploiement : Raja JARFANI
- Projet : Ytech Solutions — JobInTech Cybersécurité Casablanca

## Licence
Projet académique — JobInTech 2025