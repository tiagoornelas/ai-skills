---
name: agent-self-review
description: >-
  Portão de qualidade autônomo executado pelo próprio agente sobre seu código antes da revisão humana. Analisa ferramentas estáticas, cobertura da Definition of Done (DoD) e sanidade de testes em um loop contínuo de auto-correção até aprovação.
---

# Agent Self-Review

Portão de qualidade pré-humano executado de forma autônoma pelo agente de código.

---

## 1. Princípio Operacional

O objetivo desta skill é garantir que nenhum erro mecânico, quebra de tipagem, regressão de linter, violação de regras de código ou falta de cobertura de requisitos chegue até o desenvolvedor humano.

O agente roda as validações em um loop fechado: **avaliar → corrigir → reavaliar** até obter o veredito **clean**.

---

## 2. As Fases de Verificação

### Fase 1: Ferramental Estático e Tipagem
- Execute os linters, verificadores de tipo (`tsc`, `mypy`, etc.) e suítes de testes automatizados do projeto.
- Corrija qualquer erro de sintaxe, estilo ou tipagem. Não silencie alertas com anotações de supressão sem justificativa imperativa.

### Fase 2: Conformidade com Regras do Projeto (`docs/rules/`) e Skill `coding` (Red Flags)
- **Regras Locais do Projeto (`docs/rules/`)**: Verifique se o projeto possui arquivos de regras em `docs/rules/`. Se existirem, leia todas as regras locais e assegure conformidade estrita da implementação com esses padrões.
- **Padrões da Skill `coding` e `references/`**: Inspecione criticamente o código contra as diretrizes de [`coding`](../coding/SKILL.md) e todo o material contido em suas `references/`.
- **Tolerância Zero (Red Flag)**: Qualquer desvio ou violação de regras em `docs/rules/` ou da skill `coding` e suas referências (ex.: funções longas, falta de clareza, efeitos colaterais ocultos, acoplamento desnecessário, etc.) é uma **falha bloqueante** e deve ser corrigida antes de avançar.

### Fase 3: Cobertura BDD da Definition of Done (DoD)
Para cada requisito ou critério de aceite da tarefa:
1. **Verificado por código**: Confirme que existe um teste que observa o comportamento externamente pela interface pública. Testes que observam detalhes internos ou algo adjacente não contam como cobertura.
2. **Não testável por código**: Se um comportamento não puder ser testado deterministicamente (ex.: layout visual, comportamento de staging, percepção de LLM), declare explicitamente:
   - Qual é o comportamento;
   - Por que não é testável via código;
   - Como foi verificado alternativamente;
   - Passo a passo exato para o humano validar manualmente.

> 🚨 **Atenção**: Um comportamento da DoD que não possua teste automatizado e nem tenha sido explicitamente declarado é uma falha bloqueante.

### Fase 4: Sanidade e Desacoplamento dos Testes
- Elimine testes que estejam acoplados a detalhes internos de implementação (ex.: strings exatas de prompts que mudam com frequência, nomes de variáveis privadas).
- Assegure que os testes sobrevivam a refatorações internas sem quebrar o contrato.

---

## 3. Veredito e Loop de Auto-Correção

- **Blocking (Red Flag)**: Violação de regras locais em `docs/rules/`; violação de diretrizes/referências da skill `coding`; falha em linter/tipagem; teste quebrado; requisito da DoD não coberto e não declarado.
- **Should fix**: Lógica sem teste ou teste acoplado a detalhe interno.

Se houver qualquer item **Blocking** ou **Should fix**, o agente deve **corrigir o código ou os testes imediatamente** e reiniciar a verificação. Apenas quando o veredito for **clean**, a entrega pode ser considerada concluída no nível do agente.

