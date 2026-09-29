# Princípios de Refatoração

> **Tese central**: refatorar é **mudar a estrutura interna do código sem mudar o comportamento observável**. Refatoração só é segura quando vem em passos pequenos, com testes verdes antes e depois, e nunca misturada com mudança de comportamento.

---

## Quando consultar

- Antes de alterar código existente que está difícil de mudar.
- No passo "refactor" do ciclo red → green → refactor.
- Ao corrigir um achado de code smell (ver [code-smells.md](code-smells.md)).
- Ao decidir se uma melhoria de estrutura vale a pena agora.

---

## 1. Regras

- **Comportamento preservado.** Se o comportamento observável muda, não é refatoração: é uma mudança de funcionalidade, com seus próprios testes e sua própria DoD.
- **Testes verdes antes e depois.** Se a área não tem testes que observem o comportamento, escreva-os primeiro, ou não refatore.
- **Passos pequenos.** Cada passo deixa os testes verdes. Se um passo quebra algo, desfaça o passo em vez de depurar uma mudança grande.
- **Dois chapéus.** Num dado momento, ou se acrescenta comportamento, ou se refatora. Nunca os dois no mesmo passo, e nunca no mesmo commit.

---

## 2. Quando refatorar

- **Preparatória**: antes de uma mudança, reestruture para que a mudança fique fácil; depois, faça a mudança fácil. É a refatoração de maior retorno.
- **De compreensão**: se foi preciso esforço para entender um trecho que a tarefa altera, deixe esse entendimento no código (nome melhor, condicional mais clara).
- **Depois do verde**: no passo "refactor", limpe o que a própria tarefa acabou de escrever.

Em todos os casos, **só no código que a tarefa toca**. Refatorar o que está ao redor, sem relação com a tarefa, aumenta o diff, o risco e o custo de revisão.

---

## 3. Quando não refatorar

- O código funciona, não precisa mudar e ninguém precisa entendê-lo agora.
- Vai ser reescrito ou removido em breve.
- Não há testes, e escrevê-los custaria mais que o benefício.
- A melhoria é preferência de estilo, sem um cenário concreto de leitura ou mudança que fique mais fácil.

---

## 4. Refatoração e a Camada Humana

- Refatoração do agente acontece **abaixo dos contratos**. Uma mudança que alguém fora do módulo perceberia (assinatura pública, responsabilidade entre módulos, fronteiras, direção das dependências) não é refatoração: é Camada Humana, pelo teste da fronteira de [`ai-assisted-software-development`](../../ai-assisted-software-development/SKILL.md) (seção 4). Não aplique; escale com [`software-designing`](../../software-designing/SKILL.md).

---

## 5. Desempenho

- Escreva primeiro o código claro. Otimize depois, só onde uma **medição** mostrar que é necessário, e isole a otimização.

---

## Relações

- O que refatorar e como: [code-smells.md](code-smells.md).
- Por que estrutura importa: [nature-of-complexity.md](../../software-designing/references/nature-of-complexity.md).
- Mudanças em código existente, no nível de design: [strategic-programming.md](../../software-designing/references/strategic-programming.md) (seção 5).
- Commits de refatoração separados dos de comportamento: [`commit`](../../commit/SKILL.md).
