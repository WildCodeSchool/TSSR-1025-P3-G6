# ECOTECH — VLAN Dynamique — Session 1
## Date : 03/03/2026

---

## Objectif

Mettre en place une attribution dynamique de VLAN en fonction du département de l'utilisateur connecté.
Quand un utilisateur se connecte sur une VM du réseau HERCULE, le système détecte son OU dans l'AD et reconfigure automatiquement l'interface réseau vers le bon VLAN.

---

## Architecture retenue

### Pourquoi pas le 802.1X ?
VirtualBox ne supporte pas le tagging 802.1Q natif depuis les VMs. Le 802.1X avec OVS/hostapd est trop complexe en environnement virtualisé. On simule l'attribution VLAN via un script PowerShell GPO.

### Flux de fonctionnement
```
VM démarre → IP statique 10.15.99.x (VLAN 99 quarantaine)
    ↓
Utilisateur se connecte au domaine
    ↓
Script GPO Logon s'exécute
    ↓
Interrogation AD → détection OU département
    ↓
Changement IP → 10.15.XX.10 (VLAN du département)
    ↓
SSH SYSTEM → ATHENA → ajout route /32
    ↓
Montage partage Z: \\PROMETHEE\Partages$
    ↓
Accès aux dossiers du département
```

---

## Mapping VLAN / Département

| VLAN | Département | Subnet | Passerelle |
|------|-------------|--------|------------|
| 10 | Direction | 10.15.10.0/24 | 10.15.10.1 |
| 20 | Développement | 10.15.20.0/24 | 10.15.20.1 |
| 30 | RH | 10.15.30.0/24 | 10.15.30.1 |
| 40 | Comptabilité | 10.15.40.0/24 | 10.15.40.1 |
| 50 | Commercial | 10.15.50.0/24 | 10.15.50.1 |
| 60 | Communication | 10.15.60.0/24 | 10.15.60.1 |
| 70 | DSI | 10.15.70.0/24 | 10.15.70.1 |
| 80 | Prestataire | 10.15.80.0/24 | 10.15.80.1 |
| 90 | Accueil | 10.15.90.0/24 | 10.15.90.1 |
| 99 | Quarantaine | 10.15.99.0/24 | 10.15.99.1 |

---

## Réalisations

### 1. VLAN 99 Quarantaine sur ATHENA

Ajout dans `/etc/network/interfaces` :

```
# VLAN 99 : Quarantaine (trafic non tagué)
auto br99
iface br99 inet static
    address 10.15.99.1/24
    bridge_ports enp0s9
    bridge_stp off
    bridge_fd 0
```

> ⚠️ `bridge_ports enp0s9` (pas enp0s9.99) pour recevoir le trafic non tagué des VMs VirtualBox.

Activation sans redémarrage :
```bash
sudo ifup br99
```

---

### 2. DHCP Relay sur ATHENA

Installation :
```bash
sudo apt install isc-dhcp-relay -y
```

Configuration :
- Serveurs DHCP : `10.10.20.4 10.10.20.7` (ARESKI + PROMETHEE)
- Interfaces : vide (toutes les interfaces broadcast)
- Options supplémentaires : vide

---

### 3. Scope DHCP VLAN 99 sur ARESKI

Via `dhcpmgmt.msc` sur ARESG :

| Paramètre | Valeur |
|-----------|--------|
| Nom | VLAN99-Quarantaine |
| Réseau | 10.15.99.0/24 |
| Plage | 10.15.99.10 → 10.15.99.50 |
| Passerelle | 10.15.99.1 |
| DNS | 10.10.20.4 |
| Domaine | ecotech.tssr |

---

### 4. Routes statiques sur ARESKI et PROMETHEE

Commande PowerShell (sur chaque DC) :
```powershell
New-NetRoute -InterfaceAlias "Ethernet" -DestinationPrefix "10.15.0.0/16" -NextHop 10.10.20.1
```

> Une seule route /16 couvre tous les VLANs 10.15.x.x.

---

### 5. Problème double passerelle sur HADES

HADES avait deux passerelles par défaut :
- NAT VirtualBox (10.0.2.2) → métrique 25 (prioritaire)
- ATHENA (10.15.99.1) → métrique 281

Le trafic partait par la NAT au lieu d'ATHENA.

**Solution** : supprimer la passerelle NAT pour la démo :
```powershell
route delete 0.0.0.0 mask 0.0.0.0 10.0.2.2
```

> ⚠️ La carte NAT reste utile pour l'installation de logiciels. Ne pas la supprimer définitivement.

---

### 6. Route /32 sur ATHENA

Problème : quand HADES change son IP en 10.15.70.10, ATHENA envoie les réponses vers br70 au lieu de br99 (HADES est physiquement sur br99).

**Solution** : ajouter une route hôte /32 sur ATHENA :
```bash
sudo ip route add 10.15.70.10/32 dev br99
```

> Cette commande sera exécutée automatiquement par le script via SSH.

---

### 7. SSH sans mot de passe depuis SYSTEM vers ATHENA

**Génération clé SSH sous SYSTEM via PsExec** :
```powershell
# Lancer PsExec
C:\PSTools\PsExec.exe -i -s powershell.exe

# Dans la fenêtre SYSTEM
New-Item -ItemType Directory -Path "C:\Windows\System32\config\systemprofile\.ssh"
ssh-keygen -t rsa -b 4096 -f "C:\Windows\System32\config\systemprofile\.ssh\id_rsa"
```

**Copie de la clé publique sur ATHENA** :
```bash
echo "ssh-rsa AAAA..." >> ~/.ssh/authorized_keys
```

**sudo sans mot de passe pour ip route sur ATHENA** :
```bash
echo "wilder ALL=(ALL) NOPASSWD: /sbin/ip route add *" | sudo tee /etc/sudoers.d/iproute
```

**Test de la connexion SSH depuis SYSTEM** :
```powershell
ssh -i "C:\Windows\System32\config\systemprofile\.ssh\id_rsa" wilder@10.15.99.1 "sudo ip route add 10.15.70.20/32 dev br99"
```

---

### 8. Détection OU sans module RSAT

HADES est Windows 10 sans RSAT. Utilisation des classes .NET intégrées :

```powershell
$searcher = New-Object DirectoryServices.DirectorySearcher
$searcher.Filter = "(&(objectClass=user)(sAMAccountName=$env:USERNAME))"
$result = $searcher.FindOne()
$dn = $result.Properties["distinguishedname"][0]
$ou = ($dn -split ',')[1] -replace 'OU=',''
```

Test validé avec `ya.tsai` → `DSI` ✅

---

### 9. Accès partage PROMETHEE

```powershell
net use Z: \\10.10.20.7\Partages$
```

Structure des partages :
```
Z:\
├── Direction\
├── Developpement\
├── RH\
├── Comptabilite\
├── Commercial\
├── Communication\
├── DSI\
├── Prestataire\ (Clients)
├── Accueil\ (Public)
├── Managers\
└── Users\
```

---

## Points importants à retenir

- **Double passerelle VirtualBox** : toujours vérifier avec `route print` que la NAT ne prend pas la priorité sur ATHENA
- **Route /32** : indispensable sur ATHENA pour que les réponses reviennent vers la bonne interface
- **SSH SYSTEM** : la clé est dans `C:\Windows\System32\config\systemprofile\.ssh\`
- **Partage caché** : le partage s'appelle `Partages$` (avec le $)
- **net use en admin élevé** : le lecteur n'est pas visible dans l'Explorateur — utiliser un PowerShell non élevé

---

## Prochaine session

- Écrire le script PowerShell logon complet
- Écrire le script PowerShell logoff (retour quarantaine)
- Créer les GPO Logon/Logoff sur ARESG
- Gérer les droits d'accès sur les dossiers PROMETHEE
- Créer les scopes DHCP pour les VLANs 10 à 90 sur ARESKI
- Tester le scénario complet de démo

---

*EcoTech Solutions — TSSR CCP — Session VLAN Dynamique 03/03/2026*
