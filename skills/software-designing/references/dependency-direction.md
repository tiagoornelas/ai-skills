# Dependências Apontam para as Regras de Negócio

> **Tese central**: separe a **política** (as regras de negócio) dos **detalhes** (persistência, UI, frameworks, provedores externos, mecanismos de entrega) e faça as dependências de código cruzarem essa fronteira **num único sentido: em direção à política**. As regras de negócio declaram as **portas** de que precisam, no vocabulário delas; os detalhes as implementam como **plug-ins**. Assim, nenhuma mudança num detalhe obriga a mudar a política.

---

## Quando consultar

- Ao definir ou revisar a **direção das dependências** entre módulos.
- Quando uma regra de negócio precisa de algo de infraestrutura (persistência, mensageria, HTTP, relógio, provedor externo).
- Ao desenhar a arquitetura de um sistema ou de um módulo grande, e decidir onde ficam as fronteiras entre núcleo e detalhes.
- Quando houver pressão para escolher cedo banco, framework ou topologia de serviços.

---

## 1. Política e detalhe

- **Política**: as regras que existiriam mesmo sem computador (cálculos, validações, decisões e fluxos do negócio). É o que o sistema **é**.
- **Detalhe**: tudo o que existe para entregar, guardar ou buscar informação (banco, UI, API, CLI, fila, framework, SDK de provedor). É **como** o sistema funciona hoje, e pode mudar sem que o negócio mude.
- As duas partes mudam por motivos diferentes e em ritmos diferentes. Essa diferença é o que justifica uma fronteira entre elas.
- Vocabulário: esta referência usa **política × detalhe**, e não "alto/baixo nível". "Camada de cima/de baixo" continua tendo o sentido de [different-layer-different-abstraction.md](different-layer-different-abstraction.md) e de [general-purpose-modules.md](general-purpose-modules.md) (o mecanismo mais geral fica embaixo, e quem está em cima o usa).

---

## 2. Fronteira e direção

- A direção da **dependência de código** (quem importa ou conhece quem) não precisa acompanhar a direção do **fluxo de controle** (quem chama quem em tempo de execução).
- A regra de negócio chama a persistência em tempo de execução. Mas, no código, é o módulo de persistência que conhece a porta declarada pela regra de negócio, e não o contrário:

```text
Pedidos ──declara──▶ RepositorioDePedidos.salvar(pedido)
                              ▲
PersistenciaPostgres ──implementa──┘
```

- Toda seta que cruza a fronteira aponta para o lado da política. O núcleo não sabe qual banco, framework ou provedor existe do outro lado.
- Consequência: as regras de negócio podem ser **entendidas e testadas sozinhas**, sem subir banco, servidor ou provedor.

---

## 3. A porta pertence à política

- A porta é declarada **pelo núcleo**, com os **conceitos do núcleo** e **apenas as operações que ele usa**. Para o núcleo, `RepositorioDePedidos` é um conceito do próprio domínio, e não uma necessidade de um cliente qualquer.
- Isso não contraria [general-purpose-modules.md](general-purpose-modules.md). As duas regras valem em lugares diferentes:
  - **na fronteira entre política e detalhe**, a porta fica do lado da política e usa o vocabulário dela;
  - **atrás da porta**, o adaptador pode (e costuma) usar módulos gerais, com interfaces no vocabulário deles (um cliente de banco, um armazenamento chave-valor, um cliente HTTP).
- A porta deve ser **profunda** e **esconder** tudo sobre o detalhe (ver [information-hiding.md](information-hiding.md)). Uma porta que só espelha a API do banco ou do SDK inverte a seta, mas não protege nada: os conceitos da infraestrutura (tabelas, transações, códigos de status, paginação do provedor) continuam vazando para as regras de negócio.

---

## 4. Detalhes como plug-ins

- Com as portas do lado da política, cada detalhe vira um **plug-in**: pode ser trocado, duplicado (uma implementação real e uma em memória para testes) ou adiado sem alterar o núcleo.
- A relação é **assimétrica**: o plug-in conhece o núcleo; o núcleo não sabe que o plug-in existe.
- Para isso funcionar, as implementações precisam ser **substituíveis**: qualquer uma deve cumprir o contrato completo da porta, inclusive a parte informal (ver [deep-modules.md](deep-modules.md)).

### Adiar decisões

- Com a porta definida, a escolha do detalhe (qual banco, qual framework, qual provedor, se haverá serviços separados) pode ser **adiada** até existir informação suficiente para decidir. Começa-se com a implementação mais simples que cumpre o contrato.
- Decisões de infraestrutura tomadas cedo demais, antes de entender os casos de uso, tendem a contaminar o núcleo e a custar caro depois.

---

## 5. Onde se criam os concretos

- Alguém precisa conhecer as implementações concretas para criá-las e conectá-las às portas.
- Concentre esse conhecimento em **poucos pontos de composição** (o `main`, um *composition root*, a configuração da aplicação), e não espalhado pelas regras de negócio.

---

## 6. Levando longe demais

- **Inverta só onde há fronteira entre política e detalhe.** Dentro da própria política, ou dentro de um mesmo detalhe, dependências diretas entre módulos são mais simples e mais óbvias. Uma interface para cada classe, com uma única implementação e nada a proteger, gera módulos rasos e **obscuridade** (o leitor precisa descobrir o que roda de verdade). Ver [deep-modules.md](deep-modules.md) e [obvious-code.md](obvious-code.md).
- **Dependências estáveis podem ser diretas.** Bibliotecas padrão da linguagem e tipos básicos mudam raramente; escondê-las atrás de portas é custo sem ganho.
- **Fronteira lógica antes de física.** Uma fronteira arquitetural não precisa ser um serviço, um processo ou uma fila: na maioria dos casos, basta uma porta no código com as dependências no sentido certo. Fronteiras físicas antes de uma necessidade concreta (escala, implantação independente, times separados) trazem o custo da distribuição sem o benefício.
- **Não separe o que muda junto.** Uma fronteira no lugar errado gera amplificação de mudança a cada nova funcionalidade. Confira contra [together-or-apart.md](together-or-apart.md).

---

## Red flags

- Uma regra de negócio que importa um módulo de banco, framework web, SDK de provedor ou fila.
- Conceitos de infraestrutura (tabelas, transações, códigos HTTP, formatos de provedor) aparecendo nas regras de negócio.
- Portas que espelham a API da infraestrutura em vez de expressar a necessidade do núcleo.
- Não dá para testar as regras de negócio sem subir banco, servidor ou provedor.
- Trocar um detalhe (banco, UI, provedor) exigiria alterar o núcleo.
- Setas de dependência cruzando uma fronteira nos dois sentidos.
- Criação de implementações concretas espalhada pelas regras de negócio.
- O oposto: interfaces com uma única implementação e nenhuma fronteira entre política e detalhe a proteger.

---

## Como aplicar

1. No mapa de módulos, **classifique cada módulo** como política ou detalhe. Quando a classificação depender do negócio, pergunte ao humano.
2. **Trace a fronteira** entre as duas partes.
3. Para cada dependência de código que vai da política para um detalhe, **crie uma porta do lado da política**, com o vocabulário dela e só com as operações que ela usa. O detalhe implementa a porta.
4. Verifique se cada porta **esconde** o detalhe: nenhum conceito de infraestrutura deve atravessá-la.
5. **Concentre a criação** dos concretos em poucos pontos de composição.
6. **Teste do plug-in**: para cada detalhe, pergunte "dá para trocar isto, ou substituir por uma versão em memória, sem alterar as regras de negócio?". Se não, a fronteira está vazando.
7. Liste as **decisões de infraestrutura que podem ser adiadas** e o que falta saber para tomá-las.

Ao reportar ao humano, mostre no mapa de módulos o núcleo, os plug-ins e a fronteira, com todas as setas cruzando no mesmo sentido, e um cartão de interface para cada porta. A direção das dependências, as portas e as decisões adiadas são da Camada Humana.

---

## Relações

- Portas devem ser profundas e esconder o detalhe: [deep-modules.md](deep-modules.md) e [information-hiding.md](information-hiding.md).
- Atrás da porta, módulos gerais no vocabulário deles: [general-purpose-modules.md](general-purpose-modules.md).
- Cada lado da fronteira oferece uma abstração diferente: [different-layer-different-abstraction.md](different-layer-different-abstraction.md).
- O custo de separar o que muda junto: [together-or-apart.md](together-or-apart.md).
- Dependências são uma das duas causas de complexidade: [nature-of-complexity.md](nature-of-complexity.md).
