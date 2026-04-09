---
id: limites-simulation
title: Limites de la simulation 
sidebar_label: Limites de la simulation 
sidebar_position: 1
---

# ⚠️ Limites du Projet

> Cette section documente les contraintes techniques et les écarts entre notre environnement de simulation et un déploiement en production réel.

---

## 16.1 Limites de la Simulation

### Vue d'ensemble

Le projet Ytech Solutions a été entièrement simulé dans un environnement virtualisé à des fins pédagogiques dans le cadre de **JobInTech Casablanca 2025**. Cette approche, bien que fonctionnelle pour valider les concepts, présente plusieurs limites inhérentes.

### Ressources matérielles limitées

| Contrainte | Impact | Workaround appliqué |
|---|---|---|
| RAM partagée entre VMs | Performance dégradée lors des tests de charge | Allocation dynamique de mémoire |
| CPU limité (pas de GPU) | Ollama/llama3.2:1b lent (~10 tokens/s) | Modèle 1B paramètres (le plus léger) |
| Disque SSD personnel | Pas de RAID, pas de redondance réelle | Backup externe + Google Drive |
| Réseau WiFi école | Latence variable, pas de QoS | Tests en réseau Host-Only isolé |

### Limites des outils de simulation réseau

- **GNS3 / Packet Tracer** : simulateurs réseau sans trafic réel — les tests de performance ne reflètent pas un switch physique Cisco
- **VLANs simulés** : les règles inter-VLAN sont logiques, non enforced par un équipement physique
- **Suricata IDS/IPS** : fonctionne mais ne peut pas capturer du trafic réseau physique réel depuis OPNSense simulé

---
