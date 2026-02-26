
# prendre en main PROMETHEE

```
Enter-PSSession -ComputerName 10.10.20.7 -Credential (Get-Credential)

```





# permission du dossier partage

```
Get-SmbShareAccess -Name "Partages$"
```


# qui sont admins ?


```
 Get-ADGroupMember -Identity "Domain Admins" | Select-Object Name,SamAccountName
```

# quels sont les droits d'un user

```
Get-ADUser -Identity wilder -Properties MemberOf | Select-Object -ExpandProperty MemberOf   
```

# mettre un user wilder admin

```
Add-ADGroupMember -Identity "Domain Admins" -Members "wilder"
```


# tester le partage 
 

```
Test-Path"\\PROMETHEE\Partages$\Public\Wallpapers\LOGO_ECOTECH_USER.png"
```


# voir les gpo sur une session

```
gpresult /r
```


structure de OU

```
Get-ADOrganizationalUnit -Filter * | Select-Object Name,DistinguishedName | Format-Table -AutoSize
```


affiche 3 groupes  "*manager* *user* *standart*"


```
Get-ADGroup -Filter "Name -like '*manager*' -or Name -like '*user*' -or Name -like '*standard*'" -SearchBase "OU=Ecotech_Groups,DC=ecotech,DC=tssr" | Select-Object Name,DistinguishedName
```

forcer un mot de passe long Azerty1*2025
arrete le chgment de mdp au logon

```
Set-ADAccountPassword -Identity ad.bakir -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "Azerty1*2025*" -Force)
Set-ADUser -Identity xx.xxxxxx -ChangePasswordAtLogon $false
```
- `Set-ADAccountPassword` : cmdlet pour modifier un mot de passe AD
- `-Identity ad.bakir` : cible l'utilisateur ad.bakir
- `-Reset` : force le reset (pas besoin de l'ancien mot de passe)
- `-NewPassword` : nouveau mot de passe à définir
- `ConvertTo-SecureString -AsPlainText "Azerty1*" -Force` : convertit le texte en chaîne sécurisée (format requis par AD)

reactive le compte

```
Get-ADUser -Identity xx.xxxxx | Select-Object Name,Enabled
Enable-ADAccount -Identity xx.xxxx
Unlock-ADAccount -Identity ma.zhang
```
Ce sont deux choses différentes :

**`Enable-ADAccount`** agit sur l'attribut `Enabled` — il active ou désactive un compte. Si le compte est déjà activé (`Enabled = True`), cette commande ne change rien.

**`Unlock-ADAccount`** agit sur l'attribut `lockoutTime` — il déverrouille un compte qui a été bloqué automatiquement après trop de tentatives de connexion échouées (GPO lockout).

Un compte peut donc être **activé ET verrouillé en même temps** — c'est exactement ce qui s'est passé avec `ma.zhang` : compte actif, mais verrouillé par la GPO à cause des multiples tentatives d'auth échouées cette nuit.

---

connaitre interface reseau d'une machine

```
Get-NetAdapter | Select-Object Name,InterfaceIndex,Status
```

ajoute le dns a une machine

```
Set-DnsClientServerAddress -InterfaceIndex X -ServerAddresses 10.10.XX.XX
```

donne la config d'une interface X

```
Get-NetIPConfiguration -InterfaceIndex x
```


voir les enregistrements dns 

```
Resolve-DnsName ecotech.tssr
```

connexion en PSRemoting :

```
Enter-PSSession -ComputerName PROMETHEE -Credential (Get-Credential)

ou

Enter-PSSession -ComputerName 10.10.20.5 -Credential (Get-Credential)
```
pour savoir qui on est ??
```
hostname
```

pour connaitre les disks

```
Get-Disk 
```

Initialisation et formatage du disque


```
$disk = Get-Disk | Where-Object PartitionStyle -eq 'RAW'

Initialize-Disk -Number $disk.Number -PartitionStyle GPT

New-Partition -DiskNumber $disk.Number -UseMaximumSize -DriveLetter D

Format-Volume -DriveLetter D -FileSystem NTFS -NewFileSystemLabel "Partages" -Confirm:$false
```
exemples de creations de x dossier  dans Z:\
```
New-Item -Path "Z:\Partages" -ItemType Directory
New-Item -Path "Z:\Partages\Direction" -ItemType Directory
New-Item -Path "Z:\Partages\RH" -ItemType Directory
New-Item -Path "Z:\Partages\Comptabilite" -ItemType Directory

```