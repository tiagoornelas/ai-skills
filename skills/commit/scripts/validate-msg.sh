#!/usr/bin/env bash
# Deterministic gate for the commit conventions in SKILL.md.
# Usage:  validate-msg.sh <file>   |   validate-msg.sh -m "<message>"
# Exit 0 = valid. Exit 1 = rejected, with one reason per line on stderr.
# Portable to bash 3.2 (macOS default) — no mapfile, no negative indices.

set -uo pipefail

TYPES='feat|fix|refactor|test|docs|chore|style|perf|ci'
TITLE_RE="^(${TYPES})(\([a-z0-9._/-]+\))?: .+"
TASK_RE='^[A-Z][A-Z0-9]+-[0-9]+$'
TASK_ANYWHERE='[A-Z][A-Z0-9]+-[0-9]+'
BULLET_RE='^[[:space:]]*([-*+•]|[0-9]+[.)])[[:space:]]'
BLANK_RE='^[[:space:]]*$'
MAX_TITLE=72
MAX_BODY=3

case "${1:-}" in
  -m) message="${2:-}" ;;
  '') echo "usage: validate-msg.sh <file> | -m \"<message>\"" >&2; exit 2 ;;
  *)  [ -r "$1" ] || { echo "cannot read $1" >&2; exit 2; }
      message=$(cat "$1") ;;
esac

# Drop git template comments.
message=$(printf '%s\n' "$message" | grep -v '^#' || true)

errors=""
fail() { errors="${errors}  - ${1}
"; }

line() { printf '%s\n' "$message" | sed -n "${1}p"; }

title=$(line 1)
line2=$(line 2)
line3=$(line 3)

# --- Title ---------------------------------------------------------------
if [ -z "${title//[[:space:]]/}" ]; then
  fail "empty commit message"
else
  if ! [[ $title =~ $TITLE_RE ]]; then
    fail "title must match '<type>(<scope>): <description>' with type in: ${TYPES//|/, }"
  fi
  if [[ $title =~ $TASK_ANYWHERE ]]; then
    fail "title must not contain a task key — put it alone on the line after a blank line"
  fi
  case "$title" in
    *.) fail "title must not end with a period" ;;
  esac
  if [ "${#title}" -gt "$MAX_TITLE" ]; then
    fail "title is ${#title} chars — keep it to ${MAX_TITLE}"
  fi
fi

total_lines=$(printf '%s\n' "$message" | wc -l | tr -d ' ')

# --- Structure -----------------------------------------------------------
if [ "$total_lines" -gt 1 ] && ! [[ $line2 =~ $BLANK_RE ]]; then
  fail "line 2 must be blank (title is separated from everything else)"
fi

if [[ $line3 =~ $TASK_RE ]]; then
  body=$(printf '%s\n' "$message" | tail -n +4)
  line4=$(line 4)
  if [ "$total_lines" -gt 3 ] && ! [[ $line4 =~ $BLANK_RE ]]; then
    fail "the task reference must be followed by a blank line"
  fi
else
  body=$(printf '%s\n' "$message" | tail -n +3)
fi

body_content=$(printf '%s\n' "$body" | grep -vE "$BLANK_RE" || true)

# --- Body ----------------------------------------------------------------
if [ -n "$body_content" ]; then
  offender=$(printf '%s\n' "$body_content" | grep -E "$BULLET_RE" | head -1 || true)
  if [ -n "$offender" ]; then
    fail "body must not use bullet points or numbered lists: $(printf '%.40s' "$offender")"
  fi

  selfreview_count=$(printf '%s\n' "$body_content" | grep -cE '^Self-review: ' || true)
  prose_count=$(printf '%s\n' "$body_content" | grep -vcE '^Self-review: ' || true)

  if [ "$selfreview_count" -gt 0 ]; then
    last=$(printf '%s\n' "$body_content" | tail -1)
    if ! [[ $last =~ ^Self-review:\ .+ ]]; then
      fail "'Self-review:' must be the last body line and name the finding"
    fi
  fi

  if [ "$prose_count" -gt "$MAX_BODY" ]; then
    fail "body prose is ${prose_count} lines — maximum is ${MAX_BODY}"
  fi
fi

# --- Report --------------------------------------------------------------
if [ -n "$errors" ]; then
  printf 'commit message rejected:\n' >&2
  printf '%s' "$errors" >&2
  exit 1
fi

exit 0
