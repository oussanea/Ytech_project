---
id: politiques-securite
title: Politiques de sécurité ACL
sidebar_position: 4
---

# Politiques de sécurité

## Principe

Les règles ACL Headscale définissent précisément quelles machines peuvent communiquer avec quelles autres. **Tout ce qui n'est pas explicitement autorisé est refusé** — implémentation concrète du Zero Trust.

## Fichier ACL

```json
{
  "tagOwners": {
    "tag:it-admin":      ["ytech@ytech.local"],
    "tag:developer":     ["ytech@ytech.local"],
    "tag:hr":            ["ytech@ytech.local"],
    "tag:finance":       ["ytech@ytech.local"],
    "tag:commercial":    ["ytech@ytech.local"],
    "tag:ceo":           ["ytech@ytech.local"],
    "tag:server-app":    ["ytech@ytech.local"],
    "tag:server-web":    ["ytech@ytech.local"],
    "tag:server-db":     ["ytech@ytech.local"],
    "tag:server-backup": ["ytech@ytech.local"],
    "tag:monitoring":    ["ytech@ytech.local"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["tag:it-admin"],
      "dst": ["*:*"]
    },
    {
      "action": "accept",
      "src": ["*"],
      "dst": ["tag:server-app:80", "tag:server-app:443"]
    },
    {
      "action": "accept",
      "src": ["*"],
      "dst": ["tag:monitoring:8444"]
    },
    {
      "action": "accept",
      "src": ["tag:developer"],
      "dst": ["tag:server-web:8501"]
    },
    {
      "action": "accept",
      "src": ["tag:hr"],
      "dst": ["tag:server-web:8443", "tag:server-web:8501"]
    },
    {
      "action": "accept",
      "src": ["tag:finance", "tag:commercial"],
      "dst": ["tag:server-app:443", "tag:server-web:8501"]
    },
    {
      "action": "accept",
      "src": ["tag:ceo"],
      "dst": ["tag:server-web:8443", "tag:server-web:8501"]
    },
    {
      "action": "accept",
      "src": ["tag:server-app", "tag:server-web"],
      "dst": ["tag:server-db:3306"]
    }
  ]
}
```

## Matrice des accès

| Source            | App RH :8443 | IA Ollama :8501 | App Web :443 | DB :3306 |
|------------------|:------------:|:---------------:|:------------:|:--------:|
| tag:it-admin     | ✅ | ✅ | ✅ | ✅ |
| tag:ceo          | ✅ | ✅ | ❌ | ❌ |
| tag:hr           | ✅ | ✅ | ❌ | ❌ |
| tag:developer    | ❌ | ✅ | ❌ | ❌ |
| tag:finance      | ❌ | ✅ | ✅ | ❌ |
| tag:commercial   | ❌ | ✅ | ✅ | ❌ |
| tag:server-app   | ❌ | ❌ | ❌ | ✅ |
| tag:server-web   | ❌ | ❌ | ❌ | ✅ |

## Preuve d'application — Accès refusé

Un utilisateur `finance` tente d'accéder à l'application RH. Son tag (`tag:commercial`) ne figure pas dans la règle ACL pour le port 8443 — connexion bloquée au niveau réseau.

![Accès refusé — finance ne peut pas atteindre l'app RH](./finance-crude.png)

## Preuve d'application — Accès autorisé (CEO)

Le Directeur Général (`tag:ceo`) accède à l'application RH.

Son tag est explicitement autorisé dans les règles ACL pour le port 8443 — la connexion est acceptée.

![Accès CEO HR App](./ceo-crude.png)