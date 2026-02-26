
## Console d'administration Active Directory

Voici les consoles d'administration (MSC) les plus fréquentes pour la gestion d'infrastructure :

| Console                            | Commande       | Usage principal                                                  |
| :--------------------------------- | :------------- | :--------------------------------------------------------------- |
| **Utilisateurs et ordinateurs AD** | `dsa.msc`      | Création d'utilisateurs, groupes, unités d'organisation (OU).    |
| **Centre d'administration AD**     | `dsac.exe`     | Gestion moderne (basée sur PowerShell) avec corbeille AD.        |
| **Domaines et approbations AD**    | `domain.msc`   | Gestion des niveaux fonctionnels et des relations d'approbation. |
| **Sites et services AD**           | `dssite.msc`   | Gestion de la réplication et de la topologie réseau.             |
| **Éditeur ADSI**                   | `adsiedit.msc` | Modification de bas niveau des attributs de l'annuaire.          |





# Module ADDS/DHCP/DNS - Récapitulatif

## Objectifs

- Créer la structure Active Directory pour le domaine `ecotech.tssr`
- Organiser 251 utilisateurs en 9 services (Direction, RH, Communication, DSI, Développement, Comptabilité, Commercial, Prestataire, Accueil)
- Mettre en place une hiérarchie avec 3 niveaux : Manager (mgr), User (usr), Transverse (trv)
- Configurer DNS et DHCP sur le DC principal
- Isoler les prestataires (UBIHard, Studio Dlight) dans une OU dédiée

---

## Infrastructure

- **ARESKI** : Windows Server 2022 Core - DC principal (ADDS/DNS/DHCP)
- **PROMETHEE** : Windows Server 2022 Core - DC  (ADDS/DNS/DHCP)
- **ARESG** : Windows Server avec GUI - Station d'administration (RSAT) . peut etre eteinte pour gagner de la RAM
- **Domaine** : ecotech.tssr
- **Réseau** : 10.10.20.0/26 (ACROPOLE)

---

## Réalisations

### 1. Structure des OUs

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
```

**Création manuelle via dsa.msc** puis déplacement des OUs dans EcoTech_Users.

---

### 2. Création des groupes de sécurité (27 groupes)

**Convention de nommage** : `grp.[service].[niveau]`

**Script de création automatique** :

```powershell
$services = @("Direction", "Developpement", "RH", "Comptabilite", "Commercial", "Communication", "DSI", "Prestataire", "Accueil")
$niveaux = @("mgr", "usr", "trv")

foreach ($service in $services) {
    foreach ($niveau in $niveaux) {
        $nomGroupe = "grp.$service.$niveau"
        try {
            New-ADGroup -Name $nomGroupe -GroupScope Global -GroupCategory Security -Path "OU=EcoTech_Groups,DC=ecotech,DC=tssr"
            Write-Host "Création du GROUPE $nomGroupe" -ForegroundColor Green
        } catch {
            Write-Host "Erreur : $nomGroupe - $_" -ForegroundColor Red
        }
    }
}
```

**Résultat** : 27 groupes créés (9 services × 3 niveaux)

---

### 3. Import des utilisateurs (251 utilisateurs)

**Tableaux de correspondance** :

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

$mapNiveau = @{
    "Directeur" = "mgr"
    "Directeur adjoint" = "mgr"
    "Responsable*" = "mgr"
    "Directrice" = "mgr"
    "Chef de projet" = "mgr"
    # ... (toutes les autres fonctions = "usr")
}
```

**Script d'import complet** :

```powershell
$users = Import-Csv "users.csv" -Delimiter ";"
$loginsUtilises = @()
$compteurCrees = 0
$compteurIgnores = 0
$compteurErreurs = 0

foreach ($user in $users) {
    $prenom = $user.Prenom
    $nom = $user.Nom
    $fonction = $user.fonction
    $departement = $user.Departement
    $societe = $user.Societe
    
    # Validation prénom/nom
    if ([string]::IsNullOrWhiteSpace($prenom) -or $prenom.Length -lt 2) {
        $compteurIgnores++
        continue
    }
    
    # Construction du login : 2 lettres prénom + nom
    $deuxLettres = $prenom.Substring(0,2)
    $login = "$deuxLettres.$nom".ToLower()
    
    # Gestion des doublons
    if ($loginsUtilises -contains $login) {
        $login = "$prenom.$nom".ToLower()
    }
    $loginsUtilises += $login
    
    # Mapping département → OU et fonction → niveau
    $OU = $mapDepartement[$departement]
    $niveau = $mapNiveau[$fonction]
    
    # Redirection des prestataires
    if ($societe -ne "EcoTechSolutions") {
        $OU = "Prestataire"
    }
    
    # Vérification que le mapping a fonctionné
    if ([string]::IsNullOrWhiteSpace($OU) -or [string]::IsNullOrWhiteSpace($niveau)) {
        $compteurErreurs++
        continue
    }
    
    # Vérifier si l'utilisateur existe déjà
    try {
        Get-ADUser -Identity $login -ErrorAction Stop
        $compteurIgnores++
        continue
    } catch {}
    
    # Création de l'utilisateur
    try {
        New-ADUser -Name "$prenom $nom" `
                   -SamAccountName $login `
                   -UserPrincipalName "$login@ecotech.tssr" `
                   -Path "OU=$OU,OU=EcoTech_Users,DC=ecotech,DC=tssr" `
                   -Description $fonction `
                   -Company $societe `
                   -ErrorAction Stop
        
        $compteurCrees++
        
        # Ajout au groupe
        $nomGroupe = "grp.$OU.$niveau"
        Add-ADGroupMember -Identity $nomGroupe -Members $login
        
    } catch {
        $compteurErreurs++
    }
}

Write-Host "Utilisateurs créés : $compteurCrees" -ForegroundColor Green
Write-Host "Lignes ignorées : $compteurIgnores" -ForegroundColor Yellow
Write-Host "Erreurs : $compteurErreurs" -ForegroundColor Red
```

**Résultat** : 251 utilisateurs créés avec succès

---

### 4. Groupes globaux pour simplifier la gestion

**Création de 2 méta-groupes** :

```powershell
# Créer les groupes globaux
New-ADGroup -Name "grp.ALL.managers" -GroupScope Global -GroupCategory Security -Path "OU=EcoTech_Groups,DC=ecotech,DC=tssr"
New-ADGroup -Name "grp.ALL.users" -GroupScope Global -GroupCategory Security -Path "OU=EcoTech_Groups,DC=ecotech,DC=tssr"

# Ajouter tous les *.mgr dans grp.ALL.managers
Get-ADGroup -Filter "Name -like '*.mgr'" | ForEach-Object {
    Add-ADGroupMember -Identity "grp.ALL.managers" -Members $_.DistinguishedName
}

# Ajouter tous les *.usr dans grp.ALL.users
Get-ADGroup -Filter "Name -like '*.usr'" | ForEach-Object {
    Add-ADGroupMember -Identity "grp.ALL.users" -Members $_.DistinguishedName
}
```

**Résultat** : Gestion simplifiée des permissions via 2 groupes au lieu de 18

---

## Commandes utiles

### Vérification des services

```powershell
# Sur ARESKI
Get-Service NTDS,DNS,DHCPServer | Select Name,Status,StartType

# Depuis ARESG (à distance)
Get-Service -ComputerName ARESKI NTDS,DNS,DHCPServer
```

### Gestion des utilisateurs

```powershell
# Lister les utilisateurs par OU
Get-ADUser -Filter * -SearchBase "OU=Communication,OU=EcoTech_Users,DC=ecotech,DC=tssr"

# Compter les utilisateurs
Get-ADUser -Filter * -SearchBase "OU=EcoTech_Users,DC=ecotech,DC=tssr" | Measure-Object

# Rechercher un utilisateur
Get-ADUser -Filter "Name -like '*Gomez*'"
```

### Gestion des groupes

```powershell
# Lister les membres d'un groupe
Get-ADGroupMember -Identity "grp.Communication.mgr"

# Lister tous les groupes
Get-ADGroup -Filter * -SearchBase "OU=EcoTech_Groups,DC=ecotech,DC=tssr"
```

### Outils RSAT (depuis ARESG)

```powershell
dsa.msc      # Active Directory Users and Computers
dnsmgmt.msc  # DNS Manager
dhcpmgmt.msc # DHCP Manager
gpmc.msc     # Group Policy Management
```

---

## Points techniques résolus

### 1. Gestion des accents
**Problème** : Les accents dans les noms (Gómez) causaient des erreurs  
**Solution** : Nettoyage du CSV pour supprimer les accents

### 2. Nomenclature cohérente
**Problème** : Incohérence entre noms d'OUs et de groupes (Comptabilite vs Comptabilite/Finance)  
**Solution** : Renommage pour uniformiser sur "Comptabilite"

```powershell
# Renommer une OU
Rename-ADObject -Identity "OU=Comptabilite/Finance,OU=EcoTech_Users,DC=ecotech,DC=tssr" -NewName "Comptabilite"

# Renommer un groupe
Rename-ADObject -Identity "CN=grp.Comptabilite.mgr,OU=EcoTech_Groups,DC=ecotech,DC=tssr" -NewName "grp.ComptabiliteFinance.mgr"
```

### 3. Identification des prestataires
**Problème** : Prestataires mélangés avec employés EcoTech  
**Solution** : Redirection automatique vers OU Prestataire + champ Company rempli

### 4. Server Manager ne voit plus ARESKI
**Problème** : ARESKI disparaît de Server Manager après redémarrage  
**Solution** : Réajout manuel via Manage → Add Servers

---

## Configuration DHCP

### Scopes existants

```powershell
Get-DhcpServerv4Scope

# Résultat :
# ACROPOLE : 10.10.20.0/26 (10.10.20.1 - 10.10.20.60)
# vlan 10  : 10.15.10.0/24 (10.15.10.1 - 10.15.10.254)
```

---


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
	└─OU=Prestataire →(ni.papadopoulos) - UBIHard
│
├── ORDINATEURS (OU=Ecotech_Computers)
│   ├── ARESG ( Server 2022 GUI)-10.10.20.14
│   ├── ARESKI ( Server 2022 Core)-10.10.20.4 - DC1
│   ├── PROMETHEE (Server 2022 Core)-10.10.20.7-DC2 (
│   ├── APOLLON (Windows 10/11)
│   └── HADES (Windows 10/11)
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
 **Utilisateurs :**

- 251 users répartis dans 9 OUs (départements)
- 3 niveaux : mgr (managers), usr (standard), trv (travelers/prestataires)

**Groupes :**

- **Locaux** : grp.[Service].[niveau] (ex: grp.DSI.mgr)
- **Globaux** : grp.ALL.managers / grp.ALL.users
- **Admin** : grp.Music.Vocal/Instru (cachés)

