## Commandes utiles sur ARESG

powershell

```powershell
# Active Directory Users and Computers
dsa.msc

# DNS Manager
dnsmgmt.msc

# DHCP Manager
dhcpmgmt.msc

# Group Policy Management
gpmc.msc
```

Toutes ces commandes s'exécutent sur **ARESG** et gèrent **nos 3 serveurs core** à distance


Pour attribuer un rsat a un serveur :

```
Install-WindowsFeature -Name GPMC,RSAT-AD-Tools -IncludeAllSubFeature
```