**Principe technique :** 
`LogonHours` est un tableau de 21 octets (3 par jour, dimanche en premier). 
Chaque bit = 1 heure.

Objectif : **7h-20h, lundi-samedi** (dimanche = bloqué toute la journée).



```powershell
$hours = New-Object byte[] 21
# Dimanche : 0x00 (bloqué)
# Lundi-Samedi : 7h-20h = 0x80, 0xFF, 0x0F
1..6 | % { $hours[$_*3]=0x80; $hours[$_*3+1]=0xFF; $hours[$_*3+2]=0x0F }
Get-ADGroupMember -Identity "grp.ALL.users" -Recursive | % { Set-ADUser -Identity $_.SamAccountName -Replace @{logonHours=$hours} }
Write-Host "Restrictions horaires appliquées"
```

## LogonHours : comment ça fonctionne

**AD stocke les horaires dans un tableau de 21 octets.**

Pourquoi 21 ? → **7 jours × 3 octets par jour**

---

**Pourquoi 3 octets par jour ?**

1 octet = 8 bits = 8 heures 3 octets = 24 bits = **24 heures** ✅

Moyen mnémotechnique : **"3 octets = 3 tranches de 8h = une journée complète"**

---

**Comment lire les bits ?**

Chaque bit = 1 heure. Si le bit est **1** → connexion autorisée. Si **0** → bloquée.

```
Octet 1 (heures 0-7)   : 10000000 = 0x80 → seulement h7 autorisée
Octet 2 (heures 8-15)  : 11111111 = 0xFF → toutes autorisées (h8 à h15)
Octet 3 (heures 16-23) : 00001111 = 0x0F → h16 à h19 autorisées
```

Ensemble : **h7 à h19 = 7h à 20h** ✅

Mnémotechnique : **"0x80 démarre, 0xFF plein gaz, 0x0F freine"**

---

**Ordre des jours dans AD**

AD commence par **dimanche** (convention américaine) :

```
Index 0  → Dimanche  (0x00 0x00 0x00 = bloqué)
Index 1  → Lundi     (0x80 0xFF 0x0F)
Index 2  → Mardi     (0x80 0xFF 0x0F)
...
Index 6  → Samedi    (0x80 0xFF 0x0F)
```

Mnémotechnique : **"AD pense américain : Sunday first"**

---

Tu as compris la logique ? Je t'explique la commande ligne par ligne avant qu'on la lance.

ok

18:25

Prepared to dissect command syntax systematically

Good, now I'll explain the command line by line.

Terminé

## La commande décortiquée

powershell

```powershell
$hours = New-Object byte[] 21
```

→ Crée un tableau de 21 octets, tous à **0** par défaut = **tout bloqué** pour tout le monde.

---

powershell

```powershell
1..6 | % { ... }
```

→ Boucle de 1 à 6 = **lundi à samedi** (dimanche = index 0, on ne le touche pas → reste 0x00 = bloqué).

Mnémotechnique : **"1 à 6 = lundi à samedi, 0 = dimanche on l'oublie"**

---

powershell

```powershell
$hours[$_*3]   = 0x80
$hours[$_*3+1] = 0xFF
$hours[$_*3+2] = 0x0F
```

→ Pour chaque jour, on remplit ses 3 octets :

- `$_*3` = premier octet du jour (heures 0-7) → `0x80` = seulement h7 ouverte
- `$_*3+1` = deuxième octet (heures 8-15) → `0xFF` = tout ouvert
- `$_*3+2` = troisième octet (heures 16-23) → `0x0F` = h16 à h19 ouvertes

---

powershell

```powershell
Get-ADGroupMember -Identity "grp.ALL.users" -Recursive | % {
    Set-ADUser -Identity $_.SamAccountName -Replace @{logonHours=$hours}
}
```

→ Pour chaque user dans le groupe, on applique le tableau d'heures.

---

**Tu as compris les 4 blocs ? On lance ?**