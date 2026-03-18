from database import get_connection
from datetime import datetime

def create_conversation(user_email, first_message):
    conn = get_connection()
    if not conn:
        return None
    cursor = conn.cursor()
    
    # Titre = date + première question (tronquée à 50 chars)
    date = datetime.now().strftime("%d/%m %H:%M")
    title = f"{date} - {first_message[:50]}..."
    
    cursor.execute("""
        INSERT INTO conversations (user_email, title)
        VALUES (%s, %s)
    """, (user_email, title))
    
    conn.commit()
    conv_id = cursor.lastrowid
    cursor.close()
    conn.close()
    return conv_id

def get_conversations(user_email):
    conn = get_connection()
    if not conn:
        return []
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT * FROM conversations 
        WHERE user_email = %s AND deleted = 0
        ORDER BY created_at DESC
    """, (user_email,))
    
    conversations = cursor.fetchall()
    cursor.close()
    conn.close()
    return conversations

def delete_conversation(conv_id):
    conn = get_connection()
    if not conn:
        return
    cursor = conn.cursor()
    
    # Soft delete → deleted = 1
    cursor.execute("""
        UPDATE conversations 
        SET deleted = 1 
        WHERE id = %s
    """, (conv_id,))
    
    conn.commit()
    cursor.close()
    conn.close()

def add_message(conv_id, role, content):
    conn = get_connection()
    if not conn:
        return
    cursor = conn.cursor()
    
    cursor.execute("""
        INSERT INTO messages (conversation_id, role, content)
        VALUES (%s, %s, %s)
    """, (conv_id, role, content))
    
    conn.commit()
    cursor.close()
    conn.close()

def get_messages(conv_id):
    conn = get_connection()
    if not conn:
        return []
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT * FROM messages 
        WHERE conversation_id = %s
        ORDER BY created_at ASC
    """, (conv_id,))
    
    messages = cursor.fetchall()
    cursor.close()
    conn.close()
    return messages