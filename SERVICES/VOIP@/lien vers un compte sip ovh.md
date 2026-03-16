Pour infos reglages des port sip 

![](ressources/Reglages_ports_sip.png)
![](Install%20SIP/recoOVH6.png)

![](ressources/IMG_2581.jpg)





# lien vers un compte sip ovh

clique sur connectivite / trunk 

![](ressources/trunk%20sip.png)

### remplir les infos![](ressources/trunk_sip2.png)![](ressources/trunk_sip3.png)

### Onglet mode Avancée remplir Contact user puis Domain 


![](ressources/trunk_sip4.png)

###  Soumettre   
![](ressources/trunk_sip5.png)

### Appliquer la configuration en rouge en haut a droite 

## reglages de la redirection de port sur la box 

![](ressources/trunk_sipconfig%20_box.png)


comme il y a conflit dans la box sur le port 4060 on passe sur 4061 donc il faut faire la modif sur asterix port listening

allez faire le reglages  dans parametre / parametre SIP d'asterix / port to listen on
![](ressources/config-port-d-ecoute%206.png)![](ressources/trunk_sipreglageparefeusortant.png)![](ressources/trunk_sipreglageparefeusortant2.png)