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

codex_args=()
case "${PERMISSION_MODE:-default}" in
  full-auto)
    codex_args+=(--full-auto)
    echo "Permissions : Full Auto (écriture et commandes dans le sandbox du dossier de travail)."
    ;;
  full-access)
    codex_args+=(--dangerously-bypass-approvals-and-sandbox)
    echo "ATTENTION : Full Access activé — aucune approbation et aucun sandbox Codex."
    ;;
  *)
    echo "Permissions : mode Codex par défaut."
    ;;
esac

if [[ "${AUTO_RESUME_LAST_SESSION:-false}" == "true" ]]; then
  echo "Reprise automatique de la dernière session Codex disponible."
  echo
  codex "${codex_args[@]}" resume --last
else
  echo "Utilise /resume ou le bouton /resume pour reprendre une conversation."
  echo
  codex "${codex_args[@]}"
fi

exit_code=$?

echo
echo "Codex s'est arrêté avec le code ${exit_code}."
echo "Tu es maintenant dans un terminal classique."
echo "Relance Codex avec : codex"
echo
echo "Remarque : le mode Full Access désactive les confirmations et le sandbox Codex."
echo

exec bash --login