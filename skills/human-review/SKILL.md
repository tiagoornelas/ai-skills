---
name: human-review
description: >-
  Assiste o desenvolvedor humano na revisão de entregas exclusivamente na Camada Humana (arquitetura, direção de dependências, contratos de interface e comportamentos da DoD). Invocada sob demanda pelo usuário.
---

# Human Review

Assistência para revisão e deliberação humana de alto nível.

---

## 1. Princípio Fundamental

O agente **não realiza a revisão humana; ele a prepara**. A prerrogativa de aprovação e julgamento é do humano.

O papel do agente é tornar a entrega visível na **Camada Humana**, filtrando ruídos de implementação de baixo nível que já foram aprovados pelo [`agent-self-review`](../agent-self-review/SKILL.md).

> 🎨 **Visualização Nativa Obrigatória**: Esta skill utiliza nativamente a skill [`visualize-it`](../visualize-it/SKILL.md). O humano deve ser capaz de *enxergar* os limites, dependências e contratos através de diagramas (ASCII ou Mermaid), e não apenas ler descrições textuais.

---

## 2. Estrutura da Apresentação para o Humano

Ao ser acionada, esta skill deve gerar uma apresentação estruturada contendo:

### 1. Mapa de Módulos e Dependências (via `visualize-it`)
- Desenhe o mapa de componentes com [`visualize-it`](../visualize-it/SKILL.md), evidenciando:
  - Módulos e pacotes novos (`🆕`), alterados (`🔧`) ou removidos (`🗑️`).
  - Direção exata das dependências (confirmando que as setas apontam para as regras de negócio).
  - Alertas visuais (`⚠️`) para qualquer desvio arquitetural em relação ao planejado.

### 2. Contratos e Interfaces Públicas
- Interfaces, endpoints, tipos e assinaturas públicas criadas ou alteradas.
- O que cada método/contrato promete e seus possíveis modos de falha.

### 3. Tabela de Validação de Comportamentos (DoD)
Apresente uma tabela direta mapeando cada critério de aceite:

| Status | Comportamento (DoD) | Como foi Verificado | O que o Humano deve Fazer |
| :---: | :--- | :--- | :--- |
| ✅ | Regra de cálculo de juros | Teste unitário em `tests/interest.test.ts` | Nenhuma ação necessária |
| 🔎 | Redirecionamento após login | Verificado em ambiente local de teste | Opcional conferir |
| 👤 | Responsividade visual no mobile | Não testável via código | Testar manualmente no navegador com viewport 375px |
| 🚨 | Critério X não testado | Sem cobertura e sem declaração | **Bloqueio crítico para o humano avaliar** |

### 4. Itens que Exigem Decisão Humana
Destaque no final apenas o que realmente demanda a atenção do humano:
- Comportamentos marcados como verificação manual (👤);
- Decisões de trade-off ou contratos novos a serem validados;
- Dúvidas de negócio em aberto.
