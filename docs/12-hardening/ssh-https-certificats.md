---
id: ssh-https-certificats
title: SSH & HTTPS — Certificats
sidebar_label: "🔐 SSH & HTTPS"
sidebar_position: 5
---

# 🔐 SSH & HTTPS — Certificats

## SSH — Configuration durcie

Le durcissement SSH est appliqué sur tous les systèmes Linux de l'infrastructure avec des niveaux de restriction adaptés au rôle de chaque machine.

### Comparatif des configurations SSH

| Paramètre | Bastion | Ubuntu Srv | Kali Admin | Valeur sécurisée |
|-----------|---------|------------|------------|-----------------|
| **Port** | **2222** | 22 | 22 | Non standard recommandé |
| **PermitRootLogin** | no | no | no | ✅ |
| **PasswordAuthentication** | no | yes* | no | no (clés uniquement) |
| **MaxAuthTries** | 3 | 4 | 3 | ≤ 5 |
| **Protocol** | 2 | 2 | 2 | ✅ |
| **X11Forwarding** | no | no | no | ✅ |
| **AllowTcpForwarding** | no | no | no | ✅ |
| **Ciphers** | ChaCha20/AES-GCM | ChaCha20/AES-GCM | ChaCha20/AES-GCM | ✅ |
| **MACs** | SHA2-512-etm | SHA2-512-etm | SHA2-512-etm | ✅ |
| **KexAlgorithms** | curve25519 | curve25519 | curve25519 | ✅ |
| **LogLevel** | VERBOSE | VERBOSE | VERBOSE | ✅ |
| **Fail2ban** | ✅ | ✅ | — | ✅ |

> *Ubuntu Srv : PasswordAuthentication yes maintenu pour compatibilité — à migrer vers clés uniquement en production.

### Crypto SSH recommandée (appliquée)

```bash
# Algorithmes d'échange de clés
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256

# Chiffrements
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com

# MACs
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# Clés hôtes (faibles supprimées)
HostKey /etc/ssh/ssh_host_ed25519_key   # Ed25519 uniquement
HostKey /etc/ssh/ssh_host_rsa_key       # RSA 4096
# Supprimés : DSA, ECDSA (trop faibles)
```

### Moduli faibles supprimés

```bash
# Supprimer les moduli Diffie-Hellman < 3071 bits
awk '$5 >= 3071' /etc/ssh/moduli > /tmp/moduli_strong
mv /tmp/moduli_strong /etc/ssh/moduli
```

:::info Pourquoi supprimer les moduli faibles ?
Les moduli DH < 3071 bits sont vulnérables à des attaques de type Logjam. En ne conservant que les moduli ≥ 3071 bits, on force l'usage de paramètres résistants.
:::

### Bannières SSH

Affichées avant l'authentification sur tous les systèmes :

```
+--------------------------------------------------+
|       YTECH SOLUTIONS - ACCES RESTREINT          |
|  Systeme prive. Acces non autorise interdit.     |
|  Toute activite est enregistree et surveillee.   |
+--------------------------------------------------+
```

### Génération et déploiement des clés SSH

```bash
# Générer une paire de clés Ed25519 (recommandé)
ssh-keygen -t ed25519 -C "admin@ytech" -f ~/.ssh/id_ed25519

# Déployer la clé publique sur le bastion
ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 2222 admin@192.168.1.20

# Déployer via ProxyJump sur les serveurs
ssh-copy-id -i ~/.ssh/id_ed25519.pub -o "ProxyJump admin@192.168.1.20:2222" admin@192.168.9.253
```

---

## HTTPS & Certificats

### Contexte

Les services web de l'infrastructure Y-Tech (HR App, Chatbot, Bitwarden, Grafana) sont accessibles en **HTTPS**. Les certificats peuvent être auto-signés (environnement lab) ou signés par une CA (production).

### Ports HTTPS des services

| Service | Port | Protocole |
|---------|------|-----------|
| HR App (Laravel) | 8443 | HTTPS |
| Bitwarden | 8444 | HTTPS |
| OPNsense Web GUI | 443 | HTTPS |
| Grafana | 3000 | HTTP (à migrer HTTPS) |
| Nessus | 8834 | HTTPS |

### Headers HTTP de sécurité (Apache)

Configurés via le script `ytech_hardening_v7.sh` (étape 17) :

```apache
# /etc/apache2/conf-available/ytech-security.conf
Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
Header always set X-Frame-Options "SAMEORIGIN"
Header always set X-Content-Type-Options "nosniff"
Header always set X-XSS-Protection "1; mode=block"
Header always set Referrer-Policy "strict-origin-when-cross-origin"
Header always set Content-Security-Policy "default-src 'self';"
Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
Header unset Server
Header unset X-Powered-By
ServerTokens Prod
ServerSignature Off
TraceEnable Off
```

### Certificat auto-signé — Génération

```bash
# Générer un certificat auto-signé 4096 bits valable 2 ans
openssl req -x509 -nodes -days 730 -newkey rsa:4096 \
    -keyout /etc/ssl/private/ytech.key \
    -out /etc/ssl/certs/ytech.crt \
    -subj "/C=MA/ST=Casablanca/O=YTech Solutions/CN=ytech.local"

# Permissions
chmod 600 /etc/ssl/private/ytech.key
chmod 644 /etc/ssl/certs/ytech.crt
```

### Configuration TLS Apache

```apache
<VirtualHost *:443>
    ServerName ytech.local

    SSLEngine on
    SSLCertificateFile    /etc/ssl/certs/ytech.crt
    SSLCertificateKeyFile /etc/ssl/private/ytech.key

    # Désactiver protocoles faibles
    SSLProtocol -all +TLSv1.2 +TLSv1.3
    SSLCipherSuite ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder on
    SSLCompression off

    # HSTS
    Header always set Strict-Transport-Security "max-age=63072000"
</VirtualHost>

# Redirection HTTP → HTTPS
<VirtualHost *:80>
    RewriteEngine On
    RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]
</VirtualHost>
```

:::warning Environnement lab
Dans l'environnement VirtualBox, les certificats sont auto-signés. En production, il faudrait utiliser **Let's Encrypt** (`certbot --apache`) ou une CA interne pour des certificats de confiance.
:::
