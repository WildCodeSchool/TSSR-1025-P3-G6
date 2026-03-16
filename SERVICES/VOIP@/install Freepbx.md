

## Installation

Au démarrage de la VM, dans la liste, choisir la version **recommandée**. 

![image de choix de version](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-01.png?raw=true)

Puis sélectionner `Graphical Installation - Output to VGA`.  
![Choix de l'installation graphique](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-02.png?raw=true)

Enfin choisir `FreePBX Standard`  

![Choix de l'installation standard](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-03.png?raw=true)

Pendant l'installation, il faut configurer le mot de passe root (`Root password is not set` s'affiche).  
![](ressources/A4.png)
![Alerte du mot de passe root à changer](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-04.png?raw=true)

Clique sur `ROOT PASSWORD` et entre un mot de passe (robuste, est-il besoin de le préciser ?) pour le compte root.

Le clavier est en anglais donc attention aux lettres des touches du clavier QWERTY !

![Alerte du mot de passe root à changer](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-05.png?raw=true)

Indication que le mot de passe root a été changé :  

![Indication que le mot de passe a été changé](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-06.png?raw=true)

L'installation continue et se termine.  

![Fin de l'installation](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-07.png?raw=true)

Éteindre la VM, enlever l'ISO du lecteur et redémarrer la VM.  

![prompt|294](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-08.png?raw=true)Connecte toi en root.

### [](https://odyssey.wildcodeschool.com/quests/2790/pages/10087#modification-de-la-langue-du-clavier)Modification de la langue du clavier

La commande `localectl` donne les informations suivantes :

```
System Locale: LANG=en_US.UTF-8
    VC Keymap: us
   X11 Layout: us
```

Vérifie avec la commande `localectl list-locales` que tu as bien `fr_FR.utf8` dans la liste qui s'affiche.

Ecrit les lignes de commandes suivantes pour mettre le clavier en français :

```
localectl set-locale LANG=fr_FR.utf8
localectl set-keymap fr
localectl set-x11-keymap fr
```

Vérifie avec la commande `localectl` :

```
System Locale: LANG=fr_FR.UTF-8
    VC Keymap: fr
   X11 Layout: fr
```![](install_ok%20.png)![](install_ok%20.png)```

````
``

![](ressources/install_ok%20.png)![](ressources/sshconnectionroot.png)

si vous etes en user standart et que au demarrage , les interfaces reseaux sont eteintes alors passez en root pour allumer les interfaces avec 

```
ifup eth<nbre>
verifier le up avec ip a 
```

![](ressources/FREEPBX%20page%20cli.png)

on se connecte sur son adresse ip 
ici 10.10.20.12. et on arrive sur l'interface graphique 
on passe sur user Guide .
merci
![](ressources/freepbx%20page%20admin2.png)


