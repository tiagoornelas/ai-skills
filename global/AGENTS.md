# Instruções Globais

> Regras de trabalho que valem em **qualquer projeto**, para qualquer agente (Claude Code, Codex, Antigravity CLI). Instaladas como instrução global pelo `setup-global.sh` do repositório **ai-skills**.
>
> As skills citadas abaixo são referenciadas **pelo nome**: estão instaladas na pasta de skills do harness. O `AGENTS.md` do projeto em que você está trabalhando complementa estas regras e, em caso de conflito, prevalece.

---

## 1. Como reportar ao usuário

- **Resposta primeiro, detalhes depois.**
- **Conciso e visual**: prefira estrutura (tópicos, tabelas curtas, títulos, blocos de código) a parágrafos longos.
- **Frases curtas e completas**: não sacrifique gramática nem clareza pela brevidade.

---

## 2. Princípios de trabalho

- **Segurança e não-destrutividade**: preserve os dados do usuário, não execute comandos destrutivos sem verificar o alvo antes e respeite arquivos existentes.
- **Links formatados**: ao citar arquivos em Markdown, use links (ex.: `[README.md](README.md)`).
- **Sem referências locais em artefatos compartilhados**: commits, PRs, comentários de revisão, issues e relatórios nunca citam caminhos que o leitor não consegue abrir (caminhos da máquina, `docs/tickets/`, `docs/prd/`, arquivos no `.gitignore`). Use a issue vinculada ou reescreva a informação. Detalhes na referência `no-local-references` da skill `ai-assisted-software-development`.

---

## 3. Governança do desenvolvimento

A divisão de trabalho segue a skill `ai-assisted-software-development`: o humano governa módulos, fronteiras, direção das dependências, contratos e comportamentos (**Camada Humana**); o agente responde por tudo abaixo dos contratos (**Camada do Agente**).

| Gatilho | Ação obrigatória |
| :--- | :--- |
| Antes de decidir módulos, fronteiras, interfaces, contratos ou a direção das dependências | Carregue `software-designing`. |
| Antes de fixar uma decisão de design cara de mudar depois | Passe por `design-it-twice`. |
| **Antes de criar, editar, testar ou refatorar qualquer arquivo de código** | **Carregue `coding`**, mesmo numa mudança pequena. |
| Antes de entregar código ao humano | Rode `agent-self-review` e corrija os achados até o veredito limpo. |
| Quando o humano pedir revisão da entrega | Use `human-review`, só na Camada Humana. |
| Antes de qualquer commit | Use `commit`. |

---

## 4. Subagentes e delegação

- Quando um fluxo exigir trabalho em segundo plano ou contexto isolado, use a ferramenta de subagentes do harness atual:
  - **Claude Code**: ferramenta `Agent`, com tipo `general-purpose`.
  - **Antigravity CLI**: `invoke_subagent`, com `TypeName: "self"` ou um tipo específico.
  - **Codex**: sub-processo ou thread isolada.
- Passe o contexto e os requisitos **integralmente**, sem perda de fidelidade (*ipsis litteris*).
- Caminhos de skills citados num brief vão como **caminhos absolutos**: o subagente roda na pasta do projeto, não na pasta das skills. Detalhes na referência `subagent-delegation` da skill `ai-assisted-software-development`.
