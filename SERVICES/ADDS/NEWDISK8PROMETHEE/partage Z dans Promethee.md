**Méthode native AD "Home Folder" :**

1. **Créer partage racine** → \PROMETHEE\Home$
2. **Dans propriétés utilisateur AD** → Onglet Profile → Home Folder
3. **Spécifier** → Lettre I: + Chemin \PROMETHEE\Home$%username%
4. **À première connexion** → AD crée dossier + applique permissions automatiquement

**Avantages :**

- Zéro pré-création manuelle
- Permissions correctes auto (utilisateur = propriétaire)
- Mappage lecteur auto
- Scalable 251 utilisateurs

**Lister structure **
```
Z:\Partages Get-ChildItem Z:\Partages -Recurse | Select FullName,PSIsContainer
```

**Vérification partages SMB actuels :**

```powershell
# Toujours sur PROMETHEE
Get-SmbShare | Where-Object {$_.Path -like "Z:*"} | Select Name,Path,Description
```
**Décomposition :**

**1. `Get-SmbShare`**

- Liste TOUS les partages SMB du serveur
- Inclut partages système (C,ADMIN, ADMIN ,ADMIN, IPC$) + partages personnalisés

**2. `|` (pipe)**

- Envoie résultat de commande 1 vers commande 2
- "Tuyau" entre cmdlets

**3. `Where-Object {$_.Path -like "Z:*"}`**

- Filtre uniquement partages dont chemin commence par "Z:"
- `$_` = objet en cours d'analyse
- `-like "Z:*"` = commence par Z: (wildcard *)
- Exclut C,ADMIN, ADMIN ,ADMIN, etc.

**4. `| Select Name,Path,Description`**

- Affiche seulement 3 colonnes :
    - **Name** = Nom du partage réseau (ex: Public,Users, Users ,Users)
    - **Path** = Chemin local (ex: Z:\Partages\Public)
    - **Description** = Commentaire




Commande création partage Home$ :



New-SmbShare -Name "Home$" -Path "Z:\Partages\Users" -FullAccess "Everyone"
```
= "Créer porte d'entrée Home$ qui ouvre sur couloir Users, tout le monde peut entrer dans le hall"

---

**3. PERMISSIONS NTFS (clés des appartements)**

**Actuellement :**
- Porte immeuble ouverte (partage Home$)
- MAIS appartements n'existent pas encore
- Permissions NTFS = système de clés individuelles

**Objectif permissions NTFS :**
```
Z:\Partages\Users\           → Admins peuvent tout voir
Z:\Partages\Users\john.doe\  → SEUL john.doe a la clé
Z:\Partages\Users\marie.martin\ → SEULE marie.martin a la clé
```

**Application :**
- Permissions racine Users\ = Administrateurs + SYSTEM + CREATOR OWNER
- CREATOR OWNER = "celui qui crée l'appartement devient propriétaire"

---

**4. HOME FOLDER AD (automatisation)**

**Dans propriétés utilisateur AD :**

User : john.doe
├── Profile tab
└── Home folder :
    ├── Drive letter : I:
    └── Connect to : \\PROMETHEE\Home$\john.doe
```

**Ce qui se passe à première connexion john.doe :**

1. John ouvre session sur client Windows
2. AD lit propriété Home Folder
3. AD vérifie si \PROMETHEE\Home$\john.doe existe
4. **NON → AD CRÉE automatiquement le dossier**
5. AD applique permissions NTFS → john.doe = propriétaire
6. AD mappe lecteur I: → pointe vers \PROMETHEE\Home$\john.doe
7. John voit lecteur I: dans "Ce PC"


```
Name     ScopeName        Path Description 
----     ---------        ---- ----------- 
Home$*   Z:\Partages\Users Dossiers individuels utilisateurs
```


on va donc faire un script que va donner les autorisations a certaines personnes ( admin et system ) et le creator lui aura tout les droits sur les ficheirs et dossiers qu'il va creer dedans mais pas sur le dossier user lui meme


**Excellent point - je dois expliquer le mécanisme complet.**

**ÉTAPE MANQUANTE = Configuration Home Folder dans AD**

**Préparation (ce qu'on va faire après le script) :**

Dans Active Directory, pour chaque utilisateur, on configure :

```
Propriétés utilisateur john.doe
└── Onglet "Profile"
    └── Home folder:
        ├── Drive letter: I:
        └── Connect to: \\PROMETHEE\Home$\john.doe
```

---

**CE QUI SE PASSE À LA PREMIÈRE CONNEXION :**

**1. John.doe ouvre session sur client Windows**

- Windows contacte DC (ARESKI ou PROMETHEE)
- Lit propriétés utilisateur john.doe

**2. Windows voit Home Folder configuré**

- Chemin : `\\PROMETHEE\Home$\john.doe`
- Lettre : I:

**3. Windows vérifie si dossier existe**

- Accès réseau à `\\PROMETHEE\Home$` (partage SMB)
- Permissions SMB Everyone → Autorisé à parcourir ✅
- Cherche sous-dossier `john.doe`
- **Résultat : N'existe pas**

**4. Windows CRÉE automatiquement le dossier**

- Exécution : Service AD en tant que john.doe (contexte utilisateur)
- Action : `New-Item \\PROMETHEE\Home$\john.doe`
- **CRÉATEUR = john.doe** (important !)

**5. Permissions NTFS appliquées automatiquement**

- Dossier nouvellement créé hérite de Z:\Partages\Users\
- CREATOR OWNER activé → john.doe devient propriétaire
- Windows remplace "CREATOR OWNER" par "ECOTECH\john.doe"
- john.doe reçoit Full Control

**6. Mappage lecteur I:**

- Windows mappe I: → `\\PROMETHEE\Home$\john.doe`
- john.doe voit lecteur I: dans "Ce PC"

---

**PERMISSIONS FINALES sur Z:\Partages\Users\john.doe\ :**

- ECOTECH\john.doe → Full Control (propriétaire)
- BUILTIN\Administrators → Full Control (hérité)
- NT AUTHORITY\SYSTEM → Full Control (hérité)
- **Tous autres utilisateurs → Aucun accès**

---

**MAGIE CREATOR OWNER :**

**Sans CREATOR OWNER :**

- Dossier créé → Permissions par défaut (Everyone, Users, etc.)
- Tous les utilisateurs pourraient accéder

**Avec CREATOR OWNER (notre config) :**

- Dossier créé par john.doe → john.doe = CREATOR
- Windows applique règle "CREATOR OWNER → Full Control"
- Remplace "CREATOR OWNER" par nom réel "john.doe"
- Isolation automatique

---

**POURQUOI ÇA MARCHE :**

**Héritage configuré dans le script :**

powershell

```powershell
"ContainerInherit,ObjectInherit"  → Sous-dossiers et fichiers héritent
"InheritOnly" (CREATOR OWNER)      → S'applique aux enfants, pas au parent
```

**Résultat :**

- Z:\Partages\Users\ → Pas de CREATOR OWNER (c'est le parent)
- Z:\Partages\Users\john.doe\ → CREATOR OWNER remplacé par john.doe