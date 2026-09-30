#!/usr/bin/env bash
# ==============================================================================
# scripts/uninstall-global.sh
# Reverts setup-global.sh: removes the global skills and instructions it
# installed from this repository, whether as links or as copies. Anything else
# in the harness folders is left untouched.
#
# Usage:
#   ./scripts/uninstall-global.sh               # removes skills and instructions
#   ./scripts/uninstall-global.sh --restore     # also moves backed-up content back
#   ./scripts/uninstall-global.sh --skills-only # keeps the global instructions
#   ./scripts/uninstall-global.sh --dry-run     # prints what would change, changes nothing
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
GLOBAL_AGENTS_FILE="$REPO_ROOT/global/AGENTS.md"
BACKUP_ROOT="$HOME/.ai-skills-backup"

RESTORE=0
SKILLS_ONLY=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --restore)     RESTORE=1 ;;
    --skills-only) SKILLS_ONLY=1 ;;
    --dry-run)     DRY_RUN=1 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

# shellcheck source=lib/link.sh
source "$SCRIPT_DIR/lib/link.sh"

# links_into <path> <target>: true when <path> is a symlink to <target> or to
# anything under it. Dangling links count, so skills deleted from the repo are
# still recognized. setup-global.sh always links with absolute paths; a
# relative link is resolved from its own folder, and left alone if that fails.
links_into() {
  local path="$1" target="$2" dest
  [ -L "$path" ] || return 1
  dest="$(readlink "$path")"
  case "$dest" in
    /*) ;;
    *) dest="$(cd "$(dirname "$path")" 2>/dev/null && cd "$(dirname "$dest")" 2>/dev/null && pwd)/$(basename "$dest")" || return 1 ;;
  esac
  case "$dest" in
    "$target" | "$target"/*) return 0 ;;
    *) return 1 ;;
  esac
}

# copy_of <path> <source>: true when <path> is a real file or folder with the
# same content as <source>. Git Bash on Windows without symlink permission
# turns `ln -s` into a copy, so setup-global.sh leaves copies instead of links.
# An identical copy holds nothing of the user's, so it is safe to remove.
copy_of() {
  [ ! -L "$1" ] && [ -e "$1" ] && [ -e "$2" ] && diff -rq "$2" "$1" >/dev/null 2>&1
}

installed_by_setup() {
  links_into "$1" "$SKILLS_DIR" || links_into "$1" "$GLOBAL_AGENTS_FILE" ||
    copy_of "$1" "$SKILLS_DIR/$(basename "$1")" || copy_of "$1" "$GLOBAL_AGENTS_FILE"
}

removed=0
remove_entry() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [would remove] $1"
  else
    rm -rf -- "$1"
    echo "  [removed] $1"
  fi
  removed=$((removed + 1))
}

report_kept() {
  echo "  [kept] $1 (not from this repository, or edited since setup)"
}

remove_skills() {
  local dir="$1" entry
  [ -d "$dir" ] || return 0
  for entry in "$dir"/* "$dir"/.[!.]*; do
    if installed_by_setup "$entry"; then
      remove_entry "$entry"
    elif [ -e "$SKILLS_DIR/$(basename "$entry")" ]; then
      report_kept "$entry"
    fi
  done
}

# original_path <label> <name>: where setup-global.sh found an item before
# moving it to <backup>/<label>/<name>.
original_path() {
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

is_instruction_path() {
  local target
  for target in "${GLOBAL_INSTRUCTION_FILES[@]}"; do
    [ "${target#*:}" = "$1" ] && return 0
  done
  return 1
}

# A dry run changes nothing on disk, so it tracks what it would have done:
# a path still holding something setup installed counts as free, and a path it already
# restored counts as taken. One path per line.
dry_run_restored=""
path_is_free() {
  if [ "$DRY_RUN" -eq 1 ] && printf '%s' "$dry_run_restored" | grep -Fxq -- "$1"; then
    return 1
  fi
  if [ -e "$1" ] || [ -L "$1" ]; then
    if [ "$DRY_RUN" -eq 1 ] && installed_by_setup "$1"; then
      return 0
    fi
    return 1
  fi
  return 0
}

restore_item() {
  local item="$1" dest="$2"
  if ! path_is_free "$dest"; then
    echo "  [kept in backup] $item ($dest is in use)"
    return 0
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [would restore] $dest"
    dry_run_restored="$dry_run_restored$dest"$'\n'
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  mv "$item" "$dest"
  echo "  [restored] $dest"
}

# Walks backups newest first, so each path gets its latest backed-up version;
# older versions of an already restored path stay in the backup.
restore_backups() {
  local stamps=("$BACKUP_ROOT"/*/) i stamp target label item dest
  for ((i = ${#stamps[@]} - 1; i >= 0; i--)); do
    stamp="${stamps[$i]%/}"
    [ -d "$stamp" ] || continue
    for target in "${GLOBAL_SKILL_DIRS[@]}"; do
      label="${target%%:*}"
      for item in "$stamp/$label"/* "$stamp/$label"/.[!.]*; do
        [ -e "$item" ] || [ -L "$item" ] || continue
        dest="$(original_path "$label" "$(basename "$item")")"
        if [ "$SKILLS_ONLY" -eq 1 ] && is_instruction_path "$dest"; then
          continue
        fi
        restore_item "$item" "$dest"
      done
      [ "$DRY_RUN" -eq 1 ] || rmdir "$stamp/$label" 2>/dev/null || true
    done
    [ "$DRY_RUN" -eq 1 ] || rmdir "$stamp" 2>/dev/null || true
  done
  [ "$DRY_RUN" -eq 1 ] || rmdir "$BACKUP_ROOT" 2>/dev/null || true
}

echo "=========================================================="
echo "  ai-skills: Global Uninstall"
echo "  Repository: $REPO_ROOT"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "  Dry run: nothing will be changed."
fi
echo "=========================================================="

# 1. Skills
echo ""
echo "🔗 Removing skills..."
for target in "${GLOBAL_SKILL_DIRS[@]}"; do
  remove_skills "${target#*:}"
done

# 2. Global instructions
echo ""
if [ "$SKILLS_ONLY" -eq 1 ]; then
  echo "⚙️ Global instructions kept (--skills-only)."
else
  echo "⚙️ Removing global instructions..."
  for target in "${GLOBAL_INSTRUCTION_FILES[@]}"; do
    path="${target#*:}"
    if installed_by_setup "$path"; then
      remove_entry "$path"
    elif [ -e "$path" ] || [ -L "$path" ]; then
      report_kept "$path"
    fi
  done
fi

echo ""
if [ "$removed" -eq 0 ]; then
  echo "  Nothing installed from this repository was found."
elif [ "$DRY_RUN" -eq 1 ]; then
  echo "  ✓ Would remove $removed item(s)."
else
  echo "  ✓ Removed $removed item(s)."
fi

# 3. Backups made by setup-global.sh
if [ -d "$BACKUP_ROOT" ]; then
  echo ""
  if [ "$RESTORE" -eq 1 ]; then
    echo "📦 Restoring backed-up content from $BACKUP_ROOT..."
    restore_backups
  else
    echo "📦 Content replaced during setup is still in: $BACKUP_ROOT"
    echo "   Run with --restore to move it back."
  fi
fi

echo ""
echo "✅ Done!"
