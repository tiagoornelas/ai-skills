#!/usr/bin/env bash
# ==============================================================================
# scripts/cursor-global-instructions.sh
# Cursor CLI `sessionStart` hook, registered in ~/.cursor/hooks.json by
# setup-global.sh. Cursor CLI reads no global rules file, so this hook injects
# global/AGENTS.md as additional context at the start of every session, always
# from the current version of the file.
#
# Prints: {"additional_context": "<global/AGENTS.md>", "continue": true}
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_AGENTS_FILE="$SCRIPT_DIR/../global/AGENTS.md"

# Cursor sends the hook payload on stdin; drain it so the writer never blocks.
[ -t 0 ] || cat >/dev/null

# A missing file must never stop the session from starting.
if [ ! -r "$GLOBAL_AGENTS_FILE" ]; then
  printf '{"continue": true}\n'
  exit 0
fi

# JSON string escaping without external tools: backslashes and quotes first,
# tabs as \t, other control characters dropped, and lines joined with \n.
tab="$(printf '\t')"
context="$(
  tr -d '\r\000-\010\013\014\016-\037' < "$GLOBAL_AGENTS_FILE" |
    sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e "s/$tab/\\\\t/g" |
    awk 'NR > 1 { printf "%s", "\\n" } { printf "%s", $0 }'
)"
printf '{"additional_context": "%s", "continue": true}\n' "$context"
