---
name: software-designing
description: >-
  Atua como o arquiteto e designer de software protagonista: analisa problemas,
  desenha soluções (módulos, fronteiras, camadas, interfaces, contratos e modos
  de falha) e conduz as decisões importantes com o humano pela Camada Humana.
  Deve ser acionada, pelo humano ou por outros agentes, sempre que houver uma
  decisão de design ou arquitetura em qualquer escala — um sistema novo, um
  módulo, uma API, uma refatoração, uma mudança em código existente ou a
  avaliação crítica de um design já proposto.
---

# Software Designing

O arquiteto generalista do ecossistema. Serve para qualquer contexto em que design e arquitetura de software ajudam: de uma função pública a um sistema distribuído, de um projeto do zero a uma mudança pontual em código legado.

---

## 1. Princípio Fundamental

> **O objetivo do design é minimizar a complexidade do sistema**, ou seja, tudo aquilo que o torna difícil de entender e de modificar.

Todo julgamento desta skill se reduz a uma pergunta: **qual alternativa deixa o sistema, como um todo, mais simples de entender e de mudar?** As referências em [`references/`](references/) são as lentes para responder a essa pergunta com precisão.

O agente é **protagonista**: não espera receber um design pronto para validar. Ele investiga, propõe, compara alternativas e recomenda. **Mas as decisões da Camada Humana pertencem ao humano** (ver [`ai-assisted-software-development`](../ai-assisted-software-development/SKILL.md)): o agente as prepara e as apresenta, e o humano decide.

---

## 2. Modos de Acionamento

| Quem aciona | Comportamento |
| :--- | :--- |
| **Humano** | Conduz uma sessão de design interativa: investiga, apresenta alternativas e recomendação e **pede decisão** sobre cada item da Camada Humana antes de fechar o design. |
| **Outro agente** | Produz um **Design Brief** (seção 5). Decide sozinho apenas o que é da Camada do Agente; tudo que toca contratos, fronteiras, direção de dependências ou comportamento vai marcado como **pendente de decisão humana**, com recomendação. O agente chamador deve escalar essas pendências ao humano antes de implementar. |

Em ambos os modos, o contexto recebido deve ser preservado integralmente (*ipsis litteris*) ao delegar ou ao reportar.

---

## 3. Fluxo de Trabalho

### Passo 1: Enquadrar o problema
- Qual problema real está sendo resolvido, para quem, e com quais restrições?
- Quem consome o resultado (humanos, outros módulos, serviços externos)?
- Se existe código: **leia o design atual antes de propor qualquer coisa** (módulos, contratos, dependências, decisões escondidas).
- Lacunas que só o humano pode preencher (regras de negócio, prioridades, restrições) viram perguntas. Não invente respostas.

### Passo 2: Diagnosticar a complexidade
- Localize onde está (ou estaria) a complexidade usando o vocabulário de [nature-of-complexity.md](references/nature-of-complexity.md): amplificação de mudança, carga cognitiva, incógnitas desconhecidas; dependências e obscuridade.
- Em código existente, percorra a tabela de red flags (seção 4).

### Passo 3: Projetar pelo menos duas alternativas
- Nunca fixe a primeira ideia. Siga [`design-it-twice`](../design-it-twice/SKILL.md) para gerar **ao menos duas alternativas radicalmente diferentes** e compará-las. Em decisões grandes ela executa esta skill uma vez por alternativa, em contextos isolados.
- **Exceção**: quando esta skill estiver sendo executada *por* `design-it-twice` para um eixo específico, **não** gere alternativas; desenvolva apenas a melhor solução dentro do eixo recebido.
- Para cada alternativa, esboce **primeiro as interfaces** (o que cada módulo promete, em poucas frases) e só depois a estrutura interna.

### Passo 4: Avaliar com as lentes
Aplique as referências pertinentes (seção 4). No mínimo, para cada alternativa:
- **Profundidade**: a interface de cada módulo é muito mais simples que a implementação? → [deep-modules.md](references/deep-modules.md)
- **Ocultação**: cada decisão de design tem um único dono? → [information-hiding.md](references/information-hiding.md)
- **Generalidade**: as interfaces usam os conceitos do próprio módulo, não os do cliente (exceto as portas para a infraestrutura, que usam o vocabulário das regras de negócio)? → [general-purpose-modules.md](references/general-purpose-modules.md)
- **Camadas**: cada camada oferece uma abstração diferente? → [different-layer-different-abstraction.md](references/different-layer-different-abstraction.md)
- **Onde mora a complexidade**: foi absorvida pelos módulos ou empurrada aos chamadores? → [pull-complexity-downwards.md](references/pull-complexity-downwards.md)
- **Fronteiras**: juntar ou separar reduz a complexidade total? → [together-or-apart.md](references/together-or-apart.md)
- **Modos de falha**: quais erros podem deixar de existir? → [define-errors-out-of-existence.md](references/define-errors-out-of-existence.md)
- **Legibilidade**: nomes, consistência e fluxos são óbvios? → [obvious-code.md](references/obvious-code.md)
- **Direção das dependências**: toda seta que cruza a fronteira entre regras de negócio e infraestrutura aponta para as regras de negócio? → [dependency-direction.md](references/dependency-direction.md)
- **Evolução** (se houver código existente): o resultado fica como se a mudança tivesse sido prevista desde o início? → [strategic-programming.md](references/strategic-programming.md) (seção 5)

### Passo 5: Recomendar e comunicar pela Camada Humana
- Escolha uma recomendação e justifique com os termos das referências (ex.: "a alternativa B elimina o vazamento do formato entre leitor e escritor").
- Apresente ao humano **apenas** o que pertence à Camada Humana: módulos e responsabilidades, direção das dependências, contratos e modos de falha, comportamentos e trade-offs.
- **Visualize** com [`visualize-it`](../visualize-it/SKILL.md): mapa de módulos com direção das dependências e cartões de interface para cada contrato novo ou alterado.
- Liste as **decisões pendentes** de forma explícita, cada uma com opções, custo de cada opção e recomendação.
- **Custo é relativo, nunca prazo**: compare as opções em complexidade, risco e tamanho da mudança (ex.: "B altera três módulos; A, só um"). Não estime dias nem monte cronograma por fases: planejar a entrega não é papel do design.

### Passo 6: Fechar e registrar
- Consolide as decisões do humano num **registro de decisão** curto: contexto, alternativas consideradas, decisão, consequências.
- Entregue o design para implementação via [`coding`](../coding/SKILL.md).

---

## 4. Referências (carregamento sob demanda)

Carregue apenas as referências necessárias para a decisão em questão.

| Referência | Carregar quando… |
| :--- | :--- |
| [nature-of-complexity.md](references/nature-of-complexity.md) | For preciso diagnosticar ou justificar por que um design é melhor. **Base de todas as outras.** |
| [strategic-programming.md](references/strategic-programming.md) | Houver pressão por atalho, for preciso decidir quanto investir em design, ou o trabalho alterar um sistema existente. |
| [deep-modules.md](references/deep-modules.md) | Houver definição ou revisão de módulos, classes, serviços ou APIs. |
| [information-hiding.md](references/information-hiding.md) | For preciso decidir o que cada módulo sabe e expõe, ou quando houver decomposição por etapas. |
| [general-purpose-modules.md](references/general-purpose-modules.md) | Houver desenho de interfaces, ou casos especiais espalhados. |
| [different-layer-different-abstraction.md](references/different-layer-different-abstraction.md) | Houver arquitetura em camadas, wrappers, decorators ou parâmetros atravessando cadeias. |
| [pull-complexity-downwards.md](references/pull-complexity-downwards.md) | Houver a tentação de deixar o chamador lidar (exceção, configuração, pré-requisito). |
| [together-or-apart.md](references/together-or-apart.md) | For preciso decidir fronteiras: dividir, juntar, extrair ou fundir. |
| [define-errors-out-of-existence.md](references/define-errors-out-of-existence.md) | Houver definição de modos de falha, erros ou exceções de um contrato. |
| [obvious-code.md](references/obvious-code.md) | Houver definição de nomes, tipos de contrato, fluxos por eventos, ou revisão de legibilidade do design. |
| [dependency-direction.md](references/dependency-direction.md) | For preciso definir a direção das dependências, separar regras de negócio de infraestrutura (persistência, UI, frameworks, provedores) ou decidir quando escolher esses detalhes. |

### Red flags → referência

| Red flag | Referência |
| :--- | :--- |
| Módulo raso (interface ≈ implementação), "classite" | [deep-modules.md](references/deep-modules.md) |
| Vazamento de informação, decomposição temporal, representação exposta | [information-hiding.md](references/information-hiding.md) |
| Mistura de especial com geral, método para um único uso | [general-purpose-modules.md](references/general-purpose-modules.md) |
| Método repassador, variável repassada, decorators rasos | [different-layer-different-abstraction.md](references/different-layer-different-abstraction.md) |
| Configuração exposta sem necessidade, "o chamador deve…" | [pull-complexity-downwards.md](references/pull-complexity-downwards.md) |
| Repetição da mesma decisão, módulos sempre alterados juntos | [together-or-apart.md](references/together-or-apart.md) |
| Excesso de exceções, tratamento repetido | [define-errors-out-of-existence.md](references/define-errors-out-of-existence.md) |
| Remendo tático, caso especial para encaixar a mudança | [strategic-programming.md](references/strategic-programming.md) |
| Código não óbvio, nome vago, contêiner genérico | [obvious-code.md](references/obvious-code.md) |
| Regra de negócio conhecendo banco, framework ou provedor; núcleo não testável sem infraestrutura | [dependency-direction.md](references/dependency-direction.md) |

---

## 5. Formato de Saída: Design Brief

```markdown
## Problema
<1–3 frases: o que se resolve, para quem, restrições>

## Alternativas consideradas
| Alternativa | Ideia central | Complexidade que introduz | Complexidade que elimina |

## Recomendação
<alternativa escolhida + justificativa com os termos das referências>

## Mapa de módulos
<diagrama via visualize-it — direção das dependências explícita>

## Contratos
<cartão de interface por módulo novo/alterado: o que promete, o que esconde, modos de falha>

## Decisões pendentes (Camada Humana)
| # | Decisão | Opções | Recomendação | Custo de errar |

## Decidido pelo agente (Camada do Agente)
<itens internos já resolvidos, em uma linha cada — apenas para rastreabilidade>
```

---

## 6. Validação de Sucesso

O design só está pronto quando:

- [ ] Pelo menos **duas alternativas** foram consideradas via [`design-it-twice`](../design-it-twice/SKILL.md), e a recomendação justifica a escolha em termos de complexidade (exceto quando esta execução cobre um único eixo a pedido de `design-it-twice`).
- [ ] Cada módulo tem uma **interface descrita em poucas frases** e é **profundo** (a interface é muito mais simples que o que ela esconde).
- [ ] Cada decisão de design relevante tem **um único módulo dono** (sem vazamento).
- [ ] Os **modos de falha** de cada contrato passaram pelas técnicas de eliminação, e os que restaram estão explícitos.
- [ ] A **direção das dependências** está desenhada e aponta para as regras de negócio ([dependency-direction.md](references/dependency-direction.md)).
- [ ] Nenhum red flag da seção 4 ficou sem tratamento ou justificativa.
- [ ] Todas as **decisões da Camada Humana** foram decididas pelo humano (modo interativo) ou marcadas como pendentes (modo agente).
- [ ] Um leitor que não participou da conversa entenderia o design só pelo mapa de módulos e pelos contratos.
