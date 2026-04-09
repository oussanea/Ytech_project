---
id: contraintes
title: Contraintes
sidebar_position: 4
---

# Contraintes

## Vue d'ensemble

Les contraintes regroupent l'ensemble des **limites imposées** au projet — qu'elles soient techniques, organisationnelles, temporelles ou budgétaires. Elles ont directement influencé les choix d'architecture et les compromis réalisés.

---

## CT-01 — Contraintes techniques

### Environnement de simulation

L'infrastructure réelle aurait nécessité du matériel dédié (serveurs physiques, switches managés, routeurs). Dans le cadre académique, tout est simulé sur **VirtualBox** :

| Contrainte | Impact | Contournement |
|---|---|---|
| Pas de switch physique 802.1Q | VLANs simulés uniquement dans Cisco/OPNSense | Simulation Cisco + trunking OPNSense |
| Pas de réseau isolé dédié | VMs en bridge sur le réseau WiFi de classe | Adressage bridge cohérent entre membres |
| Ressources limitées (RAM/CPU PC) | Impossible de faire tourner toutes les VMs sur un seul PC | Répartition des VMs sur les PCs des membres |
| IPs dynamiques (DHCP WiFi) | IPs bridge peuvent changer selon le réseau | Utilisation prioritaire des IPs Host-Only pour la comm interne |

### Interconnexion multi-PC

Les VMs de membres différents communiquent via le **réseau bridge** (WiFi de classe). Cette topologie impose :

- Que tous les PCs soient sur le **même sous-réseau** simultanément
- Que les tests réseau inter-membres nécessitent une **présence physique simultanée**
- Que les IPs bridge soient documentées et vérifiées avant chaque session de travail

:::warning Limite critique
En cas d'absence d'un membre ou de changement de réseau, les services hébergés sur sa machine sont **inaccessibles**. Ce risque a été atténué par la documentation exhaustive des configs et la containerisation Docker.
:::

### Certificats SSL

Les certificats utilisés sont **auto-signés** (non reconnus par les navigateurs). Les avertissements SSL sont attendus et normaux dans ce contexte de simulation.

---

## CT-02 — Contraintes organisationnelles

### Travail en équipe distribuée

Le projet implique 5 membres travaillant sur des machines séparées, ce qui a imposé :

| Défi | Solution adoptée |
|---|---|
| Coordination des configs réseau | Tableau partagé des IPs + réunions de synchronisation |
| Intégration des services cross-membres | Agents Wazuh et Tailscale déployés sur toutes les VMs |
| Accès aux dashboards centraux | Grafana agrège les données de toutes les VMs via bridge |
| Versioning du code | GitHub multi-branches, une branche par membre |

### Répartition des responsabilités

Chaque membre est **propriétaire** de ses VMs et services. En cas de problème sur une VM, seul son propriétaire peut intervenir directement. Cette contrainte a imposé une **documentation détaillée** de chaque configuration pour permettre la reproduction par un autre membre si nécessaire.

---

## CT-03 — Contraintes temporelles

Le projet s'est déroulé sur **5 semaines** découpées en 3 sprints :

```
Sprint 1 (Semaine 1-2) — Fondations
Sprint 2 (Semaine 3-4) — Sécurisation
Sprint 3 (Semaine 5)   — Pentest + Livraison
```

| Contrainte | Impact |
|---|---|
| 5 semaines au total | Priorisation des livrables obligatoires |
| Présentation jury en S5 | Documentation et démos doivent être prêtes |
| Pentest en Sprint 3 | Les vulnérabilités doivent être corrigées avant la présentation |
| Docusaurus en parallèle | Rédaction progressive tout au long du projet |

---

## CT-04 — Contraintes de ressources

### Matériel

| Ressource | Disponibilité | Contrainte |
|---|---|---|
| Serveurs physiques | ✗ Aucun | Simulation VirtualBox obligatoire |
| Switches managés | ✗ Aucun | Simulation Cisco + OPNSense |
| Réseau isolé | ✗ Aucun | Bridge WiFi de classe |
| IPs publiques | ✗ Aucune | Pas de tests depuis Internet réel |

### Budget

| Outil | Licence | Coût |
|---|---|---|
| Nessus Essentials | Gratuit (limité à 16 IPs) | 0 € |
| Vaultwarden | Open source | 0 € |
| Zabbix | Open source | 0 € |
| Wazuh | Open source | 0 € |
| Grafana | Open source | 0 € |
| OPNSense | Open source | 0 € |
| Headscale | Open source | 0 € |
| Ollama | Open source | 0 € |
| VirtualBox | Gratuit | 0 € |

:::tip Choix open source
L'ensemble de la stack technique est **100% open source et gratuit**, ce qui correspond à une contrainte budgétaire académique tout en restant représentatif d'une infrastructure d'entreprise réelle.
:::

---

## CT-05 — Contraintes de sécurité imposées

Le cahier des charges impose l'utilisation **obligatoire** des outils suivants, sans possibilité de substitution :

| Catégorie | Outil obligatoire | Outil retenu |
|---|---|---|
| Scanner de vulnérabilités | Nessus Essentials | ✅ Nessus Essentials |
| Monitoring | Zabbix ou Nagios | ✅ Zabbix |
| Gestionnaire de mots de passe | Bitwarden ou Passbolt | ✅ Bitwarden (Vaultwarden) |
| IA locale | Ollama | ✅ Ollama + llama3.2:1b |
| Zero Trust | Twingate ou Netbird | ✅ Headscale + Tailscale |
| Firewall dédié | OPNSense, PfSense ou Palo Alto | ✅ OPNSense |
| Gestion de projet | Jira ou Plane.so | ✅ Jira |
| Documentation | Docusaurus | ✅ Docusaurus |

---

## CT-06 — Contraintes de conformité

| Norme / Standard | Exigence | Statut |
|---|---|---|
| ISO/IEC 27001 | Alignement sur les contrôles de sécurité | ✅ Appliqué |
| OWASP Top 10 | Protection applicative WAF | ✅ ModSecurity CRS |
| Règle 3-2-1 | Stratégie de sauvegarde | ✅ Appliquée |
| Principe moindre privilège | Accès restreints par rôle | ✅ Appliqué |
| Défense en profondeur | Couches de sécurité multiples | ✅ Appliqué |

---

## Synthèse des écarts par rapport à un environnement de production

| Élément | Simulation (projet) | Production réelle |
|---|---|---|
| Réseau | Bridge WiFi + VirtualBox | VLANs physiques, switches dédiés |
| Firewall | VM OPNSense | Appliance physique dédiée |
| Certificats SSL | Auto-signés | Let's Encrypt ou PKI interne |
| IPs | Privées (RFC 1918) | IPs publiques routables |
| Redondance | Failover logiciel | HA physique (clustering) |
| Nessus | Essentials (16 IPs max) | Pro ou Expert (illimité) |
| Accès Internet | Non exposé réellement | Exposition contrôlée en DMZ réelle |

Ces écarts sont documentés en détail dans la section [Limites de la simulation](/limites/limites-simulation).