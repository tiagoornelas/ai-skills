# Módulos Devem Ser Profundos

> **Tese central**: os melhores módulos são aqueles cuja **interface é muito mais simples que sua implementação**. Um módulo profundo oferece muita funcionalidade por trás de uma interface pequena, escondendo complexidade do resto do sistema.

---

## Quando consultar

- Ao definir novos módulos, classes, serviços, pacotes ou funções públicas.
- Ao avaliar se uma decomposição está gerando pedaços demais (e rasos demais).
- Ao revisar uma interface proposta e decidir se ela "paga o próprio custo".

---

## 1. Design modular

- O objetivo do design modular é decompor o sistema em módulos **relativamente independentes**, de modo que um desenvolvedor só precise entender uma pequena parte da complexidade total para trabalhar em qualquer um deles.
- "Módulo" é qualquer unidade de código com **interface e implementação**: uma classe, um subsistema, um serviço, uma função, um pacote.
- Independência total é impossível: módulos trabalham juntos chamando funções uns dos outros, então existem dependências. O objetivo é **minimizá-las**.

### Interface vs. implementação

- **Interface**: tudo o que um desenvolvedor trabalhando em *outro* módulo precisa saber para usar este. Descreve **o quê** o módulo faz, não **como**.
- **Implementação**: o código que cumpre as promessas da interface.
- Quem trabalha dentro de um módulo precisa entender a interface e a implementação dele, e as interfaces dos módulos que ele usa. **Não** precisa entender a implementação de outros módulos.

### Partes formais e informais da interface

- **Formal**: especificado explicitamente no código (assinaturas, nomes e tipos de parâmetros, tipo de retorno, exceções). A linguagem ou o compilador pode verificar.
- **Informal**: comportamento de alto nível, efeitos colaterais, restrições de ordem de chamada ("só chame `b` depois de `a`"), invariantes. Só pode ser descrito em comentários e documentação, e costuma ser **maior e mais complexa** que a parte formal.
- Uma interface bem especificada reduz as **incógnitas desconhecidas**: diz exatamente o que se precisa saber para usar o módulo.

### Várias implementações de uma mesma interface

- Quando uma interface tem várias implementações (adaptadores, drivers, provedores, uma versão em memória para testes), **todas precisam cumprir o contrato completo**, formal e informal. Quem usa a interface não pode precisar saber qual implementação recebeu.
- Uma implementação que exige pré-condições a mais, entrega garantias a menos, lança "não suportado" ou muda um efeito colateral **quebra o contrato**, mesmo que as assinaturas batam.
- O sintoma é o chamador verificar o tipo ou a origem da implementação para decidir o que fazer. Cada verificação dessas é conhecimento da implementação vazando para fora. Absorva a diferença dentro da própria implementação, ou num adaptador, em vez de espalhá-la pelos chamadores (ver [pull-complexity-downwards.md](pull-complexity-downwards.md)).

---

## 2. Abstração

- Abstração é uma **visão simplificada de uma entidade que omite detalhes sem importância**. Módulos fornecem abstrações por meio de suas interfaces.
- Quanto mais detalhes sem importância forem omitidos, melhor. Mas um detalhe só pode ser omitido **se não for importante** para quem usa.
- Dois modos de errar:
  1. **Incluir detalhes que não são importantes**: a abstração fica mais complicada do que precisa e aumenta a carga cognitiva de quem usa.
  2. **Omitir detalhes que são importantes**: gera obscuridade. Quem usa não tem a informação necessária. É uma **falsa abstração**: parece simples, mas não é.
- Exemplo: um sistema de arquivos omite como os blocos são escolhidos no disco; isso não importa para quem lê e escreve. Mas em alguns casos o momento em que os dados chegam ao armazenamento durável **importa** (ex.: um banco de dados que precisa garantir persistência após um crash), então a interface precisa expor algo como `flush`/`fsync`.

---

## 3. Profundidade: a metáfora do retângulo

```text
Módulo profundo                  Módulo raso
┌──────┐  ← interface (custo)    ┌──────────────────────┐ ← interface (custo)
│      │                         │                      │
│      │                         └──────────────────────┘
│      │  ← funcionalidade         ↑ pouca funcionalidade
│      │     (benefício)
│      │
└──────┘
```

- A área representa a funcionalidade entregue (benefício). A borda de cima representa a interface (custo, em complexidade imposta a quem usa).
- **Profundidade = benefício ÷ custo.** O melhor módulo entrega muita funcionalidade com uma interface pequena.

### Exemplos canônicos de módulos profundos

- **I/O de arquivos no Unix**: cinco chamadas básicas (`open`, `read`, `write`, `lseek`, `close`) com assinaturas simples. Por trás, a implementação esconde centenas de milhares de linhas: representação em disco, diretórios e caminhos, permissões, escalonamento de acesso ao disco, cache de blocos, independência de dispositivo. Essa implementação mudou radicalmente ao longo de décadas sem que a interface mudasse.
- **Coletor de lixo**: praticamente **não tem interface**. Funciona de forma invisível e ainda *reduz* a interface do sistema, eliminando a necessidade de liberar memória.

### Módulos rasos

- Um módulo raso tem interface relativamente complexa em comparação com a funcionalidade que entrega. Ele não ajuda muito na batalha contra a complexidade: o benefício de não precisar entender a implementação é anulado pelo custo de aprender e usar a interface.
- Exemplo: uma classe de lista encadeada esconde pouquíssimo (algumas linhas de ponteiros) por trás de uma interface quase tão complexa quanto a implementação.
- Exemplo extremo de método raso:

  ```java
  private void addNullValueForAttribute(String attribute) {
      data.put(attribute, null);
  }
  ```

  Não oferece abstração nenhuma: toda a funcionalidade é visível na interface. Pensar no método é tão caro quanto pensar no código que ele contém. E ainda adiciona mais uma interface para aprender e mais código para ler.

---

## 4. "Classite" (*classitis*)

- Existe uma sabedoria convencional de que classes (e funções) devem ser pequenas: "quebre qualquer coisa com mais de N linhas".
- Levada ao extremo, isso gera **classite**: um grande número de classes pequenas e rasas. Cada uma parece simples, mas o sistema como um todo fica mais complexo: há mais interfaces, e cada interface adiciona complexidade. Também gera um estilo verboso, com muito código de amarração.
- Exemplo: na biblioteca clássica de I/O do Java, para ler objetos serializados de um arquivo é preciso criar três objetos:

  ```java
  FileInputStream fileStream = new FileInputStream(fileName);
  BufferedInputStream bufferedStream = new BufferedInputStream(fileStream);
  ObjectInputStream objectStream = new ObjectInputStream(bufferedStream);
  ```

  O buffering, que quase todo mundo quer, precisa ser pedido explicitamente. Esquecer significa nenhum buffering e I/O lento, sem nenhum aviso. Seria melhor que o buffering fosse o **padrão**, com uma forma de desligá-lo nos raros casos em que não é desejado.
- **Princípio**: interfaces devem ser desenhadas para tornar o **caso comum o mais simples possível**. Se quase todo usuário de uma classe precisa de um recurso, ele deve vir por padrão.
- Por contraste, os projetistas do Unix tornaram o caso comum simples: I/O sequencial é o padrão; acesso aleatório é possível (`lseek`), mas quem só lê sequencialmente não precisa saber disso.

---

## Red flags

- **Módulo raso**: a interface não é muito mais simples que a implementação.
- Recurso que quase todo chamador precisa, mas que precisa ser ativado explicitamente.
- Muitas classes ou funções pequenas que só fazem sentido juntas, cada uma com sua própria interface.
- Uma interface formal simples que esconde uma interface informal complexa (restrições de ordem, efeitos colaterais não documentados).
- A abstração omite algo que o chamador realmente precisa saber (falsa abstração).
- Chamador que verifica o tipo ou a origem da implementação para decidir o que fazer.

---

## Como aplicar

Para cada módulo proposto:

1. **Escreva a interface primeiro** (assinaturas + comportamento informal em uma ou duas frases). Se não conseguir descrever de forma curta, o módulo provavelmente está mal definido.
2. **Compare interface e implementação**: a interface é muito mais simples do que aquilo que ela esconde? Se não, considere fundir com outro módulo ou mover mais responsabilidade para dentro dele.
3. **Identifique o caso comum** e verifique se ele é trivial de usar, sem configuração ou passos obrigatórios.
4. **Conte as interfaces** do design inteiro, não só as linhas por arquivo: menos módulos, mais profundos, costumam ser melhores que muitos rasos.
5. **Verifique a abstração**: algo importante foi omitido? Algo sem importância foi exposto?

Ao reportar ao humano, apresente cada módulo como um cartão de interface (via [`visualize-it`](../../visualize-it/SKILL.md)): o que ele promete, o que ele esconde, e por que isso é profundo.

---

## Relações

- O conteúdo que torna um módulo profundo é o conhecimento que ele esconde: [information-hiding.md](information-hiding.md).
- Interfaces gerais tendem a ser mais profundas: [general-purpose-modules.md](general-purpose-modules.md).
- Quando dividir ou juntar módulos: [together-or-apart.md](together-or-apart.md).
- Exceções também fazem parte da interface e a tornam mais rasa: [define-errors-out-of-existence.md](define-errors-out-of-existence.md).
- Portas entre regras de negócio e infraestrutura, e suas implementações substituíveis: [dependency-direction.md](dependency-direction.md).
