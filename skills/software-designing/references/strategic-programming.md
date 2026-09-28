# Código Funcionando Não Basta: Programação Estratégica vs. Tática

> **Tese central**: o objetivo principal não pode ser "fazer funcionar". O objetivo principal deve ser **produzir um ótimo design, que também funciona**. Bom design não sai de graça: é um investimento contínuo e pequeno, feito em todas as tarefas.

---

## Quando consultar

- Sempre que houver pressão para "só fazer funcionar" ou para um atalho "só dessa vez".
- Ao decidir quanto esforço de design investir numa tarefa.
- Ao explicar ao humano o custo de longo prazo de uma solução rápida.

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

- Em vez de pegar a primeira ideia, experimentar alguns designs alternativos e escolher o mais limpo.
- Imaginar como o sistema provavelmente vai precisar mudar no futuro e deixar isso fácil.
- Escrever boa documentação (comentários de interface, invariantes, decisões).

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

## Red flags

- A justificativa "é só dessa vez" ou "depois a gente arruma".
- Uma correção que contorna o problema de design em vez de consertá-lo.
- A solução foi escolhida porque é a primeira que funciona, sem alternativas consideradas.
- Mudança que exige conhecimento especial ("não esquece de também mexer em X") para não quebrar.
- Produtividade medida só pela velocidade de entrega da tarefa atual.

---

## Como aplicar

Em toda tarefa de design, o agente deve:

1. **Recusar complexidade gratuita**: se a solução mais rápida adiciona dependência ou obscuridade evitável, apresentar a alternativa limpa e seu custo real.
2. **Considerar alternativas** antes de fixar uma solução (ao menos duas, de preferência radicalmente diferentes).
3. **Pensar na próxima mudança**: qual é a próxima mudança provável nesta área? O design a torna fácil?
4. **Consertar em vez de contornar** quando encontrar um problema de design no caminho, desde que dentro do escopo razoável (~10–20% de investimento). Se o conserto for grande demais, **escalar ao humano** como decisão de trade-off, com o custo de cada caminho explícito.
5. **Tornar a dívida visível**: quando uma solução tática for conscientemente escolhida pelo humano, registrar a decisão e o que ficou pendente.

---

## Relações

- O que exatamente se acumula quando se programa taticamente: [nature-of-complexity.md](nature-of-complexity.md).
- Como manter a postura estratégica ao mexer em código existente: [modifying-existing-code.md](modifying-existing-code.md).
