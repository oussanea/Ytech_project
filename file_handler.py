import PyPDF2
import docx
import streamlit as st

def extract_text_from_file(uploaded_file):
    text = ""
    
    # PDF
    if uploaded_file.type == "application/pdf":
        reader = PyPDF2.PdfReader(uploaded_file)
        for page in reader.pages:
            text += page.extract_text()
    
    # Word
    elif uploaded_file.type == "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
        doc = docx.Document(uploaded_file)
        for para in doc.paragraphs:
            text += para.text + "\n"
    
    # TXT
    elif uploaded_file.type == "text/plain":
        text = uploaded_file.read().decode("utf-8")
    
    return text.strip()