#!/usr/bin/env bash
# ==============================================================================
# scripts/setup-global.sh
# Globally links ai-skills and instructions across supported harnesses:
# - Claude Code   (~/.claude)
# - Antigravity   (~/.gemini/config)
# - Codex         (~/.codex)
# - Cursor CLI    (~/.cursor; instructions through a sessionStart hook)
#
# Usage:
#   ./scripts/setup-global.sh                         # links for detected harnesses, prompts for instructions
#   ./scripts/setup-global.sh --global-instructions   # links global instructions without prompting
#   ./scripts/setup-global.sh --skills-only           # links skills only
#   ./scripts/setup-global.sh --all                   # installs for all supported harnesses without filtering
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
GLOBAL_AGENTS_FILE="$REPO_ROOT/global/AGENTS.md"
CURSOR_HOOK_SCRIPT="$SCRIPT_DIR/cursor-global-instructions.sh"

GLOBAL_INSTRUCTIONS="ask"
INSTALL_ALL="no"
for arg in "$@"; do
  case "$arg" in
    --global-instructions) GLOBAL_INSTRUCTIONS="yes" ;;
    --skills-only)         GLOBAL_INSTRUCTIONS="no" ;;
    --all)                 INSTALL_ALL="yes" ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

# shellcheck source=lib/link.sh
source "$SCRIPT_DIR/lib/link.sh"

echo "=========================================================="
echo "  ai-skills: Global Setup for Skills and Agents"
echo "  Repository: $REPO_ROOT"
echo "=========================================================="

# Filter active targets based on installed harnesses
ACTIVE_SKILL_DIRS=()
ACTIVE_INSTRUCTION_FILES=()
for target in "${GLOBAL_SKILL_DIRS[@]}"; do
  label="${target%%:*}"
  if [ "$INSTALL_ALL" = "yes" ] || is_harness_installed "$label"; then
    ACTIVE_SKILL_DIRS+=("$target")
  fi
done

for target in "${GLOBAL_INSTRUCTION_FILES[@]}"; do
  label="${target%%:*}"
  if [ "$INSTALL_ALL" = "yes" ] || is_harness_installed "$label"; then
    ACTIVE_INSTRUCTION_FILES+=("$target")
  fi
done

# 1. Report detected harnesses and ensure target directories exist
echo ""
echo "🔍 Harness Detection:"
detected_labels=()
for target in "${ACTIVE_SKILL_DIRS[@]}"; do
  label="${target%%:*}"
  if [[ ! " ${detected_labels[*]:-} " =~ " ${label} " ]]; then
    detected_labels+=("$label")
    echo "  ✓ $label"
  fi
done

skipped_labels=()
for target in "${GLOBAL_SKILL_DIRS[@]}"; do
  label="${target%%:*}"
  if [[ ! " ${detected_labels[*]:-} " =~ " ${label} " ]] && [[ ! " ${skipped_labels[*]:-} " =~ " ${label} " ]]; then
    skipped_labels+=("$label")
    echo "  ○ $label (not detected - skipped; use --all to force)"
  fi
done

if [ "${#ACTIVE_SKILL_DIRS[@]}" -eq 0 ]; then
  echo ""
  echo "⚠️  No supported AI agent harness detected on this machine."
  echo "   (Checked: claude, gemini, codex, cursor)."
  echo "   To install anyway, run with: ./scripts/setup-global.sh --all"
  exit 0
fi

for target in "${ACTIVE_SKILL_DIRS[@]}"; do
  mkdir -p "${target#*:}"
done

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
    for target in "${ACTIVE_SKILL_DIRS[@]}"; do
      safe_link "$skill_path" "${target#*:}/$skill_name" "${target%%:*}"
    done
    count=$((count + 1))
  fi
done

# Prune dangling links for skills removed from repository
for target in "${ACTIVE_SKILL_DIRS[@]}"; do
  prune_dangling_links "${target#*:}" "$SKILLS_DIR"
done

if [ "$count" -eq 0 ]; then
  echo "  (No skills found in $SKILLS_DIR yet. When adding new skill folders, run this script again to link them automatically)."
else
  echo "  ✓ Successfully linked $count skill(s)!"
fi

# Remove links an earlier setup made at instruction paths no harness reads
for target in "${LEGACY_INSTRUCTION_FILES[@]}"; do
  path="${target#*:}"
  if [ -L "$path" ] && [ "$(readlink "$path")" = "$GLOBAL_AGENTS_FILE" ]; then
    rm "$path"
    echo "     [removed] unused instruction link: $path"
  fi
done

# 3. Global instructions (global/AGENTS.md)
echo ""
echo "⚙️ Global Instructions ($GLOBAL_AGENTS_FILE):"
for target in ${ACTIVE_INSTRUCTION_FILES[@]+"${ACTIVE_INSTRUCTION_FILES[@]}"}; do
  path="${target#*:}"
  echo "  - ${target%%:*}: ~${path#"$HOME"}"
done
CURSOR_ACTIVE="no"
if [ "$INSTALL_ALL" = "yes" ] || is_harness_installed cursor; then
  CURSOR_ACTIVE="yes"
  echo "  - cursor: ~${CURSOR_HOOKS_FILE#"$HOME"} (sessionStart hook that injects the file into every session)"
fi
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
  for target in ${ACTIVE_INSTRUCTION_FILES[@]+"${ACTIVE_INSTRUCTION_FILES[@]}"}; do
    path="${target#*:}"
    mkdir -p "$(dirname "$path")"
    safe_link "$GLOBAL_AGENTS_FILE" "$path" "${target%%:*}"
    echo "  ✓ ~${path#"$HOME"} -> $GLOBAL_AGENTS_FILE"
  done
  if [ "$CURSOR_ACTIVE" = "yes" ]; then
    register_cursor_hook "$CURSOR_HOOK_SCRIPT"
    if cursor_hook_registered "$CURSOR_HOOK_SCRIPT"; then
      echo "  ✓ ~${CURSOR_HOOKS_FILE#"$HOME"} sessionStart -> $CURSOR_HOOK_SCRIPT"
    fi
  fi
else
  echo "  Global instructions not linked (existing configurations preserved)."
fi

echo ""
if [ "$AI_SKILLS_BACKED_UP" -eq 1 ]; then
  echo "📦 Replaced content was safely moved to: $AI_SKILLS_BACKUP_DIR"
fi
echo "✅ Done!"
