#!/usr/bin/env bash
set -Euo pipefail

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

while ! codex login status >/dev/null 2>&1; do
  echo "Aucune authentification Codex valide détectée."
  echo "Démarrage automatique de la connexion par code appareil..."
  echo

  if codex login --device-auth; then
    echo
    echo "Authentification réussie."
    break
  fi

  echo
  echo "La connexion Codex a échoué ou a été annulée."
  echo "Nouvelle tentative automatique dans 10 secondes..."
  sleep 10
done

echo
echo "Authentification Codex détectée. Démarrage automatique..."
echo "Après une reconnexion, utilise /resume pour reprendre une conversation."
echo

codex
exit_code=$?

echo
echo "Codex s'est arrêté avec le code ${exit_code}."
echo "Tu es maintenant dans un terminal classique. Relance Codex avec : codex"
echo "Puis utilise /resume pour reprendre une conversation."
echo

exec bash --login
