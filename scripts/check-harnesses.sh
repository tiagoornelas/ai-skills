#!/usr/bin/env bash
# ==============================================================================
# scripts/check-harnesses.sh
# Checks that each installed harness CLI actually receives the global
# instructions and sees the skills: runs one cheap headless prompt per harness
# in an empty temporary folder and prints a pass/fail table. Read-only: it
# changes no configuration. Each probe is one short model call.
#
# Usage:
#   ./scripts/check-harnesses.sh                      # probes every installed harness
#   ./scripts/check-harnesses.sh --skill <name>       # skill to look for (default: agentic-parallel-work)
#   ./scripts/check-harnesses.sh --timeout <seconds>  # per-harness limit (default: 180)
#
# Exit status: 0 when every installed harness passes both checks, 1 otherwise.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GLOBAL_AGENTS_FILE="$REPO_ROOT/global/AGENTS.md"

SKILL="agentic-parallel-work"
TIMEOUT=180
while [ "$#" -gt 0 ]; do
  case "$1" in
    --skill)   SKILL="${2:?--skill needs a name}"; shift 2 ;;
    --timeout) TIMEOUT="${2:?--timeout needs seconds}"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

# The marker is the first bold item under "What I watch" in global/AGENTS.md:
# a model can quote it only when the file is in its context.
MARKER="$(awk '/^### What I watch/ { found = 1; next }
  found && /^- \*\*/ { sub(/^- \*\*/, ""); sub(/\*\*.*/, ""); sub(/:$/, ""); print; exit }' "$GLOBAL_AGENTS_FILE")"
if [ -z "$MARKER" ]; then
  echo "No marker found under '### What I watch' in $GLOBAL_AGENTS_FILE" >&2
  exit 2
fi

PROMPT="This is an automated configuration check. Do not read files, run commands, or use any tool: answer only from what is already in your context. Reply with exactly two lines and nothing else.
Line 1: GLOBAL= followed by the first bold item listed under the heading 'What I watch' in your global instructions, copied verbatim, or NONE if you have no such heading.
Line 2: SKILL= followed by YES if a skill named '$SKILL' is listed as available to you, otherwise NO."

WORK_DIR="$(mktemp -d)"
cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT
PROBE_DIR="$WORK_DIR/probe"
mkdir -p "$PROBE_DIR"

HARNESSES="claude codex agy cursor-agent"

# run_probe <harness> <answer-file>: one headless prompt, run from the empty folder.
run_probe() {
  local harness="$1" answer="$2"
  cd "$PROBE_DIR"
  case "$harness" in
    claude)       claude -p "$PROMPT" > "$answer" ;;
    codex)        codex exec --skip-git-repo-check --ephemeral -s read-only -o "$answer" "$PROMPT" > /dev/null ;;
    agy)          agy --print-timeout "${TIMEOUT}s" -p "$PROMPT" > "$answer" ;;
    cursor-agent) cursor-agent -p --trust --output-format text "$PROMPT" > "$answer" ;;
  esac
}

# run_with_timeout <seconds> <command...>: macOS has no `timeout`.
run_with_timeout() {
  local seconds="$1" pid watcher status=0
  shift
  "$@" &
  pid=$!
  # The watcher holds no output descriptor, so a caller's pipe closes when the probe ends.
  ( sleep "$seconds"; pkill -TERM -P "$pid"; kill "$pid" ) > /dev/null 2>&1 &
  watcher=$!
  wait "$pid" || status=$?
  # Stop the watcher's sleep too, or it outlives the probe.
  pkill -P "$watcher" 2>/dev/null || true
  kill "$watcher" 2>/dev/null || true
  wait "$watcher" 2>/dev/null || true
  return "$status"
}

echo "Probing harnesses (marker: \"$MARKER\", skill: $SKILL, limit: ${TIMEOUT}s each)..."
pids=""
for harness in $HARNESSES; do
  command -v "$harness" >/dev/null 2>&1 || continue
  (
    status=0
    run_with_timeout "$TIMEOUT" run_probe "$harness" "$WORK_DIR/$harness.answer" \
      < /dev/null 2> "$WORK_DIR/$harness.err" || status=$?
    echo "$status" > "$WORK_DIR/$harness.status"
  ) &
  pids="$pids $!"
done
for pid in $pids; do
  wait "$pid" || true
done

# verdict <answer-file> <check>: prints "pass" or "fail".
verdict() {
  local answer="$1" check="$2" line
  line="$(grep -i "^[[:space:]*\`]*$check=" "$answer" 2>/dev/null | head -1 || true)"
  case "$check" in
    GLOBAL) printf '%s' "$line" | grep -Fqi -- "$MARKER" && echo pass || echo fail ;;
    SKILL)  printf '%s' "$line" | grep -qi "SKILL=[[:space:]*\`]*YES" && echo pass || echo fail ;;
  esac
}

echo ""
printf '%-14s %-22s %s\n' "Harness" "Global instructions" "Skill $SKILL"
all_pass=1
for harness in $HARNESSES; do
  if [ ! -f "$WORK_DIR/$harness.status" ]; then
    printf '%-14s %s\n' "$harness" "- not installed (skipped)"
    continue
  fi
  answer="$WORK_DIR/$harness.answer"
  global="$(verdict "$answer" GLOBAL)"
  skill="$(verdict "$answer" SKILL)"
  printf '%-14s %-22s %s\n' "$harness" "$global" "$skill"
  if [ "$global" != pass ] || [ "$skill" != pass ]; then
    all_pass=0
    echo "    exit status $(cat "$WORK_DIR/$harness.status"); answer:"
    sed -n '1,4s/^/      /p' "$answer" 2>/dev/null || true
    sed -n '1,3s/^/      stderr: /p' "$WORK_DIR/$harness.err"
  fi
done

[ "$all_pass" -eq 1 ]
