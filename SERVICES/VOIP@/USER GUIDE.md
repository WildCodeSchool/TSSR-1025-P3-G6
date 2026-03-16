![](ressources/freepbx%20page%20admin1.png)

si vous perdez la main pdt la config essaye en CLI , il se peut que le firewall se soit activé

```
fwconsole firewall stop
```

**Abort le firewall** et nous arrivons sur le panneau de config

![](ressources/PANNEAU_config_1.png)![](ressources/PANNEAU_config_ok.png)


dans Admin/system Admin on peut activer freepbx pour récuperer **le trial de 15 jours** 



![](ressources/Activation.png)![](ressources/Activationok.png)


maintenant faisons **la mise a jour :**


![](ressources/miseajour.png)

et encore quelque mise a jour

![](ressources/majsuite.png)

maintenant ajoutons des **postes SIP** 
rendez vous dans **Applications /postes**

![](ressources/OngletExtensionsdans%20aplications%20(postes).png)![](ressources/ajout_de_nouveaux_poste_SIP.png)![](ressources/ajout_de_nouveaux_poste_SIP.png)![](ressources/5ajout_de_nouveaux_poste_SIP.png)


Apres avoir installer les terminaux sip dans vos vm, lancer un appel .
## A vous de parler 
![](ressources/APPELOk.png)![](ressources/appelwinubu.png)![](ressources/APPELUBUNTUWIN4.png)


# Renvoi d'appel

dans Aplications / Suivez moi 
Active le poste que vous voulez renvoyer .![](ressources/Renvoi1.png)

pour le initial ring time 
![](ressources/Renvoi2.png)

a la fin n'oubliez pas de cliquer sur "envoyer" sinons vos réglages ne seront pas pris en compte .