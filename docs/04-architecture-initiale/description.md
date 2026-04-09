---
id: description
title: Description de l'état actuel
sidebar_position: 1
---

### L'Infrastructure Héritée (Legacy)

Avant le lancement du projet de sécurisation, **Ytech Solutions** reposait sur une architecture dite "classique" mais devenue obsolète face aux menaces actuelles. Cette infrastructure était centralisée et minimaliste, privilégiant la facilité d'accès au détriment de la sécurité.

#### 🏗️ Composants Principaux
*   **Accès Internet** : Une seule ligne ISP sans aucune redondance.
*   **Routeur/Firewall basique** : Un simple routeur jouant un rôle de filtrage périmétrique très limité.
*   **Switch Central (Core Switch)** : Un unique switch gérant l'ensemble du trafic sans aucune segmentation.
*   **Un LAN Unique (Réseau Plat)** : Tous les départements (Direction, RH, Finance, Marketing, IT) et tous les serveurs partagent le même espace d'adressage.

#### 🖥️ Centralisation des Services
L'ensemble des services critiques tournait sur un **serveur Linux unique**, créant un point de défaillance unique (SPOF):
*   Serveur Web (Nginx/Apache) hébergeant l'application commerciale.
*   Application CRUD RH interne contenant des données hautement sensibles.
*   Base de données MariaDB centralisant à la fois les données Clients et RH.
*   Serveur de sauvegarde situé sur le même réseau local que les sources .

> 💶 **Analyse de valeur** : Bien que cette infrastructure affiche un coût apparent de **0 €**, son coût réel en cas d'incident est incalculable car elle ne protège aucun des actifs critiques de l'entreprise. Une simple compromission d'un poste de travail permet d'accéder directement à la base de données RH.
