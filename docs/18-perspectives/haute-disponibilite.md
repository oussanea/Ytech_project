---
id: haute-disponibilite
sidebar_label: Haute Disponibilité
sidebar_position: 19.4
description: Architecture HA, redondance serveurs, MariaDB Galera Cluster et SLA cibles pour Ytech Solutions.
---

# 🔁 Haute Disponibilité

> Architecture cible pour un déploiement en production réelle avec redondance complète.

---

## Architecture cible HA

### Redondance des serveurs

```
Actuel (simulation)          Cible (production HA)
────────────────────         ─────────────────────────
1x APP Server                2x APP Server (Active/Active)
1x DB Server                 2x DB Server (MariaDB Galera Cluster)
1x Monitoring                2x Monitoring (Zabbix Proxy)
1x Backup                    3x Backup (3-2-1 étendu)
1x OPNSense                  2x OPNSense (CARP failover)
```

---

## MariaDB Galera Cluster

```sql
-- Cluster multi-maître avec réplication synchrone
-- Minimum 3 nœuds pour éviter split-brain
-- wsrep_cluster_address = gcomm://node1,node2,node3
```

---

## Load Balancing

```nginx
# HAProxy ou Nginx upstream pour les applications web
upstream ytech_app {
    least_conn;
    server 192.168.20.10:8443 weight=5;
    server 192.168.20.11:8443 weight=5;
    server 192.168.20.12:8443 backup;
}
```

---

## Failover ISP (déjà configuré dans OPNSense)

```
ISP1 Principal → Eth6 (actif)
ISP2 Backup    → Eth6 (standby)

Basculement automatique si ISP1 down :
→ OPNSense détecte la perte de route
→ Bascule vers ISP2 en < 30 secondes
→ Notification Grafana
```

---

## Métriques de disponibilité cibles

| Service | SLA actuel (simulation) | SLA cible (production) |
|---|---|---|
| App Web | ~95% | 99.9% |
| DB Server | ~90% | 99.99% |
| Monitoring | ~85% | 99.5% |
| Backup | 100% (cron 2h) | 100% (temps réel) |
| VPN Headscale | ~95% | 99.9% |

---

## Évolutions technologiques envisagées

| Évolution | Technologie | Justification |
|---|---|---|
| Migration cloud hybride | AWS/Azure + VPN site-to-site | Scalabilité + redondance géographique |
| Kubernetes | K3s léger | Orchestration des conteneurs Docker |
| PKI interne | Step-CA | Remplacement des certificats auto-signés |
| LDAP/AD | FreeIPA | Centralisation de l'authentification |
| EDR | Wazuh + YARA rules | Détection de malware avancée |
| Modèle IA amélioré | Llama 3.1 8B (si GPU) | Meilleures réponses YtechBot |
| SOAR | Shuffle (open source) | Automatisation de la réponse aux incidents |
