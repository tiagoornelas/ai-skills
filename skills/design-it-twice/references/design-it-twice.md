# Projete Duas Vezes

> **Tese central**: projetar software é difícil, e é improvável que a primeira ideia sobre como estruturar um módulo ou sistema seja o melhor design. Os resultados ficam muito melhores quando se consideram **várias opções para cada decisão importante**, e elas são **radicalmente diferentes** entre si.

---

## Quando consultar

- Antes de fixar qualquer decisão de design importante: decomposição de um sistema, interface de um módulo, contrato de uma API, implementação de um mecanismo central.
- Quando a primeira ideia "parece óbvia" e ninguém questionou alternativas.
- Ao comparar alternativas e decidir entre elas.

---

## 1. O princípio

- Para cada decisão de design importante, não pegue a primeira ideia. Esboce **duas ou mais abordagens**, compare-as e escolha, ou combine, a melhor.
- As alternativas devem ser **radicalmente diferentes**, não variações da mesma ideia. Variações pequenas exploram pouco do espaço de soluções. Alternativas radicalmente diferentes ensinam mais sobre o problema, mesmo que sejam descartadas.
- Isso vale mesmo quando você acha que só existe uma forma razoável. Esboçar uma alternativa, mesmo uma que você sabe que não é boa, ajuda a entender o que torna a outra melhor.

---

## 2. Exemplo: a classe de texto do editor

Para a interface de uma classe que gerencia o texto de um arquivo num editor gráfico, três alternativas bem diferentes:

1. **Orientada a linhas**: operações para inserir, apagar e ler linhas inteiras.
2. **Orientada a caracteres**: operações para inserir e apagar caracteres individuais.
3. **Orientada a intervalos**: operações sobre trechos arbitrários de texto, que podem atravessar linhas.

Comparando:

- A interface por linhas obriga a camada de cima a dividir e juntar linhas em operações parciais e em operações que atravessam linhas (ex.: apagar uma seleção).
- A interface por caracteres obriga a fazer laços para operações sobre vários caracteres (ex.: apagar uma seleção caractere por caractere).
- A interface por intervalos cobre bem os dois casos e tende a ser a mais simples de usar, além de ser de propósito mais geral.

---

## 3. Como comparar as alternativas

- Liste os **prós e contras** de cada alternativa.
- O critério mais importante para uma interface é a **facilidade de uso para quem está acima dela** (o software de nível mais alto que vai consumi-la).
- Outros fatores a considerar:
  - A interface de uma alternativa é **mais simples** que a de outra?
  - Uma interface é **mais de propósito geral** que a outra?
  - Uma interface permite uma **implementação mais eficiente**?
- Quase sempre, a comparação revela fraquezas de cada alternativa. Isso é útil por si só.

### Quando nenhuma alternativa convence

- Às vezes nenhuma das alternativas é atraente. Nesse caso, use os problemas identificados em cada uma para chegar a um **novo design**.
- É comum que o melhor design seja uma **combinação** das melhores características de alternativas diferentes, ou uma ideia nova que só surgiu por causa da comparação.
- Se nenhuma opção for satisfatória, isso é um sinal de que o problema ainda não foi bem entendido. Vale investir mais antes de escolher.

---

## 4. Em que níveis aplicar

- **Interfaces** de módulos: o uso mais importante.
- **Implementação**: vale para partes centrais, em que simplicidade e desempenho importam.
- **Decomposição do sistema**: quais módulos existem e como se dividem as responsabilidades.
- **Interfaces com o usuário**: layouts e fluxos também se beneficiam de alternativas radicalmente diferentes.

Em cada nível, projetar duas vezes é mais barato do que parece. Para um módulo pequeno, esboçar alternativas no nível da interface leva uma ou duas horas, pouco perto do tempo que se passará implementando e mantendo o módulo. Em decisões maiores o investimento é maior, mas o custo de errar também é muito maior.

---

## 5. O obstáculo das "pessoas inteligentes"

- Pessoas muito capazes às vezes resistem a projetar duas vezes. Ao longo da vida, a primeira ideia delas costumava ser boa o bastante (na escola, em exercícios menores), e elas se acostumaram a confiar nela.
- Com problemas grandes e difíceis, isso deixa de funcionar: **ninguém é bom o suficiente para acertar na primeira tentativa**.
- Considerar múltiplas opções não é sinal de insegurança. É a forma de chegar ao melhor resultado.
- Projetar duas vezes também **melhora a habilidade de projetar**: quem compara alternativas com frequência aprende o que torna um design melhor que outro, e passa a descartar ideias ruins mais rápido.

---

## Red flags

- Só uma alternativa foi considerada para uma decisão importante.
- As "alternativas" são variações da mesma ideia (mesma decomposição, com nomes ou detalhes diferentes).
- Uma alternativa foi montada fraca de propósito, só para perder para a favorita (*espantalho*).
- A comparação só lista prós da favorita e contras das outras.
- A escolha foi feita pela facilidade de implementação, sem considerar a facilidade de uso da interface.

---

## Como aplicar

1. Identifique as **decisões importantes** do problema (as que seriam caras de mudar depois).
2. Para cada uma, gere **ao menos duas alternativas radicalmente diferentes**, esboçadas no nível da interface.
3. Compare, com a facilidade de uso para quem consome como critério principal, e depois simplicidade, generalidade e eficiência.
4. Escolha, combine ou, se nenhuma servir, gere uma nova a partir das fraquezas encontradas.
5. Registre as alternativas descartadas e por que foram descartadas.
