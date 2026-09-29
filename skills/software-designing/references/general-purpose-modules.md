# Módulos de Propósito Geral São Mais Profundos

> **Tese central**: o ponto ideal é criar módulos **"um pouco de propósito geral"**: a funcionalidade reflete as necessidades atuais, mas a **interface** é geral o bastante para suportar múltiplos usos. Interfaces gerais tendem a ser mais simples, mais profundas e a esconder mais informação que interfaces especializadas.

---

## Quando consultar

- Ao desenhar a interface de um novo módulo ou API.
- Quando uma interface tem um método para cada caso de uso da tela ou do cliente atual.
- Ao notar condicionais espalhadas tratando casos especiais.
- Ao decidir entre "resolver só o problema de hoje" e "construir um framework genérico".

---

## 1. Especializar ou generalizar?

- **Abordagem especializada**: implementar exatamente o que é necessário hoje. Argumento: não se sabe o que será necessário no futuro, e generalizar pode gerar código que nunca será usado.
- **Abordagem de propósito geral**: implementar um mecanismo que resolve uma gama ampla de problemas. Argumento: pode economizar tempo no futuro.
- O meio-termo recomendado: **um pouco de propósito geral**.
  - A **funcionalidade** deve refletir as necessidades atuais (não implementar recursos que ninguém pediu).
  - A **interface** não deve ficar amarrada aos usos de hoje; deve ser geral o bastante para servir a múltiplos usos.
  - A interface deve ser fácil de usar para as necessidades de hoje, sem estar presa especificamente a elas.
- O benefício mais importante nem é a reutilização futura: é que **a interface geral fica mais simples e mais profunda agora**.

---

## 2. Exemplo canônico: a classe de texto de um editor

Num projeto de editor de texto gráfico, a classe responsável pelo texto (armazenar e modificar o conteúdo do arquivo) pode ser projetada de duas formas.

### Interface especializada (ruim)

Métodos que espelham as operações da interface do usuário:

```java
void backspace(Cursor cursor);
void delete(Cursor cursor);
void deleteSelection(Selection selection);
```

- Cada nova operação da UI exige um novo método na classe de texto.
- A classe de texto passa a conhecer conceitos da UI (cursor, seleção, tecla backspace): vazamento de informação.
- Muitos métodos rasos, cada um usado por um único recurso da UI.
- Quem trabalha na UI precisa aprender um grande número de métodos.

### Interface de propósito geral (melhor)

Operações básicas sobre texto, sem referência à UI:

```java
void insert(Position position, String newText);
void delete(Position start, Position end);
Position changePosition(Position position, int numChars);
```

As operações da UI passam a ser implementadas **em cima** dessa interface:

```java
// backspace
text.delete(text.changePosition(cursor, -1), cursor);

// delete (tecla "Del")
text.delete(cursor, text.changePosition(cursor, 1));
```

- Menos métodos, cada um mais poderoso: a classe fica mais profunda.
- A classe de texto não sabe nada sobre a UI: melhor separação e ocultação.
- O código de UI fica até mais **óbvio**: a intenção ("apagar o caractere antes do cursor") está visível.
- Novas operações da UI não exigem mudanças na classe de texto.

---

## 3. Generalidade leva a melhor ocultação de informação

- A abordagem geral separa claramente as classes: a classe de texto não precisa conhecer cursores, seleções ou teclas; a UI não precisa conhecer a representação do texto.
- Métodos especializados para cada caso de uso da UI tendem a ser rasos e a vazar conhecimento de cima para baixo.

---

## 4. Perguntas para encontrar o ponto certo

1. **Qual é a interface mais simples que cobre todas as minhas necessidades atuais?** Reduzir o número de métodos sem reduzir a capacidade geral geralmente torna a interface mais geral. Cuidado: reduzir métodos à custa de muitos argumentos adicionais não simplifica.
2. **Em quantas situações este método será usado?** Se um método é desenhado para **um único uso específico**, é um sinal de alerta de que ele pode ser especializado demais. Veja se vários métodos especializados podem ser substituídos por um único geral.
3. **Esta API é fácil de usar para as minhas necessidades atuais?** Se é preciso escrever muito código adicional para usar a classe no caso de hoje, a interface provavelmente não tem a funcionalidade certa. Exemplo: se a única forma de apagar um intervalo de texto é chamar em loop um método que apaga um caractere, a interface é geral demais (ou baixa demais) para o uso real.

---

## 5. Empurrar a especialização para cima (e para baixo)

- A maioria dos sistemas precisa ter algum código especializado. O objetivo não é eliminá-lo, mas **separá-lo** do código geral.
- Normalmente, a especialização fica **no topo**: a camada de aplicação/UI implementa os recursos específicos usando os mecanismos gerais das camadas inferiores.
- Às vezes a especialização vai **para baixo**: drivers de dispositivo, por exemplo, são especializados, mas ficam atrás de uma interface geral que o resto do sistema usa sem conhecer os detalhes.
- Exemplo: um mecanismo de **desfazer** (*undo*) num editor. O mecanismo geral mantém um histórico de ações e sabe voltar e avançar. Cada tipo de ação (inserir texto, mudar seleção) fornece seu próprio handler especializado para desfazer/refazer. O mecanismo geral não conhece os detalhes das ações; as ações não conhecem a mecânica do histórico.

### Eliminar casos especiais

- Especialização também aparece como casos especiais espalhados. Como eliminá-los: [define-errors-out-of-existence.md](define-errors-out-of-existence.md) (seção 3).

---

## Red flags

- **Mistura de especial com geral** (*special-general mixture*): um mecanismo de propósito geral contém código especializado para um uso particular dele.
- Um método projetado para exatamente um caso de uso.
- A interface de um módulo de baixo nível usa conceitos de uma camada superior (ex.: classe de dados que conhece "tela", "botão", "cursor").
- Cada nova feature da camada superior exige um novo método na camada inferior.
- Condicionais para casos especiais espalhadas pelo código.

---

## Como aplicar

1. Liste os **usos atuais** do módulo.
2. Desenhe a **menor interface** que cobre todos eles, usando os conceitos do próprio domínio do módulo (não os do cliente).
3. Escreva, em pseudo-código, **como cada uso atual ficaria** em cima dessa interface. Se algum ficar muito verboso, ajuste a interface.
4. Separe o que é especializado e empurre-o para a camada que o origina (normalmente a de cima).
5. Procure casos especiais que possam ser eliminados redefinindo o caso normal.
6. **Não implemente** funcionalidade especulativa: generalize a interface, não o escopo.

---

## Relações

- Por que interfaces menores e mais gerais são melhores: [deep-modules.md](deep-modules.md).
- A classe de texto e a UI como camadas com abstrações distintas: [different-layer-different-abstraction.md](different-layer-different-abstraction.md).
- Separar código geral e especializado também guia a decisão de juntar/separar: [together-or-apart.md](together-or-apart.md).
- Eliminar casos especiais é o mesmo raciocínio de eliminar erros: [define-errors-out-of-existence.md](define-errors-out-of-existence.md).
- Exceção na fronteira com a infraestrutura: a porta usa o vocabulário das regras de negócio: [dependency-direction.md](dependency-direction.md).
