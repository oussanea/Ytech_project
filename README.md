# 🛡️ Hardening — Ytech Solutions

> Durcissement des systèmes de l'infrastructure Ytech Solutions  
> Réalisé dans le cadre du projet **JobInTech Cybersécurité — Casablanca 2026**

---

## 📋 Sommaire

- [Contexte](#contexte)
- [Machines concernées](#machines-concernées)
- [Windows — Postes employés](#-windows--postes-employés)
- [Kali Linux — Poste IT](#-kali-linux--poste-it)
- [Ubuntu Server — Serveurs](#-ubuntu-server--serveurs)
- [Résultats globaux](#-résultats-globaux)
- [Structure du dossier](#-structure-du-dossier)

---

## Contexte

Le hardening (durcissement) consiste à réduire la surface d'attaque de chaque machine en appliquant des mesures de sécurité adaptées à son rôle dans l'infrastructure.

Trois types de machines ont été durcis dans ce projet :

| Machine | Rôle | Outil d'audit |
|---|---|---|
| Windows 10/11 | Postes des employés | CIS-CAT / Script audit |
| Kali Linux | Poste de l'administrateur IT | Lynis |
| Ubuntu Server 22.04 | Serveurs de l'infrastructure | Lynis |

---

## Machines concernées

```
Infrastructure Ytech Solutions
│
├── 💻 Postes employés        → Windows 10     (hardening utilisateur)
├── 🖥️  Poste IT / Admin      → Kali Linux          (hardening administrateur)
└── 🗄️  Serveurs              → Ubuntu Server 22.04 (hardening serveurs)
```

---

## 🪟 Windows — Postes employés

### Objectif
Sécuriser les postes de travail des employés, qui sont la première cible des attaques (phishing, malware, accès non autorisé).

### Mesures appliquées
- ✅ Activation et vérification du pare-feu Windows
- ✅ Durcissement de Windows Defender — protection temps réel activée
- ✅ Désactivation des services non nécessaires (SMBv1, Telnet, RDP restreint)
- ✅ Politique de mots de passe renforcée
- ✅ UAC activé au niveau maximum
- ✅ Journalisation des événements de sécurité (Event Log)
- ✅ Mises à jour automatiques activées (Windows Update)

### Scripts
| Fichier | Description |
|---|---|
| `windows/hardening_windows10.ps1` | Script PowerShell de durcissement automatique |
| `windows/audit_windows10.ps1` | Script d'audit — génère un rapport avant/après |

### Résultats

| | Score |
|---|---|
| **Avant hardening** | 50 / 100 |
| **Après hardening** | 100 / 100 |
| **Amélioration** | +50 % ✅ |

### Captures
> 📷 

windows-audit-before-after.png

## 🐉 Kali Linux — Poste IT

### Objectif
Sécuriser la machine de l'administrateur IT. Si ce poste est compromis, toute l'infrastructure peut l'être — son durcissement est critique.

### Mesures appliquées
- ✅ Configuration du pare-feu UFW avec règles strictes
- ✅ Durcissement SSH : connexion root désactivée, authentification par clés uniquement
- ✅ Politique de mots de passe renforcée (PAM)
- ✅ Désactivation des services inutiles
- ✅ Auditd activé — suivi de toutes les commandes exécutées
- ✅ Fail2ban — protection contre le brute-force SSH

### Scripts
| Fichier | Description |
|---|---|
| `kali/hardening_kali_safe.sh` | Script Bash de durcissement du poste Kali |

### Résultats (Lynis)

| | Score |
|---|---|
| **Avant hardening** | 61 / 100 |
| **Après hardening** | 79 / 100 |
| **Amélioration** | 18 % ✅ |

### Captures
kaliavant.png
kaliapres.png
## 🐧 Ubuntu Server — Serveurs

### Objectif
Protéger les serveurs critiques de l'infrastructure (Web, Base de données, SIEM, Monitoring) hébergés sur Ubuntu Server 22.04 LTS.

### Mesures appliquées
- ✅ Mises à jour système automatiques (unattended-upgrades)
- ✅ Configuration UFW — pare-feu serveur
- ✅ Sécurisation SSH : port modifié, root désactivé, clés uniquement
- ✅ Séparation des privilèges et contrôle d'accès (least privilege)
- ✅ Journalisation centralisée vers Wazuh SIEM
- ✅ Audit avant / après avec Lynis

### Scripts
| Fichier | Description |
|---|---|
| `ubuntu/hardening_ubuntu.sh` | Script Bash de durcissement principal |
| `ubuntu/boost_score.sh` | Script de durcissement avancé (niveau supérieur) |

### Résultats (Lynis)

| | Score |
|---|---|
| **Avant hardening** | 64 / 100 |
| **Après hardening** | 87 / 100 |
| **Amélioration** | +23 % ✅ |

### Captures
ubuntuavant.png
ubuntuapres.png
---

## 📊 Résultats globaux

```
Machine          Avant    Après   
─────────────────────────────────
Windows          50/100   100/100
Kali Linux       61/100   79/100 
Ubuntu Server    63/100   87/100 
```

> 🎯 **Objectif atteint** : réduction significative de la surface d'attaque sur les trois types de machines.

---

## 📁 Structure du dossier

```
hardening/
│
├── README.md                        ← ce fichier
│
├── windows/
│   ├── hardening_windows.ps1        ← script de durcissement
│   ├── audit_windows.ps1            ← script d'audit
│   └── screens/                     ← captures avant / après
│       ├── audit_avant.png
│       └── audit_apres.png
│
├── kali/
│   ├── hardening_kali.sh            ← script de durcissement
│   └── screens/                     ← captures Lynis avant / après
│       ├── lynis_avant.png
│       └── lynis_apres.png
│
└── ubuntu/
    ├── hardening_ubuntu.sh          ← script de durcissement principal
    ├── boost_hardening_ubuntu.sh    ← script de durcissement avancé
    └── screens/                     ← captures Lynis avant / après
        ├── lynis_avant.png
        └── lynis_apres.png
```

---

## 👤 Auteur

Projet réalisé dans le cadre de la formation **JobInTech Cybersécurité — Casablanca 2026**  
ASMAA — Ytech Solutions
