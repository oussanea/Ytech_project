---
id: principe-moindre-privilege
title: Principe du moindre privilège
sidebar_label: "🔒 Moindre privilège"
sidebar_position: 3
---

# 🔒 Principe du moindre privilège

## Définition

Le **principe du moindre privilège (PoLP — Principle of Least Privilege)** stipule que chaque entité (utilisateur, service, machine) ne doit disposer que des droits strictement nécessaires à l'accomplissement de sa fonction — rien de plus.

Dans l'infrastructure Y-Tech, ce principe est appliqué à **trois niveaux** :

| Niveau | Mécanisme | Outil |
|--------|-----------|-------|
| Réseau | Isolation VLAN | OPNsense |
| Flux | Règles firewall | OPNsense Rules |
| Accès SSH | Jump Host | Bastion Ubuntu |

## Application concrète — Exemples réels

### Cas 1 — Utilisateur métier (VLAN40_USERS)

```
Un utilisateur du département RH veut accéder à la base de données directement.

❌ Bloqué par :
   Firewall VLAN40 : BLOCK VLAN40_USERS → VLAN25_DB

✅ Ce qu'il peut faire :
   Accéder à l'application HR (port 8443) qui, elle, parle à la DB.
   L'utilisateur ne communique JAMAIS directement avec MySQL.
```

**Pourquoi c'est important :** Si le compte d'un utilisateur est compromis, l'attaquant ne peut pas exfiltrer la base de données directement.

---

### Cas 2 — Serveur applicatif (VLAN20_APP)

```
Le serveur Laravel a besoin de lire/écrire dans MySQL.

✅ Autorisé :
   VLAN20_APP → VLAN25_DB sur port 3306

❌ Bloqué — tout le reste :
   VLAN20_APP → Internet       ❌
   VLAN20_APP → VLAN30_MGMT   ❌
   VLAN20_APP → VLAN40_USERS  ❌
```

**Pourquoi c'est important :** Un serveur compromis ne peut pas pivoter vers d'autres segments ni exfiltrer des données vers Internet.

---

### Cas 3 — Serveur de base de données (VLAN25_DB)

```
La DB ne peut initier AUCUNE connexion sortante.

Règle unique sur VLAN25_DB :
   ❌ BLOCK ALL (source: *, destination: *, port: *)

Elle répond uniquement aux connexions entrantes légitimes depuis APP et DMZ.
```

**Pourquoi c'est important :** Même si un attaquant compromet MySQL, il ne peut pas établir de connexion sortante pour exfiltrer les données (pas de reverse shell possible).

---

### Cas 4 — Accès VPN (WireGuard)

```
Un utilisateur connecté via VPN a les droits du rôle "équipe".

✅ Accès autorisé :
   10.10.0.x → APP_SRV (ports APP_PORTS)
   10.10.0.x → MGMT_SRV (ports MGMT_PORTS)

❌ Accès refusé :
   10.10.0.x → DB_SRV      ❌ (bloqué explicitement)
   10.10.0.x → BACKUP_SRV  ❌ (bloqué explicitement)

Exception admin :
   10.10.0.2 (sara) → * (accès complet — rôle ADMIN)
```

---

### Cas 5 — Serveur Nessus (scanner de vulnérabilités)

```
Seul l'administrateur Kali peut accéder à l'interface Nessus.

✅ KALI_ADMIN → MGMT_SRV sur NESSUS_PORT (8834)
❌ Tout autre source → MGMT_SRV:8834 est bloqué
```

**Pourquoi c'est important :** Un scanner de vulnérabilités expose des informations critiques sur l'infrastructure. Son accès est strictement limité à l'admin.

## Synthèse des restrictions appliquées

| Entité | Ce qui est autorisé | Ce qui est interdit |
|--------|---------------------|---------------------|
| Utilisateurs VLAN40 | Apps (8443, 8501) | DB, MGMT, Admin, Internet direct |
| Serveurs APP | DB MySQL (3306) | Internet, MGMT, autres VLANs |
| Serveur DB | Réponses entrantes uniquement | Tout flux sortant |
| VPN Users | APP + MGMT | DB, BACKUP |
| Backup | SSH vers serveurs | Tout autre flux |
| Admin (KALI/sara) | Tout | — |

:::warning Anti-pattern évité
❌ **Ne pas faire** : donner des droits admin à tous les utilisateurs "pour que ça marche".  
✅ **Ce qui est fait** : créer des règles précises par rôle, quitte à ajouter des exceptions ponctuelles documentées.
:::
