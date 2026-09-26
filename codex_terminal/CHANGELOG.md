# Changelog

## 0.5.6

- Correction du mode Full Access sur les conversations déjà actives
- Utilisation de `thread/settings/update` pour appliquer immédiatement `approvalPolicy: never` et `sandboxPolicy: dangerFullAccess`
- Correction du format structuré des politiques sandbox envoyées à Codex app-server
- Retrait du paquet `bubblewrap` système, incompatible avec les restrictions de mount/namespaces du conteneur Home Assistant
- Retour au mécanisme bubblewrap embarqué/fallback de Codex pour les modes sandboxés
- Chromium reste installé et disponible pour les tests navigateur

## 0.5.5

- Rétablissement de Chromium après confirmation que la 0.5.3 s’installe correctement sur Home Assistant
- Conservation de `bubblewrap` système
- Rétablissement de `CHROME_BIN` et `CHROMIUM_BIN` vers `/usr/bin/chromium-browser`
- Conservation du dossier `/data/codex/screenshots`
- Aucune régression des fonctions Chat, session persistante, modèles, activités repliables, durée ou uploads

## 0.5.4

- Correctif d’installation après blocages constatés sur plusieurs Home Assistant
- Retrait de Chromium du build local par défaut : le paquet complet ajoute environ 259 Mo installés et une chaîne importante de dépendances
- Conservation de `bubblewrap`, de l’interface Chat, du choix dynamique du modèle, des étapes repliables, de la durée et des uploads
- Le support navigateur sera réintroduit via une méthode qui n’alourdit pas le build local de chaque installation

## 0.5.3

- Rétablissement du nom stable `Codex Terminal` afin de conserver une identité d’add-on cohérente pour Home Assistant Supervisor
- Conservation de l’interface Chat et du `slug: codex_terminal`
- Installation du paquet système `bubblewrap` pour supprimer l’avertissement de sandbox Codex au démarrage
- Inclut toutes les fonctions 0.5.1/0.5.2 : étapes repliables, durée, choix dynamique du modèle et Chromium

## 0.5.2

- Ajout du sélecteur de modèle dans l’en-tête de l’interface Chat
- Catalogue chargé dynamiquement depuis l’API `model/list` de Codex app-server
- Option `Modèle auto` pour conserver le choix recommandé par Codex
- Persistance du modèle sélectionné et application aux nouveaux tours via `turn/start`
- Installation de Chromium dans l’image de l’add-on pour les tests et validations visuelles headless
- Ajout des variables `CHROME_BIN` et `CHROMIUM_BIN`
- Création du dossier persistant `/data/codex/screenshots` pour les captures produites par les outils navigateur
- Conservation des étapes repliables et de l’affichage `Terminé en X min Y s`
- Nettoyage de l’ancienne entrée de changelog 0.4.24 mal formatée

## 0.5.1

- Affichage des commandes, modifications de fichiers et appels d’outils sous forme d’étapes repliables dans la conversation
- Conservation des outputs détaillés accessibles en cliquant sur une étape
- Persistance des étapes dans `ui-state.json` lors de la navigation dans Home Assistant
- Mesure côté backend de la durée réelle de chaque tour Codex
- Affichage `Terminé en X min Y s` à la fin du traitement
- Conservation de la dernière durée après reconnexion à l’interface

## 0.5.0

- Nouvelle interface principale de type chat, conçue pour Home Assistant et les écrans mobiles
- Remplacement du terminal comme propriétaire de la session par un backend Codex persistant
- Utilisation directe de `codex app-server` et de ses événements structurés
- La navigation vers une autre page Home Assistant ne ferme plus Codex et ne crée plus une nouvelle session
- Conservation du `threadId` et du journal d’affichage dans `/data/codex/ui-state.json`
- Reconnexion automatique de l’interface au même backend et à la même conversation
- Reprise du thread après redémarrage de l’add-on avec `thread/resume` sans recharger tout le transcript dans le navigateur
- Ajout d’un bouton d’upload d’images
- Stockage persistant des images dans `/data/codex/uploads` et transmission du chemin local à Codex
- Ajout d’un bouton Nouvelle conversation
- Sélection visuelle des modes Standard, Full Auto et Full Access
- Conservation de l’authentification et des rollouts Codex existants dans `/data/codex/.codex`

## 0.4.25

- Correction du YAML invalide de la version 0.4.24 qui empêchait Home Assistant de détecter la mise à jour
- Correction du script de démarrage GNU Screen et de la variable `TERMINAL_COMMAND`
- Conservation de l’option `persistent_screen`, désormais fonctionnelle

## 0.4.23

- Ajout d’un mode `Sélection` adapté aux écrans tactiles et à la WebView Android Home Assistant
- Ajout du bouton `Copier` pour envoyer la sélection au presse-papiers
- Le mode sélection active explicitement la sélection native du texte dans le terminal ttyd
- Le bouton `↓ Bas` quitte le mode sélection et rend le focus au terminal

## 0.4.22

- Correction de la compatibilité avec Codex CLI 0.157.0 dans le conteneur Home Assistant
- Lancement systématique de Codex avec `--no-daemon` pour éviter l'échec du pid-managed app-server (`failed to read start time`)
- La reprise automatique utilise également `--no-daemon`
- Conservation des modes de permissions `default`, `full-auto` et `full-access`

## 0.4.21

- Mise à jour automatique de Codex CLI de `0.156.1` vers `0.157.0`
- Version détectée via le canal stable npm `@openai/codex`
## 0.4.20

- Mise à jour automatique de Codex CLI de `0.155.1` vers `0.156.1`
- Version détectée via le canal stable npm `@openai/codex`
## 0.4.19

- Mise à jour automatique de Codex CLI de `0.155.0` vers `0.155.1`
- Version détectée via le canal stable npm `@openai/codex`
## 0.4.18

- Mise à jour automatique de Codex CLI de `0.154.0` vers `0.155.0`
- Version détectée via le canal stable npm `@openai/codex`
## 0.4.17

- Mise à jour automatique de Codex CLI de `0.153.4` vers `0.154.0`
- Version détectée via le canal stable npm `@openai/codex`
## 0.4.16

- Mise à jour automatique de Codex CLI de `0.153.2` vers `0.153.4`
- Version détectée via le canal stable npm `@openai/codex`
## 0.4.15

- Mise à jour automatique de Codex CLI de `0.153.0` vers `0.153.2`
- Version détectée via le canal stable npm `@openai/codex`
## 0.4.14

- Ajout du bouton `↶ Derniers` dans la barre d’actions du terminal
- Ajout de l’utilitaire local `codex-last-exchanges` pour lire les derniers échanges réellement persistés dans le rollout JSONL Codex
- Le bouton utilise le mode shell local Codex (`!commande`) : aucun appel au modèle et aucun nouveau tour de conversation
- Affichage des 12 derniers messages utilisateur/assistant détectés, de la session lue et de sa taille
- Lecture limitée aux dernières 20 000 lignes / 32 MiB du rollout afin de rester rapide même sur de très grosses sessions
- Déduplication des messages persistés sous plusieurs formes par Codex
- Lecture strictement seule : aucun fichier de session n’est modifié ou tronqué

## 0.4.13

- Remplacement du renderer ttyd `canvas` par `dom` pour permettre la sélection et la copie de texte dans le terminal
- Conservation du scrollback ttyd à 50 000 lignes : il s’agit uniquement de l’historique visuel du terminal et non du contexte de conversation Codex
- Aucun effacement automatique des anciennes sessions Codex

## 0.4.12

- Mise à jour automatique de Codex CLI de `0.152.1` vers `0.153.0`
- Version détectée via le canal stable npm `@openai/codex`
## 0.4.11

- Mise à jour automatique de Codex CLI de `0.152.0` vers `0.152.1`
- Version détectée via le canal stable npm `@openai/codex`
## 0.4.10

- Mise à jour automatique de Codex CLI de `0.151.0` vers `0.152.0`
- Version détectée via le canal stable npm `@openai/codex`
## 0.4.9

- Mise à jour automatique de Codex CLI de `0.150.1` vers `0.151.0`
- Version détectée via le canal stable npm `@openai/codex`
## 0.4.8

- Mise à jour de Codex CLI vers la version stable `0.150.1`
- Conservation du contrôle `codex --version` pendant la construction de l’image
- Aucune modification des options de session, de permissions ou de l’interface ttyd

## 0.4.7

- Mise à jour de Codex CLI vers la version stable `0.149.1`
- Version Codex désormais figée explicitement dans le Dockerfile pour garantir des builds reproductibles
- Ajout d’un contrôle `codex --version` pendant la construction de l’image

## 0.4.6

- Ajout de l’option `auto_resume_last_session` pour reprendre automatiquement la dernière session avec `codex resume --last`
- Ajout de l’option `permission_mode`
- Ajout du mode `default` utilisant les permissions Codex standard
- Ajout du mode `full-auto` autorisant l’écriture et les commandes dans le sandbox du dossier de travail
- Ajout du mode `full-access` désactivant les confirmations et le sandbox Codex
- Affichage du mode de permissions et de la reprise automatique dans les journaux de démarrage
- Validation des valeurs de configuration avant le lancement du terminal

## 0.4.5

- Ajout d’un bouton `Esc` dans la barre d’actions flottante
- Envoi direct de la touche Échap au terminal ttyd
- Conservation des boutons `↓ Bas` et `/resume`

## 0.4.4

- Ajout d’une barre d’actions flottante dans l’interface ttyd
- Ajout d’un bouton `↓ Bas` pour revenir immédiatement à la dernière ligne du terminal
- Ajout d’un bouton `/resume` pour envoyer et valider directement la commande Codex
- Conservation du terminal ttyd natif et de sa compatibilité Home Assistant Ingress
- Génération automatique d’un index ttyd personnalisé au démarrage

## 0.4.3

- Suppression de l’interface personnalisée Node.js, WebSocket et xterm.js
- Retour au terminal web classique `ttyd`, déjà compatible avec Home Assistant Ingress
- Suppression de la construction manuelle du chemin WebSocket
- Conservation d’une session terminal indépendante par connexion, sans `tmux`
- Démarrage automatique de Codex et authentification persistante dans `/data`
- Historique configuré à 50 000 lignes et police configurable
- Utilisation de `/resume` pour reprendre une conversation Codex après reconnexion

## 0.4.2

- Correction du chemin WebSocket Home Assistant Ingress
- Conservation explicite du jeton `/api/hassio_ingress/<token>/`
- Ajout de l’URL WebSocket utilisée dans l’infobulle du statut pour faciliter le diagnostic
- Correction du blocage persistant sur « Connexion… »

## 0.4.1

- Première correction de la construction de l’URL WebSocket derrière Home Assistant Ingress
- Ajout d’un délai d’expiration de connexion
- Ajout de messages d’erreur et de reconnexion plus explicites
- Désactivation du cache pour les fichiers JavaScript et HTML

## 0.4.0

- Suppression de tmux et retour à une session terminal classique
- Nouvelle session créée à chaque connexion WebSocket
- Conservation de l’authentification Codex dans `/data`
- Démarrage automatique de Codex
- Retour à un shell Bash lorsque Codex est fermé
- Ajout d’un bouton `/resume` pour reprendre une conversation Codex

## 0.3.1

- Tentative de défilement de l’historique Codex via le mode copie de tmux
- Ajout de commandes serveur pour remonter, redescendre et quitter l’historique

## 0.3.0

- Remplacement de ttyd par une interface xterm.js dédiée
- Ajout d’un serveur WebSocket Node.js
- Utilisation de node-pty pour fournir un pseudo-terminal réel
- Interface adaptée aux écrans mobiles
- Ajout de commandes tactiles et d’un historique de 50 000 lignes

## 0.2.2

- Correction de l’erreur `no server running on /tmp/tmux-0/default`
- Création de la session tmux avant l’application de ses options

## 0.2.1

- Police réduite à 13 px par défaut
- Historique du terminal augmenté à 50 000 lignes
- Défilement vers le haut amélioré dans le terminal web
- Environnement UTF-8 activé pour les caractères accentués
- Rendu Canvas activé pour une meilleure compatibilité navigateur

## 0.2.0

- Vérification automatique de l’authentification Codex
- Connexion par code appareil lancée automatiquement si nécessaire
- Démarrage automatique de Codex
- Session persistante via tmux tant que l’add-on fonctionne
- Relance automatique de Codex après une fermeture inattendue

## 0.1.0

- Première version
- Terminal web via Home Assistant Ingress
- Codex CLI installé depuis le paquet npm officiel
- Authentification persistante
- Accès configurable à `/config`, `/share` et `/data`