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
# Only .cursor exists in fakehome; use clean PATH to prevent system binaries from falsifying test
PATH=/usr/bin:/bin "$SCRIPT_DIR/setup-global.sh" --global-instructions > "$TEST_TMP/setup.log" 2>&1

if [ -L "$HOME/.cursor/rules/global.md" ]; then
  echo "  ✓ ~/.cursor/rules/global.md correctly linked"
else
  echo "  ✗ ~/.cursor/rules/global.md not linked" >&2; exit 1
fi

if [ -d "$HOME/.cursor/skills" ]; then
  echo "  ✓ ~/.cursor/skills directory created and linked"
else
  echo "  ✗ ~/.cursor/skills directory not created" >&2; exit 1
fi

# Ensure uninstalled harnesses were skipped and not created
if [ -d "$HOME/.codex" ]; then
  echo "  ✗ ~/.codex should not have been created" >&2; exit 1
else
  echo "  ✓ Uninstalled harness (codex) safely skipped"
fi

echo "Test 5: Running uninstall-global.sh..."
PATH=/usr/bin:/bin "$SCRIPT_DIR/uninstall-global.sh" > "$TEST_TMP/uninstall.log" 2>&1

if [ -L "$HOME/.cursor/rules/global.md" ]; then
  echo "  ✗ ~/.cursor/rules/global.md should have been removed" >&2; exit 1
else
  echo "  ✓ ~/.cursor/rules/global.md uninstalled cleanly"
fi

echo "Test 6: Testing --all flag forces all harness directories..."
PATH=/usr/bin:/bin "$SCRIPT_DIR/setup-global.sh" --skills-only --all > "$TEST_TMP/setup-all.log" 2>&1

if [ -d "$HOME/.codex/skills" ] && [ -d "$HOME/.claude/skills" ]; then
  echo "  ✓ --all correctly created directories for all harnesses"
else
  echo "  ✗ --all failed to create directories for all harnesses" >&2; exit 1
fi

export HOME="$ORIG_HOME"
echo ""
echo "✅ All tests passed successfully!"
