---
name: ai-assisted-software-development
description: >-
  Princípios fundamentais de governança e divisão de responsabilidades no desenvolvimento com IA. Define a fronteira entre a Camada Humana (governança, arquitetura e contratos) e a Camada do Agente (implementação interna, automação e self-review).
---

# AI-Assisted Software Development

Diretrizes e princípios para divisão de trabalho entre humanos e agentes de IA.

---

## 1. O Problema da Vazão e Foco

Agentes de IA produzem código mais rápido do que um desenvolvedor humano consegue ler linha por linha. Tentar inspecionar todo o código gerado transforma o humano em um gargalo ineficiente.

A resposta sustentável é **dividir o trabalho em duas camadas rígidas**:
- O **humano** foca exclusivamente no que é caro de errar e barato de revisar (arquitetura, contratos e comportamentos).
- O **agente** assume a responsabilidade total pela qualidade do código abaixo dos contratos, validando-se a si próprio por meio de testes automatizados e **self-review**.

---

## 2. A Camada Humana (*Human Layer*)

A esfera de governança e decisão humana. **Somente o que pertence a esta camada deve ser reportado ao desenvolvedor.**

### Responsabilidades Humanas:
- **Sistemas e Módulos**: Quais componentes existem, suas responsabilidades e seus limites.
- **Direção de Dependências**: Garantir que as dependências apontem em direção às regras de negócio (a política nunca depende de detalhes de infraestrutura ou frameworks). Ver [dependency-direction.md](../software-designing/references/dependency-direction.md).
- **Contratos e Interfaces Públicas**: O que cada módulo promete a quem o consome (assinaturas, garantias e modos de falha).
- **Comportamentos (Definition of Done)**: Validação dos critérios de aceite observáveis pelo usuário ou cliente da API.
- **Trade-offs e Inspeções Manuais**: Julgamento de negócios e execução de verificações que não puderem ser automatizadas.

---

## 3. A Camada do Agente (*Agent Layer*)

Tudo o que reside abaixo das fronteiras e contratos. **O humano não deve ser sobrecarregado com a leitura rotineira deste nível.**

### Responsabilidades do Agente:
- **Implementação Interna**: Fluxo de controle, loops, funções auxiliares privadas e algoritmos.
- **Estruturas de Dados Internas**: Escolha de tipos, coleções e mecanismos de cache internos.
- **Higiene Mecânica**: Formatação, padrões de linter, tipagem estática e ausência de complexidade desnecessária.
- **Cobertura de Testes (BDD/TDD)**: Escrita de testes que provem deterministicamente cada comportamento da DoD.
- **Auto-Correção Recursiva**: Realizar o próprio **`agent-self-review`**, corrigindo falhas até que todos os critérios estejam limpos (*clean*) antes de submeter ao humano.

---

## 4. O Teste da Fronteira

Na dúvida sobre a qual camada uma decisão pertence, aplique este teste:

> **"Alterar isso exigiria renegociar um contrato com quem chama externamente, ou poderia ser reescrito amanhã sem ninguém fora do módulo perceber?"**
> - Se exigir renegociação de contrato ou mudar regra de negócio → **Camada Humana**.
> - Se puder ser alterado internamente sem impacto externo → **Camada do Agente**.

---

## 5. Fluxos Operacionais Derivados

Esta teoria orienta dois fluxos de execução complementares:

1. **[`agent-self-review`](../agent-self-review/SKILL.md)**: Executado de forma autônoma pelo agente. O agente inspeciona sua própria implementação (linter/tipos, cobertura de DoD e testes), corrigindo problemas recursivamente até aprovação.
2. **[`human-review`](../human-review/SKILL.md)**: Invocado pelo desenvolvedor humano sob demanda. O agente sintetiza a entrega exclusivamente no nível de governança humana (mapa de dependências, interfaces alteradas e tabela de validação do DoD).

---

## 6. Validação de Sucesso

- [ ] A fronteira entre a Camada Humana e a Camada do Agente foi respeitada.
- [ ] Decisões sobre módulos, contratos, direção de dependências ou comportamentos da DoD foram levadas ao humano.
- [ ] Detalhes internos abaixo dos contratos foram resolvidos de forma autônoma pelo agente com testes e self-review.
- [ ] Nenhum caminho local ou não versionado foi exposto em artefatos compartilhados.
