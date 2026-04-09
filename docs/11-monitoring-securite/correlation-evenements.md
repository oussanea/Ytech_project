---
id: correlation-evenements
title: Corrélation des événements
sidebar_position: 5
---

# Corrélation des événements de sécurité

## Qu'est-ce que la corrélation d'événements ?

La corrélation d'événements, c'est l'art de **relier des informations provenant de sources différentes** pour détecter une menace que chaque source, prise isolément, ne verrait pas.

Voici une analogie : imaginons une banque. La caméra de surveillance voit quelqu'un entrer. Le badge d'accès enregistre une ouverture de porte. La caisse enregistre une tentative de transaction refusée. Séparément, rien d'alarmant. Ensemble, c'est peut-être un cambriolage en cours.

C'est exactement ce que fait notre stack de supervision : **Zabbix, Wazuh, Nessus et Headscale** parlent chacun d'une partie de l'infrastructure. Grafana les réunit pour donner une image complète.

---

## Architecture de corrélation

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   ZABBIX    │    │    WAZUH    │    │   NESSUS    │  │  HEADSCALE  │
│             │    │             │    │             │    │             │
│ CPU / RAM   │    │ Logs sécu   │    │ Vulnérabili │    │ Peers VPN   │
│ Services UP │    │ Alertes IDS │    │ tés connues │    │ Connexions  │
│ Réseau      │    │ Intégrité   │    │ CVE actives │    │ actives     │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │
       └──────────────────┴──────────────────┴──────────────────┘
                                    │
                            ┌───────▼────────┐
                            │    GRAFANA     │
                            │  SOC Dashboard │
                            │                │
                            │ Vue unifiée    │
                            │ Corrélation    │
                            │ Alertes        │
                            └────────────────┘
```

---

## Scénarios de corrélation

### Scénario 1 — Détection d'une attaque brute-force en cours

Sans corrélation, chaque outil voit une partie du tableau :

| Outil | Ce qu'il voit seul |
|---|---|
| Zabbix | CPU légèrement élevé sur APP Server |
| Wazuh | 47 tentatives de connexion SSH échouées en 2 min |
| fail2ban | IP `X.X.X.X` bannie sur SSH |
| Headscale | Aucune connexion VPN anormale |

**Avec Grafana** : le panel "Attaques temps réel" affiche simultanément l'alerte Wazuh + la montée CPU Zabbix → **confirmation d'une attaque brute-force active**, avec IP source identifiée, serveur ciblé et timestamp précis.

**Action déclenchée** : vérification du bannissement fail2ban, ajout de l'IP en liste noire OPNSense si récidive.

---

### Scénario 2 — Détection d'une anomalie de comportement

| Outil | Ce qu'il voit seul |
|---|---|
| Zabbix | Pic de trafic réseau sortant inhabituel à 03h00 |
| Wazuh | Accès à `db_rh` depuis APP Server à 03h00 |
| Headscale | Nouvelle connexion VPN non répertoriée |
| Nessus | Vulnérabilité High connue sur APP Server |

**Avec Grafana** : la corrélation temporelle (03h00) de ces 4 événements distincts déclenche une alerte composite — **possible exfiltration de données** via une vulnérabilité exploitée.

**Action déclenchée** : isolation du serveur, analyse forensic des logs Wazuh, vérification de la vulnérabilité Nessus.

---

### Scénario 3 — Surveillance de disponibilité

| Outil | Ce qu'il voit seul |
|---|---|
| Zabbix | Service MariaDB DOWN depuis 2 min |
| Wazuh | Aucune activité suspecte détectée |
| Headscale | DB Server toujours connecté au VPN |
| Nessus | Pas de CVE critique active |

**Avec Grafana** : le panel "État des serveurs" passe en rouge sur DB Server. L'absence d'alerte Wazuh suggère une **panne technique** (non un incident de sécurité). Headscale confirme que le serveur est toujours en ligne.

**Action déclenchée** : restart du container MariaDB via SSH, vérification des logs Docker.

---

## Vue unifiée Grafana

![Grafana — Vue corrélation multi-sources](./img/grafana-correlation.png)
*Dashboard Grafana — corrélation Zabbix + Wazuh + Nessus + Headscale en temps réel*

Le dashboard SOC est organisé pour faciliter la corrélation visuelle :

```
┌────────────────────────────────────────────────────────────┐
│  Security Score [Wazuh]     │  Problèmes actifs [Zabbix]   │
├─────────────────────────────┴──────────────────────────────┤
│  Attaques temps réel [Wazuh] — refresh 5s                  │
│  IP source │ Type │ Sévérité │ Cible │ Timestamp            │
├────────────────────────────────────────────────────────────┤
│  CPU/RAM [Zabbix]           │  Vulnérabilités [Nessus]     │
├─────────────────────────────┴──────────────────────────────┤
│  État serveurs [Zabbix]     │  Peers VPN [Headscale]       │
└────────────────────────────────────────────────────────────┘
```

---

## Valeur ajoutée de la corrélation

| Sans corrélation | Avec corrélation Grafana |
|---|---|
| 4 interfaces à consulter séparément | 1 seul dashboard unifié |
| Détection manuelle des liens entre événements | Corrélation visuelle instantanée |
| Temps de réaction : plusieurs minutes | Temps de réaction : secondes |
| Risque de manquer une attaque multi-vecteurs | Détection des patterns d'attaque complexes |
| Contexte fragmenté | Contexte complet (infrastructure + sécurité + VPN) |

> 💶 **Dimension financière** : La corrélation d'événements est l'une des fonctionnalités clés d'un SOC professionnel. Un analyste SOC externe facture entre **50 € et 150 €/heure**. Notre Grafana SOC Dashboard remplace une partie de ce travail d'analyse en automatisant la corrélation et la visualisation — permettant à une équipe IT réduite (3 personnes chez Ytech) de maintenir une visibilité de niveau enterprise sans budget dédié.

---

## Limites et perspectives

| Limite actuelle | Solution en production |
|---|---|
| Corrélation visuelle manuelle | SOAR (Security Orchestration, Automation and Response) |
| Pas d'alerting email/SMS | Intégration Grafana Alerting + PagerDuty |
| Logs conservés 7 jours | Rétention longue durée (SIEM cloud ou stockage dédié) |
| Pas de threat intelligence | Intégration feeds MISP ou OpenCTI |

:::tip Évolution naturelle
L'architecture actuelle (Zabbix + Wazuh + Nessus + Grafana) est la **base standard** d'un SOC d'entreprise. En production, on y ajouterait un SOAR pour automatiser les réponses aux incidents, transformant ce dashboard de visualisation en véritable plateforme de réponse automatisée.
:::
