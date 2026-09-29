---
name: github-review-react
description: >-
  Reage à revisão que um colega fez num Pull Request do usuário no GitHub: coleta
  os comentários pendentes, avalia cada um por pertinência e aplicabilidade,
  mostra de forma clara e visual o problema e a sugestão, e decide junto com o
  usuário o que acatar, ajustar, adiar ou não acatar, com justificativa. Depois
  aplica as mudanças aceitas com a skill coding, em commits rastreáveis, e redige
  respostas corteses e concisas para cada comentário, citando o commit da correção
  ou o motivo de não acatar. Deve ser acionada quando o usuário pedir para
  analisar, responder ou aplicar a revisão recebida num PR dele.
disable-model-invocation: true
argument-hint: "[número/URL do PR — por padrão, o PR da branch atual]"
---

# GitHub Review React

O outro lado da [`github-code-review`](../github-code-review/SKILL.md): aqui o PR é **do usuário**, e quem revisou foi um colega. A entrega é **cada comentário pendente com um destino decidido**, as mudanças aceitas aplicadas e uma resposta pronta para cada thread.

> Um comentário de revisão não é uma ordem nem um ataque. Ele é avaliado pelo **mérito**: o problema existe? A sugestão resolve? Cabe neste PR? O revisor pode ter contexto que o agente não tem; o agente pode ter visto o código mais de perto. **A decisão é do usuário.**

---

## 1. Coletar a revisão

```bash
gh pr view <pr> --json number,title,body,url,author,headRefName,baseRefName,reviews,comments
```

Comentários de linha e o estado de cada thread (resolvida, desatualizada), via GraphQL:

```bash
gh api graphql -F owner=<owner> -F repo=<repo> -F pr=<pr> -f query='
query($owner:String!,$repo:String!,$pr:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$pr){
      reviewThreads(first:100){ nodes{
        id isResolved isOutdated path line
        comments(first:50){ nodes{ databaseId author{login} body diffHunk createdAt } }
      }}
    }
  }
}'
```

- Considere **threads não resolvidas** e comentários gerais das revisões (corpo da review e comentários na conversa do PR).
- Ignore comentários do próprio usuário, a não ser como contexto de uma thread.
- Threads **desatualizadas** (`isOutdated`) entram, marcadas: o código pode já ter mudado, então confira se o ponto ainda vale.

Prepare o código: confirme que o working tree está limpo e que a branch local é o head do PR, atualizada (`gh pr checkout <pr>`). Se estiver sujo, avise e pare.

Encontre também a especificação (issue vinculada, descrição do PR) e as regras do projeto (`AGENTS.md`/`CLAUDE.md`, `docs/rules/`, `CONTRIBUTING.md`): são o critério para julgar se uma sugestão cabe.

---

## 2. Entender e avaliar cada comentário

Para cada comentário, leia o código atual no local indicado (não só o `diffHunk`) e o entorno necessário. Responda:

1. **O que pede?** Resuma em uma linha. Classifique o tipo: 🐛 bug · 🏗️ design · 🧪 teste · 🧹 legibilidade · 🎨 estilo/nit · ❓ pergunta · 👍 elogio.
2. **É pertinente?** O problema descrito existe de verdade? Tente reproduzir o cenário, seguir o fluxo ou escrever o teste que o provaria. Não aceite nem rejeite por autoridade.
3. **É aplicável?** Cabe no escopo deste PR? Conflita com uma regra documentada do projeto, com a especificação ou com outro comentário? Qual o custo e o risco da mudança?
4. **A sugestão é o melhor caminho?** Às vezes a preocupação é válida e a solução proposta não; às vezes existe uma alternativa mais simples.

Use como lente as referências de [`coding`](../coding/SKILL.md) e de [`software-designing`](../software-designing/SKILL.md). Uma regra documentada do repositório prevalece sobre preferências gerais, tanto do agente quanto do revisor.

Recomendação para cada comentário:

| Destino | Quando |
| :---: | :--- |
| ✅ **Acatar** | Pertinente, aplicável, e a sugestão resolve bem. |
| 🔀 **Acatar com ajuste** | A preocupação é válida, mas outra solução a resolve melhor. Diga qual e por quê. |
| 📌 **Adiar** | Válido, mas fora do escopo deste PR. Vira issue de follow-up. |
| ❌ **Não acatar** | Não pertinente (o problema não existe, ou já está tratado) ou o custo supera o benefício. Justificativa concreta obrigatória. |
| 💬 **Só responder** | Pergunta, pedido de esclarecimento ou elogio: não pede mudança de código. |

---

## 3. Apresentar e discutir

Um cartão por comentário, na ordem das threads no diff:

```markdown
### #1 · 🐛 `src/billing/invoice.ts:42` — @revisor

> <trecho curto do comentário original>

**O que pede:** <uma linha>
**Código atual:**
<trecho mínimo>

**Avaliação:** <pertinência e aplicabilidade em 1–3 frases, com o cenário concreto>
**Recomendação:** ✅ Acatar — <o que mudar, em uma linha>
```

Quando o ponto é estrutural (dependência, fronteira, fluxo), mostre o antes/depois com [`visualize-it`](../visualize-it/SKILL.md), na notação dele.

Feche com a tabela de resumo:

```markdown
| # | Local | Tipo | Revisor | Recomendação |
| :-: | :--- | :-: | :--- | :-: |
| 1 | `src/billing/invoice.ts:42` | 🐛 | @revisor | ✅ |
| 2 | `src/billing/tax.ts:10` | 🎨 | @revisor | ❌ |

✅ N · 🔀 N · 📌 N · ❌ N · 💬 N
```

Discuta com o usuário e responda às dúvidas. Ele pode mudar qualquer destino. **Nada é aplicado antes de ele fechar a lista.**

---

## 4. Planejar as mudanças

Com os destinos decididos, proponha o plano:

- **Um commit por comentário** (ou por grupo de comentários sobre o mesmo ponto), para que cada resposta aponte um commit exato.
- Ordem: 🐛 primeiro, depois 🏗️/🧪, por fim 🧹/🎨. Mudanças que dependem umas das outras seguem a dependência.
- Para cada 📌, um rascunho curto da issue de follow-up (título e duas linhas), a ser criada só com confirmação.

Confirme o plano com o usuário.

---

## 5. Aplicar

Para cada item do plano:

1. Implemente com a skill [`coding`](../coding/SKILL.md): teste primeiro quando o comentário aponta um comportamento (🐛, 🧪), refatoração segura quando é estrutura ou legibilidade.
2. Rode o portão [`agent-self-review`](../agent-self-review/SKILL.md) sobre a mudança e corrija até ficar limpo.
3. Faça o commit com a skill [`commit`](../commit/SKILL.md) e **registre o SHA** ao lado do número do comentário.

Se, ao implementar, a mudança se mostrar mais cara ou arriscada do que parecia, pare e volte ao usuário: o destino pode virar 📌 ou 🔀.

**Push só com confirmação**: as respostas citam commits, então eles precisam estar no remoto antes de publicar as respostas.

---

## 6. Redigir as respostas

Uma resposta por thread, no idioma em que o revisor escreveu (PT-BR por padrão). Rascunhe e passe pela skill [`humanize-writing`](../humanize-writing/SKILL.md): quem lê é um colega.

| Destino | Modelo |
| :---: | :--- |
| ✅ | `Corrigido em <sha>: <o que mudou, em uma frase>.` |
| 🔀 | `Boa observação. Fui por um caminho um pouco diferente em <sha>: <o que foi feito>, porque <motivo>. Resolve <a preocupação> do mesmo jeito.` |
| 📌 | `Faz sentido, mas foge do escopo deste PR. Abri <link da issue> para tratar separado.` |
| ❌ | `Vou manter como está: <motivo concreto, em uma ou duas frases>. Se tiver outro cenário em mente, me fala.` |
| 💬 | Resposta direta à pergunta, em poucas frases. |

Regras:

- **Direta e concisa**: uma a três frases. Sem agradecimento em toda resposta, sem pedir desculpas pelo código.
- **Cortês sem ceder no mérito**: um ❌ explica o motivo concreto (o cenário não ocorre porque X; a regra do projeto Y pede o contrário; o custo é Z) e deixa a porta aberta. Nunca soa como "você está errado".
- **SHA curto** (7 caracteres): o GitHub transforma em link automaticamente.
- **[sem referências locais](../ai-assisted-software-development/references/no-local-references.md)**, **sem assinatura** e sem linha de coautoria ou de IA.
- Termos técnicos, identificadores e código ficam no idioma original.

Apresente todas as respostas juntas, um bloco por thread, com o local e o destino.

---

## 7. Publicar

Nunca publique automaticamente. Com pedido explícito, mostre exatamente o que será enviado e, após a confirmação:

```bash
# resposta numa thread de comentário de linha (id = databaseId do primeiro comentário da thread)
gh api repos/<owner>/<repo>/pulls/<pr>/comments/<comment_id>/replies -f body='<resposta>'

# resposta a comentário geral da revisão ou da conversa
gh pr comment <pr> --body '<resposta>'
```

- **Não resolva threads por conta própria**: em muitos times quem resolve é o revisor. Pergunte ao usuário.
- Ofereça pedir nova revisão (`gh pr edit <pr> --add-reviewer <login>`) quando houver mudanças acatadas.
- Issues de follow-up (📌) só são criadas com confirmação, antes das respostas que as citam.

---

## 8. Validação de Sucesso

- [ ] Todas as threads não resolvidas e comentários gerais foram coletados; os desatualizados foram conferidos contra o código atual.
- [ ] Cada comentário tem tipo, avaliação de pertinência e aplicabilidade, e um destino decidido pelo usuário.
- [ ] Todo ❌ tem justificativa concreta, e todo 🔀 diz por que a alternativa resolve a preocupação.
- [ ] As mudanças aceitas foram aplicadas com `coding`, passaram no `agent-self-review`, e cada uma tem o SHA do commit registrado.
- [ ] Cada thread tem uma resposta concisa, cortês, humanizada, sem referências locais e sem assinatura, citando o commit ou o motivo.
- [ ] Nada foi enviado ao GitHub (push, respostas, issues, threads resolvidas) sem pedido e confirmação explícitos.
