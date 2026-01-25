# PERIMETRE 0   WAN

## CONNEXION SSH
ZEUS
ADMINuser

## CONNEXION VPN
USER ADDS
COMPUTER ADDS 





---

# PERIMETRE 1  ENTREE DU RESEAU



interface 1 WAN 192.168.1.250 reseau 192.168.1.0/24
			passerelle 192.168.1.1 
interface 2 LAN  10.10.0.2     reseau 10.10.0.0/28
interface 3 DMZ 172.16.30.1    reseau 172.16.30.0/28

---

# HEPHAISTOS
## PFSENSE

**role PARE FEU**
NTP : pool.ntp;org 
pfsense va chercher l'horloge sur ntp de ADDS : faire la regle  et envoyer sur deian dmz


3 interfaces ( 2 deja )
![[PFSENSE_config4.png]]

 Réglages des autorisations d'entrées par services ( ssh , vpn dns, dhcp icmp,http http  smtp smtps ftp ) 

Règles d'entrées WAN (Source → Destination)
├── SSH : TCP/22 [Any → This Firewall:22]
├── VPN : UDP/1194 [Any → This Firewall:1194]
├── DNS : UDP/TCP/53 [Any → Serveur DNS:53]
├── DHCP : UDP/67-68 [LAN → pfSense:67]
├── ICMP : ICMP [Any → Any] (avec rate limit )
├── HTTP/HTTPS : TCP/80,443 [Any → Serveur web]
├── SMTP/SMTPS : TCP/25,465 [Any → Mail server]
└── FTP : TCP/20-21 [Any → FTP server] (NAT + passive mode)

 - Reglages des autorisations de sortie par ports, par ip, par services ( ssh , vpn dns, dhcp icmp,http http  smtp smtps ftp ) 

Règles de sortie LAN (Source LAN → Destination externe) :   
├── SSH : TCP [* → 22] [LAN → Serveurs distants:22]    
├── VPN : UDP [* → 1194] [LAN → Serveurs VPN:1194]   
├── DNS : UDP/TCP [53,67-68 → 53] [LAN → DNS public:53]    
├── DHCP : UDP [67-68 → *] [LAN → Serveur DHCP externe]    
├── ICMP : ICMP [* → *] [LAN → Any] (rate limit) ( si  communication deja initié)
├── HTTP/HTTPS : TCP [* → 80,443] [LAN → Web:80/443]    
├── SMTP/SMTPS : TCP [* → 25,465] [LAN → Mail:25/465] ( si communication deja initié)
└── FTP : TCP [* → 20-21] [LAN → Serveurs FTP]`


---
# PERIMETRE 2 DMZ
réseau 172.16.30.0/28
14 adresses possibles

---


# ARTEMIS
## DEBIAN 13
 1 interface avec 2 ou plusieurs adresses (aliasing )
  bastion 172.16.30.2  
  connexion avec ZEUS et userAdmin en SSH et renvoie de ZEUS vers HEPHAISTOS pour administration HERMES HERA ARES 
  Web172.16.30.3




Azure Bastion
Apache Guacamole




# PERIMETRE 3 COEUR


## DEBIAN 13
ATHENA
COEUR

```
ATHENA (Debian Core Router/Switch)
├── Interface 1 : 10.10.0.1/28 ← Firewall HEPHAISTOS (10.10.0.2)
├── Interface 2 : 10.10.20.1/26 ← Infra serveur
│   ├── HERMES (WinSrv AD/DNS/DHCP/WSUS) : 10.10.20.1/26
│   ├── HERA (Debian GLPI/Mail) : 10.10.20.2/26
│   └── ARES (FreePBX VoIP) : 10.10.20.3/26
└── Interface 3 (TRUNK) : 9 VLANs départements
    ├── VLAN10 DIRECTION : 10.15.10.1/24 ← HADES WinSrv 10.15.10.5
    ├── VLAN20 RH : 10.15.20.0/24
    ├── VLAN30 Finance : 10.15.30.0/24
    ├── VLAN40 Compta : 10.15.40.0/24
    ├── VLAN50 Commercial : 10.15.50.0/24
    ├── VLAN60 Dev : 10.15.60.1/24 ← APOLLON 10.15.60.5
    ├── VLAN70 DSI : 10.15.70.0/24
    ├── VLAN80 Com : 10.15.80.0/24
    └── VLAN90 Accueil/Imprim : 10.15.90.0/24
```



![[ATHENA CONFIG INTERFACES OK.png]]

---



# PERIMETRE 4 INFRA

## SERVER 2022
HERMES
ADDS/DNS/DHCP/NTP


## DEBIAN 13
HERA
GLPI/MESSAGERIE






## IPBX01
ARES
FREEPBPX

---


# PERIMETRE 5 LAN

## CORE 2022
HADES

## CORE 2022
APOLLON

---

---
# ADMIN user name
pokemon.eco

