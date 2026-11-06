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
  "cursor:$HOME/.cursor/skills"
)
GLOBAL_INSTRUCTION_FILES=(
  "claude:$HOME/.claude/CLAUDE.md"
  "gemini:$HOME/.gemini/config/AGENTS.md"
  "gemini:$HOME/.gemini/GEMINI.md"
  "codex:$HOME/.codex/AGENTS.md"
)
# Instruction paths an earlier setup linked and no harness reads. Setup removes
# its own links there; uninstall and restore still recognize them.
LEGACY_INSTRUCTION_FILES=(
  "cursor:$HOME/.cursor/rules/global.md"
)
# Cursor CLI reads no global rules file: setup registers a sessionStart hook
# here that injects global/AGENTS.md into every session.
CURSOR_HOOKS_FILE="$HOME/.cursor/hooks.json"
# Backup label of hooks.json. It is edited in place, never moved, so
# `uninstall --restore` must not move it back: the label maps to no path.
CURSOR_HOOKS_BACKUP_LABEL="cursor-hooks"

# is_harness_installed <label>
# Returns 0 (true) if the harness is installed or its base configuration directory exists.
is_harness_installed() {
  local harness="$1"
  case "$harness" in
    claude) command -v claude >/dev/null 2>&1 || [ -d "$HOME/.claude" ] ;;
    gemini) command -v agy >/dev/null 2>&1 || [ -d "$HOME/.gemini" ] ;;
    codex)  command -v codex >/dev/null 2>&1 || [ -d "$HOME/.codex" ] ;;
    cursor) command -v cursor-agent >/dev/null 2>&1 || command -v cursor >/dev/null 2>&1 || command -v agent >/dev/null 2>&1 || [ -d "$HOME/.cursor" ] ;;
    *) return 1 ;;
  esac
}

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
  for target in "${GLOBAL_INSTRUCTION_FILES[@]}" "${LEGACY_INSTRUCTION_FILES[@]}"; do
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

# cursor_hook_command <hook-script>: the command string setup registers, which
# also identifies setup's entry in hooks.json.
cursor_hook_command() {
  printf '"%s"' "$1"
}

# cursor_hook_registered <hook-script>: true when hooks.json holds setup's entry.
cursor_hook_registered() {
  [ -f "$CURSOR_HOOKS_FILE" ] && command -v jq >/dev/null 2>&1 &&
    jq -e --arg c "$(cursor_hook_command "$1")" \
      'any(.hooks.sessionStart[]?; .command == $c)' "$CURSOR_HOOKS_FILE" >/dev/null 2>&1
}

# cursor_hooks_writable: true when hooks.json is absent or a hooks object
# setup can edit (an object whose sessionStart, if any, is a list).
cursor_hooks_writable() {
  [ ! -e "$CURSOR_HOOKS_FILE" ] ||
    jq -e 'type == "object" and ((.hooks // {}) | type) == "object"
      and ((.hooks.sessionStart // []) | type) == "array"' "$CURSOR_HOOKS_FILE" >/dev/null 2>&1
}

# write_cursor_hooks <jq-filter> <hook-command>: applies the filter to
# hooks.json ({} when absent), writing through any symlink.
write_cursor_hooks() {
  local filter="$1" cmd="$2" tmp
  tmp="$(mktemp)"
  { if [ -e "$CURSOR_HOOKS_FILE" ]; then cat "$CURSOR_HOOKS_FILE"; else echo '{}'; fi; } |
    jq --arg c "$cmd" "$filter" > "$tmp"
  cat "$tmp" > "$CURSOR_HOOKS_FILE"
  rm -f "$tmp"
}

# register_cursor_hook <hook-script>: adds setup's sessionStart entry to
# hooks.json, keeping everything the user has there. The file is backed up
# before its first change.
register_cursor_hook() {
  local cmd
  cmd="$(cursor_hook_command "$1")"
  if ! command -v jq >/dev/null 2>&1; then
    echo "     [skipped] jq not found: add to $CURSOR_HOOKS_FILE a sessionStart hook running $cmd"
    return 0
  fi
  if cursor_hook_registered "$1"; then
    return 0
  fi
  if ! cursor_hooks_writable; then
    echo "     [skipped] $CURSOR_HOOKS_FILE is not a valid hooks file; left untouched"
    return 0
  fi
  mkdir -p "$(dirname "$CURSOR_HOOKS_FILE")"
  if [ -e "$CURSOR_HOOKS_FILE" ]; then
    local backup="$AI_SKILLS_BACKUP_DIR/$CURSOR_HOOKS_BACKUP_LABEL/hooks.json"
    mkdir -p "$(dirname "$backup")"
    cp "$CURSOR_HOOKS_FILE" "$backup"
    echo "     [backup] $CURSOR_HOOKS_FILE -> $backup"
    AI_SKILLS_BACKED_UP=1
  fi
  # A new file needs Cursor's schema version; an existing one keeps its own.
  # shellcheck disable=SC2016 # $c is a jq variable
  write_cursor_hooks 'if . == {} then {version: 1} else . end
    | .hooks.sessionStart = ((.hooks.sessionStart // []) + [{command: $c, timeout: 10}])' "$cmd"
}

# cursor_hooks_backed_up: true when some setup run backed up hooks.json, which
# register_cursor_hook does whenever the file existed before it.
cursor_hooks_backed_up() {
  local backup
  for backup in "$AI_SKILLS_BACKUP_ROOT"/*/"$CURSOR_HOOKS_BACKUP_LABEL"/hooks.json; do
    [ -e "$backup" ] && return 0
  done
  return 1
}

# unregister_cursor_hook <hook-script>: removes setup's entry from hooks.json,
# and the file itself when setup created it and nothing else is left in it.
unregister_cursor_hook() {
  local cmd
  cmd="$(cursor_hook_command "$1")"
  cursor_hook_registered "$1" || return 0
  # shellcheck disable=SC2016 # $c is a jq variable
  write_cursor_hooks '.hooks.sessionStart |= map(select(.command != $c))
    | if .hooks.sessionStart == [] then del(.hooks.sessionStart) else . end' "$cmd"
  if ! cursor_hooks_backed_up &&
    jq -e '. == {version: 1, hooks: {}}' "$CURSOR_HOOKS_FILE" >/dev/null 2>&1; then
    rm -f "$CURSOR_HOOKS_FILE"
  fi
}
