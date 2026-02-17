
date_capture: 2026-02-14T11:31:59+01:00
---

# You said  config openvpn sur pfsense.

## 📝 Énoncé & Ressources
config openvpn sur pfsense.

---

Markdown

```
## Implémentation OpenVPN sur pfSense

Le déploiement d'un serveur OpenVPN sur pfSense (Remote Access) repose sur l'architecture PKI (Public Key Infrastructure). Voici la procédure technique normalisée.

---

### 1. Gestion des Certificats (CA & Server)
L'authentification nécessite une autorité de certification (CA) locale et des certificats signés.

* **System > Cert. Manager > CAs :** Créer une "Internal CA".
* **System > Cert. Manager > Certificates :** Créer un "Internal Certificate". 
    * **Common Name :** FQDN ou IP du serveur.
    * **Certificate Type :** Server Certificate.

---

### 2. Configuration du Serveur OpenVPN
Utilisez l'assistant (**VPN > OpenVPN > Wizards**) ou la configuration manuelle (**Servers > Add**).

| Paramètre | Valeur recommandée |
| :--- | :--- |
| **Server Mode** | Remote Access (SSL/TLS + User Auth) |
| **Protocol** | UDP on IPv4 (plus performant que TCP) |
| **Device Mode** | tun (Layer 3) |
| **Interface** | WAN |
| **TLS Configuration** | Cocher "TLS Authentication" et "Generate shared TLS Key" |
| **DH Parameters** | 2048 bit |
| **Encryption Algorithm** | AES-256-GCM |

---

### 3. Paramétrage Réseau (Tunnel Settings)
Définition du routage et de l'adressage virtuel.

* **IPv4 Tunnel Network :** Un sous-réseau inédit (ex: \`10.0.8.0/24\`).
* **IPv4 Local Network :** Le sous-réseau LAN à joindre (ex: \`192.168.1.0/24\`).
* **Concurrent Connections :** Définir selon les ressources hardware.
* **Inter-client communication :** À activer si les clients VPN doivent se voir.

---

### 4. Règles de Pare-feu (Firewall Rules)
Deux règles sont impératives pour le flux de données.

1.  **Interface WAN :** Autoriser le port OpenVPN (par défaut **UDP 1194**) vers l'adresse "WAN Address".
2.  **Interface OpenVPN :** Créer une règle "Pass" pour autoriser le trafic entrant du tunnel vers les ressources internes.

---

### 5. Exportation du Client
Installez le package **openvpn-client-export** via le gestionnaire de paquets de pfSense.

* **VPN > OpenVPN > Client Export :** * Sélectionner le serveur VPN.
    * Choisir le type d'export (Inline Configurations pour Windows/Android/iOS).
    * Télécharger le profil \`.ovpn\`.

---

### Vérification de l'état
Consultez **Status > OpenVPN** pour monitorer les sessions actives, les IPs virtuelles attribuées et le débit en temps réel.

Souhaitez-vous que je détaille la configuration spécifique pour l'authentification via un serveur RADIUS ou LDAP ?
```

---

  

Create a New Certificate Authority (CA) Certificate

  

  

  

Nom descriptif

qu'est ce que je met ici

---

Markdown

```
## Configuration de l'Autorité de Certification (CA)

Dans le champ **Nom descriptif** (Descriptive Name), vous devez saisir un identifiant interne qui vous permettra de reconnaître cette autorité de certification parmi d'autres. 

### Recommandations pour le "Nom descriptif"
Il est conseillé d'utiliser une nomenclature explicite, car ce nom apparaîtra dans les menus déroulants lors de la création de vos certificats serveurs et utilisateurs.

* **Format suggéré :** \`[Nom_Organisation]_VPN_CA\` ou \`pfSense_Internal_CA\`.
* **Exemple concret :** \`MaSociete_Root_CA\`.

---

### Paramètres critiques associés
Pour que votre CA soit valide, assurez-vous de configurer les champs suivants dans la même fenêtre :

| Champ | Valeur attendue |
| :--- | :--- |
| **Method** | Create an internal Certificate Authority |
| **Key length** | 2048 bits (Standard) ou 4096 bits (Haute sécurité) |
| **Digest Algorithm** | SHA256 |
| **Lifetime** | 3650 jours (10 ans pour éviter un renouvellement fréquent) |
| **Common Name** | Un nom unique, ex: \`internal-ca.mondomaine.local\` |

---

### Pourquoi est-ce important ?
Cette CA est la "racine de confiance". Si vous configurez un accès VPN pour plusieurs clients, c'est cette entité qui signera les certificats individuels des utilisateurs. Sans un nom clair, la gestion de l'infrastructure PKI (Public Key Infrastructure) devient complexe lors des phases de maintenance ou de révocation.

Souhaitez-vous que nous passions à l'étape de la création du **Certificat Serveur** une fois que vous aurez validé cette CA ?
```

---

next?

---

Markdown

```
## Étape 7 : Sélection du Certificat Serveur

À cette étape de l'assistant (Wizard), vous devez définir l'identité numérique de votre serveur VPN. L'option sélectionnée par défaut sur votre capture (**GUI default**) n'est pas recommandée car elle est généralement réservée à l'interface web de pfSense.

### Procédure à suivre :

1.  **Cliquez sur le bouton "Add new Certificate"**.
2.  Dans la nouvelle fenêtre qui s'ouvre, remplissez les champs comme suit :
    * **Method :** Create an internal Certificate.
    * **Descriptive name :** Saisissez \`OpenVPN_Server_Cert\`.
    * **Certificate authority :** Sélectionnez la CA que vous avez créée à l'étape précédente.
    * **Key length :** 2048 bits.
    * **Certificate Type :** **Server Certificate** (Crucial pour le fonctionnement du VPN).
    * **Common Name :** L'adresse IP publique de votre pfSense ou un nom de domaine (FQDN).
3.  **Enregistrez** le certificat.
4.  Une fois revenu sur l'écran de votre capture, sélectionnez ce nouveau certificat (\`OpenVPN_Server_Cert\`) dans la liste déroulante **Certificat**.
5.  Cliquez sur **Next**.

---

### Pourquoi ne pas utiliser "GUI default" ?
Le certificat **GUI default** est auto-signé spécifiquement pour l'accès HTTPS à votre console d'administration. L'utiliser pour le VPN pose deux problèmes :
* **Sécurité :** Une compromission du service VPN pourrait affecter l'accès à l'interface de gestion.
* **Validation :** Les clients OpenVPN rejettent souvent les certificats qui n'ont pas l'attribut spécifique "Server Certificate".

Souhaitez-vous que je vous guide sur la partie **Tunnel Settings** (réseaux IP) qui arrive juste après ?
```

---

oui etape de

---

Markdown

```
## Étape 8 : Paramètres du Serveur (Tunnel Settings)

Après avoir cliqué sur **Next**, vous arrivez sur la configuration réseau. C'est ici que vous définissez comment les données circulent entre le client distant et votre réseau local.

### 1. Cryptographie (Cryptographic Settings)
Conservez les valeurs par défaut proposées par l'assistant, qui sont généralement sécurisées :
* **TLS Authentication :** Cochée.
* **Encryption Algorithm :** AES-256-GCM (recommandé pour la performance et la sécurité).
* **Auth Digest Algorithm :** SHA256.

---

### 2. Paramètres du Tunnel (Tunnel Settings)
C'est la partie la plus critique pour éviter les conflits réseau.

* **IPv4 Tunnel Network :** Saisissez un réseau qui n'existe nulle part ailleurs dans votre infrastructure (ex: \`10.0.8.0/24\`). C'est la plage d'adresses IP "virtuelles" que recevront vos clients VPN.
* **Redirect Gateway :** * **Coché :** Tout le trafic du client (internet compris) passe par le VPN.
    * **Décoché :** Seul le trafic vers votre bureau/maison passe par le VPN (Split-tunneling).
* **IPv4 Local Network(s) :** Indiquez votre réseau LAN actuel (ex: \`192.168.1.0/24\`). Cela permet au client de savoir qu'il doit passer par le tunnel pour atteindre vos machines locales.
* **Concurrent Connections :** Nombre maximum d'utilisateurs connectés simultanément.

---

### 3. Paramètres Client (Client Settings)
* **Dynamic IP :** Cochée (permet aux clients de se reconnecter si leur IP publique change).
* **DNS Default Domain :** Votre nom de domaine local (optionnel).
* **DNS Server 1 :** L'adresse IP de votre pfSense (souvent l'IP du LAN) pour que les clients puissent résoudre les noms de vos machines locales.

---

### Prochaine étape
Une fois ces champs remplis et que vous aurez cliqué sur **Next**, l'assistant vous proposera de créer automatiquement les règles de pare-feu (Firewall Rules).

Souhaitez-vous que je vous explique comment configurer ces règles pour isoler certains clients VPN du reste du réseau ?
```

---

?

---

Markdown

```
## Étape 9 : Configuration Avancée du Tunnel

D'après vos captures d'écran, vous êtes dans la section **Tunnel Settings** et **Advanced Configuration**. Voici comment finaliser ces réglages spécifiques pour garantir stabilité et sécurité.

### 1. Gestion des Connexions (Basé sur votre image)
* **Concurrent Connections :** Vous avez saisi \`1\`. Si vous prévoyez d'utiliser le VPN sur votre téléphone et votre ordinateur en même temps, augmentez cette valeur (ex: \`5\`).
* **Compression :** Laissez sur **"Disable Compression [Omit Preference]"**. 
    > **Note technique :** La compression (VORACLE) est aujourd'hui désactivée par défaut car elle présente des failles de sécurité potentielles.
* **Inter-Client Communication :** * **Décoché (Recommandé) :** Les clients VPN peuvent voir le LAN, mais ne peuvent pas se voir entre eux.
    * **Coché :** Utile seulement si vous voulez que vos appareils distants communiquent ensemble (ex: un smartphone accédant à un fichier sur un PC lui aussi en VPN).

---

### 2. Étape 10 : Firewall Rule Assignment (Pare-feu)
Une fois que vous aurez cliqué sur **Next**, l'assistant va vous proposer deux cases à cocher cruciales. **Cochez les deux** :

1.  **Firewall Rule :** "Add a rule to permit traffic from clients to the OpenVPN server service". (Ouvre le port UDP 1194 sur le WAN).
2.  **OpenVPN Rule :** "Add a rule to allow all traffic from connected clients through the tunnel". (Autorise les données à circuler une fois dans le tunnel).

---

### 3. Étape 11 : Fin de l'Assistant
Cliquez sur **Finish**. Le serveur est maintenant opérationnel sur pfSense, mais il reste l'exportation du fichier pour votre appareil (Windows, Mac, iOS, Android).

### Prochaine étape : Installation du Client Export
Pour récupérer le fichier de connexion, nous devons installer un utilitaire.

1.  Allez dans **System > Package Manager > Available Packages**.
2.  Cherchez et installez **\`openvpn-client-export\`**.

Souhaitez-vous que je vous montre comment générer le fichier \`.ovpn\` une fois le paquet installé ?
```

---

  

Options NetBIOS

Enable NetBIOS over TCP/IP.

---

Markdown

```
## Étape 10 : Options NetBIOS et Résolution de Noms

Dans cette section de l'assistant, vous configurez la manière dont les noms de vos machines (ex: \`\\MON-PC\`) seront résolus sur le réseau VPN.

### Faut-il activer "Enable NetBIOS over TCP/IP" ?

* **Recommandation moderne : Laissez cette case décochée.**
* **Raison :** NetBIOS est un protocole ancien (héritage Windows) qui génère beaucoup de trafic de "broadcast" inutile sur le tunnel VPN. La plupart des services actuels utilisent le DNS pour la résolution de noms.

---

### Configuration DNS alternative (Plus propre)
Au lieu d'activer NetBIOS, assurez-vous de remplir les sections suivantes juste au-dessus ou en dessous dans l'interface :

1.  **DNS Default Domain :** Saisissez votre domaine local (ex: \`home.arpa\` ou \`mondomaine.local\`).
2.  **DNS Server 1 :** Saisissez l'adresse IP de votre pfSense (généralement \`192.168.1.1\` ou l'IP de votre interface LAN).

---

### Résultat final de l'assistant
Après avoir cliqué sur **Next**, vous arriverez sur l'écran **Firewall Rule Assignment**.

1.  Cochez **Firewall Rule** (pour laisser entrer le trafic VPN sur le port 1194).
2.  Cochez **OpenVPN Rule** (pour autoriser les clients à naviguer dans votre réseau).
3.  Cliquez sur **Next** puis **Finish**.

### Prochaine étape : Exportation du client
Le serveur est maintenant créé. Pour vous connecter, vous avez besoin du plugin d'exportation.

**Souhaitez-vous que je vous guide pour installer le paquet "Client Export" et générer votre premier fichier de connexion ?**
```

---

mon serveur dns est le server adds est dans un lan apres le router, je met son adresse

---

Oui, tout à fait. Comme votre serveur ADDS (Active Directory Domain Services) gère le DNS de votre domaine, c'est impératif que les clients VPN l'utilisent pour pouvoir résoudre les noms de machines (ex: `serveur-fichiers.mon-domaine.local`) et s'authentifier correctement.

Voici comment configurer cette partie dans l'assistant:

### 1\. DNS Default Domain

Saisissez ici le **nom de domaine complet de votre Active Directory** (ex: `entreprise.local` ou `ad.mondomaine.com`).

- *Pourquoi?* Cela permet aux clients d'ajouter automatiquement ce suffixe DNS lorsqu'ils cherchent une machine par son nom court.

### 2\. DNS Server 1

Saisissez l' **adresse IP privée LAN de votre serveur ADDS** (ex: `192.168.1.10`).

- *Note importante:* Assurez-vous que le réseau du tunnel VPN (le "IPv4 Tunnel Network" défini à l'étape précédente, ex: `10.0.8.0/24`) est bien autorisé à interroger votre serveur DNS/AD.

### 3\. DNS Server 2 (Optionnel)

Vous pouvez mettre l'adresse IP de votre pfSense (si le résolveur DNS y est activé) ou un DNS public (comme `1.1.1.1`), mais attention: si le serveur ADDS tombe, les noms DNS internes ne seront plus résolus par les DNS publics.

---

### Vérification cruciale après l'assistant:

Comme votre serveur DNS est "après le router" (sur le LAN), vous devez vérifier deux choses une fois l'assistant terminé:

1. **Le routage:** Votre serveur ADDS doit connaître la route de retour vers le réseau du VPN (`10.0.8.0/24`). Si pfSense est la passerelle par défaut de votre serveur ADDS, c'est automatique.
2. **Le Pare-feu (Firewall):** Allez dans **Firewall > Rules > OpenVPN** et assurez-vous qu'il existe une règle autorisant le trafic du VPN vers l'adresse IP de votre serveur ADDS sur les ports DNS (UDP/TCP 53).

**Une fois que vous avez rempli ces champs, cliquez sur "Next". Quelle est la page suivante affichée par pfSense?**

---

etape 10

---

Markdown

```
## Étape 10 : Configuration des règles de Pare-feu (Firewall)

D'après votre capture d'écran, vous êtes à l'étape cruciale où pfSense propose de générer automatiquement les ouvertures de flux nécessaires. Pour un fonctionnement standard, vous devez **cocher les deux cases** avant de cliquer sur **Next**.

### 1. Firewall Rule (Trafic entrant sur le WAN)
* **Action :** Cochez la case "Add a rule to permit connections...".
* **Effet :** Cela crée une règle sur votre interface WAN pour autoriser le trafic provenant d'Internet sur le port UDP 1194. Sans cela, votre pfSense bloquera toutes les tentatives de connexion des clients externes.

### 2. OpenVPN Rule (Trafic à l'intérieur du tunnel)
* **Action :** Cochez la case "Add a rule to allow all traffic...".
* **Effet :** Une fois le tunnel établi, cette règle autorise les clients VPN à accéder à votre réseau local (LAN). Puisque votre serveur DNS/ADDS est dans le LAN, cette règle est indispensable pour qu'ils puissent l'interroger.

---

### Rappel pour votre Serveur DNS (ADDS)
Comme votre serveur DNS est situé sur un réseau après le routeur :
1.  Le flux sera autorisé par la règle **OpenVPN rule** que vous venez de cocher.
2.  **Attention :** Si vous avez un pare-feu logiciel (Windows Firewall) sur votre serveur ADDS, assurez-vous qu'il accepte les requêtes DNS (port 53) venant du réseau VPN (ex: \`10.0.8.0/24\`).

---

### Étape 11 : Finalisation
Après avoir cliqué sur **Next**, vous arriverez à l'étape 11. Cliquez sur **Finish**. 

Votre serveur OpenVPN est maintenant actif, mais il ne reste qu'une dernière phase pour récupérer le fichier de configuration à installer sur vos appareils.

**Souhaitez-vous que je vous guide pour l'installation du paquet "Client Export" afin de générer votre fichier .ovpn ?**
```

---

ok

---

Markdown

```
## Prochaine étape : Exportation de la configuration client

Maintenant que l'assistant est terminé et que vos règles de pare-feu sont en place, vous devez récupérer le fichier de connexion pour vos appareils distants. 

### 1. Installation du gestionnaire d'exportation
Par défaut, pfSense ne contient pas l'outil de génération de fichiers \`.ovpn\`. Vous devez l'ajouter :
* Allez dans le menu **Système > Package Manager**.
* Cliquez sur l'onglet **Available Packages**.
* Recherchez \`openvpn-client-export\`.
* Cliquez sur **Install** puis **Confirm**.

---

### 2. Génération du profil utilisateur
Une fois le paquet installé :
* Allez dans **VPN > OpenVPN > Client Export**.
* Vérifiez que votre serveur est bien sélectionné dans la liste déroulante en haut.
* Descendez jusqu'à la section **Client Install Packages**.
* Vous y verrez la liste des utilisateurs créés sur votre pfSense. 
* Pour un PC Windows ou un smartphone, utilisez le bouton **Inline Config** à côté de l'utilisateur choisi pour télécharger le fichier \`.ovpn\`.

---

### 3. Création d'un compte utilisateur (si nécessaire)
Si vous n'avez pas encore d'utilisateur dédié au VPN :
* Allez dans **System > User Manager**.
* Ajoutez un utilisateur, donnez-lui un mot de passe.
* **Important :** Cochez la case pour lui créer un certificat utilisateur et choisissez votre autorité de certification (**CA**) créée au début.

Souhaitez-vous que je vous explique comment importer ce fichier \`.ovpn\` dans le logiciel client sur votre ordinateur ?
```

---

et pour les cles ssh?

---

Markdown

```
## Utilisation des clés SSH avec OpenVPN sur pfSense

Il est important de clarifier une distinction technique : **OpenVPN n'utilise pas nativement de clés SSH** (format \`.pub\` / RSA/ED25519 de type OpenSSH) pour son tunnel. OpenVPN repose sur des certificats **SSL/TLS** (format X.509).

Cependant, si votre objectif est de renforcer la sécurité ou d'automatiser des accès, voici les deux scénarios possibles :

---

### 1. Authentification par Certificat (L'équivalent OpenVPN)
L'équivalent d'une clé publique SSH dans OpenVPN est le **certificat utilisateur**. 
* Chaque utilisateur possède une clé privée (gardée secrète) et un certificat signé par votre CA.
* Lors de l'exportation via **Client Export**, pfSense inclut ces clés directement dans le fichier \`.ovpn\`.
* **Avantage :** C'est plus sécurisé qu'un simple mot de passe.

### 2. Double Authentification (Certificat + SSH Key ?)
Certains administrateurs utilisent un tunnel SSH pour encapsuler OpenVPN, ou utilisent des clés SSH pour administrer pfSense *à travers* le VPN. 
Si vous voulez configurer vos clés SSH pour l'administration de pfSense une fois connecté au VPN :

1.  Allez dans **System > User Manager**.
2.  Éditez votre utilisateur.
3.  Collez votre clé publique (commençant par \`ssh-rsa\` ou \`ssh-ed25519\`) dans le champ **Authorized SSH Keys**.
4.  Allez dans **System > Advanced > Admin Access** et cochez **Secure Shell Server** pour activer le service SSH.

---

### 3. Utilisation de clés pour le "Static Key Mode"
Si vous parliez d'une "clé partagée" (Shared Key) plutôt que de clés SSH :
* Ce mode utilise une clé unique (\`.key\`) copiée sur le serveur et le client.
* **Limitation :** Ce mode ne supporte qu'un seul client à la fois et n'est plus recommandé pour le "Remote Access" car il n'offre pas de "Perfect Forward Secrecy" (PFS) aussi robuste que le mode SSL/TLS.

### Résumé Technique
| Protocole | Type de Clé | Utilisation sur pfSense |
| :--- | :--- | :--- |
| **OpenVPN** | Certificats SSL/TLS (X.509) | Authentification des tunnels clients. |
| **SSH** | Clés RSA / Ed25519 | Administration console de pfSense via le port 22. |

Souhaitez-vous que je vous aide à générer un certificat utilisateur spécifique (l'équivalent VPN de la clé SSH) pour sécuriser davantage votre accès ?
```

---

je pourrais en rajouter apres,

---

Oui, tout à fait. L'architecture de pfSense est conçue pour être évolutive. Voici comment vous pourrez procéder par la suite pour ajouter des éléments à votre configuration OpenVPN:

### 1\. Ajouter des Utilisateurs

Si vous avez configuré le serveur en mode **"SSL/TLS + User Auth"**, vous pouvez ajouter de nouveaux utilisateurs à tout moment:

- Allez dans **System > User Manager**.
- Créez l'utilisateur et générez-lui un certificat spécifique signé par votre CA VPN.
- L'utilisateur apparaîtra automatiquement dans l'onglet **Client Export**.

### 2\. Ajouter des Clés SSH (pour l'administration)

Si vous souhaitez renforcer l'accès SSH à la console de votre pfSense une fois le VPN connecté:

- Vous pouvez éditer n'importe quel utilisateur existant dans **System > User Manager**.
- Collez simplement la nouvelle clé publique dans le champ **Authorized SSH Keys**.

### 3\. Modifier les accès réseaux

Si vous ajoutez un nouveau VLAN ou un nouveau sous-réseau dans votre LAN plus tard:

- Allez dans **VPN > OpenVPN > Servers** et éditez votre serveur.
- Modifiez le champ **IPv4 Local network(s)** pour inclure le nouveau réseau (en séparant par des virgules, ex: `192.168.1.0/24, 192.168.10.0/24`).
- Pensez à mettre à jour la règle correspondante dans **Firewall > Rules > OpenVPN**.

### 4\. Ajouter un deuxième serveur VPN

Il est possible de faire tourner plusieurs serveurs OpenVPN en parallèle sur des ports différents (ex: un pour les employés sur le port 1194 et un pour les prestataires sur le port 1195 avec des accès plus restreints).

**Avez-vous réussi à installer le paquet "Client Export" ou souhaitez-vous vérifier la règle de pare-feu spécifique pour votre serveur ADDS avant de tester la connexion?**

---

je peux deja fairte simple et copmplexifier apres?

---

Markdown

```
## Approche Graduelle : Du Simple au Complexe

Absolument, c'est même la méthode recommandée pour faciliter le **troubleshooting** (dépannage). Voici la stratégie pour une mise en service progressive.

---

### Phase 1 : Configuration "Simple" (Ce que vous venez de faire)
À ce stade, votre configuration permet de valider la connectivité de base.
* **Authentification :** Nom d'utilisateur et mot de passe locaux.
* **Accès :** Accès complet au LAN via la règle "Allow All" créée à l'étape 10.
* **DNS :** Utilisation de l'IP directe de votre serveur ADDS.

**Objectif :** Vérifier que vous arrivez à établir le tunnel et à "pinger" votre serveur ADDS depuis l'extérieur.

---

### Phase 2 : Complexification et Sécurisation (À venir)
Une fois que le tunnel fonctionne, vous pourrez ajouter ces couches de sécurité une par une :

1.  **Double Authentification (2FA) :** * Ajouter des codes **TOTP** (Google Authenticator) en plus du mot de passe.
2.  **Filtrage Granulaire :**
    * Remplacer la règle "Allow All" par des règles spécifiques.
    * *Exemple :* Autoriser uniquement le port 445 (fichiers) et 53 (DNS) vers le serveur ADDS.
3.  **Liaison Active Directory :**
    * Configurer pfSense pour qu'il utilise directement les comptes de votre serveur ADDS (**LDAP**) au lieu de créer les utilisateurs manuellement sur pfSense.
4.  **Certificats Individuels :**
    * Exiger un certificat unique par appareil pour révoquer un accès sans changer le mot de passe de l'utilisateur.

---

### Conseil de vérification immédiate
Avant de fermer l'assistant, assurez-vous que le **WAN** de votre pfSense a bien une **IP publique**. Si votre pfSense est derrière une box internet (en mode routeur), vous devrez faire une redirection de port (**Port Forwarding**) sur la box :
* **Protocole :** UDP
* **Port :** 1194
* **Destination :** L'adresse IP WAN (privée) de votre pfSense.

**Souhaitez-vous que je vous aide à vérifier si votre règle de pare-feu est bien enregistrée dans l'onglet "Firewall > Rules > WAN" ?**
```

---

la je cherche a importer le fichier client?

---

C'est la dernière ligne droite. Maintenant que le serveur est configuré, vous devez **installer le paquet d'exportation** pour générer ce fameux fichier client (`.ovpn`).

Voici comment faire étape par étape:

### 1\. Installation du paquet (Package)

Si vous ne l'avez pas encore fait, pfSense ne vous montrera pas d'option "exporter" par défaut.

- Allez dans le menu **Système > Gestionnaire de paquets** (Package Manager).
- Cliquez sur l'onglet **Paquets disponibles** (Available Packages).
- Dans la barre de recherche, tapez: `openvpn-client-export`.
- Cliquez sur le bouton **Installer** (Install) à côté du paquet, puis confirmez.

### 2\. Accès à l'interface d'exportation

Une fois l'installation terminée:

- Allez dans le menu **VPN > OpenVPN**.
- Vous verrez maintenant un nouvel onglet en haut à droite nommé **Client Export**. Cliquez dessus.

### 3\. Téléchargement du fichier

Dans cet onglet:

- Vérifiez que le champ **Remote Access Server** affiche bien le serveur que vous venez de créer.
- Descendez en bas de la page jusqu'à la section **Client Install Packages**.
- Vous y trouverez la liste des utilisateurs (User Manager).
- À côté de votre nom d'utilisateur, cherchez la colonne **Standard Configurations**.
- Cliquez sur le bouton **Inline Config** (le plus universel). Cela va télécharger un fichier `.ovpn` sur votre ordinateur.

---

### Résumé des tests à faire après l'import:

Une fois que vous avez ce fichier, importez-le dans votre client OpenVPN (sur Windows, Android ou iOS) et testez ces deux points:

1. **Ping de l'IP du serveur ADDS**: Pour vérifier que le tunnel est bien ouvert.
2. **Résolution DNS**: Essayez de taper le nom d'une machine du LAN (ex: `serveur.votre-domaine.local`) pour voir si votre serveur ADDS répond bien aux clients VPN.

**Souhaitez-vous que je vous explique comment installer et utiliser le logiciel "OpenVPN Connect" sur Windows pour utiliser ce fichier?**

---

dans ma configuration je n'ai jamais entre mon adresse public de ma box; comment ope,n vpn sait ou aller?

---

C'est une excellente question technique. Par défaut, si vous ne l'avez pas spécifiée, pfSense utilise l'adresse IP de son interface **WAN**.

Cependant, si votre pfSense est derrière une Box (en mode routeur), l'IP du WAN est une IP privée (ex: `192.168.1.x`). Le fichier client contiendra donc cette adresse privée et la connexion échouera depuis l'extérieur.

Voici comment corriger cela et indiquer votre adresse publique au client VPN:

### 1\. Identifier l'option dans pfSense

Pour que le fichier d'exportation contienne la bonne adresse, allez dans:**VPN > OpenVPN > Client Export**

### 2\. Configurer le "Host Name Resolution"

Cherchez le menu déroulant nommé **Host Name Resolution**. Vous avez plusieurs choix:

- **Interface IP Address (par défaut):** Utilise l'IP actuelle du WAN (souvent l'IP privée si vous avez une Box). **À éviter si vous êtes derrière une Box.**
- **Other:** C'est ici que vous pouvez saisir manuellement votre **Adresse IP Publique** (ex: `82.x.x.x`).
- **Dynamic DNS (Recommandé):** Si vous avez un nom de domaine (ex: `monvpn.no-ip.org`), choisissez cette option. C'est idéal si votre IP publique change régulièrement.

### 3\. Pourquoi c'est important?

Le fichier `.ovpn` que vous allez exporter est un fichier texte. À l'intérieur, il y a une ligne qui ressemble à ceci:`remote 192.168.1.10 1194` (Mauvais: c'est l'IP locale du pfSense) ou `remote 82.123.x.x 1194` (Bon: c'est votre IP internet réelle)

### 4\. Rappel: La redirection de port (NAT)

Comme vous n'avez pas entré l'IP publique dans pfSense, votre Box ne sait pas non plus quoi faire du trafic arrivant sur le port 1194.

**Vous devez impérativement aller dans l'interface de votre Box Orange/Free/SFR/Bouygues et configurer un transfert de port:**

- **Port de début/fin:** 1194
- **Protocole:** UDP
- **Destination:** L'adresse IP WAN du pfSense (ex: `192.168.1.x`).

**Une fois que vous avez modifié l'option dans "Client Export", téléchargez à nouveau le fichier "Inline Config". Il contiendra alors la bonne adresse pour se connecter.**

---
## 💡 Ma Solution / Notes
> [!TIP] Insérez votre analyse ou vos corrections ici.ontent}}