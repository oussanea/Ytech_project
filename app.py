import streamlit as st
from database import init_db
from auth import login_user, create_user
from history import (create_conversation, get_conversations, 
                     delete_conversation, add_message, get_messages)
from chatbot_logic import get_bot_response
from file_handler import extract_text_from_file
from security import check_session_timeout, update_activity, log_action

init_db()

st.set_page_config(
    page_title="YtechBot — Assistant IA Interne",
    page_icon="🔒",
    layout="wide"
)

st.markdown("""
    <style>
    /* Fond général */
    .stApp {
        background-color: #f8f9ff;
        color: #1e293b;
    }
    
    /* Sidebar */
    [data-testid="stSidebar"] {
        background-color: #ffffff;
        border-right: 2px solid #e2e8f0;
    }
    
    /* Titre Ytech */
    .ytech-logo {
        font-size: 28px;
        font-weight: 800;
        color: #B39DDB;
        letter-spacing: 3px;
        text-align: center;
        margin-bottom: 5px;
    }
    
    /* Badge sécurité */
    .security-badge {
        background-color: rgba(179,157,219,0.15);
        border: 1px solid rgba(179,157,219,0.4);
        color: #7c4dff;
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 12px;
        text-align: center;
        margin: 10px 0;
    }
    
    /* Messages utilisateur */
    .user-message {
        background-color: #B39DDB;
        color: white;
        padding: 12px 16px;
        border-radius: 18px 18px 4px 18px;
        margin: 8px 0;
        text-align: right;
        max-width: 80%;
        margin-left: auto;
    }
    
    /* Messages bot */
    .bot-message {
        background-color: #ffffff;
        color: #1e293b;
        padding: 12px 16px;
        border-radius: 18px 18px 18px 4px;
        margin: 8px 0;
        border-left: 4px solid #3b82f6;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        max-width: 80%;
    }
    
    /* Boutons principaux */
    .stButton button {
        background-color: #B39DDB !important;
        color: white !important;
        border: none !important;
        border-radius: 8px !important;
        font-weight: 600 !important;
        transition: all 0.2s !important;
    }
    
    .stButton button:hover {
        background-color: #9C7EC4 !important;
        transform: translateY(-1px) !important;
    }
    
    /* Input fields */
    .stTextInput input {
        border: 2px solid #e2e8f0 !important;
        border-radius: 8px !important;
        background-color: #ffffff !important;
    }
    
    .stTextInput input:focus {
        border-color: #B39DDB !important;
    }

    /* Chat input */
    [data-testid="stChatInput"] {
        border: 2px solid #B39DDB !important;
        border-radius: 12px !important;
    }

    /* Conversation buttons sidebar */
    [data-testid="stSidebar"] .stButton button {
        background-color: #f1f5f9 !important;
        color: #1e293b !important;
        text-align: left !important;
        border: 1px solid #e2e8f0 !important;
        font-weight: 400 !important;
    }

    [data-testid="stSidebar"] .stButton button:hover {
        background-color: #B39DDB !important;
        color: white !important;
    }

    /* Divider */
    hr {
        border-color: #e2e8f0 !important;
    }
    </style>
""", unsafe_allow_html=True)

def show_login():
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        st.markdown('<div class="ytech-logo">YTECH</div>', unsafe_allow_html=True)
        st.markdown('<div style="text-align:center;color:#64748b;font-size:14px;margin-bottom:10px;">Solutions Numériques</div>', unsafe_allow_html=True)
        st.markdown('<div class="security-badge">🛡️ Assistant IA 100% Local — Vos données restent chez Ytech</div>', unsafe_allow_html=True)
        st.markdown("---")

        col_a, col_b = st.columns(2)
        with col_a:
            if st.button("🔑 Se connecter", use_container_width=True):
                st.session_state.auth_mode = "login"
        with col_b:
            if st.button("✨ Créer un compte", use_container_width=True):
                st.session_state.auth_mode = "signup"

        st.markdown("")

        if st.session_state.get('auth_mode') == "signup":
            st.subheader("Créer un compte")
            email = st.text_input("📧 Email Ytech :")
            password = st.text_input("🔒 Mot de passe :", type="password")
            confirm = st.text_input("🔒 Confirmer mot de passe :", type="password")

            if st.button("Créer le compte", use_container_width=True):
                if password != confirm:
                    st.error("❌ Mots de passe différents !")
                elif len(password) < 8:
                    st.error("❌ Minimum 8 caractères !")
                else:
                    success, message = create_user(email, password)
                    if success:
                        st.success(message)
                        st.session_state.auth_mode = "login"
                    else:
                        st.error(message)
        else:
            st.subheader("Connexion")
            email = st.text_input("📧 Email :")
            password = st.text_input("🔒 Mot de passe :", type="password")

            if st.button("Se connecter", use_container_width=True):
                success, message = login_user(email, password)
                if success:
                    st.session_state.authenticated = True
                    st.session_state.email = email
                    st.session_state.current_conv_id = None
                    update_activity()
                    log_action(email, "login", "success")
                    st.rerun()
                else:
                    log_action(email, "login", "failed")
                    st.error(message)

def show_chat():
    email = st.session_state.email

    if check_session_timeout():
        st.session_state.authenticated = False
        st.warning("⏱️ Session expirée — reconnectez-vous !")
        st.rerun()

    update_activity()

    with st.sidebar:
        st.markdown('<div class="ytech-logo">YTECH</div>', unsafe_allow_html=True)
        st.markdown(f'<div style="text-align:center;color:#64748b;font-size:12px;">👤 {email}</div>', unsafe_allow_html=True)
        st.markdown('<div class="security-badge">🛡️ IA Locale Sécurisée</div>', unsafe_allow_html=True)
        st.markdown("---")

        if st.button("➕ Nouvelle conversation", use_container_width=True):
            st.session_state.current_conv_id = None
            st.rerun()

        st.markdown("### 💬 Conversations")

        conversations = get_conversations(email)

        if not conversations:
            st.info("Aucune conversation")
        else:
            for conv in conversations:
                col1, col2 = st.columns([4, 1])
                with col1:
                    if st.button(
                        conv['title'][:35] + "...",
                        key=f"conv_{conv['id']}",
                        use_container_width=True
                    ):
                        st.session_state.current_conv_id = conv['id']
                        st.rerun()
                with col2:
                    if st.button("🗑", key=f"del_{conv['id']}"):
                        delete_conversation(conv['id'])
                        if st.session_state.get('current_conv_id') == conv['id']:
                            st.session_state.current_conv_id = None
                        st.rerun()

        st.markdown("---")
        if st.button("🚪 Déconnexion", use_container_width=True):
            log_action(email, "logout", "success")
            st.session_state.authenticated = False
            st.session_state.email = None
            st.session_state.current_conv_id = None
            st.rerun()

    st.markdown('<div class="ytech-logo">YTECH</div>', unsafe_allow_html=True)
    st.markdown('<div style="text-align:center;color:#64748b;margin-bottom:20px;">🤖 Assistant IA Interne — 100% Local et Sécurisé</div>', unsafe_allow_html=True)
    st.markdown("---")
    # Zone upload fichier
    uploaded_file = st.file_uploader(
        "📎 Joindre un document",
        type=["pdf", "docx", "txt"],
        help="Uploadez un document pour poser des questions dessus")

    file_context = None
    if uploaded_file:
        file_context = extract_text_from_file(uploaded_file)
        st.success(f"✅ Document chargé — {uploaded_file.name}")


    current_conv_id = st.session_state.get('current_conv_id')

    if current_conv_id:
        messages = get_messages(current_conv_id)
        for msg in messages:
            if msg['role'] == 'user':
                st.markdown(
                    f'<div class="user-message">👤 {msg["content"]}</div>',
                    unsafe_allow_html=True
                )
            else:
                st.markdown(
                    f'<div class="bot-message">🤖 {msg["content"]}</div>',
                    unsafe_allow_html=True
                )
    else:
        col1, col2, col3 = st.columns([1, 2, 1])
        with col2:
            st.markdown("""
            <div style="text-align:center;padding:40px 0;">
                <div style="font-size:60px;">🤖</div>
                <h3 style="color:#B39DDB;">Bonjour ! Je suis YtechBot</h3>
                <p style="color:#64748b;">Comment puis-je vous aider aujourd'hui ?</p>
            </div>
            """, unsafe_allow_html=True)

            st.markdown("""
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:20px;">
                <div style="background:#ffffff;border:1px solid #e2e8f0;border-radius:10px;padding:15px;border-left:4px solid #B39DDB;">
                    <b>🔒 Sécurité</b><br><small style="color:#64748b;">Bonnes pratiques et conseils</small>
                </div>
                <div style="background:#ffffff;border:1px solid #e2e8f0;border-radius:10px;padding:15px;border-left:4px solid #3b82f6;">
                    <b>💼 Procédures</b><br><small style="color:#64748b;">Questions internes Ytech</small>
                </div>
                <div style="background:#ffffff;border:1px solid #e2e8f0;border-radius:10px;padding:15px;border-left:4px solid #B39DDB;">
                    <b>🛠️ Outils</b><br><small style="color:#64748b;">Aide sur les outils Ytech</small>
                </div>
                <div style="background:#ffffff;border:1px solid #e2e8f0;border-radius:10px;padding:15px;border-left:4px solid #3b82f6;">
                    <b>💡 Général</b><br><small style="color:#64748b;">Toute question professionnelle</small>
                </div>
            </div>
            """, unsafe_allow_html=True)

    user_input = st.chat_input("Posez votre question à YtechBot...")

    if user_input:
        if not current_conv_id:
            current_conv_id = create_conversation(email, user_input)
            st.session_state.current_conv_id = current_conv_id

        add_message(current_conv_id, "user", user_input)
        history = get_messages(current_conv_id)

        with st.spinner("🤖 YtechBot réfléchit..."):
            response = get_bot_response(user_input, email, history, file_context)

        add_message(current_conv_id, "assistant", response)
        st.rerun()

def main():
    if 'authenticated' not in st.session_state:
        st.session_state.authenticated = False
    if 'auth_mode' not in st.session_state:
        st.session_state.auth_mode = "login"

    if st.session_state.authenticated:
        show_chat()
    else:
        show_login()

if __name__ == "__main__":
    main()