---
sidebar_label: 'Phase 5 & 6 : Analyse des Risques E-commerce'
sidebar_position: 5
---

# Phase 5 & 6 : Analyse des Risques et Impact Business

Cette section évalue les conséquences des vulnérabilités identifiées sur la plateforme e-commerce de **Ytech Solutions**. L'objectif est de quantifier le risque pour les clients et la réputation de l'entreprise.

---

## Section 5 : Identification et Classification des Actifs

Dans un contexte E-commerce, les actifs informationnels sont classés selon leur criticité pour la transaction et la vie privée.

### 5.1 Typologie des Actifs
* **Données Clients (Sensibles) :** Noms, adresses de livraison, numéros de téléphone et historiques de commandes. (Soumis à la **Loi 09-08**).
* **Données Transactionnelles :** Détails des paniers, factures et preuves de paiement.
* **Disponibilité du Service :** La capacité de la plateforme à rester en ligne pour générer du chiffre d'affaires.

### 5.2 Cartographie des Vulnérabilités par Actif
| Actif | Vulnérabilité associée | Impact Business | Criticité |
| :--- | :--- | :--- | :--- |
| **Base de données Clients** | Exposition Port 3306 | Fuite massive de données clients. | **CRITIQUE** |
| **Paiement / Panier** | Absence Anti-CSRF | Commandes forcées ou détournement. | **MOYENNE** |
| **Sessions Clients** | Cookies sans HttpOnly | Vol de comptes clients (Session Hijacking).| **MOYENNE** |

---

## Section 6 : Évaluation CVSS v3.1 et Matrice des Risques

### 6.1 Analyse CVSS (Focus : Base de données)
**V01 : Exposition Publique MySQL (Port 3306)**
* **Vecteur :** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
* **Score Final : 9.8 (CRITIQUE)**
* **Justification :** Un attaquant peut extraire toute la table `users` contenant les informations des clients sans aucune authentification préalable.

### 6.2 Matrice de Risque E-commerce
| Probabilité \ Impact | Négligeable | Faible | Moyen | Élevé | Critique |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **5 - Très Élevée** | | | | | **V01 (DB)** |
| **4 - Élevée** | | | | **V03 (SSL)** | |
| **3 - Moyenne** | | | **V02 (CSRF)** | | |

---

## Section 7 : Impact Métier et Conformité (Loi 09-08)

### 7.1 Impact sur la Confiance Client
Le succès d'une plateforme e-commerce repose sur la confiance. L'utilisation d'un **certificat auto-signé** (détecté via SSLScan) affiche une alerte de sécurité aux clients, ce qui provoque un taux d'abandon de panier massif et une dégradation de l'image de marque de **Ytech Solutions**.

### 7.2 Conformité Réglementaire (CNDP)
Le stockage de données de milliers de citoyens (clients) sans protection adéquate (Firewalling MySQL absent) est une violation grave de la **Loi 09-08**. 
* **Risque :** En cas de fuite, la CNDP peut ordonner l'arrêt immédiat du site web et infliger des amendes lourdes.

---

:::danger Conclusion du Risque
La plateforme e-commerce présente un niveau de risque **Inacceptable**. La priorité absolue est d'isoler la base de données du réseau public et de sécuriser les sessions clients pour éviter toute fraude ou vol d'identité.
:::