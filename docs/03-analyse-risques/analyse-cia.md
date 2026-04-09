---
id: analyse-cia
title: Analyse CIA
sidebar_position: 4
---

# Analyse CIA — Confidentialité, Intégrité, Disponibilité

## Qu'est-ce que la triade CIA ?

La **triade CIA** est le fondement de toute démarche de sécurité de l'information. Elle définit les trois propriétés essentielles que tout système d'information doit garantir :

Imaginez un coffre-fort dans une banque :
- **Confidentialité** → seules les personnes autorisées peuvent l'ouvrir
- **Intégrité** → le contenu n'a pas été modifié à l'insu de personne
- **Disponibilité** → le coffre s'ouvre quand on en a besoin, pas seulement quand ça arrange le fabricant

Pour Ytech Solutions, qui gère des données sensibles pour le compte de PME clientes, **les trois propriétés sont également critiques**. Une défaillance sur l'une d'elles peut avoir des conséquences financières et juridiques graves.

---

## C — Confidentialité

> *"Seules les personnes autorisées accèdent aux informations dont elles ont besoin."*

La confidentialité garantit que les données ne sont pas divulguées à des tiers non autorisés — qu'il s'agisse d'attaquants externes, d'employés non habilités, ou d'accidents de configuration.

### Actifs à protéger en priorité

| Actif | Niveau de confidentialité requis | Raison |
|---|---|---|
| Base `db_rh` (salaires, contrats) | 🔴 Maximum | RGPD — données personnelles sensibles |
| Base `db_clients` (commandes, contacts) | 🔴 Maximum | RGPD — données clients tiers |
| Code source applications | 🔴 Maximum | Propriété intellectuelle, avantage concurrentiel |
| Credentials (SSH, BDD, API) | 🔴 Maximum | Compromission = accès total |
| Configurations serveurs | 🟡 Élevé | Cartographie de l'infrastructure |
| Logs systèmes | 🟡 Élevé | Contiennent des informations techniques sensibles |

### Mesures déployées pour la confidentialité

| Menace | Mesure | Composant |
|---|---|---|
| Interception réseau | Chiffrement TLS 1.3 sur toutes les interfaces | Nginx + Streamlit + HTTPS |
| Accès non autorisé aux données | Segmentation VLAN stricte | OPNSense + Cisco ACL |
| Accès non autorisé aux services | Zero Trust avec MFA | Headscale/Tailscale |
| Credentials exposés | Coffre centralisé chiffré | Bitwarden (Vaultwarden) |
| Accès DB non autorisé | Un utilisateur MariaDB par app, accès par IP | MariaDB GRANT restrictif |
| Fuite via sauvegarde | Chiffrement AES-256 des archives | Backup Server + openssl |

> 💶 **Dimension financière** : Une violation de confidentialité sur les données RH ou clients expose Ytech Solutions à des amendes RGPD pouvant atteindre **4% du chiffre d'affaires annuel** ou **20 millions d'euros**. S'y ajoutent les dommages et intérêts réclamés par les clients victimes, pouvant dépasser la valeur de l'entreprise elle-même.

---

## I — Intégrité

> *"Les informations sont exactes, complètes et n'ont pas été modifiées de manière non autorisée."*

L'intégrité garantit que les données n'ont pas été altérées — ni par un attaquant, ni par une erreur système, ni par une manipulation interne non autorisée. C'est particulièrement critique pour Ytech Solutions dont les clients font confiance à l'exactitude des données traitées.

### Actifs à protéger en priorité

| Actif | Risque d'atteinte à l'intégrité | Impact |
|---|---|---|
| Base `db_rh` | Modification salaires, contrats | Litige social, erreurs de paie |
| Base `db_clients` | Modification commandes, prix | Fraude, litige commercial |
| Code source | Injection de backdoor | Compromission des clients finaux |
| Configurations firewall | Modification des règles ACL | Ouverture de brèches réseau |
| Logs d'audit | Suppression de traces | Impossibilité de forensics |

### Mesures déployées pour l'intégrité

| Menace | Mesure | Composant |
|---|---|---|
| Modification non autorisée des données | Droits SQL minimaux par utilisateur | MariaDB GRANT SELECT/INSERT/UPDATE |
| Altération des logs | Logs centralisés hors serveur source | Wazuh SIEM (collecte externe) |
| Modification de configs | Surveillance des fichiers critiques | auditd (`-w /etc/passwd -p wa`) |
| Injection de code | WAF + revue de code | ModSecurity + GitHub |
| Falsification des sauvegardes | Chiffrement + intégrité AES-256 | openssl enc + backup.key |
| Accès DB direct non tracé | Logs MariaDB + Wazuh agent | Wazuh agent sur DB Server |

:::note Intégrité des logs
Les logs stockés sur le serveur source peuvent être effacés par un attaquant ayant compromis ce serveur. C'est pourquoi Wazuh centralise les logs **en temps réel** vers un serveur distinct (VLAN 30). Même si un serveur est compromis, les traces restent intactes.
:::

---

## A — Disponibilité

> *"Les services et données sont accessibles quand les utilisateurs autorisés en ont besoin."*

La disponibilité garantit que l'infrastructure fonctionne de manière continue et que les pannes sont minimisées. Pour Ytech Solutions, une indisponibilité de l'application web commerciale signifie des clients qui ne peuvent pas commander — une perte de revenus directe.

### Services et leurs exigences de disponibilité

| Service | Disponibilité requise | Impact d'une indisponibilité |
|---|---|---|
| App Web commerciale | 🔴 99%+ | Perte de chiffre d'affaires direct |
| App CRUD RH | 🟡 Heures ouvrées | Blocage du département RH |
| YtechBot | 🟡 Heures ouvrées | Perte de productivité interne |
| MariaDB | 🔴 99%+ | Arrêt de tous les services |
| Monitoring (Zabbix) | 🟡 Continue | Perte de visibilité sur les incidents |
| Backup | 🟢 Quotidien | Risque de perte de données |

### Mesures déployées pour la disponibilité

| Menace | Mesure | Composant |
|---|---|---|
| Panne Internet | Double connexion ISP avec failover automatique | OPNSense Gateway Group |
| Attaque DDoS | Suricata IPS + filtrage WAN | OPNSense + Suricata |
| Panne service Docker | Redémarrage automatique | `restart: always` Docker Compose |
| Perte de données | Backup quotidien 3-2-1 | Backup Server + Google Drive |
| Panne non détectée | Monitoring continu + alertes | Zabbix + Grafana |
| Surcharge serveur | Surveillance CPU/RAM en temps réel | Zabbix agents |

> 💶 **Dimension financière** : Une heure d'indisponibilité de l'application web commerciale représente pour Ytech Solutions une perte directe de chiffre d'affaires, mais aussi un **coût indirect** : perte de confiance des visiteurs, impact sur le référencement, image de marque dégradée. Pour une PME du numérique, la disponibilité n'est pas un luxe — c'est une **condition de survie commerciale**. Le déploiement du failover ISP et du monitoring Zabbix représente un investissement quasi nul (open source) pour une garantie de continuité d'activité qui, chez un prestataire externe, coûterait plusieurs milliers d'euros par an.

---

## Analyse CIA par actif critique

Le tableau suivant synthétise le niveau de protection CIA appliqué à chaque actif critique de Ytech Solutions :

| Actif | Confidentialité | Intégrité | Disponibilité | Score global |
|---|---|---|---|---|
| Base `db_clients` | 🔴 Critique | 🔴 Critique | 🔴 Critique | ⚠️ Maximum |
| Base `db_rh` | 🔴 Critique | 🔴 Critique | 🟡 Élevé | ⚠️ Maximum |
| App Web Laravel | 🟡 Élevé | 🟡 Élevé | 🔴 Critique | ⚠️ Élevé |
| App CRUD RH | 🔴 Critique | 🔴 Critique | 🟡 Élevé | ⚠️ Maximum |
| Code source | 🔴 Critique | 🔴 Critique | 🟢 Modéré | ⚠️ Élevé |
| Credentials (Bitwarden) | 🔴 Critique | 🔴 Critique | 🟡 Élevé | ⚠️ Maximum |
| Backup Server | 🟡 Élevé | 🔴 Critique | 🔴 Critique | ⚠️ Élevé |
| OPNSense Firewall | 🟡 Élevé | 🔴 Critique | 🔴 Critique | ⚠️ Élevé |

---

## Impact d'une défaillance CIA sur l'activité

| Scénario de défaillance | C | I | D | Conséquences |
|---|---|---|---|---|
| Fuite base clients | ✗ | ✅ | ✅ | Amende RGPD + perte clients |
| Modification salaires en BDD | ✅ | ✗ | ✅ | Litige social + fraude |
| App web hors ligne 24h | ✅ | ✅ | ✗ | Perte CA + image dégradée |
| Compromission credentials | ✗ | ✗ | ✗ | Catastrophe totale |
| Suppression des backups | ✅ | ✅ | ✗ | Données irrécupérables après incident |

:::danger Compromission des credentials
La compromission du coffre Bitwarden est le scénario le plus grave — elle affecte simultanément les **trois dimensions CIA**. C'est pourquoi Bitwarden est hébergé dans le VLAN 30 isolé, accessible uniquement depuis l'intérieur, et protégé par un master password fort.
:::

---

## Lien CIA → Architecture déployée

Chaque choix d'architecture répond directement à un besoin CIA identifié :

| Choix architectural | Propriété CIA protégée | Justification |
|---|---|---|
| Segmentation 7 VLANs | **C** + **I** | Empêche la propagation et l'accès non autorisé |
| OPNSense deny-by-default | **C** + **D** | Bloque les accès non autorisés et les attaques DDoS |
| WAF ModSecurity | **C** + **I** | Bloque SQLi (vol) et altération de données |
| Headscale/Tailscale Zero Trust | **C** | Garantit que seuls les utilisateurs légitimes accèdent aux ressources |
| Wazuh SIEM | **I** + **D** | Détecte les modifications non autorisées et les pannes |
| Backup 3-2-1 AES-256 | **D** + **C** | Garantit la restauration et la confidentialité des sauvegardes |
| Zabbix + Grafana | **D** | Détecte et anticipe les problèmes de disponibilité |
| Bitwarden | **C** | Centralise et protège tous les credentials |
| Double ISP failover | **D** | Garantit la continuité d'accès Internet |
| TLS 1.3 | **C** + **I** | Chiffre et authentifie toutes les communications |
