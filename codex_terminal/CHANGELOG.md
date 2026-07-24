# Changelog

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