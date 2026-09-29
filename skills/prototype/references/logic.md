# Protótipo de Lógica

Um HTML único e autocontido, uma **demo compartilhável**, que permite a qualquer pessoa operar um modelo de estados clicando em botões. Use quando a pergunta é sobre **regra de negócio, transições de estado ou formato de dados**: o tipo de coisa que parece razoável no papel e só soa errada quando passa por casos reais.

Como é um arquivo sem nada para instalar, dá para entregá-lo a um não-desenvolvedor (designer, PM, especialista do domínio) e deixar que ele sinta o modelo por conta própria. Por isso a demo fala a língua dele, não a do código.

---

## 1. Quando é a forma certa

- "Não sei se essa máquina de estados trata o caso em que X e depois Y."
- "Esse modelo de dados consegue representar o caso em que..."
- "Quero sentir como a API deveria ser antes de escrevê-la."
- Qualquer situação em que alguém quer **apertar botões e ver o estado mudar**.

Se a pergunta é "como isso deveria parecer", é o ramo errado: use [`ui.md`](ui.md).

---

## 2. Processo

### 2.1. Declarar a pergunta

Antes de escrever código, escreva qual modelo de estados e qual pergunta estão sendo prototipados. Um parágrafo, no topo da demo, visível (não só num comentário). Deixar a pergunta explícita permite conferir depois se foi ela que o protótipo respondeu, com o usuário olhando agora ou voltando mais tarde.

### 2.2. Isolar a lógica num módulo portátil

A lógica que responde à pergunta fica num único bloco `<script>`, escrita como um módulo pequeno e puro, que poderia ser tirado dali e colocado no código real. A página em volta é descartável; esse módulo não.

A forma depende da pergunta:

- **Reducer puro** (`(state, action) => state`): quando as ações são eventos discretos e o estado é um valor só.
- **Máquina de estados** (estados e transições explícitos): quando "quais ações são permitidas agora" faz parte da pergunta.
- **Conjunto de funções puras** sobre um tipo de dado simples: quando não há estado corrente implícito, só transformações.
- **Classe ou módulo com métodos claros**: quando a lógica de fato é dona de um estado interno contínuo.

Escolha a forma que melhor serve à pergunta, **não** a mais fácil de ligar à página. Mantenha-a pura: sem DOM, sem `document`, sem handlers de botão lá dentro. A página chama o módulo; nada flui no sentido contrário. É isso que torna o protótipo útil depois: respondida a pergunta, o reducer, a máquina ou as funções validadas vão sozinhos para o módulo real.

### 2.3. Montar o HTML compartilhável

Um arquivo, HTML/CSS/JS puro: sem framework, sem bundler, sem servidor, tudo inline, para abrir com duplo clique e sobreviver a ser enviado por e-mail.

Escreva para um não-desenvolvedor. Todo rótulo está na **linguagem do domínio**, não do código: botões e estado se leem como o negócio, não como o reducer.

Hierarquia, de cima para baixo:

1. **Título e uma linha de explicação** do que a demo permite explorar (a pergunta da 2.1).
2. **Estado atual**: o estado relevante inteiro, num painel legível (campos rotulados, não um JSON cru), redesenhado a cada clique. Onde ajudar, destaque o que acabou de mudar.
3. **Botões livres**: um por ação, sempre disponíveis, para mexer no modelo em qualquer ordem.
4. **Roteiros guiados**: um **cenário** por aba. Cada aba tem uma descrição curta do cenário (a situação e o que observar) e, embaixo, os **botões a apertar**, na ordem. Cada passo é um botão real que executa a ação e avança. Começar um roteiro reinicia para um estado inicial conhecido, para o cenário rodar sempre igual.

Escolha cenários que mostrem os casos incômodos: o caminho feliz, um caso de borda difícil, uma tentativa de algo que deveria ser proibido.

Bonito, mas contido: tipografia limpa, espaço generoso, uma cor de destaque. Sem animações nem enfeites que disputem atenção com o estado e os botões.

### 2.4. Registrar a resposta e o protótipo

Registre a resposta (veredito e pergunta resolvida) na issue vinculada ou num commit. O módulo validado entra no módulo real: é a decisão, absorvida. O HTML vai para uma branch descartável `prototype/<nome>`, fora da principal e nunca mesclada, como fonte primária da decisão; deixe na issue um ponteiro para essa branch. Enviar a branch ao remoto só com confirmação do usuário.

---

## 3. Anti-padrões

- **Adicionar testes.** Um protótipo que precisa de testes deixou de ser protótipo.
- **Ligar ao banco real.** Estado em memória, a menos que a pergunta seja justamente sobre persistência.
- **Generalizar.** Nada de "e se depois quisermos suportar X". O protótipo responde a uma pergunta.
- **Misturar lógica e página.** Se o módulo puro referencia DOM, `document` ou handlers, ele não pode mais ser reaproveitado.
- **Usar framework, bundler ou servidor.** Um arquivo que abre com duplo clique; um app React ou um servidor de desenvolvimento acabam com o "compartilhável".
- **Levar a casca HTML para produção.** A página serve para ser clicada à mão. O que vale guardar é o módulo por trás dela.
