---
id: vue-ensemble
title: 13. Hardening
sidebar_label: "🛡️ Vue d'ensemble"
sidebar_position: 1
---

# 🛡️ Hardening — Durcissement des systèmes

## Objectif

Le **hardening** (durcissement) consiste à réduire la surface d'attaque de chaque système en désactivant ce qui est inutile, en renforçant les configurations par défaut, et en appliquant les bonnes pratiques des référentiels reconnus (CIS Benchmarks, Lynis).

## Systèmes durcis

| Système | Outil principal | Score / Résultat |
|---------|----------------|-----------------|
| **Ubuntu Server** | `ytech_hardening_v7.sh` + Lynis | **87/100** |
| **Kali Linux (Admin)** | `hardening_kali.sh` | UFW + SSH + auditd |
| **Windows 10** | `hardening_windows10.ps1` + Audit | **50% → 100%** |
| **SSH (Bastion)** | sshd_config + Fail2ban + UFW | Port 2222, keys only |

## Architecture du durcissement

```
Infrastructure Y-Tech
        │
        ├── Ubuntu Server ──▶ ytech_hardening_v7.sh (18 étapes CIS)
        │                     Lynis score : 87/100
        │
        ├── Kali Admin   ──▶ hardening_kali.sh (9 étapes)
        │                     UFW + SSH durci + auditd
        │
        ├── Windows 10   ──▶ hardening_windows10.ps1 (9 sections)
        │                     Score : 50% → 100%
        │
        └── Bastion SSH  ──▶ Port 2222 + UFW + Fail2ban + auditd
                             (voir section 08. Gestion des accès)
```

## Référentiels appliqués

| Référentiel | Utilisation |
|-------------|-------------|
| **CIS Benchmarks** | Base des règles sysctl, SSH, filesystem, auditd |
| **Lynis** | Score de conformité Ubuntu (87/100) |
| **NIST SP 800-123** | Bonnes pratiques serveurs |
| **Script custom Y-Tech** | Automatisation + vérification avant/après |

## Sections de ce chapitre

- [Linux — Ubuntu](./linux-ubuntu) — Script v7, 18 étapes CIS, Lynis 87/100
- [Linux — Kali Admin](./linux-kali) — Durcissement machine d'administration
- [Windows 10](./windows) — Script PowerShell, audit avant/après 50%→100%
- [SSH & Certificats](./ssh-https) — Hardening SSH, HTTPS, certificats
- [WAF ModSecurity](./waf) — Web Application Firewall
- [Bonnes pratiques](./bonnes-pratiques) — Synthèse et recommandations
