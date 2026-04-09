---
id: presentation-entreprise
title: Présentation de l'entreprise
sidebar_position: 2
---

# Présentation de l'entreprise

## Ytech Solutions

**Ytech Solutions** est une entreprise fictive spécialisée dans les **services numériques et le développement web**. Elle propose des packs de développement web (sites vitrines, e-commerce, maintenance, hébergement) à destination des PME.

| Attribut | Valeur |
|---|---|
| **Nom** | Ytech Solutions |
| **Secteur** | Services numériques & développement web |
| **Effectif** | 24 employés |
| **Clients** | PME (Petites et Moyennes Entreprises) |
| **Données traitées** | Données clients, RH, financières, code source |

---

## Organisation interne

L'entreprise est organisée en **6 départements** :

| Département | Effectif | Rôle principal |
|---|---|---|
| Direction Générale | 1 | Pilotage stratégique |
| Informatique (IT) | 3 | Administration systèmes et réseaux |
| Développement | 6 | Développement et maintenance applicative |
| Ressources Humaines | 3 | Gestion du personnel |
| Finance / Comptabilité | 3 | Gestion financière et facturation |
| Commercial & Marketing | 8 | Gestion clients et activités commerciales |

---

## Matrice des accès par rôle

Chaque rôle dispose d'un niveau d'accès défini selon le **principe du moindre privilège** :

| Rôle | Accès SSH Linux | App Web | App CRUD RH | Doc Technique |
|---|---|---|---|---|
| Directeur Général | ✗ | ✅ | ✅ Lecture seule | ✗ |
| Administrateurs IT | ✅ SSH | ✅ | ✅ Complet | ✅ Par IP |
| Développeurs | ✗ | ✅ | ✗ | ✅ Limité |
| Ressources Humaines | ✗ | ✅ | ✅ Sans suppression | ✗ |
| Comptabilité | ✗ | ✅ | ✗ | ✗ |
| Commercial / Marketing | ✗ | ✅ | ✗ | ✗ |

---

## Enjeux de sécurité

La croissance de l'activité commerciale a engendré une augmentation des exigences en matière de sécurité, notamment en raison de :

- La **sensibilité des données** manipulées (clients, RH, finances, code source)
- L'**augmentation du nombre de clients** et de la surface d'exposition
- L'absence de **segmentation réseau** dans l'infrastructure initiale
- Le besoin de **conformité aux bonnes pratiques ISO 27001**

C'est dans ce contexte que la direction a décidé de revoir entièrement son infrastructure informatique.
