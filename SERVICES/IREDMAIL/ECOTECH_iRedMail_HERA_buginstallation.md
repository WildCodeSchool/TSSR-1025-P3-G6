# Installation iRedMail sur HERA — Debian 13 (Trixie)
> Projet EcoTech TSSR — Date : 24/02/2026
> Machine : HERA — IP : 10.10.20.11/26 — Réseau ACROPOLE

---

## 1. Préparation DNS sur ARESKI (Windows DNS Manager)

- Enregistrement **A** : `hera.ecotech.tssr` → `10.10.20.11`
- Enregistrement **MX** : `ecotech.tssr` → `hera.ecotech.tssr` (priorité 10)
- Réservation DHCP sur ARESKI pour MAC `08-00-27-27-81-13` → `10.10.20.11`

---

## 2. Préparation LVM sur HERA

```bash
# Démontage des LV clonés de DEBIANA
sudo umount /var/www/glpi

# Formatage ext4
sudo mkfs.ext4 /dev/vg_data/lv_data     # UUID: 2ea85851-a868-4c73-9e51-0b47d534b7f8
sudo mkfs.ext4 /dev/vg_data/lv_data2    # UUID: b4e78ecd-1daf-41b2-a525-e44e5e310ef2

# Création des points de montage
sudo mkdir -p /var/vmail
sudo mkdir -p /var/log/iredmail

# Montage
sudo mount /dev/vg_data/lv_data /var/vmail
sudo mount /dev/vg_data/lv_data2 /var/log/iredmail
```

### /etc/fstab — entrées à ajouter

```
UUID=2ea85851-a868-4c73-9e51-0b47d534b7f8   /var/vmail        ext4    defaults   0   2
UUID=b4e78ecd-1daf-41b2-a525-e44e5e310ef2   /var/log/iredmail ext4    defaults   0   2
```

> **Supprimer** l'entrée `/var/www/glpi` héritée du clone DEBIANA.

---

## 3. Préparation hostname

```bash
sudo hostnamectl set-hostname hera.ecotech.tssr
```

### /etc/hosts — ajouter la ligne

```
10.10.20.11     hera.ecotech.tssr hera
```

Vérification :
```bash
hostname -f
# Résultat attendu : hera.ecotech.tssr
```

---

## 4. Téléchargement iRedMail 1.7.4

```bash
wget https://github.com/iredmail/iRedMail/archive/refs/tags/1.7.4.tar.gz
tar xvf 1.7.4.tar.gz
cd iRedMail-1.7.4
```

---

## 5. Correction compatibilité Debian 13

### 5.1 Forcer l'acceptation de Debian 13

```bash
nano conf/global
```

Ligne ~289 — modifier :
```
echo "${DISTRO_VERSION}" | grep -E '^(12)' &>/dev/null
```
En :
```
echo "${DISTRO_VERSION}" | grep -E '^(12|13)' &>/dev/null
```

### 5.2 Corriger les paquets renommés dans Debian 13

```bash
# liblz4-tool → lz4
sed -i 's/liblz4-tool/lz4/g' functions/packages.sh

# Vérifier que netcat-openbsd est bien utilisé (pas netcat)
grep -n "netcat" functions/packages.sh
```

---

## 6. Installation iRedMail — Wizard

```bash
sudo bash iRedMail.sh
```

| Question | Réponse |
|----------|---------|
| Storage path | `/var/vmail` |
| Web server | Nginx |
| Backend | MariaDB |
| First mail domain | `ecotech.tssr` |
| Admin email | `postmaster@ecotech.tssr` |
| Composants | Roundcubemail, netdata, iRedAdmin, Fail2ban (SOGo décoché) |
| Firewall nftables | `n` (géré par pfSense) |

---

## 7. Corrections post-installation Debian 13 / Dovecot 2.4

iRedMail génère des configs pour Dovecot 2.3. Debian 13 installe Dovecot 2.4 — incompatible.

### 7.1 Arrêter Apache2 (conflict port 80 avec Nginx)

```bash
sudo systemctl stop apache2
sudo systemctl disable apache2
```

### 7.2 Remplacer dovecot.conf par la version Dovecot 2.4

```bash
# Backup
sudo cp /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.bak

# Télécharger la config officielle pour MariaDB + Dovecot 2.4
sudo wget -O /etc/dovecot/dovecot.conf https://docs.iredmail.org/files/dovecot/dovecot-2.4-mariadb.conf

# Récupérer le mot de passe vmailadmin
sudo grep "vmailadmin\|password" /etc/dovecot/dovecot-used-quota.conf

# Injecter le mot de passe dans la nouvelle config
sudo sed -i 's/AQjaT42HjU3sZfSHSC5h2og5iJEu22aT/VOTRE_MOT_DE_PASSE/' /etc/dovecot/dovecot.conf
```

> Mot de passe vmailadmin EcoTech : `swRnasr2kqxRU1HRCt0GD0pIQn4aA3It`

Les certificats SSL sont déjà corrects (générés par iRedMail) :
```
ssl_server_cert_file = /etc/ssl/certs/iRedMail.crt
ssl_server_key_file  = /etc/ssl/private/iRedMail.key
ssl_server_dh_file   = /etc/ssl/dh2048_param.pem
```

### 7.3 Corriger PHP-FPM — socket Unix vs port TCP

Nginx pointe vers `127.0.0.1:9999` mais PHP 8.4 écoute sur un socket Unix.

```bash
sudo nano /etc/nginx/conf-available/php_fpm.conf
```

Modifier :
```nginx
# AVANT
upstream php_workers {
    server 127.0.0.1:9999;
}

# APRÈS
upstream php_workers {
    server unix:/run/php/php8.4-fpm.sock;
}
```

```bash
sudo systemctl restart nginx
```

---

## 8. Démarrage des services

```bash
sudo systemctl start mariadb postfix dovecot nginx
sudo systemctl status mariadb postfix dovecot nginx
```

---

## 9. URLs d'accès

| Service | URL |
|---------|-----|
| Webmail Roundcube | `https://hera.ecotech.tssr/mail/` |
| Admin iRedAdmin | `https://hera.ecotech.tssr/iredadmin/` |
| Monitoring netdata | `https://hera.ecotech.tssr/netdata/` |

**Credentials admin :**
- Login : `postmaster@ecotech.tssr`
- Password : `Azerty1*2025`

---

## 10. Règles pfSense à créer (HERA 10.10.20.11)

| Port | Protocole | Service |
|------|-----------|---------|
| 25 | TCP | SMTP inter-serveurs |
| 587 | TCP | SMTP clients (Thunderbird) |
| 143 | TCP | IMAP |
| 993 | TCP | IMAP SSL |
| 443 | TCP | HTTPS Roundcube/iRedAdmin |
| 80 | TCP | Redirection vers 443 |

> Prévoir règle supplémentaire : tunnel OpenVPN → HERA sur ports 993/587/443

---

## 11. Diagnostic et sauvetage — Méthode à retenir pour Debian 13

### Problème : service qui ne démarre pas

**Ne pas se contenter de `systemctl status`** — le message est trop résumé.
Lancer le binaire directement pour obtenir l'erreur brute :

```bash
sudo dovecot -F 2>&1
sudo nginx -t
sudo postfix check
```

### Signal d'alarme : corrections en cascade

Si corriger un paramètre génère une nouvelle erreur sur la ligne suivante → **problème structurel**, pas un bug isolé. Chercher la doc officielle plutôt que de corriger ligne par ligne.

### Problème 502 Bad Gateway — Nginx + PHP-FPM

Nginx ne trouve pas PHP-FPM. Diagnostic :

```bash
# Vérifier sur quel socket PHP-FPM écoute réellement
sudo ss -xlnp | grep php
# Résultat Debian 13 : /run/php/php8.4-fpm.sock (socket Unix, pas TCP)

# Nginx pointe par défaut sur 127.0.0.1:9999 — incorrect sur Debian 13
sudo cat /etc/nginx/conf-available/php_fpm.conf
```

Correction :
```bash
sudo nano /etc/nginx/conf-available/php_fpm.conf
```
```nginx
# Remplacer
upstream php_workers {
    server 127.0.0.1:9999;
}
# Par
upstream php_workers {
    server unix:/run/php/php8.4-fpm.sock;
}
```
```bash
sudo systemctl restart nginx
```

### Problème fstab au boot — emergency mode

Si le système démarre en emergency mode :
1. Se connecter en root sur la console
2. `nano /etc/fstab`
3. Supprimer toute entrée pointant vers un UUID inexistant ou un point de montage invalide
4. `systemctl daemon-reload`
5. Redémarrer

### Commandes de diagnostic utiles

```bash
systemctl status SERVICE --no-pager     # état complet
journalctl -xeu SERVICE --no-pager      # logs systemd détaillés
/usr/sbin/dovecot -F 2>&1              # erreur brute Dovecot
ss -tlnp                                # ports TCP ouverts
ss -xlnp                                # sockets Unix ouverts
grep -rn "mot" /etc/dossier/           # chercher dans les configs
sed -i 's/ancien/nouveau/g' fichier    # modifier en place
```

---

## 12. À faire — Phase suivante

- Intégration LDAP/AD avec ARESKI (`10.10.20.4`) pour authentification des comptes `pp.nnnnnnn@ecotech.tssr`
- Modifier `/etc/dovecot/dovecot.conf` et `/etc/postfix/main.cf` pour pointer vers ARESKI LDAP port 389
- Créer compte de service AD `svc.iredmail` pour les requêtes LDAP
- Tester envoi/réception entre comptes via Thunderbird
- Correction DKIM (`/var/lib/dkim/ecotech.tssr.pem` manquant)
