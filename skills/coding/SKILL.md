---
name: coding
description: >-
  Instruções e diretrizes para implementação, escrita, testes e refatoração de código e software. Deve ser acionada sempre que for desenvolver ou alterar código em qualquer projeto.
---

# Coding

Skill base para padronização de implementação de software.

## Propósito
Centralizar as diretrizes, padrões de qualidade e fluxos operacionais para escrita e alteração de código.

## Contexto de Ativação
- Implementação de novas funcionalidades.
- Correção de bugs e refatoração.
- Criação e execução de testes automatizados.

## Testes
Implemente guiado por testes conforme [test-driven-development.md](references/test-driven-development.md), com os critérios de [testing.md](references/testing.md).

## Refatoração
Refatore antes de alterar código difícil de mudar e depois de cada teste verde, só no código que a tarefa toca, conforme [refactoring-principles.md](references/refactoring-principles.md).

## Referências

| Referência | Carregar quando… |
| :--- | :--- |
| [test-driven-development.md](references/test-driven-development.md) | For começar a implementar uma tarefa ou corrigir um bug. |
| [testing.md](references/testing.md) | For escrever ou revisar testes. |
| [refactoring-principles.md](references/refactoring-principles.md) | For refatorar, ou decidir se uma melhoria de estrutura vale a pena agora. |
| [naming.md](references/naming.md) | For nomear variáveis, funções, classes ou campos internos. |
| [functions.md](references/functions.md) | For escrever, dividir ou revisar funções. |
| [comments.md](references/comments.md) | For escrever, manter ou revisar comentários. |
| [error-handling.md](references/error-handling.md) | O código puder falhar (I/O, rede, entrada externa, terceiros), ou houver `try/catch`, retornos de erro ou nulos. |
| [code-smells.md](references/code-smells.md) | For avaliar ou limpar código abaixo dos contratos (condicionais, estado, dados internos, lugar do código). |

## Portão de Qualidade
Ao concluir alterações de código, o agente deve obrigatoriamente executar a skill [`agent-self-review`](../agent-self-review/SKILL.md) e iterar até que seu código e testes estejam aprovados.

---

## Validação de Sucesso

- [ ] A implementação foi guiada por testes (TDD) conforme [test-driven-development.md](references/test-driven-development.md).
- [ ] Os testes comprovam comportamentos observáveis pela interface pública conforme [testing.md](references/testing.md).
- [ ] Refatorações preservaram o comportamento com testes passando conforme [refactoring-principles.md](references/refactoring-principles.md).
- [ ] As alterações passaram no portão [`agent-self-review`](../agent-self-review/SKILL.md) até o veredito limpo (*clean*).
