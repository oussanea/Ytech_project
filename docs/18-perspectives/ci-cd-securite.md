---
id: ci-cd-securite
title: 19.3 CI/CD Sécurité (DevSecOps)
sidebar_label: CI/CD Sécurité
sidebar_position: 19.3
description: Pipeline DevSecOps, GitHub Actions et politique de branches sécurisée pour Ytech Solutions.
---

# 🔄 CI/CD Sécurité (DevSecOps)

> Intégrer la sécurité directement daans le pipeline de développement de l'infrastructure Ytech.

---

## Pipeline CI/CD sécurisé

```
Code Push → GitHub Actions
    │
    ├── SAST : Bandit (Python) / PHPStan (PHP)
    ├── Secrets scan : GitLeaks / trufflehog
    ├── Dependency check : OWASP Dependency-Check
    ├── Docker image scan : Trivy / Snyk
    │
    ├── Tests unitaires + intégration
    │
    ├── Build Docker image
    │
    └── Deploy (si tout ✅)
          → VM staging (192.168.56.x)
          → Tests de smoke
          → Approbation manuelle
          → VM production
```

---

## Exemple GitHub Actions — scan sécurité

```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run Trivy (Docker image scan)
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'ytech/chatbot:latest'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'

      - name: Run GitLeaks (secrets scan)
        uses: gitleaks/gitleaks-action@v2

      - name: OWASP Dependency Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'ytech'
          path: '.'
          format: 'HTML'
```

---

## Politique de branches sécurisée

```
main          → Production (protégé, review obligatoire)
  └── develop → Intégration (tests auto)
        ├── feature/chatbot-ollama
        ├── feature/monitoring
        ├── feature/hardening
        ├── feature/webapp
        └── feature/network
```
