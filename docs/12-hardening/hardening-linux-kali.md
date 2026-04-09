---
id: hardening-linux-kali
title: Hardening Linux — Kali Admin
sidebar_label: "🐉 Linux Kali"
sidebar_position: 3
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

# 🐉 Hardening Linux — Kali Admin

## Contexte

La machine **Kali Admin** est la station d'administration de l'infrastructure Y-Tech. C'est depuis cette machine que l'administrateur accède au bastion SSH, à l'interface OPNsense, et aux outils de monitoring. Son durcissement est donc critique.

| Attribut | Valeur |
|----------|--------|
| **Script** | `hardening_kali.sh` |
| **IP** | 192.168.50.20/24 (VLAN50_ADMIN) |
| **Rôle** | Machine d'administration principale |

## Script de hardening — 9 étapes

<Tabs>
  <TabItem value="systeme" label="Système" default>

### 1 — Mise à jour système

```bash
apt-get update -y && apt-get upgrade -y
apt-get dist-upgrade -y && apt-get autoremove -y
```

### 2 — UFW pare-feu

```bash
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw default deny forward

# SSH avec rate-limiting anti brute-force
ufw limit ssh comment 'SSH limite anti brute-force'
ufw logging on

ufw --force enable
```

### 6 — Désactivation services inutiles

```bash
systemctl disable avahi-daemon   # découverte réseau
systemctl disable cups            # impression
systemctl disable bluetooth       # bluetooth
systemctl disable rpcbind         # RPC
```

  </TabItem>
  <TabItem value="ssh" label="SSH Durci">

### 3 — Durcissement SSH complet

```bash
# /etc/ssh/sshd_config
PermitRootLogin            no
PasswordAuthentication     no        # clés SSH uniquement
PubkeyAuthentication       yes
MaxAuthTries               3
MaxSessions                3
LoginGraceTime             30
ClientAliveInterval        300
ClientAliveCountMax        2
X11Forwarding              no
AllowAgentForwarding       no
AllowTcpForwarding         no
Protocol                   2
LogLevel                   VERBOSE

# Crypto forte
Ciphers  chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs     hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# Bannière d'avertissement
Banner /etc/ssh/banner
```

Bannière :
```
*************************************************************
*  Acces restreint aux personnes autorisees uniquement.    *
*  Toute tentative non autorisee sera enregistree.         *
*************************************************************
```

:::warning PasswordAuthentication no
Sur Kali Admin, l'authentification par mot de passe SSH est **désactivée**. Seules les clés SSH sont acceptées. Il faut impérativement configurer sa clé publique avant d'appliquer ce hardening.
:::

  </TabItem>
  <TabItem value="pam" label="PAM & Mots de passe">

### 4 — Politique mots de passe (PAM)

```bash
# Installation
apt-get install -y libpam-pwquality

# /etc/security/pwquality.conf
minlen    = 14
dcredit   = -1
ucredit   = -1
ocredit   = -1
lcredit   = -1
difok     = 5
maxrepeat = 3
reject_username = 1

# Vieillissement
# /etc/login.defs
PASS_MAX_DAYS   90
PASS_MIN_DAYS   1
PASS_WARN_AGE   14
```

### 5 — Verrouillage de compte (faillock)

```bash
# /etc/pam.d/common-auth
auth required pam_faillock.so preauth silent deny=5 unlock_time=600
auth [default=die] pam_faillock.so authfail deny=5 unlock_time=600
auth sufficient pam_faillock.so authsucc
```

| Paramètre | Valeur |
|-----------|--------|
| `deny` | 5 tentatives max |
| `unlock_time` | 10 minutes |

  </TabItem>
  <TabItem value="audit" label="Audit & Mises à jour">

### 7 — Auditd — journalisation

```bash
apt install auditd -y
systemctl enable auditd
systemctl start auditd
```

Règles dans `/etc/audit/rules.d/hardening.rules` :

```bash
# Connexions/déconnexions
-w /var/log/wtmp  -p wa -k logins
-w /var/log/btmp  -p wa -k logins
-w /var/log/lastlog -p wa -k logins

# Fichiers sensibles
-w /etc/passwd   -p wa -k identity
-w /etc/shadow   -p wa -k identity
-w /etc/sudoers  -p wa -k sudoers
-w /etc/ssh/sshd_config -p wa -k sshd_config

# Syscalls critiques
-a always,exit -F arch=b64 -S execve -k exec_log

# Modules noyau
-w /sbin/insmod   -p x -k modules
-w /sbin/modprobe -p x -k modules
```

### 8 — Sysctl noyau

```bash
# /etc/sysctl.d/99-hardening.conf
net.ipv4.ip_forward              = 0
net.ipv4.conf.all.rp_filter      = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.tcp_syncookies          = 1
kernel.randomize_va_space        = 2
kernel.kptr_restrict             = 2
kernel.dmesg_restrict            = 1
kernel.sysrq                     = 0
fs.suid_dumpable                 = 0
```

### 9 — Mises à jour automatiques

```bash
apt install unattended-upgrades -y
dpkg-reconfigure --priority=low unattended-upgrades
```

  </TabItem>
</Tabs>

## Résumé des mesures Kali Admin

| Mesure | Configuration |
|--------|--------------|
| UFW | deny incoming, limit SSH, logging on |
| SSH | PasswordAuthentication no, MaxAuthTries 3, Ed25519, bannière |
| PAM | minlen=14, dcredit/ucredit/ocredit/lcredit = -1 |
| Faillock | deny=5, unlock=10min |
| auditd | Fichiers sensibles + syscalls critiques |
| sysctl | ASLR=2, anti-spoofing, no forwarding |
| Services | avahi, cups, bluetooth, rpcbind désactivés |
| MAJ auto | unattended-upgrades activé |

:::tip Machine d'administration
La machine Kali Admin a un profil de sécurité plus strict que les serveurs applicatifs car elle a accès à toute l'infrastructure. Sa compromission aurait un impact maximal.
:::
