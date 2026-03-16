### Tout d'abord , install en core une iso windows server 2022 avec un disque systeme et un disque pour les future mise a jours


j'ai opté pour 50 giga et 20 giga pour le systeme core
N'oublier pas la carte reseau...

![](Ressources/InstallWSUS0A.png)
![](Ressources/InstallWSUS0.png)

![](Ressources/InstallWSUS.png)


### changer le nom (2)
![](Ressources/InstallWSUS2.png)

### affecter ce server dans le domaine Ecotech.tssr(1)
![](Ressources/InstallWSUS3.png)![](Ressources/InstallWSUS4.png)

![](Ressources/InstallWSUS5.png)![](Ressources/InstallWSUS.6png.png)

Une fois configurer passer sur une console qui administre graphiquement les serveurs .
On ajoute le server dans la console
![](Ressources/SERVER1.png)![](Ressources/SERVER2.png)

## filessystem et partition#

![](Ressources/disk1.png)

```
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter W
```

![](Ressources/disk2.png)![](Ressources/disk3.png)![](Ressources/disk4.png)
# PARE FEU#

on doit desactiver le pare feu pour pouvpor communiquer sur le port 8531 en tcp : 


```
New-NetFirewallRule -DisplayName "WSUS HTTPS" -Direction Inbound -LocalPort 8531 -Protocol TCP -Action Allow

```
![](Ressources/parefeu1.png)

## Administration de HERAKLES PAR ARESG

![](Ressources/mamangement0.png)
Activation de l'administration distante sur HERAKLES Absolument, nous restons sur **HERAKLES**. Pour lever le blocage que vous voyez sur votre capture d'écran depuis **ARESG**, nous devons autoriser les groupes de règles spécifiques à l'administration distante via l'interface RPC/DCOM. 


```powershell 

Enable-NetFirewallRule -DisplayGroup "Remote Event Log Management", "Remote Service Management", "Remote Volume Management"
```
![](Ressources/mamangement1.png)![](Ressources/mamangement2.png)

Ok maintenant attachons un le role  wsus a HERAKLES![](Ressources/WSUS0.png)![](Ressources/WSUS1.png)![](Ressources/WSUS3.png)![](Ressources/WSUS4.png)