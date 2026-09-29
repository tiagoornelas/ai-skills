---
name: handoff
description: >-
  Compacta a conversa atual num documento de handoff, um único arquivo Markdown
  gravado no diretório temporário do sistema, para que um agente novo retome o
  trabalho em outro harness, outro diretório, com um colega ou numa tarefa
  paralela bifurcada da sessão atual. Referencia artefatos existentes em vez de
  copiá-los, separa o que foi verificado do que foi assumido, sugere as skills do
  próximo agente e remove dados sensíveis. Deve ser acionada somente quando o
  usuário pedir um handoff.
disable-model-invocation: true
argument-hint: "[para que a próxima sessão será usada]"
---

# Handoff

Transforma a conversa num **documento de trânsito**: o que está em andamento, por quê e o que vem a seguir, num arquivo que um agente novo lê para continuar. O ganho é **portabilidade**, não compressão.

---

## 1. Quando vale um handoff

Um arquivo só é necessário quando o trabalho precisa **viajar**:

| Situação | Por que um arquivo |
| :--- | :--- |
| Trocar de harness (ex.: Claude Code → Codex) | O novo harness não vê o contexto do anterior. |
| Mudar de diretório ou repositório | Por exemplo, para rodar um [`prototype`](../prototype/SKILL.md) em outro lugar. |
| Passar o trabalho a um colega | Ele precisa de algo que consiga ler. |
| Bifurcar uma tarefa paralela | Você continua nesta sessão; um segundo agente leva a bifurcação. |

Se nada vai viajar (mesmo harness, mesmo diretório, só mudando de fase), diga isso em uma linha: compactar ou limpar o contexto pelo próprio harness resolve melhor. Se o usuário ainda quiser o handoff, siga.

---

## 2. Ajustar ao próximo passo

Se o usuário passou um argumento, ele descreve **para que a próxima sessão será usada**. Escreva o documento para essa tarefa: guarde o raciocínio que pesa sobre ela e corte o que não pesa. Sem argumento, escreva para continuar o trabalho em andamento.

---

## 3. Conteúdo do documento

```markdown
# Handoff — <tema em poucas palavras>

**Próxima sessão:** <para que ela será usada>
**Origem:** <repositório/diretório, branch, harness>

## Objetivo
<o que o trabalho quer alcançar, em 1–3 frases>

## Estado atual
- **Feito:** <o que está pronto, com evidência: commit, PR, teste>
- **Em andamento:** <o que estava sendo feito ao parar>
- **Próximos passos:** <em ordem>

## Decisões e porquês
- <decisão tomada> — <por que, e o que foi descartado>

## Verificado × assumido
- ✅ <fato verificado na sessão, e como>
- ❓ <crença não verificada, a confirmar antes de agir sobre ela>

## Referências
- <spec, issue, PR, commit, ADR, arquivo — por link ou caminho>

## Skills sugeridas
- `<skill>` — <para quê, nesta próxima sessão>
```

Regras:

- **Não duplique o que já está escrito.** Specs, planos, ADRs, issues, commits e diffs entram como link ou caminho, nunca copiados. O documento fica pequeno e o detalhe continua num lugar só.
- **Separe fato de crença.** O próximo agente trata o documento como contrato e não vai reconferir. Uma afirmação do tipo "X não existe" ou "Y está pronto" que a sessão nunca verificou vira premissa falsa: rebaixe-a para ❓.
- **Guarde o porquê**, não só o quê: as decisões e o que foi descartado são o que um resumo costuma perder.
- **Skills sugeridas**: nomeie as skills que o próximo agente deve acionar, pelo nome com que o harness de destino as conhece.
- **Para um colega**, caminhos da máquina não servem (`AGENTS.md`, seção 2): use links de issue, PR e commit, ou reescreva a informação.
- **Remova dados sensíveis**: chaves de API, tokens, senhas e dados pessoais. Nunca entram no documento.

---

## 4. Gravar e entregar

1. Grave o arquivo no **diretório temporário do sistema operacional**, nunca no workspace: é um documento de trânsito, não um artefato a manter.
2. **Devolva o caminho completo** ao usuário. Avise que o diretório temporário pode ser limpo entre sessões ou no reboot: se a próxima sessão não começa logo, ou roda noutro harness, ele deve copiar o arquivo para um lugar durável. O mesmo vale para qualquer arquivo temporário que o documento referencie.
3. Diga como retomar: na sessão nova, **apontar para o arquivo** ("leia este arquivo e continue"), em vez de colar o resumo num comando de shell, onde crases e `$(...)` corrompem o texto em silêncio.
4. Peça ao usuário que leia o documento antes de entregá-lo e rebaixe o que ele sabe ser só suposição.

Na bifurcação, esta sessão continua intacta: não encerre nem limpe o contexto atual.

---

## 5. Validação de Sucesso

- [ ] O handoff se justificava (o trabalho vai viajar), ou o usuário confirmou que o quer mesmo assim.
- [ ] O documento está no diretório temporário do sistema, fora do workspace, e o caminho completo foi devolvido com o aviso de volatilidade.
- [ ] Artefatos existentes aparecem como link ou caminho, sem texto copiado; para um colega, sem caminhos locais.
- [ ] Toda afirmação não verificada está marcada como ❓.
- [ ] A seção de skills sugeridas existe e serve à próxima sessão declarada.
- [ ] Nenhuma chave, token, senha ou dado pessoal está no documento.
