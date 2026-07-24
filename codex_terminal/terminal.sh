#!/usr/bin/env bash
set -Eeuo pipefail

export TERM="${TERM:-xterm-256color}"
export HOME="${HOME:-/data/codex}"
export CODEX_HOME="${CODEX_HOME:-/data/codex/.codex}"

mkdir -p "${CODEX_HOME}"

# Attach to the existing Codex session, or create it on first connection.
# The tmux session survives browser refreshes and Ingress disconnections.
exec tmux new-session -A -s codex-terminal /usr/local/bin/codex-session
