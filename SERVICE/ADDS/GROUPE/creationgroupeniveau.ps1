$services = @("Direction", "Developpement","RH","Comptabilite", "Commercial","Communication","DSI","Prestataire","Accueil")
$niveaux = @("mgr", "usr", "trv")
foreach ($service in $services)

{
    foreach ($niveau in $niveaux)
     {
             try
                     {
                        $nomGroupe = "grp.$service.$niveau"
                        New-ADGroup -Name $nomGroupe -GroupScope Global -GroupCategory Security -Path "OU=Ecotech_Groups,DC=ecotech,DC=tssr"
                        Write-Host "Création du GROUPE $nomGroupe dans l'OU ou=$service,DC=ecotech,DC=tssr"-ForegroundColor Green
        
                     }
            catch
                     {
                        Write-Host "Erreur lors de la crÃ©ation de $nomGroupe : $_" -ForegroundColor Red
                     }

      }
}
  