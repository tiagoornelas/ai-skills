#!/usr/bin/env bash
# ==============================================================================
# scripts/link-project.sh
# Links ai-skills instructions and/or skills to a target project.
# Usage:
#   ./scripts/link-project.sh /path/to/target-project
#   or running from inside the target project:
#   /path/to/ai-skills/scripts/link-project.sh .
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

# shellcheck source=lib/link.sh
source "$SCRIPT_DIR/lib/link.sh"

TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo "=========================================================="
echo "  ai-skills: Project Linker"
echo "  Source (ai-skills): $REPO_ROOT"
echo "  Target:             $TARGET_DIR"
echo "=========================================================="

if [ "$TARGET_DIR" = "$REPO_ROOT" ]; then
  echo "⚠️  Target directory is the ai-skills repository itself."
  echo "   This script is intended to configure OTHER projects/repositories."
  exit 1
fi

# 1. Project Rules (AGENTS.md as Single Source of Truth)
echo ""
echo "📄 1. Configuring Project Rules (SSOT)..."

if [ ! -f "$TARGET_DIR/AGENTS.md" ]; then
  echo "  -> AGENTS.md not found in target. Creating starter template..."
  cat <<'EOF' > "$TARGET_DIR/AGENTS.md"
# AGENTS.md

> Development and governance instructions for AI agents in this project.

---

## 1. Project Overview
- Tech stack and project scope.

---

## 2. Common Commands
- Setup: `npm install` (or equivalent)
- Tests: `npm test`
- Lint: `npm run lint`

---

## 3. Operational Guidelines
- Concise and structured responses.
- Verify tests before completing tasks.
EOF
  echo "  ✓ Created: $TARGET_DIR/AGENTS.md"
else
  echo "  ✓ AGENTS.md already exists in target project."
fi

# Link CLAUDE.md -> AGENTS.md
echo "  -> Pointing CLAUDE.md to AGENTS.md..."
(cd "$TARGET_DIR" && ln -sfn "AGENTS.md" "CLAUDE.md")
echo "  ✓ Created link: $TARGET_DIR/CLAUDE.md -> AGENTS.md"

# Link GEMINI.md -> AGENTS.md
echo "  -> Pointing GEMINI.md to AGENTS.md..."
(cd "$TARGET_DIR" && ln -sfn "AGENTS.md" "GEMINI.md")
echo "  ✓ Created link: $TARGET_DIR/GEMINI.md -> AGENTS.md"

# 2. Link Skills to Project
echo ""
echo "🧩 2. Configuring Project Access to Skills..."

# link_project_skills <project-skills-dir> <label>
# - non-existent or symlink: points entire folder to ai-skills/skills;
# - real directory (project has its own skills): preserves existing skills and
#   links each skill from ai-skills individually, without overwriting homonyms.
link_project_skills() {
  local dest="$1" label="$2" skill_path skill_name

  if [ ! -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$(dirname "$dest")"
    ln -sfn "$SKILLS_DIR" "$dest"
    echo "  ✓ $label: $dest -> $SKILLS_DIR"
    return
  fi

  echo "  -> $label: $dest already contains project-specific skills; linking individually..."
  for skill_path in "$SKILLS_DIR"/*; do
    [ -d "$skill_path" ] || continue
    skill_name="$(basename "$skill_path")"
    if [ -e "$dest/$skill_name" ] && [ ! -L "$dest/$skill_name" ]; then
      echo "     [preserved] existing project skill with same name: $dest/$skill_name"
      continue
    fi
    ln -sfn "$skill_path" "$dest/$skill_name"
  done
  prune_dangling_links "$dest" "$SKILLS_DIR"
  echo "  ✓ $label: ai-skills linked into $dest"
}

# Claude Code reads locally from .claude/skills
link_project_skills "$TARGET_DIR/.claude/skills" "Claude Code"

# Antigravity CLI and Codex read locally from .agents/skills
link_project_skills "$TARGET_DIR/.agents/skills" "Antigravity / Codex"

echo ""
echo "✅ Project configured successfully!"
echo "   - Claude Code, Codex, and Antigravity CLI now share instructions from AGENTS.md."
echo "   - All harnesses have access to skills from $SKILLS_DIR."
