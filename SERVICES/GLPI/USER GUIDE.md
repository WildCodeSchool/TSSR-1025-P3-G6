Connexion en gui avec l'adresse glpi.ecotech.tssr

![](Ressources/InterfaceGLPI1.png)![](Ressources/InterfaceGLPI1.png)![](Ressources/InterfaceGLPI2.png)![](Ressources/InterfaceGLPI3french.png)

Imports des utilisateurs et jonction avec la base ADDS

installer les utilitaires ldap

```
sudo apt install ldap-utils -y
```

commande pour trouver un user dans la base ldap ici ke.yamamoto 
pour tester l'annuaire ldap
```
ldapsearch -x -H ldap://10.10.20.4 -D "CN=Administrator,CN=Users,DC=ecotech,DC=tssr" -w "Azerty1*" -b "DC=ecotech,DC=tssr" "(sAMAccountName=ke.yamamoto)"
```
ca fonctionne de mon coté

voyons maintenant comment lie la base ldap a glpi 
![](Ressources/InterfaceGLPI3LDAP1.png)![](Ressources/InterfaceGLPI3LDAP2.png)![](Ressources/InterfaceGLPI3LDAP3.png)![](Ressources/InterfaceGLPI3LDAP4.png)![](Ressources/InterfaceGLPI3LDAP5.png)