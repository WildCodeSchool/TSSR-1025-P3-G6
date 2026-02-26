


# commande 

  

```
PS C:\\Users\\wilder> Enter-PSSession -ComputerName PROMETHEE -Credential (Get-Credential)
```

---

Cette commande permet d'ouvrir une session interactive distante sur la machine **PROMETHEE**. Pour qu'elle aboutisse, plusieurs conditions techniques doivent être réunies tant sur le client que sur la cible.

Voici les points de contrôle et les actions correctives à appliquer:

---

## 1\. Prérequis sur la cible (PROMETHEE)

Le service **WinRM** (Windows Remote Management) doit être configuré et autorisé à recevoir des requêtes.

- **Activation du remoting:**Ouvrez une console PowerShell en **Administrateur** sur PROMETHEE et exécutez:
	PowerShell
	```
	Enable-PSRemoting -Force
	```
- **Vérification du service:**Assurez-vous que le service WinRM est démarré:
	PowerShell
	```
	Get-Service WinRM
	```

## 2\. Configuration du Pare-feu

Le port par défaut pour WinRM via HTTP est **5985** (ou **5986** pour HTTPS).

- Vérifiez que le pare-feu de PROMETHEE autorise le trafic entrant sur ces ports.
- `Enable-PSRemoting` crée généralement ces exceptions automatiquement.

## 3\. Gestion des TrustedHosts (Si hors Domaine)

Si vos machines ne sont pas dans un domaine Active Directory (ex: groupe de travail/Workgroup), le client doit "faire confiance" explicitement à la cible.

- **Sur votre machine locale (wilder):**Ajoutez PROMETHEE à la liste des hôtes de confiance:
	PowerShell
	```
	Set-Item WSMan:\localhost\Client\TrustedHosts -Value "PROMETHEE" -Force
	```
	*Note: Vous pouvez utiliser `*` au lieu du nom pour autoriser toutes les machines, bien que ce soit moins sécurisé.*

## 4\. Syntaxe des Identifiants

Lorsque la fenêtre `Get-Credential` s'ouvre:

- **Domaine:** Utilisez `DOMAINE\Utilisateur`
- **Local:** Utilisez `PROMETHEE\NomUtilisateur` ou `.\NomUtilisateur`

---

### Résumé du flux de connexion

| Cause fréquente | Solution |
| --- | --- |
| **Accès refusé** | Vérifiez que l'utilisateur fait partie du groupe **Administrateurs** sur PROMETHEE. |
| **Nom introuvable** | Essayez d'utiliser l'adresse IP au lieu du nom `PROMETHEE`. |
| **WinRM non configuré** | Exécutez `winrm quickconfig` sur la cible. |

**Souhaitez-vous que je vous aide à diagnostiquer un message d'erreur spécifique qui s'affiche après avoir validé vos identifiants?**

---

dans adds est ce que je pourrais directement mettre mon id et mot de passe dans (Get-?Credential)

---

Il est techniquement possible de passer les identifiants sans l'interruption de la fenêtre contextuelle, mais la méthode dépend du niveau de sécurité que vous souhaitez appliquer.

Voici les trois approches principales, de la plus automatisée à la plus sécurisée:

---

### 1\. La méthode directe (Déconseillée - Texte clair)

Vous pouvez créer un objet `PSCredential` en convertissant votre mot de passe en une chaîne sécurisée (**SecureString**).

PowerShell

```
$password = "MonMotDePasse" | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("NOM_DOMAINE\Utilisateur", $password)

Enter-PSSession -ComputerName PROMETHEE -Credential $cred
```

> **Avertissement:** Votre mot de passe apparaît en clair dans votre script ou votre historique de commandes, ce qui représente une faille de sécurité majeure.

### 2\. La méthode via fichier exporté (Recommandée pour l'automatisation)

Cette méthode permet de stocker le mot de passe chiffré dans un fichier. Seul l'utilisateur qui a créé le fichier sur cette machine spécifique pourra le lire.

- **Étape 1: Créer le fichier sécurisé (une seule fois)**
	PowerShell
	```
	Get-Credential | Export-CliXml -Path "C:\Scripts\MaConfig.xml"
	```
- **Étape 2: Utiliser le fichier dans vos commandes futures**
	PowerShell
	```
	$cred = Import-CliXml -Path "C:\Scripts\MaConfig.xml"
	Enter-PSSession -ComputerName PROMETHEE -Credential $cred
	```

### 3\. La méthode "Session persistante"

Si vous devez vous connecter souvent à la même machine dans la même journée, créez une variable de session. Vous ne taperez vos identifiants qu'une seule fois.

PowerShell

```
$session = New-PSSession -ComputerName PROMETHEE -Credential (Get-Credential)

# Ensuite, connectez-vous instantanément :
Enter-PSSession $session
```

---

### <span style="color:rgb(255, 0, 0)">Comparaison des méthodes</span>

| Méthode            | Automatisation | Sécurité  | Usage idéal                            |
| ------------------ | -------------- | --------- | -------------------------------------- |
| **Get-Credential** | Manuelle       | Élevée    | Tâches ponctuelles                     |
| **Texte clair**    | Totale         | **Nulle** | Tests rapides (à bannir en prod)       |
| **Export-CliXml**  | Totale         | Moyenne+  | Tâches planifiées / Scripts récurrents |

---

### <span style="color:rgb(0, 176, 80)">note <span style="color:rgb(0, 176, 80)">sur</span> adds racourci<br></span>

Si vous êtes dans un environnement **ADDS** et que votre session Windows actuelle utilise un compte qui a déjà les droits d'administration sur **PROMETHEE**, vous n'avez normalement pas besoin de l'argument `-Credential`.

Tapez simplement:

PowerShell

```
Enter-PSSession -ComputerName PROMETHEE
```

PowerShell utilisera automatiquement votre jeton d'authentification Kerberos actuel.

**Souhaitez-vous que je vous montre comment créer un script qui vérifie si la connexion est possible avant de tenter l'authentification?**

---

exit

---

PowerShell

```
Exit-PSSession
```

Cette commande termine votre session interactive distante et vous ramène à votre invite de commande locale (**PS C:\\Users\\wilder>**).

### Points clés après l'exit:

- **Session persistante:** Si vous avez utilisé une variable `$session` (via `New-PSSession`), la session reste active en arrière-plan sur le serveur même après le `exit`.
- **Nettoyage:** Pour fermer définitivement une session persistante et libérer les ressources, utilisez:
	PowerShell
	```
	Get-PSSession | Remove-PSSession
	```

Le ==service WinRM== utilise le nom de l’application pour sélectionner un ==écouteur== pour traiter la demande de connexion. WinRM (jeu de paramètres ComputerName) Pour établir une connexion à un ordinateur distant, l’ordinateur distant doit être à l’écoute sur le port utilisé par la connexion. Les ports par défaut sont 5985, qui est le port WinRM pour.