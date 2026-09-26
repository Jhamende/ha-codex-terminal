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
FONT_SIZE="$(read_option terminal_font_size 13)"
AUTO_RESUME_LAST_SESSION="$(read_option auto_resume_last_session false)"
PERMISSION_MODE="$(read_option permission_mode default)"
PERSISTENT_SCREEN="$(read_option persistent_screen false)"

case "$WORKING_DIRECTORY" in
  /config|/config/*|/share|/share/*|/data|/data/*) ;;
  *) WORKING_DIRECTORY=/config ;;
esac
case "$AUTO_RESUME_LAST_SESSION" in true|false) ;; *) AUTO_RESUME_LAST_SESSION=false ;; esac
case "$PERMISSION_MODE" in default|full-auto|full-access) ;; *) PERMISSION_MODE=default ;; esac
case "$PERSISTENT_SCREEN" in true|false) ;; *) PERSISTENT_SCREEN=false ;; esac

mkdir -p "$WORKING_DIRECTORY" /data/codex/.codex
chown -R codex:codex /data/codex

export HOME=/data/codex
export CODEX_HOME=/data/codex/.codex
export WORKING_DIRECTORY AUTO_RESUME_LAST_SESSION PERMISSION_MODE PERSISTENT_SCREEN
export LANG=C.UTF-8 LC_ALL=C.UTF-8 TERM=xterm-256color COLORTERM=truecolor

printf 'Preparing ttyd interface with quick-action toolbar\n'
/usr/local/bin/prepare-ttyd-index

printf 'Starting classic ttyd terminal on port 8099\n'
printf 'Working directory: %s\n' "$WORKING_DIRECTORY"
printf 'Font size: %s\n' "$FONT_SIZE"
printf 'Auto-resume last session: %s\n' "$AUTO_RESUME_LAST_SESSION"
printf 'Permission mode: %s\n' "$PERMISSION_MODE"
printf 'Persistent GNU Screen: %s\n' "$PERSISTENT_SCREEN"

TERMINAL_COMMAND=(/usr/local/bin/codex-terminal)
if [[ "$PERSISTENT_SCREEN" == "true" ]]; then
  TERMINAL_COMMAND=(screen -D -RR -S codex-terminal /usr/local/bin/codex-terminal)
fi

exec ttyd \
  --interface 0.0.0.0 \
  --port 8099 \
  --writable \
  --signal SIGTERM \
  --index /tmp/ttyd-index.html \
  --client-option "fontSize=${FONT_SIZE}" \
  --client-option "scrollback=50000" \
  --client-option "disableLeaveAlert=true" \
  --client-option "rendererType=dom" \
  "${TERMINAL_COMMAND[@]}"
