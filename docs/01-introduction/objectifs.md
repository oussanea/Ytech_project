---
id: objectifs
title: Objectifs du projet
sidebar_position: 5
---

# Objectifs du projet

## Objectif global

Démontrer la capacité à concevoir et déployer une **infrastructure réseau d'entreprise sécurisée**, en appliquant des mesures de sécurité réalistes, en s'alignant sur les principes ISO/IEC 27001, et en documentant chaque choix technique.

---

## Objectifs fonctionnels

| # | Objectif | Statut |
|---|---|---|
| 1 | Héberger une application web commerciale accessible publiquement | ✅ Réalisé |
| 2 | Déployer une application CRUD RH interne | ✅ Réalisé |
| 3 | Mettre en place un chatbot IA local (Ollama) | ✅ Réalisé |
| 4 | Assurer la disponibilité via monitoring et supervision | ✅ Réalisé |
| 5 | Sauvegarder les données selon la règle 3-2-1 | ✅ Réalisé |

---

## Objectifs de sécurité

| # | Objectif | Statut |
|---|---|---|
| 1 | Segmenter le réseau par VLAN (7 zones isolées) | ✅ Réalisé |
| 2 | Déployer un firewall dédié avec politique deny-by-default | ✅ OPNSense |
| 3 | Mettre en place un Zero Trust Network Access | ✅ Headscale/Tailscale |
| 4 | Durcir les serveurs (hardening Ubuntu + SSH) | ✅ Réalisé |
| 5 | Protéger l'application web avec un WAF | ✅ ModSecurity OWASP CRS |
| 6 | Détecter les intrusions avec un SIEM | ✅ Wazuh |
| 7 | Scanner les vulnérabilités avant et après | ✅ Nessus |
| 8 | Gérer les mots de passe de manière centralisée | ✅ Bitwarden |
| 9 | Chiffrer les communications (TLS 1.3) | ✅ Réalisé |
| 10 | Chiffrer les sauvegardes (AES-256) | ✅ Réalisé |

---

## Objectifs DevOps

| # | Objectif | Statut |
|---|---|---|
| 1 | Versionner le code sur GitHub avec branches par membre | ✅ Réalisé |
| 2 | Conteneuriser les services avec Docker Compose | ✅ Réalisé |
| 3 | Documenter l'infrastructure avec Docusaurus | ✅ En cours |

---

## Objectifs de test

| # | Objectif | Statut |
|---|---|---|
| 1 | Réaliser un pentest de l'infrastructure initiale | ✅ Réalisé |
| 2 | Réaliser un pentest post-sécurisation | ✅ Réalisé |
| 3 | Produire un rapport comparatif avant/après | ✅ Réalisé |

---

## Ce que ce projet démontre

À l'issue du projet, l'équipe est en mesure de :

- **Concevoir** une architecture réseau sécurisée adaptée aux contraintes d'une PME
- **Déployer** des outils de cybersécurité professionnels (Zabbix, Wazuh, Nessus, OPNSense)
- **Appliquer** les principes Zero Trust, moindre privilège, défense en profondeur
- **Tester** la robustesse d'une infrastructure via un pentest structuré
- **Documenter** et justifier chaque choix technique

:::tip Conformité ISO 27001
L'ensemble du projet respecte les grandes familles de contrôles de la norme ISO/IEC 27001 : contrôle d'accès, cryptographie, sécurité des opérations, gestion des incidents, conformité et continuité d'activité.
:::
