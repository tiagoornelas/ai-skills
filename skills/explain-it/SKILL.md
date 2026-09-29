---
name: explain-it
description: >-
  Explica código, arquivos, fluxos ou conceitos técnicos de forma didática, visual e estruturada, como se estivesse orientando um desenvolvedor novo no projeto. Utiliza visualize-it para suporte gráfico.
disable-model-invocation: true
argument-hint: "[o que explicar — por padrão o último tópico discutido]"
---

# Explain It

Skill didática para explicar componentes, fluxos e decisões técnicas.

---

## 1. Princípio Operacional

Explique o assunto com foco em **clareza, intencionalidade e estrutura**:
- Seja didático e objetivo, evitando jargões sem explicação contextual.
- Utilize visualização: acione obrigatoriamente a skill [`visualize-it`](../visualize-it/SKILL.md) sempre que houver relações estruturais, sequência de chamadas ou modelos de estado.
- Responda no mesmo idioma em que o usuário se comunicou.

---

## 2. Estrutura da Explicação

1. **Alvo da Explicação**: Se nenhum argumento for fornecido, explique o último componente, arquivo ou fluxo discutido na conversa.
2. **O Que É e Qual o Propósito**: Explicação em 1 a 2 frases do objetivo daquele elemento no sistema.
3. **Visão Estrutural / Fluxo (Visual)**: Diagrama em ASCII ou Mermaid (via `visualize-it`) mostrando como ele interage com o restante da aplicação.
4. **Pontos de Atenção**: Casos de borda, regras de negócio críticas ou armadilhas comuns.
5. **Resumo / Takeaway**: Conclusão em tópicos curtos.

---

## 3. Validação de Sucesso

- [ ] O alvo da explicação foi identificado e contextualizado em 1–2 frases.
- [ ] Inclui representação visual via [`visualize-it`](../visualize-it/SKILL.md) quando há relações estruturais, sequências ou estados.
- [ ] Pontos de atenção e regras críticas foram destacados sem jargões desnecessários.
- [ ] A explicação foi concluída com takeaway conciso em tópicos curtos.
