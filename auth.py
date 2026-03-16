import bcrypt
from datetime import datetime
from database import get_connection, init_db

MAX_ATTEMPTS = 3

def hash_password(password):
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

def verify_password(password, hashed):
    return bcrypt.checkpw(password.encode(), hashed.encode())

def create_user(email, password):
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO users (email, password)
            VALUES (?, ?)
        """, (email, hash_password(password)))
        conn.commit()
        return True, "✅ Compte créé avec succès !"
    except Exception as e:
        return False, "❌ Email déjà utilisé !"
    finally:
        conn.close()

def login_user(email, password):
    conn = get_connection()
    cursor = conn.cursor()
    
    # Vérifier si l'utilisateur existe
    cursor.execute("SELECT * FROM users WHERE email = ?", (email,))
    user = cursor.fetchone()
    
    if not user:
        conn.close()
        return False, "❌ Email ou mot de passe incorrect !"
    
    # Vérifier si bloqué
    if user['is_blocked']:
        conn.close()
        return False, "🔒 Compte bloqué — trop de tentatives échouées !"
    
    # Vérifier le mot de passe
    if verify_password(password, user['password']):
        # Reset tentatives échouées
        cursor.execute("""
            UPDATE users SET failed_attempts = 0 
            WHERE email = ?
        """, (email,))
        conn.commit()
        conn.close()
        return True, "✅ Connexion réussie !"
    else:
        # Incrémenter tentatives échouées
        new_attempts = user['failed_attempts'] + 1
        is_blocked = 1 if new_attempts >= MAX_ATTEMPTS else 0
        
        cursor.execute("""
            UPDATE users SET failed_attempts = ?, is_blocked = ?
            WHERE email = ?
        """, (new_attempts, is_blocked, email))