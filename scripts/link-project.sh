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

> Instruções de desenvolvimento e governança para agentes de IA neste projeto.

---

## 1. Visão Geral do Projeto
- Stack tecnológica e escopo do projeto.

---

## 2. Comandos Frequentes
- Instalação: `npm install` (ou equivalente)
- Testes: `npm test`
- Lint: `npm run lint`

---

## 3. Diretrizes Operacionais
- Respostas concisas e estruturadas.
- Verifique testes antes de concluir tarefas.
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

# Claude Code lê localmente em .claude/skills
mkdir -p "$TARGET_DIR/.claude"
ln -sfn "$SKILLS_DIR" "$TARGET_DIR/.claude/skills"
echo "  ✓ Claude Code: $TARGET_DIR/.claude/skills -> $SKILLS_DIR"

# Antigravity CLI e Codex leem localmente em .agents/skills
mkdir -p "$TARGET_DIR/.agents"
ln -sfn "$SKILLS_DIR" "$TARGET_DIR/.agents/skills"
echo "  ✓ Antigravity / Codex: $TARGET_DIR/.agents/skills -> $SKILLS_DIR"

echo ""
echo "✅ Projeto configurado com sucesso!"
echo "   - Claude Code, Codex e Antigravity CLI agora compartilham as instruções de AGENTS.md."
echo "   - Ambos têm acesso às skills de $SKILLS_DIR."
