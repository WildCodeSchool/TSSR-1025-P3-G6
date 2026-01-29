C'est une excellente initiative. L'Active Directory (AD DS) est le cœur de ton réseau d'entreprise.

Puisque tu utilises **Windows Server Core** (Hades), tu vas tout faire en **PowerShell**. C'est beaucoup plus rapide et c'est exactement ce qu'on attend d'un admin système moderne.

Voici ta **Checklist de vol** avant de lancer l'installation. Si tu loupes l'étape 1 ou 2, ton domaine sera instable.

### Étape 1 : Préparation de la VM (CRITIQUE)

Un Contrôleur de Domaine (DC) est la boussole du réseau. Il ne doit **jamais** changer de nom ni d'adresse IP une fois promu.

**1. Renommer le serveur** Par défaut, Windows a un nom horrible (WIN-X45F...). Donne-lui un nom propre.

PowerShell

```
Rename-Computer -NewName "HADES-DC01" -Restart
```

_(La VM va redémarrer)._

**2. Fixer l'IP (Si ce n'est pas déjà fait)** L'AD ne supporte pas le DHCP pour un contrôleur de domaine.

- **IP :** Une adresse fixe dans ton VLAN serveur (ex: `10.15.10.10`).
    
- **DNS :** **127.0.0.1**. C'est le point le plus important. Un DC doit s'interroger lui-même pour le DNS.
    

PowerShell

```
# Exemple (adapte les valeurs à ton plan d'adressage)
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.15.10.10 -PrefixLength 24 -DefaultGateway 10.15.10.254
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1
```

---

### Étape 2 : Installation du Rôle AD DS

Une fois reconnecté (après le renommage), installe les binaires du service.

PowerShell

```
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

---

### Étape 3 : Promotion en Contrôleur de Domaine

C'est ici que tu crées ta "Forêt" (ton nouvel univers Active Directory). Choisis bien ton nom de domaine racine (ex: `bizance.local`, `corp.lan`). Évite `.com` ou `.fr` pour un lab interne pour ne pas entrer en conflit avec de vrais sites web.

Lance ce script PowerShell :

PowerShell

```
# Remplace "bizance.local" par ton nom de domaine
Install-ADDSForest `
-DomainName "bizance.local" `
-DomainNetbiosName "BIZANCE" `
-InstallDns $true `
-NoRebootOnCompletion $false `
-Force $true
```

- **Il va te demander un mot de passe (SafeModeAdministratorPassword) :** C'est le mot de passe de secours ultime si l'AD casse. Ne le perds pas.
    
- La VM va redémarrer automatiquement. Ce redémarrage sera **long** (Windows construit la base de données). C'est normal.
    

---

### Étape 4 : La configuration Post-Install (DNS)

Une fois que HADES est revenu :

1. Connecte-toi avec `BIZANCE\Administrateur` (ou ton compte admin local qui est devenu admin du domaine).
    
2. **Problème :** Ton serveur sait résoudre les noms locaux, mais il ne sait plus aller sur Internet car son DNS est `127.0.0.1`.
    
3. **Solution :** Configurer un "Redirecteur" (Forwarder) DNS vers Google ou ton pfSense.
    

PowerShell

```
# Ajoute le DNS de Google (ou ton pfSense 10.10.0.2) comme relais
Add-DnsServerForwarder -IPAddress 8.8.8.8, 8.8.4.4 -PassThru
```

### Résumé des commandes pour HADES

1. `Rename-Computer`
    
2. `New-NetIPAddress` (IP Fixe)
    
3. `Set-DnsClientServerAddress` (127.0.0.1)
    
4. `Install-WindowsFeature AD-Domain-Services`
    
5. `Install-ADDSForest`
    

Tu te sens prêt à lancer la commande de promotion ? Dis-moi quel nom de domaine tu as choisi !