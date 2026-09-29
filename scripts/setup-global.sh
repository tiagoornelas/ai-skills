#!/usr/bin/env bash
# ==============================================================================
# scripts/setup-global.sh
# Vincula globalmente as skills e instruções do ai-skills aos harnesses:
# - Claude Code   (~/.claude)
# - Antigravity   (~/.gemini/config)
# - Codex         (~/.codex)
#
# Uso:
#   ./scripts/setup-global.sh                         # pergunta sobre as instruções globais
#   ./scripts/setup-global.sh --global-instructions   # vincula sem perguntar
#   ./scripts/setup-global.sh --skills-only           # só as skills
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
    *) echo "Opção desconhecida: $arg" >&2; exit 2 ;;
  esac
done

# shellcheck source=lib/link.sh
source "$SCRIPT_DIR/lib/link.sh"

# Destinos globais de skills
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
GEMINI_SKILLS_DIR="$HOME/.gemini/config/skills"
CODEX_SKILLS_DIR="$HOME/.codex/skills"

echo "=========================================================="
echo "  ai-skills: Setup Global de Skills e Agentes"
echo "  Repositório: $REPO_ROOT"
echo "=========================================================="

# 1. Garante que as pastas de destino existam
mkdir -p "$CLAUDE_SKILLS_DIR"
mkdir -p "$GEMINI_SKILLS_DIR"
mkdir -p "$CODEX_SKILLS_DIR"

# 2. Vincula skills individuais encontradas em ai-skills/skills/
echo ""
echo "🔗 Vinculando skills em ai-skills/skills/..."

count=0
for skill_path in "$SKILLS_DIR"/*; do
  [ -e "$skill_path" ] || continue
  skill_name="$(basename "$skill_path")"

  # Ignora arquivos de controle como .gitkeep
  if [[ "$skill_name" =~ ^\. ]]; then
    continue
  fi

  if [ -d "$skill_path" ]; then
    echo "  -> Vinculando skill: $skill_name"
    safe_link "$skill_path" "$CLAUDE_SKILLS_DIR/$skill_name" claude
    safe_link "$skill_path" "$GEMINI_SKILLS_DIR/$skill_name" gemini
    safe_link "$skill_path" "$CODEX_SKILLS_DIR/$skill_name" codex
    count=$((count + 1))
  fi
done

# Links para skills que saíram do repositório
prune_dangling_links "$CLAUDE_SKILLS_DIR" "$SKILLS_DIR"
prune_dangling_links "$GEMINI_SKILLS_DIR" "$SKILLS_DIR"
prune_dangling_links "$CODEX_SKILLS_DIR" "$SKILLS_DIR"

if [ "$count" -eq 0 ]; then
  echo "  (Nenhuma skill encontrada em $SKILLS_DIR ainda. Quando adicionar novas pastas de skills, execute este script novamente para vinculá-las automaticamente)."
else
  echo "  ✓ $count skill(s) vinculada(s) com sucesso!"
fi

# 3. Instruções globais (global/AGENTS.md)
echo ""
echo "⚙️ Instruções Globais ($GLOBAL_AGENTS_FILE):"
echo "  - Claude Code: ~/.claude/CLAUDE.md"
echo "  - Antigravity: ~/.gemini/config/AGENTS.md"
echo "  - Codex:       ~/.codex/AGENTS.md"
echo ""

if [ "$GLOBAL_INSTRUCTIONS" = "ask" ]; then
  if [ -t 0 ]; then
    read -p "Deseja vincular as instruções globais agora? [s/N]: " -r response || response="n"
    [[ "$response" =~ ^([sS][iI][mM]|[sS])$ ]] && GLOBAL_INSTRUCTIONS="yes" || GLOBAL_INSTRUCTIONS="no"
  else
    echo "  Terminal não interativo: rode com --global-instructions para vincular sem perguntar."
    GLOBAL_INSTRUCTIONS="no"
  fi
fi

if [ "$GLOBAL_INSTRUCTIONS" = "yes" ]; then
  mkdir -p "$HOME/.claude" "$HOME/.gemini/config" "$HOME/.codex"
  safe_link "$GLOBAL_AGENTS_FILE" "$HOME/.claude/CLAUDE.md" claude
  echo "  ✓ ~/.claude/CLAUDE.md -> $GLOBAL_AGENTS_FILE"
  safe_link "$GLOBAL_AGENTS_FILE" "$HOME/.gemini/config/AGENTS.md" gemini
  echo "  ✓ ~/.gemini/config/AGENTS.md -> $GLOBAL_AGENTS_FILE"
  safe_link "$GLOBAL_AGENTS_FILE" "$HOME/.codex/AGENTS.md" codex
  echo "  ✓ ~/.codex/AGENTS.md -> $GLOBAL_AGENTS_FILE"
else
  echo "  Instruções globais não vinculadas (as configurações atuais foram preservadas)."
fi

echo ""
if [ "$AI_SKILLS_BACKED_UP" -eq 1 ]; then
  echo "📦 Conteúdos substituídos foram guardados em: $AI_SKILLS_BACKUP_DIR"
fi
echo "✅ Concluído!"
