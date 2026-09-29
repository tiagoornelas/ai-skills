# Código Funcionando Não Basta: Programação Estratégica vs. Tática

> **Tese central**: o objetivo principal não pode ser "fazer funcionar". O objetivo principal deve ser **produzir um ótimo design, que também funciona**. Bom design não sai de graça: é um investimento contínuo e pequeno, feito em todas as tarefas.

---

## Quando consultar

- Sempre que houver pressão para "só fazer funcionar" ou para um atalho "só dessa vez".
- Ao decidir quanto esforço de design investir numa tarefa.
- Ao explicar ao humano o custo de longo prazo de uma solução rápida.
- Em toda tarefa que altera um sistema existente (seção 5).

---

## 1. Programação tática

- Na programação tática o foco principal é **fazer algo funcionar**: uma nova feature, um bug corrigido.
- Parece razoável, mas é míope. O programador tático quer terminar a tarefa o mais rápido possível e não gasta tempo buscando o melhor design.
- Cada tarefa tática introduz um pouco de complexidade: um remendo aqui, uma dependência extra ali. Cada uma parece justificável ("é só dessa vez", "depois eu arrumo").
- Como a complexidade é incremental (ver [nature-of-complexity.md](nature-of-complexity.md)), esses atalhos se somam. Rapidamente o sistema fica difícil de mudar, e **o "depois" nunca chega**: a próxima tarefa também é urgente.
- Quando se percebe o problema, consertar exige um esforço grande demais, e a solução tática continua sendo a mais fácil. É um ciclo.

### O "tornado tático"

- Quase toda organização tem um desenvolvedor que produz código muito mais rápido que os outros, mas de forma totalmente tática.
- Às vezes a gestão o trata como herói, porque ele entrega features rápido.
- Ele deixa para trás um rastro de destruição: os engenheiros que vêm depois precisam limpar a bagunça, e o trabalho deles parece mais lento que o do "herói".

---

## 2. Programação estratégica

- O primeiro passo é perceber que **código funcionando não basta**. Não é aceitável introduzir complexidade desnecessária para terminar mais rápido.
- A coisa mais importante é a **estrutura de longo prazo** do sistema. A maior parte do código de qualquer sistema é escrita estendendo a base existente; a tarefa mais importante de hoje é facilitar essas extensões futuras.
- Exige uma **mentalidade de investimento**: gastar um pouco de tempo agora para melhorar o design, sabendo que isso será pago de volta com velocidade depois.

### Investimentos proativos

- Em vez de pegar a primeira ideia, experimentar designs alternativos e escolher o mais limpo ([`design-it-twice`](../../design-it-twice/SKILL.md)).
- Imaginar como o sistema provavelmente vai precisar mudar no futuro e deixar isso fácil.
- Documentar contratos e decisões (como comentar: [comments.md](../../coding/references/comments.md)).

### Investimentos reativos

- Por mais cuidado que se tenha, erros de design aparecem. Quando descobrir um problema de design, **não ignorar nem contornar com remendo**: separar um pouco de tempo para consertá-lo.
- Na programação estratégica, o sistema melhora continuamente ao longo do tempo, em vez de degradar.

---

## 3. Quanto investir?

- Um investimento grande no início (tentar projetar o sistema inteiro antes) não funciona: o conhecimento sobre o sistema só aparece durante a construção.
- O ideal são **investimentos pequenos e contínuos**. Uma referência razoável é gastar **cerca de 10–20% do tempo total de desenvolvimento** em investimentos de design.
- É pouco o suficiente para não afetar o cronograma de forma significativa, e o retorno aparece rápido: em poucos meses a velocidade do desenvolvimento estratégico ultrapassa a do tático, e continua crescendo, enquanto a do tático cai.

```text
progresso acumulado
  ▲                          ╱  estratégico
  │                       ╱
  │                    ╱ ─ ─ ─ ─ ─  tático (desacelera)
  │              ─ ─╱
  │         ─ ─  ╱
  │      ─     ╱
  │   ─     ╱
  │ ─    ╱
  │─  ╱
  └──────────────────────────────► tempo
```

No início o tático parece à frente; em pouco tempo o estratégico ultrapassa e a diferença só cresce.

---

## 4. Startups, prazos e dívida técnica

- O argumento mais comum a favor da programação tática é a pressão do prazo: "precisamos lançar logo, depois melhoramos".
- Na prática, quando a base de código vira espaguete, **é quase impossível consertá-la**. O custo de desenvolvimento fica alto para sempre.
- **Dívida técnica** raramente é paga integralmente. Os "juros" (lentidão, bugs, onboarding difícil) continuam sendo cobrados em cada tarefa futura.
- A qualidade do design também afeta a capacidade de atrair e manter bons engenheiros: bons engenheiros se importam com bom design.
- Empresas que começaram com "mover rápido e quebrar coisas" costumam mudar o lema quando a base de código se torna um freio; empresas com cultura forte de design tendem a manter velocidade ao longo do tempo.

---

## 5. Mudando código existente

- O design de um sistema é definido muito mais pela evolução do código do que pelo desenho inicial. Ao terminar cada mudança, o sistema deveria ter **a estrutura que teria se tivesse sido projetado desde o início com essa mudança em mente**.
- A tentação é fazer a **menor mudança possível** ("não quero mexer no que funciona"). Cada mudança mínima tende a acrescentar um caso especial, uma dependência ou uma obscuridade. **Se você não está melhorando o design, provavelmente está piorando.**
- A pergunta de cada mudança: **"este é o melhor design possível para o sistema, dado o que sei agora e a mudança que preciso fazer?"**

Ao desenhar uma mudança:

1. **Leia o design atual** da área afetada: módulos, contratos, decisões escondidas.
2. **Imagine o design ideal** considerando a nova necessidade, como se o sistema estivesse sendo projetado do zero com ela.
3. **Meça a distância** entre o atual e o ideal:
   - Pequena → faça a mudança já no formato ideal, incluindo a refatoração necessária.
   - Grande → procure uma alternativa quase tão limpa que caiba no escopo; se não houver, **escale ao humano** como trade-off explícito (custo agora × custo futuro).
4. **Melhore no caminho, dentro do que a tarefa toca**: o escopo da refatoração segue [refactoring-principles.md](../../coding/references/refactoring-principles.md).
5. **Atualize no mesmo movimento** a documentação de contratos e decisões, e os comentários conforme [comments.md](../../coding/references/comments.md).

Mudanças de contrato identificadas neste processo são decisões da Camada Humana; refatorações internas que preservam contratos são da Camada do Agente.

---

## Red flags

- A justificativa "é só dessa vez" ou "depois a gente arruma".
- Uma correção que contorna o problema de design em vez de consertá-lo.
- A solução foi escolhida porque é a primeira que funciona, sem alternativas consideradas.
- Mudança que exige conhecimento especial ("não esquece de também mexer em X") para não quebrar.
- Produtividade medida só pela velocidade de entrega da tarefa atual.
- Uma mudança que adiciona um caso especial (`if` para a nova situação) em vez de ajustar a abstração.
- "Não mexe nisso, só adiciona aqui do lado."
- A mesma mudança precisou ser replicada em vários lugares (a estrutura não comportava a mudança).

---

## Como aplicar

Em toda tarefa de design, o agente deve:

1. **Recusar complexidade gratuita**: se a solução mais rápida adiciona dependência ou obscuridade evitável, apresentar a alternativa limpa e seu custo real.
2. **Considerar alternativas** antes de fixar uma solução, seguindo [`design-it-twice`](../../design-it-twice/SKILL.md).
3. **Pensar na próxima mudança**: qual é a próxima mudança provável nesta área? O design a torna fácil?
4. **Consertar em vez de contornar** quando encontrar um problema de design no caminho, desde que dentro do que a tarefa toca e de um escopo razoável (~10–20% de investimento). Se o conserto for grande demais, **escalar ao humano** como decisão de trade-off, com o custo de cada caminho explícito.
5. **Tornar a dívida visível**: quando uma solução tática for conscientemente escolhida pelo humano, registrar a decisão e o que ficou pendente.

---

## Relações

- O que exatamente se acumula quando se programa taticamente: [nature-of-complexity.md](nature-of-complexity.md).
- O leitor futuro do código modificado: [obvious-code.md](obvious-code.md).
