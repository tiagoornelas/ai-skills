#!/usr/bin/env bash
# ==============================================================================
# scripts/setup-global.sh
# Vincula globalmente as skills e instruções do ai-skills aos harnesses:
# - Claude Code   (~/.claude)
# - Antigravity   (~/.gemini/config)
# - Codex         (~/.codex)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
AGENTS_FILE="$REPO_ROOT/AGENTS.md"

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
    ln -sfn "$skill_path" "$CLAUDE_SKILLS_DIR/$skill_name"
    ln -sfn "$skill_path" "$GEMINI_SKILLS_DIR/$skill_name"
    ln -sfn "$skill_path" "$CODEX_SKILLS_DIR/$skill_name"
    count=$((count + 1))
  fi
done

if [ "$count" -eq 0 ]; then
  echo "  (Nenhuma skill encontrada em $SKILLS_DIR ainda. Quando adicionar novas pastas de skills, execute este script novamente para vinculá-las automaticamente)."
else
  echo "  ✓ $count skill(s) vinculada(s) com sucesso!"
fi

# 3. Opção de vincular AGENTS.md como instrução global
echo ""
echo "⚙️ Configuração de Instruções Globais (AGENTS.md):"
echo "  Deseja vincular $AGENTS_FILE como instrução global?"
echo "  - Claude Code: ~/.claude/CLAUDE.md"
echo "  - Antigravity: ~/.gemini/config/AGENTS.md"
echo "  - Codex:       ~/.codex/AGENTS.md"
echo ""

read -p "Deseja criar os links simbólicos de instruções globais agora? [s/N]: " -r response || response="n"
if [[ "$response" =~ ^([sS][iI][mM]|[sS])$ ]]; then
  # Claude Code
  if [ -f "$HOME/.claude/CLAUDE.md" ] && [ ! -L "$HOME/.claude/CLAUDE.md" ]; then
    echo "  [backup] ~/.claude/CLAUDE.md existente -> ~/.claude/CLAUDE.md.bak"
    cp "$HOME/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md.bak"
  fi
  ln -sfn "$AGENTS_FILE" "$HOME/.claude/CLAUDE.md"
  echo "  ✓ Link criado: ~/.claude/CLAUDE.md -> $AGENTS_FILE"

  # Antigravity / Gemini CLI
  mkdir -p "$HOME/.gemini/config"
  if [ -f "$HOME/.gemini/config/AGENTS.md" ] && [ ! -L "$HOME/.gemini/config/AGENTS.md" ]; then
    echo "  [backup] ~/.gemini/config/AGENTS.md existente -> ~/.gemini/config/AGENTS.md.bak"
    cp "$HOME/.gemini/config/AGENTS.md" "$HOME/.gemini/config/AGENTS.md.bak"
  fi
  ln -sfn "$AGENTS_FILE" "$HOME/.gemini/config/AGENTS.md"
  echo "  ✓ Link criado: ~/.gemini/config/AGENTS.md -> $AGENTS_FILE"

  # Codex
  if [ -f "$HOME/.codex/AGENTS.md" ] && [ ! -L "$HOME/.codex/AGENTS.md" ]; then
    echo "  [backup] ~/.codex/AGENTS.md existente -> ~/.codex/AGENTS.md.bak"
    cp "$HOME/.codex/AGENTS.md" "$HOME/.codex/AGENTS.md.bak"
  fi
  ln -sfn "$AGENTS_FILE" "$HOME/.codex/AGENTS.md"
  echo "  ✓ Link criado: ~/.codex/AGENTS.md -> $AGENTS_FILE"
else
  echo "  Links de instruções globais ignorados (suas configurações globais atuais foram preservadas)."
fi

echo ""
echo "✅ Concluído!"
