---
id: tracabilite-logs
title: Traçabilité des accès
sidebar_label: "📋 Traçabilité"
sidebar_position: 7
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

# 📋 Traçabilité des accès

## Objectif

La traçabilité garantit que **chaque accès à l'infrastructure est enregistré et consultable**. Elle est indispensable pour la détection d'incidents, l'audit de sécurité et la réponse aux incidents.

## Sources de logs dans l'infrastructure Y-Tech

| Source | Type de logs | Localisation | Rétention |
|--------|-------------|--------------|-----------|
| **OPNsense Firewall** | Connexions acceptées/bloquées | Interface web + syslog | Configuration |
| **Suricata IDS** | Alertes d'intrusion, scans | `Services → IDS → Alerts` | 4 fichiers (rotation hebdo) |
| **Bastion SSH** | Connexions SSH (auth.log) | `/var/log/auth.log` sur bastion | Selon politique système |
| **WireGuard** | Sessions VPN | `VPN → WireGuard → Log File` | OPNsense |

## Logs OPNsense — Firewall

**Chemin :** `Firewall → Log Files`

OPNsense enregistre toutes les décisions de filtrage. Chaque entrée contient :

```
Timestamp | Interface | Action | Source IP:Port | Dest IP:Port | Protocol
```

### Exemple de lecture des logs firewall

```
Apr 08 13:05:22  LAN   PASS   192.168.1.14:54201  192.168.10.5:8834  TCP
Apr 08 13:05:44  LAN   BLOCK  192.168.40.5:51432  192.168.10.2:3306  TCP
Apr 08 13:06:01  WAN   PASS   192.168.9.50:51820  (WireGuard UDP)    UDP
```

- Ligne 1 : KALI_ADMIN accède à Nessus → autorisé (règle ADMIN → NESSUS)
- Ligne 2 : Un utilisateur VLAN40 tente d'accéder à MySQL → bloqué (règle BLOCK DB)
- Ligne 3 : Connexion VPN WireGuard → autorisée

### Logs en temps réel

```bash
# Depuis OPNsense → Reporting → Traffic
# Ou via CLI :
clog /var/log/filter.log
```

## Logs Suricata — Détection d'intrusions

**Chemin :** `Services → Intrusion Detection → Alerts`

Suricata génère des alertes sur les comportements suspects détectés sur LAN et WAN.

<Tabs>
  <TabItem value="alerts" label="Vue Alerts" default>

Chaque alerte contient :

| Champ | Description |
|-------|-------------|
| **Timestamp** | Date et heure de l'événement |
| **SID** | Identifiant de la règle déclenchée |
| **Action** | allowed / blocked (IDS vs IPS) |
| **Interface** | Interface réseau concernée |
| **Source** | IP source et port |
| **Destination** | IP destination et port |
| **Alert** | Message de la règle (ex: ET SCAN Possible...) |

Exemple réel enregistré lors du test Nmap :
```
2026-04-08T04:26  SID:2024364  allowed  LAN  192.168.1.14:49202  192.168.1.1:80  ET SCAN Possible...
```

  </TabItem>
  <TabItem value="logfile" label="Log File Suricata">

**Chemin :** `Services → Intrusion Detection → Log File`

Les logs système de Suricata incluent :
- Démarrages/arrêts du moteur
- Statistiques de paquets traités
- Avertissements sur les règles (flowbits)

```
[Notice] This is Suricata version 8.0.4 RELEASE running in SYSTEM mode
[Notice] em0: packets: 5, drops: 0 (0.00%)
[Notice] em1: packets: 183, drops: 0 (0.00%)
```

  </TabItem>
</Tabs>

## Logs Bastion SSH — Traçabilité des connexions

Chaque connexion SSH au bastion — et chaque rebond ProxyJump vers un serveur — est enregistrée dans `/var/log/auth.log`.

```bash
# Consultation des logs SSH sur le bastion
sudo tail -f /var/log/auth.log

# Filtrer les connexions acceptées
sudo grep "Accepted" /var/log/auth.log

# Filtrer les tentatives échouées
sudo grep "Failed" /var/log/auth.log
```

### Exemple d'entrée dans auth.log

```
Apr 08 13:08:37 bastion sshd[800]: Server listening on 0.0.0.0 port 22.
Apr 08 13:09:12 bastion sshd[812]: Accepted publickey for admin from 192.168.1.14 port 54321 ssh2
Apr 08 13:09:15 bastion sshd[815]: Accepted publickey for admin from 192.168.1.14 port 54322 ssh2: ProxyJump to 192.168.9.253
Apr 08 13:11:03 bastion sshd[819]: Disconnected from user admin 192.168.1.14 port 54321
```

:::info Valeur de la traçabilité SSH centralisée
Sans bastion, les logs SSH seraient dispersés sur N serveurs. Avec le bastion, **une seule machine** contient l'historique complet de tous les accès SSH à l'infrastructure — ce qui simplifie drastiquement l'audit.
:::

## Logs WireGuard VPN

**Chemin :** `VPN → WireGuard → Log File`

Les sessions VPN sont enregistrées par OPNsense :

```bash
# Vérification des peers connectés via CLI OPNsense
wg show

# Output
interface: wg0
  public key: <clé_publique_serveur>
  listening port: 51820

peer: <clé_publique_sara>
  endpoint: X.X.X.X:XXXXX
  allowed ips: 10.10.0.2/32
  latest handshake: 2 minutes, 14 seconds ago
  transfer: 1.23 MiB received, 456 KiB sent
```

## Synthèse — Couverture de traçabilité

| Événement | Tracé par | Localisation |
|-----------|-----------|--------------|
| Connexion VPN établie | WireGuard logs | OPNsense |
| Règle firewall déclenchée | OPNsense filter logs | OPNsense |
| Scan réseau détecté | Suricata alerts | OPNsense |
| Connexion SSH au bastion | auth.log | Bastion Ubuntu |
| Rebond SSH vers serveur | auth.log | Bastion Ubuntu |
| Tentative SSH échouée | auth.log | Bastion Ubuntu |

:::warning Amélioration possible
Pour une traçabilité complète et centralisée, les logs du bastion pourraient être envoyés vers **Wazuh** (SIEM) via rsyslog. Voir section 12. Monitoring & sécurité.
:::
