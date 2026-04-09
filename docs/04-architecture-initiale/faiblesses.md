---
id: faiblesses
title: Faiblesses identifiées
sidebar_position: 3
---

### Audit des vulnérabilités (État Initial)

L'analyse de l'infrastructure héritée de **Ytech Solutions** a révélé des lacunes critiques qui exposent directement la survie économique de l'entreprise. L'absence totale de segmentation et de supervision transformait chaque service en une porte d'entrée potentielle pour un attaquant.

#### 🛠️ Inventaire des failles techniques
Le tableau suivant récapitule les vulnérabilités majeures identifiées lors de l'audit initial :

| Vulnérabilité | Actifs exposés | Impact (CIA) | Risque associé |
| :--- | :--- | :--- | :--- |
| **Réseau plat** | Tous les serveurs | C, I, D | Propagation latérale immédiate d'un ransomware. |
| **Absence de WAF** | App Web, DB Clients | C, I | Vol de données via Injection SQL ou XSS. |
| **SSH sur Port 22** | Serveurs Linux | C, I, D | Brute-force automatisé massif et continu. |
| **Pas de Monitoring** | Infrastructure complète | D | Incidents non détectés pendant plusieurs jours. |
| **Backup non chiffré** | Données critiques | C | Vol de données lors de l'externalisation. |
| **Mots de passe faibles** | Credentials | C, I, D | Compromission totale des accès par simple dictionnaire. |

#### 🔴 Focus : L'accessibilité de la Base de Données
Une faiblesse majeure résidait dans la configuration de **MariaDB**. Dans l'architecture initiale, le serveur de base de données acceptait des connexions depuis n'importe quel poste du LAN unique [4, 6]. Cette "confiance implicite" permettait à un employé malveillant ou à un poste compromis d'exfiltrer les données RH et clients sans rencontrer d'obstacle réseau.

#### 💶 Le Coût Réel de l'Inaction
Bien que cette infrastructure affichait un coût de licence de **0 €**, l'analyse financière démontre que le coût des risques était, lui, incalculable. En cas d'attaque, les pertes potentielles pour Ytech Solutions auraient été dévastatrices :

*   **Ransomware** : Entre 10 000 € et 100 000 € de rançon et frais de restauration.
*   **Interruption de service** : Une perte estimée à **5 000 € par heure** de downtime.
*   **Amendes RGPD** : Jusqu'à **4% du chiffre d'affaires annuel** pour non-protection des données sensibles.
*   **Total des risques accumulés** : Une exposition financière dépassant les **540 000 €**.

**Conclusion de l'audit** : L'infrastructure initiale ne représentait pas une économie, mais une dette de sécurité insoutenable pour une PME en croissance.
