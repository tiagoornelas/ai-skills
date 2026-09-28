# Ocultação de Informação (e Vazamento)

> **Tese central**: cada módulo deve encapsular alguns **conhecimentos que representam decisões de design**. Esse conhecimento fica embutido na implementação e **não aparece na interface**. É a técnica mais importante para criar módulos profundos.

---

## Quando consultar

- Ao decidir o que cada módulo "sabe" e o que ele expõe.
- Ao perceber que uma mudança de formato, protocolo ou regra exigiria mexer em vários módulos.
- Ao decompor um fluxo em etapas (risco de decomposição temporal).
- Ao desenhar retornos de API, estruturas de dados públicas e valores padrão.

---

## 1. O que é ocultação de informação

- O conhecimento escondido costuma ser sobre **como** implementar um mecanismo. Exemplos:
  - Como armazenar informação numa B-tree e acessá-la de forma eficiente.
  - Como identificar o bloco físico em disco correspondente a cada bloco lógico de um arquivo.
  - Como implementar o protocolo TCP.
  - Como escalonar threads num processador multi-core.
  - Como fazer parsing de documentos JSON.
- A informação escondida inclui estruturas de dados e algoritmos, e também detalhes de mais baixo nível (tamanho de página) ou de mais alto nível (a hipótese de que a maioria dos arquivos é pequena).

### Por que reduz complexidade

1. **Simplifica a interface**: ela reflete uma visão mais simples e abstrata e omite detalhes. Isso reduz a carga cognitiva de quem usa.
2. **Facilita a evolução**: se uma informação está escondida, não há dependências dela fora do módulo. Uma mudança de design relacionada a essa informação afeta **apenas um módulo**.

### O que não é ocultação de informação

- **Tornar variáveis privadas não é, por si só, ocultação de informação.** Se a classe expõe getters e setters para cada campo, a representação continua exposta na prática.
- **Ocultação parcial também tem valor**: se uma funcionalidade só é necessária para poucos usuários e é acessada por métodos separados, ela fica escondida nos casos comuns, e isso já reduz a carga cognitiva da maioria.

---

## 2. Vazamento de informação (*information leakage*)

- É o oposto da ocultação: ocorre quando **uma decisão de design se reflete em vários módulos**. Isso cria dependência entre eles: qualquer mudança nessa decisão exige alterar todos os módulos envolvidos.
- Se uma informação aparece na interface de um módulo, ela vazou por definição. Interfaces mais simples tendem a vazar menos.
- **Vazamento pela porta dos fundos** (*back-door leakage*): a informação pode vazar mesmo sem aparecer em nenhuma interface. Exemplo: duas classes que conhecem o mesmo formato de arquivo, uma que lê e outra que escreve. Nenhuma interface menciona o formato, mas ambas dependem dele. Esse vazamento é pior porque não é óbvio.
- **Como corrigir**:
  - Se as classes afetadas são pequenas e intimamente ligadas à informação, **fundir** numa única classe.
  - Alternativamente, **extrair** a informação de todas elas e criar uma nova classe que a encapsula, com uma interface simples que abstrai os detalhes.

---

## 3. Decomposição temporal (*temporal decomposition*)

- Uma causa comum de vazamento. Na decomposição temporal, a estrutura do sistema **espelha a ordem temporal** em que as operações acontecem.
- Exemplo: uma aplicação que lê um arquivo num formato, modifica o conteúdo e escreve de volta. Decomposição temporal gera três classes: leitura, modificação e escrita. Leitura e escrita **ambas conhecem o formato**: vazamento. A solução é juntar os mecanismos centrais de leitura e escrita numa única classe, que é a dona do formato.
- É fácil cair nisso porque a ordem de execução é o que vem à cabeça ao escrever o código.
- **Regra**: ao desenhar módulos, focar no **conhecimento necessário para executar cada tarefa**, e não na ordem em que as tarefas acontecem.
- A ordem temporal geralmente importa e vai aparecer em algum lugar da aplicação, mas não deve ditar a estrutura de módulos, a menos que essa estrutura seja consistente com a ocultação de informação (por exemplo, etapas que usam informações totalmente diferentes).

---

## 4. Exemplo: um servidor HTTP

Um exercício recorrente é projetar um servidor HTTP simples. Erros e acertos comuns:

- **Classes rasas demais**: separar em uma classe para *ler* a requisição da rede e outra para *interpretar* (fazer parsing) dela. Ambas precisam conhecer boa parte do formato HTTP (por exemplo, para saber onde a requisição termina, é preciso interpretar headers como `Content-Length`). Resultado: vazamento. Melhor fundir em uma única classe que lê e interpreta.
- **Parâmetros de requisição**: uma boa interface esconde de onde o parâmetro veio (query string ou corpo da requisição) e entrega o valor já **decodificado**:

  ```java
  public String getParameter(String name) { ... }
  public int getIntParameter(String name) { ... }
  ```

  Isso esconde o formato de codificação e a distinção de origem, e o método para inteiros ainda esconde a conversão e o tratamento de erro.
- **Expor a representação interna** é um erro: um método que devolve o `Map` interno de parâmetros expõe a representação, permite que o chamador a modifique e impede a classe de mudá-la no futuro.
- **Valores padrão**: a interface de respostas deve fornecer padrões para o que quase todo mundo quer (versão do protocolo, header de data, etc.), para que quem usa não precise lidar com isso. Padrões são um exemplo de ocultação parcial e do princípio de que **o caso comum deve ser simples**. O melhor recurso é aquele que o usuário recebe sem precisar saber que existe.

---

## 5. Ocultação de informação dentro de uma classe

- O princípio também se aplica **internamente**. Métodos privados devem encapsular informação e ser usados de forma que o resto da classe não precise conhecê-la.
- Minimizar o número de lugares onde cada variável de instância é usada. Se uma variável é acessada em muitos métodos, há dependência entre eles; se é encapsulada por poucos métodos, as dependências diminuem.

---

## 6. Levando longe demais

- Ocultar só faz sentido se a informação **não é necessária fora do módulo**. Se quem usa precisa da informação, ela não deve ser escondida.
- Exemplo: se o desempenho de um módulo depende de parâmetros de configuração e diferentes usos precisam de valores diferentes, esses parâmetros precisam ser expostos. Mas o objetivo deve ser **minimizar** a necessidade de informação externa: é melhor que o módulo ajuste automaticamente sua configuração do que exponha parâmetros (ver [pull-complexity-downwards.md](pull-complexity-downwards.md)).
- É importante reconhecer qual informação é necessária fora do módulo e garantir que ela esteja exposta.

---

## Red flags

- **Vazamento de informação**: a mesma decisão de design (formato, protocolo, regra, estrutura) é usada em vários módulos.
- **Decomposição temporal**: a divisão em módulos segue a ordem de execução (ler → processar → escrever), e os módulos compartilham conhecimento.
- **Exposição de representação**: getters/setters para cada campo, retorno de coleções internas mutáveis, tipos internos na assinatura pública.
- **Excesso de exposição**: a API de um recurso muito usado obriga o usuário a aprender recursos raramente usados.

---

## Como aplicar

1. **Liste as decisões de design** do problema (formatos, protocolos, algoritmos, regras de negócio, hipóteses) e atribua cada uma a **exatamente um** módulo dono.
2. **Procure decisões com mais de um dono**: cada uma é vazamento. Proponha fusão ou extração para um módulo dono.
3. **Desconfie de módulos nomeados por etapas** (`Reader`, `Processor`, `Writer`, `Step1`...). Pergunte que conhecimento cada um usa; se compartilham conhecimento, reagrupe.
4. **Revise a interface pública** procurando representação interna vazada (estruturas mutáveis, tipos de infraestrutura, detalhes de armazenamento).
5. **Defina padrões** para tudo que o caso comum precisa.
6. **Confirme o que precisa sair**: informação que o chamador realmente precisa deve estar explícita no contrato.

Ao reportar ao humano, deixe explícito, por módulo: **o que ele esconde** (decisões de design) e **o que ele promete** (contrato).

---

## Relações

- Ocultação de informação é o que dá profundidade a um módulo: [deep-modules.md](deep-modules.md).
- Interfaces gerais escondem melhor: [general-purpose-modules.md](general-purpose-modules.md).
- Compartilhar informação é um motivo forte para juntar módulos: [together-or-apart.md](together-or-apart.md).
