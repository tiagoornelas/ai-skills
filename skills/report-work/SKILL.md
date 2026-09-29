---
name: report-work
description: >-
  Entende o trabalho que o usuário está fazendo ou já fez (conversa, commits,
  diffs, branches, PRs) e o reporta como tarefas concisas, com título e
  descrição, por padrão em PT-BR, opcionalmente organizadas em contextos/épicos,
  tarefas pai e relacionamentos. É agnóstica de ferramenta: prepara as tarefas e
  para, aguardando o usuário instruir onde e como salvá-las (Jira, GitHub,
  Linear, arquivo etc.). Deve ser acionada quando o usuário pedir para reportar,
  registrar, documentar ou transformar em tarefas um trabalho feito ou em
  andamento, inteiro ou uma fatia dele.
argument-hint: "[fatia do trabalho a reportar — por padrão, o trabalho da conversa atual]"
---

# Report Work

Inverte a ordem habitual de criação de tarefas: **primeiro se trabalha para entender o que de fato precisa ser feito, depois se reporta o trabalho como tarefas.** Tarefas escritas depois do trabalho descrevem a realidade, não uma suposição.

---

## 1. Princípio Fundamental

> A skill **entende e redige**; o usuário **decide onde e como salvar**.

- **Agnóstica de ferramenta**: o resultado é um conjunto neutro de tarefas. Nenhum campo, status ou convenção específica de ferramenta entra antes de o usuário pedir.
- **Não salva nada sozinha**: depois de apresentar as tarefas, a skill para e aguarda a instrução de destino.
- **Relata o que existe**: toda tarefa se apoia em evidência (conversa, commit, diff, PR). Nada é inventado para "completar" o conjunto.

---

## 2. Fluxo de Trabalho

### Passo 1: Delimitar a fatia
Determine **qual trabalho** será reportado:
1. **Alvo explícito no prompt** (ex.: "só a parte de autenticação", "o que fiz nesta branch", "o PR #42") → use-o.
2. **Sem alvo explícito** → use o trabalho discutido e realizado **na conversa atual**.
3. **Ambíguo** (a conversa cobre vários trabalhos sem relação, ou não há trabalho na conversa) → pergunte qual fatia reportar, oferecendo as opções que você identificou.

Declare em uma linha a fatia escolhida antes de seguir.

### Passo 2: Reunir evidências
Leia só o necessário para a fatia:
- **Conversa**: objetivos, decisões tomadas, problemas encontrados, o que ficou pendente.
- **Git**: `git log <base>..HEAD --oneline`, `git diff <base>...HEAD --stat` e o diff dos trechos relevantes; branches envolvidas.
- **PRs/issues** (se houver): título, descrição e issues vinculadas (ex.: `gh pr view`).
- **Arquivos** tocados, quando o diff sozinho não explica a intenção.

### Passo 3: Entender o trabalho
Antes de escrever, responda para si:
- Qual **problema ou objetivo** motivou o trabalho?
- Quais **resultados observáveis** ele entrega (comportamentos, capacidades, correções)?
- O que foi **concluído**, o que está **em andamento** e o que ficou **pendente**, descoberto durante o trabalho?
- Existem **agrupamentos naturais** (um objetivo maior com várias partes)?

### Passo 4: Recortar em tarefas
- **Uma tarefa = um resultado verificável**, que faz sentido sozinho para quem vai ler na ferramenta. Recorte por **resultado entregue**, não por arquivo, camada ou commit.
- Commits pequenos do mesmo resultado se fundem numa tarefa; um commit que entrega dois resultados distintos se divide.
- **Trabalho descoberto e não feito** (dívida, bug encontrado, próximo passo) vira tarefa com status *A fazer*: é justamente o valor de trabalhar antes de reportar.
- Não crie tarefas para higiene mecânica sem valor próprio (formatação, renomear variável) salvo pedido do usuário. Isso fica dentro da tarefa que a motivou.

### Passo 5: Organizar hierarquia e relações (quando fizer sentido)
- **Contexto/Épico**: use quando as tarefas servem a um objetivo maior comum. Se o usuário indicar um épico existente, associe a ele em vez de criar um novo.
- **Tarefa pai → subtarefas**: use quando um resultado é grande demais para uma tarefa, mas suas partes não são épicos.
- **Relações entre tarefas**: `bloqueia` / `é bloqueada por`, `relacionada a`, `duplica`.
- Use **chaves temporárias** (`E1`, `T1`, `T1.1`) para expressar relações antes de existirem IDs reais.
- Sem agrupamento natural → lista plana. **Não force hierarquia.**

### Passo 6: Redigir
Siga o formato da seção 3 e as regras da seção 4.

### Passo 7: Apresentar e aguardar
Apresente as tarefas e **pare**. Termine perguntando como o usuário quer salvá-las, por exemplo: em qual ferramenta, projeto, épico existente, tipos de issue, labels, responsável, sprint ou formato de arquivo.

Ajustes pedidos pelo usuário (fundir, dividir, reescrever, mudar hierarquia) são aplicados e o conjunto é reapresentado até ele aprovar.

### Passo 8: Salvar conforme instrução
Quando o usuário instruir o destino:
- Se existir uma skill específica para a ferramenta (ex.: uma skill de uso do Jira), carregue-a e siga suas regras.
- **Confirme antes de escrever** em qualquer sistema externo: mostre o que será criado, onde, e com quais campos.
- Crie na ordem que as relações exigem (épico → pai → subtarefas → vínculos), substituindo as chaves temporárias pelos IDs reais.
- Reporte ao final a tabela `chave temporária → ID/link real`.

---

## 3. Formato de Saída

```markdown
## Fatia reportada
<uma linha: o que foi considerado e de onde veio a evidência>

## E1 — <título do contexto/épico>          ← só se houver agrupamento
<1–2 frases: objetivo comum das tarefas>

### T1 — <título da tarefa>
**Status:** Concluída | Em andamento | A fazer
**Pai:** E1        **Relações:** bloqueia T2   ← omitir linhas vazias

**Contexto:** <por que esta tarefa existe — problema ou objetivo, 1–2 frases>

**Escopo:** <o que foi (ou será) feito, em termos de resultado — 1–3 frases ou poucos tópicos>

**Critérios de aceite:**
- <comportamento observável e verificável>
- <...>

**Observações:** <decisões relevantes, riscos, pendências — opcional>

#### T1.1 — <subtarefa>                      ← só se houver
...
```

Após as tarefas:

```markdown
## Resumo
| Chave | Título | Tipo | Status | Pai | Relações |

**Como deseja salvar estas tarefas?** (ferramenta, projeto, épico existente, campos, formato…)
```

---

## 4. Regras de Redação

- **Idioma**: PT-BR por padrão; siga outro idioma se o usuário pedir. Termos técnicos e identificadores ficam no original.
- **Título**: imperativo e específico, até ~70 caracteres, dizendo o resultado (ex.: *"Permitir login com conta Google"*, *"Corrigir cálculo de juros em parcelas atrasadas"*). Sem prefixos de tipo, chaves ou emojis.
- **Descrição concisa**: quem lê deve entender a tarefa em menos de um minuto. Corte tudo que não ajuda a entender o porquê, o quê ou como verificar.
- **Resultado, não implementação**: descreva comportamentos e capacidades (Camada Humana). Detalhes internos (nomes de funções privadas, estrutura de pastas) só entram se forem essenciais para entender a tarefa.
- **Critérios de aceite verificáveis**: cada um é algo que alguém pode checar. Para tarefas concluídas, descrevem o que foi entregue; para tarefas a fazer, o que define "pronto".
- **[sem referências locais](../ai-assisted-software-development/references/no-local-references.md)**. Links para PRs, commits e issues públicos são bem-vindos.
- **Sem inventar**: se uma informação necessária não está nas evidências (ex.: o motivo de negócio), pergunte ou deixe explícito como pendente, em vez de supor.
- **Status honesto**: *Concluída* só com evidência de que foi entregue; na dúvida, *Em andamento*.

---

## 5. Validação de Sucesso

- [ ] A fatia reportada foi declarada e corresponde ao pedido (ou ao contexto da conversa, sem alvo explícito).
- [ ] Toda tarefa tem título, status, contexto, escopo e critérios de aceite verificáveis, e se apoia em evidência real.
- [ ] Cada tarefa representa um resultado único e verificável, sem tarefas por arquivo ou por commit.
- [ ] Trabalho descoberto e pendente foi capturado como *A fazer*.
- [ ] Hierarquia e relações só existem onde há agrupamento natural, e todas as chaves temporárias referenciadas existem.
- [ ] Nenhum campo ou convenção específica de ferramenta foi assumido antes da instrução do usuário.
- [ ] Nada foi salvo em sistema externo sem instrução e confirmação explícitas.
