# GPO - Administrateur Local DSI - Récapitulatif

## Objectif

Rendre les membres des groupes DSI **administrateurs locaux** sur toutes les machines clientes du domaine, via une GPO.

---

## Infrastructure concernée

- **ARESG** : Station d'administration (gpmc.msc, dsa.msc)
- **ARESKI / PROMETHEE** : DCs du domaine ecotech.tssr
- **APOLLON** : Machine cliente Windows (machine de test)

---

## Ce qui a été fait

### 1. Déplacement d'APOLLON dans l'OU Ecotech_Computers

Via `dsa.msc` :
- Clic droit sur APOLLON → Move → Ecotech_Computers
- Même chose pour ARESG et HADES

---

### 2. Création de la GPO

Via `gpmc.msc` sur ARESG :
- Clic droit sur **Group Policy Objects** → New
- Nom : `grp.ou.dsi.adminlocal.computer`
- Liée à l'OU **Ecotech_Computers**

---

### 3. Configuration de la GPO (Restricted Groups)

Chemin dans l'éditeur GPO :
```
Computer Configuration
└── Policies
    └── Windows Settings
        └── Security Settings
            └── Restricted Groups
```

**Configuration** :
- Clic droit sur Restricted Groups → **Add Group**
- Groupe cible : `Administrators` (groupe local de la machine)
- Dans **"Members of this group"** :
  - `ecotech\Domain Admins`
  - `ecotech\grp.DSI.mgr`
  - `ecotech\grp.DSI.usr`

> ⚠️ **Important** : `Domain Admins` est **obligatoire** dans la liste. Sans lui, la GPO supprimerait Domain Admins du groupe local Administrators → perte d'accès admin !

---

### 4. Lien de la GPO

- GPO liée à **Ecotech_Computers** (pas à la racine du domaine)
- Security Filtering : **Authenticated Users**
- Link Enabled : **Yes**

---

### 5. Application de la GPO

Sur APOLLON :
```powershell
gpupdate /force
Restart-Computer
```

---

## Commandes de vérification

### Vérifier les GPO appliquées sur une machine
```powershell
# Paramètres ordinateur uniquement
gpresult /scope:computer /r

# Rapport HTML complet
gpresult /h C:\gpo_report.html
```

### Vérifier les membres du groupe Administrators local
```powershell
# Par SID (universel, toutes langues)
Get-LocalGroupMember -SID "S-1-5-32-544"

# Par nom (français)
Get-LocalGroupMember -Group "Administrateurs"

# Par nom (anglais)
Get-LocalGroupMember -Group "Administrators"
```

### Forcer la réplication AD entre DCs
```powershell
Invoke-Command -ComputerName ARESKI -ScriptBlock { repadmin /syncall }
```

---

## Points techniques importants

### SID du groupe Administrators
```
S-1-5-32-544
│ │ │  │  │
│ │ │  │  └─ 544 = Administrators
│ │ │  └──── 32 = BUILTIN (groupes locaux prédéfinis)
│ │ └─────── 5 = NT AUTHORITY
│ └────────── 1 = Version du SID
└──────────── S = Security Identifier
```

Le SID est **universel** : fonctionne sur toutes les machines Windows quelle que soit la langue.

Pour l'utiliser dans Restricted Groups : `*S-1-5-32-544` (avec l'astérisque `*`).

### Pourquoi Restricted Groups remplace tout

Quand Restricted Groups est configuré, Windows **remplace complètement** la liste des membres du groupe local par ce que la GPO définit.

**Conséquence** : Si Domain Admins n'est pas dans la liste GPO → il sera supprimé du groupe Administrators local !

### Différence entre les deux sections de Restricted Groups

- **"Members of this group"** → Qui est DANS le groupe (ce qu'on utilise)
- **"This group is a member of"** → De quels groupes ce groupe fait partie (rarement utilisé)

---

## Problèmes rencontrés et solutions

### GPO appliquée mais pas effective

**Cause** : La GPO listait les membres mais sans spécifier **dans quel groupe** les mettre (pas de groupe cible "Administrators" défini).

**Solution** : Reconfigurer en ajoutant d'abord le groupe `Administrators` via Add Group, puis ajouter les membres dedans.

### GPO marquée "Appliqué : Non" dans le rapport HTML

**Cause** : Réplication AD non terminée entre les DCs.

**Solution** :
```powershell
Invoke-Command -ComputerName ARESKI -ScriptBlock { repadmin /syncall }
# Puis sur la machine cliente :
gpupdate /force
```

### WinRM non activé sur APOLLON

**Erreur** : `CannotConnect,PSSessionStateBroken`

**Solution** : Sur APOLLON en local :
```cmd
winrm quickconfig
```

---

## Machines qui ne doivent PAS être jointes au domaine AD

- **ATHENA** (routeur Debian) → géré en SSH
- **Machines Linux** (APOLLONIA, etc.) → les GPO Windows ne s'appliquent pas sur Linux
- **Les DCs** → ne jamais appliquer cette GPO sur les DCs

---

## À faire (rappels)

- [ ] Vérifier que `Get-LocalGroupMember -SID "S-1-5-32-544"` retourne bien les groupes DSI après redémarrage d'APOLLON
- [ ] Créer un sous-dossier **"Managers"** dans chaque dossier de département (accessible uniquement par les groupes `*.mgr`)
- [ ] Structure prévue :
```
\\Serveur\Partages\
├── Communication\
│   ├── Managers\     ← uniquement grp.Communication.mgr
│   └── Commun\       ← tous les users de Communication
├── RH\
│   ├── Managers\
│   └── Commun\
├── DSI\
│   ├── Managers\
│   └── Commun\
└── ... (même structure pour les 9 services)
```

---

## Prochaines étapes (autres fils)

- **Fil GPO/Serveur de fichiers** : Dossiers partagés, permissions NTFS, fonds d'écran par service
- **Fil pfSense** : Validation sortie Internet
- **Fil WSUS** : Configuration des mises à jour
