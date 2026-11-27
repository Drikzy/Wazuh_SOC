# Mini SOC Lab — Wazuh (Docker & Hyper-V)

Laboratoire de supervision et de réponse aux incidents basé sur **Wazuh** (SIEM / XDR) déployé sous **Docker**, supervisant une VM **Ubuntu 22.04 LTS** sous **Hyper-V**, avec simulation d'attaque brute-force SSH et remédiation automatique via **Active Response**.

## 1. Architecture

| **Wazuh (Manager, Indexer, Dashboard)** | Docker (Hôte Windows) | Centralisation des logs, corrélation, visualisation et réponse active. |
| **Endpoint cible (`ubuntu-hyperv`)** | VM Ubuntu 22.04 (Hyper-V) | Machine supervisée (`172.31.140.28`) exécutant `wazuh-agent` et `openssh-server`. |
| **Attaquant (éphémère)** | Conteneur `kalilinux/kali-rolling` | Simulation de brute-force SSH avec `hydra`. |

## 2. Déploiement rapide

* **Stack Wazuh (Docker) :** génération des certificats TLS puis lancement via `docker compose up -d` (Dashboard sur `https://localhost`).
* **Endpoint Ubuntu (Hyper-V) :** installation de `openssh-server` et enrôlement de `wazuh-agent` auprès du Manager Docker.

## 3. Scénario 1 : Détection et blocage d'un Brute-Force SSH

* **Référentiel MITRE ATT&CK :** Credential Access — *Brute Force: Password Guessing* (`T1110.001`).

### Configuration Active Response (`ossec.conf` côté Manager)
Association de `firewall-drop` (`iptables`) à la règle de corrélation brute-force SSH (`5763`) pour bannir l'IP source pendant `180` secondes :

```xml
<ossec_config>
  <command>
    <name>firewall-drop</name>
    <executable>firewall-drop</executable>
    <timeout_allowed>yes</timeout_allowed>
  </command>

  <active-response>
    <disabled>no</disabled>
    <command>firewall-drop</command>
    <location>local</location>
    <rules_id>5763</rules_id>
    <timeout>180</timeout>
  </active-response>
</ossec_config>
```

### Simulation et validation
1. **Préparation :** activation temporaire de `PasswordAuthentication yes` sur `ubuntu-hyperv`.
2. **Attaque :** exécution de `hydra` depuis un conteneur Kali éphémère :
   ```bash
   docker run --rm -v "${PWD}:/work" -w /work kalilinux/kali-rolling bash -c \
     "apt-get update && apt-get install -y hydra && hydra -l badguy -P passwords.txt ssh://172.31.140.28"
   ```
3. **Détection & Remédiation :** remontée de l'alerte `5763` dans **Threat Hunting**, blocage automatique de l'IP pendant `180`s (vérifié dans `/var/ossec/logs/active-responses.log`), puis remise en état de la configuration SSH.