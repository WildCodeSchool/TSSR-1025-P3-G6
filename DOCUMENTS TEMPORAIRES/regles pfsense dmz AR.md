

---

Markdown

```
## Analyse des Flux Firewall (Interface DMZ)

Sur pfSense (l'interface présentée sur l'image), le filtrage s'effectue par défaut sur l'**entrée** (Inbound) de l'interface. Voici la logique de direction des flux :

---

### Direction des Règles
* **Flux sortants de la DMZ :** On place dans l'onglet **DMZ** les règles qui définissent ce que les machines situées dans la DMZ ont le droit de faire vers l'extérieur (Internet, LAN, ou autres segments). Le trafic "entre" dans l'interface du pare-feu depuis le segment physique/virtuel DMZ.
* **Flux entrants vers la DMZ :** On ne place **pas** ces règles dans l'onglet DMZ. Pour autoriser un flux provenant d'une autre interface (ex: WAN ou LAN) vers la DMZ, la règle doit être configurée sur l'onglet de l'interface **source**.
    * *Exemple :* Pour autoriser le LAN à accéder à un serveur Web en DMZ, la règle se place dans l'onglet **LAN**.

---

### Synthèse du Traffic Flow

| Source du trafic | Destination du trafic | Onglet de configuration pfSense |
| :--- | :--- | :--- |
| **Machine en DMZ** | Internet | **DMZ** |
| **Machine en DMZ** | Serveur en LAN | **DMZ** |
| **Internet (WAN)** | Serveur en DMZ | **WAN** (ou NAT Port Forward) |
| **Machine en LAN** | Serveur en DMZ | **LAN** |

---

### Observation de votre configuration
Dans votre capture, les règles présentes traitent du trafic initié **par** les hôtes de la DMZ (ex: \`172.16.30.2\` vers DNS ou vers le pare-feu) ou du trafic traversant l'interface depuis un réseau source spécifique (le subnet \`10.10.20.0/26\`). 

**Note importante :** Si vous souhaitez qu'un utilisateur externe accède à votre DMZ, vérifiez vos onglets **WAN** ou **LAN** selon la provenance souhaitée.

