#!/usr/bin/env bash
set -Eeuo pipefail

export TERM="${TERM:-xterm-256color}"
export HOME="${HOME:-/data/codex}"
export CODEX_HOME="${CODEX_HOME:-/data/codex/.codex}"
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"

mkdir -p "${CODEX_HOME}"

tmux start-server
tmux set-option -g history-limit 50000
tmux set-option -g mouse on
tmux set-option -g status off

# Attach to the existing Codex session, or create it on first connection.
# The tmux session survives browser refreshes and Ingress disconnections.
exec tmux new-session -A -s codex-terminal /usr/local/bin/codex-session