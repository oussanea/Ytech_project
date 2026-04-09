# Analyse Financière — Ytech Solutions
## Infrastructure Réseau Sécurisée

---

## Préambule

Cette analyse financière s'inscrit dans une démarche rigoureuse de justification des choix architecturaux. En tant qu'équipe ayant conçu et proposé cette architecture sécurisée, nous avons l'obligation de démontrer sa viabilité économique face aux alternatives existantes. L'objectif est de prouver que la sécurité n'est pas un coût, mais un investissement rentable, dont l'absence représente un risque financier bien supérieur.

---

## 1. Analyse de l'Infrastructure Initiale

### 1.1 Description de l'infrastructure existante

Avant notre intervention, Ytech Solutions disposait d'une infrastructure minimale et non sécurisée :

| Composant | État initial | Coût estimé |
|-----------|-------------|-------------|
| Réseau plat sans segmentation | 1 seul réseau pour tous | 0 € (existant) |
| Pas de firewall dédié | Routeur FAI basique | 0 € |
| Pas de monitoring | Aucune visibilité | 0 € |
| Pas de backup structuré | Copies manuelles irrégulières | 0 € |
| Pas de VPN | Accès direct non sécurisé | 0 € |
| Applications non chiffrées | HTTP sans TLS | 0 € |

**Coût apparent : 0 €**
**Coût réel des risques : incalculable**

### 1.2 Faiblesses financières de l'infrastructure initiale

L'absence d'investissement en sécurité crée des risques financiers directs :

| Risque | Impact financier estimé |
|--------|------------------------|
| Violation de données (24 employés + clients) | 50 000 € – 500 000 € |
| Amende RGPD (violation données personnelles) | Jusqu'à 4% du CA annuel |
| Ransomware (chiffrement données) | 10 000 € – 100 000 € |
| Interruption de service (downtime) | 5 000 € / heure |
| Atteinte à la réputation | Perte clients : 20–40% CA |
| Coût de remédiation post-incident | 50 000 € – 200 000 € |

> **Conclusion** : Une infrastructure à coût zéro expose l'entreprise à des pertes potentielles de plusieurs centaines de milliers d'euros. L'investissement en sécurité est donc non seulement justifié, mais financièrement impératif.

---

## 2. Analyse des Coûts — Architecture Proposée

### 2.1 Choix stratégique : Solutions Open Source

Notre équipe a fait le choix délibéré de construire l'architecture entièrement sur des **solutions open source gratuites**. Ce choix n'est pas un compromis — c'est une décision technique et économique argumentée.

#### Justification du choix Open Source

Les solutions open source sélectionnées sont utilisées par des entreprises du CAC 40, des banques et des institutions gouvernementales mondiales. Leur maturité, leur communauté active et leur niveau de sécurité sont comparables, voire supérieurs, aux solutions propriétaires équivalentes.

---

### 2.2 Comparaison Détaillée : Open Source vs Propriétaire

#### Firewall — OPNsense vs Alternatives

| Solution | Type | Coût annuel | Fonctionnalités |
|----------|------|-------------|-----------------|
| **OPNsense** ✅ | Open Source | **0 €** | Firewall, IDS/IPS, VPN, NAT, Failover |
| Cisco ASA | Propriétaire | 8 000 – 25 000 € | Firewall, VPN |
| Fortinet FortiGate | Propriétaire | 5 000 – 15 000 € | Firewall, IDS/IPS, VPN |
| Palo Alto Networks | Propriétaire | 10 000 – 30 000 € | NGFW complet |
| pfSense Plus | Commercial | 500 – 2 000 € | Firewall, VPN |

**Économie réalisée avec OPNsense : 5 000 – 30 000 € / an**

**Argument technique** : OPNsense est basé sur FreeBSD, intègre Suricata (IDS/IPS de niveau entreprise), supporte WireGuard, et dispose d'une interface web complète. Il est utilisé par des milliers d'entreprises en production.

---

#### Monitoring réseau — Zabbix vs Alternatives

| Solution | Type | Coût annuel | Capacité |
|----------|------|-------------|----------|
| **Zabbix** ✅ | Open Source | **0 €** | Illimité |
| Datadog | SaaS | 15 € / host / mois | Per host |
| New Relic | SaaS | 25 € / host / mois | Per host |
| PRTG Network Monitor | Propriétaire | 1 800 – 12 000 € | Limité par sondes |
| SolarWinds | Propriétaire | 3 000 – 10 000 € | Variable |
| Nagios XI | Commercial | 2 000 – 5 000 € | Variable |

**Pour 5 serveurs surveillés :**
- Datadog : 75 € / mois = **900 € / an**
- New Relic : 125 € / mois = **1 500 € / an**
- PRTG : **1 800 € / an minimum**
- **Zabbix : 0 €**

**Économie réalisée avec Zabbix : 900 – 10 000 € / an**

---

#### SIEM — Wazuh vs Alternatives

| Solution | Type | Coût annuel |
|----------|------|-------------|
| **Wazuh** ✅ | Open Source | **0 €** |
| Splunk Enterprise | Propriétaire | 10 000 – 150 000 € |
| IBM QRadar | Propriétaire | 15 000 – 80 000 € |
| Microsoft Sentinel | SaaS | 2,46 € / Go de données |
| Elastic SIEM | Commercial | 5 000 – 30 000 € |
| LogRhythm | Propriétaire | 20 000 – 50 000 € |

**Économie réalisée avec Wazuh : 10 000 – 150 000 € / an**

**Argument technique** : Wazuh est utilisé par plus de 20 millions d'utilisateurs dans le monde. Il intègre la détection d'intrusion, l'analyse de logs, la conformité RGPD/PCI-DSS et la réponse aux incidents.

---

#### Scanner de vulnérabilités — Nessus Essentials vs Alternatives

| Solution | Type | Coût annuel |
|----------|------|-------------|
| **Nessus Essentials** ✅ | Gratuit (≤16 IPs) | **0 €** |
| Nessus Professional | Commercial | 3 500 – 5 000 € |
| Qualys VMDR | SaaS | 5 000 – 20 000 € |
| Rapid7 InsightVM | SaaS | 4 000 – 15 000 € |
| Tenable.io | SaaS | 5 000 – 25 000 € |

**Économie réalisée avec Nessus Essentials : 3 500 – 25 000 € / an**

**Justification** : Nessus Essentials couvre 16 IPs, ce qui correspond exactement à notre infrastructure de simulation (5 serveurs + postes admin). Pour une PME de 24 employés, c'est suffisant en phase initiale.

---

#### Gestionnaire de mots de passe — Bitwarden vs Alternatives

| Solution | Type | Coût annuel (24 utilisateurs) |
|----------|------|-------------------------------|
| **Bitwarden (Vaultwarden)** ✅ | Open Source Self-hosted | **0 €** |
| Bitwarden Teams | SaaS | 3 € / utilisateur / mois = **864 € / an** |
| 1Password Business | SaaS | 8 € / utilisateur / mois = **2 304 € / an** |
| LastPass Teams | SaaS | 4 € / utilisateur / mois = **1 152 € / an** |
| Dashlane Business | SaaS | 8 € / utilisateur / mois = **2 304 € / an** |

**Économie réalisée avec Vaultwarden : 864 – 2 304 € / an**

**Argument** : Vaultwarden est une implémentation compatible Bitwarden, self-hosted, qui offre exactement les mêmes fonctionnalités que Bitwarden Teams mais sans frais de licence.

---

#### Zero Trust / VPN — Headscale + Tailscale vs Alternatives

| Solution | Type | Coût annuel |
|----------|------|-------------|
| **Headscale + Tailscale** ✅ | Open Source | **0 €** |
| Tailscale Business | SaaS | 6 € / utilisateur / mois = **1 728 € / an** |
| Cloudflare Zero Trust | SaaS | 7 € / utilisateur / mois = **2 016 € / an** |
| Zscaler Private Access | SaaS | 15 000 – 50 000 € / an |
| Cisco Zero Trust | Propriétaire | 20 000 – 60 000 € / an |
| Palo Alto Prisma Access | Propriétaire | 25 000 – 80 000 € / an |

**Économie réalisée avec Headscale : 1 728 – 80 000 € / an**

---

#### Dashboard SOC — Grafana vs Alternatives

| Solution | Type | Coût annuel |
|----------|------|-------------|
| **Grafana Open Source** ✅ | Open Source | **0 €** |
| Grafana Cloud | SaaS | 8 € / utilisateur / mois |
| Splunk Dashboard | Propriétaire | Inclus Splunk = 10 000 €+ |
| IBM Security QRadar Dashboard | Propriétaire | 15 000 €+ |
| Elastic Kibana | SaaS | 3 000 – 10 000 € / an |

**Économie réalisée avec Grafana : 0 – 15 000 € / an**

---

#### Backup — Script + rclone + Google Drive vs Alternatives

| Solution | Type | Coût annuel |
|----------|------|-------------|
| **Script bash + rclone + Google Drive** ✅ | Open Source + Gratuit | **0 €** |
| Veeam Backup | Commercial | 500 – 5 000 € |
| Acronis Cyber Backup | Commercial | 800 – 3 000 € |
| AWS Backup | SaaS | Variable selon volume |
| Azure Backup | SaaS | Variable selon volume |

**Économie réalisée : 500 – 5 000 € / an**

---

#### WAF — ModSecurity vs Alternatives

| Solution | Type | Coût annuel |
|----------|------|-------------|
| **ModSecurity + OWASP CRS** ✅ | Open Source | **0 €** |
| Cloudflare WAF | SaaS | 200 – 2 000 € / an |
| AWS WAF | SaaS | 600 – 5 000 € / an |
| Imperva WAF | Propriétaire | 5 000 – 20 000 € / an |
| F5 BIG-IP ASM | Propriétaire | 15 000 – 50 000 € / an |

**Économie réalisée avec ModSecurity : 200 – 50 000 € / an**

---

### 2.3 Coûts Infrastructure Matérielle

#### Scénario Simulation (VirtualBox — Projet académique)

| Composant | Coût |
|-----------|------|
| VirtualBox | 0 € (gratuit) |
| PCs étudiants (existants) | 0 € |
| Réseau WiFi école | 0 € |
| **Total infrastructure** | **0 €** |

#### Scénario Production Réelle (PME 24 employés)

| Composant | Quantité | Coût unitaire | Coût total |
|-----------|----------|---------------|------------|
| Serveur Dell PowerEdge R350 (APP + DB) | 2 | 2 500 € | 5 000 € |
| Serveur Dell PowerEdge R250 (Monitoring) | 1 | 1 800 € | 1 800 € |
| Serveur NAS Synology DS923+ (Backup) | 1 | 600 € | 600 € |
| Switch Cisco Catalyst 2960 | 1 | 800 € | 800 € |
| Routeur/Firewall (PC mini pour OPNsense) | 1 | 400 € | 400 € |
| Câblage réseau + baie | 1 | 500 € | 500 € |
| **Total matériel** | | | **9 100 €** |

---

## 3. Tableau Comparatif Global

### Solution Propriétaire vs Notre Solution Open Source

| Composant | Solution propriétaire | Coût annuel propriétaire | Notre solution | Coût annuel |
|-----------|----------------------|--------------------------|----------------|-------------|
| Firewall | Fortinet FortiGate | 8 000 € | OPNsense | 0 € |
| Monitoring | Datadog (5 hosts) | 900 € | Zabbix | 0 € |
| SIEM | Splunk | 15 000 € | Wazuh | 0 € |
| Scanner vulnérabilités | Nessus Pro | 4 000 € | Nessus Essentials | 0 € |
| Gestionnaire MDP | 1Password (24u) | 2 304 € | Vaultwarden | 0 € |
| Zero Trust VPN | Tailscale Business | 1 728 € | Headscale | 0 € |
| SOC Dashboard | Grafana Cloud | 960 € | Grafana Open Source | 0 € |
| Backup | Veeam | 1 500 € | Script + rclone | 0 € |
| WAF | Cloudflare WAF | 500 € | ModSecurity | 0 € |
| **TOTAL LOGICIELS** | | **34 892 € / an** | | **0 € / an** |

**Économie annuelle sur les logiciels : 34 892 €**

---

## 4. Analyse du Retour sur Investissement (ROI)

### 4.1 Investissement total

| Poste | Coût |
|-------|------|
| Logiciels (open source) | 0 € |
| Matériel serveurs (production) | 9 100 € |
| Temps de déploiement (5 × 3 semaines) | 0 € (projet académique) |
| Formation équipe | 0 € (projet académique) |
| **Investissement total** | **9 100 €** |

### 4.2 Économies générées

| Source d'économie | Montant annuel |
|-------------------|---------------|
| Logiciels open source vs propriétaire | 34 892 € |
| Évitement incidents sécurité (probabilité 30%) | 15 000 – 50 000 € |
| Conformité RGPD (évitement amendes) | 10 000 – 50 000 € |
| Réduction downtime | 5 000 – 20 000 € |
| **Total économies annuelles** | **64 892 – 154 892 €** |

### 4.3 Calcul ROI

```
ROI = (Gains - Investissement) / Investissement × 100

ROI minimum = (64 892 - 9 100) / 9 100 × 100 = 613%
ROI maximum = (154 892 - 9 100) / 9 100 × 100 = 1 602%
```

**Période de retour sur investissement : moins de 2 mois**

---

## 5. Analyse des Coûts par Bénéfice de Sécurité

### 5.1 Segmentation VLAN — Impact financier

La segmentation en 7 VLANs permet de **contenir les incidents** et d'éviter la propagation latérale :

| Scénario sans VLAN | Coût incident |
|--------------------|--------------|
| Ransomware se propage sur tout le réseau | 50 000 – 200 000 € |
| Violation complète de toutes les données | 100 000 – 500 000 € |

| Scénario avec VLAN | Coût incident |
|--------------------|--------------|
| Ransomware limité à 1 VLAN | 5 000 – 20 000 € |
| Violation limitée à 1 base de données | 10 000 – 50 000 € |

**Réduction de coût d'incident : 80 – 90%**

---

### 5.2 Backup 3-2-1 — Impact financier

| Scénario | Sans backup | Avec backup 3-2-1 |
|----------|-------------|-------------------|
| Perte données suite ransomware | 50 000 – 200 000 € | 0 € (restauration) |
| Défaillance matérielle | 20 000 – 50 000 € | 0 € (restauration) |
| Erreur humaine | 10 000 – 30 000 € | 0 € (restauration) |

**Coût du backup : 0 € (rclone + Google Drive gratuit)**
**Coût évité : jusqu'à 200 000 €**

---

### 5.3 Zero Trust (Headscale) — Impact financier

Sans Zero Trust, un compte compromis donne accès à tous les systèmes :

| Risque | Coût sans ZT | Coût avec ZT |
|--------|-------------|-------------|
| Compte admin compromis | Accès total = 200 000 €+ | Accès limité = 5 000 € |
| Credential stuffing | Accès multiple = 50 000 € | Bloqué par MFA = 0 € |

---

## 6. Coût de la Non-Conformité RGPD

Ytech Solutions traite des données personnelles (24 employés + données clients). La non-conformité RGPD expose à :

| Type d'amende | Montant |
|---------------|---------|
| Amende standard | Jusqu'à 10 M€ ou 2% du CA |
| Amende grave | Jusqu'à 20 M€ ou 4% du CA |
| Amende CNIL France (moyenne PME) | 50 000 – 500 000 € |

### Notre architecture assure la conformité RGPD via :

| Exigence RGPD | Notre solution | Coût |
|---------------|----------------|------|
| Chiffrement des données | AES-256 (backups) + TLS 1.3 | 0 € |
| Contrôle d'accès | Bitwarden + Zero Trust | 0 € |
| Traçabilité | Wazuh + Zabbix logs | 0 € |
| Notification incidents | Wazuh alertes temps réel | 0 € |
| Droit à l'oubli (soft delete) | Implémenté dans chatbot | 0 € |

**Économie sur risque RGPD : 50 000 – 500 000 €**

---

## 7. Comparaison avec Externalisation (Cloud)

Certaines entreprises choisissent d'externaliser totalement leur infrastructure. Voici la comparaison :

### Infrastructure Ytech sur AWS/Azure vs Notre Solution

| Composant | AWS/Azure / an | Notre Solution / an |
|-----------|----------------|---------------------|
| 3 serveurs EC2 (t3.medium) | 3 600 € | 0 € (VMs locales) |
| WAF managé | 600 € | 0 € (ModSecurity) |
| SIEM managé | 12 000 € | 0 € (Wazuh) |
| Backup S3 | 120 € | 0 € (Google Drive) |
| VPN managé | 1 200 € | 0 € (Headscale) |
| Monitoring cloud | 900 € | 0 € (Zabbix) |
| **Total cloud** | **18 420 € / an** | **0 € / an** |

**Économie vs Cloud : 18 420 € / an**

---

## 8. Synthèse Financière

### Récapitulatif des économies

| Catégorie | Économie annuelle |
|-----------|------------------|
| Logiciels open source vs propriétaire | 34 892 € |
| Vs solution Cloud | 18 420 € |
| Évitement incidents sécurité | 15 000 – 200 000 € |
| Conformité RGPD | 50 000 – 500 000 € |
| **Total économies potentielles** | **118 312 – 753 312 € / an** |

### Investissement vs Économies

| | Simulation (académique) | Production (PME) |
|--|------------------------|-----------------|
| **Investissement** | 0 € | 9 100 € |
| **Économies annuelles** | 34 892 € (logiciels seuls) | 118 312 €+ |
| **ROI** | ∞ | 613 – 1 602% |
| **Payback period** | Immédiat | < 2 mois |

---

## 9. Argumentation des Choix Technologiques

### Pourquoi Open Source et non Propriétaire ?

**Argument 1 — Maturité technique**
Les solutions choisies (OPNsense, Zabbix, Wazuh, Grafana) sont toutes utilisées en production par des milliers d'entreprises mondiales, y compris des institutions financières et gouvernementales. Leur maturité est prouvée.

**Argument 2 — Communauté et support**
Une communauté active garantit des mises à jour de sécurité régulières, souvent plus rapides que les éditeurs propriétaires. Les CVE (vulnérabilités) sont corrigées en jours, pas en semaines.

**Argument 3 — Transparence du code**
Le code source ouvert permet l'audit de sécurité indépendant. Un logiciel propriétaire peut contenir des backdoors ou des vulnérabilités non divulguées.

**Argument 4 — Pas de vendor lock-in**
Avec des solutions open source, Ytech n'est pas prisonnier d'un éditeur qui peut augmenter ses tarifs ou arrêter son produit.

**Argument 5 — Personnalisation**
Les solutions open source peuvent être adaptées aux besoins spécifiques de Ytech, ce qu'une solution SaaS ne permet pas.

---

## 10. Conclusion Financière

L'architecture proposée pour Ytech Solutions représente une approche **financièrement optimale** :

1. **Coût logiciel nul** grâce à des solutions open source de niveau entreprise
2. **ROI exceptionnel** supérieur à 600% dès la première année
3. **Protection financière** contre des incidents pouvant coûter 50 000 à 500 000 €
4. **Conformité RGPD** sans coût supplémentaire, évitant des amendes potentielles
5. **Évolutivité** sans coût de licence supplémentaire lors de la croissance

> L'investissement en cybersécurité n'est pas une dépense — c'est une assurance dont la prime est nulle et la couverture est maximale.

La comparaison avec les solutions propriétaires équivalentes démontre une économie annuelle de **34 892 € minimum** sur les seuls logiciels, à laquelle s'ajoute la protection contre des pertes potentielles de **plusieurs centaines de milliers d'euros**.

**Notre choix architectural est donc non seulement techniquement justifié, mais économiquement optimal pour une PME de la taille de Ytech Solutions.**
