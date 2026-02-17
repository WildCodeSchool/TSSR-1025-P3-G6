# Créer les 2 groupes globaux
New-ADGroup -Name "grp.ALL.managers" -GroupScope Global -GroupCategory Security -Path "OU=EcoTech_Groups,DC=ecotech,DC=tssr"
New-ADGroup -Name "grp.ALL.users" -GroupScope Global -GroupCategory Security -Path "OU=EcoTech_Groups,DC=ecotech,DC=tssr"

# Ajouter tous les groupes *.mgr dans grp.ALL.managers
Get-ADGroup -Filter "Name -like '*.mgr'" | ForEach-Object {
    Add-ADGroupMember -Identity "grp.ALL.managers" -Members $_.DistinguishedName
    Write-Host "✓ Ajouté : $($_.Name)" -ForegroundColor Green
}

# Ajouter tous les groupes *.usr dans grp.ALL.users
Get-ADGroup -Filter "Name -like '*.usr'" | ForEach-Object {
    Add-ADGroupMember -Identity "grp.ALL.users" -Members $_.DistinguishedName
    Write-Host "✓ Ajouté : $($_.Name)" -ForegroundColor Green
}

Write-Host "`nGroupes créés avec succès !" -ForegroundColor Cyan