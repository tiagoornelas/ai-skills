---
name: github-code-review
description: >-
  Revisa o Pull Request de um colega no GitHub (ou um diff desde um ponto fixo)
  combinando os critérios do agent-self-review (ferramental, regras do projeto,
  cobertura da DoD, sanidade dos testes e qualidade do código) com os do human-review
  (módulos, direção de dependências, contratos e comportamentos). Os eixos rodam em
  subagentes paralelos. Depois a skill discute os achados com o usuário,
  recomenda aprovar ou pedir alterações e transforma os pontos aceitos em
  comentários em PT-BR prontos para colar no PR.
disable-model-invocation: true
argument-hint: "[número/URL do PR, branch, SHA ou ref base]"
---

# GitHub Code Review

Para revisar **o trabalho de outras pessoas**: o PR de um colega, ou qualquer diff desde um ponto fixo. A entrega não é a revisão em si; é **ajudar o usuário a decidir** (aprovar ou pedir alterações) e **a encontrar os pontos em que ele vai comentar**.

> Esta skill aplica ao código de um colega os mesmos critérios que o pipeline aplica ao próprio código: o rigor mecânico do [`agent-self-review`](../agent-self-review/SKILL.md) e a visão de governança do [`human-review`](../human-review/SKILL.md). A diferença é que aqui **nada é corrigido**: tudo vira achado, e o usuário escolhe o que comentar.

Quatro eixos, rodados como **subagentes paralelos** para que um não contamine o contexto do outro:

| Eixo | Origem | Pergunta |
| :--- | :--- | :--- |
| 🔧 **Qualidade e Regras** | `agent-self-review` fases 1–2 | O código passa no ferramental e segue as regras documentadas do projeto? |
| ✅ **Comportamentos e Testes** | `agent-self-review` fases 3–4 + tabela DoD do `human-review` | A mudança faz o que foi pedido, e cada comportamento está provado por teste que sobrevive a refatorações? |
| 🏗️ **Arquitetura e Contratos** | `human-review` + referências de `software-designing` | Módulos, fronteiras, direção das dependências e contratos estão sólidos? |
| 🧹 **Qualidade do Código** | `agent-self-review` fase 5 + referências de `coding` | O código novo, abaixo dos contratos, é fácil de ler e de mudar? |

---

## 1. Fixar o ponto de comparação

Use o que o usuário indicou: um PR, SHA, branch, tag, `main`, `HEAD~5`.

- **PR do GitHub**: `gh pr view <pr> --json number,title,body,baseRefName,headRefName,url,author` e `gh pr diff <pr>`. A base do PR é o ponto fixo.
- **Ref local**: `git diff <ponto-fixo>...HEAD` (três pontos, contra o merge-base) e `git log <ponto-fixo>..HEAD --oneline`.

Capture o diff **uma única vez**. Confirme que a ref resolve e que o diff não está vazio **antes** de criar qualquer subagente: uma ref inválida deve falhar aqui, não dentro dos subagentes.

Para o eixo 🔧 poder rodar o ferramental, prepare uma cópia isolada do código do PR **sem mexer no working tree do usuário**:

```bash
git fetch origin pull/<pr>/head:review/<pr>
git worktree add ../<repo>-review-<pr> review/<pr>
```

Registre o caminho do worktree para os subagentes. Ao final da revisão, remova-o (`git worktree remove`) e apague a branch local `review/<pr>`.

---

## 2. Encontrar a especificação (DoD)

Na ordem: issues referenciadas no corpo do PR ou nas mensagens de commit (Jira, GitHub) → caminho informado pelo usuário → PRD, blueprint ou ticket em `docs/` que corresponda à branch ou feature → perguntar.

Extraia uma **lista de comportamentos esperados** (critérios de aceite). Se não houver especificação, diga isso no relatório: o eixo ✅ passa a avaliar só a sanidade dos testes e o escopo aparente. **Não invente uma especificação a partir do diff.**

---

## 3. Encontrar a arquitetura pretendida

O eixo 🏗️ precisa saber o que o design *deveria* ser, senão vira preferência pessoal. Procure, na ordem:

1. um blueprint, ADR ou documento de design dessa área;
2. a arquitetura que o código ao redor já estabelece, com as convenções com que esta mudança deveria ser consistente;
3. na falta dos dois, os princípios gerais em [`software-designing/references/`](../software-designing/references/).

Diga qual dos três foi usado. "Inconsistente com a estrutura de módulos que o resto deste pacote usa" é um achado muito mais forte que "eu teria feito diferente", e o leitor merece saber qual dos dois está recebendo.

---

## 4. Escala de severidade

Todo achado, em todos os eixos, recebe uma destas marcas, para o relatório poder ser lido de relance:

- 🔴 **Crítico**: quebra um requisito, introduz bug, falha no ferramental ou viola uma regra obrigatória. Não deveria entrar como está. Equivale ao **Blocking** do `agent-self-review`.
- 🟡 **Atenção**: preocupação real, não bloqueante, que vale discutir antes do merge. Equivale ao **Should fix** do `agent-self-review`.
- 🟢 **Sugestão**: melhoria de baixo impacto, **com cenário concreto**. Preferência de estilo sem cenário concreto não é reportada em nenhum eixo.

Diferença em relação ao `agent-self-review`: lá, qualquer desvio das regras é bloqueante porque o próprio agente corrige na hora. Aqui é o código de um colega. **Violação de regra documentada** do projeto pode ser 🔴 ou 🟡, conforme o impacto. **Red flag de design** (vindo das referências de `coding` ou `software-designing`) é um julgamento e **nunca passa de 🟡**, a menos que cause um problema concreto demonstrável.

---

## 5. Reunir as regras do projeto

Todas as fontes que documentam como o código deve ser escrito aqui: `AGENTS.md`/`CLAUDE.md` do repositório e do usuário, tudo em `docs/rules/` e arquivos como `CODING_STANDARDS.md` ou `CONTRIBUTING.md`. As referências da skill [`coding`](../coding/SKILL.md) não são regras do projeto: são usadas pelo eixo 🧹.

- **O repositório prevalece**: uma regra documentada do repo sempre vence; se ela endossa algo que as referências gerais apontariam, descarte o achado.
- **Não duplique o ferramental**: ignore o que linters e formatadores já garantem; o que eles reportarem entra via Fase 1.

---

## 6. Criar os quatro subagentes em paralelo

Uma única mensagem com quatro chamadas à ferramenta de subagentes do harness (ver `AGENTS.md`, seção 4; no Claude Code, `Agent` com tipo `general-purpose`). Cole a **escala de severidade da seção 4** em cada brief: cada subagente marca seus próprios achados, e nada precisa ser retriado depois. Nenhum subagente altera código.

**🔧 Qualidade e Regras**: passe o comando do diff, a lista de commits, o caminho do worktree, as fontes de regras da seção 5 e a escala. Brief:
> *"Aplique as fases 1 e 2 de `skills/agent-self-review/SKILL.md` ao código deste PR, sem corrigir nada. (a) No worktree, rode os linters, verificadores de tipo e testes do projeto; se não for possível rodar, use `gh pr checks <pr>` e diga isso. Reporte só falhas introduzidas ou tocadas pelo diff. (b) Reporte cada ponto do diff que viola uma regra documentada, citando arquivo e regra. Não reporte code smells nem julgamentos gerais de qualidade: são de outro eixo. Cite `arquivo:linha` em todos. Prefixe cada achado com o emoji de severidade (🔴/🟡/🟢) da escala. Até 400 palavras."*

**✅ Comportamentos e Testes**: passe o comando do diff, a lista de commits, a lista de comportamentos da seção 2 e a escala, com instrução para ler antes `skills/coding/references/testing.md`. Brief:
> *"Aplique as fases 3 e 4 de `skills/agent-self-review/SKILL.md` a este PR, sem corrigir nada. Para cada comportamento da lista, classifique com a legenda de DoD de `skills/human-review/SKILL.md` (seção 2.3): ✅, 🔎, 👤 (diga o que o revisor precisa verificar manualmente e como) ou 🚨. Depois reporte como achados: (a) comportamento implementado, testável, mas sem teste adequado (🟡); (b) comportamento no diff que não foi pedido (scope creep); (c) testes do diff que violam `testing.md` (acoplados a texto, estrutura ou internos; internos expostos só para teste; mocks de colaboradores internos; infraestrutura de testes nova sem relação com a tarefa), com o cenário concreto de quebra. Cite o critério da especificação e o `arquivo:linha`. Prefixe cada achado com o emoji de severidade (🔴/🟡/🟢) da escala. Até 400 palavras."*

**🏗️ Arquitetura e Contratos**: passe o comando do diff, a lista de commits, a arquitetura pretendida da seção 3 e a escala, com instrução para ler antes `skills/human-review/SKILL.md` e todos os arquivos em `skills/software-designing/references/`, e internalizar essas lentes antes de opinar. Brief:
> *"Revise o design do diff, não a sintaxe nem a lógica de negócio. Seguindo a estrutura do `human-review`, reporte: (a) módulos novos, alterados ou removidos e a direção das dependências, com um mapa de módulos na notação do `visualize-it` e marcação de qualquer seta que aponte para fora das regras de negócio; (b) interfaces e contratos públicos criados ou alterados: o que prometem e seus modos de falha; (c) preocupações ordenadas por impacto: qual é o problema, por que importa concretamente (o que quebra, o que fica mais difícil) e uma direção sugerida, usando os termos das referências (módulo raso, vazamento de informação, método repassador etc.); (d) pontos fortes a preservar. Pese os trade-offs: diga quando uma aparente violação é razoável e deliberada. Aponte arquivos, funções e linhas. Prefixe cada preocupação com o emoji de severidade (🔴/🟡/🟢) da escala; pontos fortes não levam emoji. Até 500 palavras."*

**🧹 Qualidade do Código**: passe o comando do diff, a lista de commits, as regras do projeto da seção 5 e a escala, com instrução para ler antes todos os arquivos em `skills/coding/references/`. Brief:
> *"Aplique a Fase 5 de `skills/agent-self-review/SKILL.md` a este PR, sem corrigir nada. Olhe só as linhas adicionadas ou alteradas pelo diff. Reporte **no máximo 5** achados (nomes, funções, comentários, tratamento de erro ou code smells), escolhidos pela prioridade de impacto de `code-smells.md` (risco de bug → custo de mudança → legibilidade). Para cada um: o problema, o cenário concreto em que ele atrapalha, a refatoração sugerida pelo nome e `arquivo:linha`. Descarte o que não tiver cenário concreto, o que for preferência de estilo, o que o ferramental já pega, o que uma regra do projeto endossa e o que está na seção 'Fora deste catálogo'. Não reporte smells na escala de módulo ou de contrato: são do eixo de arquitetura. Severidade máxima 🟡. Até 300 palavras."*

---

## 7. Apresentar e discutir

Monte o relatório para ser lido em segundos. **Não misture nem reordene os achados entre eixos**: uma mudança pode passar num eixo e falhar em outro, e a separação impede que um mascare os demais.

```markdown
### 🔧 Qualidade e Regras — 🔴 1 · 🟡 2 · 🟢 0

- 🔴 **<título em uma linha>** — <por que importa, cenário concreto, arquivo:linha>
- 🟡 **<título>** — <detalhe>

### ✅ Comportamentos e Testes — 🔴 0 · 🟡 1 · 🟢 0

| Status | Comportamento (DoD) | Evidência | O que o revisor deve fazer |
| :---: | :--- | :--- | :--- |
| ✅ | ... | `tests/...` | Nada |
| 👤 | ... | Não testável por código | Verificar manualmente: ... |
| 🚨 | ... | Ausente | Bloqueante |

- 🟡 **<título>** — <detalhe>

### 🏗️ Arquitetura e Contratos — 🔴 0 · 🟡 1 · 🟢 1

<mapa de módulos via visualize-it, na notação dele>

- 🟡 **<título>** — <detalhe>
- 🟢 **<título>** — <detalhe>
- ✅ <ponto forte a preservar>

### 🧹 Qualidade do Código — 🔴 0 · 🟡 1 · 🟢 2

- 🟡 **<problema>** — <cenário concreto, refatoração sugerida, arquivo:linha>
- 🟢 **<problema>** — <detalhe>
```

Se um eixo foi pulado (sem especificação, ferramental impossível de rodar etc.) ou voltou limpo, diga isso numa linha sob o título, sem omitir o título.

Feche com o resumo e a **recomendação de veredito**:

```markdown
## 📊 Resumo

🔴 Crítico:  N   — precisa de atenção antes do merge
🟡 Atenção:  N   — vale discutir
🟢 Sugestão: N   — opcional

Pior eixo: **<eixo>** (<pior achado em uma linha>)

**Veredito sugerido:** ✅ Aprovar | 💬 Aprovar com comentários | 🔁 Pedir alterações
<uma frase justificando>
```

Regra do veredito sugerido: qualquer 🔴 (ou 🚨 na tabela DoD) → **Pedir alterações**; só 🟡/🟢 → **Aprovar com comentários**; limpo → **Aprovar**. É uma sugestão: **o veredito é do usuário**.

Depois, ofereça sem insistir: qualquer achado pode ser visto em detalhe com [`visualize-it`](../visualize-it/SKILL.md), apontando para o arquivo, função ou fluxo por trás dele. Continue na conversa e responda às dúvidas. O usuário pode rebaixar, promover ou descartar achados.

---

## 8. Transformar os pontos aceitos em comentários

Quando o usuário estiver pronto, **pergunte quais achados ele considera válidos e qual veredito vai dar.** Só esses viram comentários: nunca publique a revisão inteira.

### 8.1. Comentários de linha

Para cada achado aceito, gere um comentário pronto para colar, em **PT-BR**. Rascunhe e depois passe pela skill `humanize-writing` (se disponível no harness) antes de apresentar: são lidos por um colega, e um comentário que parece gerado por IA quebra o tom colaborativo.

<comment-template>

**Arquivo:** `caminho/do/arquivo.ext`
**Linha:** N (ou intervalo N-M)

{{explicação do problema, profissional e colaborativa, cobrindo o *porquê*: o cenário concreto que falha, o risco, o custo}}

{{se houver uma sugestão de código ou abordagem já discutida: inclua-a aqui ao final, em bloco de código quando aplicável}}

</comment-template>

### 8.2. Comentário geral da revisão

Um texto curto para o corpo da revisão, coerente com o veredito escolhido pelo usuário:
- **Aprovar**: reconhece o que ficou bom (use os pontos fortes do eixo 🏗️) em duas ou três frases.
- **Aprovar com comentários**: resume que os comentários são não bloqueantes.
- **Pedir alterações**: lista em prosa curta o que precisa mudar antes do merge (só os 🔴 aceitos) e aponta para os comentários de linha.

Passe também pelo `humanize-writing`.

### Regras dos comentários

- **Arquivo e linha exatos.** Se o achado não traz a localização, volte ao diff e encontre. Nunca invente uma localização.
- **Sem referências locais** (`AGENTS.md`, seção 2). Para apontar para a especificação, use a issue vinculada (Jira/GitHub), se existir; senão, reescreva o requisito com suas próprias palavras.
- **Profissional e colaborativo.** Apresente como uma observação para discutir, não uma ordem. Prefira *"podemos considerar"* a *"você deveria ter feito"*. Nada que soe como julgamento de quem escreveu.
- **Explique o porquê**, não só o quê.
- **Sem correções inventadas.** Se nenhuma solução foi discutida, termine na explicação.
- **Sem assinatura.** Nenhuma linha de coautoria, assinatura de IA ou rodapé.
- Termos técnicos, identificadores e código ficam no idioma original.
- Apresente na ordem em que os achados foram discutidos, um bloco por comentário, pronto para copiar.

### Publicação

Nunca publique nada automaticamente. Se o usuário pedir explicitamente para publicar, mostre exatamente o que será enviado e use `gh pr review <pr>` com `--approve`, `--comment` ou `--request-changes`, conforme o veredito dele, só depois da confirmação.

---

## 9. Validação de Sucesso

- [ ] O diff foi capturado uma única vez e validado antes dos subagentes; o working tree do usuário não foi alterado, e o worktree de revisão foi removido.
- [ ] Os quatro eixos rodaram (ou o relatório diz por que algum foi pulado), cada um com contagem por severidade.
- [ ] Todo achado tem `arquivo:linha` e emoji de severidade; nenhum foi misturado entre eixos.
- [ ] O eixo 🏗️ declara qual fonte de arquitetura pretendida usou.
- [ ] O veredito sugerido segue a regra da seção 7, e o veredito final foi dado pelo usuário.
- [ ] Só os achados aceitos pelo usuário viraram comentários, com localização exata, em PT-BR, humanizados e sem linha de coautoria.
- [ ] Nada foi publicado no GitHub sem pedido e confirmação explícitos.
