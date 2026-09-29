# Nomes

> **Tese central**: um bom nome diz **o que a coisa é e por que existe**, e poupa o leitor de ler a implementação para descobrir. Esta referência trata de nomes **internos** (variáveis, funções, classes e campos privados). Nomes de contratos públicos são decisões de design: ver [obvious-code.md](../../software-designing/references/obvious-code.md).

---

## Quando consultar

- Ao nomear qualquer coisa interna.
- Ao revisar nomes num diff.
- Quando for difícil encontrar um nome.

---

## 1. Regras

- **Revele a intenção**: o nome responde por que aquilo existe, o que faz e como se usa. Se o nome precisa de comentário, ele não revela a intenção.
- **Não desinforme**: não use um nome que sugere outra coisa (`accountList` para algo que não é uma lista, `isValid` que também altera estado).
- **Faça distinções com significado**: nada de `data1`/`data2`, e nada de palavras de ruído que não distinguem (`Info`, `Data`, `Object`, `Manager`, `Helper`). `Product` e `ProductInfo` lado a lado não dizem qual é qual.
- **Tamanho proporcional ao escopo**: `i` num laço de três linhas está ótimo; uma variável usada ao longo de um módulo precisa de um nome que se entenda e se encontre numa busca.
- **Uma palavra por conceito**: escolha entre `fetch`, `get` e `retrieve` e use sempre a mesma para a mesma ideia.
- **Uma ideia por palavra**: nunca use a mesma palavra para duas semânticas. Se `add` soma valores num lugar, não use `add` para inserir numa coleção em outro.
- **Domínio do problema e da solução**: use termos do negócio para conceitos do negócio, e termos técnicos conhecidos (`queue`, `visitor`, `cache`) para conceitos técnicos.
- **Contexto com significado, sem contexto gratuito**: `state` sozinho é ambíguo, e dentro de um `Address` basta `state`. Mas não prefixe tudo com o nome do módulo ou do projeto.
- **Forma gramatical**: classes e tipos são substantivos; funções são verbos; booleanos são predicados (`isActive`, `hasItems`).

As convenções do repositório (prefixos, capitalização, idioma dos nomes) prevalecem sobre estas regras.

---

## 2. Nome difícil é sinal

- Se é difícil achar um nome simples e preciso, a coisa provavelmente faz mais de uma coisa ou não tem um propósito claro. Antes de aceitar um nome vago, reveja o que ela faz (ver [functions.md](functions.md)).

---

## Red flags

- Nomes genéricos (`data`, `info`, `result`, `temp`, `obj`, `handle`) fora de escopos mínimos.
- Nome que sugere algo que o código não faz.
- O mesmo conceito com nomes diferentes, ou o mesmo nome para conceitos diferentes.
- Palavras de ruído distinguindo nomes parecidos.
- Abreviações que só o autor entende.

---

## Como aplicar

- **Ao escrever**: nomeie pela intenção; se travar, reveja o que a coisa faz.
- **Ao revisar**: nome **desinformativo** (sugere o que não é) ou **inconsistente** com o conceito já usado no código tem cenário concreto e vale corrigir. Nome apenas melhorável não tem: não vale apontar.

---

## Relações

- Nomes de contratos públicos e consistência no design: [obvious-code.md](../../software-designing/references/obvious-code.md).
- Nomes que dispensam comentários: [comments.md](comments.md).
- Função que é difícil de nomear: [functions.md](functions.md).
