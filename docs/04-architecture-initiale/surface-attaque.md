---
id: surface-attaque
title: Analyse de la Surface d'Attaque Initiale
sidebar_position: 4
---

### Cartographie de l'Exposition

La **surface d'attaque** de l'infrastructure héritée de Ytech Solutions représente l'intégralité des points d'entrée et des vecteurs exploitables par une source de menace pour compromettre nos actifs critiques. Dans le modèle de "réseau plat" initial, cette surface est maximale car aucune barrière interne ne vient freiner la progression d'un attaquant.

#### 🎯 Vecteurs d'Entrée et Points de Terminaison
L'analyse technique identifie trois vecteurs majeurs d'exposition :

1.  **Vecteur Web Public (DMZ inexistante)** : 
    *   L'application commerciale Laravel est exposée directement sur Internet sans **WAF (Web Application Firewall)**.
    *   Un attaquant opportuniste (*Script Kiddie*) peut utiliser des scanners automatisés pour exploiter des failles de type **Injection SQL** ou **XSS**, accédant ainsi directement à la base `db_clients`.
2.  **Vecteur Humain et Interne (Réseau Plat)** : 
    *   Le **Phishing** est la menace la plus probable. Sans segmentation, un employé du département Marketing (VLAN 40) qui clique sur un lien malveillant permet au malware de "voir" et d'attaquer les serveurs RH et de Base de Données (VLAN 20/25) sans aucune restriction.
3.  **Vecteur d'Administration (Shadow IT)** : 
    *   L'utilisation du **port SSH standard (22)** sur l'unique serveur Linux expose l'infrastructure à des attaques de force brute incessantes.
    *   L'absence de gestionnaire de mots de passe centralisé favorise l'usage de credentials faibles ou réutilisés, augmentant le risque de compromission totale.

#### 📊 Évaluation de la Triade CIA (État Initial)
Le niveau de protection initial, évalué selon les piliers de la sécurité de l'information, est jugé **alarmant**:

| Pilier | Score (1-4) | Constat Critique |
| :--- | :---: | :--- |
| **Confidentialité** | 🔴 1/4 | Accès possible aux bases `db_rh` et `db_clients` depuis n'importe quel poste du LAN. |
| **Intégrité** | 🔴 1/4 | Absence de logs centralisés (Wazuh) ; un attaquant peut modifier les salaires ou le code source sans laisser de traces. |
| **Disponibilité** | 🔴 2/4 | Point de défaillance unique (SPOF). Une panne du serveur unique ou une attaque DDoS paralyse 100% de l'activité. |

#### 📈 Métriques du Risque et Impact Financier
Selon notre **Matrice des Risques**, l'infrastructure affiche des indicateurs de criticité extrêmes avant toute mesure de remédiation :

*   **Risques Critiques (Score 12-16)** : **11 scénarios sur 15** (Injection SQL, Ransomware, Brute-force SSH, etc.).
*   **Criticité Moyenne** : **12.5 / 16**, signifiant qu'une compromission majeure est jugée "quasi-certaine" à court terme.
*   **Exposition Financière Totale** : Le cumul des risques non traités (amendes RGPD, rançons, perte d'activité) dépasse les **540 000 €**.

> 🛡️ **Conclusion de l'Analyse** : Cette surface d'attaque n'est pas seulement une faiblesse technique ; c'est un risque de faillite pour Ytech Solutions. La transformation vers l'architecture cible vise à ramener ce score de criticité en dessous de **4/16** pour la quasi-totalité des vecteurs.
