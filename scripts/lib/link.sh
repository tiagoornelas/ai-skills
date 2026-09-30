#!/usr/bin/env bash
# ==============================================================================
# scripts/lib/link.sh
# Shared linking functions used by ai-skills scripts.
# Usage: source "$SCRIPT_DIR/lib/link.sh"
#
# Rationale: `ln -sfn <source> <target>` only replaces the target when it is
# a symlink. If the target is an existing real directory, the symlink is created
# INSIDE it (e.g., ~/.claude/skills/commit/commit), and the old version continues to be read.
# ==============================================================================

# Global destinations, shared by setup-global.sh and uninstall-global.sh.
# Each entry is "<label>:<path>"; the label names the harness and its folder
# inside the backup.
GLOBAL_SKILL_DIRS=(
  "claude:$HOME/.claude/skills"
  "gemini:$HOME/.gemini/config/skills"
  "codex:$HOME/.codex/skills"
)
GLOBAL_INSTRUCTION_FILES=(
  "claude:$HOME/.claude/CLAUDE.md"
  "gemini:$HOME/.gemini/config/AGENTS.md"
  "gemini:$HOME/.gemini/GEMINI.md"
  "codex:$HOME/.codex/AGENTS.md"
)

# Directory where replaced real content is backed up, outside skill folders,
# so no harness accidentally loads the backup copy as an active skill.
# Layout: <root>/<timestamp>/<label>/<name>, one timestamp per setup run.
AI_SKILLS_BACKUP_ROOT="$HOME/.ai-skills-backup"
AI_SKILLS_BACKUP_DIR="${AI_SKILLS_BACKUP_DIR:-$AI_SKILLS_BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)}"
# Set to 1 when any file or folder was moved to backup during this execution.
AI_SKILLS_BACKED_UP=0

# safe_link <source> <target> <backup-label>
# - non-existent target or symlink: creates/updates the symlink;
# - real target (directory or file): moves to backup, then creates the symlink.
safe_link() {
  local src="$1" dest="$2" label="$3"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    local backup="$AI_SKILLS_BACKUP_DIR/$label/$(basename "$dest")"
    mkdir -p "$(dirname "$backup")"
    mv "$dest" "$backup"
    echo "     [backup] $dest -> $backup"
    AI_SKILLS_BACKED_UP=1
  fi

  ln -sfn "$src" "$dest"
}

# prune_dangling_links <directory> <source-prefix>
# Removes broken symlinks pointing to <source-prefix>
# (e.g., skills removed or renamed in the repository).
prune_dangling_links() {
  local dir="$1" prefix="$2" entry target
  [ -d "$dir" ] || return 0

  for entry in "$dir"/* "$dir"/.[!.]*; do
    [ -L "$entry" ] || continue
    [ -e "$entry" ] && continue
    target="$(readlink "$entry")"
    case "$target" in
      "$prefix"/*)
        rm "$entry"
        echo "     [removed] dangling link: $entry"
        ;;
    esac
  done
}

# backup_original_path <label> <name>: where safe_link found an item before
# moving it to <backup>/<label>/<name>. Prints nothing for an unknown label.
backup_original_path() {
  local label="$1" name="$2" target
  for target in "${GLOBAL_INSTRUCTION_FILES[@]}"; do
    if [ "${target%%:*}" = "$label" ] && [ "$(basename "${target#*:}")" = "$name" ]; then
      echo "${target#*:}"
      return 0
    fi
  done
  for target in "${GLOBAL_SKILL_DIRS[@]}"; do
    if [ "${target%%:*}" = "$label" ]; then
      echo "${target#*:}/$name"
      return 0
    fi
  done
}

# for_each_backup <callback>: calls `<callback> <item> <original-path>` for
# every backed-up item, newest backup first, so the latest version of a path
# comes before older ones.
for_each_backup() {
  local callback="$1" stamps=("$AI_SKILLS_BACKUP_ROOT"/*/) i label_dir item dest
  for ((i = ${#stamps[@]} - 1; i >= 0; i--)); do
    for label_dir in "${stamps[$i]}"*/; do
      [ -d "$label_dir" ] || continue
      for item in "$label_dir"* "$label_dir".[!.]*; do
        [ -e "$item" ] || [ -L "$item" ] || continue
        dest="$(backup_original_path "$(basename "$label_dir")" "$(basename "$item")")"
        if [ -n "$dest" ]; then
          "$callback" "$item" "$dest"
        fi
      done
    done
  done
}

# prune_empty_backups: removes backup folders emptied by a restore.
prune_empty_backups() {
  local dir
  for dir in "$AI_SKILLS_BACKUP_ROOT"/*/*/ "$AI_SKILLS_BACKUP_ROOT"/*/; do
    rmdir "$dir" 2>/dev/null || true
  done
  rmdir "$AI_SKILLS_BACKUP_ROOT" 2>/dev/null || true
}
