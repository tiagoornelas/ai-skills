---
name: design-it-twice
description: >-
  Orquestra a prática de projetar duas (ou mais) vezes: gera alternativas de
  design radicalmente diferentes para uma mesma decisão, cada uma produzida por
  uma execução isolada do arquiteto software-designing, compara-as com critérios
  explícitos e leva ao humano uma recomendação (escolha, combinação ou novo
  design). Deve ser acionada, pelo humano ou por outros agentes, antes de fixar
  qualquer decisão de design cara de mudar depois — decomposição de sistema,
  interface de módulo, contrato de API ou mecanismo central.
---

# Design It Twice

Garante que nenhuma decisão de design importante seja fixada com base na primeira ideia. O conceito completo está em [references/design-it-twice.md](references/design-it-twice.md); esta skill é o procedimento.

---

## 1. Princípio Fundamental

Esta skill **não substitui** o arquiteto. Ela o executa **uma vez por alternativa**, em contextos isolados, e depois conduz a comparação. Todo o raciocínio de design de cada alternativa vem de [`software-designing`](../software-designing/SKILL.md) e de suas referências.

---

## 2. Quando Usar e em Qual Escala

| Situação | Execução |
| :--- | :--- |
| Decisão pequena (interface de uma função ou classe, um contrato local) | **Em linha**: esboce as alternativas no próprio contexto, só no nível da interface. |
| Decisão grande (decomposição de sistema, API pública, mecanismo central, fronteiras entre serviços) | **Subagentes isolados**: uma execução de `software-designing` por alternativa (seção 4). |
| Decisão trivial ou facilmente reversível | Não use. Registre só a escolha. |

O isolamento importa: um agente que já desenhou a alternativa A tende a ancorar nela e produzir variações de A. Contextos separados, cada um obrigado a seguir um eixo diferente, geram alternativas realmente distintas.

---

## 3. Fluxo de Trabalho

### Passo 1: Enquadrar uma única vez
Execute os Passos 1 e 2 de [`software-designing`](../software-designing/SKILL.md) (enquadrar o problema e diagnosticar a complexidade) **uma só vez**, e consolide o resultado num **Pacote de Contexto**:
- o problema, os consumidores e as restrições, *ipsis litteris* do que foi recebido do humano ou do agente chamador;
- o design atual relevante, se houver código;
- a **decisão a ser tomada**, formulada como pergunta (ex.: "qual deve ser a interface do módulo de texto?");
- o critério principal de comparação (por padrão: facilidade de uso para quem consome).

Perguntas em aberto que só o humano responde devem ser resolvidas **antes** de gerar alternativas. Senão cada alternativa vai inventar uma resposta diferente.

### Passo 2: Escolher eixos radicalmente diferentes
Antes de desenhar qualquer coisa, defina **de 2 a 4 eixos de design**, cada um com uma premissa central diferente. Exemplos de eixos que tendem a gerar alternativas distintas:
- **Unidade da abstração**: por linha × por caractere × por intervalo; por registro × por lote × por fluxo.
- **Onde mora o conhecimento**: centralizado num módulo profundo × distribuído entre pares × empurrado para uma camada de plataforma.
- **Modelo de interação**: chamada síncrona × eventos × fila/lote; *push* × *pull*.
- **Modelo de estado**: estado mutável encapsulado × dados imutáveis + transformações × log de eventos.
- **Fronteira**: tudo num módulo × separação geral/especializado × serviço independente.

Descarte eixos que produziriam a mesma decomposição com outro nome.

### Passo 3: Gerar cada alternativa isoladamente
Para cada eixo, execute `software-designing` com a instrução da seção 4. Cada execução produz **uma única alternativa**, levada a sério, sem comparar com as outras.

### Passo 4: Comparar
Monte a matriz de comparação (seção 5), com os critérios de [references/design-it-twice.md](references/design-it-twice.md) (seção 3). Para cada alternativa, liste prós e contras honestos, usando os termos das referências do arquiteto: profundidade, vazamento, generalidade, camadas, onde mora a complexidade, modos de falha e obviedade.

### Passo 5: Escolher, combinar ou recomeçar
- **Uma vence com clareza** → recomende-a.
- **Cada uma tem uma força diferente** → proponha uma **combinação**, explicitando de qual alternativa vem cada característica. A combinação deve passar de novo pelas lentes de `software-designing` para confirmar que é coerente.
- **Nenhuma convence** → use as fraquezas encontradas para definir um novo eixo e volte ao Passo 3 (uma rodada extra, no máximo; se ainda não convencer, leve ao humano como problema mal entendido).

### Passo 6: Levar ao humano pela Camada Humana
Apresente, com [`visualize-it`](../visualize-it/SKILL.md), um mapa de módulos por alternativa (lado a lado) e a matriz de comparação. A escolha entre alternativas que mudam contratos, fronteiras ou direção de dependências é **decisão do humano**: apresente a recomendação e peça a decisão. No modo agente, marque-a como pendente.

Depois da decisão, o design escolhido segue o Passo 6 de `software-designing` (registro de decisão e entrega para [`coding`](../coding/SKILL.md)). As alternativas descartadas e o motivo do descarte entram no registro.

---

## 4. Delegação a Subagentes

Siga [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md): brief autossuficiente e caminhos de skills absolutos. Ferramenta por harness:
- **Claude Code**: `Agent` com tipo `general-purpose`, uma chamada por alternativa, **todas no mesmo turno**, para rodarem em paralelo.
- **Antigravity CLI**: `invoke_subagent` com `TypeName: "self"`.
- **Codex**: um sub-processo ou thread isolada por alternativa.

Prompt de cada subagente (preencha e repasse o Pacote de Contexto integralmente):

```markdown
Siga a skill `software-designing` (<skills>/software-designing/SKILL.md) no modo
"acionada por outro agente".

## Pacote de Contexto
<Pacote de Contexto completo, ipsis litteris>

## Seu eixo obrigatório
<nome do eixo + premissa central>. Projete a MELHOR solução possível que respeite
esta premissa. Não proponha alternativas fora dela e não a enfraqueça: outros
agentes estão cobrindo os outros eixos.

## Entrega
Um Design Brief com UMA alternativa (pule a tabela "Alternativas consideradas").
Inclua, obrigatoriamente: mapa de módulos, cartões de interface, modos de falha,
e uma seção "Fraquezas conhecidas" com os pontos fracos honestos desta abordagem.
Custo só em termos relativos (complexidade, risco, tamanho da mudança), sem
estimativa em dias nem fases.
Não implemente código.
```

---

## 5. Formato de Saída

```markdown
## Decisão em jogo
<a pergunta de design, em uma frase>

## Alternativas
### A — <nome do eixo>
<ideia central em 2–3 frases + mapa de módulos + interface principal>
### B — <nome do eixo>
...

## Matriz de comparação
| Critério | A | B | C |
| :--- | :--- | :--- | :--- |
| Facilidade de uso para quem consome (critério principal) | | | |
| Simplicidade da interface / profundidade | | | |
| Generalidade | | | |
| Vazamento de informação | | | |
| Modos de falha expostos | | | |
| Eficiência / custo relativo de implementação (sem prazo) | | | |
| Facilidade de mudança provável | | | |

## Recomendação
<escolha | combinação (qual característica vem de qual alternativa) | recomeço>
<justificativa nos termos das referências>

## Decisão pendente (Camada Humana)
<opções, recomendação e custo de errar>
```

---

## 6. Validação de Sucesso

- [ ] Existem **pelo menos duas** alternativas, e cada uma parte de uma **premissa central diferente** (não são variações de nome ou de detalhe).
- [ ] Nenhuma alternativa é espantalho: cada uma é a melhor versão possível do seu eixo e lista suas próprias fraquezas.
- [ ] Todas as alternativas partiram do **mesmo Pacote de Contexto**, repassado sem perda.
- [ ] A matriz compara todas as alternativas nos mesmos critérios, com a facilidade de uso para quem consome como critério principal.
- [ ] A recomendação diz explicitamente se é escolha, combinação ou recomeço, e a combinação (se houver) passou de novo pelas lentes do arquiteto.
- [ ] A decisão final foi tomada pelo humano (ou marcada como pendente no modo agente), e as alternativas descartadas foram registradas com o motivo.
