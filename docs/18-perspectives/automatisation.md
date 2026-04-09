---
id: automatisation
sidebar_label: Automatisation
sidebar_position: 19.2
description: Infrastructure as Code, automatisation des sauvegardes et alerting automatique pour Ytech Solutions.
---

# 🤖 Automatisation

> Rendre l'infrastructure Ytech entièrement reproductible et auto-surveillée grâce à l'Infrastructure as Code.

---

## Infrastructure as Code (IaC)

```
Outil         Usage
─────────────────────────────────────────
Ansible       → Configuration des VMs (UFW, SSH, packages)
Terraform     → Provisioning cloud (si migration AWS/Azure)
Docker Compose→ Déjà en place — à étendre
Makefile      → Commandes de déploiement unifiées
```

**Exemple : Ansible playbook pour configurer UFW**

```yaml
# playbooks/configure-ufw.yml
---
- hosts: app_servers
  become: yes
  tasks:
    - name: Allow SSH from internal networks
      ufw:
        rule: allow
        from_ip: "{{ item }}"
        to_port: 22
      loop:
        - 192.168.56.0/24
        - 192.168.9.0/24
        - 192.168.10.0/24

    - name: Allow HR App HTTPS
      ufw:
        rule: allow
        from_ip: 192.168.9.0/24
        to_port: 8443

    - name: Enable UFW
      ufw:
        state: enabled
        policy: deny
```

---

## Automatisation des sauvegardes

```bash
# Amélioration du script backup.sh
# Ajouter : notification Slack/email en cas d'échec
# Ajouter : vérification d'intégrité des archives (sha256sum)
# Ajouter : rotation automatique (garder 30 jours au lieu de 7)

# Exemple : notification en cas d'échec
if [ $? -ne 0 ]; then
  curl -X POST "$SLACK_WEBHOOK" \
    -H 'Content-type: application/json' \
    --data '{"text":"⚠️ Backup Ytech FAILED - '"$(date)"'"}'
fi
```

---

## Alerting automatique Wazuh → Grafana → Email/SMS

```
Wazuh détecte une alerte niveau 10+
  → Elasticsearch index wazuh-alerts-*
  → Grafana Alert Rule déclenche
  → Notification email/Slack/PagerDuty
  → Ticket automatique (Jira/ServiceNow)
```
