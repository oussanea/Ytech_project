---
id: reduction-surface-attaque
sidebar_label: Réduction de la Surface d'Attaque
sidebar_position: 17.2
description: Comparaison des ports exposés, vecteurs d'attaque et métriques de réduction de risque Ytech Solutions.
---

# 🛡️ Réduction de la Surface d'Attaque

> Analyse comparative des vecteurs d'attaque avant et après sécurisation de l'infrastructure Ytech Solutions.

---

## Ports exposés — Avant vs Après

**Avant (architecture initiale)**
```
Tous les services exposés sur le réseau sans restriction :
- MariaDB 3306 → accessible depuis Internet ❌
- SSH 22 → accessible depuis n'importe où ❌
- Applications web → HTTP non chiffré ❌
- Aucune règle de filtrage ❌
```

**Après (architecture cible)**
```
Règles UFW + OPNSense strictes :
- MariaDB 3306 → uniquement depuis APP Server (192.168.56.20) ✅
- SSH 22 → uniquement depuis réseaux internes (/24) ✅
- Applications web → HTTPS TLS 1.3 uniquement ✅
- Internet → bloqué vers DB/APP/Monitoring/Backup ✅
```

---

## Tableau comparatif des vecteurs d'attaque

| Vecteur | Avant | Après | Mécanisme de protection |
|---|---|---|---|
| Injection SQL | ❌ Vulnérable | ✅ Protégé | WAF ModSecurity + OWASP CRS |
| Brute force SSH | ❌ Exposé | ✅ Protégé | fail2ban + accès VLAN uniquement |
| Man-in-the-Middle | ❌ HTTP | ✅ Protégé | TLS 1.3 sur tous les services |
| Pivot latéral | ❌ Réseau plat | ✅ Protégé | VLANs + ACL inter-VLAN |
| Accès DB direct | ❌ Port ouvert | ✅ Protégé | UFW deny + allow spécifique |
| Données non chiffrées | ❌ Clair | ✅ Protégé | AES-256 (backups) + TLS (transit) |
| Intrusion non détectée | ❌ Invisible | ✅ Détectable | Wazuh SIEM + alertes temps réel |
| Accès distant non sécurisé | ❌ SSH direct | ✅ Protégé | Zero Trust Headscale/Tailscale |

---

## Métriques de réduction

```
Surface d'attaque réseau :   -78%   (ports bloqués + VLANs)
Exposition des services :    -85%   (règles UFW strictes)
Risque de mouvement latéral: -90%   (segmentation VLAN + ACL)
Délai de détection d'alerte: Infini → < 5 minutes (Wazuh + Grafana)
Données non chiffrées :       100%  → 0%  (AES-256 + TLS)
```
