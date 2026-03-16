import ollama
from security import sanitize_input, log_action, check_rate_limit

SYSTEM_PROMPT = """Tu es YtechBot, l'assistant IA interne de Ytech Solutions.
Tu aides les employés de Ytech avec leurs questions professionnelles.
Tu réponds en français par défaut.
Tu ne partages jamais d'informations confidentielles.
Tu es professionnel, concis et utile.
Rappelle toujours que tu es un assistant LOCAL et sécurisé."""

def get_bot_response(user_input, email, conversation_history=[], file_context=None):
    allowed, message = check_rate_limit(email)
    if not allowed:
        return message
    
    clean_input = sanitize_input(user_input)
    
    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    
    # Ajouter le contexte du fichier si présent
    if file_context:
        messages.append({
            "role": "system",
            "content": f"""L'employé a partagé un document. 
            Réponds aux questions basé sur ce contenu :
            
            {file_context[:3000]}"""
        })
    
    for msg in conversation_history:
        messages.append({
            "role": msg['role'],
            "content": msg['content']
        })
    
    messages.append({
        "role": "user",
        "content": clean_input
    })
    
    try:
        response = ollama.chat(
            model="llama3",
            messages=messages
        )
        bot_response = response['message']['content']
        log_action(email, "message", "success")
        return bot_response
    
    except Exception as e:
        log_action(email, "message", "error")
        return "❌ Erreur — Vérifiez qu'Ollama est bien lancé !"