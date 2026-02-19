Pour genérer cette restriction , on passe par une commande qui va s'appliquer sur un choix de user parmi les users de ecotech.tssr .
On veut que soit appliqué une restriction d'horaire de 20h00 à 7h00 pour les personnes non managers cadres de l'ensemble des employés de Ecotech.tssr

chaque jour se voit attribué 3 case d'un tableau de 21 cases ( 7x3 )
chaque case représente une plage horaire donc 3 plages horaire de 8 heures 
pour un jour codées sur 8 bits et transcodée en hexadécimal
Octet 1 (heures 0-7)   : 10000000 = 0x80 → seulement h7 autorisée
Octet 2 (heures 8-15)  : 11111111 = 0xFF → toutes autorisées (h8 à h15)
Octet 3 (heures 16-23) : 00001111 = 0x0F → h16 à h19 autorisées

jour 0 case 0 a 2  	dimanche	 	=> 0x00 (bloqué)
jour 1 case 3 a 5	lundi 7h-20h 	=>0x80, 0xFF, 0x0F
jour 2 case 6 a 8 	mardi 7h-20h 	=> 0x80, 0xFF, 0x0F
jour 3 case 9 a 11 	mercredi 7h-20h 	=> 0x80, 0xFF, 0x0F
jour 4 case 12 a 14 	jeudi 7h-20h	=> 0x80, 0xFF, 0x0F
jour 5 case 15 a 18 	vendredi 7h-20h	=> 0x80, 0xFF, 0x0F
jour 6 case 19 a 21 	samedi 7h-20h 	=> 0x80, 0xFF, 0x0F

```
$hours = New-Object byte 21
```
cette commande correspond à la création d'un tableau de 21 cases de case a 0


```
1..6 | % { hours[*3]=0x80; hours[3+1]=0xFF; hours[_*3+2]=0x0F }
```

jour 1 a 6  le premier octet à 0x80 le second à 0xFF et le troisième à 0x0F
jour 0 on en parle pas donc reste à 0
( le % corespond a une boucle ForEach)


Maintenant qu'on a rempli le tableau on l'applique sur le tableau de logon des objets user choisis
Ici ce sera sur groupe grp.ALL.users seulement car on laisse le droit aux managers de manager la nuit ..


```
Get-ADGroupMember -Identity "grp.ALL.users" -Recursive | % { Set-ADUser -Identity _.SamAccountName -Replace @{logonHours=hours} }

```