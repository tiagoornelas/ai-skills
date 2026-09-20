# ai-skills

Hub central de **Skills** e diretrizes de **Agentes de IA** compartilhado entre **Claude Code**, **Antigravity CLI** e **Codex**.

O objetivo deste repositório é manter uma fonte única da verdade (**Single Source of Truth - SSOT**) para instruções operacionais e disponibilizar runbooks/skills modulares que podem ser consumidos por qualquer um dos harnesses.

---

## 📌 Como Funciona a Arquitetura

| Harness | Regras do Projeto (SSOT) | Skills no Projeto | Skills Globais |
| :--- | :--- | :--- | :--- |
| **Antigravity CLI** | `AGENTS.md` (nativo) ou `GEMINI.md` | `.agents/skills/` | `~/.gemini/config/skills/` |
| **Claude Code** | `CLAUDE.md` *(symlink → `AGENTS.md`)* | `.claude/skills/` | `~/.claude/skills/` |
| **Codex** | `AGENTS.md` (nativo) | `.agents/skills/` | `~/.codex/skills/` |

---

## 🚀 Como Apontar os Harnesses

### 1. Configuração Global (Recomendado)

Disponibiliza as skills deste repositório para serem usadas em qualquer terminal/sessão dos harnesses.

Execute o script de setup global:
```bash
./scripts/setup-global.sh
```

**O que o script faz:**
1. Cria symlinks de cada skill presente em `skills/` para:
   - `~/.claude/skills/<skill>`
   - `~/.gemini/config/skills/<skill>`
   - `~/.codex/skills/<skill>`
2. Pergunta se você deseja vincular o `AGENTS.md` deste repositório como instrução global padrão nos três ambientes (com backup automático dos arquivos existentes).

---

### 2. Configuração em um Projeto Específico

Para fazer um repositório existente usar as regras (`AGENTS.md`) e a pasta de skills deste repositório:

Execute o script apontando para a pasta do projeto:
```bash
./scripts/link-project.sh /caminho/para/seu-projeto
```
*(Ou entre no diretório do projeto e execute `/caminho/para/ai-skills/scripts/link-project.sh .`)*

**O que o script faz no projeto de destino:**
1. **Regras Unificadas:** Cria `AGENTS.md` base (se ainda não existir) e gera os symlinks `CLAUDE.md -> AGENTS.md` e `GEMINI.md -> AGENTS.md`.
2. **Acesso às Skills:** Aponta `.claude/skills` e `.agents/skills` diretamente para a pasta `skills/` deste repositório.

---

### 3. Configuração Manual (Passo a Passo)

Se preferir configurar manualmente sem usar os scripts:

#### Em outro projeto/repositório:
```bash
cd /caminho/para/seu-projeto

# 1. Vincular regras (CLAUDE.md e GEMINI.md lendo AGENTS.md)
ln -sfn AGENTS.md CLAUDE.md
ln -sfn AGENTS.md GEMINI.md

# 2. Vincular pasta de skills
mkdir -p .claude .agents
ln -sfn /caminho/para/ai-skills/skills .claude/skills
ln -sfn /caminho/para/ai-skills/skills .agents/skills
```

#### Globalmente na sua máquina:
```bash
AI_SKILLS_PATH="$HOME/Documents/dev/ai-skills"

# Vincular uma skill específica (exemplo: minha-skill)
ln -sfn "$AI_SKILLS_PATH/skills/minha-skill" ~/.claude/skills/minha-skill
ln -sfn "$AI_SKILLS_PATH/skills/minha-skill" ~/.gemini/config/skills/minha-skill
ln -sfn "$AI_SKILLS_PATH/skills/minha-skill" ~/.codex/skills/minha-skill
```

---

## 🛠️ Como Adicionar Novas Skills no Futuro

1. Crie uma nova pasta dentro de `skills/` seguindo a estrutura:
   ```text
   skills/<nome-da-skill>/
   ├── SKILL.md            # Obrigatório: YAML frontmatter + instruções
   ├── references/         # Opcional: Documentações aprofundadas
   └── scripts/            # Opcional: Scripts auxiliares
   ```
2. No arquivo `SKILL.md`, inclua o cabeçalho YAML obrigatório:
   ```markdown
   ---
   name: nome-da-skill
   description: >-
     O que a skill faz e exatamente quando o agente deve utilizá-la.
   ---

    # Nome da Skill
   Passo a passo e instruções para o agente...
   ```
3. Execute `./scripts/setup-global.sh` para disponibilizar a nova skill imediatamente para todos os harnesses configurados.

---

## 📝 Modelo Sugerido para `AGENTS.md` de Projetos

Ao criar ou personalizar o `AGENTS.md` em um projeto de software, utilize uma estrutura enxuta como esta:

```markdown
# AGENTS.md

> Instruções de desenvolvimento e governança para agentes de IA neste projeto.

---

## 1. Visão Geral do Projeto
- **Stack Tecnológica**: [ex.: TypeScript, Node.js, Next.js, Docker]
- **Objetivo**: [Breve descrição do produto/serviço]

---

## 2. Comandos Principais
- Instalar dependências: `npm install`
- Executar testes: `npm test`
- Linter / Formatador: `npm run lint`
- Ambiente dev: `npm run dev`

---

## 3. Diretrizes de Código e Governança
- Respostas concisas e estruturadas (priorize tabelas, listas e blocos de código).
- Validação contínua: Execute testes ou linter antes de considerar tarefas concluídas.
- Commits atômicos no imperativo (ex.: `feat: add user login endpoint`).
```

