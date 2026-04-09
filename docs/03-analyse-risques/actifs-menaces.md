---
id: actifs-menaces
title: Actifs & Sources de menaces
sidebar_position: 2
---

# Actifs & Sources de menaces

## Pourquoi identifier les actifs en premier ?

Avant de parler de hackers ou d'attaques, il faut d'abord répondre à une question simple : **qu'est-ce qu'on protège ?**

C'est comme assurer une voiture — avant de choisir une assurance, on évalue d'abord la valeur du véhicule, ce qu'il contient, et dans quel quartier il est garé. Sans cette étape, on risque de sur-assurer ce qui ne vaut rien et de sous-protéger ce qui est critique.

Pour Ytech Solutions, cette étape est d'autant plus importante que l'entreprise **gère des données sensibles pour le compte de tiers** (ses clients PME). Une compromission ne touche pas seulement Ytech — elle touche tous ses clients.

---

## Inventaire des actifs

### Actifs informationnels

Ce sont les **données** — ce que l'entreprise possède et qui a une valeur directe.

| Actif | Description | Valeur | Localisation |
|---|---|---|---|
| Données clients | Commandes, contacts, informations commerciales | 🔴 Critique | Base `db_clients` |
| Données RH | Salaires, contrats, informations personnelles | 🔴 Critique | Base `db_rh` |
| Code source | Applications développées pour les clients PME | 🔴 Critique | GitHub + serveurs |
| Credentials | Mots de passe, clés SSH, tokens API | 🔴 Critique | Bitwarden |
| Données applicatives | Sessions utilisateurs, logs applicatifs | 🟡 Modérée | App Server |
| Configurations | Fichiers Docker, configs Nginx, règles firewall | 🟡 Modérée | Serveurs |

> 💶 **Valeur financière** : Les données clients et RH sont soumises au **RGPD**. En cas de fuite, les amendes peuvent atteindre **4% du chiffre d'affaires annuel** ou 20 millions d'euros. Pour une PME comme Ytech Solutions, même une amende de 50 000 € peut être fatale. S'ajoute à cela le coût de la perte de confiance clients, estimé à **plusieurs années de revenus**.

---

### Actifs logiciels

Ce sont les **applications et services** qui font tourner l'activité.

| Actif | Criticité | Impact si compromis |
|---|---|---|
| App Web Laravel | 🔴 Critique | Vitrine de l'entreprise, perte de clients |
| App CRUD RH | 🔴 Critique | Fuite données personnelles employés |
| YtechBot (Ollama) | 🟡 Modérée | Perte de productivité interne |
| MariaDB (3 bases) | 🔴 Critique | Perte totale des données métier |
| Zabbix / Wazuh | 🟡 Modérée | Perte de visibilité sur les incidents |
| Bitwarden | 🔴 Critique | Compromission de tous les accès |

---

### Actifs infrastructure

Ce sont les **composants techniques** qui font fonctionner les services.

| Actif | Criticité | Impact si compromis |
|---|---|---|
| OPNSense (firewall) | 🔴 Critique | Exposition totale du réseau interne |
| Serveur MariaDB (VM2) | 🔴 Critique | Perte ou vol de toutes les données |
| APP Server (VM1) | 🔴 Critique | Arrêt des services applicatifs |
| Monitoring (VM3) | 🟡 Modérée | Perte de supervision |
| Backup Server | 🔴 Critique | Impossibilité de restauration |
| Réseau interne (VLANs) | 🔴 Critique | Propagation latérale d'une attaque |

---

## Sources de menaces

Une **source de menace** est toute entité susceptible de causer un dommage intentionnel ou accidentel à nos actifs. On distingue les menaces **externes** et **internes**.

### Menaces externes

#### 🎯 Attaquant opportuniste (Script Kiddie)

| Attribut | Valeur |
|---|---|
| **Profil** | Individu peu qualifié utilisant des outils automatisés |
| **Motivation** | Opportunisme, curiosité, réputation |
| **Capacité** | Faible à moyenne |
| **Vecteurs probables** | Scan de ports, exploitation de CVEs publiques, attaques web automatisées |
| **Cibles chez Ytech** | Application web publique, services exposés |

> C'est la menace **la plus fréquente** sur Internet. Des milliers de scans automatisés frappent chaque serveur exposé chaque jour. Sans firewall et WAF, l'application web de Ytech serait compromise en quelques heures.

---

#### 🎯 Cybercriminel organisé

| Attribut | Valeur |
|---|---|
| **Profil** | Groupe structuré avec objectifs financiers |
| **Motivation** | Gain financier (ransomware, revente de données) |
| **Capacité** | Élevée |
| **Vecteurs probables** | Phishing ciblé, exploitation de vulnérabilités, ransomware |
| **Cibles chez Ytech** | Données clients, données RH, systèmes critiques |

> 💶 **Dimension financière** : Le coût moyen d'une attaque ransomware pour une PME est de **170 000 €** (rançon + temps d'arrêt + restauration). Sans backup 3-2-1 chiffré, Ytech n'aurait d'autre choix que de payer ou de tout perdre.

---

#### 🎯 Concurrent malveillant

| Attribut | Valeur |
|---|---|
| **Profil** | Entreprise concurrente cherchant un avantage compétitif |
| **Motivation** | Espionnage industriel, sabotage |
| **Capacité** | Moyenne à élevée |
| **Vecteurs probables** | Vol de code source, exfiltration de listes clients |
| **Cibles chez Ytech** | Code source des applications, base clients |

---

### Menaces internes

#### ⚠️ Employé négligent

| Attribut | Valeur |
|---|---|
| **Profil** | Collaborateur interne sans intention malveillante |
| **Motivation** | Erreur humaine, manque de formation |
| **Capacité** | Variable |
| **Vecteurs probables** | Mot de passe faible, clic sur phishing, mauvaise configuration |
| **Cibles chez Ytech** | Tous les actifs accessibles depuis VLAN 40 |

> C'est statistiquement la **première cause de compromission** en entreprise. C'est pour cette raison que Ytech déploie Bitwarden (gestion des mots de passe), fail2ban (blocage brute-force) et Headscale/Tailscale (Zero Trust même en interne).

---

#### ⚠️ Employé malveillant (Insider Threat)

| Attribut | Valeur |
|---|---|
| **Profil** | Collaborateur avec accès légitimes et intentions malveillantes |
| **Motivation** | Rancœur, gain financier, espionnage |
| **Capacité** | Élevée (accès internes) |
| **Vecteurs probables** | Exfiltration de données, sabotage, création de backdoors |
| **Cibles chez Ytech** | Données RH, code source, configurations |

---

## Cartographie actifs / menaces

Le tableau suivant croise chaque actif critique avec les sources de menaces les plus probables :

| Actif | Script Kiddie | Cybercriminel | Concurrent | Employé négligent | Insider |
|---|---|---|---|---|---|
| App Web (Laravel) | 🔴 Élevé | 🟡 Moyen | 🟢 Faible | 🟡 Moyen | 🟢 Faible |
| Base `db_clients` | 🟡 Moyen | 🔴 Élevé | 🔴 Élevé | 🟡 Moyen | 🔴 Élevé |
| Base `db_rh` | 🟢 Faible | 🔴 Élevé | 🟡 Moyen | 🟡 Moyen | 🔴 Élevé |
| Code source | 🟢 Faible | 🟡 Moyen | 🔴 Élevé | 🟡 Moyen | 🔴 Élevé |
| Credentials | 🟡 Moyen | 🔴 Élevé | 🟡 Moyen | 🔴 Élevé | 🔴 Élevé |
| Firewall OPNSense | 🟡 Moyen | 🔴 Élevé | 🟢 Faible | 🟡 Moyen | 🟡 Moyen |
| Backup Server | 🟢 Faible | 🔴 Élevé | 🟢 Faible | 🟢 Faible | 🟡 Moyen |

---

## Vulnérabilités identifiées sur l'infrastructure initiale

Avant toute sécurisation, l'infrastructure initiale présentait les vulnérabilités suivantes qui exposaient directement ces actifs :

| Vulnérabilité | Actifs exposés | Risque |
|---|---|---|
| Réseau plat sans segmentation | Tous | Un poste compromis = accès à tout |
| Pas de WAF sur l'app web | App Web, `db_clients` | Injection SQL, XSS, vol de données |
| Mots de passe non gérés | Credentials | Brute-force, réutilisation |
| Pas de monitoring | Tous | Incident non détecté pendant des jours |
| Pas de backup chiffré | Toutes les données | Perte totale ou ransomware |
| SSH sur port 22 standard | Serveurs | Brute-force automatisé massif |
| Pas de Zero Trust | Réseau interne | Propagation latérale libre |

> 💶 **Coût de l'inaction** : Une entreprise de services numériques sans sécurité correcte s'expose à une perte moyenne de **200 000 €** en cas d'incident majeur (IBM, 2023), sans compter les **poursuites judiciaires** de clients dont les données auraient été compromises. L'ensemble de l'architecture sécurisée que nous proposons a été déployée avec des outils **100% open source**, représentant un coût quasi nul en licences, contre un risque financier potentiellement fatal.

Cette analyse d'actifs et de menaces constitue le socle sur lequel sont construits les scénarios d'attaque et la matrice des risques des sections suivantes.
