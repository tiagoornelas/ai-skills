---
name: agent-self-review
description: >-
  Portão de qualidade autônomo executado pelo próprio agente sobre seu código antes da revisão humana. Analisa ferramentas estáticas, regras do projeto, cobertura da Definition of Done (DoD), sanidade de testes e qualidade do código abaixo dos contratos, num loop de auto-correção com orçamento e limite de rodadas, até aprovação.
---

# Agent Self-Review

Portão de qualidade pré-humano executado de forma autônoma pelo agente de código.

---

## 1. Princípio Operacional

O objetivo é que nenhum erro mecânico, quebra de tipagem, regressão de linter, violação de regra do projeto ou falta de cobertura da DoD chegue até o desenvolvedor humano.

O objetivo **não** é código perfeito. É código **correto, coberto e sem problemas que custem caro**. Uma melhoria marginal nunca justifica mais uma rodada do loop. O agente busca o 80/20: poucas correções, as de maior impacto, e para.

A "tolerância zero" à complexidade de [`software-designing`](../software-designing/SKILL.md) vale para **decisões de design**. Abaixo dos contratos, vale o orçamento da seção 5.

O loop é **avaliar → corrigir → reavaliar**, com as regras de convergência da seção 5.

---

## 2. Classes de Achado

Todo achado cai numa destas quatro classes. A classe decide o que fazer com ele.

| Classe | O que é | Ação |
| :--- | :--- | :--- |
| **Blocking** | Objetivo e verificável: falha de ferramental ou teste, violação de regra documentada do projeto, comportamento da DoD sem cobertura e sem declaração. | Corrigir sempre. |
| **Should fix** | Julgamento **com cenário concreto**: dá para dizer em uma frase qual bug provável, qual mudança cara ou qual confusão do leitor ele causa. | Corrigir dentro do orçamento (seção 5) ou justificar em uma linha por que fica. |
| **Descartar** | Julgamento sem cenário concreto, preferência de estilo, "poderia ser mais elegante". | Não corrigir e não registrar. |
| **Escalar** | A correção mudaria um contrato público, uma fronteira de módulo ou a direção das dependências. | Não aplicar. Registrar como pendência da Camada Humana. |

Na dúvida entre **Should fix** e **Descartar**: se o cenário concreto não vem à mente de imediato, descarte.

---

## 3. Escopo

- Avalie **só o que a tarefa criou ou alterou**. Problemas pré-existentes em código não tocado ficam fora, mesmo que sejam reais.
- Exceção: se um problema pré-existente impede o ferramental de passar, trate-o como **Escalar**, e não como uma limpeza a fazer.

---

## 4. As Fases de Verificação

### Fase 1: Ferramental Estático e Testes (objetiva → Blocking)
- Execute os linters, verificadores de tipo (`tsc`, `mypy`, etc.) e a suíte de testes do projeto.
- Corrija qualquer erro de sintaxe, estilo, tipagem ou teste quebrado. Não silencie alertas com anotações de supressão sem justificativa imperativa.

### Fase 2: Regras do Projeto (objetiva → Blocking)
- Leia as regras documentadas: `AGENTS.md`/`CLAUDE.md` do repositório e tudo em `docs/rules/`, se existir.
- Violação de regra **documentada** é **Blocking**. Julgamentos gerais de qualidade não entram aqui: ficam na Fase 5.

### Fase 3: Cobertura BDD da Definition of Done (objetiva → Blocking)
Para cada requisito ou critério de aceite da tarefa:
1. **Verificado por código**: confirme que existe um teste que observa o comportamento pela interface pública, conforme [testing.md](../coding/references/testing.md). Testes que observam detalhes internos ou algo adjacente não contam como cobertura.
2. **Não testável por código**: se o comportamento não é testável por código ([testing.md](../coding/references/testing.md), seção 5), declare explicitamente:
   - qual é o comportamento;
   - por que não é testável via código;
   - como foi verificado alternativamente;
   - o passo a passo exato para o humano validar manualmente.

3. **Falta infraestrutura**: se o comportamento só seria testável com infraestrutura que o projeto não tem, declare-o como no item 2 e registre a falta como **Escalar**. Não construa a infraestrutura.

> 🚨 Um comportamento da DoD sem teste automatizado e sem declaração explícita é **Blocking**.

### Fase 4: Sanidade dos Testes (julgamento → Should fix)
- Aplique [testing.md](../coding/references/testing.md) aos testes da tarefa. Teste com cenário concreto de quebra sem mudança de comportamento (acoplado a texto, estrutura ou internos), ou que exponha internos só para testar, é **Should fix**, dentro do orçamento da seção 5.

### Fase 5: Qualidade do Código (julgamento → Should fix)
- Aplique as referências de [`coding`](../coding/SKILL.md) (nomes, funções, comentários, tratamento de erro e code smells) ao código da tarefa, seguindo a prioridade por impacto de [code-smells.md](../coding/references/code-smells.md) (risco de bug → custo de mudança → legibilidade).
- Tradução para as classes da seção 2: com cenário concreto → **Should fix**; sem cenário concreto → **Descartar**; mudaria contrato ou fronteira → **Escalar**.
- Toda correção segue [refactoring-principles.md](../coding/references/refactoring-principles.md): comportamento preservado, testes verdes.
- Smells na escala de módulo ou de contrato são **Escalar**, nunca correção local.

---

## 5. Loop e Convergência

### Ordem
Rode primeiro as fases objetivas (1, 2, 3) e corrija os **Blocking**. Só depois rode as fases de julgamento (4, 5), sobre o código já corrigido.

### Orçamento
- No máximo **5 correções Should fix** por tarefa, somando as fases 4 e 5, escolhidas pelo maior impacto.
- Achados de julgamento além do orçamento são **descartados**, não adiados.

### Reavaliação
- Depois de corrigir, rode de novo as fases **1, 2 e 3** completas. São baratas e objetivas.
- As fases **4 e 5 não rodam de novo** sobre o código inteiro. Verifique apenas se as linhas alteradas pelas correções continuam passando nas fases 1–3.
- **Sem achados de segunda ordem**: um smell que aparece no código produzido por uma correção não abre uma nova rodada de julgamento.

### Limite de rodadas
- No máximo **3 rodadas** de avaliar → corrigir → reavaliar.
- Se ainda houver **Blocking** depois da 3ª rodada, pare. Registre o impedimento (o que falha, o que foi tentado) como pendência para o humano. Não continue tentando.

### Anti-oscilação
- Se uma correção desfaria uma correção anterior, ou um achado contradiz uma decisão já tomada nesta revisão, **mantenha a versão atual** e siga em frente.

### Commits
- As correções do self-review são commits separados, depois do commit da implementação, seguindo [`commit`](../commit/SKILL.md).

---

## 6. Veredito

A entrega está **clean** no nível do agente quando:

- não há **Blocking** (ou o impedimento restante foi registrado depois da 3ª rodada);
- cada **Should fix** reportado foi corrigido ou tem justificativa de uma linha;
- cada item **Escalar** está listado como pendência da Camada Humana.

Registre, em poucas linhas, para rastreabilidade: o que foi corrigido, o que ficou justificado e o que foi escalado. Achados descartados não são registrados.

---

## 7. Validação de Sucesso

- [ ] As fases objetivas (1–3) rodaram antes das de julgamento (4–5).
- [ ] Só o código da tarefa foi avaliado.
- [ ] No máximo 5 correções Should fix e no máximo 3 rodadas.
- [ ] Nenhuma rodada nova foi aberta por achados de segunda ordem.
- [ ] Nenhuma mudança de contrato, fronteira ou direção de dependência foi aplicada: tudo isso foi escalado.
- [ ] Os testes passam depois da última correção.
