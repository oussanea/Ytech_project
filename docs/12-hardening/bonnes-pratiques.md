---
id: bonnes-pratiques
title: Bonnes pratiques & Synthèse
sidebar_label: "📋 Bonnes pratiques"
sidebar_position: 7
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

# 📋 Bonnes pratiques & Synthèse du hardening

## Checklist de sécurité appliquée

<Tabs>
  <TabItem value="linux" label="Linux" default>

### ✅ Ubuntu Server & Kali Admin

| Mesure | Appliqué | Outil |
|--------|----------|-------|
| MAJ automatiques de sécurité | ✅ | unattended-upgrades |
| Pare-feu local | ✅ | UFW |
| SSH : no root, clés uniquement | ✅ | sshd_config |
| SSH : crypto forte (Ed25519, ChaCha20) | ✅ | sshd_config |
| SSH : bannière légale | ✅ | /etc/issue.net |
| Anti-brute force SSH | ✅ | Fail2ban |
| Politique mots de passe (minlen=14) | ✅ | pwquality.conf |
| Vieillissement mots de passe (90j) | ✅ | login.defs |
| ASLR activé (=2) | ✅ | sysctl |
| IPv6 désactivé | ✅ | sysctl / GRUB |
| Anti-spoofing (rp_filter) | ✅ | sysctl |
| SYN cookies (anti flood) | ✅ | sysctl |
| Modules inutiles blacklistés | ✅ | modprobe.d |
| Core dumps désactivés | ✅ | limits.conf |
| Auditd avec règles CIS | ✅ | auditd |
| AppArmor enforce | ✅ | apparmor |
| AIDE (détection intégrité) | ✅ | aide |
| Rkhunter (détection rootkits) | ✅ | rkhunter |
| Sudo : use_pty, logging | ✅ | sudoers.d |
| Timeout session (15 min) | ✅ | profile.d |
| /boot/grub/grub.cfg chmod 600 | ✅ | filesystem |
| Compilateurs accès restreint | ✅ | chmod 750 |
| Services inutiles désactivés | ✅ | systemd |
| Ctrl+Alt+Del désactivé | ✅ | systemd |
| Chrony NTP | ✅ | chrony |
| **Score Lynis** | **87/100** | lynis |

  </TabItem>
  <TabItem value="windows" label="Windows 10">

### ✅ Windows 10

| Mesure | Appliqué | Impact |
|--------|----------|--------|
| Pare-feu activé (3 profils) | ✅ | Protection réseau |
| SMBv1 désactivé | ✅ | EternalBlue / WannaCry |
| UAC niveau maximal | ✅ | Élévation de privilèges |
| RDP désactivé | ✅ | Accès distant non autorisé |
| Télémétrie désactivée | ✅ | Confidentialité |
| Cortana désactivée | ✅ | Surface d'attaque |
| Autorun désactivé | ✅ | Malware USB |
| MAJ automatiques activées | ✅ | Patches de sécurité |
| DiagTrack désactivé | ✅ | Télémétrie Microsoft |
| Xbox services désactivés | ✅ | Services inutiles |
| wsearch désactivé | ✅ | Service inutile |
| PS ScriptBlock Logging | ✅ | Détection scripts |
| PowerShell v2 désactivé | ✅ | Downgrade attacks |
| Publicités ciblées désactivées | ✅ | Confidentialité |
| BitLocker (si TPM) | ✅ | Chiffrement disque |
| **Score audit** | **100%** | audit_windows10.ps1 |

  </TabItem>
  <TabItem value="bastion" label="Bastion SSH">

### ✅ Bastion Ubuntu

| Mesure | Valeur |
|--------|--------|
| Port SSH | **2222** (non standard) |
| Accès entrant | 192.168.50.0/24 uniquement (UFW) |
| PasswordAuthentication | no |
| MaxAuthTries | 3 |
| Fail2ban maxretry | 3 / bantime 1h |
| auditd | Actif avec augenrules |
| ProxyJump | Configuré vers tous les serveurs |

  </TabItem>
</Tabs>

## Règles générales de hardening

### 1 — Principe du moindre privilège (Least Privilege)

> Chaque compte, service ou processus ne dispose que des droits strictement nécessaires à sa fonction.

```bash
# ❌ À éviter
chmod 777 /var/www/html
sudo ALL=(ALL) NOPASSWD: ALL

# ✅ À faire
chmod 750 /var/www/html
sudo -l   # vérifier les droits effectifs
```

### 2 — Réduction de la surface d'attaque

```bash
# Désactiver tout ce qui n'est pas utilisé
systemctl disable <service>
systemctl stop <service>

# Fermer les ports inutiles
ufw deny <port>

# Supprimer les paquets inutiles
apt purge <paquet>
```

### 3 — Défense en profondeur (Defense in Depth)

Ne pas compter sur une seule couche de protection :

```
Internet → Firewall OPNsense → UFW local → Fail2ban → SSH keys → auditd
```

Chaque couche est indépendante : si l'une échoue, les suivantes tiennent.

### 4 — Surveillance et alertes

```bash
# Vérifier les connexions suspectes
sudo grep "Failed password" /var/log/auth.log
sudo grep "Invalid user" /var/log/auth.log

# Vérifier les IPs bannies par Fail2ban
sudo fail2ban-client status sshd

# Consulter les alertes Suricata
# Services → Intrusion Detection → Alerts (OPNsense)
```

### 5 — Mises à jour régulières

```bash
# Ubuntu — vérifier les MAJ disponibles
apt list --upgradable

# Vérifier le statut unattended-upgrades
systemctl status unattended-upgrades
grep "Packages that will be upgraded" /var/log/unattended-upgrades/unattended-upgrades.log
```

### 6 — Sauvegarde avant modification

```bash
# Toujours sauvegarder avant de modifier un fichier de config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%Y%m%d)

# Valider la config SSH avant redémarrage
sshd -t && systemctl restart sshd
```

## Commandes de vérification post-hardening

```bash
# Score Lynis complet
sudo lynis audit system
sudo grep "Hardening index" /var/log/lynis.log

# Ports en écoute
ss -tuln

# Services actifs
systemctl list-units --type=service --state=running

# Règles UFW
sudo ufw status verbose

# IPs bannies Fail2ban
sudo fail2ban-client status sshd

# Règles auditd chargées
sudo auditctl -l

# Processus SUID/SGID (audit)
find / -xdev -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null
```

## Synthèse des scores obtenus

| Système | Score | Outil de mesure |
|---------|-------|----------------|
| **Ubuntu Server** | **87/100** | Lynis |
| **Windows 10** | **100%** (22/22 checks) | audit_windows10.ps1 |
| **Kali Admin** | UFW + SSH + auditd ✅ | Manuel |
| **Bastion** | 4 couches de protection ✅ | Manuel |

:::tip Score Lynis 87/100
Un score Lynis de **87/100** est excellent pour un environnement de laboratoire. En production, les ajustements supplémentaires (PAM complet, SELinux, auditd immuable `-e 2`) permettraient d'atteindre 90+.
:::
