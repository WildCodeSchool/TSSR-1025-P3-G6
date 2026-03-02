

1. Redémarre la VM.
    
2. Au menu **GRUB**, sélectionne le noyau et appuie sur `e`.
    
3. Trouve la ligne qui commence par `linux16` (ou `linux`) et **ajoute à la fin** :
    
```
     rd.break
```
        
4. Démarre avec `Ctrl`+`x` (ou `F10`).
    
5. À l’invite, fais :
    

```
mount -o remount,rw /sysroot  
chroot /sysroot  
passwd <nouveau mot de passe> 
touch /.autorelabel  
exit  

```

La machine redémarre, le relabel SELinux peut prendre du temps.