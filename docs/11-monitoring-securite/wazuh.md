---
id: wazuh
title: Wazuh — SIEM
sidebar_position: 2
---

# Wazuh — SIEM & Détection d'intrusions

:::caution Page en cours de rédaction
Cette section est rédigée par **Meryem** — responsable du déploiement Wazuh SIEM.
:::

## Informations techniques de référence

Pour la coordination avec les autres services, voici les paramètres Wazuh utilisés dans l'infrastructure :

| Attribut | Valeur |
|---|---|
| **IP** | `192.168.9.152` |
| **VM** | PC Meryem |
| **Elasticsearch** | Port `9200` |
| **API Wazuh** | Port `55000` |
| **Dashboard** | Port `443` |

### Intégration Grafana

Les données Wazuh sont remontées dans le Grafana SOC Dashboard :

```
Source     : Wazuh Elasticsearch
URL        : https://192.168.9.152:9200
Auth       : admin / wbUdIoo.T32ZivW89G4EHhu8XxYUIecP
Index      : wazuh-alerts-*
```

### Agents déployés

| Serveur | Agent Wazuh | Statut |
|---|---|---|
| APP Server (VM1) | ✅ Installé | Actif |
| DB Server (VM2) | ✅ Installé | Actif |
| Web Server (Meryem) | ✅ Installé | Actif |

---

*Section à compléter par Meryem avec : présentation Wazuh, déploiement Docker, dashboard screenshots, règles de détection, alertes configurées.*
