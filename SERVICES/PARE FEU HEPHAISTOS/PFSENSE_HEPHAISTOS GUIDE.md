# 

---

## Sommaire

1. [État initial](#1-état-initial)
2. [Renommage interface OPT1 en DMZ](#2-renommage-interface-opt1-en-dmz)
3. [Audit des règles firewall](#3-audit-des-règles-firewall)
4. [Correction gateway LAN incorrecte](#4-correction-gateway-lan-incorrecte)
5. [Incident : perte d'accès interface web](#5-incident--perte-daccès-interface-web)
6. [Correction cases réseaux privés sur DMZ](#6-correction-cases-réseaux-privés-sur-dmz)
7. [Passage pfSense en français](#7-passage-pfsense-en-français)
8. [Analyse table de routage pfSense](#8-analyse-table-de-routage-pfsense)
9. [Création gateway ATHENA](#9-création-gateway-athena)
10. [Ajout route statique vers ACROPOLE](#10-ajout-route-statique-vers-acropole)
11. [Correction NAT Outbound](#11-correction-nat-outbound)
12. [Création alias réseau](#12-création-alias-réseau)
13. [Création alias ports](#13-création-alias-ports)
14. [Création règles firewall LAN spécifiques](#14-création-règles-firewall-lan-spécifiques)
15. [Administration pfSense depuis ACROPOLE](#15-administration-pfsense-depuis-acropole)
16. [Correction DHCP option 003 sur ACROPOLE](#16-correction-dhcp-option-003-sur-acropole)
17. [Correction gateway persistante sur ATHENA](#17-correction-gateway-persistante-sur-athena)
18. [État final et points en suspens](#18-état-final-et-points-en-suspens)

---

## 1. État initial

**Machine HEPHAISTOS (pfSense)**

| Interface | IP | Réseau |
|-----------|-----|--------|
| WAN (em0) | 192.168.1.250 | Vers box Internet (192.168.1.1) |
| LAN (em1) | 10.10.0.2 | Réseau ATHENES (vers ATHENA) |
| OPT1 (em2) | 172.16.30.1 | Réseau BYZANCE (DMZ) |

**Accès interface web :**
- Depuis SPARTAKA (Ubuntu, 172.16.30.2) via `https://172.16.30.1`
- Login : `admin` / `pfsense`
![](PFSENSE_config4%20.png)

![](PFSENSE_config5%20.png)



## 2. Renommage interface OPT1 en DMZ

**Interfaces > OPT1**

- Description changée : `OPT1` → `DMZ`
- IPv4 Configuration Type : `Static IPv4`
- IPv4 Address : `172.16.30.1/28`
- Enable interface : coché
- Save → Apply Changes
![](PFSENSE_config5%20.png)
---
## 2b. Gestionsur interface graphique 
## 3. Audit des règles firewall

**État initial des règles :**

| Interface | Règles trouvées | Statut |
|-----------|----------------|--------|
| WAN | 2 règles BLOCK (RFC1918 + bogons) | ✓ Sécurisé |
| LAN | 4 règles ALLOW (anti-lockout + tout trafic) | ⚠️ Trop permissif |
| DMZ | 1 règle ALLOW générique IPv4 TCP | ⚠️ Trop permissif |

---

## 4. Correction gateway LAN incorrecte

**Problème identifié :**
`LANGW` sur interface LAN pointait vers `192.168.1.1` (la box Internet).

Les interfaces LAN et DMZ ne doivent **pas** avoir de gateway — pfSense est lui-même la gateway pour ces réseaux.

**System > Routing > Gateways**

Action : Suppression de `LANGW` (gateway IPv4 incorrecte sur interface LAN).

**Règle :** Seule l'interface WAN doit avoir une gateway (192.168.1.1).
![](RESSOURCES/PFSENSE_configgateway%201%20.png)
---

## 5. Incident : perte d'accès interface web

**Cause :** Cases "Bloquer les réseaux privés" et "Bloquer les réseaux invalides" cochées sur l'interface DMZ, bloquant SPARTAKA (172.16.30.2 = réseau privé RFC1918).

**Solution d'urgence :** Désactivation temporaire du firewall via console HEPHAISTOS.

```bash
# Option 8 dans le menu pfSense → Shell
pfctl -d    # Désactive le firewall
pfctl -e    # Réactive le firewall
```

> **Important :** Ces commandes sont temporaires et non persistantes.

---

## 6. Correction cases réseaux privés sur DMZ

**Interfaces > DMZ**, section "Reserved Networks" :

- **Décocher** : "Bloquer les réseaux privés et les adresses de loopback"
- **Décocher** : "Bloquer les réseaux invalides"
- Save → Apply Changes

> **Règle :** Ces options sont **uniquement pour l'interface WAN**. Sur LAN et DMZ, elles bloquent les réseaux privés internes.

---

## 7. Passage pfSense en français

**System > General Setup**, section **Localization** :

- Language : `Français`
- Save

---

## 8. Analyse table de routage pfSense

**Diagnostics > Routes**

```
DESTINATION         PASSERELLE    DRAPEAUX  INTERFACE
default             192.168.1.1   UGS       em0 (WAN)
10.10.0.0/28        link#2        U         em1 (LAN)
10.10.0.2           link#5        UHS       lo0 (loopback)
172.16.30.0/28      link#3        U         em2 (DMZ)
172.16.30.1         link#5        UHS       lo0 (loopback)
192.168.1.0/24      link#1        U         em0 (WAN)
192.168.1.250       link#5        UHS       lo0 (loopback)
```

**Signification link# :**
- `link#1` = em0 (WAN)
- `link#2` = em1 (LAN)
- `link#3` = em2 (DMZ)
- `link#5` = lo0 (loopback = adresses IP locales de pfSense lui-même)

**Problème identifié :** Absence de route vers ACROPOLE (10.10.20.0/26) qui est derrière ATHENA.

---

## 9. Création gateway ATHENA

**System > Routing > Gateways > + Ajouter**

| Paramètre | Valeur |
|-----------|--------|
| Interface | LAN |
| Famille d'adresses | IPv4 |
| Nom | GW_ATHENA |
| Passerelle | 10.10.0.1 |
| IP surveillée | 10.10.0.1 |
| Description | Gateway vers ATHENA pour routage ACROPOLE |

---

## 10. Ajout route statique vers ACROPOLE

**System > Routing > Routes statiques > + Ajouter**

| Paramètre | Valeur |
|-----------|--------|
| Réseau de destination | 10.10.20.0/26 |
| Passerelle | GW_ATHENA - 10.10.0.1 |
| Description | Route vers réseau ACROPOLE |

**Table de routage après ajout :**
```
10.10.20.0/26   10.10.0.1   UGS   em1 (LAN)
```

---

## 11. Correction NAT Outbound

**Problème :** En mode NAT Automatique, pfSense ne voyait pas le réseau ACROPOLE (10.10.20.0/26) car il est derrière ATHENA.

**Solution :** Passage en mode **Hybride** (Hybrid Outbound NAT).

**Pare-feu > NAT > Sortant**

Mode sélectionné : `Hybride`

**Règles manuelles ajoutées :**

| Interface | Source | Port source | Destination | Port dest | Adresse NAT | Description |
|-----------|--------|------------|-------------|-----------|-------------|-------------|
| WAN | 10.10.20.0/26 | * | * | 500 (ISAKMP) | WAN address | NAT ACROPOLE ISAKMP |
| WAN | 10.10.20.0/26 | * | * | * | WAN address | NAT ACROPOLE général |

---

## 12. Création alias réseau

**Pare-feu > Alias > IP > + Ajouter**

| Paramètre | Valeur |
|-----------|--------|
| Nom | LAN_ATHENES_ACROPOLE |
| Type | Networks |
| Réseau 1 | 10.10.0.0/28 (ATHENES) |
| Réseau 2 | 10.10.20.0/26 (ACROPOLE) |
| Description | Réseaux internes LANS |

**Utilité :** Regroupe les deux réseaux internes pour simplifier les règles firewall.

---

## 13. Création alias ports

**Pare-feu > Alias > Ports > + Ajouter**

| Paramètre | Valeur |
|-----------|--------|
| Nom | SERVICES_INTERNET |
| Type | Port(s) |
| Port 53 | DNS |
| Port 80 | HTTP |
| Port 443 | HTTPS |
| Port 123 | NTP |
| Description | Services autorisés vers Internet |

---

## 14. Création règles firewall LAN spécifiques

**Pare-feu > Règles > LAN**

**Règles créées (dans l'ordre) :**

| # | Action | Protocole | Source | Destination | Port dest | Description |
|---|--------|-----------|--------|-------------|-----------|-------------|
| 1 | Pass (système) | * | * | LAN Address | 443, 80 | Règle anti-blocage |
| 2 | Pass | IPv4 ICMP | LAN_ATHENES_ACROPOLE | * | * | Autoriser ICMP (ping) |
| 3 | Pass | IPv4 TCP/UDP | LAN_ATHENES_ACROPOLE | * | SERVICES_INTERNET | Autoriser LAN vers services Internet |
| 4 | (désactivé) | IPv4 * | LAN subnets | * | * | Default allow LAN to any rule |
| 5 | (désactivé) | IPv6 * | LAN subnets | * | * | Default allow LAN IPv6 to any rule |

> **Principe :** Les règles 4 et 5 (trop permissives) ont été désactivées et remplacées par les règles spécifiques 2 et 3 utilisant les alias.

---

## 15. Administration pfSense depuis ACROPOLE

**Test :** Accès à `https://10.10.0.2` depuis ARESG (10.10.20.14).

✓ **Fonctionnel** — Administration pfSense possible depuis ACROPOLE sans passer par la DMZ.

---

## 16. Correction DHCP option 003 sur ACROPOLE

**Problème identifié :** ARESG avait 2 routes par défaut dans sa table de routage :

```
0.0.0.0  0.0.0.0  10.10.20.1  Metric 10  ✓ Correct (via ATHENA)
0.0.0.0  0.0.0.0  10.10.0.2   Metric 11  ✗ Incorrect (pfSense hors sous-réseau)
```

**Cause :** Option DHCP 003 (Router) du scope ACROPOLE contenait 2 valeurs : `10.10.20.1` et `10.10.0.2`.

**Correction via RSAT DHCP sur ARESG :**

DHCP > ARESKI.ecotech.tssr > IPv4 > Scope [10.10.20.0] ACROPOLE > Scope Options > 003 Router

Suppression de `10.10.0.2`, conservation uniquement de `10.10.20.1`.

**Renouvellement bail DHCP sur ARESG :**

```powershell
ipconfig /release
ipconfig /renew
```

**Table de routage corrigée :**
```
Default Gateway: 10.10.20.1 (uniquement)
```

---

## 17. Correction gateway persistante sur ATHENA

**Problème :** La route par défaut d'ATHENA (`ip route add default via 10.10.0.2`) n'était pas persistante (perdue après redémarrage).

**Solution :** Ajout de la directive `gateway` dans `/etc/network/interfaces`.

```bash
nano /etc/network/interfaces
```

**Modification :**

```
auto enp0s3
# INT1 interne HEPHAISTOS
iface enp0s3 inet static
    address 10.10.0.1/28
    gateway 10.10.0.2      # ← Ajouté pour persistance
```

**Application :**

```bash
systemctl restart networking
```

**Vérification :**

```bash
ip route show | grep default
# Résultat attendu : default via 10.10.0.2 dev enp0s3
```

---

## 18. État final et points en suspens

### ✓ Fonctionnel

| Test | Résultat |
|------|----------|
| ARESKI → pfSense (10.10.0.2) | ✓ OK |
| ARESG → pfSense (10.10.0.2) | ✓ OK |
| ATHENA → pfSense (10.10.0.2) | ✓ OK |
| Administration web pfSense depuis ACROPOLE | ✓ OK |
| Routage ARESG → ATHENA → pfSense (tracert hop 1 et 2) | ✓ OK |

### ⏳ En suspens

- **Ping 8.8.8.8 depuis ARESKI/ARESG/ATHENA** : Timeout — paquets arrivent à pfSense mais ne sortent pas vers Internet
- **Cause probable** : Règles firewall LAN pas encore totalement effectives ou problème NAT résiduel
- **À vérifier** : Logs firewall pfSense sur trafic source ACROPOLE / vérifier état des règles LAN

### Topologie réseau actuelle

```
Internet (8.8.8.8)
    |
Box (192.168.1.1)
    |
HEPHAISTOS pfSense (WAN: 192.168.1.250)
    ├── LAN (10.10.0.2) ←→ ATHENA (10.10.0.1)
    │                           ├── ACROPOLE (10.10.20.0/26)
    │                           │       ├── ARESKI  10.10.20.4 (ADDS/DNS/DHCP)
    │                           │       ├── ARESG   10.10.20.14 (RSAT admin)
    │                           │       └── HERA    10.10.20.x (GLPI/Messagerie)
    │                           └── HERCULE VLANs (10.15.x.0/24) × 9
    └── DMZ (172.16.30.1) ←→ BYZANCE (172.16.30.0/28)
                                    └── SPARTAKA 172.16.30.2 (Ubuntu)
```

---

*Fil de conversation : PFSENSE — EcoTech Solutions TSSR*

