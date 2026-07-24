#!/usr/bin/env bash
set -Eeuo pipefail

cd "${WORKING_DIRECTORY:-/config}"

cat <<'BANNER'
┌──────────────────────────────────────────────────────────────┐
│                 Codex Terminal · Home Assistant              │
└──────────────────────────────────────────────────────────────┘

Codex peut lire et modifier les fichiers du dossier courant.
Répertoire de travail :
BANNER

pwd
echo

if ! codex login status >/dev/null 2>&1; then
  cat <<'LOGIN'
Aucune session Codex n'est encore configurée.

Connexion avec ton abonnement ChatGPT :
  codex login --device-auth

Connexion avec une clé API :
  read -rsp "OpenAI API key: " OPENAI_API_KEY; echo
  printf '%s' "$OPENAI_API_KEY" | codex login --with-api-key
  unset OPENAI_API_KEY

Après la connexion, lance :
  codex
LOGIN
  echo
fi

if [[ "${START_CODEX:-true}" == "true" ]] && codex login status >/dev/null 2>&1; then
  exec codex
fi

exec bash --login
