import mysql.connector
from mysql.connector import Error
import os
import threading

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', 3306)),
    'database': os.getenv('DB_NAME', 'ytech_chatbot'),
    'user': os.getenv('DB_USER', 'chatbot'),
    'password': os.getenv('DB_PASSWORD', 'ChatbotPass123!')
}

def get_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"❌ Erreur connexion DB : {e}")
        return None

_init_lock = threading.Lock()
_initialized = False

def init_db():
    global _initialized
    with _init_lock:
        if _initialized:
            return
        
        conn = get_connection()
        if not conn:
            print("❌ Impossible de connecter à MariaDB !")
            return
        
        cursor = conn.cursor()
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                email VARCHAR(255) UNIQUE NOT NULL,
                password VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                is_blocked INT DEFAULT 0,
                failed_attempts INT DEFAULT 0,
                blocked_until TIMESTAMP DEFAULT NULL
            )
        """)
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS conversations (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_email VARCHAR(255) NOT NULL,
                title VARCHAR(500) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                deleted INT DEFAULT 0
            )
        """)
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS messages (
                id INT AUTO_INCREMENT PRIMARY KEY,
                conversation_id INT NOT NULL,
                role VARCHAR(50) NOT NULL,
                content TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (conversation_id) REFERENCES conversations(id)
            )
        """)
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS security_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                email VARCHAR(255),
                action VARCHAR(100) NOT NULL,
                ip_address VARCHAR(50),
                status VARCHAR(50) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        conn.commit()
        cursor.close()
        conn.close()
        _initialized = True
        print("✅ Base de données MariaDB initialisée !")

if __name__ == "__main__":
    init_db()