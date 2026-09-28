# Melhor Juntos ou Separados?

> **Tese central**: a pergunta fundamental do design é se duas funcionalidades devem morar no mesmo lugar ou em lugares separados. O objetivo é **reduzir a complexidade do sistema como um todo**, não a de cada parte isoladamente. Subdividir tem custos, e nem sempre compensa.

---

## Quando consultar

- Ao decidir se uma responsabilidade vira um novo módulo/classe/serviço/função ou fica num existente.
- Ao revisar decomposições com muitos pedaços pequenos (ou um pedaço gigante).
- Ao decidir se um método longo deve ser quebrado.
- Ao encontrar código duplicado.

---

## 1. Os custos de subdividir

Dividir o sistema em mais componentes parece deixar cada um mais simples, mas a subdivisão cria complexidade que não existia antes:

1. **Mais componentes**: é mais difícil acompanhar todos, e é mais difícil encontrar o componente certo. Cada um adiciona uma interface, e cada interface adiciona complexidade.
2. **Código extra de gerenciamento**: coordenar os componentes (por exemplo, código para conectar, passar dados, sincronizar).
3. **Separação**: código relacionado fica distante. Se as partes são realmente independentes, isso é bom. Se são dependentes, o desenvolvedor precisa ir e voltar entre elas, e pode nem perceber a dependência.
4. **Duplicação**: código que estava num lugar pode acabar repetido em cada componente.

Juntar partes relacionadas tende a ser benéfico. Juntar partes não relacionadas tende a ser ruim.

---

## 2. Quando juntar

Sinais de que dois trechos devem ficar juntos:

- **Compartilham informação**: ambos dependem do mesmo conhecimento. Exemplo: ler uma requisição HTTP e interpretá-la dependem do formato HTTP; separá-las gera vazamento de informação.
- **São usados juntos**: se quem usa um quase sempre usa o outro, e vice-versa. A relação precisa ser **bidirecional**. Exemplo: um cache de disco quase sempre acompanha o acesso ao disco, mas o cache também é usado apenas com ele.
- **Se sobrepõem conceitualmente**: existe uma categoria de nível mais alto que inclui ambos (ex.: busca de substring e busca por expressão regular são ambas "busca de texto").
- **É difícil entender um sem olhar o outro.**

### Juntar se isso simplificar a interface

- Quando dois módulos são combinados, às vezes a interface resultante é **mais simples** que a soma das duas originais. Isso é comum quando os módulos implementam partes de uma mesma solução.
- Exemplo: se buffering fosse parte da classe de leitura de arquivos (em vez de um decorator separado), o buffering seria automático e ninguém precisaria saber que ele existe.
- Juntar também pode eliminar a necessidade de passar informação entre os módulos.

### Juntar para eliminar duplicação

- Se o mesmo padrão de código aparece repetidamente, provavelmente a abstração certa não foi encontrada.
- Opções: extrair o código repetido para um método único (vale se o trecho for substancial e a assinatura resultante for simples); ou reestruturar o fluxo para que o trecho só precise ser executado em um lugar. Exemplo: em C, um tratamento de fim de laço repetido em vários pontos pode ser consolidado com um único ponto de saída/limpeza.

---

## 3. Quando separar

### Separar código de propósito geral de código especializado

- Se um módulo contém um mecanismo que pode ser usado para vários propósitos, ele deve oferecer **apenas** esse mecanismo geral. Código especializado para um uso particular vai para outro módulo (normalmente o de cima).
- Exemplo: o mecanismo de *undo* de um editor. O histórico (lista de ações, voltar e avançar) é geral e independente do tipo de ação. Os detalhes de como desfazer cada ação (texto, seleção, formatação) ficam nos módulos que criam essas ações, registrados no histórico como handlers. Misturar os dois (o histórico conhecendo cada tipo de ação) criaria acoplamento e um módulo pior.
- Em geral, a camada de baixo tende a ser geral e a de cima, especializada.

### Exemplos de junções e separações ruins

- **Cursor de inserção e seleção** implementados como classes separadas, mas intimamente relacionados (a posição do cursor é sempre um dos extremos da seleção). O código que os usa precisava manipular os dois sempre em conjunto. Juntá-los num único objeto simplificou o sistema.
- **Classe de log separada** para mensagens de erro de rede, com um método por tipo de erro, cada um chamado de um único lugar. A separação não escondia nada, só fazia o leitor pular entre arquivos para entender o que era logado. Melhor registrar o log **no local** onde o erro é detectado.

---

## 4. Dividir e juntar métodos

- **Comprimento, por si só, raramente é um bom motivo para quebrar um método.** Em geral, desenvolvedores tendem a quebrar métodos demais. Quebrar introduz interfaces adicionais e aumenta a complexidade.
- Um método longo pode ser perfeitamente adequado se tem uma **assinatura simples** e é **fácil de ler**, por exemplo, porque consiste em blocos relativamente independentes executados em sequência.
- **Profundidade importa mais que comprimento.** Primeiro torne as funções profundas; depois, tente deixá-las curtas o suficiente para serem fáceis de ler. Não sacrifique profundidade por comprimento.

### Quando quebrar faz sentido

1. **Extrair uma subtarefa**: o método filho encapsula uma subtarefa de propósito relativamente geral, e o pai fica mais simples. O teste é a **independência**: deve ser possível entender o filho sem ler o pai, e entender o pai sem ler o filho.
2. **Dividir em dois métodos visíveis aos chamadores**: faz sentido quando o método original tinha uma interface complexa demais porque tentava fazer várias coisas. Cada novo método deve ter uma interface mais simples que a original. Se, na maioria dos casos, os chamadores precisam chamar os dois, a divisão provavelmente não valeu.

### Métodos conjugados

- Se não dá para entender a implementação de um método sem ler a de outro, é um sinal de alerta: os dois estão **conjugados**. Isso vale para qualquer par de trechos de código.
- Quebrar um método em pedaços que precisam ser lidos juntos (com dependência entre eles pela ordem, por variáveis de estado compartilhadas, etc.) aumenta a complexidade em vez de reduzir.

### Uma opinião diferente

- Existe uma escola de pensamento que defende funções **extremamente curtas** (poucas linhas cada), quebrando tudo em métodos pequenos. Levada ao extremo, essa abordagem produz muitas funções **rasas**, com interfaces que custam tanto quanto o código que escondem, e cria **entrelaçamento**: para entender o comportamento, o leitor precisa ler várias funções que estão conjugadas.
- A posição aqui é: prefira funções profundas; torne-as curtas quando isso não custar profundidade nem gerar conjugação.

---

## Red flags

- **Repetição**: o mesmo trecho (ou quase o mesmo) aparece várias vezes.
- **Mistura de especial com geral**: um mecanismo geral contendo código específico de um uso.
- **Métodos conjugados**: não dá para entender um sem ler o outro.
- Módulos separados que sempre são alterados juntos.
- Módulo novo com um único chamador e nenhuma informação escondida.

---

## Como aplicar

Para cada fronteira proposta (dividir ou juntar):

1. **Compartilham informação?** Se sim, tendem a ficar juntos.
2. **São usados juntos, nos dois sentidos?** Se sim, tendem a ficar juntos.
3. **Juntar simplifica a interface ou elimina passagem de dados?** Se sim, juntar.
4. **Há um mecanismo geral misturado a um uso específico?** Separar.
5. **Cada lado pode ser entendido sozinho?** Se não, a fronteira está no lugar errado.
6. **Qual opção reduz a complexidade do sistema inteiro?** Esta é a decisão final, não a complexidade de cada parte isolada.

Ao reportar ao humano, apresente a fronteira escolhida e a alternativa descartada, com o critério decisivo de forma explícita.

---

## Relações

- Compartilhamento de informação e vazamento: [information-hiding.md](information-hiding.md).
- Profundidade como critério principal: [deep-modules.md](deep-modules.md).
- Separar o geral do especializado: [general-purpose-modules.md](general-purpose-modules.md).
