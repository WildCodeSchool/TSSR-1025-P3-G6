## 251 créés

j'ai importé les utilisateurs a partir du fichier user.csv

# Convention de login
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

````


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





