#!/usr/bin/env bash
set -Eeuo pipefail

export TERM="${TERM:-xterm-256color}"
export HOME="${HOME:-/data/codex}"
export CODEX_HOME="${CODEX_HOME:-/data/codex/.codex}"
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"

SESSION_NAME="codex-terminal"
mkdir -p "${CODEX_HOME}"

# Create the persistent session first. A bare `tmux start-server` exits
# immediately when no session exists, which caused the reconnect error.
if ! tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
  tmux new-session -d -s "${SESSION_NAME}" /usr/local/bin/codex-session
fi

# Apply options only after the tmux server and session exist.
tmux set-option -g history-limit 50000
tmux set-option -g mouse on
tmux set-option -g status off

# Reattach to the same Codex session after refreshes or Ingress disconnects.
exec tmux attach-session -t "${SESSION_NAME}"
