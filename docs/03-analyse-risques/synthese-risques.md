---
id: synthese-risques
title: Synthèse de la Gestion des Risques
sidebar_position: 7
---

### Synthèse de la Gestion des Risques

Cette section présente le bilan global de la stratégie de cybersécurité de **Ytech Solutions**. L'objectif est de démontrer comment l'architecture cible transforme une infrastructure initialement vulnérable en un environnement résilient et conforme aux standards professionnels.

---

#### 📊 Bilan de la Réduction de Criticité
Avant l'intervention, l'infrastructure de Ytech Solutions présentait **11 risques critiques** (score ≥ 12/16), notamment en raison d'un réseau plat et d'une absence de supervision [3]. Grâce au déploiement de la défense en profondeur, la criticité moyenne a été réduite de **68%**.

| Indicateur | État Initial (Vulnerable) | État Final (Sécurisé) | Évolution |
| :--- | :---: | :---: | :---: |
| **Risques Critiques (12-16)** | 11 | 0 | -100% |
| **Risques Élevés (8-9)** | 3 | 0 | -100% |
| **Risques Modérés/Faibles** | 1 | 15 | +1400% |
| **Score de criticité moyen** | **12.5 / 16** | **3.9 / 16** | **-68%** |

> 🛡️ **Note technique :** Les vecteurs d'attaque les plus dangereux (Injection SQL, Ransomware, Brute-force SSH) ont vu leur vraisemblance chuter de 4/4 à 1/4 grâce aux contre-mesures techniques comme le WAF ModSecurity et le durcissement SSH.

---

#### 💰 Bilan Financier et ROI de la Sécurité
L'approche de Ytech Solutions prouve que la sécurité est un investissement rentable. En utilisant une stack **100% Open Source**, l'entreprise réalise une économie annuelle de **34 892 €** par rapport à des solutions propriétaires équivalentes.

*   **Investissement en licences :** 0 € .
*   **Risque financier total évité :** **> 540 000 €**.

| Risque Majeur Neutralisé | Impact Financier Évité | Solution Déployée |
| :--- | :--- | :--- |
| **Ransomware** | ~170 000 € | Segmentation VLAN + Backup 3-2-1 |
| **Violation de données (RGPD)** | Jusqu'à 20M € (ou 4% CA) | WAF + Chiffrement AES-256 |
| **Compromission des accès** | ~200 000 € | Zero Trust + Bitwarden |

---

#### ⚠️ Analyse du Risque Résiduel : Le Phishing
Le risque **R11 (Phishing employé)** est le seul à demeurer en zone modérée (**6/16**) après sécurisation. 

*   **Pourquoi ?** Il repose sur le **facteur humain**, qui reste le maillon le plus imprévisible de la chaîne de sécurité [17, 18]. 
*   **Atténuation :** Si l'isolation VLAN et le Zero Trust limitent la propagation d'une infection, seule une **formation de sensibilisation** régulière permet de réduire davantage cette menace.

---

#### ✅ Conclusion sur la Posture de Sécurité
L'architecture finale validée par le SOC Dashboard (Grafana) garantit le respect de la triade **CIA** (Confidentialité, Intégrité, Disponibilité)  :

1.  **Confidentialité :** Assurée par le chiffrement TLS 1.3, le Zero Trust (Headscale) et la segmentation en 7 VLANs .
2.  **Intégrité :** Garantie par la centralisation des logs dans Wazuh SIEM et les contrôles d'accès RBAC.
3.  **Disponibilité :** Maintenue via le failover ISP sur OPNsense, le monitoring Zabbix et la stratégie de sauvegarde 3-2-1.

**Ytech Solutions dispose désormais d'une infrastructure robuste, alignée sur la norme ISO/IEC 27001, capable de protéger ses actifs critiques contre les menaces modernes pour un coût logiciel nul .**
