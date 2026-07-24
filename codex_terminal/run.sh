#!/usr/bin/env bash
set -Eeuo pipefail

OPTIONS_FILE="/data/options.json"

read_option() {
  local key="$1"
  local fallback="$2"
  if [[ -f "${OPTIONS_FILE}" ]]; then
    jq -r --arg key "${key}" --arg fallback "${fallback}" \
      'if has($key) then .[$key] else $fallback end' "${OPTIONS_FILE}"
  else
    printf '%s\n' "${fallback}"
  fi
}

WORKING_DIRECTORY="$(read_option working_directory /config)"
FONT_SIZE="$(read_option terminal_font_size 15)"

case "${WORKING_DIRECTORY}" in
  /config|/config/*|/share|/share/*|/data|/data/*) ;;
  *)
    echo "Invalid working_directory: ${WORKING_DIRECTORY}"
    echo "Falling back to /config"
    WORKING_DIRECTORY="/config"
    ;;
esac

mkdir -p "${WORKING_DIRECTORY}" /data/codex/.codex
chown -R codex:codex /data/codex

export CODEX_HOME="/data/codex/.codex"
export HOME="/data/codex"
export WORKING_DIRECTORY

echo "Starting Codex Terminal on Home Assistant Ingress port 8099"
echo "Working directory: ${WORKING_DIRECTORY}"
echo "Authentication and Codex startup are automatic."
echo "The tmux session remains active until the add-on stops or restarts."

exec ttyd \
  --port 8099 \
  --interface 0.0.0.0 \
  --writable \
  --check-origin \
  --client-option "fontSize=${FONT_SIZE}" \
  --client-option "disableLeaveAlert=true" \
  /usr/local/bin/codex-terminal
