---
sidebar_position: 2
title: 📑 Executive Summary
---

# Executive Summary

:::info Vue d'ensemble du projet
Le présent projet s'inscrit dans le cadre de la transformation digitale et sécuritaire de **Ytech Solutions**, une entreprise spécialisée dans les services numériques et le développement web. Face à une croissance commerciale soutenue et à une sensibilité accrue des données manipulées (données clients, ressources humaines, informations financières et code source), l'entreprise se trouve confrontée à la nécessité impérieuse de revoir intégralement son infrastructure informatique.
:::

## ⚠️ Problématique Identifiée
L'infrastructure actuelle de **Ytech Solutions** repose sur une architecture simple et centralisée (LAN unique), inadaptée aux enjeux de sécurité contemporains. 

* **Segmentation nulle :** Le serveur Linux héberge à la fois l'application commerciale et l'application RH sur le même réseau.
* **Risques majeurs :** L'augmentation du volume de clients expose l'entreprise à des risques critiques en matière de **confidentialité**, **d'intégrité** et **de disponibilité**.

## 🎯 Objectif Principal
Concevoir et déployer une **infrastructure réseau sécurisée, fiable et évolutive**, capable de supporter la croissance de l'entreprise tout en garantissant la protection des actifs informationnels critiques, le tout conforme à la norme **ISO/IEC 27001**.

## 🚀 Résultats Attendus
Le projet vise à atteindre trois objectifs stratégiques majeurs :

1.  **Sécurisation des communications web :** Implémentation du protocole HTTPS (Apache/Nginx) avec durcissement TLS et redirection HTTP → HTTPS.
2.  **Segmentation réseau :** Mise en place de **VLANs** et d'une **DMZ** pour isoler les services publics des ressources internes comme l'application CRUD RH.
3.  **Pratiques DevOps modernes :** Gestion sécurisée du code source via GitHub ou GitLab, incluant le versioning et l'intégration continue.

## 📋 Périmètre et Livrables
* Analyse approfondie de l'infrastructure existante et identification des failles.
* Simulation d'une architecture améliorée via **GNS3 ou Packet Tracer**.
* Réalisation d'un **Test d'Intrusion (Pentest)** avec rapport comparatif "Avant / Après"
* Documentation technique complète sous **Docusaurus**.

:::tip Contraintes et Limites
* **Effectif concerné :** 24 employés[cite: 10].
* **Délai d'exécution :** 1 mois (Soumission le 3 Avril 2026).
* **Priorité :** Sécurisation de l'accès aux données RH et hardening des services.
:::