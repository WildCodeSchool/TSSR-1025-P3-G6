
![](schemareseau.png)
# EcoTech Solutions 

## Vue d'ensemble

**Domaine** : ecotech.tssr  
**Utilisateurs** : 251 créés et organisés  
**Groupes** : 29 groupes de sécurité  
**DCs** : ARESKI (principal), PROMETHEE (secondaire)  
**Administration** : ARESG (RSAT)  
**Réseau ACROPOLE** : 10.10.20.0/26
---

## 1. Structure Active Directory

### OUs (Organizational Units)

```
ecotech.tssr
├── EcoTech_Users
│   ├── Direction
│   ├── Developpement
│   ├── RH
│   ├── Comptabilite
│   ├── Commercial
│   ├── Communication
│   ├── DSI
│   ├── Prestataire
│   └── Accueil
├── EcoTech_Groups
└── EcoTech_Computers
    ├── APOLLON
    ├── ARESG
    └── HADES



```




---

## 2. Groupes de sécurité

### Convention de nommage
`grp.[service].[niveau]`

### 27 groupes créés (9 services × 3 niveaux)
- **Niveau mgr** (managers) : 9 groupes
- **Niveau usr** (users) : 9 groupes
- **Niveau trv** (transverse) : 9 groupes

### Méta-groupes pour simplifier la gestion
- **grp.ALL.managers** : contient tous les *.mgr
- **grp.ALL.users** : contient tous les *.usr

**Script de création** :
```powershell
# Créer les méta-groupes
New-ADGroup -Name "grp.ALL.managers" -GroupScope Global -GroupCategory Security -Path "OU=EcoTech_Groups,DC=ecotech,DC=tssr"
New-ADGroup -Name "grp.ALL.users" -GroupScope Global -GroupCategory Security -Path "OU=EcoTech_Groups,DC=ecotech,DC=tssr"

# Peupler automatiquement
Get-ADGroup -Filter "Name -like '*.mgr'" | ForEach-Object {
    Add-ADGroupMember -Identity "grp.ALL.managers" -Members $_.DistinguishedName
}

Get-ADGroup -Filter "Name -like '*.usr'" | ForEach-Object {
    Add-ADGroupMember -Identity "grp.ALL.users" -Members $_.DistinguishedName
}
```

---

## 3. Utilisateurs (251 créés)

### Mapping département → service
```powershell
$mapDepartement = @{
    "Communication" = "Communication"
    "Développement" = "Developpement"
    "Direction" = "Direction"
    "Direction des Ressources Humaines" = "RH"
    "DSI" = "DSI"
    "Finance et Comptabilité" = "Comptabilite"
    "Service Commercial" = "Commercial"
}
```

### Mapping fonction → niveau
- Directeur*, Responsable*, Chef de projet*, Account Manager → **mgr**
- Toutes les autres fonctions → **usr**

### Convention de login
- Format : `[2 lettres prénom].[nom]` (ex: `am.boussaid`)
- Gestion des doublons : prénom complet si collision
- Email : `[login]@ecotech.tssr`
- Champ Company : `EcoTechSolutions`, `Studio Dlight`, ou `UBIHard`

### Isolation des prestataires
- Société ≠ "EcoTechSolutions" → redirigés vers OU **Prestataire**
- Studio Dlight et UBIHard dans une OU séparée

### Script d'import (structure)
```powershell
$users = Import-Csv "users.csv" -Delimiter ";"
$loginsUtilises = @()

foreach ($user in $users) {
    # Validation prénom/nom
    if ([string]::IsNullOrWhiteSpace($prenom) -or $prenom.Length -lt 2) {
        continue
    }
    
    # Construction login avec gestion doublons
    $login = "$deuxLettres.$nom".ToLower()
    if ($loginsUtilises -contains $login) {
        $login = "$prenom.$nom".ToLower()
    }
    $loginsUtilises += $login
    
    # Redirection prestataires
    if ($societe -ne "EcoTechSolutions") {
        $OU = "Prestataire"
    }
    
    # Création avec Company
    New-ADUser -Name "$prenom $nom" `
               -SamAccountName $login `
               -UserPrincipalName "$login@ecotech.tssr" `
               -Path "OU=$OU,OU=EcoTech_Users,DC=ecotech,DC=tssr" `
               -Description $fonction `
               -Company $societe
    
    # Ajout au groupe
    Add-ADGroupMember -Identity "grp.$OU.$niveau" -Members $login
}
```

---

## 4. DNS

### Configuration sur ARESKI
- Zone directe : **ecotech.tssr**
- DNS Forwarders configurés
- Enregistrements A pour l'infrastructure

### Enregistrements principaux
- areski.ecotech.tssr → 10.10.20.4
- promethee.ecotech.tssr → (IP de PROMETHEE)
- mail.ecotech.tssr → (IP serveur mail - à créer)

### Vérification
```powershell
# Résoudre le domaine
Resolve-DnsName ecotech.tssr

# Vérifier le SRV LDAP
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.ecotech.tssr
```

---

## 5. DHCP

### Scopes configurés sur ARESKI

| Scope | Réseau | Plage | Durée bail |
|-------|--------|-------|------------|
| ACROPOLE | 10.10.20.0/26 | 10.10.20.1 - 10.10.20.60 | 8 jours |
| VLAN 10 | 10.15.10.0/24 | 10.15.10.1 - 10.15.10.254 | 8 jours |

### Vérification
```powershell
Get-DhcpServerv4Scope
Get-DhcpServerv4Statistics
```

---

## 6. GPO (Group Policy Objects)

### GPO Admin Local DSI

**Objectif** : Rendre les groupes DSI administrateurs locaux sur toutes les machines clientes

**Configuration** :
- Nom : `grp.ou.dsi.adminlocal.computer`
- Liée à : **Ecotech_Computers**
- Chemin : `Computer Configuration → Policies → Windows Settings → Security Settings → Restricted Groups`

**Restricted Groups - Administrators** :
- ecotech\Domain Admins
- ecotech\grp.DSI.mgr
- ecotech\grp.DSI.usr

**Application** :
```powershell
# Sur la machine cliente
gpupdate /force
Restart-Computer

# Vérifier
gpresult /scope:computer /r
Get-LocalGroupMember -SID "S-1-5-32-544"
```

---

## 7. Infrastructure serveurs

### ARESKI (DC principal)
- **OS** : Windows Server 2022 Core
- **Rôles** : AD DS, DNS, DHCP, NTP
- **IP** : 10.10.20.4/26
- **Réseau** : ACROPOLE

### PROMETHEE (DC secondaire)
- **OS** : Windows Server 2022 Core
- **Rôles** : AD DS, DNS
- **Réseau** : ACROPOLE
- **Réplication** : Avec ARESKI

### ARESG (Administration)
- **OS** : Windows Server GUI
- **Rôle** : Poste d'administration RSAT
- **Outils** :
  - `dsa.msc` (AD Users and Computers)
  - `dnsmgmt.msc` (DNS Manager)
  - `dhcpmgmt.msc` (DHCP Manager)
  - `gpmc.msc` (Group Policy Management)

---

## 8. Commandes utiles

### Active Directory
```powershell
# Lister les utilisateurs
Get-ADUser -Filter * -SearchBase "OU=EcoTech_Users,DC=ecotech,DC=tssr"

# Compter les utilisateurs
Get-ADUser -Filter * -SearchBase "OU=EcoTech_Users,DC=ecotech,DC=tssr" | Measure-Object

# Rechercher un utilisateur
Get-ADUser -Filter "Name -like '*Gomez*'"

# Lister les membres d'un groupe
Get-ADGroupMember -Identity "grp.Communication.mgr"

# Vérifier les services AD
Get-Service NTDS,DNS,DHCPServer | Select Name,Status,StartType
```

### GPO
```powershell
# Forcer l'application des GPO
gpupdate /force

# Voir les GPO appliquées (ordinateur)
gpresult /scope:computer /r

# Rapport HTML complet
gpresult /h C:\gpo_report.html
```

### Réplication AD
```powershell
# Forcer la réplication
Invoke-Command -ComputerName ARESKI -ScriptBlock { repadmin /syncall }

# Résumé de la réplication
Invoke-Command -ComputerName ARESKI -ScriptBlock { repadmin /replsummary }
```

---

## 9. Points techniques importants

### SID du groupe Administrators local
`S-1-5-32-544` = Groupe Administrators (universel, toutes langues)

### Restricted Groups remplace tout
Quand Restricted Groups est configuré, Windows **remplace complètement** la liste des membres.  
⚠️ Toujours inclure **Domain Admins** pour ne pas perdre l'accès admin !

### Login convention et gestion des doublons
- 2 lettres prénom + nom (am.boussaid)
- Si collision : prénom complet + nom (amira.boussaid)
- Array `$loginsUtilises` pour tracker les doublons

### Validation des données avant création
```powershell
if ([string]::IsNullOrWhiteSpace($prenom) -or $prenom.Length -lt 2) {
    continue  # Évite l'erreur .Substring(0,2)
}
```


---

## 11. Architecture réseau option CORE 
j
Mon infra est virtualisé sur mon host avec comme hyperviseur 2 virtual box
j'ai 32 giga de Ram
Pour que je puisse travailler tranquillement tous mes services , j'ai opté pour la solution 1 vm 1 service .
De plus j'opte pour une majorité de vm en core  et la possibilité de les configurer en ssh ou en graphique avec une vm graphique qui n'aura pour role que de les administrer .( ou depuis mon host avec redirection de port)
j'ai aussi crééé la configuration pour pouvoir administrer toutes mes vm depuis l'exterieurs 
-mes deux serveurs controleurs de domaine ADDS
-mon routeur ATHENA
-GLPI
-FreePBX
j'ai reussi a faire tourner en meme temps 10 vm .
ma solution 
### Périmètres
- **WAN** : Internet (192.168.1.0/24)
- **DMZ BYZANCE** : 172.16.30.0/28 (Debian bastion, web externe)
- **LAN ATHENES** : 10.10.0.0/28 (routeur ATHENA)
- **ACROPOLE** : 10.10.20.0/26 (serveurs ARESKI, HERA, ARESG PROMETHEE VOXA DEBIANA APOLLONIA APOLLON)
- **VLAN HERCULE** : 10.15.x.0/24 (9 VLANs départements)

### Mapping VLAN → Services
- VLAN 10 : Direction (10.15.10.0/24)
- VLAN 20 : Développement (10.15.20.0/24)
- VLAN 30 : RH (10.15.30.0/24)
- VLAN 40 : Comptabilité (10.15.40.0/24)
- VLAN 50 : Commercial (10.15.50.0/24)
- VLAN 60 : Communication (10.15.60.0/24)
- VLAN 70 : DSI (10.15.70.0/24)
- VLAN 80 : Prestataire (10.15.80.0/24)
- VLAN 90 : Accueil (10.15.90.0/24)

Pour l'instant , c'est a la personne qui se connecte de s'inserer dans un vlan en s'atribuant une adresse dans le vlan de son service. Plus tard on fera une atribution automatique en fonction des caracteristiques de l'utilisateurs 


---

## Résumé des réalisations

✅ **Structure AD complète** : 9 OUs services + groupes + computers  
✅ **27 groupes de sécurité** + 2 méta-groupes (ALL.managers, ALL.users)  
✅ **251 utilisateurs** créés automatiquement via script PowerShell  
✅ **Isolation prestataires** dans OU dédiée     
✅ **SWITCH L2 L3** sur ATHENA pour routagesur les reseaux et vlan departementaux  
✅ **DNS/DHCP** opérationnels sur ARESKI  
✅ **GPO Admin Local DSI** configurée et liée   
✅ **GPO Block PanelI** configurée et liée  
✅ **GPO Fond d'ecran**configuré et liée  
✅ **GPO mot de passe**configuré et liée  
✅ **GPO Powershell seecurity**configuré et liée    
✅ **GPO Partage de fichier au Logon**configuré et liée              
✅ **GPO Restriction hoiraire**configuré et liée  
✅ **2 DCs** (ARESKI + PROMETHEE) avec réplication  
✅ **RSAT** sur ARESG pour administration graphique  
✅ **GLPI** sur DEBIANA pour administration du parc  
✅ **IREDMAIL** sur HERA pour Messagerie   
✅ **PFSENSE** sur HEPHAISTOS pour Firewall   
✅ **FREEPBX** sur VOXA pour Telephonie softphone   
✅ **WSUS** sur PROMETHEE pour administration mise a jour   
✅ **VPN** sur ZEUS pour gestion serveur en WAN


**État** : Infrastructure de base opérationnelle, prête pour les modules suivants (GPO avancées, messagerie, WSUS, VLAN dynamique).
## Arbre de l'infrastructure EcoTech

```
DOMAINE : ecotech.tssr
│
├── UTILISATEURS (OU=Ecotech_Users)
│   ├── OU=Direction
│   │   ├── Managers (grp.Direction.mgr)
│   │   ├── Users (grp.Direction.usr)
│   │   └── Travelers (grp.Direction.trv)
│   │
│   ├── OU=DSI
│   │   ├── Managers (grp.DSI.mgr) → Yara Tsai (ya.tsai)
│   │   ├── Users (grp.DSI.usr)
│   │   └── Travelers (grp.DSI.trv)
│   │
│   ├── OU=Developpement
│   │   ├── Managers (grp.Developpement.mgr)
│   │   ├── Users (grp.Developpement.usr) → Kenzo Yamamoto (ke.yamamoto)
│   │   └── Travelers (grp.Developpement.trv)
│   │
│   ├── OU=RH
│   ├── OU=Comptabilite
│   ├── OU=Commercial
│   ├── OU=Communication
│   ├── OU=Accueil
│   └── OU=Prestataire → Nikos Papadopoulos (ni.papadopoulos) - UBIHard
│
├── ORDINATEURS (OU=Ecotech_Computers)
│   ├── ARESG (Wins Server 2022 GUI)10.10.20.14
│   ├── ARESKI (Win Server 2022 Core)10.10.20.4-DC1
│   ├── PROMETHEE (WinServer 2022 Core)10.10.20.7-DC2 
│   ├── APOLLON (Windows 10/11)   
│   ├── HERA (Windows 10/11)
│   │── VOXA (Windows 10/11)  
│   │── VOXA (Windows 10/11)
│   ├── ATHENA (Windows 10/11)
│   ├── APOLLONIA (Windows 10/11)
│   │── ATHENA (Windows 10/11)│
│   └── APOLLONIA (Windows 10/11)
│   │── DEBIANA2 (Windows 10/11)
│
├── GROUPES (OU=Ecotech_Groups)
│   ├── Groupes métier par OU (grp.[Service].[niveau])
│   │   ├── grp.Direction.mgr/usr/trv
│   │   ├── grp.DSI.mgr/usr/trv
│   │   ├── grp.Developpement.mgr/usr/trv
│   │   └── ... (tous les départements)
│   │
│   ├── Groupes globaux
│   │   ├── grp.ALL.managers → regroupe tous les .mgr
│   │   └── grp.ALL.users → regroupe tous les .usr
│   │
│   └── Groupes administration (cachés)
│       ├── grp.Music.Vocal → Yara (Admin niveau 1)
│       └── grp.Music.Instru → Nikos + Kenzo (Admin niveau 1)
│
└── SERVEUR DE FICHIERS (PROMETHEE)
    └── Z:\Partages\
        ├── Direction\
        ├── RH\
        ├── Comptabilite\
        ├── Commercial\
        ├── Developpement\
        ├── DSI\
        ├── Communication\
        ├── Managers\ (réservé grp.ALL.managers)
        ├── Users\
        ├── Clients\
        └── Public\
            └── Wallpapers\ (fonds d'écran)
```