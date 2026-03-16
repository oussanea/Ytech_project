from database import get_connection
from datetime import datetime

def create_conversation(user_email, first_message):
    conn = get_connection()
    cursor = conn.cursor()
    
    # Titre = date + première question (tronquée à 50 chars)
    date = datetime.now().strftime("%d/%m %H:%M")
    title = f"{date} - {first_message[:50]}..."
    
    cursor.execute("""
        INSERT INTO conversations (user_email, title)
        VALUES (?, ?)
    """, (user_email, title))
    
    conn.commit()
    conv_id = cursor.lastrowid
    conn.close()
    return conv_id

def get_conversations(user_email):
    conn = get_connection()
    cursor = conn.cursor()
    
    # Récupérer toutes les conversations non supprimées
    cursor.execute("""
        SELECT * FROM conversations 
        WHERE user_email = ? AND deleted = 0
        ORDER BY created_at DESC
    """, (user_email,))
    
    conversations = cursor.fetchall()
    conn.close()
    return conversations

def delete_conversation(conv_id):
    conn = get_connection()
    cursor = conn.cursor()
    
    # Soft delete → deleted = 1
    cursor.execute("""
        UPDATE conversations 
        SET deleted = 1 
        WHERE id = ?
    """, (conv_id,))
    
    conn.commit()
    conn.close()

def add_message(conv_id, role, content):
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        INSERT INTO messages (conversation_id, role, content)
        VALUES (?, ?, ?)
    """, (conv_id, role, content))
    
    conn.commit()
    conn.close()

def get_messages(conv_id):
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT * FROM messages 
        WHERE conversation_id = ?
        ORDER BY created_at ASC
    """, (conv_id,))
    
    messages = cursor.fetchall()
    conn.close()
    return messages