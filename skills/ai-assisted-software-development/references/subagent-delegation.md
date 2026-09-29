# Delegação a Subagentes

> **Tese central**: um subagente só enxerga o que o brief entrega. Ele não herda a conversa, não herda o contexto de quem o criou e **não sabe onde as skills estão instaladas**. Todo brief precisa ser autossuficiente.

---

## Quando consultar

- Sempre que uma skill mandar criar subagentes (trabalho em paralelo, contexto isolado, busca em segundo plano).
- Ao escrever um brief que manda o subagente ler uma skill ou uma referência.

---

## 1. A ferramenta de cada harness

| Harness | Como criar um subagente |
| :--- | :--- |
| **Claude Code** | Ferramenta `Agent`, com tipo `general-purpose`. Várias chamadas na mesma mensagem rodam em paralelo. |
| **Antigravity CLI** | `invoke_subagent`, com `TypeName: "self"` ou um tipo específico. |
| **Codex** | Um sub-processo ou thread isolada por tarefa. |

Em outro harness, use a ferramenta equivalente. Sem nenhuma, execute as tarefas em sequência no contexto atual e diga isso.

---

## 2. Contexto integral

Passe ao subagente o contexto e os requisitos **integralmente, sem perda de fidelidade** (*ipsis litteris*): especificação, decisões já tomadas, restrições, a escala de severidade ou o formato de entrega que a skill define. Resumir o contexto ao delegar é a forma mais comum de o subagente responder à pergunta errada.

---

## 3. Caminhos de skills no brief

As skills são instaladas fora do projeto (ex.: `~/.claude/skills/`), e o subagente roda na pasta do projeto. Um caminho como `agent-self-review/SKILL.md`, escrito no brief do jeito que aparece na skill, não resolve lá.

Antes de enviar o brief:

1. Localize a **pasta de skills**: é a pasta que contém a skill em execução (o diretório pai da pasta dela). Os links relativos das skills (`../<skill>/SKILL.md`) partem dela.
2. Nos briefs, `<skills>` representa essa pasta. Troque `<skills>` pelo **caminho absoluto** antes de enviar (ex.: `<skills>/coding/references/testing.md` → `/Users/<usuário>/.claude/skills/coding/references/testing.md`).
3. Confirme que os arquivos citados existem nesse caminho. Se algum não existir, não delegue às cegas: diga qual está faltando.

---

## 4. Validação

- [ ] A ferramenta usada é a do harness atual (ou a execução sequencial foi declarada).
- [ ] O brief carrega o contexto e os requisitos completos.
- [ ] Nenhum brief contém `<skills>` ou um caminho relativo de skill; todos os caminhos são absolutos e existem.
