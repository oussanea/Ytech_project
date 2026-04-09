---
id: waf-modsecurity
title: WAF — ModSecurity
sidebar_label: "🧱 WAF ModSecurity"
sidebar_position: 6
---

# 🧱 WAF — ModSecurity (Web Application Firewall)

## Présentation

**ModSecurity** est un pare-feu applicatif web (WAF) open source intégré à Apache. Il analyse le trafic HTTP/HTTPS en temps réel et bloque les attaques web courantes : injections SQL, XSS, traversées de répertoires, etc.

| Attribut | Valeur |
|----------|--------|
| **Module** | `libapache2-mod-security2` |
| **Serveur** | Apache2 (Ubuntu Server) |
| **Mode** | DetectionOnly → On |
| **Règles** | OWASP Core Rule Set (CRS) |

## Installation

Installé dans le cadre du script `ytech_hardening_v7.sh` (étape 3) :

```bash
apt-get install -y libapache2-mod-evasive libapache2-mod-security2
a2enmod security2 evasive headers ssl rewrite
```

## Configuration de base

### Activer ModSecurity

```bash
# Copier la config par défaut
cp /etc/modsecurity/modsecurity.conf-recommended \
   /etc/modsecurity/modsecurity.conf

# Passer de DetectionOnly à On
sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' \
   /etc/modsecurity/modsecurity.conf
```

```apache
# /etc/modsecurity/modsecurity.conf
SecRuleEngine On
SecRequestBodyAccess On
SecResponseBodyAccess On
SecResponseBodyMimeType text/plain text/html text/xml application/json
SecAuditLog /var/log/apache2/modsecurity_audit.log
SecDebugLog /var/log/apache2/modsecurity_debug.log
SecDebugLogLevel 0
```

## OWASP Core Rule Set (CRS)

Le CRS est le jeu de règles de référence pour ModSecurity. Il couvre les **Top 10 OWASP** :

```bash
# Installation du CRS
apt-get install -y modsecurity-crs

# Activation
ln -s /usr/share/modsecurity-crs/owasp-crs.load \
      /etc/apache2/mods-enabled/
```

### Attaques détectées par le CRS

| Catégorie | Règles | Exemples détectés |
|-----------|--------|------------------|
| **Injection SQL** | CRS 942xxx | `' OR 1=1 --`, `UNION SELECT` |
| **XSS** | CRS 941xxx | `<script>alert()</script>` |
| **Path Traversal** | CRS 930xxx | `../../etc/passwd` |
| **Remote File Inclusion** | CRS 931xxx | `?file=http://evil.com/shell.php` |
| **Scanners** | CRS 913xxx | Nmap, Nikto, SQLMap détectés |
| **Protocol** | CRS 920xxx | Headers malformés |

## Règles complémentaires Y-Tech

```apache
# /etc/apache2/conf-available/ytech-security.conf
# Headers de sécurité (déjà configurés dans hardening)
Header always set X-Frame-Options "SAMEORIGIN"
Header always set X-Content-Type-Options "nosniff"
Header always set X-XSS-Protection "1; mode=block"

# Cacher la version Apache
ServerTokens Prod
ServerSignature Off

# Désactiver TRACE (évite XST attacks)
TraceEnable Off
```

## mod_evasive — Protection DDoS

`mod_evasive` complète ModSecurity en détectant les attaques par déni de service applicatif :

```apache
# /etc/apache2/mods-available/evasive.conf
<IfModule mod_evasive20.c>
    DOSHashTableSize    3097
    DOSPageCount        2       # max 2 req/sec sur une même page
    DOSSiteCount        50      # max 50 req/sec sur le site
    DOSPageInterval     1
    DOSSiteInterval     1
    DOSBlockingPeriod   10      # blocage 10 secondes
    DOSLogDir           /var/log/apache2/mod_evasive
    DOSEmailNotify      root
</IfModule>
```

## Consultation des logs WAF

```bash
# Logs d'audit ModSecurity — alertes détectées
sudo tail -f /var/log/apache2/modsecurity_audit.log

# Filtrer les attaques SQL
sudo grep "SQL" /var/log/apache2/modsecurity_audit.log

# Filtrer les XSS
sudo grep "XSS" /var/log/apache2/modsecurity_audit.log

# Logs mod_evasive
ls /var/log/apache2/mod_evasive/
```

:::info Intégration avec Wazuh
Les logs ModSecurity peuvent être ingérés par **Wazuh** (section 12. Monitoring) pour une corrélation centralisée des événements de sécurité web.
:::

## Validation du WAF

```bash
# Tester la détection XSS (depuis Kali Admin)
curl -v "http://192.168.9.253/?q=<script>alert('xss')</script>"
# Réponse attendue : 403 Forbidden

# Tester la détection SQLi
curl -v "http://192.168.9.253/?id=1' OR '1'='1"
# Réponse attendue : 403 Forbidden

# Vérifier dans les logs
sudo grep "403" /var/log/apache2/access.log
sudo grep "OWASP" /var/log/apache2/modsecurity_audit.log
```
