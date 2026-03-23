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
- 🔒 HTTPS avec certificat SSL

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

### Méthode 2 — Docker développement (tout en un)

**Prérequis :**
- Docker Desktop → https://www.docker.com/products/docker-desktop/
```bash
# Cloner le repo
git clone https://github.com/oussanea/Ytech_project.git
cd Ytech_project
git checkout feature/chatbot-ollama

# Lancer tous les conteneurs
docker-compose up -d

# Télécharger le modèle IA
docker exec -it ytech-ollama ollama pull llama3.2:1b
```

**Accès :**
```
http://localhost:8501
```

### Méthode 3 — Docker production (2 serveurs séparés)

**Sur VM1 — Serveur Chatbot + Ollama (VLAN 20) :**
```bash
git clone https://github.com/oussanea/Ytech_project.git
cd Ytech_project
git checkout feature/chatbot-ollama

# Générer certificat HTTPS
sudo mkdir -p /etc/ssl/ytech
sudo openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/ytech/ytech.key \
  -out /etc/ssl/ytech/ytech.crt \
  -subj "/C=MA/ST=Casablanca/O=Ytech Solutions/CN=IP_VM1"

# Lancer chatbot + ollama
docker-compose -f docker-compose.prod.yml up -d

# Télécharger le modèle
docker exec -it ytech-ollama ollama pull llama3.2:1b
```

**Sur VM2 — Serveur MariaDB (VLAN 25) :**
```bash
git clone https://github.com/oussanea/Ytech_project.git
cd Ytech_project
git checkout feature/chatbot-ollama

# Lancer MariaDB
docker-compose -f docker-compose.db.yml up -d

# Autoriser VM1
docker exec -it ytech-mariadb mariadb -u root -pRootPass123!
GRANT ALL ON ytech_chatbot.* TO 'chatbot'@'IP_VM1' IDENTIFIED BY 'ChatbotPass123!';
FLUSH PRIVILEGES;
EXIT;
```

**Accès HTTPS :**
```
https://IP_VM1:8501
```

## Architecture de déploiement
```
VM1 — Serveur Chatbot (VLAN 20)
└── Docker
    ├── Ollama (port 11434)
    └── YtechBot Streamlit (port 8501 HTTPS)
        └── → MariaDB VM2

VM2 — Serveur MariaDB (VLAN 25)
└── Docker
    └── MariaDB (port 3306)
        └── ytech_chatbot database
```

## Structure du projet
```
Ytech_project/
├── app.py                    # Interface Streamlit
├── chatbot_logic.py          # Logique Ollama
├── auth.py                   # Authentification
├── history.py                # Historique conversations
├── security.py               # Logs + rate limiting
├── database.py               # MariaDB
├── file_handler.py           # Upload fichiers
├── docker-compose.yml        # Docker dev (tout en un)
├── docker-compose.prod.yml   # Docker prod VM1
├── docker-compose.db.yml     # Docker prod VM2
├── Dockerfile                # Build chatbot
├── requirements.txt          # Dépendances
└── .gitignore
```

## Conteneurs Docker

| Conteneur | Rôle | Port | Serveur |
|---|---|---|---|
| ytech-ollama | IA locale | 11434 | VM1 |
| ytech-chatbot | Interface web HTTPS | 8501 | VM1 |
| ytech-mariadb | Base de données | 3306 | VM2 |

## Sécurité
- Mots de passe hashés avec **bcrypt**
- Blocage compte **15 minutes** après 3 tentatives
- **Session timeout** 30 minutes d'inactivité
- **Rate limiting** 10 messages/minute
- **Sanitisation** des inputs utilisateur
- **Logs** de toutes les actions de sécurité
- Données **100% locales** — ISO 27001
- **HTTPS** avec certificat SSL auto-signé
- BDD isolée sur serveur séparé — VLAN 25

## Note déploiement
Les IPs 192.168.56.x sont utilisées pour la simulation VirtualBox.
En production réelle sur GNS3 :
- VM1 Chatbot → 192.168.20.20
- VM2 MariaDB → 192.168.25.10

## Membres
- Développement & Déploiement : Raja JARFANI
- Projet : Ytech Solutions — JobInTech Cybersécurité Casablanca

## Licence
Projet académique — JobInTech 2025
