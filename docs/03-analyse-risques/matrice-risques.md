---
id: matrice-risques
title: Matrice des risques
sidebar_position: 5
---

# Matrice des risques

## Qu'est-ce qu'une matrice des risques ?

Une matrice des risques, c'est l'outil qui permet de **prioriser** : on ne peut pas tout traiter en même temps avec des ressources limitées. Il faut donc savoir ce qui est urgent, ce qui peut attendre, et ce qui est négligeable.

Imaginez un médecin aux urgences : il ne soigne pas les patients dans l'ordre d'arrivée, mais en fonction de la **gravité** de leur état et de la **probabilité** que ça empire sans traitement. C'est exactement le raisonnement de la matrice des risques.

Chaque risque est évalué sur deux axes :
- **Impact** (1→4) : à quel point les dégâts seraient graves si ça arrive
- **Vraisemblance** (1→4) : à quel point c'est probable que ça arrive

La **criticité** = Impact × Vraisemblance, sur une échelle de 1 à 16.

---

## Échelle d'évaluation

### Impact

| Niveau | Valeur | Description |
|---|---|---|
| Négligeable | 1 | Perturbation mineure, aucun impact business |
| Limité | 2 | Impact opérationnel localisé, récupération rapide |
| Significatif | 3 | Impact sur l'activité, perte financière notable |
| Critique | 4 | Impact majeur sur l'entreprise, risque de survie |

### Vraisemblance

| Niveau | Valeur | Description |
|---|---|---|
| Improbable | 1 | Rare, nécessite des conditions très particulières |
| Possible | 2 | Peut arriver dans certaines circonstances |
| Probable | 3 | Susceptible d'arriver sans mesure de protection |
| Quasi-certain | 4 | Se produira très probablement sans protection |

### Seuils de criticité

```
Criticité = Impact × Vraisemblance

  1 - 4  → 🟢 Faible    — Surveillance simple
  5 - 8  → 🟡 Modérée   — Traitement recommandé
  9 - 12 → 🟠 Élevée    — Traitement prioritaire
 13 - 16 → 🔴 Critique  — Traitement immédiat obligatoire
```

---

## Matrice visuelle

```
         │  Impact
         │  1 (Négl.) │  2 (Limité) │  3 (Signif.) │  4 (Critique)
─────────┼────────────┼─────────────┼──────────────┼──────────────
Vrais. 4 │  🟡  4     │  🟠   8    │  🔴   12    │  🔴   16
Vrais. 3 │  🟢  3     │  🟡   6    │  🟠    9    │  🔴   12
Vrais. 2 │  🟢  2     │  🟡   4    │  🟡    6    │  🟠    8
Vrais. 1 │  🟢  1     │  🟢   2    │  🟢    3    │  🟡    4
```

---

## Inventaire et évaluation des risques

### Risques AVANT sécurisation

| ID | Risque | Actif concerné | Impact | Vrais. | Criticité | Niveau |
|---|---|---|---|---|---|---|
| R01 | Injection SQL sur app web | `db_clients` | 4 | 4 | **16** | 🔴 Critique |
| R02 | Brute-force SSH port 22 | Serveurs | 4 | 4 | **16** | 🔴 Critique |
| R03 | Ransomware via réseau plat | Toute l'infra | 4 | 4 | **16** | 🔴 Critique |
| R04 | Accès non autorisé app RH | `db_rh` | 4 | 3 | **12** | 🔴 Critique |
| R05 | Fuite credentials en clair | Tous actifs | 4 | 3 | **12** | 🔴 Critique |
| R06 | Absence de backup chiffré | Données | 4 | 3 | **12** | 🔴 Critique |
| R07 | Pas de monitoring — incident non détecté | Tous services | 3 | 4 | **12** | 🔴 Critique |
| R08 | Accès DB depuis n'importe quel poste | `db_clients`, `db_rh` | 4 | 3 | **12** | 🔴 Critique |
| R09 | Attaque XSS sur app web | Utilisateurs | 3 | 3 | **9** | 🟠 Élevé |
| R10 | Panne Internet unique (pas de failover) | App web | 3 | 2 | **6** | 🟡 Modéré |
| R11 | Employé négligent (phishing) | Postes VLAN 40 | 3 | 3 | **9** | 🟠 Élevé |
| R12 | Insider threat — exfiltration données | `db_rh`, code source | 4 | 2 | **8** | 🟡 Modéré |
| R13 | Scan de vulnérabilités non réalisé | Toute l'infra | 3 | 3 | **9** | 🟠 Élevé |
| R14 | Mots de passe faibles / réutilisés | Tous services | 4 | 3 | **12** | 🔴 Critique |
| R15 | Absence de logs centralisés | Forensics | 3 | 4 | **12** | 🔴 Critique |

---

### Risques APRÈS sécurisation

| ID | Risque | Mesure déployée | Impact | Vrais. | Criticité | Niveau |
|---|---|---|---|---|---|---|
| R01 | Injection SQL | WAF ModSecurity OWASP CRS | 4 | 1 | **4** | 🟢 Faible |
| R02 | Brute-force SSH | Port 2222 + clés SSH + fail2ban | 4 | 1 | **4** | 🟢 Faible |
| R03 | Ransomware | VLAN isolation + Backup 3-2-1 AES-256 | 4 | 1 | **4** | 🟢 Faible |
| R04 | Accès non autorisé RH | Zero Trust Headscale + ACL VLAN | 4 | 1 | **4** | 🟢 Faible |
| R05 | Fuite credentials | Bitwarden + bcrypt + MFA | 4 | 1 | **4** | 🟢 Faible |
| R06 | Perte de données | Backup 3-2-1 + Google Drive chiffré | 4 | 1 | **4** | 🟢 Faible |
| R07 | Incident non détecté | Zabbix + Wazuh + Grafana SOC | 3 | 1 | **3** | 🟢 Faible |
| R08 | Accès DB non restreint | MariaDB GRANT par IP + UFW | 4 | 1 | **4** | 🟢 Faible |
| R09 | XSS app web | WAF ModSecurity règle 941xxx | 3 | 1 | **3** | 🟢 Faible |
| R10 | Panne Internet | Failover ISP automatique OPNSense | 3 | 1 | **3** | 🟢 Faible |
| R11 | Phishing employé | VLAN isolation + Zero Trust | 3 | 2 | **6** | 🟡 Modéré |
| R12 | Insider threat | auditd + Wazuh + RBAC | 4 | 1 | **4** | 🟢 Faible |
| R13 | Vulnérabilités non détectées | Nessus scan continu | 3 | 1 | **3** | 🟢 Faible |
| R14 | Mots de passe faibles | Bitwarden centralisé + politique forte | 4 | 1 | **4** | 🟢 Faible |
| R15 | Logs non centralisés | Wazuh SIEM collecte temps réel | 3 | 1 | **3** | 🟢 Faible |

---

## Comparaison avant / après

| ID | Risque | Criticité avant | Criticité après | Réduction |
|---|---|---|---|---|
| R01 | Injection SQL | 🔴 16 | 🟢 4 | **-75%** |
| R02 | Brute-force SSH | 🔴 16 | 🟢 4 | **-75%** |
| R03 | Ransomware | 🔴 16 | 🟢 4 | **-75%** |
| R04 | Accès non autorisé RH | 🔴 12 | 🟢 4 | **-67%** |
| R05 | Fuite credentials | 🔴 12 | 🟢 4 | **-67%** |
| R06 | Perte de données | 🔴 12 | 🟢 4 | **-67%** |
| R07 | Incident non détecté | 🔴 12 | 🟢 3 | **-75%** |
| R08 | Accès DB non restreint | 🔴 12 | 🟢 4 | **-67%** |
| R09 | XSS app web | 🟠 9 | 🟢 3 | **-67%** |
| R10 | Panne Internet | 🟡 6 | 🟢 3 | **-50%** |
| R11 | Phishing employé | 🟠 9 | 🟡 6 | **-33%** |
| R12 | Insider threat | 🟡 8 | 🟢 4 | **-50%** |
| R13 | Vulnérabilités non détectées | 🟠 9 | 🟢 3 | **-67%** |
| R14 | Mots de passe faibles | 🔴 12 | 🟢 4 | **-67%** |
| R15 | Logs non centralisés | 🔴 12 | 🟢 3 | **-75%** |

:::tip Risque résiduel R11 — Phishing
Le risque lié au phishing reste à 🟡 **6/16** après sécurisation. C'est le seul risque qui ne descend pas en zone verte, car il repose sur le **facteur humain** — une segmentation réseau et un Zero Trust réduisent l'impact, mais ne peuvent pas empêcher un employé de cliquer sur un lien malveillant. La solution complémentaire serait une **formation de sensibilisation** régulière des employés.
:::

---

## Risques résiduels acceptés

| ID | Risque résiduel | Justification de l'acceptation |
|---|---|---|
| R11 | Phishing employé (6/16) | Facteur humain irréductible — atténué par isolation VLAN et Zero Trust |

Tous les autres risques sont ramenés en zone **verte (≤ 4/16)**, en dessous du seuil d'acceptabilité défini à **8/16** dans notre méthodologie.

---

## Bilan financier de la réduction des risques

> 💶 **Coût total des mesures déployées** : **0 € en licences** (stack 100% open source)

| Risque traité | Coût potentiel si non traité | Coût de la mesure |
|---|---|---|
| R01 — SQLi / fuite clients | Amende RGPD jusqu'à 20M€ | 0 € (ModSecurity) |
| R02 — Brute-force SSH | Compromission serveurs + restauration ~50k€ | 0 € (fail2ban + config SSH) |
| R03 — Ransomware | Rançon + arrêt activité ~170k€ | 0 € (OPNSense + Backup) |
| R06 — Perte données | Perte totale données métier ~100k€ | 0 € (Backup 3-2-1 + rclone) |
| R07 — Incident non détecté | Détection tardive → dégâts x10 | 0 € (Zabbix + Wazuh) |
| R14 — Mots de passe faibles | Compromission totale ~200k€ | 0 € (Bitwarden) |

**Risque financier total évité : > 540 000 €**
**Investissement en licences : 0 €**

C'est l'argument business fondamental de ce projet : une architecture de sécurité professionnelle, alignée ISO 27001, construite **entièrement sur des outils open source**, offre un **retour sur investissement exceptionnel** même pour une PME sans budget cybersécurité dédié.
