---
name: visualize-it
description: >-
  Renderiza qualquer aspecto de um projeto como imagem ou diagrama — mapas de módulos, direção de dependências, interfaces, contratos, fluxos de execução, estados e comparações antes/depois. Usada nativamente por human-review e invocável diretamente.
---

# Visualize It

Módulo central de visualização estrutural e diagramação do ecossistema.

---

## 1. Princípio Fundamental

Toda visualização deve responder a **uma única pergunta com clareza**. Uma imagem que tenta mostrar tudo não comunica nada.

| Pergunta a Responder | Formato Recomendado |
| :--- | :--- |
| Quais são as partes e para onde apontam as dependências? | **Mapa de Módulos**: grafo direcionado (`A → B` = "A depende de B") |
| O que este módulo ou interface promete? | **Cartão de Interface**: assinatura, contratos e modos de falha |
| O que acontece, em qual ordem, cruzando quais fronteiras? | **Diagrama de Sequência** |
| Em quais estados o sistema pode estar e o que dispara transições? | **Diagrama de Estados** |
| O que mudou entre o planejado e o executado? | **Comparação Antes / Depois** com elementos alterados destacados |

---

## 2. Regras para Diagramas Legíveis

1. **Uma pergunta por diagrama**: Divida diagramas complexos em visões de sobrevoo (*overview*) e visões de detalhe (*zoom*).
2. **Desenhe fronteiras, não árvores de arquivos**: Pastas não são necessariamente módulos. Agrupe por responsabilidade e ciclo de vida.
3. **Sentido único para setas**: Sempre declare a convenção utilizada (ex.: `→` significa "depende de").
4. **Evidencie o novo**: Em revisões de entrega ou comparações, marque novos componentes com `🆕`, alterados com `🔧` e removidos com `🗑️`.
5. **Máximo de 7 caixas principais**: Acima disso, reduza o nível de detalhe ou crie dois diagramas em altitudes diferentes.

---

## 3. Formatos de Saída

- **Padrão (Terminal-Native / Markdown Puro)**:
  - Utilize caracteres de caixa (`┌ ┐ └ ┘ ─ │ ├ ┤ ┬ ┴ ┼`) e setas (`→ ← ↔ ⇒ ▶`).
  - Tabelas Markdown para cartões de interface e comparação antes/depois.
- **Mermaid (````mermaid`)**:
  - Utilize quando o destino for visualização em Markdown renderizado (GitHub, PRs, documentação ou artefatos).
  - Use `graph TD` ou `graph LR` para mapas de módulos e `sequenceDiagram` para fluxos.

> **Regra de Ouro**: Sempre acompanhe o diagrama de um parágrafo conciso explicando o que o leitor deve notar (ex.: seta invertida, fronteira respeitada ou novo contrato introduzido).
