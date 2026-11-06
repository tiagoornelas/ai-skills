#!/usr/bin/env bash
# ==============================================================================
# scripts/test_setup.sh
# Tests conditional harness detection and linking in ai-skills scripts.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TEST_TMP="$(mktemp -d)"
cleanup() {
  rm -rf "$TEST_TMP"
}
trap cleanup EXIT

echo "=== Running ai-skills setup tests in: $TEST_TMP ==="

# 1. Test is_harness_installed behavior
# Set mock HOME
ORIG_HOME="$HOME"
export HOME="$TEST_TMP/fakehome"
mkdir -p "$HOME"

# shellcheck source=lib/link.sh
source "$SCRIPT_DIR/lib/link.sh"

echo "Test 1: Verification of registered global harnesses..."
has_claude=0; has_gemini=0; has_codex=0; has_cursor=0
for target in "${GLOBAL_SKILL_DIRS[@]}"; do
  case "${target%%:*}" in
    claude) has_claude=1 ;;
    gemini) has_gemini=1 ;;
    codex)  has_codex=1 ;;
    cursor) has_cursor=1 ;;
  esac
done
if [ "$has_claude" -eq 1 ] && [ "$has_gemini" -eq 1 ] && [ "$has_codex" -eq 1 ] && [ "$has_cursor" -eq 1 ]; then
  echo "  ✓ All 4 harnesses registered in GLOBAL_SKILL_DIRS"
else
  echo "  ✗ Missing harness in GLOBAL_SKILL_DIRS" >&2; exit 1
fi

echo "Test 2: Harness detection returns false when neither binary nor directory exists..."
if is_harness_installed "cursor" && [ ! -d "$HOME/.cursor" ] && ! command -v cursor-agent >/dev/null 2>&1 && ! command -v cursor >/dev/null 2>&1 && ! command -v agent >/dev/null 2>&1; then
  echo "  ✗ Expected cursor to be false in clean env" >&2; exit 1
else
  echo "  ✓ Clean env correctly evaluated"
fi

echo "Test 3: Harness detection returns true when directory exists in HOME..."
mkdir -p "$HOME/.cursor"
if is_harness_installed "cursor"; then
  echo "  ✓ .cursor directory recognized"
else
  echo "  ✗ Failed to recognize .cursor directory" >&2; exit 1
fi

echo "Test 4: Running setup-global.sh conditionally with only cursor present..."
# Only .cursor exists in fakehome; use clean PATH to prevent system binaries from falsifying test.
# Seed a link an earlier setup left at a path Cursor never reads, and a link to a skill removed from the repo.
mkdir -p "$HOME/.cursor/rules" "$HOME/.cursor/skills"
ln -s "$REPO_ROOT/global/AGENTS.md" "$HOME/.cursor/rules/global.md"
ln -s "$REPO_ROOT/skills/removed-skill" "$HOME/.cursor/skills/removed-skill"
PATH=/usr/bin:/bin "$SCRIPT_DIR/setup-global.sh" --global-instructions > "$TEST_TMP/setup.log" 2>&1

HOOK_COMMAND="\"$SCRIPT_DIR/cursor-global-instructions.sh\""
hook_count() {
  jq --arg c "$HOOK_COMMAND" '[.hooks.sessionStart[]? | select(.command == $c)] | length' "$HOME/.cursor/hooks.json"
}

if [ -f "$HOME/.cursor/hooks.json" ] && [ "$(hook_count)" -eq 1 ]; then
  echo "  ✓ Cursor sessionStart hook registered in ~/.cursor/hooks.json"
else
  echo "  ✗ Cursor sessionStart hook not registered" >&2; exit 1
fi

hook_context="$(echo '{}' | "$SCRIPT_DIR/cursor-global-instructions.sh" | jq -r '.additional_context')"
if [ "$hook_context" = "$(cat "$REPO_ROOT/global/AGENTS.md")" ]; then
  echo "  ✓ The hook prints global/AGENTS.md as additional context"
else
  echo "  ✗ The hook output does not match global/AGENTS.md" >&2; exit 1
fi

if [ ! -e "$HOME/.cursor/rules/global.md" ] && [ ! -L "$HOME/.cursor/rules/global.md" ]; then
  echo "  ✓ Dead ~/.cursor/rules/global.md link removed"
else
  echo "  ✗ ~/.cursor/rules/global.md should have been removed" >&2; exit 1
fi

if [ ! -L "$HOME/.cursor/skills/removed-skill" ] && [ -L "$HOME/.cursor/skills/coding" ]; then
  echo "  ✓ Skills linked and the link to a removed skill pruned"
else
  echo "  ✗ Skill links not updated" >&2; exit 1
fi

# Ensure uninstalled harnesses were skipped and not created
if [ -d "$HOME/.codex" ]; then
  echo "  ✗ ~/.codex should not have been created" >&2; exit 1
else
  echo "  ✓ Uninstalled harness (codex) safely skipped"
fi

echo "Test 5: Running uninstall-global.sh..."
PATH=/usr/bin:/bin "$SCRIPT_DIR/uninstall-global.sh" > "$TEST_TMP/uninstall.log" 2>&1

if [ ! -e "$HOME/.cursor/hooks.json" ] && [ ! -L "$HOME/.cursor/skills/coding" ]; then
  echo "  ✓ Skill links and the hooks.json setup created removed"
else
  echo "  ✗ Uninstall left skill links or setup's hooks.json" >&2; exit 1
fi

echo "Test 6: Setup merges the hook into an existing hooks.json; uninstall keeps the user's hooks..."
cat > "$HOME/.cursor/hooks.json" <<'JSON'
{
  "version": 1,
  "hooks": {
    "sessionStart": [{ "command": "./hooks/mine.sh start", "timeout": 5 }],
    "stop": [{ "command": "./hooks/mine.sh stop" }]
  }
}
JSON
cp "$HOME/.cursor/hooks.json" "$TEST_TMP/hooks.original.json"
PATH=/usr/bin:/bin "$SCRIPT_DIR/setup-global.sh" --global-instructions > "$TEST_TMP/setup-merge.log" 2>&1
PATH=/usr/bin:/bin "$SCRIPT_DIR/setup-global.sh" --global-instructions > "$TEST_TMP/setup-again.log" 2>&1

if [ "$(hook_count)" -eq 1 ] &&
  jq -e '.hooks.sessionStart[0].command == "./hooks/mine.sh start" and .hooks.stop[0].command == "./hooks/mine.sh stop"' \
    "$HOME/.cursor/hooks.json" >/dev/null; then
  echo "  ✓ Hook added once across two runs, the user's hooks kept"
else
  echo "  ✗ hooks.json merge lost the user's hooks or duplicated the entry" >&2; exit 1
fi

if find "$HOME/.ai-skills-backup" -path '*cursor-hooks/hooks.json' | grep -q .; then
  echo "  ✓ The original hooks.json was backed up"
else
  echo "  ✗ No backup of the original hooks.json" >&2; exit 1
fi

PATH=/usr/bin:/bin "$SCRIPT_DIR/uninstall-global.sh" --dry-run > "$TEST_TMP/uninstall-dry.log" 2>&1
if [ "$(hook_count)" -eq 1 ] && grep -q "would remove.*hooks.json" "$TEST_TMP/uninstall-dry.log"; then
  echo "  ✓ Dry run reports the hook and changes nothing"
else
  echo "  ✗ Dry run changed hooks.json or did not report the hook" >&2; exit 1
fi

PATH=/usr/bin:/bin "$SCRIPT_DIR/uninstall-global.sh" > "$TEST_TMP/uninstall-merge.log" 2>&1
if jq -e --slurpfile o "$TEST_TMP/hooks.original.json" '. == $o[0]' "$HOME/.cursor/hooks.json" >/dev/null; then
  echo "  ✓ Uninstall removed only the hook setup added"
else
  echo "  ✗ Uninstall changed the user's hooks" >&2; exit 1
fi

echo "  Uninstall keeps an empty hooks.json the user had before setup..."
printf '{"version": 1, "hooks": {}}\n' > "$HOME/.cursor/hooks.json"
PATH=/usr/bin:/bin "$SCRIPT_DIR/setup-global.sh" --global-instructions > "$TEST_TMP/setup-empty.log" 2>&1
PATH=/usr/bin:/bin "$SCRIPT_DIR/uninstall-global.sh" > "$TEST_TMP/uninstall-empty.log" 2>&1
if [ -f "$HOME/.cursor/hooks.json" ] && [ "$(hook_count)" -eq 0 ]; then
  echo "  ✓ The user's own empty hooks.json survived uninstall"
else
  echo "  ✗ Uninstall deleted a hooks.json the user had before setup" >&2; exit 1
fi

echo "  Setup with --skills-only leaves the old Cursor rules link alone..."
mkdir -p "$HOME/.cursor/rules"
ln -s "$REPO_ROOT/global/AGENTS.md" "$HOME/.cursor/rules/global.md"
PATH=/usr/bin:/bin "$SCRIPT_DIR/setup-global.sh" --skills-only > "$TEST_TMP/setup-skills-only.log" 2>&1
if [ -L "$HOME/.cursor/rules/global.md" ]; then
  echo "  ✓ --skills-only touched no instruction path"
else
  echo "  ✗ --skills-only removed an instruction link" >&2; exit 1
fi
rm "$HOME/.cursor/rules/global.md"

echo "  Setup leaves a hooks.json it cannot parse untouched..."
echo 'not json' > "$HOME/.cursor/hooks.json"
PATH=/usr/bin:/bin "$SCRIPT_DIR/setup-global.sh" --global-instructions > "$TEST_TMP/setup-invalid.log" 2>&1
if [ "$(cat "$HOME/.cursor/hooks.json")" = "not json" ] && grep -q "not a valid hooks file" "$TEST_TMP/setup-invalid.log"; then
  echo "  ✓ Invalid hooks.json left untouched and reported"
else
  echo "  ✗ Setup changed an invalid hooks.json or did not report it" >&2; exit 1
fi

echo "Test 7: Testing --all flag forces all harness directories..."
PATH=/usr/bin:/bin "$SCRIPT_DIR/setup-global.sh" --skills-only --all > "$TEST_TMP/setup-all.log" 2>&1

if [ -d "$HOME/.codex/skills" ] && [ -d "$HOME/.claude/skills" ]; then
  echo "  ✓ --all correctly created directories for all harnesses"
else
  echo "  ✗ --all failed to create directories for all harnesses" >&2; exit 1
fi

export HOME="$ORIG_HOME"
echo ""
echo "✅ All tests passed successfully!"
