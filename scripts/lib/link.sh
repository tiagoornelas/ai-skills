#!/usr/bin/env bash
# ==============================================================================
# scripts/lib/link.sh
# Funções de vínculo compartilhadas pelos scripts do ai-skills.
# Uso: source "$SCRIPT_DIR/lib/link.sh"
#
# Por que existe: `ln -sfn <origem> <destino>` só substitui o destino quando ele
# é um symlink. Se o destino é uma pasta real, o link é criado DENTRO dela
# (ex.: ~/.claude/skills/commit/commit), e a versão antiga continua sendo lida.
# ==============================================================================

# Pasta onde conteúdos reais substituídos são guardados, fora das pastas de
# skills, para que nenhum harness carregue a cópia de backup como skill.
AI_SKILLS_BACKUP_DIR="${AI_SKILLS_BACKUP_DIR:-$HOME/.ai-skills-backup/$(date +%Y%m%d-%H%M%S)}"
# Vira 1 quando algo foi movido para o backup nesta execução.
AI_SKILLS_BACKED_UP=0

# safe_link <origem> <destino> <rótulo-do-backup>
# - destino inexistente ou symlink: cria/atualiza o link;
# - destino real (pasta ou arquivo): move para o backup e cria o link.
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

# prune_dangling_links <pasta> <prefixo-de-origem>
# Remove symlinks quebrados que apontavam para <prefixo-de-origem>
# (ex.: skills removidas ou renomeadas no repositório).
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
        echo "     [removido] link quebrado: $entry"
        ;;
    esac
  done
}
