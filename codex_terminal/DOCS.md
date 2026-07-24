# Codex Terminal

## Premier démarrage

Ouvre l'interface web de l'app. Sans session existante, le terminal affiche les commandes de connexion.

### Utiliser l'abonnement ChatGPT

```bash
codex login --device-auth
```

Ouvre l'adresse affichée sur un autre appareil et saisis le code.

### Utiliser une clé API OpenAI

```bash
read -rsp "OpenAI API key: " OPENAI_API_KEY; echo
printf '%s' "$OPENAI_API_KEY" | codex login --with-api-key
unset OPENAI_API_KEY
```

L'utilisation par clé API est facturée via le compte OpenAI Platform et non via l'abonnement ChatGPT.

## Répertoires

- `/config` : configuration Home Assistant, montée en lecture/écriture
- `/share` : dossier partagé Home Assistant, monté en lecture/écriture
- `/data/codex/.codex` : authentification et configuration Codex persistantes

## Options

- `start_codex_automatically` : démarre Codex dès l'ouverture si l'utilisateur est connecté
- `working_directory` : `/config`, `/share`, `/data`, ou un sous-dossier
- `terminal_font_size` : taille de police entre 10 et 30

## Exemples

```text
Analyse mon configuration.yaml et relève les erreurs potentielles sans rien modifier.
```

```text
Crée un dashboard Lovelace pour l'énergie dans /config/dashboards/energy.yaml.
Avant toute modification, montre-moi ton plan.
```

```text
Recherche les entités liées au salon dans /config/.storage et propose une carte dashboard.
Ne modifie pas les fichiers .storage.
```

## Limites de sécurité

L'app n'accède pas au socket Docker, au réseau hôte, aux périphériques ou aux privilèges système. Codex peut néanmoins exécuter des commandes et modifier `/config` et `/share`. Effectue une sauvegarde Home Assistant avant des changements importants.
