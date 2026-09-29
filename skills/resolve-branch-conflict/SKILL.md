---
name: resolve-branch-conflict
description: >-
  Conduz, junto com o usuário, a resolução de conflitos entre duas branches (ou
  entre um PR e sua base): mostra visualmente onde e por que os trabalhos
  paralelos colidiram, entende a intenção de cada lado, separa o que se resolve
  mecanicamente do que exige composição cuidadosa, detecta conflitos semânticos
  que o Git não acusa e resolve preservando o comportamento e a arquitetura dos
  dois trabalhos, levando ao usuário as decisões que forem dele. Deve ser acionada
  quando o usuário pedir ajuda para entender ou resolver conflitos de merge ou
  rebase entre branches ou num PR.
disable-model-invocation: true
argument-hint: "[número/URL do PR, ou duas branches: <nossa> <deles>]"
---

# Resolve Branch Conflict

Um conflito é o sinal de que duas pessoas mexeram na mesma camada **sem saber uma da outra**. Resolver bem não é escolher um lado: é entregar o que **os dois** trabalhos pretendiam, de um jeito que nenhum dos autores estranharia, e que continue escalando quando o próximo trabalho paralelo chegar.

> O agente entende, classifica, propõe e executa. **Descartar o trabalho de alguém, mudar um contrato ou escolher entre designs é decisão do usuário.**

Usa [`visualize-it`](../visualize-it/SKILL.md) para mostrar a colisão, [`software-designing`](../software-designing/SKILL.md) quando a resolução toca design, e [`coding`](../coding/SKILL.md) para escrever o código resolvido. O catálogo de padrões de conflito e as receitas de cada classe estão em [`references/conflict-patterns.md`](references/conflict-patterns.md).

---

## 1. Fixar as duas pontas

- **PR**: `gh pr view <pr> --json number,title,body,url,author,baseRefName,headRefName,commits`. *Nossa* = head do PR; *deles* = base.
- **Duas branches**: a primeira é *nossa* (a que recebe a resolução); a segunda é *deles*. Se a ordem não estiver clara, pergunte.

Depois:

```bash
git fetch origin
git merge-base <nossa> <deles>                          # ponto de divergência
git merge-tree --write-tree --name-only <nossa> <deles> # conflitos textuais, sem tocar no working tree
git diff --name-only <merge-base> <nossa>                # tocado por nós
git diff --name-only <merge-base> <deles>                # tocado por eles
```

Confirme que as refs resolvem e que existe conflito (textual ou sobreposição de arquivos) **antes** de seguir. Sem sobreposição nenhuma, diga isso e pare.

**Não altere o working tree do usuário nesta fase.** Se ele estiver sujo, avise antes de qualquer merge.

---

## 2. Entender o trabalho paralelo

Para cada lado, reúna a intenção, não só o diff:

- `git log <merge-base>..<lado> --format='%h %an %s'`: commits e autores.
- Descrição do PR, issues vinculadas (Jira/GitHub) e mensagens de commit.
- Os trechos do diff de cada lado nos arquivos sobrepostos.

Resuma em uma frase por lado: **"Nós queríamos X. Eles queriam Y."** Se a intenção de um lado não estiver clara pelas evidências, diga isso e pergunte, em vez de supor.

Mostre a divergência com `visualize-it`:
- **Linha do tempo**: merge-base, commits de cada lado e onde cada um tocou a área em conflito.
- **Mapa de módulos** da sobreposição: quais módulos cada lado alterou, marcados na notação do `visualize-it` (🆕 🔧 🗑️ ⚠️), com os pontos de colisão em ⚠️.

---

## 3. Classificar cada ponto de conflito

Cada hunk em conflito, e cada sobreposição sem conflito textual, recebe uma classe (detalhes e receitas em [`references/conflict-patterns.md`](references/conflict-patterns.md)):

| Classe | Significado | Quem decide |
| :---: | :--- | :--- |
| 🟢 **Mecânico** | Mudanças independentes que só colidiram no texto: imports, entradas em listas, formatação, arquivos gerados, lockfiles. | Agente resolve; mostra o resumo. |
| 🟡 **Composição** | Os dois lados mexeram na mesma lógica com intenções compatíveis; a resolução precisa conter os dois comportamentos. | Agente propõe; usuário confirma. |
| 🔴 **Intenções em choque** | Intenções incompatíveis ou designs divergentes (um refatora enquanto o outro estende, os dois criam abstrações para a mesma coisa, regras de negócio contraditórias). | Usuário decide, com opções e recomendação. |
| ⚠️ **Semântico** | Sem conflito textual, mas quebra ao juntar: um lado mudou um contrato (assinatura, nome, formato, migração) e o outro adicionou uso do contrato antigo. | Tratado como 🟡 ou 🔴, conforme o caso. |

A classe ⚠️ é a que o Git não mostra. Para encontrá-la, cruze **os símbolos, contratos e esquemas alterados por um lado** com **o código novo do outro lado** (`git diff <merge-base> <lado> -- <arquivo>` e busca pelos símbolos). Na dúvida entre duas classes, use a mais alta.

---

## 4. Apresentar o mapa do conflito

```markdown
## Nós × Eles
- **Nós** (<branch>, <autores>): <intenção em uma frase>
- **Eles** (<branch>, <autores>): <intenção em uma frase>

<linha do tempo e mapa de módulos via visualize-it>

## Pontos de conflito — 🟢 N · 🟡 N · 🔴 N · ⚠️ N

| # | Local | Classe | Nós | Eles | Proposta |
| :-: | :--- | :-: | :--- | :--- | :--- |
| 1 | `src/a.ts:40-58` | 🟢 | adiciona import X | adiciona import Y | manter os dois |
| 2 | `src/b.ts:12-30` | 🟡 | valida CPF | normaliza CPF | normalizar, depois validar |
| 3 | `src/c.ts` + `src/d.ts:88` | ⚠️ | renomeia `getUser` → `findUser` | nova chamada a `getUser` | atualizar a chamada nova |
```

Para cada 🟡, 🔴 e ⚠️, mostre um cartão em três colunas (**base / nós / eles**) com o trecho mínimo que explica o conflito, seguido da proposta. Use `zdiff3` para enxergar a base nos marcadores: `git -c merge.conflictStyle=zdiff3 ...`.

Discuta com o usuário. Ele pode mudar classes, propostas e a ordem.

---

## 5. Decidir a estratégia de integração

Pergunte, com recomendação, se não estiver claro pela convenção do repositório:

- **Merge de *deles* em *nossa*** (recomendado por padrão): não reescreve histórico e é seguro em branch compartilhada.
- **Rebase de *nossa* sobre *deles***: histórico linear, mas reescreve commits; só em branch que só o usuário usa. Exige `push --force-with-lease` depois.

Faça a integração numa branch de trabalho ou num worktree (`git worktree add`), para que o estado original fique intacto até o usuário aprovar.

---

## 6. Resolver

Na ordem:

1. **🟢 Mecânicos em lote**, seguindo as receitas da referência. Arquivos gerados e lockfiles são **regenerados** pela ferramenta, não mesclados à mão.
2. **🟡 Composição e ⚠️ semânticos**, um por vez: escreva a resolução com a skill [`coding`](../coding/SKILL.md), mostre o resultado ao lado da base, de nós e deles, e siga após a confirmação.
3. **🔴 Intenções em choque**: leve ao usuário 2–3 opções, com o que cada uma preserva e perde de cada lado, e uma recomendação. Quando a escolha é de design (qual abstração fica, onde mora a regra, direção de dependência), aplique [`software-designing`](../software-designing/SKILL.md); se for cara de mudar depois, passe por [`design-it-twice`](../design-it-twice/SKILL.md).

Regras da resolução:

- **Os dois comportamentos sobrevivem**, a menos que o usuário decida o contrário. Nunca descarte um lado em silêncio (`--ours`/`--theirs` num arquivo inteiro só em 🟢 ou com decisão explícita).
- **Respeite o design de quem veio antes**: se *deles* já está na base (merged), o código novo de *nós* se adapta ao design deles, e não o contrário, salvo decisão do usuário.
- **Elegância, não empilhamento**: se a composição só fica certa com `if` para cada lado, é sinal de que falta um conceito; proponha-o (via `software-designing`) em vez de acumular ramos.
- **Sem escopo extra**: a resolução não aproveita para refatorar o que não está no conflito. Ideias de melhoria vão para a seção 8.
- Se a resolução muda o trabalho de outro autor de forma relevante, ofereça um rascunho curto de mensagem para avisá-lo.

---

## 7. Verificar

- [ ] Nenhum marcador restante: `git diff --check` e busca por `<<<<<<<`, `=======`, `>>>>>>>`.
- [ ] Build, linters e verificadores de tipo do projeto passam.
- [ ] **Os testes dos dois lados** passam; nenhum teste de um lado foi removido ou afrouxado para caber o outro.
- [ ] Cada intenção da seção 2 continua entregue: liste os comportamentos de *nós* e de *eles* e como cada um foi verificado (legenda de DoD do [`human-review`](../human-review/SKILL.md), seção 2.3).
- [ ] Os pontos ⚠️ foram exercitados por teste ou por execução.

Falha na verificação volta para a seção 6, não para o usuário, salvo se exigir decisão.

---

## 8. Concluir

1. Commit de merge (ou `rebase --continue`) com a skill [`commit`](../commit/SKILL.md). A mensagem registra as resoluções 🟡, 🔴 e ⚠️ e as decisões tomadas, para quem ler o histórico depois.
2. **Não faça push sem pedido.** Com pedido, mostre o comando (`--force-with-lease` se houve rebase) e confirme.
3. Feche com o resumo:

```markdown
## ✅ Conflito resolvido
- 🟢 N mecânicos · 🟡 N composições · 🔴 N decisões · ⚠️ N semânticos
- Decisões tomadas: <uma linha por decisão do usuário>
- Verificação: <build/testes/comportamentos>

## Pontos de atrito para o futuro
- <onde o trabalho paralelo colidiu por falta de uma fronteira, ponto de extensão ou contrato claro, com a sugestão — nada disso foi feito>
```

A última seção é o que faz o software escalar: cada conflito real aponta um lugar onde dois desenvolvedores não conseguiam trabalhar sem se esbarrar. Ofereça transformar esses pontos em tarefas com [`report-work`](../report-work/SKILL.md).

---

## 9. Validação de Sucesso

- [ ] As duas pontas e o merge-base foram fixados e validados antes de qualquer alteração; o working tree do usuário não foi alterado sem aviso.
- [ ] A intenção de cada lado foi declarada com evidência, e a divergência foi mostrada visualmente.
- [ ] Todo ponto de conflito, inclusive os semânticos sem conflito textual, tem classe e proposta.
- [ ] Todo 🔴 e todo descarte de trabalho alheio foram decididos pelo usuário.
- [ ] A verificação da seção 7 passou por completo, com os comportamentos dos dois lados preservados.
- [ ] Nada foi enviado ao remoto sem pedido e confirmação explícitos.
