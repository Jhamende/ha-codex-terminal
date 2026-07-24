#!/usr/bin/env bash
set -Eeuo pipefail

OPTIONS_FILE="/data/options.json"

read_option() {
  local key="$1"
  local fallback="$2"

  if [[ -f "$OPTIONS_FILE" ]]; then
    jq -r --arg key "$key" --arg fallback "$fallback" \
      'if has($key) then .[$key] else $fallback end' "$OPTIONS_FILE"
  else
    printf '%s\n' "$fallback"
  fi
}

WORKING_DIRECTORY="$(read_option working_directory /config)"
FONT_SIZE="$(read_option terminal_font_size 13)"

case "$WORKING_DIRECTORY" in
  /config|/config/*|/share|/share/*|/data|/data/*) ;;
  *) WORKING_DIRECTORY=/config ;;
esac

mkdir -p "$WORKING_DIRECTORY" /data/codex/.codex
chown -R codex:codex /data/codex

export HOME=/data/codex
export CODEX_HOME=/data/codex/.codex
export WORKING_DIRECTORY
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export TERM=xterm-256color
export COLORTERM=truecolor

printf 'Preparing ttyd interface with quick-action toolbar\n'
/usr/local/bin/prepare-ttyd-index

printf 'Starting classic ttyd terminal on port 8099\n'
printf 'Working directory: %s\n' "$WORKING_DIRECTORY"
printf 'Font size: %s\n' "$FONT_SIZE"

exec ttyd \
  --interface 0.0.0.0 \
  --port 8099 \
  --writable \
  --signal SIGTERM \
  --index /tmp/ttyd-index.html \
  --client-option "fontSize=${FONT_SIZE}" \
  --client-option "scrollback=50000" \
  --client-option "disableLeaveAlert=true" \
  --client-option "rendererType=canvas" \
  /usr/local/bin/codex-terminal