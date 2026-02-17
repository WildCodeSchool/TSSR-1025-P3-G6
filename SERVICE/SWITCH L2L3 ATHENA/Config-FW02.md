# Guide de Configuration FW02 - Routeur Debian

## Projet Ekoloclast - Infrastructure Réseau

---

## 📋 Table des matières

1. [Analyse de FW02](https://claude.ai/chat/987841d5-53ee-4cdc-8d9c-26faa906ad93#1-analyse-de-fw02)
2. [Architecture VirtualBox](https://claude.ai/chat/987841d5-53ee-4cdc-8d9c-26faa906ad93#2-architecture-virtualbox)
3. [Installation Debian](https://claude.ai/chat/987841d5-53ee-4cdc-8d9c-26faa906ad93#3-installation-debian)
4. [Configuration Réseau](https://claude.ai/chat/987841d5-53ee-4cdc-8d9c-26faa906ad93#4-configuration-r%C3%A9seau)
5. [Activation du Routage](https://claude.ai/chat/987841d5-53ee-4cdc-8d9c-26faa906ad93#5-activation-du-routage)
6. [Configuration des VLANs](https://claude.ai/chat/987841d5-53ee-4cdc-8d9c-26faa906ad93#6-configuration-des-vlans)
7. [Configuration iptables](https://claude.ai/chat/987841d5-53ee-4cdc-8d9c-26faa906ad93#7-configuration-iptables)
8. [Tests et Validation](https://claude.ai/chat/987841d5-53ee-4cdc-8d9c-26faa906ad93#8-tests-et-validation)
9. [Simulation des Switches](https://claude.ai/chat/987841d5-53ee-4cdc-8d9c-26faa906ad93#9-simulation-des-switches)

---

## 1. Analyse de FW02

### 1.1 Rôle de FW02 "Retour"

D'après le schéma réseau, **FW02** est un élément central qui assure :

|Fonction|Description|
|---|---|
|**Routeur inter-VLAN**|Permet la communication entre les VLANs 10, 20, 30|
|**Passerelle par défaut**|Pour tous les VLANs internes|
|**Point de transit**|Vers FW01 (pfSense) pour l'accès Internet|
|**Filtrage interne**|Contrôle du trafic entre zones|

### 1.2 Interfaces de FW02 selon le schéma

```
                    ┌─────────────────────────────────────┐
                    │           FW02 Retour               │
                    │           (Debian)                  │
                    │                                     │
    Vers FW01 ──────┤ G0/0    │    G0/1 (trunk)          │
    VLAN 5          │ 10.10.5.2│    ├── IF1: 172.16.10.14/28 (VLAN 10)
    10.10.5.0/29    │         │    ├── IF2: 172.16.20.14/28 (VLAN 20)
                    │         │    └── IF3: 172.16.30.14/28 (VLAN 30)
                    └─────────────────────────────────────┘
```

### 1.3 Plan d'adressage FW02

|Interface|VLAN|Adresse IP|Masque|Rôle|
|---|---|---|---|---|
|enp0s3 (G0/0)|5|10.10.5.2|/29|Lien vers FW01|
|enp0s8.10|10|172.16.10.14|/28|Passerelle Serveurs|
|enp0s8.20|20|172.16.20.14|/28|Passerelle Zone Test|
|enp0s8.30|30|172.16.30.14|/28|Passerelle DMZ|

### 1.4 Table de routage cible

|Destination|Passerelle|Interface|Description|
|---|---|---|---|
|10.10.5.0/29|direct|enp0s3|VLAN 5 Transit|
|172.16.10.0/28|direct|enp0s8.10|VLAN 10 Serveurs|
|172.16.20.0/28|direct|enp0s8.20|VLAN 20 Test|
|172.16.30.0/28|direct|enp0s8.30|VLAN 30 DMZ|
|0.0.0.0/0|10.10.5.1|enp0s3|Route par défaut vers FW01|

---

## 2. Architecture VirtualBox

### 2.1 Configuration des réseaux VirtualBox

Avant de créer la VM, configure les réseaux dans VirtualBox :

#### Création des réseaux internes

Dans VirtualBox → Fichier → Outils → Gestionnaire de réseau :

|Nom du réseau|Type|Usage|
|---|---|---|
|`VLAN5_Transit`|Réseau interne|Lien FW01 ↔ FW02|
|`VLAN10_Serveurs`|Réseau interne|Serveurs (SRVWIN01, IPBX01, etc.)|
|`VLAN20_Test`|Réseau interne|Clients test (CLIWIN01, CLIWIN02)|
|`VLAN30_DMZ`|Réseau interne|DMZ (SRVLX01 Messagerie)|

### 2.2 Configuration VM FW02

#### Paramètres généraux

|Paramètre|Valeur|
|---|---|
|Nom|FW02-Debian|
|Type|Linux|
|Version|Debian (64-bit)|
|RAM|1024 MB minimum|
|CPU|1 vCPU|
|Disque|20 GB (dynamique)|

#### Configuration des cartes réseau

```
┌─────────────────────────────────────────────────────────────────┐
│                    FW02 - Cartes Réseau                         │
├─────────────────────────────────────────────────────────────────┤
│ Carte 1 (enp0s3)                                                │
│   ├── Mode : Réseau interne                                     │
│   ├── Nom : VLAN5_Transit                                       │
│   └── Mode promiscuité : Autoriser tout                         │
├─────────────────────────────────────────────────────────────────┤
│ Carte 2 (enp0s8)                                                │
│   ├── Mode : Réseau interne                                     │
│   ├── Nom : TRUNK_VLANS                                         │
│   ├── Mode promiscuité : Autoriser tout                         │
│   └── Type de carte : Intel PRO/1000 MT Desktop (82540EM)       │
└─────────────────────────────────────────────────────────────────┘
```

> ⚠️ **Important** : Active le "Mode promiscuité" sur toutes les cartes pour permettre le passage des trames VLAN taggées.

### 2.3 Alternative : Plusieurs cartes réseau (sans VLAN tagging)

Si tu préfères ne pas utiliser le VLAN tagging 802.1Q :

```
┌─────────────────────────────────────────────────────────────────┐
│ Carte 1 (enp0s3) → Réseau interne "VLAN5_Transit"              │
│ Carte 2 (enp0s8) → Réseau interne "VLAN10_Serveurs"            │
│ Carte 3 (enp0s9) → Réseau interne "VLAN20_Test"                │
│ Carte 4 (enp0s10) → Réseau interne "VLAN30_DMZ"                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Installation Debian

### 3.1 Téléchargement

Télécharge Debian 12 (Bookworm) CLI :

- URL : https://www.debian.org/download
- Version : **netinst** (installation minimale)

### 3.2 Installation minimale

Pendant l'installation :

1. **Langue** : Français
2. **Nom de machine** : `FW02`
3. **Domaine** : `tssr.lan`
4. **Utilisateur root** : Définir un mot de passe
5. **Utilisateur standard** : `admin` / mot de passe
6. **Partitionnement** : Utiliser tout le disque
7. **Sélection des logiciels** :
    - ❌ Environnement de bureau
    - ✅ Serveur SSH
    - ✅ Utilitaires usuels du système

### 3.3 Post-installation - Paquets nécessaires

```bash
# Connexion en root
su -

# Mise à jour du système
apt update && apt upgrade -y

# Installation des paquets nécessaires
apt install -y \
    vlan \
    iptables \
    iptables-persistent \
    net-tools \
    tcpdump \
    traceroute \
    htop \
    vim \
    sudo

# Ajouter l'utilisateur admin au groupe sudo
usermod -aG sudo admin
```

---

## 4. Configuration Réseau

### 4.1 Vérification des interfaces

```bash
# Lister les interfaces
ip link show

# Résultat attendu :
# 1: lo: <LOOPBACK,UP,LOWER_UP>
# 2: enp0s3: <BROADCAST,MULTICAST>
# 3: enp0s8: <BROADCAST,MULTICAST>
```

### 4.2 Configuration avec VLANs (Option recommandée)

Édite le fichier `/etc/network/interfaces` :

```bash
nano /etc/network/interfaces
```

```bash
# /etc/network/interfaces
# Configuration FW02 - Routeur Debian Ekoloclast

# Interface loopback
auto lo
iface lo inet loopback

#=====================================================
# INTERFACE G0/0 - VLAN 5 (Transit vers FW01)
#=====================================================
auto enp0s3
iface enp0s3 inet static
    address 10.10.5.2
    netmask 255.255.255.248
    # Route par défaut vers FW01 (pfSense)
    gateway 10.10.5.1

#=====================================================
# INTERFACE G0/1 - Interface trunk (physique)
#=====================================================
auto enp0s8
iface enp0s8 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down

#=====================================================
# VLAN 10 - Serveurs (172.16.10.0/28)
#=====================================================
auto enp0s8.10
iface enp0s8.10 inet static
    address 172.16.10.14
    netmask 255.255.255.240
    vlan-raw-device enp0s8

#=====================================================
# VLAN 20 - Zone Test (172.16.20.0/28)
#=====================================================
auto enp0s8.20
iface enp0s8.20 inet static
    address 172.16.20.14
    netmask 255.255.255.240
    vlan-raw-device enp0s8

#=====================================================
# VLAN 30 - DMZ (172.16.30.0/28)
#=====================================================
auto enp0s8.30
iface enp0s8.30 inet static
    address 172.16.30.14
    netmask 255.255.255.240
    vlan-raw-device enp0s8
```

### 4.3 Configuration SANS VLANs (avec plusieurs cartes)

Si tu utilises 4 cartes réseau séparées :

```bash
# /etc/network/interfaces

auto lo
iface lo inet loopback

# G0/0 - VLAN 5 Transit
auto enp0s3
iface enp0s3 inet static
    address 10.10.5.2
    netmask 255.255.255.248
    gateway 10.10.5.1

# Carte 2 - VLAN 10 Serveurs
auto enp0s8
iface enp0s8 inet static
    address 172.16.10.14
    netmask 255.255.255.240

# Carte 3 - VLAN 20 Test
auto enp0s9
iface enp0s9 inet static
    address 172.16.20.14
    netmask 255.255.255.240

# Carte 4 - VLAN 30 DMZ
auto enp0s10
iface enp0s10 inet static
    address 172.16.30.14
    netmask 255.255.255.240
```

### 4.4 Charger le module VLAN (si utilisation des VLANs)

```bash
# Charger le module 8021q
modprobe 8021q

# Le rendre permanent
echo "8021q" >> /etc/modules
```

### 4.5 Appliquer la configuration

```bash
# Redémarrer le service réseau
systemctl restart networking

# OU redémarrer la machine
reboot
```

### 4.6 Vérification

```bash
# Vérifier les interfaces
ip addr show

# Résultat attendu :
# enp0s3: 10.10.5.2/29
# enp0s8.10: 172.16.10.14/28
# enp0s8.20: 172.16.20.14/28
# enp0s8.30: 172.16.30.14/28

# Vérifier les VLANs
cat /proc/net/vlan/config
```

---

## 5. Activation du Routage

### 5.1 Activer le routage IPv4

```bash
# Activation temporaire (test)
echo 1 > /proc/sys/net/ipv4/ip_forward

# Activation permanente
nano /etc/sysctl.conf
```

Décommenter ou ajouter la ligne :

```bash
# /etc/sysctl.conf
net.ipv4.ip_forward = 1
```

Appliquer :

```bash
sysctl -p
```

### 5.2 Vérifier le routage

```bash
# Vérifier que le forwarding est actif
cat /proc/sys/net/ipv4/ip_forward
# Doit retourner : 1

# Afficher la table de routage
ip route show

# Résultat attendu :
# default via 10.10.5.1 dev enp0s3
# 10.10.5.0/29 dev enp0s3 proto kernel scope link src 10.10.5.2
# 172.16.10.0/28 dev enp0s8.10 proto kernel scope link src 172.16.10.14
# 172.16.20.0/28 dev enp0s8.20 proto kernel scope link src 172.16.20.14
# 172.16.30.0/28 dev enp0s8.30 proto kernel scope link src 172.16.30.14
```

---

## 6. Configuration des VLANs

### 6.1 Schéma logique des VLANs

```
                          INTERNET
                              │
                              ▼
                    ┌─────────────────┐
                    │  FW01 pfSense   │
                    │  192.168.1.x    │
                    └────────┬────────┘
                             │ 10.10.5.1
                    ═══════════════════  VLAN 5 (Transit)
                             │ 10.10.5.2
                    ┌────────┴────────┐
                    │   FW02 Debian   │
                    │     Routeur     │
                    └┬───────┬───────┬┘
                     │       │       │
        ┌────────────┘       │       └────────────┐
        │                    │                    │
   ═════════════       ═════════════       ═════════════
    VLAN 10              VLAN 20              VLAN 30
   172.16.10.0/28       172.16.20.0/28       172.16.30.0/28
   Passerelle: .14      Passerelle: .14      Passerelle: .14
        │                    │                    │
   ┌────┴────┐          ┌────┴────┐          ┌────┴────┐
   │SRVWIN01 │          │CLIWIN01 │          │SRVLX01  │
   │IPBX01   │          │CLIWIN02 │          │Messagerie│
   │SRVWIN04 │          │         │          │         │
   │SRVLX02  │          │         │          │         │
   └─────────┘          └─────────┘          └─────────┘
```

### 6.2 Récapitulatif des adresses

#### VLAN 10 - Serveurs (172.16.10.0/28)

|Machine|IP|Rôle|
|---|---|---|
|SRVWIN01|172.16.10.1|AD-DS, DHCP, DNS|
|IPBX01|172.16.10.2|VoIP (FreePBX)|
|SRVWIN04|172.16.10.3|WSUS|
|SRVLX02|172.16.10.4|GLPI|
|**FW02**|**172.16.10.14**|**Passerelle**|

#### VLAN 20 - Test (172.16.20.0/28)

|Machine|IP|Rôle|
|---|---|---|
|CLIWIN01|172.16.20.1|Client Windows 10|
|CLIWIN02|172.16.20.2 (DHCP)|Client Windows 11|
|**FW02**|**172.16.20.14**|**Passerelle**|

#### VLAN 30 - DMZ (172.16.30.0/28)

|Machine|IP|Rôle|
|---|---|---|
|SRVLX01|172.16.30.1|Messagerie (Zimbra/iRedMail)|
|**FW02**|**172.16.30.14**|**Passerelle**|

---

## 7. Configuration iptables

### 7.1 Politique de base (Deny All)

```bash
# Script de configuration iptables
nano /etc/iptables/rules.v4
```

```bash
#!/bin/bash
#=====================================================
# FW02 - Configuration iptables
# Projet Ekoloclast
#=====================================================

# Variables
VLAN5="enp0s3"
VLAN10="enp0s8.10"
VLAN20="enp0s8.20"
VLAN30="enp0s8.30"

# Flush des règles existantes
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

#=====================================================
# POLITIQUE PAR DÉFAUT (Deny All)
#=====================================================
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

#=====================================================
# RÈGLES INPUT (trafic vers FW02)
#=====================================================

# Autoriser loopback
iptables -A INPUT -i lo -j ACCEPT

# Autoriser les connexions établies
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Autoriser SSH depuis VLAN 10 (admin)
iptables -A INPUT -i $VLAN10 -p tcp --dport 22 -j ACCEPT

# Autoriser ICMP (ping) depuis tous les VLANs internes
iptables -A INPUT -i $VLAN10 -p icmp -j ACCEPT
iptables -A INPUT -i $VLAN20 -p icmp -j ACCEPT
iptables -A INPUT -i $VLAN30 -p icmp -j ACCEPT
iptables -A INPUT -i $VLAN5 -p icmp -j ACCEPT

#=====================================================
# RÈGLES FORWARD (routage inter-VLAN)
#=====================================================

# Autoriser les connexions établies
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

#-----------------------------------------------------
# VLAN 10 (Serveurs) → Peut communiquer avec tous
#-----------------------------------------------------
iptables -A FORWARD -i $VLAN10 -o $VLAN5 -j ACCEPT
iptables -A FORWARD -i $VLAN10 -o $VLAN20 -j ACCEPT
iptables -A FORWARD -i $VLAN10 -o $VLAN30 -j ACCEPT

#-----------------------------------------------------
# VLAN 20 (Test) → Accès aux serveurs et Internet
#-----------------------------------------------------
# Vers Internet (via VLAN 5)
iptables -A FORWARD -i $VLAN20 -o $VLAN5 -j ACCEPT

# Vers VLAN 10 (DNS, DHCP, AD)
iptables -A FORWARD -i $VLAN20 -o $VLAN10 -p udp --dport 53 -j ACCEPT  # DNS
iptables -A FORWARD -i $VLAN20 -o $VLAN10 -p tcp --dport 53 -j ACCEPT  # DNS
iptables -A FORWARD -i $VLAN20 -o $VLAN10 -p udp --dport 67 -j ACCEPT  # DHCP
iptables -A FORWARD -i $VLAN20 -o $VLAN10 -p tcp --dport 88 -j ACCEPT  # Kerberos
iptables -A FORWARD -i $VLAN20 -o $VLAN10 -p udp --dport 88 -j ACCEPT  # Kerberos
iptables -A FORWARD -i $VLAN20 -o $VLAN10 -p tcp --dport 389 -j ACCEPT # LDAP
iptables -A FORWARD -i $VLAN20 -o $VLAN10 -p tcp --dport 445 -j ACCEPT # SMB
iptables -A FORWARD -i $VLAN20 -o $VLAN10 -p tcp --dport 80 -j ACCEPT  # HTTP (GLPI)
iptables -A FORWARD -i $VLAN20 -o $VLAN10 -p tcp --dport 443 -j ACCEPT # HTTPS

# Vers VLAN 30 (Messagerie)
iptables -A FORWARD -i $VLAN20 -o $VLAN30 -p tcp --dport 25 -j ACCEPT   # SMTP
iptables -A FORWARD -i $VLAN20 -o $VLAN30 -p tcp --dport 143 -j ACCEPT  # IMAP
iptables -A FORWARD -i $VLAN20 -o $VLAN30 -p tcp --dport 993 -j ACCEPT  # IMAPS
iptables -A FORWARD -i $VLAN20 -o $VLAN30 -p tcp --dport 587 -j ACCEPT  # SMTP submission
iptables -A FORWARD -i $VLAN20 -o $VLAN30 -p tcp --dport 443 -j ACCEPT  # Webmail

#-----------------------------------------------------
# VLAN 30 (DMZ) → Accès limité
#-----------------------------------------------------
# Vers Internet (via VLAN 5)
iptables -A FORWARD -i $VLAN30 -o $VLAN5 -j ACCEPT

# Vers VLAN 10 (DNS uniquement)
iptables -A FORWARD -i $VLAN30 -o $VLAN10 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -i $VLAN30 -o $VLAN10 -p tcp --dport 53 -j ACCEPT

#-----------------------------------------------------
# VLAN 5 (Transit) → Réponses vers VLANs internes
#-----------------------------------------------------
iptables -A FORWARD -i $VLAN5 -o $VLAN10 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $VLAN5 -o $VLAN20 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $VLAN5 -o $VLAN30 -m state --state ESTABLISHED,RELATED -j ACCEPT

#=====================================================
# LOGGING (optionnel - pour debug)
#=====================================================
iptables -A INPUT -j LOG --log-prefix "FW02-INPUT-DROP: "
iptables -A FORWARD -j LOG --log-prefix "FW02-FORWARD-DROP: "

#=====================================================
# Sauvegarder les règles
#=====================================================
# iptables-save > /etc/iptables/rules.v4
```

### 7.2 Script d'application des règles

```bash
# Créer le script
nano /usr/local/bin/fw02-iptables.sh
chmod +x /usr/local/bin/fw02-iptables.sh
```

```bash
#!/bin/bash
# Contenu du script ci-dessus

# À la fin, sauvegarder :
iptables-save > /etc/iptables/rules.v4
echo "Règles iptables appliquées et sauvegardées."
```

### 7.3 Charger les règles au démarrage

```bash
# Installer iptables-persistent si pas déjà fait
apt install -y iptables-persistent

# Les règles dans /etc/iptables/rules.v4 seront chargées automatiquement
```

### 7.4 Commandes utiles iptables

```bash
# Voir toutes les règles
iptables -L -v -n

# Voir les règles avec numéros de ligne
iptables -L --line-numbers

# Voir les règles NAT
iptables -t nat -L -v -n

# Réinitialiser (ATTENTION - coupe le réseau!)
iptables -F

# Voir les logs
tail -f /var/log/syslog | grep FW02
```

---

## 8. Tests et Validation

### 8.1 Tests de connectivité

Depuis FW02, tester :

```bash
# Test vers FW01 (VLAN 5)
ping 10.10.5.1

# Test vers un serveur VLAN 10
ping 172.16.10.1

# Test vers un client VLAN 20
ping 172.16.20.1

# Test vers DMZ VLAN 30
ping 172.16.30.1
```

### 8.2 Test du routage

```bash
# Vérifier la table de routage
ip route show

# Tracer une route vers Internet
traceroute 8.8.8.8
```

### 8.3 Test depuis les clients

Depuis CLIWIN01 (VLAN 20) :

```cmd
REM Ping vers FW02 (passerelle)
ping 172.16.20.14

REM Ping vers serveur DNS (VLAN 10)
ping 172.16.10.1

REM Ping vers messagerie (VLAN 30)
ping 172.16.30.1

REM Test DNS
nslookup srvwin01.tssr.lan 172.16.10.1
```

### 8.4 Capture de trafic (debug)

```bash
# Capturer le trafic sur VLAN 10
tcpdump -i enp0s8.10 -n

# Capturer ICMP uniquement
tcpdump -i enp0s8.10 icmp -n

# Capturer vers un fichier
tcpdump -i enp0s8.10 -w /tmp/capture.pcap
```

---

## 9. Simulation des Switches

### 9.1 Concept dans VirtualBox

Les switches **SW-A** et **SW-B** sont simulés par les **réseaux internes VirtualBox**.

```
┌─────────────────────────────────────────────────────────────┐
│                    VirtualBox                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Réseau interne "VLAN10_Serveurs" = Switch SW-A virtuel    │
│     │                                                       │
│     ├── FW02 (enp0s8 ou sous-interface .10)                │
│     ├── SRVWIN01 (carte réseau)                            │
│     ├── IPBX01 (carte réseau)                              │
│     ├── SRVWIN04 (carte réseau)                            │
│     └── SRVLX02 (carte réseau)                             │
│                                                             │
│  Réseau interne "VLAN20_Test" = Switch SW-A virtuel        │
│     │                                                       │
│     ├── FW02 (sous-interface .20)                          │
│     ├── CLIWIN01 (carte réseau)                            │
│     └── CLIWIN02 (carte réseau)                            │
│                                                             │
│  Réseau interne "VLAN30_DMZ" = Switch SW-C virtuel         │
│     │                                                       │
│     ├── FW02 (sous-interface .30)                          │
│     └── SRVLX01 (carte réseau)                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 9.2 Option avancée : Bridge Linux sur Debian

Si tu veux que FW02 fasse aussi office de switch (Layer 2) :

```bash
# Installer bridge-utils
apt install bridge-utils

# Exemple : créer un bridge pour VLAN 10
# /etc/network/interfaces

auto br10
iface br10 inet static
    address 172.16.10.14
    netmask 255.255.255.240
    bridge_ports enp0s8
    bridge_stp off
    bridge_fd 0
```

> ⚠️ **Note** : Cette option est plus complexe et généralement inutile si tu utilises les réseaux internes VirtualBox.

---

## 10. Récapitulatif des commandes essentielles

### Configuration initiale

```bash
# Mettre à jour
apt update && apt upgrade -y

# Installer les paquets
apt install -y vlan iptables iptables-persistent net-tools tcpdump

# Charger le module VLAN
modprobe 8021q
echo "8021q" >> /etc/modules

# Activer le routage
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p
```

### Vérifications

```bash
# Interfaces
ip addr show

# Table de routage  
ip route show

# VLANs configurés
cat /proc/net/vlan/config

# Règles firewall
iptables -L -v -n

# État du routage
cat /proc/sys/net/ipv4/ip_forward
```

### Dépannage

```bash
# Voir les logs
journalctl -xe
tail -f /var/log/syslog

# Capture réseau
tcpdump -i enp0s8.10 -n

# Statistiques réseau
netstat -i
ss -tuln
```

---

## 11. Checklist de déploiement

- [ ] VM Debian créée avec 2+ cartes réseau
- [ ] Debian installé en mode CLI
- [ ] Paquets installés (vlan, iptables, etc.)
- [ ] Module 8021q chargé
- [ ] Fichier `/etc/network/interfaces` configuré
- [ ] Routage IPv4 activé (`ip_forward = 1`)
- [ ] Interfaces UP et avec bonnes IPs
- [ ] Table de routage correcte
- [ ] Règles iptables appliquées
- [ ] Ping entre VLANs fonctionnel
- [ ] Accès Internet depuis VLANs internes

---

## 12. Fichiers de configuration complets

### /etc/network/interfaces (version finale)

```bash
# Loopback
auto lo
iface lo inet loopback

# VLAN 5 - Transit vers FW01
auto enp0s3
iface enp0s3 inet static
    address 10.10.5.2
    netmask 255.255.255.248
    gateway 10.10.5.1

# Interface trunk
auto enp0s8
iface enp0s8 inet manual
    up ip link set dev $IFACE up

# VLAN 10 - Serveurs
auto enp0s8.10
iface enp0s8.10 inet static
    address 172.16.10.14
    netmask 255.255.255.240
    vlan-raw-device enp0s8

# VLAN 20 - Test
auto enp0s8.20
iface enp0s8.20 inet static
    address 172.16.20.14
    netmask 255.255.255.240
    vlan-raw-device enp0s8

# VLAN 30 - DMZ
auto enp0s8.30
iface enp0s8.30 inet static
    address 172.16.30.14
    netmask 255.255.255.240
    vlan-raw-device enp0s8
```

### /etc/sysctl.conf (extrait)

```bash
# Activer le routage IPv4
net.ipv4.ip_forward = 1

# Désactiver les redirections ICMP
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Ignorer les ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
```

---

**Document créé pour le projet Ekoloclast** **Infrastructure réseau - FW02 Debian**