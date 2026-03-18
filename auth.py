import bcrypt
from datetime import datetime, timedelta
from database import get_connection, init_db

MAX_ATTEMPTS = 3
BLOCK_DURATION_MINUTES = 15

def hash_password(password):
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

def verify_password(password, hashed):
    return bcrypt.checkpw(password.encode(), hashed.encode())

def create_user(email, password):
    if not email or not password:
        return False, "❌ Email et mot de passe obligatoires !"
    
    conn = get_connection()
    if not conn:
        return False, "❌ Erreur connexion base de données !"
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO users (email, password)
            VALUES (%s, %s)
        """, (email, hash_password(password)))
        conn.commit()
        return True, "✅ Compte créé avec succès !"
    except Exception as e:
        return False, "❌ Email déjà utilisé !"
    finally:
        cursor.close()
        conn.close()

def login_user(email, password):
    if not email or not password:
        return False, "❌ Email et mot de passe obligatoires !"

    conn = get_connection()
    if not conn:
        return False, "❌ Erreur connexion base de données !"
    
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()
    
    if not user:
        cursor.close()
        conn.close()
        return False, "❌ Email ou mot de passe incorrect !"
    
    # Vérifier si bloqué temporairement
    if user['is_blocked']:
        blocked_until = user['blocked_until']
        
        if blocked_until:
            # Convertir en datetime si string
            if isinstance(blocked_until, str):
                try:
                    blocked_until = datetime.strptime(
                        blocked_until, '%Y-%m-%d %H:%M:%S.%f'
                    )
                except:
                    blocked_until = datetime.strptime(
                        blocked_until, '%Y-%m-%d %H:%M:%S'
                    )
            
            if datetime.now() > blocked_until:
                # Débloquer automatiquement ✅
                cursor.execute("""
                    UPDATE users SET
                        is_blocked = 0,
                        failed_attempts = 0,
                        blocked_until = NULL
                    WHERE email = %s
                """, (email,))
                conn.commit()
            else:
                # Encore bloqué → afficher temps restant
                seconds_left = (blocked_until - datetime.now()).seconds
                minutes_left = (seconds_left // 60) + 1
                cursor.close()
                conn.close()
                return False, f"🔒 Compte bloqué — réessayez dans {minutes_left} minute(s) !"
    
    # Vérifier le mot de passe
    if verify_password(password, user['password']):
        cursor.execute("""
            UPDATE users SET
                failed_attempts = 0,
                is_blocked = 0,
                blocked_until = NULL
            WHERE email = %s
        """, (email,))
        conn.commit()
        cursor.close()
        conn.close()
        return True, "✅ Connexion réussie !"
    else:
        new_attempts = user['failed_attempts'] + 1
        
        if new_attempts >= MAX_ATTEMPTS:
            # Bloquer 15 minutes
            blocked_until = datetime.now() + timedelta(
                minutes=BLOCK_DURATION_MINUTES
            )
            cursor.execute("""
                UPDATE users SET
                    failed_attempts = %s,
                    is_blocked = 1,
                    blocked_until = %s
                WHERE email = %s
            """, (new_attempts, blocked_until, email))
            conn.commit()
            cursor.close()
            conn.close()
            return False, f"🔒 Compte bloqué {BLOCK_DURATION_MINUTES} minutes — trop de tentatives !"
        else:
            cursor.execute("""
                UPDATE users SET failed_attempts = %s
                WHERE email = %s
            """, (new_attempts, email))
            conn.commit()
            cursor.close()
            conn.close()
            restantes = MAX_ATTEMPTS - new_attempts
            return False, f"❌ Mot de passe incorrect — {restantes} tentative(s) restante(s) !"

def get_user(email):
    conn = get_connection()
    if not conn:
        return None
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()
    return user