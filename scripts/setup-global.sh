#!/usr/bin/env bash
# ==============================================================================
# scripts/setup-global.sh
# Globally links ai-skills and instructions across supported harnesses:
# - Claude Code   (~/.claude)
# - Antigravity   (~/.gemini/config)
# - Codex         (~/.codex)
#
# Usage:
#   ./scripts/setup-global.sh                         # prompts before linking global instructions
#   ./scripts/setup-global.sh --global-instructions   # links global instructions without prompting
#   ./scripts/setup-global.sh --skills-only           # links skills only
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
GLOBAL_AGENTS_FILE="$REPO_ROOT/global/AGENTS.md"

GLOBAL_INSTRUCTIONS="ask"
for arg in "$@"; do
  case "$arg" in
    --global-instructions) GLOBAL_INSTRUCTIONS="yes" ;;
    --skills-only)         GLOBAL_INSTRUCTIONS="no" ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

# shellcheck source=lib/link.sh
source "$SCRIPT_DIR/lib/link.sh"

# Global skill destinations
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
GEMINI_SKILLS_DIR="$HOME/.gemini/config/skills"
CODEX_SKILLS_DIR="$HOME/.codex/skills"

echo "=========================================================="
echo "  ai-skills: Global Setup for Skills and Agents"
echo "  Repository: $REPO_ROOT"
echo "=========================================================="

# 1. Ensure target directories exist
mkdir -p "$CLAUDE_SKILLS_DIR"
mkdir -p "$GEMINI_SKILLS_DIR"
mkdir -p "$CODEX_SKILLS_DIR"

# 2. Link individual skills found in ai-skills/skills/
echo ""
echo "🔗 Linking skills from ai-skills/skills/..."

count=0
for skill_path in "$SKILLS_DIR"/*; do
  [ -e "$skill_path" ] || continue
  skill_name="$(basename "$skill_path")"

  # Ignore hidden control files like .gitkeep
  if [[ "$skill_name" =~ ^\. ]]; then
    continue
  fi

  if [ -d "$skill_path" ]; then
    echo "  -> Linking skill: $skill_name"
    safe_link "$skill_path" "$CLAUDE_SKILLS_DIR/$skill_name" claude
    safe_link "$skill_path" "$GEMINI_SKILLS_DIR/$skill_name" gemini
    safe_link "$skill_path" "$CODEX_SKILLS_DIR/$skill_name" codex
    count=$((count + 1))
  fi
done

# Prune dangling links for skills removed from repository
prune_dangling_links "$CLAUDE_SKILLS_DIR" "$SKILLS_DIR"
prune_dangling_links "$GEMINI_SKILLS_DIR" "$SKILLS_DIR"
prune_dangling_links "$CODEX_SKILLS_DIR" "$SKILLS_DIR"

if [ "$count" -eq 0 ]; then
  echo "  (No skills found in $SKILLS_DIR yet. When adding new skill folders, run this script again to link them automatically)."
else
  echo "  ✓ Successfully linked $count skill(s)!"
fi

# 3. Global instructions (global/AGENTS.md)
echo ""
echo "⚙️ Global Instructions ($GLOBAL_AGENTS_FILE):"
echo "  - Claude Code: ~/.claude/CLAUDE.md"
echo "  - Antigravity: ~/.gemini/GEMINI.md (and ~/.gemini/config/AGENTS.md)"
echo "  - Codex:       ~/.codex/AGENTS.md"
echo ""

if [ "$GLOBAL_INSTRUCTIONS" = "ask" ]; then
  if [ -t 0 ]; then
    read -p "Do you want to link global instructions now? [y/N]: " -r response || response="n"
    [[ "$response" =~ ^([yY][eE][sS]|[yY]|[sS][iI][mM]|[sS])$ ]] && GLOBAL_INSTRUCTIONS="yes" || GLOBAL_INSTRUCTIONS="no"
  else
    echo "  Non-interactive terminal: run with --global-instructions to link without prompting."
    GLOBAL_INSTRUCTIONS="no"
  fi
fi

if [ "$GLOBAL_INSTRUCTIONS" = "yes" ]; then
  mkdir -p "$HOME/.claude" "$HOME/.gemini/config" "$HOME/.codex"
  safe_link "$GLOBAL_AGENTS_FILE" "$HOME/.claude/CLAUDE.md" claude
  echo "  ✓ ~/.claude/CLAUDE.md -> $GLOBAL_AGENTS_FILE"
  safe_link "$GLOBAL_AGENTS_FILE" "$HOME/.gemini/config/AGENTS.md" gemini
  echo "  ✓ ~/.gemini/config/AGENTS.md -> $GLOBAL_AGENTS_FILE"
  safe_link "$GLOBAL_AGENTS_FILE" "$HOME/.gemini/GEMINI.md" gemini
  echo "  ✓ ~/.gemini/GEMINI.md -> $GLOBAL_AGENTS_FILE"
  safe_link "$GLOBAL_AGENTS_FILE" "$HOME/.codex/AGENTS.md" codex
  echo "  ✓ ~/.codex/AGENTS.md -> $GLOBAL_AGENTS_FILE"
else
  echo "  Global instructions not linked (existing configurations preserved)."
fi

echo ""
if [ "$AI_SKILLS_BACKED_UP" -eq 1 ]; then
  echo "📦 Replaced content was safely moved to: $AI_SKILLS_BACKUP_DIR"
fi
echo "✅ Done!"
