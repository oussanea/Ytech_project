---
id: methodologie-iso
title: Méthodologie ISO / EBIOS RM
sidebar_position: 1
---

# Méthodologie de gestion des risques

## Pourquoi une méthodologie ?

Avant de sécuriser quoi que ce soit, il faut d'abord **comprendre ce qu'on protège, contre qui, et pourquoi**.

Imaginez que vous construisez une maison. Vous n'installez pas des barreaux aux fenêtres sans avoir d'abord identifié que vous êtes dans un quartier à risque, que vous avez des objets de valeur, et que votre porte d'entrée est la principale vulnérabilité. C'est exactement ce que fait une méthodologie de gestion des risques : elle force à **réfléchir avant d'agir**.

Sans cette étape, on risque de :
- Dépenser de l'argent sur des outils inutiles
- Oublier les vraies menaces
- Sécuriser les mauvaises choses

:::info Choix de la méthodologie
Pour ce projet, nous avons combiné deux approches complémentaires : **ISO/IEC 27005** pour le cadre général de gestion des risques, et les principes d'**EBIOS Risk Manager** pour la construction des scénarios de menace. Ce choix reflète les standards utilisés en entreprise en France et au Maroc.
:::

---

## Les deux référentiels utilisés

### ISO/IEC 27005 — Gestion des risques de sécurité

La norme **ISO 27005** est le guide officiel pour gérer les risques liés à la sécurité de l'information. Elle s'intègre naturellement dans le cadre ISO 27001.

**Ce qu'elle apporte :**
- Un processus structuré et répétable
- Une terminologie commune (actif, menace, vulnérabilité, risque)
- Une méthode d'évaluation objective

**Pourquoi ce choix ?**
ISO 27005 est reconnue internationalement. Une entreprise comme Ytech Solutions qui travaille avec des PME clientes a tout intérêt à s'aligner sur des standards reconnus — cela rassure les clients et facilite d'éventuelles certifications futures.

> 💶 **Dimension financière** : Une certification ISO 27001 coûte entre 15 000 € et 50 000 € pour une PME. S'aligner dès maintenant sur ses principes réduit considérablement ce coût futur et démontre une maturité sécurité aux clients potentiels.

---

### EBIOS Risk Manager — Construction des scénarios

**EBIOS RM** (Expression des Besoins et Identification des Objectifs de Sécurité) est la méthode développée par l'**ANSSI** (Agence Nationale de la Sécurité des Systèmes d'Information française). Elle est particulièrement adaptée pour modéliser des scénarios d'attaque réalistes.

**Ce qu'elle apporte :**
- L'identification des **sources de menaces** (qui peut nous attaquer ?)
- La construction de **scénarios stratégiques** (quel chemin emprunte un attaquant ?)
- L'évaluation de la **vraisemblance** des attaques

**Pourquoi ce choix ?**
EBIOS RM est orientée "attaquant" — elle force à penser comme un adversaire, pas seulement comme un défenseur. C'est ce qui permet d'identifier les scénarios réalistes plutôt que théoriques.

---

## Notre processus en 5 étapes

Nous avons suivi un processus linéaire adapté à la taille et au contexte du projet :

```
Étape 1 — Identification des actifs
          ↓
Étape 2 — Identification des menaces et sources
          ↓
Étape 3 — Construction des scénarios d'attaque
          ↓
Étape 4 — Évaluation (Impact × Vraisemblance)
          ↓
Étape 5 — Traitement des risques (accepter / réduire / transférer)
```

### Étape 1 — Identification des actifs

Un **actif** est tout ce qui a de la valeur pour l'entreprise et qui doit être protégé.

Pour Ytech Solutions, nous avons catégorisé les actifs en trois familles :

| Famille | Exemples |
|---|---|
| **Actifs informationnels** | Données clients, données RH, code source, credentials |
| **Actifs logiciels** | App Web Laravel, App CRUD RH, YtechBot, bases de données |
| **Actifs infrastructure** | Serveurs, réseau, firewall, sauvegardes |

### Étape 2 — Identification des menaces

Pour chaque actif, nous avons identifié les **sources de menaces** potentielles et les **vulnérabilités** exploitables. Cette étape est détaillée dans la page [Actifs & Menaces](./actifs-menaces).

### Étape 3 — Scénarios d'attaque

Nous avons construit des **scénarios réalistes** en suivant le raisonnement EBIOS RM : qui attaque, par où, avec quel objectif. Cette étape est détaillée dans la page [Scénarios d'attaque](./scenarios-attaque).

### Étape 4 — Évaluation des risques

Chaque risque identifié est évalué selon deux dimensions :

| Dimension | Échelle | Description |
|---|---|---|
| **Impact** | 1 → 4 | Gravité des conséquences si le risque se réalise |
| **Vraisemblance** | 1 → 4 | Probabilité que le risque se réalise |
| **Criticité** | Impact × Vraisemblance | Score final de priorité |

```
Criticité = Impact × Vraisemblance

Faible    : 1 - 4   → Surveillance
Modérée   : 5 - 8   → Traitement recommandé
Élevée    : 9 - 12  → Traitement prioritaire
Critique  : 13 - 16 → Traitement immédiat
```

### Étape 5 — Traitement des risques

Pour chaque risque évalué, une décision de traitement est prise :

| Décision | Signification | Exemple appliqué |
|---|---|---|
| **Réduire** | Mettre en place une mesure de sécurité | Déployer WAF pour réduire le risque SQLi |
| **Accepter** | Le risque est faible et le coût de traitement trop élevé | Risque de panne matérielle sur simulation |
| **Transférer** | Déléguer le risque (assurance, prestataire) | Non applicable dans ce projet académique |
| **Éviter** | Supprimer l'activité à risque | Ne pas exposer l'app RH sur Internet |

---

## Lien avec les mesures déployées

Chaque mesure de sécurité mise en place dans ce projet est **directement justifiée** par un risque identifié :

| Risque identifié | Mesure déployée | Justification |
|---|---|---|
| Accès non autorisé aux données | Segmentation VLAN + Zero Trust | Limiter la propagation latérale |
| Attaque web (SQLi, XSS) | WAF ModSecurity OWASP CRS | Bloquer les attaques applicatives |
| Compromission des credentials | Bitwarden + bcrypt + fail2ban | Protéger et gérer les mots de passe |
| Intrusion réseau | OPNSense + Suricata IPS | Détecter et bloquer en temps réel |
| Perte de données | Backup 3-2-1 AES-256 | Garantir la continuité |
| Accès interne non contrôlé | Headscale/Tailscale MFA | Zero Trust même en interne |
| Vulnérabilités non détectées | Nessus + Wazuh | Scanner et surveiller en continu |

> 💶 **Dimension financière** : Une violation de données coûte en moyenne **4,45 millions de dollars** selon le rapport IBM Cost of a Data Breach 2023. Pour une PME comme Ytech Solutions, même une fraction de ce montant serait fatale. Chaque mesure déployée représente un investissement de quelques centaines d'euros (open source) pour éviter un risque potentiellement destructeur.

---

## Pourquoi cette approche est crédible pour le jury

- Elle est **structurée** : on ne sécurise pas au hasard, chaque choix est tracé
- Elle est **alignée sur les standards** internationaux (ISO) et nationaux (ANSSI/EBIOS)
- Elle est **proportionnée** : on ne déploie pas un outil sans avoir identifié le risque qu'il couvre
- Elle est **documentée** : chaque risque, chaque mesure, chaque justification est traçable dans cette documentation
