---
id: conclusion-generale
title: 18. Conclusion
sidebar_label: Conclusion
sidebar_position: 1
---

# 🏁 Conclusion Générale

---

## Bilan du projet

Le projet **Ytech Solutions — Infrastructure Réseau Sécurisée** représente l'aboutissement de trois sprints de travail intensif, menés par une équipe de cinq membres dans le cadre de **JobInTech Casablanca 2025**.

Partant d'une architecture initiale sans protection — réseau plat, services non chiffrés, aucun monitoring — nous avons conçu et déployé une infrastructure complète répondant aux standards de l'industrie en matière de cybersécurité.

---

## Ce que nous avons construit

L'infrastructure Ytech est aujourd'hui composée de :

- **7 VLANs segmentés** (DMZ, App, DB, MGMT, Users, Admin, Backup)
- **Double firewall** (OPNSense externe + Cisco ACL inter-VLAN)
- **Stack de monitoring complète** (Zabbix + Wazuh SIEM + Nessus + Grafana SOC)
- **Zero Trust Network Access** via Headscale/Tailscale (7 nodes connectés)
- **IA locale sécurisée** (YtechBot — Ollama llama3.2, sans dépendance cloud)
- **Gestion des identités** (Bitwarden, bcrypt, fail2ban)
- **Backup résilient 3-2-1** avec chiffrement AES-256 et stockage cloud
- **Protection applicative** (WAF ModSecurity OWASP CRS sur Laravel)
- **Applications métier** (CRUD RH, App Web, Chatbot IA)

---

## Ce que nous avons appris

Ce projet nous a permis de dépasser la théorie pour confronter chaque décision d'architecture à une réalité pratique : configurer un VLAN, c'est aussi gérer les ruptures de connectivité inattendues ; déployer Wazuh, c'est comprendre Elasticsearch en profondeur ; faire tourner Ollama sur une VM limitée, c'est optimiser chaque ressource.

Nous avons également appris à travailler en équipe sur une infrastructure distribuée — chaque VM appartenant à un PC différent — en coordonnant les accès, les configurations réseau et les tests via Git, Headscale et des sessions de travail collaboratif.

---

## Conformité et niveau de maturité

À l'issue du projet, l'infrastructure Ytech atteint un niveau de maturité correspondant aux exigences fondamentales de la norme **ISO 27001**, avec une couverture complète des domaines : contrôle d'accès, cryptographie, sécurité des communications, monitoring, gestion des incidents et continuité d'activité.

---

## Mot de fin

> *"La sécurité n'est pas un produit, c'est un processus."*
> — Bruce Schneier

Ce projet n'est pas une fin en soi. Il pose les fondations d'une démarche de sécurité continue. Les perspectives identifiées — automatisation CI/CD, haute disponibilité, pentest formel — constituent la prochaine étape naturelle pour une équipe désormais formée aux enjeux réels de la cybersécurité d'entreprise.

---

**Équipe Ytech Solutions — Groupe 5**

| Membre | Rôle principal |
|---|---|
| Raja JARFANI | Chatbot IA + Monitoring + DevOps |
| Asmaa | Hardening + OPNSense + Sécurité |
| Sara | App CRUD RH + Nessus + Headscale |
| Meryem | App Web + Wazuh + Backup |
| Chaima | GNS3 + Grafana Dashboard |

*JobInTech Casablanca 2025 — Projet Final Cybersécurité*
