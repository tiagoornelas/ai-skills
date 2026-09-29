---
name: grill-me
description: >-
  Entrevista o usuário de forma implacável para pôr à prova um plano, uma
  decisão, um design ou uma ideia, de qualquer assunto e em qualquer momento,
  até chegar a um entendimento compartilhado sem nada assumido em silêncio.
  Organiza as perguntas numa árvore de decisões e pergunta em rodadas, sempre
  com uma recomendação; busca por conta própria os fatos que o ambiente
  responde e deixa as decisões com o usuário. Não produz artefato nem pertence a
  um fluxo fixo. Deve ser acionada quando o usuário pedir para ser entrevistado,
  questionado ou para testar o próprio raciocínio ("me sabatina", "grill me",
  "stress test"), ou por outra skill que precise conduzir uma entrevista.
argument-hint: "[o plano, decisão ou ideia a pôr à prova — por padrão, o que está em discussão]"
---

# Grill Me

Uma entrevista para **pôr o raciocínio à prova antes de agir**. Serve para qualquer coisa: uma feature, uma arquitetura, uma decisão de negócio, um texto, o que fazer em seguida. Não precisa de repositório, a entrevista não escreve arquivos (o único artefato possível é um protótipo descartável, na seção 5) e **não tem saída fixa**: o que fica é uma versão mais afiada da ideia, na cabeça do usuário.

> Os **fatos** são trabalho do agente. As **decisões** são do usuário. Um agente que responde às próprias perguntas de decisão quebrou a skill.

---

## 1. Fixar o assunto

Confirme em uma linha o que está sendo posto à prova. Sem argumento, use o que está em discussão na conversa; se estiver ambíguo, pergunte.

Se o assunto for grande demais para uma sessão (várias frentes independentes, cada uma com a própria árvore), diga isso e proponha começar por uma delas. Sessões com centenas de perguntas quase sempre são escopo demais, e a qualidade das perguntas cai conforme o contexto enche.

---

## 2. A árvore de decisões

Mapeie o assunto como uma **árvore de decisões**: cada decisão se ramifica nas decisões que dependem dela.

- A **fronteira** é o conjunto de decisões cujos pré-requisitos já estão resolvidos: as perguntas que dá para fazer **agora**, sem adivinhar respostas que ainda não vieram.
- Uma **rodada** pergunta a fronteira inteira, de uma vez. Duas perguntas nunca dividem a rodada se uma depende da outra: a dependente vai para uma rodada seguinte.
- Cada resposta **remodela a árvore**: decisões resolvidas empurram a fronteira para fora e liberam o que dependia delas. Recalcule a fronteira a cada rodada; a próxima rodada é recalculada, não pré-escrita.

A fronteira é julgamento, não um grafo calculado. Se uma resposta mostrar que outra pergunta da mesma rodada deveria ter mudado, diga isso e reabra o ramo na rodada seguinte.

Para pôr à prova, não só para esclarecer, procure ativamente os ramos que o usuário não mencionou: suposições implícitas, modos de falha, casos de borda, custo de reverter, quem mais é afetado, o que acontece se a premissa principal estiver errada.

---

## 3. Formato da rodada

Cada pergunta segue exatamente este bloco, separado da próxima por `---`:

```markdown
❓ **Q1** · **<título da pergunta>**

<só o contexto necessário para decidir, o mais curto possível>

- **A)** <opção>
- **B)** <opção>
- **C)** <opção>

➡️ **A**: <uma frase dizendo por que esta>

---

❓ **Q2** · **<título da pergunta>**

<pergunta aberta, quando não há opções discretas>

➡️ <resposta recomendada, em uma frase>
```

- **Opções em lista**, uma por linha, com letras. Se a pergunta não tem opções discretas, pergunte aberta: não invente letras.
- **Uma recomendação por pergunta**, com uma letra só em negrito logo após `➡️`, e **uma frase sobre a opção escolhida**. Raciocínio que precisa de mais espaço vai no corpo da pergunta.
- **As letras são o vocabulário do usuário**: ele deve conseguir responder a rodada inteira com `Q1 A, Q2 C, Q3 não, porque...`.
- Se o usuário pedir **uma pergunta por vez**, siga assim pelo resto da sessão, mantendo o mesmo bloco.

Depois da rodada, **pare e espere** as respostas.

---

## 4. Fatos: buscar, não perguntar

Nunca pergunte ao usuário algo que o ambiente responde. Feche as duas ignorâncias:

- **O que o usuário sabe e o agente não**: motivo de negócio, restrição não escrita, tentativa anterior que falhou, como é "pronto". Só a entrevista traz isso.
- **O que o ambiente sabe e o usuário não**: o que já existe no código, o que uma mudança afeta, como o sistema se comporta de fato (versus como ele lembra). Vá ler e conte a ele.

Quando uma pergunta da fronteira depende de um fato:

- **No ambiente local** (arquivos, git, ferramentas): despache um subagente para buscar (ver [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md)).
- **Fora do ambiente** (comportamento de API de terceiros, contrato de biblioteca, documentação): despache um subagente, do mesmo jeito, para pesquisar em fontes primárias (documentação oficial, código-fonte, especificação) e trazer a resposta com o link. Não chute.
- **Não bloqueie**: uma busca em andamento é um pré-requisito não resolvido. Só as perguntas que dependem dela esperam; o resto da fronteira é perguntado agora.

---

## 5. Perguntas que conversa não resolve

Algumas perguntas se respondem conversando. Outras não, e nenhuma quantidade de entrevista chega lá.

"Um formulário longo ou três páginas?", "como essa interação deveria parecer?" e "esse modelo de estados se sustenta?" são perguntas que **não se resolvem na conversa**: precisam de algo concreto para reagir. Quando aparecer uma, **pare a entrevista**. Construa a versão descartável com a skill [`prototype`](../prototype/SKILL.md), olhe para ela junto com o usuário, depois volte e responda à pergunta em uma linha. A resposta entra na árvore como uma decisão resolvida, e a entrevista segue.

Insistir em prosa numa pergunta dessas é onde as sessões incham: o agente reformula, o usuário chuta, e o escopo cresce para preencher a incerteza.

---

## 6. Guardar contra a passividade

O modo de falha é o usuário concordar com tudo e sair com um plano que o agente escreveu e ele só aprovou. Parece produtivo porque foi longo; nada foi decidido de fato.

- **"Não sei" é resposta válida.** Registre como decisão em aberto e, se for o caso, aponte como resolver (protótipo, pesquisa, perguntar a alguém).
- **Resposta fraca pede contestação**: se uma resposta contradiz outra, ignora um risco concreto ou só repete a recomendação sem motivo numa decisão cara, diga isso numa frase e pergunte de novo no ramo afetado.
- **Sequência de concordâncias numa decisão cara**: lembre, uma vez, que o valor está em discordar do que não faz sentido. Não repita a cada rodada.
- **O usuário controla o escopo**: ele pode aprofundar, pular, mudar o nível de detalhe ou encerrar a qualquer momento. Siga.

---

## 7. Encerrar

A sessão termina quando **a fronteira está vazia** (todos os ramos visitados, nada assumido em silêncio) ou quando o usuário pede para parar.

1. Pergunte se o entendimento está compartilhado. **Não aja sobre nada do que foi decidido antes dessa confirmação**: nem código, nem documento, nem tarefa.
2. Se o usuário quiser, apresente um resumo curto: decisões tomadas, decisões em aberto, riscos identificados.
3. Não há próximo passo obrigatório. Se fizer sentido, sugira em uma linha para onde a conversa pode seguir (por exemplo, [`software-designing`](../software-designing/SKILL.md) para desenhar a solução, [`report-work`](../report-work/SKILL.md) para virar tarefas), sem assumir nenhum.

Quando outra skill aciona esta entrevista, o encerramento devolve a ela as decisões confirmadas.

---

## 8. Validação de Sucesso

- [ ] O assunto foi confirmado em uma linha, e o escopo cabia numa sessão (ou foi dividido).
- [ ] As perguntas vieram em rodadas, cada rodada com a fronteira inteira e sem perguntas que dependem de outra da mesma rodada.
- [ ] Toda pergunta seguiu o bloco da seção 3, com exatamente uma recomendação.
- [ ] Nenhum fato que o ambiente responde foi perguntado ao usuário, e nenhuma decisão foi respondida pelo agente.
- [ ] Rodadas posteriores perguntaram o que as primeiras não podiam perguntar.
- [ ] Perguntas de aparência ou comportamento pausaram a entrevista e foram levadas ao `prototype`, não debatidas em prosa.
- [ ] Nada foi executado antes de o usuário confirmar o entendimento compartilhado.
