
date_capture: 2026-02-26T12:47:46+01:00
---

# iRedMail 2 suite overview

## 📝 Énoncé & Ressources
IREDMAIL 2 suite

---

1. À faire — Phase suivante
2. Intégration LDAP/AD avec ARESKI (`10.10.20.4`) pour authentification des comptes `pp.nnnnnnn@ecotech.tssr`
3. Modifier `/etc/dovecot/dovecot.conf` et `/etc/postfix/main.cf` pour pointer vers ARESKI LDAP port 389
4. Créer compte de service AD `svc.iredmail` pour les requêtes LDAP
5. Tester envoi/réception entre comptes via Thunderbird
6. Correction DKIM (`/var/lib/dkim/ecotech.tssr.pem` manquant)
7. r

---

j'ai deja cree la base pour glpi tu penses que cette base va recuperer les mails que l'on va creer la,

---

ce que je voulais dire c'est comment glpi et adds vont recuperer les emails de nos utilistauers ecotech

---

mais pour glpi si on modifie les donnes d'u\_ user il va le voir et va se synchroniser? je veux dire que nous avons deja fais la synchro ldap pour glpi mais il n'y avait aucun mail de renseigner...

---

ok

---

\[ARESKI\]: PS C:\\Users\\wilder\\Documents> Get-ADOrganizationalUnit -Filter \* | Select-Object Name, DistinguishedName Name DistinguishedName ---- ----------------- Domain Controllers OU=Domain Controllers,DC=ecotech,DC=tssr Direction OU=Direction,OU=Ecotech\_Users,DC=ecotech,DC=tssr Developpement OU=Developpement,OU=Ecotech\_Users,DC=ecotech,DC=tssr RH OU=RH,OU=Ecotech\_Users,DC=ecotech,DC=tssr Comptabilite OU=Comptabilite,OU=Ecotech\_Users,DC=ecotech,DC=tssr Commercial OU=Commercial,OU=Ecotech\_Users,DC=ecotech,DC=tssr Communication OU=Communication,OU=Ecotech\_Users,DC=ecotech,DC=tssr DSI OU=DSI,OU=Ecotech\_Users,DC=ecotech,DC=tssr Prestataire OU=Prestataire,OU=Ecotech\_Users,DC=ecotech,DC=tssr Accueil OU=Accueil,OU=Ecotech\_Users,DC=ecotech,DC=tssr Ecotech\_Groups OU=Ecotech\_Groups,DC=ecotech,DC=tssr Ecotech\_Computers OU=Ecotech\_Computers,DC=ecotech,DC=tssr Ecotech\_Users OU=Ecotech\_Users,DC=ecotech,DC=tssr STATIONS OU=STATIONS,OU=Ecotech\_Computers,DC=ecotech,DC=tssr SERVERS OU=SERVERS,OU=Ecotech\_Computers,DC=ecotech,DC=tssr WINDOWS\_OS OU=WINDOWS\_OS,OU=STATIONS,OU=Ecotech\_Computers,DC=ecotech,DC=tssr LINUX\_OS OU=LINUX\_OS,OU=STATIONS,OU=Ecotech\_Computers,DC=ecotech,DC=tssr \[ARESKI\]: PS C:\\Users\\wilder\\Documents>

---

faisons une ou pour les compte de service tu as raison

---

good

---

Domain Controllers OU=Domain Controllers,DC=ecotech,DC=tssr Direction OU=Direction,OU=Ecotech\_Users,DC=ecotech,DC=tssr Developpement OU=Developpement,OU=Ecotech\_Users,DC=ecotech,DC=tssr RH OU=RH,OU=Ecotech\_Users,DC=ecotech,DC=tssr Comptabilite OU=Comptabilite,OU=Ecotech\_Users,DC=ecotech,DC=tssr Commercial OU=Commercial,OU=Ecotech\_Users,DC=ecotech,DC=tssr Communication OU=Communication,OU=Ecotech\_Users,DC=ecotech,DC=tssr DSI OU=DSI,OU=Ecotech\_Users,DC=ecotech,DC=tssr Prestataire OU=Prestataire,OU=Ecotech\_Users,DC=ecotech,DC=tssr Accueil OU=Accueil,OU=Ecotech\_Users,DC=ecotech,DC=tssr Ecotech\_Groups OU=Ecotech\_Groups,DC=ecotech,DC=tssr Ecotech\_Computers OU=Ecotech\_Computers,DC=ecotech,DC=tssr Ecotech\_Users OU=Ecotech\_Users,DC=ecotech,DC=tssr STATIONS OU=STATIONS,OU=Ecotech\_Computers,DC=ecotech,DC=tssr SERVERS OU=SERVERS,OU=Ecotech\_Computers,DC=ecotech,DC=tssr WINDOWS\_OS OU=WINDOWS\_OS,OU=STATIONS,OU=Ecotech\_Computers,DC=ecotech,DC=tssr LINUX\_OS OU=LINUX\_OS,OU=STATIONS,OU=Ecotech\_Computers,DC=ecotech,DC=tssr Service\_Accounts OU=Service\_Accounts,DC=ecotech,DC=tssr

---

est ce que tu peux faire la commande eu un ligne stp

---

pourquoi svc?

---

good

---

tout est au vert

---

aucun fichier a ce nom??

---

wilder@hera:~$ ls -la /etc/dovecot total 64 drwxr-xr-x 4 root root 4096 24 févr. 17:42. drwxr-xr-x 141 root root 12288 24 févr. 14:37.. drwxr-xr-x 2 root root 4096 23 févr. 16:08 conf.d -rw-rw-r-- 1 root root 18301 24 févr. 17:42 dovecot.conf -rw-r--r-- 1 root root 3777 23 févr. 16:08 dovecot.conf.2026.02.23.15.59.34 -rw-r--r-- 1 root root 0 24 févr. 15:57 dovecot.conf.bak -r-x------ 1 dovecot dovecot 916 23 févr. 16:08 dovecot-last-login.conf -r-x------ 1 dovecot dovecot 0 23 févr. 16:08 dovecot-master-users -r-xr-x--- 1 root root 1191 23 févr. 16:08 dovecot-mysql.conf -r-x------ 1 dovecot dovecot 517 23 févr. 16:08 dovecot-share-folder.conf -r-x------ 1 dovecot dovecot 346 23 févr. 16:08 dovecot-used-quota.conf drwx------ 2 root root 4096 23 févr. 16:06 private wilder@hera:~$

---

wilder@hera:~$ sudo cat /etc/dovecot/dovecot-mysql.conf \[sudo\] Mot de passe de wilder: driver = mysql default\_pass\_scheme = CRYPT connect = host=127.0.0.1 port=3306 dbname=vmail user=vmail password=XH1n8z71uAmrTVPfXT0ZM25skOXa9r0m # Required by doveadm tools which require to list all mail users. iterate\_query = SELECT username AS user FROM mailbox password\_query = SELECT mailbox.password, mailbox.allow\_nets \\ FROM mailbox,domain \\ WHERE mailbox.username='%u' \\ AND mailbox.`enable%Ls%Lc` =1 \\ AND mailbox.active=1 \\ AND mailbox.domain=domain.domain \\ AND domain.backupmx=0 \\ AND domain.active=1 user\_query = SELECT \\ LOWER('%u') AS master\_user, \\ LOWER(CONCAT(mailbox.storagebasedirectory, '/', mailbox.storagenode, '/', mailbox.maildir)) AS home, \\ CONCAT(mailbox.mailboxformat, ':~/', mailbox.mailboxfolder) AS mail, \\ CONCAT('\*:bytes=', mailbox.quota\*1048576) AS quota\_rule \\ FROM mailbox,domain \\ WHERE mailbox.username='%u' \\ AND mailbox.`enable%Ls%Lc` =1 \\ AND mailbox.active=1 \\ AND mailbox.domain=domain.domain \\ AND domain.backupmx=0 \\ AND domain.active=1 wilder@hera:~$

---

ca veut dire quoi unpassdb

---

wilder@hera:~$ sudo grep -n "passdb\\|userdb" /etc/dovecot/dovecot.conf 106:mail\_driver = %{userdb:mail\_driver | default("maildir") | lower} 107:mail\_path = %{userdb:mail\_path | default("~/Maildir")} 137:passdb passwd-file { 266:userdb sql { 286:passdb sql { 500: unix\_listener auth-userdb { wilder@hera:~$

---

\[sudo\] Mot de passe de wilder: # Master user. # Master users are able to log in as other users. It's also possible to # directly log in as any user using a master password, although this isn't # recommended. # Reference: [http://wiki2.dovecot.org/Authentication/MasterUsers](http://wiki2.dovecot.org/Authentication/MasterUsers) auth\_master\_user\_separator = \* passdb passwd-file { master = yes passwd\_file\_path = /etc/dovecot/dovecot-master-users result\_success = continue } # `mailbox_list_index = yes` can help a lot by replying to IMAP STATUS (and # similar) lookups from a single index without having to open each mailbox # index separately. # This is the default in v2.3+. mailbox\_list\_index = yes # Assume that the list index is up-to-date. mailbox\_list\_index\_very\_dirty\_syncs = yes # Maximum IMAP command line length. Some clients generate very long command # lines with huge mailboxes, so you may need to raise this if you get # "Too long argument" or "IMAP command line too large" errors often. # Defaults to 64k. imap\_max\_line\_length = 2m sql\_driver = mysql mysql 127.0.0.1 { port = 3306 dbname = vmail user = vmailadmin password = swRnasr2kqxRU1HRCt0GD0pIQn4aA3It } dict\_server { dict acl { driver = sql dict\_map shared/shared-boxes/user/$to/$from { sql\_table = share\_folder value\_field dummy { } key\_field from\_user { value = $from } key\_field to\_user { value = $to } } dict\_map shared/shared-boxes/anyone/$from { sql\_table = anyone\_shares value\_field dummy { } key\_field from\_user { value = $from } } } dict lastlogin { driver = sql dict\_map shared/last-login/imap/$user/$domain { sql\_table = last\_login value\_field imap { type = uint } key\_field username { value = $user } key\_field domain { value = $domain } } dict\_map shared/last-login/pop3/$user/$domain { sql\_table = last\_login value\_field pop3 { type = uint } key\_field username { value = $user } key\_field domain { value = $domain } } dict\_map shared/last-login/lda/$user/$domain { sql\_table = last\_login value\_field lda { type = uint } key\_field username { value = $user } key\_field domain { value = $domain } } # Treat lmtp as lda dict\_map shared/last-login/lmtp/$user/$domain { sql\_table = last\_login value\_field lda { type = uint } key\_field username { value = $user } key\_field domain { value = $domain } } } } # # Virtual mail accounts. # userdb sql { iterate\_query = SELECT username AS user FROM mailbox # Use COALESCE(NULLIF(...)) to prevent empty value. query = SELECT \\ LOWER('%{user | lower}') AS master\_user, \\ LOWER(CONCAT(mailbox.storagebasedirectory, '/', mailbox.storagenode, '/', mailbox.maildir)) AS home, \\ COALESCE(NULLIF(mailbox.mailboxformat, ''), 'maildir') AS mail\_driver, \\ CONCAT("~/", COALESCE(NULLIF(mailbox.mailboxfolder, ''), 'Maildir')) AS mail\_path, \\ mailbox.quota \* 1048576 AS quota\_storage\_size \\ FROM mailbox,domain \\ WHERE mailbox.username='%{user | lower}' \\ AND mailbox.domain='%{user | domain | lower}' \\ AND mailbox.`enable%{protocol | lower}%{secured | lower}` =1 \\ AND mailbox.domain=domain.domain \\ AND domain.backupmx=0 \\ AND domain.active=1 \\ AND mailbox.active=1 } passdb sql { query = SELECT mailbox.password, mailbox.allow\_nets \\ FROM mailbox,domain \\ WHERE mailbox.username='%{user | lower}' \\ AND mailbox.`enable%{protocol | lower}%{secured | lower}` =1 \\ AND mailbox.active=1 \\ AND mailbox.domain=domain.domain \\ AND domain.active=1 } # # Namespaces # namespace inbox { type = private wilder@hera:~$

---

good est ce que tu sais que le logon est le preambule de ladresse email de chaque users logon =pp.nnnnn ou pp sont les deux premieres lettres du prenom et nnn est le nom de famille

---

wilder@hera:~$ sudo sed -n '280,295p' /etc/dovecot/dovecot.conf AND mailbox.domain=domain.domain \\ AND domain.backupmx=0 \\ AND domain.active=1 \\ AND mailbox.active=1 } passdb sql { query = SELECT mailbox.password, mailbox.allow\_nets \\ FROM mailbox,domain \\ WHERE mailbox.username='%{user | lower}' \\ AND mailbox.`enable%{protocol | lower}%{secured | lower}` =1 \\ AND mailbox.active=1 \\ AND mailbox.domain=domain.domain \\ AND domain.active=1 } il est la peux tu me donner des details sur ta formule sed

---

ok pour le backup

---

ok

---

wilder@hera:~$ sudo sed -n '283,300p' /etc/dovecot/dovecot.conf AND mailbox.active=1 } passdb ldap { ldap\_conf\_path = /etc/dovecot/dovecot-ldap.conf.ext result\_success = continue } passdb sql { query = SELECT mailbox.password, mailbox.allow\_nets \\ FROM mailbox,domain \\ WHERE mailbox.username='%{user | lower}' \\ AND mailbox.`enable%{protocol | lower}%{secured | lower}` =1 \\ AND mailbox.active=1 \\ AND mailbox.domain=domain.domain \\ AND domain.active=1 } c'est good bravo et merci

---

wilder@hera:~$ sudo systemctl restart dovecot && systemctl status dovecot Job for dovecot.service failed because the control process exited with error code. See "systemctl status dovecot.service" and "journalctl -xeu dovecot.service" for details. wilder@hera:~$

meme probleme que tout a l'heure non,

---

wilder@hera:~$ journalctl -xeu dovecot.service | tail -30 Hint: You are currently not seeing messages from other users and the system. Users in groups 'adm', 'systemd-journal' can see all messages. Pass -q to turn off this notice. -- No entries -- wilder@hera:~$

---

wilder@hera:~$ journalctl -xeu dovecot.service | tail -30 Hint: You are currently not seeing messages from other users and the system. Users in groups 'adm', 'systemd-journal' can see all messages. Pass -q to turn off this notice. -- No entries -- wilder@hera:~$ sudo wget -O /etc/dovecot/dovecot.conf [https://docs.iredmail.org/files/dovecot/dovecot-2.4-mariadb.conf](https://docs.iredmail.org/files/dovecot/dovecot-2.4-mariadb.conf) --2026-02-24 22:30:43-- [https://docs.iredmail.org/files/dovecot/dovecot-2.4-mariadb.conf](https://docs.iredmail.org/files/dovecot/dovecot-2.4-mariadb.conf) Résolution de docs.iredmail.org (docs.iredmail.org)… 139.162.146.87 Connexion à docs.iredmail.org (docs.iredmail.org)|139.162.146.87|:443… connecté. requête HTTP transmise, en attente de la réponse… 200 OK Taille: 18301 (18K) Sauvegarde en: « /etc/dovecot/dovecot.conf » /etc/dovecot/dovecot.conf 100%\[========================================================================================>\] 17,87K --.-KB/s ds 0,01s 2026-02-24 22:30:43 (1,56 MB/s) — « /etc/dovecot/dovecot.conf » sauvegardé \[18301/18301\] wilder@hera:~$ sudo systemctl restart dovecot && systemctl status dovecot ● dovecot.service - Dovecot IMAP/POP3 email server Loaded: loaded (/usr/lib/systemd/system/dovecot.service; enabled; preset: enabled) Active: active (running) since Tue 2026-02-24 22:30:53 CET; 47ms ago Invocation: 2bb996a27d19408f84ae225246dc3b8f Docs: man:dovecot(1) [https://doc.dovecot.org/](https://doc.dovecot.org/) Main PID: 37485 (dovecot) Status: "v2.4.1-4 (7d8c0e5759) running" Tasks: 8 (limit: 2293) Memory: 4.5M (peak: 4.8M) CPU: 69ms CGroup: /system.slice/dovecot.service ├─37485 /usr/sbin/dovecot -F ├─37486 dovecot/anvil ├─37487 dovecot/lmtp -L ├─37488 dovecot/log ├─37490 dovecot/lmtp -L ├─37491 dovecot/lmtp -L ├─37492 dovecot/lmtp -L ├─37494 "\[dovecot\]" └─37495 /usr/sbin/dovecot -F

---

desole

---

wilder@hera:~$ sudo grep -n "passdb" /etc/dovecot/dovecot.conf 137:passdb passwd-file { 286:passdb ldap { 290:passdb sql { wilder@hera:~$

---

nope ce reste en rouge comme tout a l'heure

---

290:passdb sql { wilder@hera:~$ sudo systemctl restart dovecot && systemctl status dovecot Job for dovecot.service failed because the control process exited with error code. See "systemctl status dovecot.service" and "journalctl -xeu dovecot.service" for details. wilder@hera:~$ sudo dovecot -n 2>&1 | tail -20 # 2.4.1-4 (7d8c0e5759): /etc/dovecot/dovecot.conf doveconf: Fatal: Error in configuration file /etc/dovecot/dovecot.conf line 287: ldap\_conf\_path: Unknown setting: ldap\_conf\_path (passdb\_ldap\_conf\_path or passdb\_ldap\_ldap\_conf\_path not found either.) # Pigeonhole version 2.4.1-4 (0a86619f) wilder@hera:~$

---

wilder@hera:~$ sudo grep -A3 "passdb ldap" /etc/dovecot/dovecot.conf passdb ldap { conf\_file = /etc/dovecot/dovecot-ldap.conf.ext result\_success = continue } wilder@hera:~$

---

} wilder@hera:~$ sudo systemctl restart dovecot && systemctl status dovecot Job for dovecot.service failed because the control process exited with error code. See "systemctl status dovecot.service" and "journalctl -xeu dovecot.service" for details. wilder@hera:~$

---

\-bash: wilder@hera:~$: commande introuvable wilder@hera:~$ sudo dovecot -n 2>&1 | tail -20 # 2.4.1-4 (7d8c0e5759): /etc/dovecot/dovecot.conf doveconf: Fatal: Error in configuration file /etc/dovecot/dovecot.conf line 287: conf\_file: Unknown setting: conf\_file (passdb\_conf\_file or passdb\_ldap\_conf\_file not found either.) # Pigeonhole version 2.4.1-4 (0a86619f) wilder@hera:~$

---

on s'en sort pas de cette histoire de debian12

---

vxt/' /etc/dovecot/dovecot.conf wilder@hera:~$ sudo grep -A3 "passdb ldap" /etc/dovecot/dovecot.conf passdb ldap { ldap\_conf\_file = /etc/dovecot/dovecot-ldap.conf.ext result\_success = continue } wilder@hera:~$

---

wilder@hera:~$ sudo grep -n "passdb" /etc/dovecot/dovecot.conf 137:passdb passwd-file { 286:passdb sql { wilder@hera:~$

---

\# LDAP AD integration ldap\_uris = ldap://10.10.20.4 ldap\_auth\_dn = CN=svc.iredmail,OU=Service\_Accounts,DC=ecotech,DC=tssr ldap\_auth\_dn\_password = Azerty1\* ldap\_base = OU=Ecotech\_Users,DC=ecotech,DC=tssr wilder@hera:~$

---

/etc/dovecot/dovecot.conf wilder@hera:~$ sudo grep -n -A4 "passdb ldap" /etc/dovecot/dovecot.conf 286:passdb ldap { 287- passdb\_ldap\_filter = (&(objectClass=user)(sAMAccountName=%{user | username})) 288- ldap\_bind = yes 289- result\_success = continue 290-} wilder@hera:~$

---

deux phrases rouge pareil

---

j'ai l'impression qu'on tourne en roond non?

---

wilder@hera:~$ sudo dovecot -n 2>&1 | grep -i "error\\|fatal\\|warn > " # 2.4.1-4 (7d8c0e5759): /etc/dovecot/dovecot.conf doveconf: Fatal: Error in configuration file /etc/dovecot/dovecot.conf line 287: passdb\_ldap\_filter: Unknown setting: passdb\_ldap\_filter (passdb\_passdb\_ldap\_filter or passdb\_ldap\_passdb\_ldap\_filter not found either.) # Pigeonhole version 2.4.1-4 (0a86619f) wilder@hera:~$

---

c/dovecot/dovecot.conf wilder@hera:~$ sudo grep -A4 "passdb ldap" /etc/dovecot/dovecot.conf passdb ldap { ldap\_filter = (&(objectClass=user)(sAMAccountName=%{user | username})) ldap\_bind = yes result\_success = continue } wilder@hera:~$

---

} wilder@hera:~$ sudo systemctl restart dovecot && systemctl status dovecot Job for dovecot.service failed because the control process exited with error code. See "systemctl status dovecot.service" and "journalctl -xeu dovecot.service" for details. wilder@hera:~$

---

\-bash: See: commande introuvable wilder@hera:~$ sudo dovecot -n 2>&1 | grep -i "error\\|fatal" doveconf: Fatal: Error in configuration file /etc/dovecot/dovecot.conf line 287: ldap\_filter: Unknown setting: ldap\_filter (passdb\_ldap\_filter or passdb\_ldap\_ldap\_filter not found either.) wilder@hera:~$ pareil pour la 4eme fois on fait quoi on recommance avec debian

---

reponse vide

---

wilder@hera:~$ apt-cache search dovecot | grep ldap dovecot-ldap - serveur POP3/IMAP sécurisé – prise en charge de LDAP wilder@hera:~$

---

comment se fait il que ce n'est pas installe et qu'on ne s'en est pas rendu compte avant?

---

ok

---

● dovecot.service - Dovecot IMAP/POP3 email server Loaded: loaded (/usr/lib/systemd/system/dovecot.service; enabled; preset: enabled) Active: active (running) since Tue 2026-02-24 23:01:49 CET; 23s ago Invocation: 9f794a5a4247461cb6a80d04be4ba74d Docs: man:dovecot(1) [https://doc.dovecot.org/](https://doc.dovecot.org/) Main PID: 39983 (dovecot) Status: "v2.4.1-4 (7d8c0e5759) running" Tasks: 13 (limit: 2293) Memory: 26.7M (peak: 26.9M) CPU: 241ms CGroup: /system.slice/dovecot.service ├─39983 /usr/sbin/dovecot -F ├─39984 dovecot/anvil ├─39985 dovecot/lmtp -L ├─39986 dovecot/log ├─39987 dovecot/lmtp -L ├─39988 dovecot/lmtp -L ├─39989 dovecot/lmtp -L ├─39990 dovecot/lmtp -L ├─39991 dovecot/config ├─39992 dovecot/stats ├─39994 dovecot/imap-login ├─39995 dovecot/auth └─39997 dovecot/auth -w févr. 24 23:01:51 hera.ecotech.tssr dovecot\[39986\]: auth: Error: mysql(127.0.0.1): Connect failed to database (vmail): Access denied for user 'vmailadmin'@'localhost' (usi> févr. 24 23:01:51 hera.ecotech.tssr dovecot\[39986\]: auth: Error: mysql(127.0.0.1): Connect failed to database (vmail): Access denied for user 'vmailadmin'@'localhost' (usi> févr. 24 23:01:51 hera.ecotech.tssr dovecot\[39986\]: auth: Error: mysql(127.0.0.1): Connect failed to database (vmail): Access denied for user 'vmailadmin'@'localhost' (usi> févr. 24 23:01:51 hera.ecotech.tssr dovecot\[39986\]: auth: Error: mysql(127.0.0.1): Connect failed to database (vmail): Access denied for user 'vmailadmin'@'localhost' (usi> févr. 24 23:01:51 hera.ecotech.tssr dovecot\[39986\]: auth: Error: mysql(127.0.0.1): Connect failed to database (vmail): Access denied for user 'vmailadmin'@'localhost' (usi> févr. 24 23:01:51 hera.ecotech.tssr dovecot\[39986\]: auth-worker(39997): Error: mysql(127.0.0.1): Connect failed to database (vmail): Access denied for user 'vmailadmin'@'l> févr. 24 23:01:51 hera.ecotech.tssr dovecot\[39986\]: auth-worker(39997): Error: mysql(127.0.0.1): Connect failed to database (vmail): Access denied for user 'vmailadmin'@'l> févr. 24 23:01:51 hera.ecotech.tssr dovecot\[39986\]: auth-worker(39997): Error: mysql(127.0.0.1): Connect failed to database (vmail): Access denied for user 'vmailadmin'@'l> févr. 24 23:01:51 hera.ecotech.tssr dovecot\[39986\]: auth-worker(39997): Error: mysql(127.0.0.1): Connect failed to database (vmail): Access denied for user 'vmailadmin'@'l> févr. 24 23:01:51 hera.ecotech.tssr dovecot\[39986\]: auth-worker(39997): Error: mysql(127.0.0.1): Connect failed to database (vmail): Access denied for user 'vmailadmin'@'l> lines 3-36/36 (END)

---

user = vmailadmin

---

wilder@hera:~$ sudo grep -i "vmailadmin" /etc/dovecot/dovecot.conf user = vmailadmin wilder@hera:~$ sudo grep -i "pass\\|password" /etc/dovecot/dovecot.conf | grep -v "^#" passdb passwd-file { passwd\_file\_path = /etc/dovecot/dovecot-master-users password = IdWPrT8a6Fwxc69zUCGB7TSryzbLRGAw passdb ldap { passdb sql { query = SELECT mailbox.password, mailbox.allow\_nets \\ ldap\_auth\_dn\_password = Azerty1\* ldap\_auth\_dn\_password = Azerty1\* wilder@hera:~$

---

wilder@hera:~$ sudo grep -A5 "mysql 127.0.0.1" /etc/dovecot/dovecot.conf mysql 127.0.0.1 { port = 3306 dbname = vmail user = vmailadmin password = IdWPrT8a6Fwxc69zUCGB7TSryzbLRGAw } wilder@hera:~$

---

wilder@hera:~$ mysql -u vmailadmin -p'IdWPrT8a6Fwxc69zUCGB7TSryzbLRGAw' vmail -e "SELECT 1;" ERROR 1045 (28000): Access denied for user 'vmailadmin'@'localhost' (using password: YES) wilder@hera:~$

---

good

---

vide

---

je vais cgercher une debian 12 et on va tout rfefaire sinon ubunto

---

ok

---

vide

---

" wilder@hera:~$ sudo grep -r "vmailadmin" /etc/ 2>/dev/null | grep -i "pass" /etc/dovecot/dovecot-used-quota.conf:connect = host=127.0.0.1 port=3306 dbname=vmail user=vmailadmin password=swRnasr2kqxRU1HRCt0GD0pIQn4aA3It /etc/dovecot/dovecot-last-login.conf:connect = host=127.0.0.1 port=3306 dbname=vmail user=vmailadmin password=swRnasr2kqxRU1HRCt0GD0pIQn4aA3It /etc/dovecot/dovecot-share-folder.conf:connect = host=127.0.0.1 port=3306 dbname=vmail user=vmailadmin password=swRnasr2kqxRU1HRCt0GD0pIQn4aA3It wilder@hera:~$

---

a priori good

---

good

---

wilder@hera:~$ sudo journalctl -u dovecot --since "1 minute ago" | grep -i error wilder@hera:~$ sudo doveadm auth test ma.zhang@ecotech.tssr Password: passdb: ma.zhang@ecotech.tssr auth failed extra fields: user=ma.zhang@ecotech.tssr wilder@hera:~$ sudo doveadm auth test ma.zhang@ecotech.tssr Password: passdb: ma.zhang@ecotech.tssr auth failed extra fields: user=ma.zhang@ecotech.tssr wilder@hera:~$ sudo doveadm auth test ma.zhang@ecotech.tssr Password: passdb: ma.zhang@ecotech.tssr auth failed extra fields: user=ma.zhang@ecotech.tssr wilder@hera:~$

---

wilder@hera:~$ user=ma.zhang@ecotech.tssr wilder@hera:~$ sudo doveadm auth test -x service=imap ma.zhang@ecotech.tssr 2>&1 Password: passdb: ma.zhang@ecotech.tssr auth failed extra fields: user=ma.zhang@ecotech.tssr wilder@hera:~$ sudo doveadm auth test -x service=imap ma.zhang@ecotech.tssr 2>&1 Password: passdb: ma.zhang@ecotech.tssr auth failed extra fields: user=ma.zhang@ecotech.tssr wilder@hera:~$ sudo doveadm auth test -x service=imap ma.zhang@ecotech.tssr 2>&1 Password: passdb: ma.zhang@ecotech.tssr auth failed extra fields: user=ma.zhang@ecotech.tssr wilder@hera:~$

---

on reprend la demain je vais me coucher

---

les users ont dans adds une gpo qui bloque leurs compte apres 20 h. c'est peut etre cela qui s'est passe hier. on reessaye ma.zhang?

---

Last login: Tue Feb 24 22:54:42 2026 from 10.0.2.2 wilder@hera:~$ sudo doveadm -D auth test ma.zhang@ecotech.tssr 2>&1 | grep -i "ldap\\|auth\\|error\\|fail" \[sudo\] Mot de passe de wilder: Debug: Skipping module doveadm\_acl\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_acl\_plugin.so: undefined symbol: acl\_user\_module (this is usually intentional, so just ignore this message) Debug: Skipping module doveadm\_quota\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_quota\_plugin.so: undefined symbol: quota\_user\_module (this is usually intentional, so just ignore this message) Debug: Skipping module doveadm\_fts\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/lib20\_doveadm\_fts\_plugin.so: undefined symbol: fts\_backend\_rescan (this is usually intentional, so just ignore this message) Debug: Skipping module doveadm\_fts\_flatcurve\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/libdoveadm\_fts\_flatcurve\_plugin.so: undefined symbol: fts\_flatcurve\_user\_module (this is usually intentional, so just ignore this message) Debug: Skipping module doveadm\_mail\_crypt\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/libdoveadm\_mail\_crypt\_plugin.so: undefined symbol: crypt\_acl\_setting\_parser\_info (this is usually intentional, so just ignore this message) Feb 25 08:31:16 Debug: Skipping module doveadm\_fts\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/lib20\_doveadm\_fts\_plugin.so: undefined symbol: fts\_backend\_rescan (this is usually intentional, so just ignore this message) Feb 25 08:31:16 Debug: Skipping module doveadm\_fts\_flatcurve\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/libdoveadm\_fts\_flatcurve\_plugin.so: undefined symbol: fts\_flatcurve\_user\_module (this is usually intentional, so just ignore this message) Feb 25 08:31:16 Debug: Skipping module doveadm\_mail\_crypt\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/libdoveadm\_mail\_crypt\_plugin.so: undefined symbol: crypt\_acl\_setting\_parser\_info (this is usually intentional, so just ignore this message)

---

user=ma.zhang@ecotech.tssr wilder@hera:~$ sudo doveadm -D auth test ma.zhang@ecotech.tssr 2>&1 | tail -40 Debug: Loading modules from directory: /usr/lib/dovecot/modules/doveadm Debug: Skipping module doveadm\_acl\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_acl\_plugin.so: undefined symbol: acl\_user\_module (this is usually intentional, so just ignore this message) Debug: Skipping module doveadm\_quota\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_quota\_plugin.so: undefined symbol: quota\_user\_module (this is usually intentional, so just ignore this message) Debug: Module loaded: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_sieve\_plugin.so Debug: Skipping module doveadm\_fts\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/lib20\_doveadm\_fts\_plugin.so: undefined symbol: fts\_backend\_rescan (this is usually intentional, so just ignore this message) Debug: Skipping module doveadm\_fts\_flatcurve\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/libdoveadm\_fts\_flatcurve\_plugin.so: undefined symbol: fts\_flatcurve\_user\_module (this is usually intentional, so just ignore this message) Debug: Skipping module doveadm\_mail\_crypt\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/libdoveadm\_mail\_crypt\_plugin.so: undefined symbol: crypt\_acl\_setting\_parser\_info (this is usually intentional, so just ignore this message) Feb 25 08:33:48 Debug: Loading modules from directory: /usr/lib/dovecot/modules Feb 25 08:33:48 Debug: Module loaded: /usr/lib/dovecot/modules/lib01\_acl\_plugin.so Feb 25 08:33:48 Debug: Module loaded: /usr/lib/dovecot/modules/lib10\_quota\_plugin.so Feb 25 08:33:48 Debug: Module loaded: /usr/lib/dovecot/modules/lib15\_notify\_plugin.so Feb 25 08:33:48 Debug: Module loaded: /usr/lib/dovecot/modules/lib20\_mail\_log\_plugin.so Feb 25 08:33:48 Debug: Loading modules from directory: /usr/lib/dovecot/modules/doveadm Feb 25 08:33:48 Debug: Module loaded: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_acl\_plugin.so Feb 25 08:33:48 Debug: Module loaded: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_quota\_plugin.so Feb 25 08:33:48 Debug: Skipping module doveadm\_fts\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/lib20\_doveadm\_fts\_plugin.so: undefined symbol: fts\_backend\_rescan (this is usually intentional, so just ignore this message) Feb 25 08:33:48 Debug: Skipping module doveadm\_fts\_flatcurve\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/libdoveadm\_fts\_flatcurve\_plugin.so: undefined symbol: fts\_flatcurve\_user\_module (this is usually intentional, so just ignore this message) Feb 25 08:33:48 Debug: Skipping module doveadm\_mail\_crypt\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/libdoveadm\_mail\_crypt\_plugin.so: undefined symbol: crypt\_acl\_setting\_parser\_info (this is usually intentional, so just ignore this message) Password: Feb 25 08:34:09 Debug: auth-client: conn unix:/run/dovecot/auth-client: Connecting Feb 25 08:34:09 Debug: auth-client: conn unix:/run/dovecot/auth-client (pid=900,uid=0): Client connected (fd=9) Feb 25 08:34:09 Debug: auth-client: request \[1\]: Started request Feb 25 08:34:11 Debug: auth-client: conn unix:/run/dovecot/auth-client (pid=900,uid=0): auth input: FAIL 1user=ma.zhang@ecotech.tssr Feb 25 08:34:11 Debug: auth-client: request \[1\]: Finished Feb 25 08:34:11 Debug: auth-client: conn unix:/run/dovecot/auth-client (pid=900,uid=0): Disconnected: Connection closed (fd=9) passdb: ma.zhang@ecotech.tssr auth failed extra fields: user=ma.zhang@ecotech.tssr wilder@hera:~$

---

tu comprends quelques choses a tout ca...moi rien du tout. i dit quoi?

---

ldapsearch: commande introuvable

---

Traitement des actions différées (« triggers ») pour man-db (2.13.1-1)... wilder@hera:~$ sudo ldapsearch -x -H ldap://10.10.20.4 -D "CN=svc.iredmail,OU=Service\_Accounts,DC=ecotech,DC=tssr" -w "Azerty1\*" -b "OU=Ecotech\_Users,DC=ecotech,DC=tssr" "(sAMAccountName=ma.zhang)" sAMAccountName # extended LDIF #nstallation de: # LDAPv3tils # base <OU=Ecotech\_Users,DC=ecotech,DC=tssr> with scope subtree # filter: (sAMAccountName=ma.zhang) # requesting: sAMAccountName | libsasl2-modules-gssapi-heimdal # Sommaire: # Mateo Zhang, DSI, Ecotech\_Users, ecotech.tssrrimé: 0. Non mis à jour: 0 dn: CN=Mateo Zhang,OU=DSI,OU=Ecotech\_Users,DC=ecotech,DC=tssr sAMAccountName: ma.zhang7 kB / 488 MB disponible # search result1 [http://deb.debian.org/debian](http://deb.debian.org/debian) trixie/main amd64 ldap-utils amd64 2.6.10+dfsg-1 \[152 kB\] search: 2ceptionnés en 0s (2 243 ko/s) result: 0 Success # numResponses: 2 # numEntries: 1 wilder@hera:~$ tu es un chef

---

tu veux pas que l'on essaye de se connecter la?

---

---

user=ma.zhang@ecotech.tssr wilder@hera:~$ sudo tail -f /var/log/dovecot/dovecot.log 2026-02-25T08:34:09.861778+01:00 hera dovecot: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: sql: Finished passdb lookup 2026-02-25T08:34:09.861896+01:00 hera dovecot: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: Auth request finished 2026-02-25T08:34:09.861974+01:00 hera dovecot: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: delaying auth failure 2026-02-25T08:35:50.609415+01:00 hera dovecot: auth: Warning: Event 0x56443bbd3978 leaked (parent=0x56443bbddd48): auth-request.c:166 2026-02-25T08:35:50.611638+01:00 hera dovecot: auth: Warning: Event 0x56443bbddd48 leaked (parent=0x56443bbdc458): auth-request.c:138 2026-02-25T08:35:50.612189+01:00 hera dovecot: auth: Warning: Event 0x56443bbdc458 leaked (parent=0x56443bb35658): connection.c:620 2026-02-25T08:35:50.612586+01:00 hera dovecot: auth: Warning: Event 0x56443bbdbf38 leaked (parent=0x56443bbd2a78): auth-request.c:166 2026-02-25T08:35:50.612704+01:00 hera dovecot: auth: Warning: Event 0x56443bbd2a78 leaked (parent=0x56443bbd2668): auth-request.c:138 2026-02-25T08:35:50.612777+01:00 hera dovecot: auth: Warning: Event 0x56443bbd2668 leaked (parent=0x56443bb35658): connection.c:620 2026-02-25T08:35:50.612879+01:00 hera dovecot: auth: Warning: Event 0x56443bb35658 leaked (parent=(nil)): auth.c:515 ^C wilder@hera:~$ sudo doveadm auth test ma.zhang@ecotech.tssr Password: passdb: ma.zhang@ecotech.tssr auth failed extra fields: user=ma.zhang@ecotech.tssr wilder@hera:~$

---

wilder@hera:~$ sudo grep "ldap\_filter" /etc/dovecot/dovecot.conf ldap\_filter = (&(objectClass=user)(sAMAccountName=%n)) wilder@hera:~$ 2026-02-25T08:47:15.041856+01:00 hera dovecot: auth: Warning: Event 0x558242bbc1e8 leaked (parent=0x558242bbaa78): auth-request.c:166 2026-02-25T08:47:15.043388+01:00 hera dovecot: auth: Warning: Event 0x558242bbaa78 leaked (parent=0x558242bba668): auth-request.c:138 2026-02-25T08:47:15.043427+01:00 hera dovecot: auth: Warning: Event 0x558242bba668 leaked (parent=0x558242b1d658): connection.c:620 2026-02-25T08:47:15.043461+01:00 hera dovecot: auth: Warning: Event 0x558242b1d658 leaked (parent=(nil)): auth.c:515

---

c'est vraiment le mot de passe de Ma.Zhang que l'on attend? xchangeons le dans ADDS pour etre sur que je fais le good one

---

user=ma.zhang@ecotech.tssr wilder@hera:~$ sudo systemctl restart dovecot && sudo doveadm auth test ma.zhang@ecotech.tssr 2026-02-25T08:50:36.376296+01:00 hera dovecot: master: Warning: Killed with signal 15 (by pid=5489 uid=0 code=kill) 2026-02-25T08:50:36.499405+01:00 hera dovecot: master: Dovecot v2.4.1-4 (7d8c0e5759) starting up for pop3, imap, sieve, lmtp (core dumps disabled) Password: passdb: ma.zhang@ecotech.tssr auth failed extra fields: user=ma.zhang@ecotech.tssr wilder@hera:~$

j'ai bien teste avec le mot de pass ADDs peut etre faut il attendre un peu... je vais me connecter sur une session AD pour voir

---

user=ma.zhang@ecotech.tssr wilder@hera:~$ sudo tail -20 /var/log/dovecot/dovecot.log 2026-02-25T08:34:09.861778+01:00 hera dovecot: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: sql: Finished passdb lookup 2026-02-25T08:34:09.861896+01:00 hera dovecot: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: Auth request finished 2026-02-25T08:34:09.861974+01:00 hera dovecot: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: delaying auth failure 2026-02-25T08:35:50.609415+01:00 hera dovecot: auth: Warning: Event 0x56443bbd3978 leaked (parent=0x56443bbddd48): auth-request.c:166 2026-02-25T08:35:50.611638+01:00 hera dovecot: auth: Warning: Event 0x56443bbddd48 leaked (parent=0x56443bbdc458): auth-request.c:138 2026-02-25T08:35:50.612189+01:00 hera dovecot: auth: Warning: Event 0x56443bbdc458 leaked (parent=0x56443bb35658): connection.c:620 2026-02-25T08:35:50.612586+01:00 hera dovecot: auth: Warning: Event 0x56443bbdbf38 leaked (parent=0x56443bbd2a78): auth-request.c:166 2026-02-25T08:35:50.612704+01:00 hera dovecot: auth: Warning: Event 0x56443bbd2a78 leaked (parent=0x56443bbd2668): auth-request.c:138 2026-02-25T08:35:50.612777+01:00 hera dovecot: auth: Warning: Event 0x56443bbd2668 leaked (parent=0x56443bb35658): connection.c:620 2026-02-25T08:35:50.612879+01:00 hera dovecot: auth: Warning: Event 0x56443bb35658 leaked (parent=(nil)): auth.c:515 2026-02-25T08:47:15.041856+01:00 hera dovecot: auth: Warning: Event 0x558242bbc1e8 leaked (parent=0x558242bbaa78): auth-request.c:166 2026-02-25T08:47:15.043388+01:00 hera dovecot: auth: Warning: Event 0x558242bbaa78 leaked (parent=0x558242bba668): auth-request.c:138 2026-02-25T08:47:15.043427+01:00 hera dovecot: auth: Warning: Event 0x558242bba668 leaked (parent=0x558242b1d658): connection.c:620 2026-02-25T08:47:15.043461+01:00 hera dovecot: auth: Warning: Event 0x558242b1d658 leaked (parent=(nil)): auth.c:515 2026-02-25T08:48:00.464099+01:00 hera dovecot: master: Warning: Killed with signal 15 (by pid=5368 uid=0 code=kill) 2026-02-25T08:48:00.809495+01:00 hera dovecot: master: Dovecot v2.4.1-4 (7d8c0e5759) starting up for pop3, imap, sieve, lmtp (core dumps disabled) 2026-02-25T08:48:40.098324+01:00 hera dovecot: master: Warning: Killed with signal 15 (by pid=5416 uid=0 code=kill) 2026-02-25T08:48:40.203902+01:00 hera dovecot: master: Dovecot v2.4.1-4 (7d8c0e5759) starting up for pop3, imap, sieve, lmtp (core dumps disabled) 2026-02-25T08:50:36.376296+01:00 hera dovecot: master: Warning: Killed with signal 15 (by pid=5489 uid=0 code=kill) 2026-02-25T08:50:36.499405+01:00 hera dovecot: master: Dovecot v2.4.1-4 (7d8c0e5759) starting up for pop3, imap, sieve, lmtp (core dumps disabled)

---

c/dovecot/dovecot.conf wilder@hera:~$ sudo grep -A5 "passdb ldap" /etc/dovecot/dovecot.conf passdb ldap { ldap\_filter = (&(objectClass=user)(sAMAccountName=%n)) ldap\_bind = yes passdb\_use\_worker = yes result\_success = return-ok } wilder@hera:~$

---

ok ca fonctionnne

j'avais essaye avec cette commenade pourquoi la tienen a fonctionne? Get-ADUser -Identity xx.xxxxx | Select-Object Name,Enabled Enable-ADAccount -Identity xx.xxxx ( avec ma.zhang je te rassure pas XXXX

---

wilder@hera:~$ sudo systemctl restart dovecot && sudo doveadm auth test ma.zhang@ecotech.tssr 2026-02-25T09:04:38.963652+01:00 hera dovecot: master: Warning: Killed with signal 15 (by pid=5925 uid=0 code=kill) 2026-02-25T09:04:39.089438+01:00 hera dovecot: master: Dovecot v2.4.1-4 (7d8c0e5759) starting up for pop3, imap, sieve, lmtp (core dumps disabled) Password: passdb: ma.zhang@ecotech.tssr auth failed extra fields: user=ma.zhang@ecotech.tssr wilder@hera:~$

---

user=ma.zhang@ecotech.tssr wilder@hera:~$ sudo tail -20 /var/log/dovecot/dovecot.log 2026-02-25T08:34:09.861974+01:00 hera dovecot: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: delaying auth failure 2026-02-25T08:35:50.609415+01:00 hera dovecot: auth: Warning: Event 0x56443bbd3978 leaked (parent=0x56443bbddd48): auth-request.c:166 2026-02-25T08:35:50.611638+01:00 hera dovecot: auth: Warning: Event 0x56443bbddd48 leaked (parent=0x56443bbdc458): auth-request.c:138 2026-02-25T08:35:50.612189+01:00 hera dovecot: auth: Warning: Event 0x56443bbdc458 leaked (parent=0x56443bb35658): connection.c:620 2026-02-25T08:35:50.612586+01:00 hera dovecot: auth: Warning: Event 0x56443bbdbf38 leaked (parent=0x56443bbd2a78): auth-request.c:166 2026-02-25T08:35:50.612704+01:00 hera dovecot: auth: Warning: Event 0x56443bbd2a78 leaked (parent=0x56443bbd2668): auth-request.c:138 2026-02-25T08:35:50.612777+01:00 hera dovecot: auth: Warning: Event 0x56443bbd2668 leaked (parent=0x56443bb35658): connection.c:620 2026-02-25T08:35:50.612879+01:00 hera dovecot: auth: Warning: Event 0x56443bb35658 leaked (parent=(nil)): auth.c:515 2026-02-25T08:47:15.041856+01:00 hera dovecot: auth: Warning: Event 0x558242bbc1e8 leaked (parent=0x558242bbaa78): auth-request.c:166 2026-02-25T08:47:15.043388+01:00 hera dovecot: auth: Warning: Event 0x558242bbaa78 leaked (parent=0x558242bba668): auth-request.c:138 2026-02-25T08:47:15.043427+01:00 hera dovecot: auth: Warning: Event 0x558242bba668 leaked (parent=0x558242b1d658): connection.c:620 2026-02-25T08:47:15.043461+01:00 hera dovecot: auth: Warning: Event 0x558242b1d658 leaked (parent=(nil)): auth.c:515 2026-02-25T08:48:00.464099+01:00 hera dovecot: master: Warning: Killed with signal 15 (by pid=5368 uid=0 code=kill) 2026-02-25T08:48:00.809495+01:00 hera dovecot: master: Dovecot v2.4.1-4 (7d8c0e5759) starting up for pop3, imap, sieve, lmtp (core dumps disabled) 2026-02-25T08:48:40.098324+01:00 hera dovecot: master: Warning: Killed with signal 15 (by pid=5416 uid=0 code=kill) 2026-02-25T08:48:40.203902+01:00 hera dovecot: master: Dovecot v2.4.1-4 (7d8c0e5759) starting up for pop3, imap, sieve, lmtp (core dumps disabled) 2026-02-25T08:50:36.376296+01:00 hera dovecot: master: Warning: Killed with signal 15 (by pid=5489 uid=0 code=kill) 2026-02-25T08:50:36.499405+01:00 hera dovecot: master: Dovecot v2.4.1-4 (7d8c0e5759) starting up for pop3, imap, sieve, lmtp (core dumps disabled) 2026-02-25T09:04:38.963652+01:00 hera dovecot: master: Warning: Killed with signal 15 (by pid=5925 uid=0 code=kill) 2026-02-25T09:04:39.089438+01:00 hera dovecot: master: Dovecot v2.4.1-4 (7d8c0e5759) starting up for pop3, imap, sieve, lmtp (core dumps disabled) wilder@hera:~$

---

abled) wilder@hera:~$ sudo grep -n "auth\_debug\\|log\_path" /etc/dovecot/dovecot.conf | head -10 \[sudo\] Mot de passe de wilder: 56:#auth\_debug\_passwords = yes 81:log\_path = syslog 570: # Require 'log\_path =' in 'protocol lmtp {}' block. wilder@hera:~$

---

tail: option utilisée dans un contexte incorrect — 2

---

wilder@hera:~$ sudo journalctl -u dovecot | grep "ma.zhang\\|ldap\\|auth" | tail -20 \[sudo\] Mot de passe de wilder: févr. 25 08:34:09 hera.ecotech.tssr dovecot\[942\]: auth-worker(ma.zhang@ecotech.tssr)<4743>: request \[4\]: Debug: sql: query: SELECT mailbox.password, mailbox.allow\_nets FROM mailbox,domain WHERE mailbox.username='ma.zhang@ecotech.tssr' AND mailbox.`enabledoveadm` =1 AND mailbox.active=1 AND mailbox.domain=domain.domain AND domain.active=1 févr. 25 08:34:09 hera.ecotech.tssr dovecot\[942\]: auth-worker(ma.zhang@ecotech.tssr)<4743>: request \[4\]: sql: unknown user févr. 25 08:34:09 hera.ecotech.tssr dovecot\[942\]: auth-worker(ma.zhang@ecotech.tssr)<4743>: request \[4\]: Debug: sql: Finished passdb lookup févr. 25 08:34:09 hera.ecotech.tssr dovecot\[942\]: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: sql: Finished passdb lookup févr. 25 08:34:09 hera.ecotech.tssr dovecot\[942\]: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: Auth request finished févr. 25 08:34:09 hera.ecotech.tssr dovecot\[942\]: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: delaying auth failure févr. 25 08:35:50 hera.ecotech.tssr dovecot\[942\]: auth: Warning: Event 0x56443bbd3978 leaked (parent=0x56443bbddd48): auth-request.c:166 févr. 25 08:35:50 hera.ecotech.tssr dovecot\[942\]: auth: Warning: Event 0x56443bbddd48 leaked (parent=0x56443bbdc458): auth-request.c:138 févr. 25 08:35:50 hera.ecotech.tssr dovecot\[942\]: auth: Warning: Event 0x56443bbdc458 leaked (parent=0x56443bb35658): connection.c:620 févr. 25 08:35:50 hera.ecotech.tssr dovecot\[942\]: auth: Warning: Event 0x56443bbdbf38 leaked (parent=0x56443bbd2a78): auth-request.c:166 févr. 25 08:35:50 hera.ecotech.tssr dovecot\[942\]: auth: Warning: Event 0x56443bbd2a78 leaked (parent=0x56443bbd2668): auth-request.c:138 févr. 25 08:35:50 hera.ecotech.tssr dovecot\[942\]: auth: Warning: Event 0x56443bbd2668 leaked (parent=0x56443bb35658): connection.c:620 févr. 25 08:35:50 hera.ecotech.tssr dovecot\[942\]: auth: Warning: Event 0x56443bb35658 leaked (parent=(nil)): auth.c:515 févr. 25 08:43:16 hera.ecotech.tssr dovecot\[942\]: imap-login: Login aborted: Connection closed (auth failed, 1 attempts in 2 secs) (auth\_failed): user=<ma.zhang@ecotech.tssr>, method=LOGIN, rip=127.0.0.1, lip=127.0.0.1, TLS, session=<d3oaKKFLYNx/AAAB> févr. 25 08:43:33 hera.ecotech.tssr dovecot\[942\]: imap-login: Login aborted: Connection closed (auth failed, 1 attempts in 2 secs) (auth\_failed): user=<ma.zhang@ecotech.tssr>, method=LOGIN, rip=127.0.0.1, lip=127.0.0.1, TLS, session=<mNMYKaFLfol/AAAB> févr. 25 08:43:51 hera.ecotech.tssr dovecot\[942\]: imap-login: Login aborted: Connection closed (auth failed, 1 attempts in 2 secs) (auth\_failed): user=<ma.zhang@ecotech.tssr>, method=LOGIN, rip=127.0.0.1, lip=127.0.0.1, TLS, session=<+qErKqFLEJd/AAAB> févr. 25 08:47:15 hera.ecotech.tssr dovecot\[942\]: auth: Warning: Event 0x558242bbc1e8 leaked (parent=0x558242bbaa78): auth-request.c:166 févr. 25 08:47:15 hera.ecotech.tssr dovecot\[942\]: auth: Warning: Event 0x558242bbaa78 leaked (parent=0x558242bba668): auth-request.c:138 févr. 25 08:47:15 hera.ecotech.tssr dovecot\[942\]: auth: Warning: Event 0x558242bba668 leaked (parent=0x558242b1d658): connection.c:620 févr. 25 08:47:15 hera.ecotech.tssr dovecot\[942\]: auth: Warning: Event 0x558242b1d658 leaked (parent=(nil)): auth.c:515 wilder@hera:~$

---

wilder@hera:~$ sudo doveadm auth test ma.zhang@ecotech.tssr; sudo journalctl -u dovecot | grep "ma.zhang\\|ldap" | tail -10 Password: passdb: ma.zhang@ecotech.tssr auth failed extra fields: user=ma.zhang@ecotech.tssr févr. 25 08:34:09 hera.ecotech.tssr dovecot\[942\]: auth-worker(ma.zhang@ecotech.tssr)<4743>: request \[4\]: Debug: sql: Performing passdb lookup févr. 25 08:34:09 hera.ecotech.tssr dovecot\[942\]: auth-worker(ma.zhang@ecotech.tssr)<4743>: request \[4\]: Debug: sql: query: SELECT mailbox.password, mailbox.allow\_nets FROM mailbox,domain WHERE mailbox.username='ma.zhang@ecotech.tssr' AND mailbox.`enabledoveadm` =1 AND mailbox.active=1 AND mailbox.domain=domain.domain AND domain.active=1 févr. 25 08:34:09 hera.ecotech.tssr dovecot\[942\]: auth-worker(ma.zhang@ecotech.tssr)<4743>: request \[4\]: sql: unknown user févr. 25 08:34:09 hera.ecotech.tssr dovecot\[942\]: auth-worker(ma.zhang@ecotech.tssr)<4743>: request \[4\]: Debug: sql: Finished passdb lookup févr. 25 08:34:09 hera.ecotech.tssr dovecot\[942\]: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: sql: Finished passdb lookup févr. 25 08:34:09 hera.ecotech.tssr dovecot\[942\]: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: Auth request finished févr. 25 08:34:09 hera.ecotech.tssr dovecot\[942\]: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: delaying auth failure févr. 25 08:43:16 hera.ecotech.tssr dovecot\[942\]: imap-login: Login aborted: Connection closed (auth failed, 1 attempts in 2 secs) (auth\_failed): user=<ma.zhang@ecotech.tssr>, method=LOGIN, rip=127.0.0.1, lip=127.0.0.1, TLS, session=<d3oaKKFLYNx/AAAB> févr. 25 08:43:33 hera.ecotech.tssr dovecot\[942\]: imap-login: Login aborted: Connection closed (auth failed, 1 attempts in 2 secs) (auth\_failed): user=<ma.zhang@ecotech.tssr>, method=LOGIN, rip=127.0.0.1, lip=127.0.0.1, TLS, session=<mNMYKaFLfol/AAAB> févr. 25 08:43:51 hera.ecotech.tssr dovecot\[942\]: imap-login: Login aborted: Connection closed (auth failed, 1 attempts in 2 secs) (auth\_failed): user=<ma.zhang@ecotech.tssr>, method=LOGIN, rip=127.0.0.1, lip=127.0.0.1, TLS, session=<+qErKqFLEJd/AAAB> wilder@hera:~$

---

wilder@hera:~$ sudo journalctl -u dovecot --since "09:04" | grep -v "Warning\\|Debug\\|Skipping" | tail -20 févr. 25 09:04:38 hera.ecotech.tssr systemd\[1\]: Stopping dovecot.service - Dovecot IMAP/POP3 email server... févr. 25 09:04:39 hera.ecotech.tssr systemd\[1\]: dovecot.service: Deactivated successfully. févr. 25 09:04:39 hera.ecotech.tssr systemd\[1\]: Stopped dovecot.service - Dovecot IMAP/POP3 email server. févr. 25 09:04:39 hera.ecotech.tssr systemd\[1\]: Starting dovecot.service - Dovecot IMAP/POP3 email server... févr. 25 09:04:39 hera.ecotech.tssr dovecot\[5930\]: master: Dovecot v2.4.1-4 (7d8c0e5759) starting up for pop3, imap, sieve, lmtp (core dumps disabled) févr. 25 09:04:39 hera.ecotech.tssr systemd\[1\]: Started dovecot.service - Dovecot IMAP/POP3 email server. wilder@hera:~$

---

desole c'est log comme reponse...

---

c'est ok

---

ldap\_filter = (&(objectClass=user)(sAMAccountName=%{user | username})) wilder@hera:~$ sudo systemctl restart dovecot && sudo doveadm auth test ma.zhang@ecotech.tssr 2026-02-25T11:01:19.502092+01:00 hera dovecot: master: Warning: Killed with signal 15 (by pid=9438 uid=0 code=kill) 2026-02-25T11:01:19.617213+01:00 hera dovecot: master: Dovecot v2.4.1-4 (7d8c0e5759) starting up for pop3, imap, sieve, lmtp (core dumps disabled) Password: 2026-02-25T11:01:38.154113+01:00 hera dovecot: auth: Debug: Loading modules from directory: /usr/lib/dovecot/modules/auth 2026-02-25T11:01:38.158167+01:00 hera dovecot: auth: Debug: Module loaded: /usr/lib/dovecot/modules/auth/libdriver\_mysql.so 2026-02-25T11:01:38.159390+01:00 hera dovecot: auth: Debug: Loading modules from directory: /usr/lib/dovecot/modules/auth 2026-02-25T11:01:38.161118+01:00 hera dovecot: auth: Debug: Module loaded: /usr/lib/dovecot/modules/auth/libauthdb\_ldap.so 2026-02-25T11:01:38.164329+01:00 hera dovecot: auth: Debug: sqlpool(mysql): Creating new connection 2026-02-25T11:01:38.168073+01:00 hera dovecot: auth: Debug: Read auth token secret from /run/dovecot/auth-token-secret.dat 2026-02-25T11:01:38.168907+01:00 hera dovecot: auth: Debug: passwd-file /etc/dovecot/dovecot-master-users:Read 0 users in 0 secs 2026-02-25T11:01:38.169527+01:00 hera dovecot: auth: Debug: mysql(127.0.0.1): Connecting 2026-02-25T11:01:38.171745+01:00 hera dovecot: auth: Debug: conn unix:auth-client (pid=9456,uid=0) \[1\]: Server accepted connection (fd=21) 2026-02-25T11:01:38.172637+01:00 hera dovecot: auth: Debug: conn unix:auth-client (pid=9456,uid=0) \[1\]: auth client connected (pid=0) 2026-02-25T11:01:38.173261+01:00 hera dovecot: auth: Debug: conn unix:auth-client (pid=9456,uid=0) \[1\]: client in: AUTH#0111#011PLAIN#011protocol=doveadm#011final-resp-ok#011resp=AG1hLnpoYW5nQGVjb3RlY2gudHNzcgABemVydHkqMjAyNQ== (previous base64 data may contain sensitive data) 2026-02-25T11:01:38.174148+01:00 hera dovecot: auth(ma.zhang@ecotech.tssr,sasl:plain): Attempted login with password having illegal chars 2026-02-25T11:01:38.174935+01:00 hera dovecot: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: Auth request finished 2026-02-25T11:01:38.175423+01:00 hera dovecot: auth(ma.zhang@ecotech.tssr,sasl:plain): Debug: delaying auth failure passdb: ma.zhang@ecotech.tssr auth failed extra fields: user=ma.zhang@ecotech.tssr 2026-02-25T11:01:40.177814+01:00 hera dovecot: auth: Debug: conn unix:auth-client (pid=9456,uid=0) \[1\]: client passdb out: FAIL#0111#011user=ma.zhang@ecotech.tssr 2026-02-25T11:01:40.178473+01:00 hera dovecot: auth: Debug: conn unix:auth-client (pid=9456,uid=0) \[1\]: Disconnected: Connection closed (fd=21) wilder@hera:~$

ca pourrait pas etre un truc bete que nousavons oublié d'installer ou on peut peut etre chager de user?

---

je ne vois pas vraiment le resultat tu m'expliques?

---

sur rouncube connection to storage server failed...

---

quand j'essaye de me connecter cela me donne " [https://hera.ecotech.tssr/iredadmin](https://hera.ecotech.tssr/iredadmin) " Internal server error

---

vide

---

aucun fichier a ce nom

---

$repoonse vide

---

a:~$ sudo systemctl status iredadmin ● iredadmin.service - iRedAdmin daemon service Loaded: loaded (/usr/lib/systemd/system/iredadmin.service; enabled; preset: enabled) Active: active (running) since Wed 2026-02-25 08:23:54 CET; 3h 7min ago Invocation: 204bd38f0fb44ace9b73f241a895c68b Process: 852 ExecStartPre=/bin/mkdir -p /var/run/iredadmin (code=exited, status=0/SUCCESS) Process: 876 ExecStartPre=/bin/chown iredadmin:iredadmin /var/run/iredadmin (code=exited, status=0/SUCCESS) Process: 887 ExecStartPre=/bin/chmod 0755 /var/run/iredadmin (code=exited, status=0/SUCCESS) Main PID: 936 (uwsgi) Tasks: 6 (limit: 2293) Memory: 16.4M (peak: 26.4M, swap: 17.8M, swap peak: 18.3M) CPU: 3.089s CGroup: /system.slice/iredadmin.service ├─ 936 /usr/bin/uwsgi --ini /opt/www/iredadmin/rc\_scripts/uwsgi/debian.ini --pidfile /var/run/iredadmin/iredadmin.pid ├─1118 /usr/bin/uwsgi --ini /opt/www/iredadmin/rc\_scripts/uwsgi/debian.ini --pidfile /var/run/iredadmin/iredadmin.pid ├─1121 /usr/bin/uwsgi --ini /opt/www/iredadmin/rc\_scripts/uwsgi/debian.ini --pidfile /var/run/iredadmin/iredadmin.pid ├─1122 /usr/bin/uwsgi --ini /opt/www/iredadmin/rc\_scripts/uwsgi/debian.ini --pidfile /var/run/iredadmin/iredadmin.pid ├─1126 /usr/bin/uwsgi --ini /opt/www/iredadmin/rc\_scripts/uwsgi/debian.ini --pidfile /var/run/iredadmin/iredadmin.pid └─1131 /usr/bin/uwsgi --ini /opt/www/iredadmin/rc\_scripts/uwsgi/debian.ini --pidfile /var/run/iredadmin/iredadmin.pid févr. 25 11:28:23 hera.ecotech.tssr iredadmin\[936\]: Traceback (most recent call last): févr. 25 11:28:23 hera.ecotech.tssr iredadmin\[936\]: File "/opt/www/iRedAdmin-2.6/iredadmin.py", line 8, in <module> from libs import iredbase févr. 25 11:28:23 hera.ecotech.tssr iredadmin\[936\]: File "/opt/www/iRedAdmin-2.6/libs/iredbase.py", line 5, in <module> import web févr. 25 11:28:23 hera.ecotech.tssr iredadmin\[936\]: File "/opt/www/iRedAdmin-2.6/web/\_\_init\_\_.py", line 4, in <module> from. import ( # noqa: F401...<11 lines>... ) févr. 25 11:28:23 hera.ecotech.tssr iredadmin\[936\]: File "/opt/www/iRedAdmin-2.6/web/debugerror.py", line 19, in <module> from. import webapi as web févr. 25 11:28:23 hera.ecotech.tssr iredadmin\[936\]: File "/opt/www/iRedAdmin-2.6/web/webapi.py", line 6, in <module> import cgi févr. 25 11:28:23 hera.ecotech.tssr iredadmin\[936\]: ModuleNotFoundError: No module named 'cgi' févr. 25 11:28:23 hera.ecotech.tssr iredadmin\[936\]: unable to load app 0 (mountpoint='hera.ecotech.tssr|/iredadmin') (callable not found or import err> févr. 25 11:28:23 hera.ecotech.tssr iredadmin\[936\]: --- no python application found, check your startup logs for errors --- févr. 25 11:28:23 hera.ecotech.tssr iredadmin\[936\]: \[10.10.20.15\] GET /iredadmin 500 104 "-" lines 1-36/36 (END)

---

wilder@hera:~$ sudo pip install legacy-cgi --break-system-packages Collecting legacy-cgi Downloading legacy\_cgi-2.6.4-py3-none-any.whl.metadata (2.3 kB) Downloading legacy\_cgi-2.6.4-py3-none-any.whl (20 kB) Installing collected packages: legacy-cgi Successfully installed legacy-cgi-2.6.4 WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager, possibly rendering your system unusable. It is recommended to use a virtual environment instead: [https://pip.pypa.io/warnings/venv](https://pip.pypa.io/warnings/venv). Use the --root-user-action option if you know what you are doing and want to suppress this warning. wilder@hera:~$

---

ca peut mettre du temps ou je fais control C

---

Active: active (running) since Wed 2026-02-25 11:34:56 CET; 59ms ago

---

internal server error encor je redemarre?

---

Active: active (running) since Wed 2026-02-25 11:34:56 CET; 59ms ago wilder@hera:~$ sudo systemctl status iredadmin | grep "error\\|Error\\|module\\|Module" févr. 25 11:35:35 hera.ecotech.tssr iredadmin\[10469\]: --- no python application found, check your startup logs for errors --- févr. 25 11:37:01 hera.ecotech.tssr iredadmin\[10469\]: File "/opt/www/iRedAdmin-2.6/iredadmin.py", line 8, in <module> févr. 25 11:37:01 hera.ecotech.tssr iredadmin\[10469\]: File "/opt/www/iRedAdmin-2.6/libs/iredbase.py", line 19, in <module> févr. 25 11:37:01 hera.ecotech.tssr iredadmin\[10469\]: File "/opt/www/iRedAdmin-2.6/libs/iredpwd.py", line 3, in <module> févr. 25 11:37:01 hera.ecotech.tssr iredadmin\[10469\]: ModuleNotFoundError: No module named 'crypt' févr. 25 11:37:01 hera.ecotech.tssr iredadmin\[10469\]: unable to load app 0 (mountpoint='hera.ecotech.tssr|/iredadmin') (callable not found or import error) févr. 25 11:37:01 hera.ecotech.tssr iredadmin\[10469\]: --- no python application found, check your startup logs for errors --- wilder@hera:~$

---

la on a une liste d'error? on peut les regler toue a la suite et on voit apres non?

---

no module named crypt

---

ok

---

error encore

---

wilder@hera:~$ sudo systemctl status iredadmin | grep "ModuleNotFoundError\\|Error" févr. 25 11:42:05 hera.ecotech.tssr iredadmin\[10779\]: ModuleNotFoundError: No module named 'crypt' wilder@hera:~$

---

ok

---

ok

---

ok

---

il faudrait obigerv a utiliser l'adresse 10.10.20.11

---

ok

---

ok

---

desole coupure de courant dans mon immeuble a champigny

---

est ce que tu pense qu'on peut reussir a creer un compte a tous les users de la ADDS ecotech ou ca va etre galere?

---

l'envoie est bon mais pas de reception cote lu.morel@ecotech.tssr

---

2026-02-25T13:42:01.919789+01:00 hera roundcube: PHP Deprecated: session\_set\_save\_handler(): Providing individual callbacks instead of an object implementing SessionHandlerInterface is deprecated in /opt/www/roundcubemail-1.6.11/program/lib/Roundcube/rcube\_session.php on line 119 2026-02-25T13:42:03.145872+01:00 hera roundcube: PHP Deprecated: session\_set\_save\_handler(): Providing individual callbacks instead of an object implementing SessionHandlerInterface is deprecated in /opt/www/roundcubemail-1.6.11/program/lib/Roundcube/rcube\_session.php on line 119 2026-02-25T13:42:03.146277+01:00 hera roundcube: PHP Deprecated: session\_set\_save\_handler(): Providing individual callbacks instead of an object implementing SessionHandlerInterface is deprecated in /opt/www/roundcubemail-1.6.11/program/lib/Roundcube/rcube\_session.php on line 119 2026-02-25T13:42:41.666050+01:00 hera roundcube: PHP Deprecated: session\_set\_save\_handler(): Providing individual callbacks instead of an object implementing SessionHandlerInterface is deprecated in /opt/www/roundcubemail-1.6.11/program/lib/Roundcube/rcube\_session.php on line 119 2026-02-25T13:43:03.140161+01:00 hera roundcube: PHP Deprecated: session\_set\_save\_handler(): Providing individual callbacks instead of an object implementing SessionHandlerInterface is deprecated in /opt/www/roundcubemail-1.6.11/program/lib/Roundcube/rcube\_session.php on line 119 2026-02-25T13:43:04.781226+01:00 hera roundcube: PHP Deprecated: session\_set\_save\_handler(): Providing individual callbacks instead of an object implementing SessionHandlerInterface is deprecated in /opt/www/roundcubemail-1.6.11/program/lib/Roundcube/rcube\_session.php on line 119 wilder@hera:~$

---

dcubemail-1.6.11/program/lib/Roundcube/rcube\_imap.php on line 211 (POST /mail/?\_task=login&\_action=login) 2026-02-25T13:41:33.245251+01:00 hera roundcube: <868b9096> Failed login for lu.morel from 10.10.20.15 in session 868b90967a4b790b (error: -2) 2026-02-25T13:41:39.967105+01:00 hera roundcube: PHP Deprecated: session\_set\_save\_handler(): Providing individual callbacks instead of an object implementing SessionHandlerInterface is deprecated in /opt/www/roundcubemail-1.6.11/program/lib/Roundcube/rcube\_session.php on line 119 2026-02-25T13:41:40.059107+01:00 hera roundcube: <47dfafc1> Successful login for lu.morel@ecotech.tssr (ID: 3) from 10.10.20.15 in session 47dfafc1fb7e115e 2026-02-25T13:41:40.100061+01:00 hera roundcube: PHP Deprecated: session\_set\_save\_handler(): Providing individual callbacks instead of an object implementing SessionHandlerInterface is deprecated in /op

---

fwilder@hera:~$ sudo systemctl status amavis × amavis.service - Interface between MTA and virus scanner/content filters Loaded: loaded (/usr/lib/systemd/system/amavis.service; enabled; preset: enabled) Active: failed (Result: exit-code) since Wed 2026-02-25 12:55:38 CET; 51min ago Duration: 883ms Invocation: a0bbc546968045caa30343ea641a7253 Docs: [http://www.ijs.si/software/amavisd/#doc](http://www.ijs.si/software/amavisd/#doc) Process: 2530 ExecStartPre=/usr/bin/find /var/lib/amavis -maxdepth 1 -name amavis-\* -type d -exec rm -rf {}; (code=exited, status=0/SUCCESS) Process: 2533 ExecStartPre=/usr/bin/find /var/lib/amavis/tmp -maxdepth 1 -name amavis-\* -type d -exec rm -rf {}; (code=exited, status=0/SUCCESS) Process: 2536 ExecStart=/usr/sbin/amavisd foreground (code=exited, status=1/FAILURE) Main PID: 2536 (code=exited, status=1/FAILURE) févr. 25 12:55:38 hera.ecotech.tssr systemd\[1\]: amavis.service: Main process exited, code=exited, status=1/FAILURE févr. 25 12:55:38 hera.ecotech.tssr systemd\[1\]: amavis.service: Failed with result 'exit-code'. févr. 25 12:55:38 hera.ecotech.tssr systemd\[1\]: amavis.service: Scheduled restart job, restart counter is at 13. févr. 25 12:55:38 hera.ecotech.tssr systemd\[1\]: amavis.service: Start request repeated too quickly. févr. 25 12:55:38 hera.ecotech.tssr systemd\[1\]: amavis.service: Failed with result 'exit-code'. févr. 25 12:55:38 hera.ecotech.tssr systemd\[1\]: Failed to start amavis.service - Interface between MTA and virus scanner/content filters. wilder@hera:~$

---

évr. 25 12:55:38 hera.ecotech.tssr systemd\[1\]: Failed to start amavis.service - Interface between MTA and virus scanner/content filters. wilder@hera:~$ sudo amavisd foreground 2>&1 | tail -20 Error in config file "/etc/amavis/conf.d/50-user": Can't open PEM file /var/lib/dkim/ecotech.tssr.pem: No such file or directory at /usr/share/perl5/Amavis/Conf.pm line 388.

---

c'est quoi

---

amavisd-new commande introuvable

---

ok

---

ok

---

recu!!!!!!!!

---

on essaye de creer un compte a tous le monde on change le mot de passe

---

sur aresg?

---

sur aresg?

---

peut tu me faire la commande pour copier cela dans un fichier txt comme ca je te le transmet..

---

on peut se le r amener sur le host avec scp

---

la on l'envoie ou, je veux le rpatrier sur mon host

---

on peut remonter part les ports?

---

le fichier est sur hera et je veux le recuperer dans mon host pour te le donner

---

C:\\WINDOWS\\System32\\OpenSSH\\scp.exe: Connection closed PS C:\\Users\\Antoine the BG> scp -p 34000 wilder@127.0.0.1:/tmp/users\_ad.txt C:\\Users\\"Antoine the BG"\\Desktop\\users\_ad.txt C:/Users/Antoine the BG/Desktop/users\_ad.txt: No such file or directory PS C:\\Users\\Antoine the BG> le p doit etre nen misnudcule

---

sinon je te copie les users tel quel

---

je vais faire la commande mais avant je voulais te demander ce qu'on a fait et pourquopoi le domaine tssr est sur le disque principal alors qu'on a plein de place sur le LV

---

91%

---

wilder@hera:~$ sudo du -sh /var/cache/\* /var/lib/\* 2>/dev/null | sort -rh | head -20 168M /var/lib/clamav 163M /var/lib/mysql 125M /var/lib/apt 93M /var/cache/apt 67M /var/lib/dpkg 22M /var/lib/aspell 22M /var/cache/fwupd 21M /var/cache/swcatalog 19M /var/lib/swcatalog 6,3M /var/cache/debconf 5,1M /var/lib/spamassassin 3,9M /var/lib/gdm3 3,7M /var/cache/apparmor 3,0M /var/lib/ucf 2,1M /var/cache/man 1,9M /var/lib/fwupd 1,9M /var/cache/cracklib 1,7M /var/cache/fontconfig 784K /var/lib/systemd 252K /var/lib/amavis wilder@hera:~$

---

sinon j'agrandis le disque dans virtual box:-)

---

wilder@hera:~$ df -h Sys. de fichiers Taille Utilisé Dispo Uti% Monté sur udev 957M 0 957M 0% /dev tmpfs 198M 1,5M 196M 1% /run /dev/sda2 7,3G 6,3G 605M 92% / tmpfs 987M 612K 987M 1% /dev/shm tmpfs 5,0M 8,0K 5,0M 1% /run/lock tmpfs 1,0M 0 1,0M 0% /run/credentials/systemd-journald.service /dev/mapper/vg\_data-lv\_data2 15G 2,1M 14G 1% /var/log/iredmail /dev/mapper/vg\_data-lv\_data 15G 2,9M 14G 1% /var/vmail tmpfs 987M 112K 987M 1% /tmp /dev/sda1 455M 147M 283M 35% /boot /dev/sda4 11G 288M 11G 3% /home tmpfs 198M 92K 198M 1% /run/user/1000 wilder@hera:~$

---

400Mo environ

---

wilder@hera:~$ sudo du -sh /\* 2>/dev/null | sort -rh | head -15 5,1G /usr 834M /var 404M /opt 286M /home 147M /boot 14M /etc 2,2M /root 1,6M /run 608K /dev 20K /mnt 16K /tmp 16K /lost+found 12K /media 12K /log 4,0K /srv wilder@hera:~$ wilder@hera:~$

---

ca y est j'ai agrandi sda

---

j'ai agrandi et redemarre

---

sda 8:0 0 30G 0 disk ├─sda1 8:1 0 487M 0 part /boot ├─sda2 8:2 0 7,5G 0 part / ├─sda3 8:3 0 954M 0 part \[SWAP\] └─sda4 8:4 0 11,1G 0 part /home wilder@hera:/usr$

je l'ai groqsi de 10 giga il fait 30

---

pourquio parles tu de sdb?

---

Number Start End Size Type File system Flags 1024B 1049kB 1048kB Free Space 1 1049kB 512MB 511MB primary ext2 boot 2 512MB 8511MB 8000MB primary ext4 3 8511MB 9512MB 1000MB primary linux-swap(v1) swap 4 9512MB 21,5GB 12,0GB primary ext4 21,5GB 32,3GB 10,8GB Free Space sinon on degage le swap,

---

c'est bien le sda2 qui pose problemem

---

on est en mbr....on ne peux pas recreer de parttion

---

et on ne peut rien faire avec me sdisque s LV

---

NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS sda 8:0 0 30G 0 disk ├─sda1 8:1 0 487M 0 part /boot ├─sda2 8:2 0 7,5G 0 part / ├─sda3 8:3 0 954M 0 part \[SWAP\] └─sda4 8:4 0 11,1G 0 part /home sdb 8:16 0 10,4G 0 disk sdc 8:32 0 20G 0 disk └─vg\_data-lv\_data 254:0 0 15G 0 lvm /var/vmail sdd 8:48 0 25,1G 0 disk └─vg\_data-lv\_data2 254:1 0 15G 0 lvm /var/log/iredmail wilder@hera:/usr$

---

wilder@hera:/usr$ sudo vgs && sudo lvs && sudo pvs VG #PV #LV #SN Attr VSize VFree vg\_data 3 2 0 wz--n- 55,48g 25,48g LV VG Attr LSize Pool Origin Data% Meta% Move Log Cpy%Sync Convert lv\_data vg\_data -wi-ao---- 15,00g lv\_data2 vg\_data -wi-ao---- 15,00g PV VG Fmt Attr PSize PFree /dev/sdb vg\_data lvm2 a-- <10,43g <10,43g /dev/sdc vg\_data lvm2 a-- <20,00g <5,00g /dev/sdd vg\_data lvm2 a-- <25,06g <10,06g wilder@hera:/usr$

---

et comme tu disais on peut pas creer un disque en symlink et on le pose dans user...

---

decoupe pas prend directement data-lv\_data2

---

ok

---

wilder@hera:/usr$ sudo du -sh /var/log/iredmail/opt/ 405M /var/log/iredmail/opt/ wilder@hera:/usr$

---

te m'explique je en comprends pas tout

---

ok

---

vide

---

wilder@hera:/usr$ ls -la / | grep opt && df -h / lrwxrwxrwx 1 root root 21 25 févr. 18:33 opt -> /var/log/iredmail/opt drwxr-xr-x 6 root root 4096 23 févr. 16:08 opt.bak Sys. de fichiers Taille Utilisé Dispo Uti% Monté sur /dev/sda2 7,3G 6,3G 604M 92% / wilder@hera:/usr$

---

il y avait pas une version de iredmail qu'o,n avait charge pour rien peut on voir si dans user il n'y aurait pas des paquets en trop

---

les 4 services actifs et running

---

c'est quoi le monitoring

---

estc e que j'en aurais besoin dans zabbix

---

wilder@hera:/usr$ sudo du -sh /opt.bak/\* 0 /opt.bak/iredapd 1,8M /opt.bak/iRedAPD-5.9.1 0 /opt.bak/mlmmjadmin 1,2M /opt.bak/mlmmjadmin-3.4.0 367M /opt.bak/netdata 37M /opt.bak/www wilder@hera:/usr$

---

37M /opt.bak/www wilder@hera:/usr$ sudo systemctl stop netdata && sudo systemctl disable netdata Removed '/etc/systemd/system/multi-user.target.wants/netdata.service'. wilder@hera:/usr$

---

Sys. de fichiers Taille Utilisé Dispo Uti% Monté sur udev 957M 0 957M 0% /dev tmpfs 198M 1,5M 196M 1% /run /dev/sda2 7,3G 6,0G 969M 87% / tmpfs 987M 608K 987M 1% /dev/shm tmpfs 5,0M 8,0K 5,0M 1% /run/lock tmpfs 1,0M 0 1,0M 0% /run/credentials/systemd-journald.service /dev/mapper/vg\_data-lv\_data2 15G 42M 14G 1% /var/log/iredmail /dev/mapper/vg\_data-lv\_data 15G 2,9M 14G 1% /var/vmail tmpfs 987M 112K 987M 1% /tmp /dev/sda1 455M 147M 283M 35% /boot /dev/sda4 11G 288M 11G 3% /home tmpfs 198M 92K 198M 1% /run/user/1000 wilder@hera:/usr$

---

ok 86 %

---

tu sais qu'il faut changer tous les mots de passe

---

wilder@hera:/usr$ sudo mysql -u vmailadmin -p'swRnasr2kqxRU1HRCt0GD0pIQn4aA3It' vmail -e "SELECT username FROM mailbox;" +-------------------------+ | username | +-------------------------+ | lu.morel@ecotech.tssr | | ma.zhang@ecotech.tssr | | postmaster@ecotech.tssr | +-------------------------+ wilder@hera:/usr$

---

+-------------------------+ wilder@hera:/usr$ python3 -c "import bcrypt; print(bcrypt.hashpw(b'Ecotech2025!', bcrypt.gensalt()).decode())" -bash:!',: event not found wilder@hera:/usr$

---

$2b$12$KQWWF5mJMwJtzTRtWMXlJucL3OAkI/PHn916BGrsFAoVZwMJnG4ta

---

ok

---

ca fait combien,

---

on aurait pu copiet les users dans un fichier et faire unscripts de lignes?

---

tu peux me montrer ce que le script serait devenu avec le fichier comme source

---

ca t'embete de m'expliquer ligne par ligne?

---

ok

---

comment verifie t'on?

---

mais le mdp "Ecotech2025!" n'ouvre pas la porte

---

ce n'etait pas ce qu'on a deja fait?

---

pourquoi ce ne marche jamais du premier coup avec moi.....

---

si je l'ai fais bien sur

---

PS C:\\Users\\wilder> Get-ADUser ad.bakir -Properties LockedOut, Enabled | Select Name, LockedOut, Enabled Name LockedOut Enabled ---- --------- ------- Adel Bakir True True PS C:\\Users\\wilder>

---

PS C:\\Users\\wilder> Get-ADUser am.silva -Properties LockedOut, Enabled | Select Name, LockedOut, Enabled Name LockedOut Enabled ---- --------- ------- Amara Silva False True

---

PS C:\\Users\\wilder> Get-ADUser am.silva -Properties PasswordLastSet | Select Name, PasswordLastSet Name PasswordLastSet ---- --------------- Amara Silva 25/02/2026 22:00:46

---

\-bash: Ecotech2025!: commande introuvable wilder@hera:~$ sudo doveadm auth test am.silva@ecotech.tssr Password: passdb: am.silva@ecotech.tssr auth failed extra fields: user=am.silva@ecotech.tssr wilder@hera:~$

---

user=am.silva@ecotech.tssr wilder@hera:~$ sudo doveadm -D auth test am.silva@ecotech.tssr 2>&1 | grep -i "ldap\\|bind\\|filter\\|result\\|fail" Debug: Skipping module doveadm\_acl\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_acl\_plugin.so: undefined symbol: acl\_user\_module (this is usually intentional, so just ignore this message) Debug: Skipping module doveadm\_quota\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_quota\_plugin.so: undefined symbol: quota\_user\_module (this is usually intentional, so just ignore this message) Debug: Skipping module doveadm\_fts\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/lib20\_doveadm\_fts\_plugin.so: undefined symbol: fts\_backend\_rescan (this is usually intentional, so just ignore this message) Debug: Skipping module doveadm\_fts\_flatcurve\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/libdoveadm\_fts\_flatcurve\_plugin.so: undefined symbol: fts\_flatcurve\_user\_module (this is usually intentional, so just ignore this message) Debug: Skipping module doveadm\_mail\_crypt\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/libdoveadm\_mail\_crypt\_plugin.so: undefined symbol: crypt\_acl\_setting\_parser\_info (this is usually intentional, so just ignore this message) Feb 25 22:18:50 Debug: Skipping module doveadm\_fts\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/lib20\_doveadm\_fts\_plugin.so: undefined symbol: fts\_backend\_rescan (this is usually intentional, so just ignore this message) Feb 25 22:18:50 Debug: Skipping module doveadm\_fts\_flatcurve\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/libdoveadm\_fts\_flatcurve\_plugin.so: undefined symbol: fts\_flatcurve\_user\_module (this is usually intentional, so just ignore this message) Feb 25 22:18:50 Debug: Skipping module doveadm\_mail\_crypt\_plugin, because dlopen() failed: /usr/lib/dovecot/modules/doveadm/libdoveadm\_mail\_crypt\_plugin.so: undefined symbol: crypt\_acl\_setting\_parser\_info (this is usually intentional, so just ignore this message)

---

passdb: am.silva@ecotech.tssr auth failed wilder@hera:~$ sudo doveadm -D auth test am.silva@ecotech.tssr 2>&1 | grep -v "Skipping\\|dlopen\\|undefined" Debug: Loading modules from directory: /usr/lib/dovecot/modules/doveadm Debug: Module loaded: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_sieve\_plugin.so Feb 25 22:20:01 Debug: Loading modules from directory: /usr/lib/dovecot/modules Feb 25 22:20:01 Debug: Module loaded: /usr/lib/dovecot/modules/lib01\_acl\_plugin.so Feb 25 22:20:01 Debug: Module loaded: /usr/lib/dovecot/modules/lib10\_quota\_plugin.so Feb 25 22:20:01 Debug: Module loaded: /usr/lib/dovecot/modules/lib15\_notify\_plugin.so Feb 25 22:20:01 Debug: Module loaded: /usr/lib/dovecot/modules/lib20\_mail\_log\_plugin.so Feb 25 22:20:01 Debug: Loading modules from directory: /usr/lib/dovecot/modules/doveadm Feb 25 22:20:01 Debug: Module loaded: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_acl\_plugin.so Feb 25 22:20:01 Debug: Module loaded: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_quota\_plugin.so

---

passdb: am.silva@ecotech.tssr auth failed wilder@hera:~$ sudo doveadm -D auth test am.silva@ecotech.tssr 2>&1 | grep -v "Skipping\\|dlopen\\|undefined" Debug: Loading modules from directory: /usr/lib/dovecot/modules/doveadm Debug: Module loaded: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_sieve\_plugin.so Feb 25 22:20:01 Debug: Loading modules from directory: /usr/lib/dovecot/modules Feb 25 22:20:01 Debug: Module loaded: /usr/lib/dovecot/modules/lib01\_acl\_plugin.so Feb 25 22:20:01 Debug: Module loaded: /usr/lib/dovecot/modules/lib10\_quota\_plugin.so Feb 25 22:20:01 Debug: Module loaded: /usr/lib/dovecot/modules/lib15\_notify\_plugin.so Feb 25 22:20:01 Debug: Module loaded: /usr/lib/dovecot/modules/lib20\_mail\_log\_plugin.so Feb 25 22:20:01 Debug: Loading modules from directory: /usr/lib/dovecot/modules/doveadm Feb 25 22:20:01 Debug: Module loaded: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_acl\_plugin.so Feb 25 22:20:01 Debug: Module loaded: /usr/lib/dovecot/modules/doveadm/lib10\_doveadm\_quota\_plugin.so Password: Feb 25 22:21:58 Debug: auth-client: conn unix:/run/dovecot/auth-client: Connecting Feb 25 22:21:58 Debug: auth-client: conn unix:/run/dovecot/auth-client (pid=918,uid=0): Client connected (fd=9) Feb 25 22:21:58 Debug: auth-client: request \[1\]: Started request Feb 25 22:22:01 Debug: auth-client: conn unix:/run/dovecot/auth-client (pid=918,uid=0): auth input: FAIL 1 user=am.silva@ecotech.tssr Feb 25 22:22:01 Debug: auth-client: request \[1\]: Finished Feb 25 22:22:01 Debug: auth-client: conn unix:/run/dovecot/auth-client (pid=918,uid=0): Disconnected: Connection closed (fd=9) passdb: am.silva@ecotech.tssr auth failed extra fields: user=am.silva@ecotech.tssr wilder@hera:~$

---

user=am.silva@ecotech.tssr wilder@hera:~$ sudo journalctl -u dovecot --since "1 min ago" | grep -v "Warning\\|Debug\\|Skipping" févr. 25 22:21:58 hera.ecotech.tssr dovecot\[963\]: \[1.4K blob data\] févr. 25 22:21:58 hera.ecotech.tssr dovecot\[963\]: auth-worker(am.silva@ecotech.tssr)<11659>: request \[1\]: ldap: Password mismatch (for LDAP bind) févr. 25 22:21:58 hera.ecotech.tssr dovecot\[963\]: auth-worker(am.silva@ecotech.tssr)<11659>: request \[2\]: sql: Password mismatch wilder@hera:~$

---

PS C:\\Users\\wilder> Get-ADUser am.silva -Properties PasswordLastSet, BadPwdCount | Select Name, PasswordLastSet, BadPwdCount Name PasswordLastSet BadPwdCount ---- --------------- ----------- Amara Silva 25/02/2026 22:00:46 3 PS C:\\Users\\wilder>

---

tu veux metre EcotechSolutions2025! comme mdp

---

mais on ne la pas changer dans la bse, c'est pas grave, il y a juste le mdp de ADDS qui compte,

---

févr. 25 22:21:58 hera.ecotech.tssr dovecot\[963\]: auth-worker(am.silva@ecotech.tssr)<11659>: request \[2\]: sql: Password mismatch wilder@hera:~$ sudo doveadm auth test ma.zhang@ecotech.tssr Password: passdb: ma.zhang@ecotech.tssr auth succeeded extra fields: user=ma.zhang@ecotech.tssr wilder@hera:~

---

o

---

o

---

Count: 0 Average: Sum: Maximum: Minimum: Property: Count: 0 Average: Sum: Maximum: Minimum: Property:

---

Name LockedOut Enabled ---- --------- ------- Amara Silva False True

---

mais on l'a chage en EcotechSolutions2025! non?

---

je crois savoir les comptes sont desactives entte 20h et 7 hoo du matin...

---

marche pas

---

je voudrais rajouter une experience sur mon Dossier Professionnel et je voudrais raconter dans les même termes et à la premiere personne notre installation de iredmail. tu pourrais m'aider a le rediger?

---

je voudrais rajouter une experience sur mon Dossier Professionnel et je voudrais raconter dans les même termes et à la premiere personne notre installation de iredmail. tu pourrais m'aider a le rediger?

---

c'est super merci tu peux ralonger un peu l'historique, dire que je me suis aider d'une IA ( Claude ) et expliquer au debut la structure d'un service de messagerie avec nginx maria apache2 posix

---

j'ai modifié un peu, je te montre?

---

corrigee

---

est ce que tu pourrais me faire un schema de l'architecture que nous avons creer avec tous les services que s'enchaines que je comprennes bien la cahien, aussiavec roundcube et le smtp et le pop /imap c'est possible?

---
## 💡 Ma Solution / Notes
> [!TIP] Insérez votre analyse ou vos corrections ici.ontent}}