# Código Deve Ser Óbvio

> **Tese central**: obscuridade é uma das duas principais causas de complexidade. Código óbvio é aquele que o leitor consegue ler rapidamente, sem muito esforço, e cujas **primeiras suposições sobre o comportamento estão corretas**. Software deve ser projetado para facilidade de **leitura**, não de escrita.

---

## Quando consultar

- Ao definir nomes de módulos, tipos, operações e campos de um contrato.
- Ao escolher estruturas de dados públicas (retornos, eventos, mensagens).
- Ao avaliar designs orientados a eventos, callbacks ou fluxos indiretos.
- Ao revisar se um design comunica sua intenção para quem não participou da conversa.

---

## 1. O que é "óbvio"

- Se o código é óbvio, o leitor não precisa gastar tempo nem esforço para entendê-lo, e é improvável que ele se engane ao modificá-lo.
- Se o código não é óbvio, o leitor precisa gastar muito tempo, ou vai supor errado e introduzir bugs.
- **A obviedade está na mente do leitor.** É mais fácil perceber que o código de outra pessoa não é óbvio do que perceber isso no próprio código. Por isso, a melhor forma de verificar é **revisão por outras pessoas**: se alguém diz que o código não é óbvio, ele não é, por mais claro que pareça ao autor. Em vez de discutir, entenda o que confundiu o leitor e mude o código.
- Para ser óbvio, o código precisa garantir que o leitor tenha a **informação necessária** para entendê-lo, e que o código seja **consistente com as expectativas** do leitor.

---

## 2. O que torna o código mais óbvio

- **Bons nomes**: nos contratos (módulos, tipos, operações e campos públicos), nomes precisos esclarecem o comportamento e reduzem a necessidade de documentação. Um nome difícil de escolher é sinal de conceito confuso. Regras para nomes: [naming.md](../../coding/references/naming.md).
- **Consistência**: coisas parecidas feitas de forma parecida, e coisas diferentes feitas de forma diferente. Se o leitor reconhece um padrão já visto, pode tirar conclusões com segurança sem analisar tudo de novo. Nomes, estilo de codificação, interfaces, padrões de design e invariantes devem ser consistentes.
- **Uso criterioso de espaço em branco**: a forma como o código é formatado afeta a facilidade de leitura. Linhas em branco separando blocos lógicos, alinhamento de parâmetros documentados e espaçamento consistente ajudam o leitor a enxergar a estrutura.
- **Comentários**: quando o código não consegue dizer tudo, um comentário curto fornece a informação que falta. O que comentar e como: [comments.md](../../coding/references/comments.md).

---

## 3. O que torna o código menos óbvio

- **Programação orientada a eventos**: o fluxo de controle é difícil de acompanhar, porque handlers não são chamados diretamente; são invocados indiretamente por um mecanismo de eventos. Nunca é óbvio *quando* ou *por quem* um handler é chamado. **Compensação**: documente quando e por quem cada handler é invocado ([comments.md](../../coding/references/comments.md)).
- **Contêineres genéricos**: estruturas como `Pair<Integer, Boolean>` ou tuplas agrupam valores sem dar nome a eles. Quem usa vê `getKey()` e `getValue()` (ou `t[0]`, `t[1]`), que não dizem nada sobre o significado. O código fica mais fácil de **escrever**, mas mais difícil de **ler**. Melhor definir um tipo nomeado para o caso específico, com campos significativos.
- **Tipos diferentes na declaração e na alocação**: por exemplo, declarar uma variável como `List<Message>` e atribuir uma `ArrayList`. O leitor vê a declaração e pode não perceber o tipo real, que pode afetar desempenho ou thread-safety. Quando o tipo concreto importa para o comportamento, torne-o visível.
- **Código que viola as expectativas do leitor**: por exemplo, uma função `main` que retorna logo depois de inicializar, enquanto a aplicação continua rodando em uma thread criada por um construtor. O leitor espera que a aplicação termine ao fim da `main`. Se o código faz algo diferente do esperado, isso **precisa ser documentado** de forma explícita.

---

## 4. Princípio geral

- Software deve ser projetado para facilidade de leitura, não de escrita. Atalhos que economizam digitação para quem escreve e custam compreensão para quem lê são um mau negócio: o código é lido muito mais vezes do que é escrito.
- Duas abordagens para tornar código óbvio:
  1. **Reduzir a quantidade de informação necessária** (abstração, eliminação de casos especiais, ocultação).
  2. **Aproveitar informação que o leitor já tem** (consistência com convenções e padrões conhecidos), para que ele não precise aprender nada novo.
- Quando isso não bastar, **fornecer a informação que falta** no próprio código (comentários, nomes, tipos).

---

## Red flags

- **Código não óbvio**: o significado e o comportamento não podem ser entendidos numa leitura rápida.
- **Nome vago** ou **nome difícil de escolher** (sinal de design confuso).
- Tuplas, pares e mapas genéricos em contratos públicos.
- Fluxos por eventos, callbacks ou hooks sem documentação de quando e por quem são disparados.
- Inconsistência: mesmo conceito com nomes diferentes, ou mesmo nome para conceitos diferentes.
- Comportamento surpreendente sem documentação.

---

## Como aplicar

Ao finalizar um design, revise-o **como leitor**, não como autor:

1. **Nomes**: cada módulo, tipo, operação e campo tem um nome preciso? Algum nome foi difícil de escolher? (Se sim, revise o conceito.)
2. **Consistência**: o design segue as convenções já existentes no sistema? Onde diverge, a divergência é intencional e explicada?
3. **Contratos com tipos nomeados**: substitua estruturas genéricas por tipos com significado.
4. **Fluxos indiretos**: para cada evento/callback, está claro quando e por quem é disparado?
5. **Surpresas**: algo no comportamento contraria o que um leitor esperaria? Documente ou mude.
6. **Teste do leitor externo**: alguém que não participou da conversa entenderia o design só olhando para os contratos e o diagrama? Ao apresentar ao humano, se ele precisar de muita explicação, trate isso como sinal de obscuridade no design, não de falta de explicação.

---

## Relações

- Obscuridade como causa de complexidade: [nature-of-complexity.md](nature-of-complexity.md).
- Reduzir a informação necessária via abstração: [deep-modules.md](deep-modules.md) e [information-hiding.md](information-hiding.md).
- Escrever e manter comentários: [comments.md](../../coding/references/comments.md).
