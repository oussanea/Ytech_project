from database import get_connection
from datetime import datetime, timedelta
import streamlit as st

# Limite de questions par minute
RATE_LIMIT = 10

def log_action(email, action, status, ip_address="localhost"):
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        INSERT INTO security_logs (email, action, ip_address, status)
        VALUES (?, ?, ?, ?)
    """, (email, action, ip_address, status))
    
    conn.commit()
    conn.close()

def check_rate_limit(email):
    conn = get_connection()
    cursor = conn.cursor()
    
    # Compter les messages dans la dernière minute
    one_minute_ago = datetime.now() - timedelta(minutes=1)
    
    cursor.execute("""
        SELECT COUNT(*) as count 
        FROM security_logs 
        WHERE email = ? 
        AND action = 'message'
        AND status = 'success'
        AND created_at > ?
    """, (email, one_minute_ago))
    
    result = cursor.fetchone()
    conn.close()
    
    if result['count'] >= RATE_LIMIT:
        return False, f"⚠️ Limite atteinte — max {RATE_LIMIT} messages/minute !"
    return True, "✅ OK"

def sanitize_input(text):
    # Supprimer les caractères dangereux
    dangerous = ["<", ">", "{", "}", "SELECT", "DROP", "INSERT", "DELETE"]
    for char in dangerous:
        text = text.replace(char, "")
    return text.strip()

def check_session_timeout():
    if 'last_activity' not in st.session_state:
        return False
    
    # Timeout après 30 minutes d'inactivité
    timeout = timedelta(minutes=30)
    last_activity = st.session_state.last_activity
    
    if datetime.now() - last_activity > timeout:
        return True
    return False

def update_activity():
    st.session_state.last_activity = datetime.now()

def get_security_logs(email):
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT * FROM security_logs 
        WHERE email = ?
        ORDER BY created_at DESC
        LIMIT 50
    """, (email,))
    
    logs = cursor.fetchall()
    conn.close()
    return logs