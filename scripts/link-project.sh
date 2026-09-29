#!/usr/bin/env bash
# ==============================================================================
# scripts/link-project.sh
# Vincula as instruções e/ou skills do ai-skills a um projeto específico.
# Uso:
#   ./scripts/link-project.sh /caminho/para/outro-projeto
#   ou rodando de dentro do próprio projeto de destino:
#   /caminho/para/ai-skills/scripts/link-project.sh .
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
echo "  ai-skills: Linker de Projeto"
echo "  Origem (ai-skills): $REPO_ROOT"
echo "  Destino:            $TARGET_DIR"
echo "=========================================================="

if [ "$TARGET_DIR" = "$REPO_ROOT" ]; then
  echo "⚠️  O diretório de destino é o próprio repositório ai-skills."
  echo "   Este script serve para configurar OUTROS projetos/repositórios."
  exit 1
fi

# 1. Regras do Projeto (AGENTS.md como Single Source of Truth)
echo ""
echo "📄 1. Configurando Regras do Projeto (SSOT)..."

if [ ! -f "$TARGET_DIR/AGENTS.md" ]; then
  echo "  -> AGENTS.md não encontrado no destino. Criando arquivo base..."
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
  echo "  ✓ Criado: $TARGET_DIR/AGENTS.md"
else
  echo "  ✓ AGENTS.md já existe no projeto."
fi

# Link CLAUDE.md -> AGENTS.md
echo "  -> Apontando CLAUDE.md para AGENTS.md..."
(cd "$TARGET_DIR" && ln -sfn "AGENTS.md" "CLAUDE.md")
echo "  ✓ Link criado: $TARGET_DIR/CLAUDE.md -> AGENTS.md"

# Link GEMINI.md -> AGENTS.md
echo "  -> Apontando GEMINI.md para AGENTS.md..."
(cd "$TARGET_DIR" && ln -sfn "AGENTS.md" "GEMINI.md")
echo "  ✓ Link criado: $TARGET_DIR/GEMINI.md -> AGENTS.md"

# 2. Vínculo de Skills no Projeto
echo ""
echo "🧩 2. Configurando Acesso às Skills no Projeto..."

# link_project_skills <pasta-de-skills-do-projeto> <rótulo>
# - inexistente ou symlink: aponta a pasta inteira para ai-skills/skills;
# - pasta real (o projeto tem skills próprias): preserva as skills do projeto e
#   vincula cada skill do ai-skills dentro dela, sem sobrescrever homônimas.
link_project_skills() {
  local dest="$1" label="$2" skill_path skill_name

  if [ ! -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$(dirname "$dest")"
    ln -sfn "$SKILLS_DIR" "$dest"
    echo "  ✓ $label: $dest -> $SKILLS_DIR"
    return
  fi

  echo "  -> $label: $dest já tem skills próprias do projeto; vinculando uma a uma..."
  for skill_path in "$SKILLS_DIR"/*; do
    [ -d "$skill_path" ] || continue
    skill_name="$(basename "$skill_path")"
    if [ -e "$dest/$skill_name" ] && [ ! -L "$dest/$skill_name" ]; then
      echo "     [mantida] skill do projeto com o mesmo nome: $dest/$skill_name"
      continue
    fi
    ln -sfn "$skill_path" "$dest/$skill_name"
  done
  prune_dangling_links "$dest" "$SKILLS_DIR"
  echo "  ✓ $label: skills do ai-skills vinculadas em $dest"
}

# Claude Code lê localmente em .claude/skills
link_project_skills "$TARGET_DIR/.claude/skills" "Claude Code"

# Antigravity CLI e Codex leem localmente em .agents/skills
link_project_skills "$TARGET_DIR/.agents/skills" "Antigravity / Codex"

echo ""
echo "✅ Projeto configurado com sucesso!"
echo "   - Claude Code, Codex e Antigravity CLI agora compartilham as instruções de AGENTS.md."
echo "   - Ambos têm acesso às skills de $SKILLS_DIR."
