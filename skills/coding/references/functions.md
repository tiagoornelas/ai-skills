# Funções

> **Tese central**: uma boa função faz **o que o nome promete**, pode ser entendida **sem ler outras funções** e tem uma assinatura que diz como usá-la. Entre a escola das funções minúsculas e a das funções longas e profundas, a posição aqui é um meio-termo: **extrair ajuda a leitura quando o pedaço extraído é independente**, e atrapalha quando só espalha o que precisa ser lido junto.

---

## Quando consultar

- Ao escrever ou dividir funções e métodos.
- Ao revisar funções num diff.
- Esta referência cobre funções internas. Dividir uma interface pública em várias, ou juntar várias numa, é mudança de contrato: Camada Humana (ver [deep-modules.md](../../software-designing/references/deep-modules.md)).

---

## 1. Tamanho e extração

| Tema | Um polo | O outro polo | Aqui |
| :--- | :--- | :--- | :--- |
| Tamanho | Funções minúsculas, de poucas linhas. | O tamanho quase nunca importa. | O tamanho sozinho não decide. O que decide é a independência. |
| "Fazer uma coisa só" | Regra absoluta, aplicada até não sobrar nada a extrair. | Não é critério. | A função faz o que o nome promete, sem efeito escondido. |
| Níveis de abstração | Um único nível por função, descendo em cascata. | Não é critério. | Misturar níveis é **sinal** de uma possível subtarefa independente. Quem decide é o critério de independência. |

### Quando extrair

- **Extraia uma subtarefa independente**: com entrada e saída explícitas, e compreensível sem ler a função original, e vice-versa. Isso melhora a leitura, inclusive dentro de um módulo profundo.
- **Extraia o que se repete** e representa a mesma decisão (ver [together-or-apart.md](../../software-designing/references/together-or-apart.md)).

### Quando não extrair

- **Pedaços conjugados**: se as partes se comunicam por estado compartilhado ou dependem da ordem de chamada, extrair só espalha a complexidade. O leitor precisa ler todas juntas.
- **Só por tamanho**: uma função longa, com assinatura simples e blocos em sequência fáceis de ler, pode ficar como está.

```python
# Conjugado: cada parte depende do estado deixado pela anterior
def processar(pedido):
    self._validar(pedido)        # preenche self._itens_validos
    self._aplicar_descontos()    # lê self._itens_validos, preenche self._total
    self._registrar()            # lê self._total

# Independente: cada parte se entende sozinha
def processar(pedido):
    itens = itens_validos(pedido)
    total = total_com_descontos(itens, pedido.cliente)
    registrar_venda(pedido.id, total)
```

---

## 2. A função faz o que o nome promete

- **Sem efeito colateral escondido**: `verificarSenha()` que também abre a sessão promete uma coisa e faz duas. Ou o nome diz tudo, ou o efeito sai da função.
- **Consulta separada de modificação**: uma função devolve informação ou altera estado, não as duas coisas.
- **Sem argumento de saída**: devolva o resultado em vez de alterar o objeto recebido. Se a função precisa alterar um objeto, ela deveria ser um método dele.

---

## 3. Argumentos

- **Sem número fixo.** Uma função profunda pode precisar de vários parâmetros. Muitos parâmetros são um **sinal** de que:
  - alguns formam um conceito (vire um objeto de parâmetro, ou passe o objeto inteiro);
  - algum pode ser obtido pela própria função a partir dos outros;
  - a função faz coisas demais.
- **Nunca troque parâmetros explícitos por estado escondido** (campos da classe preenchidos antes da chamada): a assinatura fica menor, mas as funções passam a depender da ordem de chamada.
- **Sem argumento flag**: um literal (`true`, `"modo"`) que escolhe o comportamento indica duas funções numa. Divida-as, a menos que o valor venha de dados.

---

## Red flags

- Função cujo nome não diz tudo o que ela faz.
- Função que devolve um valor e também altera estado.
- Argumento de saída.
- Argumento flag passado como literal.
- Funções que só podem ser entendidas lidas em conjunto (conjugadas).
- Parâmetros substituídos por campos preenchidos antes da chamada.
- Extração que deixa a função original mais difícil de entender do que antes.

---

## Como aplicar

- **Ao escrever**: escreva a função pelo que ela promete; extraia só subtarefas independentes.
- **Ao revisar**: efeito colateral escondido, consulta com modificação e funções conjugadas têm cenário concreto e valem corrigir. Quebrar uma função legível só por tamanho não tem: não vale apontar.

---

## Relações

- Profundidade vale mais que comprimento: [deep-modules.md](../../software-designing/references/deep-modules.md).
- Juntar ou separar, e o critério de duplicação: [together-or-apart.md](../../software-designing/references/together-or-apart.md).
- Nomes de funções: [naming.md](naming.md).
- Erros na implementação: [error-handling.md](error-handling.md).
- Outros smells e refatorações: [code-smells.md](code-smells.md).
