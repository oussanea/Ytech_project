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
- **Ollama + llama3** — IA locale
- **SQLite** — Base de données locale
- **bcrypt** — Hashage des mots de passe

## Fonctionnalités
- 🔐 Authentification sécurisée (bcrypt + blocage 3 tentatives)
- 💬 Historique des conversations par utilisateur
- 📎 Upload de fichiers PDF/Word/TXT
- 🛡️ Rate limiting (10 messages/minute)
- ⏱️ Session timeout (30 minutes)
- 🔒 Logs de sécurité complets
- 🗑️ Soft delete des conversations

## Installation

### Prérequis
- Python 3.11+
- Ollama installé → https://ollama.com/download
- llama3 téléchargé → `ollama pull llama3`

### Installation
```bash
# Cloner le repo
git clone https://github.com/ytech-solutions/ytech-chatbot
cd ytech-chatbot

# Créer l'environnement virtuel
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac

# Installer les dépendances
pip install -r requirements.txt

# Lancer l'application
streamlit run app.py
```

## Structure du projet
```
ytech-chatbot/
├── app.py              # Interface Streamlit
├── chatbot_logic.py    # Logique Ollama
├── auth.py             # Authentification
├── history.py          # Historique conversations
├── security.py         # Logs + rate limiting
├── database.py         # SQLite
├── file_handler.py     # Upload fichiers
├── requirements.txt    # Dépendances
└── .gitignore
```

## Sécurité
- Mots de passe hashés avec **bcrypt**
- Blocage compte après **3 tentatives** échouées
- **Session timeout** 30 minutes d'inactivité
- **Rate limiting** 10 messages/minute
- **Sanitisation** des inputs utilisateur
- **Logs** de toutes les actions de sécurité
- Données stockées **localement** uniquement

## Déploiement Ubuntu Server
```bash
# Installer les dépendances système
sudo apt update
sudo apt install python3 python3-pip python3-venv

# Installer Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3

# Cloner et lancer
git clone https://github.com/ytech-solutions/ytech-chatbot
cd ytech-chatbot
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
streamlit run app.py --server.port 8501
```

## Membres
- Développement & Déploiement : Raja JARFANI
- Projet : Ytech Solutions — JobInTech Cybersécurité Casablanca

## Licence
Projet académique — JobInTech 2025
