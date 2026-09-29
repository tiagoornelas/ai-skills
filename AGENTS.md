# AGENTS.md

> Regras para manter o repositório **ai-skills** (Hub Central de Skills e Regras Multi-Harness).
>
> As regras de trabalho que valem em qualquer projeto (como reportar, princípios, governança do desenvolvimento e subagentes) estão em [`global/AGENTS.md`](global/AGENTS.md). Elas também valem aqui: siga as duas.

---

## 1. Identidade e Propósito do Repositório

Este repositório centraliza:
1. **Skills reutilizáveis ([`skills/`](skills/))**: procedimentos sob demanda em formato universal (`SKILL.md`), consumidos por Claude Code, Antigravity CLI e Codex.
2. **Instruções globais ([`global/AGENTS.md`](global/AGENTS.md))**: as regras de trabalho instaladas como instrução global nos três harnesses.
3. **Scripts de automação ([`scripts/`](scripts/))**: vinculam, via symlinks, as skills e as instruções globais aos ambientes locais.

---

## 2. Princípios de Manutenção

- **Single Source of Truth (SSOT)**: cada regra mora num lugar só. Regras de trabalho ficam em [`global/AGENTS.md`](global/AGENTS.md); regras compartilhadas entre skills ficam numa referência de skill e são ligadas por caminho relativo (ex.: `../ai-assisted-software-development/references/`). Arquivos específicos de harness (`CLAUDE.md`, `GEMINI.md`) apontam para o arquivo primário via symlink.
- **Agnosticismo de harness**: instruções e skills são portáveis, sem dependência rígida de um único motor quando existe equivalente direto (ex.: ferramentas de subagentes).
- **Skills autossuficientes**: uma skill nunca depende deste `AGENTS.md` nem de caminhos do repositório (`skills/...`); instalada globalmente, ela roda na pasta de outro projeto. Links entre skills são relativos à pasta de skills (`../<skill>/`).
- **Instruções globais citam skills pelo nome**, não por caminho: o arquivo é instalado em pastas diferentes em cada harness.

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

### 3.2. Frontmatter no `SKILL.md`

Campos obrigatórios:
```yaml
---
name: nome-da-skill
description: >-
  Descrição em 3ª pessoa explicando o que a skill faz e exatamente quando
  o agente deve ativá-la.
---
```

Campos opcionais reconhecidos pelos harnesses (usar quando aplicável):
- `argument-hint: "[dica]"`: dica visual do argumento esperado ao acionar a skill (ex.: `"[número/URL do PR]"`).
- `disable-model-invocation: true`: indica que a skill é restrita ao acionamento manual do humano via chat/comando, impedindo o acionamento autônomo pelo modelo.

### 3.3. Boas Práticas para Skills
- **Progressive Disclosure**: mantenha o `SKILL.md` conciso e focado nas decisões e passos essenciais. Delegue referências extensas para arquivos em `references/`.
- **Nomes Padronizados**: use `kebab-case` para nomes de pastas e skills (ex.: `code-review`, `deploy-helper`).
- **Pastas Limpas**: não crie pastas `references/` ou `scripts/` vazias sem arquivos reais.
- **Validação de Sucesso**: toda skill termina obrigatoriamente com uma seção de checklist orientando o agente sobre como verificar se os passos foram executados com êxito.
- **Depois de adicionar ou remover uma skill**, rode `./scripts/setup-global.sh`.
