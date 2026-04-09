---
id: scenarios-attaque
title: Scénarios d'attaque
sidebar_position: 3
---

# Scénarios d'attaque

## Pourquoi construire des scénarios ?

Identifier les actifs et les menaces ne suffit pas. Il faut aller plus loin et se demander : **comment concrètement un attaquant pourrait-il s'introduire dans notre système ?**

Un scénario d'attaque, c'est comme reconstituer un cambriolage avant qu'il n'ait lieu. On suit le chemin que prendrait le voleur : par où il entre, ce qu'il contourne, ce qu'il cible. Cette approche, inspirée d'**EBIOS Risk Manager**, permet de tester nos défenses contre des situations réelles et non théoriques.

Pour chaque scénario, nous décrivons :
- **Le chemin d'attaque** (kill chain)
- **Les mesures en place** pour le contrer
- **Le niveau de risque résiduel** après sécurisation

---

## Scénario 1 — Injection SQL sur l'application web

### Contexte
Un attaquant externe détecte l'application web commerciale de Ytech Solutions via un scanner automatisé. Il tente d'exploiter un formulaire pour extraire la base de données clients.

### Chemin d'attaque (Kill Chain)

```
1. Reconnaissance
   └─ Scanner automatisé détecte app-web:443 exposée

2. Scanning
   └─ Nikto / sqlmap identifie un formulaire vulnérable

3. Exploitation
   └─ Injection SQL → accès à db_clients
   └─ Extraction : emails, commandes, données clients

4. Exfiltration
   └─ Export base de données vers serveur attaquant

5. Impact
   └─ Violation RGPD + perte de confiance clients
```

### Mesures de protection déployées

| Étape kill chain | Contre-mesure | Composant |
|---|---|---|
| Reconnaissance | Blocage scanners web | ModSecurity WAF (OWASP CRS) |
| Scanning | Détection et bannissement | Suricata IPS + fail2ban |
| Exploitation | Blocage SQLi | WAF ModSecurity règle 942xxx |
| Exploitation | Requêtes paramétrées | Code Laravel (PDO) |
| Exfiltration | Accès DB limité par IP | MariaDB `GRANT` + UFW |
| Impact | Logs d'audit | Wazuh SIEM + modsec_audit.log |

### Risque résiduel
- **Avant sécurisation** : 🔴 Critique (16/16)
- **Après sécurisation** : 🟢 Faible (2/16)

> 💶 **Dimension financière** : Une fuite de données clients via SQLi peut entraîner une amende RGPD allant jusqu'à **20 millions d'euros** ou 4% du CA. Le déploiement de ModSecurity (gratuit, open source) neutralise cette menace pour un coût opérationnel quasi nul.

---

## Scénario 2 — Attaque par force brute sur les services exposés

### Contexte
Un cybercriminel tente d'accéder aux services administratifs de Ytech Solutions (SSH, interfaces web) en testant des milliers de combinaisons login/mot de passe de manière automatisée.

### Chemin d'attaque (Kill Chain)

```
1. Reconnaissance
   └─ Nmap détecte SSH:22, Zabbix:8443, Bitwarden:8444

2. Brute-force SSH
   └─ Hydra / Medusa teste des listes de credentials
   └─ Objectif : accès root au serveur

3. Brute-force applicatif
   └─ Burp Suite attaque les formulaires de login
   └─ Objectif : accès admin Zabbix ou Bitwarden

4. Compromission
   └─ Accès root → pivot vers DB, MGMT, BACKUP

5. Impact
   └─ Contrôle total de l'infrastructure
```

### Mesures de protection déployées

| Étape kill chain | Contre-mesure | Composant |
|---|---|---|
| Reconnaissance | Port SSH non standard | SSH port 2222 |
| Reconnaissance | Services non exposés WAN | OPNSense deny-by-default |
| Brute-force SSH | Blocage après 3 échecs | fail2ban (bantime 1h) |
| Brute-force SSH | Authentification par clé uniquement | `PasswordAuthentication no` |
| Brute-force applicatif | Blocage 15 min après 3 tentatives | YtechBot + CRUD RH |
| Compromission | Zero Trust obligatoire | Headscale/Tailscale MFA |
| Impact | Logs et alertes | Wazuh SIEM + Zabbix |

### Risque résiduel
- **Avant sécurisation** : 🔴 Critique (16/16)
- **Après sécurisation** : 🟢 Faible (3/16)

---

## Scénario 3 — Accès non autorisé à l'application RH

### Contexte
Un employé du département Commercial tente d'accéder à l'application CRUD RH pour consulter les salaires de ses collègues. Il n'y est pas autorisé mais est sur le même réseau interne.

### Chemin d'attaque (Kill Chain)

```
1. Accès réseau interne
   └─ Employé connecté sur VLAN 40 (USERS)

2. Tentative d'accès direct
   └─ Navigateur → http://192.168.20.10:8443/hr-app/
   └─ Objectif : accéder à l'interface RH

3. Escalade de privilèges applicatifs
   └─ Tester des comptes par défaut / credentials volés
   └─ Objectif : se connecter comme administrateur RH

4. Exfiltration
   └─ Export liste employés + salaires

5. Impact
   └─ Violation RGPD données personnelles employés
```

### Mesures de protection déployées

| Étape kill chain | Contre-mesure | Composant |
|---|---|---|
| Accès réseau | VLAN 40 bloqué vers VLAN 20 | OPNSense ACL inter-VLAN |
| Accès réseau | Zero Trust obligatoire | Headscale/Tailscale (RH seulement) |
| Accès applicatif | Authentification obligatoire | CRUD RH login |
| Escalade | Rôles applicatifs (RH sans suppression) | Code PHP RBAC |
| Exfiltration | Logs d'accès applicatifs | Wazuh agent APP Server |
| Impact | Alertes comportement anormal | Wazuh SIEM |

### Risque résiduel
- **Avant sécurisation** : 🔴 Élevé (12/16) — réseau plat, pas de contrôle d'accès
- **Après sécurisation** : 🟢 Faible (2/16)

---

## Scénario 4 — Ransomware via propagation latérale

### Contexte
Un employé clique sur un lien de phishing et télécharge un malware. Celui-ci cherche à se propager sur le réseau interne pour chiffrer un maximum de données et demander une rançon.

### Chemin d'attaque (Kill Chain)

```
1. Infection initiale
   └─ Poste employé VLAN 40 compromis via phishing

2. Reconnaissance interne
   └─ Nmap interne → cartographie des serveurs accessibles

3. Propagation latérale
   └─ Tentative d'atteindre DB Server, APP Server, Backup

4. Chiffrement
   └─ Chiffrement des bases de données et fichiers
   └─ Suppression des sauvegardes locales

5. Demande de rançon
   └─ Message sur tous les postes : payer ou perdre tout
```

### Mesures de protection déployées

| Étape kill chain | Contre-mesure | Composant |
|---|---|---|
| Infection initiale | Sensibilisation + MFA | Formation + Headscale MFA |
| Reconnaissance interne | Isolation VLAN 40 | OPNSense ACL : USERS → serveurs bloqué |
| Propagation latérale | Zero Trust : chaque connexion vérifiée | Headscale/Tailscale |
| Propagation latérale | Détection comportement anormal | Wazuh SIEM + Suricata |
| Chiffrement | Backup hors site chiffré | Backup 3-2-1 Google Drive AES-256 |
| Chiffrement | Backup VLAN isolé | VLAN 60 inaccessible depuis VLAN 40 |
| Impact | Restauration possible | Backup quotidien 02h00 |

### Risque résiduel
- **Avant sécurisation** : 🔴 Critique (16/16) — réseau plat, pas de backup chiffré
- **Après sécurisation** : 🟡 Modéré (6/16) — risque résiduel sur le poste infecté lui-même

> 💶 **Dimension financière** : Le coût moyen d'une attaque ransomware pour une PME est de **170 000 €** (Hiscox Cyber Readiness Report 2023). Sans segmentation VLAN et sans backup 3-2-1, Ytech n'aurait aucun recours. Avec notre architecture, même en cas d'infection d'un poste, les serveurs critiques restent **inaccessibles** et les données **restaurables** depuis le backup Google Drive chiffré.

---

## Scénario 5 — Compromission du gestionnaire de mots de passe

### Contexte
Un attaquant ayant accédé à un poste admin tente de récupérer les credentials de l'ensemble de l'infrastructure stockés dans Bitwarden.

### Chemin d'attaque (Kill Chain)

```
1. Accès initial
   └─ Compromission poste admin VLAN 50

2. Ciblage Bitwarden
   └─ Accès à https://192.168.30.10:8444

3. Extraction credentials
   └─ Master password volé → accès à tous les secrets
   └─ Clés SSH, mots de passe DB, tokens API

4. Pivot
   └─ Connexion SSH à tous les serveurs
   └─ Accès direct aux bases de données

5. Impact
   └─ Compromission totale de l'infrastructure
```

### Mesures de protection déployées

| Étape kill chain | Contre-mesure | Composant |
|---|---|---|
| Accès initial | VLAN 50 isolé, accès restreint | OPNSense + Bastion SSH |
| Accès initial | fail2ban + auditd sur bastion | Hardening VLAN 50 |
| Ciblage Bitwarden | Bitwarden non exposé WAN | OPNSense deny WAN → MGMT |
| Ciblage Bitwarden | Accessible uniquement depuis VLAN 30 | ACL inter-VLAN |
| Extraction credentials | Master password bcrypt | Vaultwarden |
| Pivot | Clés SSH par serveur | Rotation des clés |
| Impact | Logs Wazuh + alertes Grafana | SIEM + SOC Dashboard |

### Risque résiduel
- **Avant sécurisation** : 🔴 Critique — credentials en clair, pas de gestionnaire centralisé
- **Après sécurisation** : 🟡 Modéré (4/16) — risque résiduel si master password compromis

---

## Synthèse des scénarios

| Scénario | Source menace | Actifs ciblés | Risque initial | Risque résiduel |
|---|---|---|---|---|
| SQLi App Web | Attaquant externe | `db_clients` | 🔴 16/16 | 🟢 2/16 |
| Brute-force services | Cybercriminel | Serveurs, admin | 🔴 16/16 | 🟢 3/16 |
| Accès non autorisé RH | Insider / employé | `db_rh` | 🔴 12/16 | 🟢 2/16 |
| Ransomware latéral | Cybercriminel | Toute l'infra | 🔴 16/16 | 🟡 6/16 |
| Compromission Bitwarden | Attaquant avancé | Credentials | 🔴 16/16 | 🟡 4/16 |

:::tip Lecture du tableau
Le **risque résiduel** n'est jamais zéro — aucun système n'est parfait. L'objectif est de **ramener le risque à un niveau acceptable**, c'est-à-dire inférieur au seuil de criticité (9/16) défini dans notre méthodologie. Tous nos scénarios passent en dessous de ce seuil après sécurisation.
:::

> 💶 **Bilan financier global** : L'ensemble des mesures déployées pour contrer ces 5 scénarios repose sur des outils **100% open source** (OPNSense, Wazuh, ModSecurity, Headscale, Bitwarden). Le coût en licences est **nul**. En regard, le coût potentiel cumulé de ces 5 scénarios non traités dépasse **500 000 €** (amendes RGPD + ransomware + perte clients). C'est un ROI de sécurité exceptionnel, accessible même à une PME sans budget dédié à la cybersécurité.
