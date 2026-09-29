---
name: commit
description: >-
  Prepara e valida mensagens de commit padronizadas no formato Conventional Commits,
  obrigatoriamente em inglês, garantindo mensagens concisas, rastreáveis e sem referências locais.
---

# Commit

Produz mensagens de commit de alta qualidade que aderem estritamente às regras obrigatórias abaixo.

---

## 1. Regras Obrigatórias

Estas regras são inegociáveis e se aplicam a **todo** commit criado por Claude, Codex ou Antigravity.

- **Apenas Título por Padrão**: Na grande maioria dos casos, o título (primeira linha) é a mensagem inteira. Não adicione corpo. Não explique o "porquê" nem o "como", a menos que o usuário peça explicitamente.
- **Sem Chave de Tarefa no Título**: A primeira linha deve descrever o que foi feito, sem qualquer chave de issue ou tarefa (ex.: `DEV-1234`, `PROJ-56`). Se houver referência a uma issue, coloque-a isolada na terceira linha (após uma linha em branco).
- **Sem Referências Locais** ([no-local-references](../ai-assisted-software-development/references/no-local-references.md)): A referência de tarefa deve ser uma chave real (Jira, GitHub, Linear). Se não houver issue formal vinculada, omita a linha de referência.
- **Corpo É Exceção, Não Regra**: Adicione corpo apenas quando o usuário solicitar contexto adicional ou quando a alteração for impossível de compreender apenas pelo título (ex.: contorno não óbvio de um bug externo). Na dúvida, omita. Quando adicionado, deve ser um parágrafo único de **no máximo 3 linhas** — nunca mais.
- **Sem Listas ou Tópicos**: Nunca use marcadores (*bullet points*) ou listas no corpo do commit.
- **Mensagem Exclusivamente em Inglês**: Todas as mensagens de commit devem ser escritas em inglês (*English Only*).

---

## 2. Formato Conventional Commits

`<type>(<scope>): <short description>`

**Tipos:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`, `perf`, `ci`.

---

## 3. Estrutura da Mensagem

- **Padrão — apenas título:**
```text
<type>(<scope>): <description>
```

- **Com referência de tarefa isolada:**
```text
<type>(<scope>): <description>

TASK-123
```

- **Com corpo explicativo (quando estritamente justificado):**
```text
<type>(<scope>): <description>

TASK-123

<single paragraph, maximum 3 lines>
```

---

## 4. Commits de Correção do Self-Review

Correções feitas pelo agente em resposta ao [`agent-self-review`](../agent-self-review/SKILL.md) são **commits separados, sempre posteriores ao commit da implementação** — nunca aglutinados (*squashed*) nem emendados (*amended*). Essa separação permite ao leitor rastrear o que a revisão pegou e como o agente respondeu.

Esses commits são o único caso em que o corpo é **obrigatório**, pois a rastreabilidade é o objetivo central.

```text
<type>(<scope>): <what the fix does>

TASK-123

Self-review: <the review finding, in one line>
```

Regras específicas para estes commits:
- A última linha do corpo deve iniciar com o prefixo `Self-review:` seguido pelo achado que ela soluciona — um achado por linha, um commit por achado sempre que as correções forem separáveis.
- O título continua descrevendo a alteração em si, e não o ato de revisar: `fix(auth): reject expired tokens at the boundary`, e não `fix: address review comment`.
- Mantenha a linha `Self-review:` restrita ao achado. O raciocínio pertence ao relatório do review, não à mensagem do commit.

---

## 5. Aplicação e Validação

- Escreva a mensagem diretamente no comando `git commit -m`. Não a envolva em blocos de texto nem adicione comentários antes ou depois.
- Antes de commitar, valide deterministicamente a mensagem contra as regras (tamanho máximo de 72 caracteres no título, ausência de ponto final, ausência de listas/bullet points, estrutura de linhas). Se o script utilitário da skill estiver acessível no ambiente local, execute-o:
  ```bash
  <pasta-da-skill>/scripts/validate-msg.sh -m "<mensagem>"
  ```
  Se falhar, reformule a mensagem antes de efetuar o commit.

---

## 6. Validação de Sucesso

- [ ] A mensagem está escrita em inglês e segue o formato Conventional Commits `<type>(<scope>): <desc>`.
- [ ] O título tem até 72 caracteres, não termina com ponto e não inclui chave de issue.
- [ ] A referência de tarefa (se presente) está na linha 3, isolada entre linhas em branco.
- [ ] O corpo (se presente) possui no máximo 3 linhas e não contém listas ou marcadores.
- [ ] Commits de self-review possuem a linha final `Self-review: <achado>`.
- [ ] A validação passou sem rejeições antes da execução de `git commit`.
