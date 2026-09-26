#!/usr/bin/env bash
set -Eeuo pipefail
OPTIONS_FILE="/data/options.json"
read_option() {
  local key="$1"
  local fallback="$2"
  if [[ -f "$OPTIONS_FILE" ]]; then
    jq -r --arg key "$key" --arg fallback "$fallback" 'if has($key) then .[$key] else $fallback end' "$OPTIONS_FILE"
  else
    printf '%s\n' "$fallback"
  fi
}
WORKING_DIRECTORY="$(read_option working_directory /config)"
PERMISSION_MODE="$(read_option permission_mode default)"
case "$WORKING_DIRECTORY" in
  /config|/config/*|/share|/share/*|/data|/data/*) ;;
  *) WORKING_DIRECTORY=/config ;;
esac
case "$PERMISSION_MODE" in
  default|full-auto|full-access) ;;
  *) PERMISSION_MODE=default ;;
esac
mkdir -p /data/codex/.codex /data/codex/uploads "$WORKING_DIRECTORY"
export HOME=/data/codex
export CODEX_HOME=/data/codex/.codex
export WORKING_DIRECTORY PERMISSION_MODE
export LANG=C.UTF-8 LC_ALL=C.UTF-8 TERM=xterm-256color COLORTERM=truecolor
echo "Starting persistent Codex Chat UI on port 8099"
exec node /app/server.js
