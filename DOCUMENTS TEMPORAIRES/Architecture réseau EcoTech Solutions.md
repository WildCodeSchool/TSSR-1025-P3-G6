



 # **DOCUMENTATION DE REFERENCE**
 
###  **PÉRIMÈTRE 0 - WAN/ACCÈS DISTANT**

- **ZEUS** : Serveur VPN via réseau public (accès distant sécurisé)
- **SPARTACUS** : Ubuntu admin pfSense via réseau privé 192.168.1.38

### **PÉRIMÈTRE 1 - FIREWALL HEPHAISTOS (pfSense)**

**Interfaces :**

- WAN : IPv4 192.168.1.250  (passerelle 192.168.1.1)
- WAN : IPv6 2a01:cb08:df2:1100:5a1d:d8ff:fe53:c4c0
- LAN : 10.10.0.2/28 → réseau ATHENES
- DMZ : 172.16.30.1/28 → réseau BYZANCE

Réglages des autorisations d'entrées par services 

Règles d'entrées WAN (Source → Destination)
├── SSH : TCP/22 [Any → This Firewall:22] avec author speciale par personne et par ordi 
├── VPN : UDP/1194 [Any → This Firewall:1194] avec author speciale par personne et par ordi 
├── DNS : UDP/TCP/53 [Any → Serveur DNS:53] ??? besoin 
├── DHCP : UDP/67-68 [LAN → pfSense:67] ??? besoin 
├── ICMP : ICMP [Any → Any] (avec rate limit )( si  communication deja initié) besoin ????
├── HTTP/HTTPS : TCP/80,443 [Any → Serveur web]  si  communication deja initié
├── SMTP/SMTPS : TCP/25,465 [Any → Mail server]  si  communication deja initié
└── FTP : TCP/20-21 [Any → FTP server] (NAT + passive mode)  si  communication deja initié 

 - Reglages des autorisations de sortie par ports, par ip, par services ( ssh , vpn dns, dhcp icmp,http http  smtp smtps ftp ) 

Règles de sortie LAN (Source LAN → Destination externe) :   
├── SSH : TCP [* → 22] [LAN → Serveurs distants:22]    ??? vers dmz 
├── VPN : UDP [* → 1194] [LAN → Serveurs VPN:1194]   ??? vers DMZ 
├── DNS : UDP/TCP [53,67-68 → 53] [LAN → DNS public:53]    ??? vers DMZ
├── DHCP : UDP [67-68 → *] [LAN → Serveur DHCP externe]    ???? vers DMZ
├── ICMP : ICMP [* → *] [LAN → Any]  avec regle
├── HTTP/HTTPS : TCP [* → 80,443] [LAN → Web:80/443]    avec regle
├── SMTP/SMTPS : TCP [* → 25,465] [LAN → Mail:25/465] si serveur interne de messageri e
└── FTP : TCP [* → 20-21] [LAN → Serveurs FTP] ???


### **PÉRIMÈTRE 2 - DMZ BYZANCE (172.16.30.0/28)**

- **Serveur bastion/Web** : 172.16.30.2
- **SPARTAKA** : admin pfSense
- Règle HTTPS configurée

### **PÉRIMÈTRE 3 - COEUR ATHENA (Switch L2/L3 Debian)**

**Interconnexions :**

- Vers firewall : 10.10.0.1/28 (LAN ATHENES)
- Vers infra : 10.10.20.1/26 (LAN ACROPOLE)
- Vers VLANs : 10.10.10.2/28 (LAN HERCULE)
- Vers infra redondante : 10.10.30.0
- DHCP IP helper à définir pour VLANs

### **PÉRIMÈTRE 4 - INFRA ACROPOLE (10.10.20.0/26)**

**Serveurs applicatifs :**

- VOXA : FreePBX Distro VOIP - 10.10.20.x/26
- **HERA** : Debian 13 - GLPI/Messagerie - 10.10.20.x/26
- **APOLLONIA** : Ubuntu - Admin pfSense - 10.10.20.x/26

**Infrastructure domaine :** **Domaine AD :** ecotech.tssr

- **HARESKI** : DC PRIMAIRE / MAITRE FSMO/ Windows Server 2022 CORE - **ADDS/DNS/DHCP/NTP**  - 10.10.20.4/26 (DC primaire)
- **HARESG** : Windows Server 2022 GUI - **RSAT AD DS/DNS/DHCP/WSUS** - 10.10.20.x/26 (DC secondaire)
- **PROMETHEE** : Windows Server 2022 CORE - **AD DS/DNS/DHCP** - 10.10.20.x/26 (DC tertiaire)
- **HERAKLES**  Windows Server 2022 CORE **WSUS**

**Infrastructure client  :** 

- **APOLLON** : Windows 11 client - 10.10.20.x/26

### **PÉRIMÈTRE 5 - VLAN HERCULE (Segmentation utilisateurs)**

Pour le périmètre 5 sur le VLAN HERCULE, plusieurs segments réseau sont configurés : VLAN 10 dédié à la direction avec HADES en tant que serveur Windows Server 2022, VLAN 20 pour les ressources humaines, VLAN 30 pour le secteur commercial, et VLAN 40 en cours de définition.
Les VLANs 50 à 90 couvrent les départements de développement, communication, DSI, ainsi que  les espaces partagés comme l'accueil et les salles de réunion avec imprimantes. 
La configuration d'ATHENA est visible avec ses paramètres VLAN et le routage global mis en place.

| VLAN | Service                     | Réseau        | Machine                 |
| ---- | --------------------------- | ------------- | ----------------------- |
| 10   | Direction                   | 10.15.10.0/24 | HADES (Win Server 2022) |
| 20   | RH                          | 10.15.20.0/24 | -                       |
| 30   | Commercial                  | 10.15.30.0/24 | -                       |
| 40   | Comptabilité                | 10.15.40.0/24 | -                       |
| 50   | Développement               | 10.15.50.0/24 | -                       |
| 60   | Communication               | 10.15.60.0/24 | -                       |
| 70   | DSI                         | 10.15.70.0/24 | -                       |
| 80   | vide                        | 10.15.80.0/24 | -                       |
| 90   | Accueil/Réunion/Imprimantes | 10.15.90.0/24 | -                       |

