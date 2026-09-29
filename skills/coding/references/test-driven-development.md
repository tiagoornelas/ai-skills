# Test-Driven Development pelo Agente

> **Tese central**: o agente implementa guiado por testes, **na medida em que a implementação permite**. O teste vem antes do código quando existe um comportamento observável e uma forma de testá-lo com a infraestrutura do projeto. Onde isso não existe, o agente não força um teste: declara o comportamento e segue.

---

## Quando consultar

- Ao começar a implementar uma tarefa.
- Ao corrigir um bug.

---

## 1. Antes de escrever código: a estratégia de teste

Para cada comportamento da DoD, decida uma única vez:

1. **É testável por código?** Veja [testing.md](testing.md), seção 5. Conteúdo de prompt, layout, cópia, configuração e código de ligação não são.
2. **Em qual altitude?** Comportamento pela interface pública ou componente ([testing.md](testing.md), seção 1).
3. **Com qual infraestrutura?** Só a que o projeto já tem ([testing.md](testing.md), seção 4).

Este passo impede o agente de construir o que não precisa: a estratégia é decidida antes, e não descoberta durante uma tentativa de testar o que não é testável.

---

## 2. O ciclo

1. **Red**: escreva o teste de um comportamento e **rode-o antes de implementar**. Ele precisa falhar, e falhar pelo motivo certo (o comportamento ainda não existe, e não um erro de importação ou de setup). Um teste que nunca falhou não prova nada.
2. **Green**: escreva o mínimo de código que faz o teste passar.
3. **Refactor**: com o teste verde, limpe o que a tarefa escreveu, seguindo [refactoring-principles.md](refactoring-principles.md).

Um comportamento por ciclo. O teste é escrito pela interface pública, como se a implementação ainda não existisse. Por isso ele não conhece os internos.

---

## 3. Bugs

- Antes de corrigir, escreva o teste que reproduz o bug e veja-o falhar. Depois corrija.

---

## 4. Onde o TDD não se aplica

- Para o que não é testável por código, implemente diretamente e **escreva a declaração no mesmo momento**: qual é o comportamento, por que não é testável, como foi verificado e o passo a passo para o humano validar.
- Teste o que estiver ao redor e for testável (por exemplo, o código que interpreta a resposta do LLM, com um LLM falso), mesmo que o núcleo não seja.

---

## 5. Quando falta infraestrutura

- Se um comportamento importante só seria testável com infraestrutura que o projeto não tem, **não a construa**.
- Declare o comportamento como não testável na estrutura atual e registre a falta de infraestrutura como **pendência para o humano**, com o que ela permitiria testar.

---

## Red flags

- Código escrito antes do teste, para um comportamento testável.
- Teste que passou na primeira execução, antes de existir implementação.
- Infraestrutura de testes criada para conseguir testar um comportamento da tarefa.
- Teste escrito para algo que a seção 5 de [testing.md](testing.md) diz para não testar.
- Comportamento não testável sem declaração.

---

## Relações

- O que é um bom teste: [testing.md](testing.md).
- O passo de refatoração: [refactoring-principles.md](refactoring-principles.md).
