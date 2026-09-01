# Changelog

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