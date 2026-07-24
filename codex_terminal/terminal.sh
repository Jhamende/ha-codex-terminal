#!/usr/bin/env bash
set -Eeuo pipefail

export TERM="${TERM:-xterm-256color}"
export HOME="${HOME:-/data/codex}"
export CODEX_HOME="${CODEX_HOME:-/data/codex/.codex}"
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"

mkdir -p "${CODEX_HOME}"

# One conventional terminal process per browser connection.
# Codex conversations remain available through /resume.
exec /usr/local/bin/codex-session
