# AGENTS.md

> Diretrizes e instruções operacionais do repositório **ai-skills** (Hub Central de Skills e Regras Multi-Harness).

---

## 1. Identidade e Propósito do Repositório

Este repositório centraliza:
1. **Skills reutilizáveis (`skills/`)**: Procedimentos e runbooks sob demanda em formato universal (`SKILL.md`), consumidos por Claude Code, Antigravity CLI e Codex.
2. **Modelos e Governança de Agentes (`AGENTS.md`)**: Diretrizes operacionais e regras de contexto compartilhadas entre múltiplos harnesses.
3. **Scripts de Automação (`scripts/`)**: Ferramentas para vincular (via symlinks) as regras e skills aos ambientes locais de desenvolvimento.

---

## 2. Princípios Operacionais Globais

Todo agente operando neste repositório (ou em repositórios configurados a partir dele) deve seguir estes princípios:

- **Comunicação Concisa e Estruturada**: Priorize respostas diretas, estruturadas com tópicos, tabelas e blocos de código. Evite prolixidade.
- **Single Source of Truth (SSOT)**: `AGENTS.md` é o arquivo primário de regras. Adaptações para harnesses específicos (ex.: `CLAUDE.md`, `GEMINI.md`) devem apontar para o `AGENTS.md` via symlinks ou diretivas de inclusão.
- **Agnosticismo de Harness**: As instruções e skills devem ser descritas de forma portável, evitando dependências rígidas de um único motor quando houver equivalentes diretos (ex.: ferramentas de subagentes).
- **Segurança e Não-Destrutividade**: Sempre preserve dados do usuário, não execute comandos destrutivos sem verificação e respeite arquivos existentes.
- **Formatação de Arquivos**: Ao referenciar arquivos no Markdown, use links formatados (ex.: `[README.md](README.md)`).

---

## 3. Padrão de Autoria de Skills (`skills/`)

Ao criar ou atualizar skills neste repositório:

### 3.1. Estrutura de Diretórios
```text
skills/<nome-da-skill>/
├── SKILL.md            # [Obrigatório] Instruções principais com YAML frontmatter
├── scripts/            # [Opcional] Scripts utilitários executáveis
├── references/         # [Opcional] Documentação aprofundada carregada sob demanda
└── resources/          # [Opcional] Templates, dados e ativos estáticos
```

### 3.2. Frontmatter Obrigatório no `SKILL.md`
```markdown
---
name: nome-da-skill
description: >-
  Descrição em 3ª pessoa explicando o que a skill faz e exatamente quando
  o agente deve ativá-la.
---
```

### 3.3. Boas Práticas para Skills
- **Progressive Disclosure**: Mantenha o `SKILL.md` conciso e focado nas decisões/passos essenciais. Delegue referências extensas para arquivos em `references/`.
- **Nomes Padronizados**: Use `kebab-case` para nomes de pastas e skills (ex.: `code-review`, `deploy-helper`).
- **Validação de Sucesso**: Toda skill deve orientar o agente em como verificar se os passos foram executados com êxito.

---

## 4. Subagentes e Delegação

- Quando um fluxo exigir trabalho em segundo plano ou contexto isolado, utilize a ferramenta de subagentes disponível no harness atual:
  - **Antigravity CLI**: `invoke_subagent` (com `TypeName: "self"` ou tipo específico).
  - **Claude Code**: Ferramenta `Agent` (com tipo `general-purpose`).
  - **Codex**: Execução em sub-processo / thread isolada.
- O contexto e os requisitos devem ser passados integralmente e sem perda de fidelidade (*ipsis litteris*).

---

## 5. Governança e Ciclo de Vida do Desenvolvimento

- **Divisão de Responsabilidades (Human Layer vs. Agent Layer)**: Siga rigorosamente os princípios de [`ai-assisted-software-development`](skills/ai-assisted-software-development/SKILL.md).
- **Desenho / Design de Software**: É **obrigatório** utilizar a skill [`software-designing`](skills/software-designing/SKILL.md) para modelagem, fronteiras e contratos.
- **Implementação de Código**: É **obrigatório** utilizar a skill [`coding`](skills/coding/SKILL.md) para escrita, testes e refatoração.
- **Portão Autônomo de Qualidade**: O agente deve rodar obrigatoriamente [`agent-self-review`](skills/agent-self-review/SKILL.md) e corrigir seus próprios achados até obter aprovação (*clean*) antes de submeter ao humano.
- **Revisão Humana de Alto Nível**: Utilize [`human-review`](skills/human-review/SKILL.md) sempre que o humano solicitar revisão da entrega, focando exclusivamente na camada de governança humana.


