# Tratamento de Erro na Implementação

> **Tese central**: o tratamento de erro não pode esconder a lógica principal nem deixar falhas passarem em silêncio. Esta referência trata de **como implementar** o tratamento dentro do código. **Quais** erros um contrato público expõe é decisão de design e da Camada Humana: ver [define-errors-out-of-existence.md](../../software-designing/references/define-errors-out-of-existence.md).

---

## Quando consultar

- Ao escrever código que pode falhar (I/O, rede, entrada externa, bibliotecas de terceiros).
- Ao revisar `try/catch`, retornos de erro, `null` e mensagens de erro num diff.

---

## 1. Mecanismo idiomático

- Use o mecanismo de erro **idiomático da linguagem e do repositório**: exceções, `Result`/`Maybe`/`Either`, retorno de erro. A convenção do repositório prevalece.
- Qualquer que seja o mecanismo: o **caminho principal fica legível**, e nenhum chamador é obrigado a checar um retorno que ele pode esquecer. Prefira mecanismos que o tipo ou a linguagem obrigam a tratar.

---

## 2. Primeiro, faça o erro não existir

- Antes de tratar um erro interno, veja se ele precisa existir: ajustar a semântica, devolver coleção vazia, usar um objeto de caso especial. As técnicas estão em [define-errors-out-of-existence.md](../../software-designing/references/define-errors-out-of-existence.md).

---

## 3. Não devolva nem passe nulo

- Devolver `null`/`None`/`nil` obriga cada chamador a checar, e basta um esquecimento para o erro aparecer longe da origem.
- Prefira coleção vazia, um objeto de caso especial ou o tipo opcional idiomático da linguagem.
- Não passe nulo como argumento, a menos que a interface declare isso explicitamente.

---

## 4. Erros com contexto

- A mensagem diz **qual operação falhou**, com qual entrada relevante e por quê. "Erro ao processar" não ajuda ninguém.
- Preserve a causa original (encadeamento de exceções, erro envolvido) em vez de substituí-la.
- Não coloque dados sensíveis na mensagem.

---

## 5. Não engula erros

- `catch` vazio, `except: pass` e "logar e seguir" sem uma decisão escondem falhas.
- Capture só o que você sabe tratar, no ponto em que sabe tratar. O resto sobe.

---

## 6. Separe o tratamento da lógica

- O corpo de um `try` não deve misturar lógica com tratamento. Extraia a lógica para uma função, e deixe o `try` só com a chamada e o tratamento.
- Mantenha o `try` o mais estreito possível, envolvendo só o que pode falhar.

---

## 7. Erros de terceiros

- No ponto em que o código chama uma biblioteca ou serviço externo, traduza as falhas dele para os erros que o módulo já define no contrato. Os erros do terceiro não devem se espalhar pelo resto do código.

---

## Red flags

- `catch` vazio, `except: pass`, ou erro só logado sem decisão.
- Função que devolve `null` para indicar falha ou ausência.
- Mensagem de erro sem a operação e o motivo.
- Causa original descartada ao relançar.
- `try` longo misturando lógica e tratamento.
- Checagem do mesmo erro repetida em vários chamadores.
- Exceções de biblioteca externa atravessando o código do módulo.

---

## Como aplicar

- **Ao escrever**: tente eliminar o erro; se ele existir, use o mecanismo idiomático, com contexto, sem nulo, e tratado só onde há algo a fazer.
- **Ao revisar**: erro engolido, nulo devolvido sem necessidade e causa perdida têm cenário concreto (falha silenciosa, erro longe da origem) e valem corrigir.
- Se a correção mudaria os erros que um contrato público expõe, não é implementação: é Camada Humana.

---

## Relações

- Quais erros um contrato expõe, e como eliminá-los: [define-errors-out-of-existence.md](../../software-designing/references/define-errors-out-of-existence.md).
- Funções que fazem o que o nome promete: [functions.md](functions.md).
- Caso especial em vez de checagens repetidas: [code-smells.md](code-smells.md).
