# Testes: o que é um bom teste

> **Tese central**: a unidade de um teste é um **comportamento observável pela interface pública**, não uma classe nem um método. O teste monta o estado real, chama a interface pública e confere o resultado, sem mexer na estrutura interna. Um bom teste **só quebra quando o comportamento muda**, e nunca por causa de um detalhe que ninguém fora do módulo percebe.

---

## Quando consultar

- Ao escrever testes (o fluxo de trabalho está em [test-driven-development.md](test-driven-development.md)).
- Ao revisar testes, próprios ou de outra pessoa.

---

## 1. Altitude do teste

| Altitude | O que é | Quando usar |
| :--- | :--- | :--- |
| **Comportamento pela interface pública** | Chama a função ou classe pública e confere o resultado. | Lógica com contrato próprio: cálculo, regra, transformação. |
| **Componente** | Sobe o ambiente necessário (banco em memória, contexto de injeção de dependência) e chama o módulo inteiro pela interface pública, deixando os internos rodarem livremente entre si. | Comportamentos que existem na colaboração entre as partes do módulo. |

- **Nunca exponha nada só para testar.** Nada é exportado, tornado público ou acessado por artifício (reflexão, atributo privado lido de fora) para que um teste o alcance. Uma parte interna é testada pelo comportamento público que ela produz.
- Se uma parte interna parece precisar de teste próprio e o comportamento público não basta para cobri-la, isso é sinal de que ela é um módulo à parte. Criar esse módulo é decisão de design: Camada Humana.

---

## 2. O teste só quebra se o comportamento mudar

Não faça asserções sobre:

- **Texto**: conteúdo de prompts, rótulos de interface, mensagens, cópias.
- **Estrutura**: markup, ordem interna de chamadas, nomes privados, formato interno de dados.
- **Snapshots** de markup ou de qualquer detalhe que não seja comportamento. Um snapshot só é aceitável quando o dado capturado **é** o comportamento (por exemplo, a saída serializada de uma API pública).

No frontend, encontre o elemento pelo **papel** (`role`) quando ele for único na tela, sem usar o nome acessível. Quando não for único, use um **identificador estável** (`data-testid`). Verifique o **efeito** da interação (o que acontece depois do clique), não a presença do rótulo.

```ts
// Frágil: quebra se o texto mudar, sem nenhuma mudança de comportamento
expect(screen.getByText("Salvar alterações")).toBeInTheDocument();

// Robusto: encontra pelo papel e verifica o efeito
await user.click(screen.getByRole("button"));
expect(await api.perfilSalvo()).toEqual(perfilEditado);
```

---

## 3. Dublês só nas bordas que você não controla

- Substitua por dublês (fakes, stubs, mocks) apenas o que está fora do seu controle: serviços externos, rede, relógio, aleatoriedade, LLM.
- **Colaboradores internos rodam de verdade.** Mockar um colaborador interno acopla o teste à estrutura e o quebra numa refatoração.
- Prefira fakes que implementam as portas do núcleo (uma implementação em memória de um repositório, por exemplo) a mocks que verificam chamadas. Ver [dependency-direction.md](../../software-designing/references/dependency-direction.md).

---

## 4. Use a infraestrutura que o projeto já tem

- Escreva os testes com as ferramentas, os tipos de teste e os padrões **que o projeto já usa**. Se existe teste de integração com banco, use-o.
- Se o tipo de teste necessário não existe no projeto e criá-lo não faz parte da tarefa, fique nos tipos que já existem.
- **Criar infraestrutura nova de testes** (framework, container de banco, harness de ponta a ponta) nunca é efeito colateral de uma tarefa. É uma decisão de escopo, do humano.

---

## 5. O que não se testa por código

Não escreva teste automatizado para:

- **conteúdo de prompts** de agentes e LLMs;
- **layout visual** e **cópia**;
- **configuração** estática;
- **código de ligação** sem lógica própria.

Teste o que o sistema **faz** com isso. Por exemplo: como a resposta de um LLM é interpretada e roteada, usando um LLM falso. Comportamentos que não são testáveis por código são **declarados**: qual é o comportamento, por que não é testável, como foi verificado e como o humano valida.

**Evals** de prompt não são testes de código. Não crie nem altere evals, a menos que o usuário peça explicitamente.

---

## 6. Escolher o que testar

- **Teste por risco, não por cobertura.** Concentre os testes no que tem mais chance de dar errado. Testes incompletos que rodam valem mais que testes completos que ninguém escreve.
- **Explore as bordas**: entrada vazia, zero, valores negativos, entrada inválida, limites de coleção.
- **Todo bug vira primeiro um teste** que o reproduz.

---

## 7. Forma do teste

- **Um fixture novo por teste.** Nenhum estado compartilhado ou mutável entre testes; a ordem de execução não pode importar.
- **Um comportamento por teste**, com um nome que diz qual é o comportamento e o resultado esperado.
- **Testes rápidos**, para serem rodados com frequência.
- **Determinísticos**: sem depender de hora real, rede real ou ordem aleatória.

---

## Red flags

- Asserção sobre texto de prompt, rótulo, mensagem ou markup.
- Função, campo ou método exportado ou tornado público só para um teste.
- Mock de colaborador interno, ou verificação da ordem interna de chamadas.
- Teste que quebra numa refatoração sem mudança de comportamento.
- Infraestrutura de testes nova criada como parte de uma tarefa que não era sobre isso.
- Fixture compartilhado e mutável; teste que depende da ordem de execução.
- Teste que nunca falhou.
- Snapshot de markup.

---

## Como aplicar

- **Ao escrever**: escolha a altitude, use a infraestrutura existente, teste pelo comportamento público e só use dublês nas bordas.
- **Ao revisar**: teste acoplado a texto, estrutura ou internos tem cenário concreto (vai quebrar sem mudança de comportamento) e vale corrigir. Teste ausente para um comportamento de risco também vale apontar.

---

## Relações

- Como o agente trabalha com testes: [test-driven-development.md](test-driven-development.md).
- Refatorar com os testes verdes: [refactoring-principles.md](refactoring-principles.md).
- Portas e implementações em memória: [dependency-direction.md](../../software-designing/references/dependency-direction.md).
- Interface pública como contrato: [deep-modules.md](../../software-designing/references/deep-modules.md).
