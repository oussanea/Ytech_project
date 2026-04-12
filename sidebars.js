module.exports = {
  tutorialSidebar: [
    {
      type: 'doc',
      id: 'PagedeGarde',
      label: '🏠 Accueil',
    },

    {
      type: 'category',
      label: '01. Introduction',
      items: [
        'introduction/presentation-projet',
        'introduction/presentation-entreprise',
        'introduction/contexte-metier',
        'introduction/equipe',
        'introduction/objectifs',
      ],
    },

    {
      type: 'category',
      label: '02. Cahier des charges',
      items: [
        'cahier-des-charges/besoins-fonctionnels',
        'cahier-des-charges/besoins-techniques',
        'cahier-des-charges/exigences-securite',
        'cahier-des-charges/contraintes',
      ],
    },

    {
      type: 'category',
      label: '03. Analyse des risques',
      items: [
        'analyse-risques/methodologie-iso',
        'analyse-risques/actifs-menaces',
        'analyse-risques/scenarios-attaque',
        'analyse-risques/analyse-cia',
        'analyse-risques/matrice-risques',
        'analyse-risques/swot-securite',
        'analyse-risques/synthese-risques',
        'analyse-risques/analyse-financiere',
      ],
    },

    {
      type: 'category',
      label: '04. Architecture initiale',
      items: [
        'architecture-initiale/description',
        'architecture-initiale/schema-reseau',
        'architecture-initiale/faiblesses',
        'architecture-initiale/surface-attaque',
      ],
    },

    {
      type: 'category',
      label: '05. Pentest',
      items: [
        'pentest/introduction',
        'pentest/scope',
        'pentest/phase-1-reconnaissance',
        'pentest/phase-2-scanning',
        'pentest/phase-3-vulnerabilites',
        'pentest/phase-4-audit-interne',
        'pentest/analyse-risques',
        'pentest/resultats',
        'pentest/comparaison-avant-apres',
      ],
    },

    {
      type: 'category',
      label: '06. Architecture cible',
      items: [
        'architecture-cible/vision-globale',
        'architecture-cible/segmentation-vlan',
        'architecture-cible/dmz',
        'architecture-cible/zero-trust',
        'architecture-cible/plan-adressage',
        'architecture-cible/schema-final',
      ],
    },

    {
      type: 'category',
      label: '07. Firewall OPNsense',
      items: [
        'firewall-opnsense/index',
        'firewall-opnsense/installation',
        'firewall-opnsense/interfaces-vlans',
        'firewall-opnsense/aliases',
        'firewall-opnsense/nat',
        'firewall-opnsense/regles-firewall',
        'firewall-opnsense/regles-inter-vlan',
        'firewall-opnsense/logs-surveillance',
      ],
    },

    {
      type: 'category',
      label: '08. Gestion des accès',
      items: [
        'gestion-acces/index',
        'gestion-acces/modelisation-roles',
        'gestion-acces/principe-moindre-privilege',
        'gestion-acces/acces-par-departement',
        'gestion-acces/bastion-ssh',
        'gestion-acces/bitwarden',
        'gestion-acces/tracabilite-logs',
        'gestion-acces/controle-acces',
      ],
    },

    {
      type: 'category',
      label: '09. VPN & Zero Trust',
      items: [
        'vpn-zero-trust/intro-vpn',
        'vpn-zero-trust/wireguard',
        'vpn-zero-trust/headscale-tailscale',
        'vpn-zero-trust/architecture-acces',
        'vpn-zero-trust/politiques-securite',
      ],
    },

    {
      type: 'category',
      label: '10. DevOps & Déploiement',
      items: [
        'devops/github-organisation',
        'devops/docker-compose',
        'devops/deploiement-ubuntu',
      ],
    },

    {
      type: 'category',
      label: '11. Services infrastructure',
      items: [
        'services-infrastructure/web-app-laravel',
        'services-infrastructure/app-crud-rh',
        'services-infrastructure/chatbot-ytechbot',
        'services-infrastructure/base-de-donnees',
        'services-infrastructure/gestion-serveurs',
      ],
    },

    {
      type: 'category',
      label: '12. Monitoring & sécurité',
      items: [
        'monitoring-securite/zabbix',
        'monitoring-securite/wazuh',
        'monitoring-securite/grafana',
        'monitoring-securite/nessus',
        'monitoring-securite/correlation-evenements',
      ],
    },

    {
      type: 'category',
      label: '13. Hardening',
      items: [
        'hardening/vue-ensemble',
        'hardening/hardening-linux-ubuntu',
        'hardening/hardening-linux-kali',
        'hardening/hardening-windows',
        'hardening/ssh-https-certificats',
        'hardening/waf-modsecurity',
        'hardening/bonnes-pratiques',
      ],
    },

    {
      type: 'category',
      label: '14. Sauvegarde & résilience',
      items: [
        'sauvegarde-resilience/strategie-3-2-1',
        'sauvegarde-resilience/script-backup',
        'sauvegarde-resilience/Stockage-Externe',
        'sauvegarde-resilience/Sécurisation-des-Sauvegardes',
      ],
    },

    {
      type: 'category',
      label: '15. Infrastructure Sécurisée',
      items: [
        'infrastructure-securisee/infrastructure-securisee',
      ],
    },

    {
      type: 'category',
      label: '16. Limites',
      items: [
        'limites/limites-simulation',
        'limites/mode-virtualbox-bridged',
        'limites/ecart-production',
      ],
    },

    {
      type: 'category',
      label: '17. Résultats',
      items: [
        'resultats/ameliorations-securite',
        'resultats/reduction-surface-attaque',
        'resultats/valeur-ajoutee',
      ],
    },

    {
      type: 'category',
      label: '18. Conclusion',
      items: ['conclusion/conclusion-generale'],
    },

    {
      type: 'category',
      label: '19. Perspectives',
      items: [
        'perspectives/ameliorations',
        'perspectives/automatisation',
        'perspectives/ci-cd-securite',
        'perspectives/haute-disponibilite',
      ],
    },

  ],
}
