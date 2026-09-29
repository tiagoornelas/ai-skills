# Comentários

> **Tese central**: explique-se **primeiro no código**, com nomes, tipos e estrutura. Comente só o que o código não consegue dizer: o porquê, a intenção, o que não é óbvio. Todo comentário é **direto e conciso**. Um comentário desnecessário é ruído; um comentário desatualizado é pior que nenhum.

---

## Quando consultar

- Ao escrever ou alterar código.
- Ao revisar os comentários de um diff.

---

## 1. Explique-se no código primeiro

- Antes de escrever um comentário que explica **o que** um trecho faz, tente torná-lo desnecessário: um nome melhor ([naming.md](naming.md)), uma subtarefa independente extraída ([functions.md](functions.md)), uma variável explicativa, um tipo nomeado.
- Só comente quando o código, já claro, ainda não disser tudo o que o leitor precisa saber.

---

## 2. O que comentar

Apenas o que não é óbvio a partir do código:

- **Interfaces públicas** (o que outros módulos usam): um comentário curto com o contrato, contendo só o que a assinatura não diz: o que promete, efeitos colaterais, erros, pré-condições, unidades. Não descreva a implementação.
- **O porquê** de uma decisão que parece estranha: contorno de um bug externo, limitação de uma biblioteca, requisito de negócio, otimização medida.
- **Aviso de consequência**: o que quebra se alguém mudar aquilo.
- **Invariantes e premissas** que o código não consegue expressar por tipo ou asserção.
- **Fluxos indiretos**: quando e por quem um handler ou callback é disparado.

**Funções e classes não públicas não levam comentário de documentação.** Se precisam de explicação para serem usadas, melhore primeiro o nome e a assinatura. Se ainda restar algo não óbvio (um efeito colateral inevitável, uma unidade), basta um comentário de uma linha.

---

## 3. O que não comentar

- **Redundante**: repete o que o código já diz.
- **Enganoso**: diz algo diferente do que o código faz.
- **Documentação por obrigação**: cabeçalho em função interna, docstring que só repete o nome e os parâmetros.
- **Histórico**: diário de mudanças, autoria, datas. Isso é do git.
- **Código comentado**: apague. O histórico fica no git.
- **Marcadores**: de posição, de seção, de fim de bloco.
- **Informação não local**: comentário que descreve outra parte do sistema, e que vai desatualizar quando ela mudar.

---

## 4. Manter comentários corretos

- **Perto do código**: comentário de interface junto à declaração; comentário de implementação dentro do corpo, perto do trecho que explica. Quanto mais longe, maior a chance de desatualizar.
- **No código, não no commit**: se a informação é necessária para entender ou mudar o código no futuro, ela vai no código. A mensagem de commit resume e aponta.
- **Uma vez só**: cada decisão documentada num único lugar, o mais óbvio para quem vai precisar dela. Nos outros, referencie.
- **O quê e porquê duram mais que o como**: comentários de intenção e invariante não mudam a cada ajuste de implementação.
- **Revise o diff**: toda mudança de comportamento deve estar refletida nos comentários que falam dela.

---

## Red flags

- Comentário que explica o que um trecho confuso faz, em vez de o trecho ser esclarecido.
- Comentário que contradiz o código.
- Diff que muda comportamento sem tocar nos comentários que o descrevem.
- Interface pública sem nenhuma indicação do que promete além da assinatura.
- A explicação de por que o código é assim só existe na mensagem de commit ou no ticket.
- Docstrings em funções internas que só repetem nome e parâmetros.
- Código comentado.

---

## Como aplicar

- **Ao escrever**: esclareça o código primeiro; depois comente só o que sobrar de não óbvio, em poucas palavras.
- **Ao revisar**: comentário **enganoso ou desatualizado** tem cenário concreto (o próximo leitor vai se enganar) e vale corrigir. Comentário apenas redundante ou de ruído não tem cenário concreto: não vale apontar, mas não deve ser escrito.

---

## Relações

- Nomes que dispensam comentários: [naming.md](naming.md).
- Extrair para esclarecer: [functions.md](functions.md).
- Obscuridade e a informação que o leitor precisa: [obvious-code.md](../../software-designing/references/obvious-code.md).
- A parte informal de uma interface, que só os comentários descrevem: [deep-modules.md](../../software-designing/references/deep-modules.md).
