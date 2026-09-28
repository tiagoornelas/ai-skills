# Defina Erros Fora da Existência

> **Tese central**: o tratamento de exceções é uma das maiores fontes de complexidade em software. A melhor forma de reduzi-la é **diminuir o número de lugares onde exceções precisam ser tratadas**, idealmente redefinindo a semântica das operações para que a condição de erro simplesmente não exista.

---

## Quando consultar

- Ao definir os modos de falha de um contrato (erros, exceções, códigos de retorno).
- Quando uma interface lista muitas exceções ou erros possíveis.
- Ao projetar recuperação de falhas em sistemas distribuídos.
- Ao encontrar casos especiais que espalham condicionais.

---

## 1. Por que exceções adicionam tanta complexidade

- "Exceção" aqui é qualquer condição incomum que altera o fluxo normal: exceções da linguagem, códigos de erro, casos especiais.
- Surgem de várias formas: o chamador passa argumentos ou configuração inválida; o método chamado não consegue completar (falha de I/O, recurso indisponível); em sistemas distribuídos, pacotes se perdem ou chegam atrasados, servidores caem; o código detecta um bug, uma inconsistência interna ou uma situação para a qual não foi preparado.
- **Tratar é difícil**: é preciso decidir entre seguir em frente contornando a falha ou abortar e reportar. Abortar exige desfazer mudanças parciais para manter consistência. Recuperação frequentemente gera novas exceções (falhas durante a recuperação).
- **Código de tratamento raramente executa**, então bugs nele passam despercebidos por muito tempo, e aparecem justamente quando algo já deu errado.
- **Lançar é fácil; tratar é difícil.** Isso cria a tentação de lançar exceções para qualquer coisa.
- Exceções são sintaticamente verbosas (blocos `try/catch` quebram o fluxo e tornam o código normal mais difícil de ler).

### Exceções demais

- É comum programadores lançarem exceções para situações que poderiam tratar, só para se livrar do problema ("se não sei o que fazer, lanço"). Também há a crença de que "quanto mais erros detectados e reportados, melhor".
- **As exceções que um módulo lança fazem parte da sua interface.** Um módulo com muitas exceções tem uma interface complexa, e por isso é **mais raso**.
- Cada exceção lançada empurra complexidade para todos os chamadores (o oposto de [pull-complexity-downwards.md](pull-complexity-downwards.md)).

---

## 2. As quatro técnicas

### 2.1. Defina erros fora da existência

Redefina a semântica da operação para que a condição de erro deixe de ser um erro.

- **`unset` no Tcl**: o comando remove uma variável e lança erro se ela não existe. Mas o uso mais comum de `unset` é limpar estado temporário, e muitas vezes não se sabe se a variável chegou a ser criada. O resultado é que quase todo uso precisa capturar o erro. Uma definição melhor seria: **`unset` garante que a variável não exista mais**. Se ela já não existe, não há nada a fazer, e não há erro.
- **Remoção de arquivos**: no Windows, tentar apagar um arquivo aberto por algum processo resulta em erro, e o usuário precisa descobrir quem está com o arquivo aberto. No Unix, o arquivo pode ser apagado mesmo aberto: ele sai do diretório imediatamente (novos processos não o veem), mas os dados só são liberados quando o último processo que o usa o fecha. O processo que tinha o arquivo aberto continua funcionando normalmente. Nenhum dos lados precisa tratar erro.
- **`substring` em Java**: lança `IndexOutOfBoundsException` se os índices estiverem fora dos limites da string. Isso força o chamador a checar e ajustar índices antes de chamar. Uma definição melhor é a das *slices* em Python: índices fora do intervalo são **ajustados** aos limites, e o resultado é o trecho da string que se sobrepõe ao intervalo pedido (possivelmente vazio). O código fica mais simples e não perde nada.

### 2.2. Mascare exceções

Detecte e trate a condição **num nível baixo**, para que os níveis superiores não precisem saber dela.

- **TCP**: pacotes perdidos são detectados e retransmitidos pelo protocolo. A aplicação recebe um fluxo confiável e nunca vê a perda.
- **NFS**: se o servidor fica indisponível, o cliente não reporta erro à aplicação; ele continua tentando até o servidor voltar (a aplicação apenas espera). Pode ser frustrante para o usuário, mas é melhor do que fazer cada aplicação tratar a falha, o que a maioria faria mal, ou nem faria.
- Mascarar exceções é uma forma de **puxar complexidade para baixo**: o módulo que mascara fica mais complexo, mas todos os que o usam ficam mais simples.

### 2.3. Agregue exceções

Trate muitas exceções com **um único trecho de código**, em vez de um tratamento para cada uma.

- **Servidor web e parâmetros ausentes**: em vez de cada handler de URL checar e tratar cada parâmetro obrigatório ausente, o método que busca o parâmetro lança uma exceção padronizada, e **o despachante de nível mais alto** a captura e gera uma resposta de erro única, com a mensagem apropriada. Os handlers não têm nenhum código de tratamento.
- Isso é o oposto de capturar e tratar exceções o mais perto possível de onde ocorrem. A agregação move o tratamento para um lugar mais alto, onde **um único ponto** trata muitas situações.
- **Promova exceções raras a exceções comuns**: em um sistema de armazenamento distribuído, um objeto corrompido pode ser tratado como se o servidor onde ele está tivesse caído: o sistema de recuperação de falhas (que já existe e é testado com frequência) recupera o objeto a partir das réplicas. Um mecanismo único cobre várias falhas, e o caminho raro passa a usar código bem exercitado.

### 2.4. Simplesmente deixe quebrar (*just crash*)

- Para algumas condições, **não vale a pena tratar**. O mais simples é imprimir informação de diagnóstico e abortar a aplicação.
- Exemplos: falta de memória em aplicações comuns (um alocador que aborta em vez de devolver nulo evita que cada chamador cheque o retorno); erros de I/O inesperados; inconsistências em estruturas de dados internas (sinal de bug).
- Se aplica a erros **raros e difíceis ou impossíveis de tratar**. A decisão depende da aplicação: um sistema de armazenamento replicado **não** deve abortar por um erro de I/O; deve recuperar a partir das réplicas.

---

## 3. Elimine casos especiais da existência

- O mesmo raciocínio vale para casos especiais em geral: eles espalham `if`s e tornam o código mais difícil de entender.
- Exemplo: no editor de texto, tratar "não há seleção" como um estado especial exige checagens antes de cada operação sobre a seleção. Se a seleção **sempre existe** e pode estar **vazia**, as operações funcionam sem nenhuma checagem.
- Sempre que possível, projete o **caso normal** para tratar automaticamente os casos extremos.

---

## 4. Levando longe demais

- Definir erros fora da existência ou mascarar exceções só faz sentido se **a informação sobre a exceção não é necessária fora do módulo**.
- Exemplo: um módulo de rede que mascara **todas** as exceções de rede (sem avisar o chamador) seria um erro, porque aplicações muitas vezes precisam saber que a comunicação falhou para tomar decisões.
- Assim como na ocultação de informação, é preciso discernimento: exponha a exceção quando quem está acima realmente precisa dela; nesses casos, ela deve ser **parte explícita do contrato**.

---

## Red flags

- Uma interface com muitas exceções ou códigos de erro diferentes.
- Chamadores que sempre capturam a mesma exceção e fazem a mesma coisa (sinal de que a exceção nem deveria existir, ou deveria ser tratada abaixo).
- Tratamento de erro idêntico espalhado por muitos handlers (candidato a agregação).
- Checagens de pré-condição repetidas antes de cada chamada (sinal de semântica mal definida).
- Estados especiais ("nenhum", "não inicializado") que exigem checagem em todo uso.

---

## Como aplicar

Para cada modo de falha de um contrato, percorra na ordem:

1. **Posso redefinir a operação para que esta condição não seja erro?** (idempotência, "garante que X" em vez de "faz X", ajuste de limites, coleções vazias em vez de nulos)
2. **Posso mascarar a condição dentro do módulo?** (retry, fallback, recuperação local), desde que o chamador não precise dessa informação.
3. **Posso agregar o tratamento num único ponto de nível mais alto?** (despachante, middleware, mecanismo de recuperação existente)
4. **Vale a pena tratar, ou é melhor abortar com diagnóstico?**
5. Só então: **expor a exceção no contrato**, documentada, com a informação que o chamador precisa para agir.

Os modos de falha que sobrarem no contrato são **decisões da Camada Humana**: apresente-os ao humano no cartão de interface, junto com os que foram eliminados e a técnica usada para cada um.

---

## Relações

- Exceções como parte da interface, e interfaces menores: [deep-modules.md](deep-modules.md).
- Mascarar é puxar complexidade para baixo: [pull-complexity-downwards.md](pull-complexity-downwards.md).
- Eliminar casos especiais: [general-purpose-modules.md](general-purpose-modules.md).
