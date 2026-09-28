# Camada Diferente, Abstração Diferente

> **Tese central**: em um sistema bem projetado, **cada camada oferece uma abstração diferente** das camadas acima e abaixo dela. Se duas camadas adjacentes têm abstrações parecidas, provavelmente há um problema na decomposição.

---

## Quando consultar

- Ao desenhar arquiteturas em camadas (UI → aplicação → domínio → infraestrutura; controller → service → repository; etc.).
- Ao encontrar métodos que só repassam chamadas, wrappers e decorators.
- Ao notar um parâmetro atravessando uma longa cadeia de funções sem ser usado por elas.

---

## 1. Camadas com abstrações distintas

- Sistemas de software são compostos em camadas: as mais altas usam as facilidades das mais baixas. Cada camada deve fornecer uma abstração **diferente**.
- Exemplos:
  - **Sistema de arquivos**: a camada de cima implementa a abstração de *arquivo* (sequência de bytes de tamanho variável); a do meio, um *cache* de blocos de tamanho fixo em memória; a de baixo, *drivers de dispositivo* que movem blocos entre o armazenamento e a memória.
  - **Protocolo de rede**: TCP oferece um *fluxo de bytes* confiável; a camada abaixo transmite *pacotes* de tamanho limitado, sem garantia de entrega.
- Se as abstrações de camadas adjacentes são muito parecidas, a separação provavelmente não está pagando o próprio custo.

---

## 2. Métodos repassadores (*pass-through methods*)

- Um método repassador faz pouca coisa além de chamar outro método, com assinatura igual ou muito parecida.

  ```java
  public class TextDocument ... {
      private TextArea textArea;
      public Character getLastTypedCharacter() {
          return textArea.getLastTypedCharacter();
      }
      public int getCursorOffset() {
          return textArea.getCursorOffset();
      }
      public void insertString(String textToInsert, int offset) {
          textArea.insertString(textToInsert, offset);
      }
  }
  ```

- Métodos repassadores tornam as classes **mais rasas**: aumentam a interface sem aumentar a funcionalidade. Também criam dependência: se a assinatura do método de baixo muda, o de cima muda junto.
- Eles indicam **confusão na divisão de responsabilidades** entre as classes.
- **Como corrigir**:
  1. Expor a classe de baixo diretamente aos chamadores da de cima, removendo a responsabilidade da classe de cima.
  2. Redistribuir a funcionalidade entre as classes, para que cada uma tenha responsabilidades distintas e coerentes.
  3. Se as classes não podem ser separadas de forma limpa, **fundi-las**.

### Quando duplicar a interface é aceitável

- Ter métodos com a mesma assinatura não é sempre ruim. O importante é que **cada novo método contribua com funcionalidade significativa**.
- **Despachante** (*dispatcher*): um método que usa seus argumentos para escolher qual de vários métodos chamar, e repassa a chamada (ex.: o roteador de um servidor web que escolhe o handler pela URL). A assinatura pode ser igual à dos métodos chamados, mas ele entrega uma funcionalidade útil: escolher.
- **Múltiplas implementações de uma mesma interface** (ex.: drivers de disco diferentes sob um mesmo contrato do sistema operacional). Eles estão na **mesma camada** e não chamam uns aos outros. Isso reduz carga cognitiva: quem trabalhou com um já sabe usar os outros.

---

## 3. Decorators

- O padrão *decorator* (ou wrapper) recebe um objeto existente e estende sua funcionalidade, com uma API igual ou parecida. Exemplo: `BufferedInputStream` envolve um `InputStream` e adiciona buffering, mantendo a mesma interface.
- A motivação é separar extensões especializadas de um núcleo mais geral. Mas decorators **tendem a ser rasos**: introduzem muito código de repasse para uma funcionalidade pequena.
- Antes de criar um decorator, considere:
  1. Adicionar a funcionalidade **diretamente na classe base**, se ela for de propósito relativamente geral, logicamente relacionada à classe base, ou necessária para a maioria dos usos. (Ex.: buffering em I/O deveria ser padrão.)
  2. Se a funcionalidade é especializada para um caso de uso, **fundi-la com o caso de uso** em vez de criar uma classe separada.
  3. **Fundir com um decorator existente**, em vez de criar mais um: fica um decorator mais profundo em vez de vários rasos.
  4. Implementar a nova funcionalidade como uma **classe independente**, que não envolve a classe base. Exemplo: rolagem de janela (*scrolling*) pode ser implementada separadamente da janela, em vez de "envolver" cada método da janela.

---

## 4. Interface versus implementação

- A interface de uma classe normalmente deve ser **diferente** de sua implementação: a representação interna não deve ditar a abstração oferecida.
- Exemplo: no editor de texto, é natural armazenar o texto como uma lista de linhas. Se a classe expõe uma interface orientada a linhas (`getLine`, `putLine`), as operações mais comuns da UI (inserir e apagar caracteres no meio de uma linha, ou atravessando linhas) exigem que os chamadores façam contas de divisão e junção de linhas. Uma interface **orientada a caracteres** (`insert`, `delete` por posição) é mais simples para quem usa e esconde a representação em linhas dentro da classe.
- Se a interface é idêntica à implementação, a classe é rasa.

---

## 5. Variáveis repassadas (*pass-through variables*)

- Uma variável repassada é passada por uma longa cadeia de métodos. Os métodos intermediários não a usam; só existem para levá-la até quem usa.
- Ela adiciona complexidade: força todos os métodos intermediários a saberem de sua existência. Se uma nova variável desse tipo surgir, é preciso mudar muitas assinaturas.

```text
main(cert) → m1(…, cert) → m2(…, cert) → m3(…, cert) → abrirSocket(cert)
             (não usa)      (não usa)      (não usa)      (usa)
```

- Opções para eliminar:
  1. Verificar se já existe um **objeto compartilhado** entre o topo e a base da cadeia (algo que ambos já acessam) e guardar a informação ali.
  2. Usar uma **variável global**. Evita repasse, mas cria outros problemas: impede, por exemplo, ter duas instâncias do sistema no mesmo processo, e cria dependências invisíveis.
  3. Usar um **objeto de contexto** (a solução mais usada): ele guarda o estado global da aplicação (opções de configuração, subsistemas compartilhados, contadores de desempenho) e existe um por instância do sistema. As referências ao contexto ficam em variáveis de instância dos objetos principais, então **não precisam ser passadas como argumento** em cada chamada. Novos dados globais são adicionados ao contexto sem mudar assinaturas.
- Contextos não são uma solução perfeita. Sem disciplina viram um "saco de tudo" com dependências não óbvias. Recomendações: variáveis do contexto devem ser, idealmente, **imutáveis** (evita problemas de concorrência), e deve ficar claro por que cada variável está ali.

---

## 6. Conclusão da camada

Cada peça de infraestrutura de design adicionada (uma interface, um argumento, uma função, uma classe, uma definição) adiciona complexidade, porque os desenvolvedores precisam aprendê-la. **Para que um elemento ofereça ganho líquido, ele precisa eliminar mais complexidade do que adiciona.**

---

## Red flags

- **Método repassador**: um método que não faz nada além de repassar argumentos para outro método com assinatura parecida.
- Duas camadas adjacentes com vocabulário e operações quase idênticos (ex.: `Service.create()` que só chama `Repository.create()`).
- Decorators ou wrappers em cadeia, cada um com pouca funcionalidade.
- Interface que espelha a representação interna.
- Parâmetro que atravessa várias funções sem ser usado por elas.

---

## Como aplicar

1. Para cada camada, escreva **em uma frase** a abstração que ela oferece. Se duas camadas adjacentes tiverem a mesma frase, reveja a divisão.
2. Procure métodos repassadores e decida entre expor, redistribuir ou fundir.
3. Para cada decorator/wrapper proposto, passe pelas quatro alternativas antes de aceitá-lo.
4. Confirme que a interface de cada módulo é expressa nos conceitos de quem usa, não na representação interna.
5. Mapeie variáveis repassadas e proponha um contexto ou objeto compartilhado quando fizer sentido.

Ao reportar ao humano, desenhe as camadas (via [`visualize-it`](../../visualize-it/SKILL.md)) com a abstração de cada uma escrita ao lado e com a direção das dependências explícita.

---

## Relações

- Repassadores e decorators são casos de módulos rasos: [deep-modules.md](deep-modules.md).
- Onde cada complexidade deve morar entre as camadas: [pull-complexity-downwards.md](pull-complexity-downwards.md).
- Quando fundir camadas: [together-or-apart.md](together-or-apart.md).
