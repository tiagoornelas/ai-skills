---
name: prototype
description: >-
  Constrói um protótipo descartável para responder a uma única pergunta de
  design que conversa não resolve: se uma lógica ou modelo de estados se
  sustenta (demo HTML interativa, com a lógica num módulo puro reaproveitável)
  ou como uma interface deveria parecer (mockup HTML avulso, fora do projeto,
  com variantes radicalmente diferentes lado a lado). Deve ser acionada quando o
  usuário quiser testar uma lógica ou explorar uma interface antes de construí-la,
  ou quando uma entrevista (grill-me) esbarrar numa pergunta de aparência ou
  comportamento.
argument-hint: "[a pergunta que o protótipo deve responder]"
---

# Prototype

Um protótipo é **código descartável que responde a uma pergunta**. A pergunta vem primeiro e decide a forma de tudo: um protótipo que responde à pergunta errada é desperdício, por melhor que pareça.

---

## 1. Escolher o ramo

Identifique qual pergunta está sendo respondida, pelo pedido do usuário, pelo código ao redor ou perguntando:

| Pergunta | Ramo | Artefato |
| :--- | :--- | :--- |
| **"Essa lógica / modelo de estados se sustenta?"** | [`references/logic.md`](references/logic.md) | Um HTML único e compartilhável, com botões livres e roteiros guiados em abas, que empurra o modelo pelos casos difíceis de raciocinar no papel e que um não-desenvolvedor consegue operar. |
| **"Como isso deveria parecer?"** | [`references/ui.md`](references/ui.md) | Um mockup HTML avulso, **fora do projeto**, que reproduz o design system real e mostra variantes radicalmente diferentes lado a lado. Nada é ligado ao app. |

Os dois ramos produzem artefatos muito diferentes: errar aqui desperdiça o protótipo inteiro. Se a pergunta for de fato ambígua e o usuário não estiver disponível, escolha o ramo que combina com o código ao redor (módulo de backend → lógica; página ou componente → UI) e declare a suposição no topo do protótipo.

Se a pergunta não cabe numa sessão ("como é o app inteiro?"), não é um protótipo: corte até uma pergunta só.

---

## 2. Regras dos dois ramos

1. **Descartável desde o início, e marcado como tal.** A demo de lógica fica ao lado do módulo que prototipa, com nome que deixa claro que não é produção. O mockup de UI fica **fora do projeto**: nada vai para o repositório, então não há o que confundir com produção.
2. **Trivial de rodar.** Os dois ramos geram um único HTML autocontido que se abre com duplo clique: sem comando, sem servidor de desenvolvimento.
3. **Sem persistência por padrão.** O estado vive em memória. Persistência é o que o protótipo *verifica*, não algo de que ele depende. Se a pergunta envolve banco de dados, use um banco ou arquivo de rascunho com nome claro, como `PROTOTYPE-apagar`.
4. **Sem acabamento.** Sem testes, sem tratamento de erro além do necessário para rodar, sem abstrações. No momento em que você endurece o protótipo (adiciona teste, liga o banco real, generaliza), parou de prototipar.
5. **Estado visível.** Depois de cada ação (lógica) ou lado a lado na página (UI), mostre o estado relevante inteiro, para o usuário ver o que mudou.
6. **Registrar ao terminar.** A **resposta** (o veredito e a pergunta que ele resolveu) é registrada na issue vinculada ou numa mensagem de commit. O **protótipo** segue o destino do seu ramo: na lógica, o módulo validado entra no código real e o HTML vai para uma branch descartável; na UI, o vencedor é reimplementado de verdade e o mockup é apagado.

---

## 3. Entregar e iterar

Abra o arquivo para o usuário ou passe o caminho. Os momentos que importam são *"espera, isso não devia ser possível"* ou *"ah, eu achava que X seria diferente"*: são os bugs **da ideia**, que é o objetivo. Se ele pedir novas ações, cenários ou variantes, acrescente. Protótipos evoluem.

Quando o protótipo foi acionado por outra skill (por exemplo, uma entrevista do [`grill-me`](../grill-me/SKILL.md)), devolva a ela a resposta em uma linha.

---

## 4. Validação de Sucesso

- [ ] A pergunta que o protótipo responde cabe em uma frase e está escrita no topo do artefato.
- [ ] O ramo escolhido corresponde à pergunta (lógica × aparência), ou a suposição foi declarada.
- [ ] O artefato é um único HTML autocontido que abre com duplo clique, com o estado visível.
- [ ] O mockup de UI não foi escrito dentro do repositório; a demo de lógica está marcada como protótipo.
- [ ] A resposta foi registrada, e o protótipo teve o destino do seu ramo: nada dele entrou na branch principal como produção.
