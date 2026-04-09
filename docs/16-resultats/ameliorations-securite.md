---
id: ameliorations-securite
sidebar_label: Améliorations de Sécurité
sidebar_position: 17.1
description: Score de sécurité avant/après et conformité ISO 27001 de l'infrastructure Ytech Solutions.
---

# 🔐 Améliorations de Sécurité

> Comparaison des niveaux de sécurité avant et après déploiement de l'infrastructure sécurisée Ytech Solutions.

---

## Score de sécurité — Avant / Après

| Critère | Avant (architecture initiale) | Après (architecture cible) | Gain |
|---|---|---|---|
| Segmentation réseau | ❌ Réseau plat | ✅ 7 VLANs isolés | +++ |
| Chiffrement des données | ❌ HTTP non chiffré | ✅ TLS 1.3 + AES-256 | +++ |
| Authentification | ❌ Mots de passe simples | ✅ bcrypt + MFA Bitwarden | +++ |
| Surveillance réseau | ❌ Aucune | ✅ Zabbix + Wazuh + Grafana | +++ |
| Accès distant | ❌ SSH direct exposé | ✅ Zero Trust (Headscale) | +++ |
| Gestion des vulnérabilités | ❌ Aucun scan | ✅ Nessus + Suricata | +++ |
| Sauvegarde | ❌ Pas de backup | ✅ 3-2-1 chiffré AES-256 | +++ |
| Firewall | ❌ Aucun | ✅ OPNSense + UFW + Cisco ACL | +++ |
| Protection web | ❌ Nginx basique | ✅ ModSecurity WAF (OWASP CRS) | +++ |

---

## Conformité ISO 27001 atteinte

```
Contrôle A.8  — Gestion des actifs          ✅ Inventaire complet (Zabbix)
Contrôle A.9  — Contrôle d'accès            ✅ RBAC + Bitwarden + Headscale
Contrôle A.10 — Cryptographie               ✅ AES-256 + TLS 1.3
Contrôle A.12 — Sécurité des opérations     ✅ Monitoring + Logs + Backup
Contrôle A.13 — Sécurité des communications ✅ VLANs + WireGuard + Firewall
Contrôle A.14 — Développement sécurisé      ✅ WAF + HTTPS + bcrypt
Contrôle A.16 — Gestion des incidents       ✅ Wazuh SIEM + alertes Grafana
Contrôle A.17 — Continuité d'activité       ✅ Backup 3-2-1 + failover ISP
```
