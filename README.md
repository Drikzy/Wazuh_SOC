# Mini-SOC Local — Détection d'intrusions avec Wazuh

Lab personnel d'analyse et de détection d'incidents déployé sous Docker afin de pratiquer la supervision d'un hôte Linux, l'analyse d'alertes et le mapping **MITRE ATT&CK**.

## Architecture
- **Wazuh Stack (Docker) 4.14.13** : Manager, Indexer, Dashboard
- **Hôte supervisé** : Serveur Linux cible avec agent Wazuh actif (collecte des logs système/auth et File Integrity Monitoring)