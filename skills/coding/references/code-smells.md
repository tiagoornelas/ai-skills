# Code Smells e Refatorações

> **Tese central**: um code smell é um **sinal** de que o código ficou mais difícil de ler ou de mudar do que precisa. Não é uma regra: só vale corrigir quando existe um **cenário concreto** em que ele atrapalha (um bug provável, uma mudança que ficaria cara, um leitor que se confundiria). Este catálogo cobre a Camada do Agente, abaixo dos contratos. Design de módulos e interfaces fica com [`software-designing`](../../software-designing/SKILL.md), que **prevalece** em qualquer conflito.

---

## Quando consultar

- No passo "refactor" depois do teste verde, e na refatoração preparatória.
- Ao revisar código abaixo dos contratos, próprio ou de outra pessoa.

---

## 1. Como usar este catálogo

- Cada smell traz: **sinal** (como reconhecer), **por que atrapalha**, **refatorações** (pelo nome do catálogo de refatoração; os passos são conhecidos) e **quando não aplicar**.
- **Priorize por impacto**, nesta ordem:
  1. risco de bug (estado mutável compartilhado, consulta com efeito colateral, caso especial esquecido);
  2. custo de mudança (a próxima mudança provável tocaria vários lugares);
  3. legibilidade (o leitor precisa de esforço para entender).
- Se não dá para descrever o cenário concreto em uma frase, **descarte o achado**.
- Toda refatoração segue [refactoring-principles.md](refactoring-principles.md). Se ela mudaria um contrato público ou uma fronteira de módulo, não aplique: é Camada Humana.

---

## 2. Estado e dados

| Smell | Sinal | Por que atrapalha | Refatorações | Não aplicar quando |
| :--- | :--- | :--- | :--- | :--- |
| **Dados mutáveis** | Variável, campo ou estrutura alterada em vários pontos, ou modificada por quem só a recebeu. | Dependência escondida: mudar num lugar quebra outro sem aviso. | *Encapsulate Variable*, *Separate Query from Modifier*, *Remove Setting Method*, *Change Reference to Value* | Estado local de escopo curto, em que a mutação é óbvia. |
| **Dados globais** | Variável global, singleton mutável, estado de módulo acessível de qualquer lugar. | Qualquer ponto do sistema pode mudá-lo; ninguém sabe quem muda. | *Encapsulate Variable*, depois restringir o escopo | Constantes imutáveis. |
| **Variável com dois papéis** | A mesma variável guarda coisas diferentes ao longo da função (fora acumuladores e laços). | O leitor precisa acompanhar qual papel vale em cada linha. | *Split Variable* | — |
| **Valor derivado armazenado** | Campo que guarda algo calculável a partir de outros dados, atualizado à mão. | Pode ficar inconsistente com a origem. | *Replace Derived Variable with Query* | O cálculo é caro e isso foi medido. |
| **Campo temporário** | Campo preenchido só em algumas situações, vazio no resto. | O leitor não sabe quando o campo é válido. | *Extract Class* (interna), *Introduce Special Case*, *Move Function* | — |
| **Coleção exposta** | Getter devolve a coleção interna, que o chamador pode alterar. | O dono perde o controle das próprias invariantes. | *Encapsulate Collection* | A coleção é imutável. |
| **Referência × valor trocados** | Objeto compartilhado por referência que deveria ser um valor (dinheiro, período), ou cópias de uma entidade que deveriam ser uma só. | Alterações aparecem onde não deviam, ou deixam de aparecer onde deviam. | *Change Reference to Value*, *Change Value to Reference* | — |
| **Setter desnecessário** | Campo que só deveria ser definido na criação tem um setter. | Abre caminho para estado inconsistente. | *Remove Setting Method* | — |

---

## 3. Condicionais

| Smell | Sinal | Por que atrapalha | Refatorações | Não aplicar quando |
| :--- | :--- | :--- | :--- | :--- |
| **Condicional complexa** | Condição longa ou ramos longos, cujo propósito não está claro. | O leitor precisa decifrar a regra. | *Decompose Conditional*, *Consolidate Conditional Expression* | A condição já é curta e legível. |
| **Aninhamento para casos excepcionais** | O caminho normal fica enterrado em `if` aninhados. | Esconde qual é o fluxo principal. | *Replace Nested Conditional with Guard Clauses* | Os ramos têm peso igual (não há caso principal). |
| **Caso especial repetido** | A mesma verificação (nulo, "desconhecido", vazio) espalhada pelos chamadores. | Cada chamador novo pode esquecê-la. | *Introduce Special Case* (ver [define-errors-out-of-existence.md](../../software-designing/references/define-errors-out-of-existence.md)) | Só existe um ponto de verificação. |
| **Premissa implícita** | O código só funciona se algo for verdade, mas isso não está dito. | Incógnita desconhecida para quem mexer depois. | *Introduce Assertion* | A condição depende de entrada externa: aí é validação, não asserção. |
| **`switch` repetido** | O mesmo `switch`/`if` sobre o mesmo tipo em **vários** lugares. | Cada variação nova exige mudar todos. | *Replace Conditional with Polymorphism* | Há um único `switch`, claro: mantenha. Polimorfismo para um caso só gera classes rasas. |

---

## 4. Funções

Efeito colateral escondido, consulta com modificação, argumento de saída, argumento flag, lista longa de parâmetros e critérios de extração: ver [functions.md](functions.md).

---

## 5. Lugar do código

| Smell | Sinal | Por que atrapalha | Refatorações | Não aplicar quando |
| :--- | :--- | :--- | :--- | :--- |
| **Inveja de recurso** (*Feature Envy*) | Função que usa mais os dados de outro objeto do que os do próprio. | O conhecimento está longe dos dados (ver [information-hiding.md](../../software-designing/references/information-hiding.md)). | *Move Function*, *Move Field* | A função mistura dados de vários objetos de propósito. Se a mudança cruza uma fronteira de módulo, é Camada Humana. |
| **Cadeia de mensagens** | `a.b().c().d()` repetido pelos chamadores. | Os chamadores dependem da estrutura interna da cadeia. | *Hide Delegate*, *Move Function* | A cadeia aparece uma vez só. Cada delegação criada é um método repassador: só vale se esconder a estrutura de vários chamadores. |
| **Instruções fora do lugar** | Código relacionado espalhado; declaração longe do uso; trecho repetido antes ou depois de cada chamada de uma função. | O leitor precisa juntar as peças. | *Slide Statements*, *Move Statements into Function*, *Move Statements to Callers*, *Replace Inline Code with Function Call* | — |

---

## 6. Fluxo

| Smell | Sinal | Por que atrapalha | Refatorações | Não aplicar quando |
| :--- | :--- | :--- | :--- | :--- |
| **Laço com várias tarefas** | Um laço que calcula coisas independentes ao mesmo tempo. | Cada tarefa fica difícil de entender e de mudar separadamente. | *Split Loop*, *Replace Loop with Pipeline* (se for o idioma do repositório) | Desempenho medido exige uma única passada. |
| **Código morto** | Código, parâmetro ou ramo que nunca executa. | O leitor gasta tempo com o que não importa. | *Remove Dead Code* (o histórico fica no git) | — |
| **Expressão sem nome** | Subexpressão cujo significado o leitor precisa deduzir. | Carga cognitiva. | *Extract Variable*; o inverso, *Inline Variable*, quando o nome não diz nada além da expressão | — |
| **Algoritmo confuso** | Um jeito complicado de fazer algo que tem um jeito mais simples (inclusive uma função da biblioteca padrão). | Carga cognitiva sem ganho. | *Substitute Algorithm* | — |

---

## 7. Smells subordinados ao `software-designing`

Estes smells existem no catálogo clássico, mas aqui valem **só com o critério do `software-designing`**:

- **Função longa**: vale o critério de independência de [functions.md](functions.md). Tamanho sozinho não é smell.
- **Código duplicado**: junte só se as cópias representam a mesma decisão de design e mudariam pelo mesmo motivo. Ver [together-or-apart.md](../../software-designing/references/together-or-apart.md).
- **Separar em fases** (*Split Phase*): vale quando cada fase lida com um conhecimento diferente (interpretar a entrada × calcular). Se as fases compartilham o mesmo conhecimento (o mesmo formato), é decomposição temporal. Ver [information-hiding.md](../../software-designing/references/information-hiding.md).
- **Generalidade especulativa**: remova ganchos sem uso (parâmetros, classes abstratas, *hooks* que nenhum chamador usa). Isso não contradiz interfaces um pouco gerais, que servem às necessidades atuais. Ver [general-purpose-modules.md](../../software-designing/references/general-purpose-modules.md).

---

## 8. Cobertos pelo `software-designing`: não duplicar

| Smell clássico | Lente |
| :--- | :--- |
| Nome misterioso | [naming.md](naming.md) (nomes internos) e [obvious-code.md](../../software-designing/references/obvious-code.md) (nomes de contrato) |
| Obsessão por primitivos | [obvious-code.md](../../software-designing/references/obvious-code.md) |
| Intermediário (*Middle Man*), elemento ocioso (*Lazy Element*) | [deep-modules.md](../../software-designing/references/deep-modules.md), [different-layer-different-abstraction.md](../../software-designing/references/different-layer-different-abstraction.md) |
| Classe de dados, intimidade excessiva (*Insider Trading*) | [information-hiding.md](../../software-designing/references/information-hiding.md) |
| Alteração divergente, cirurgia com rifle (*Shotgun Surgery*), classe grande | [together-or-apart.md](../../software-designing/references/together-or-apart.md), [nature-of-complexity.md](../../software-designing/references/nature-of-complexity.md) |
| Herança recusada, classes alternativas com interfaces diferentes | [deep-modules.md](../../software-designing/references/deep-modules.md) (várias implementações de uma interface) |

Na escala de módulo ou de contrato, esses smells são decisões de design, da Camada Humana. Nomes internos são a exceção: ficam em [naming.md](naming.md).

---

## 9. Fora deste catálogo

Não reporte nem aplique, mesmo que o catálogo clássico os traga:

- **Comentários como smell.** O que comentar e o que não comentar está em [comments.md](comments.md).
- ***Replace Function with Command*.** Acrescenta uma classe rasa sem esconder nada.

---

## Relações

- Regras para refatorar com segurança: [refactoring-principles.md](refactoring-principles.md).
- Funções, nomes, comentários e erros: [functions.md](functions.md), [naming.md](naming.md), [comments.md](comments.md), [error-handling.md](error-handling.md).
- Sintomas e causas de complexidade que cada smell produz: [nature-of-complexity.md](../../software-designing/references/nature-of-complexity.md).
- Lentes de design, que prevalecem em conflito: [`software-designing`](../../software-designing/SKILL.md).
