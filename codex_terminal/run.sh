#!/usr/bin/env bash
set -Eeuo pipefail

OPTIONS_FILE="/data/options.json"
read_option(){ local key="$1" fallback="$2"; if [[ -f "$OPTIONS_FILE" ]]; then jq -r --arg key "$key" --arg fallback "$fallback" 'if has($key) then .[$key] else $fallback end' "$OPTIONS_FILE"; else printf '%s\n' "$fallback"; fi; }

WORKING_DIRECTORY="$(read_option working_directory /config)"
FONT_SIZE="$(read_option terminal_font_size 13)"
case "$WORKING_DIRECTORY" in /config|/config/*|/share|/share/*|/data|/data/*) ;; *) WORKING_DIRECTORY=/config ;; esac

mkdir -p "$WORKING_DIRECTORY" /data/codex/.codex
chown -R codex:codex /data/codex
export CODEX_HOME=/data/codex/.codex HOME=/data/codex WORKING_DIRECTORY
export TERMINAL_FONT_SIZE="$FONT_SIZE" PORT=8099 LANG=C.UTF-8 LC_ALL=C.UTF-8 TERM=xterm-256color

printf 'Starting Codex xterm.js interface on port 8099\n'
printf 'Working directory: %s\n' "$WORKING_DIRECTORY"
exec node /opt/codex-terminal/server.js
