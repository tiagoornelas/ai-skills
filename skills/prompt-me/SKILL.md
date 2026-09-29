---
name: prompt-me
description: >-
  Guia o usuário, passo a passo, numa tarefa que só ele consegue executar (login
  interativo, ação em outro sistema ou painel web, configuração de hardware ou de
  conta, aprovação manual, qualquer coisa fora do alcance do agente). Entrega um
  passo por vez, espera a confirmação, tira dúvidas e corrige a rota quando algo
  dá errado. Deve ser acionada quando o usuário pedir para ser guiado numa tarefa
  manual, ou quando um fluxo do agente esbarrar numa etapa que só o humano pode
  realizar.
argument-hint: "[a tarefa manual a realizar]"
---

# Prompt Me

Para o momento em que o trabalho não pode (ou não deve) ser feito pelo agente. Quem executa é o usuário, com as próprias mãos; o agente **indica o caminho, confere cada passo e responde às dúvidas**. Não faz o passo no lugar dele.

---

## 1. Entender a tarefa antes de guiar

1. **Confirme o objetivo em uma linha**: o que precisa estar diferente quando a tarefa acabar.
2. **Investigue o contexto** que o agente consegue ler: sistema operacional, versões instaladas, arquivos de configuração, documentação oficial da ferramenta. Guiar com base num menu que não existe mais faz o usuário perder mais tempo do que a tarefa em si.
3. **Pré-requisitos**: diga de uma vez o que ter em mãos antes de começar (acesso, senha, dispositivo, permissão de admin). Se faltar algo, é melhor saber agora.
4. **Monte o roteiro mentalmente** e estime o total de passos (`N`). Não mostre o roteiro inteiro.

Se houver mais de um caminho razoável (ex.: pela interface web ou pelo CLI), pergunte qual o usuário prefere, com uma recomendação.

---

## 2. Um passo por mensagem

Cada passo tem uma ação só, que se lê e executa em segundos, e diz como saber se deu certo.

```markdown
**Passo 2 de 5** — Autorizar o dispositivo

**Faça:** abra Configurações → Privacidade → clique em **Autorizar dispositivo**.

**Deu certo se:** aparecer "Dispositivo autorizado" com a data de hoje.

Me diga **feito**, **travei** ou mande sua dúvida.
```

- **Numere sempre** (`Passo X de N`). Se o roteiro mudar, atualize o `N` e diga isso.
- **Texto exato**: nomes de botões, menus e campos entre `**negrito**`; comandos em bloco de código prontos para copiar.
- **Espere a resposta** antes do próximo passo. Uma resposta ambígua ("ok", "acho que foi") pede a confirmação do critério de sucesso.
- **Verifique o que o agente consegue verificar**: se o resultado aparece num arquivo, comando ou API a que o agente tem acesso, confira você mesmo antes de seguir, em vez de só confiar no "feito".
- **Incerteza declarada**: se não tiver certeza de como a tela está, diga isso e peça ao usuário o que ele vê (texto da tela ou print). Não invente localização de botão.

---

## 3. Dúvidas e tropeços

- **Dúvida** no meio do passo: responda de forma curta e volte ao mesmo passo. Não avance sem a confirmação.
- **Erro ou trava**: peça a evidência (mensagem exata, print, saída do comando), diagnostique e mande o passo corrigido, ainda um de cada vez. Se o problema mudar o plano, diga o novo `N`.
- **Beco sem saída** (sem permissão, recurso indisponível, a ferramenta não oferece a opção): pare, explique o bloqueio e ofereça alternativas. Não empurre o usuário para contornos arriscados.

---

## 4. Segurança

- **Nunca peça segredos no chat**: senhas, tokens, chaves privadas ou códigos 2FA. Quando um segredo precisa chegar a um arquivo ou variável, mostre como o usuário o coloca lá sem colar na conversa.
- **Avise antes do irreversível**: passos que apagam, revogam, publicam, cobram ou afetam outras pessoas levam `⚠️` e uma linha dizendo o que acontece e se dá para desfazer. Espere a confirmação explícita.
- **Não rebaixe a segurança para facilitar** (desativar 2FA, dar permissão ampla, desligar verificação) sem dizer o custo e oferecer o caminho seguro primeiro.

---

## 5. Encerrar

Quando o último passo for confirmado:

```markdown
✅ **Concluído:** <o que ficou diferente, em uma linha>

- <o que foi feito, em 2–4 tópicos curtos>
- <o que o usuário deve guardar ou lembrar, se houver: onde ficou a config, quando o token expira>
```

Se esta skill foi acionada no meio de outro fluxo, devolva o controle a ele e diga qual etapa retoma.

---

## 6. Não fazer

- Despejar o roteiro inteiro numa mensagem.
- Executar a ação do usuário "para adiantar", ou avançar sem confirmação.
- Encher o passo de contexto: explicação longa só quando o usuário pedir.

---

## 7. Validação de Sucesso

- [ ] O objetivo foi confirmado em uma linha e os pré-requisitos foram listados antes do primeiro passo.
- [ ] Cada mensagem trouxe um único passo numerado (`X de N`), com ação exata e critério de sucesso.
- [ ] Nenhum passo avançou sem a confirmação do usuário; o que o agente podia verificar, ele verificou.
- [ ] Nenhum segredo foi pedido no chat, e todo passo irreversível foi sinalizado e confirmado.
- [ ] O encerramento resumiu o que mudou e, se aplicável, devolveu o controle ao fluxo de origem.
