# A Natureza da Complexidade

> **Tese central**: o maior limitador do software é a nossa capacidade de entendê-lo. Complexidade é **qualquer coisa na estrutura de um sistema que o torna difícil de entender e de modificar**. O trabalho de design é, antes de tudo, reconhecer complexidade e combatê-la.

---

## Quando consultar

- Antes de avaliar qualquer design: é o vocabulário base usado por todas as outras referências.
- Quando for preciso justificar ao humano **por que** uma alternativa é melhor que outra.
- Ao diagnosticar um código "difícil de mexer" e for preciso nomear o problema com precisão.

---

## 1. Definição prática

Complexidade não é tamanho nem sofisticação técnica. É algo que o desenvolvedor **sente** quando tenta alcançar um objetivo:

- Se é difícil entender como um trecho funciona, ou se uma melhoria pequena exige muito esforço, o sistema é complexo.
- Se é fácil entender e modificar, o sistema é simples, mesmo que seja grande e faça coisas sofisticadas.
- Um sistema grande e sofisticado pode ser simples de trabalhar; um sistema pequeno pode ser complexo.

### A complexidade é ponderada pelo uso

A complexidade total de um sistema pode ser pensada como a soma da complexidade de cada parte, **ponderada pela fração de tempo que os desenvolvedores passam trabalhando naquela parte**:

```text
C = Σ (c_p × t_p)
```

Consequências:

- Isolar complexidade num lugar onde ela raramente é vista é **quase tão bom quanto eliminá-la**.
- Uma parte feia mas nunca tocada contribui pouco; uma parte levemente confusa e tocada todo dia contribui muito.

### O leitor é o juiz

A complexidade é mais evidente para quem lê do que para quem escreve. Se você escreveu um código que parece simples para você, mas outras pessoas o acham complexo, **ele é complexo**. O papel de quem projeta é criar código fácil de trabalhar **para os outros**, não para si mesmo.

---

## 2. Os três sintomas

| Sintoma | O que é | Exemplo típico |
| :--- | :--- | :--- |
| **Amplificação de mudança** (*change amplification*) | Uma mudança aparentemente simples exige alterações em muitos lugares. | A cor do banner de um site está repetida explicitamente em cada página; mudar a cor exige editar todas elas. |
| **Carga cognitiva** (*cognitive load*) | Quanto o desenvolvedor precisa saber para completar uma tarefa. Mais informação para absorver = mais tempo e mais risco de bug. | Uma API de alocação de memória que exige que quem chama libere cada bloco, ou uma função com muitos parâmetros que precisam ser entendidos antes do uso. |
| **Incógnitas desconhecidas** (*unknown unknowns*) | Não é óbvio quais partes do código precisam mudar, nem qual informação é necessária para fazer a mudança corretamente. | Após trocar a cor do banner centralizada, algumas páginas usam uma variação mais escura calculada à mão; nada indica que elas também precisam mudar. |

- **Incógnitas desconhecidas são o pior sintoma.** Com amplificação de mudança você ao menos sabe o que precisa editar; com carga cognitiva você sabe o que precisa ler. Aqui você não sabe o que não sabe, e só descobre quando o bug aparece.
- **Menos linhas não significa menos carga cognitiva.** Uma abordagem que exige mais linhas de código pode ser mais simples se reduz o que o desenvolvedor precisa saber.
- Um dos objetivos mais importantes de um bom design é que o sistema seja **óbvio**: o desenvolvedor adivinha rapidamente o que fazer, e adivinha certo (ver [obvious-code.md](obvious-code.md)).

---

## 3. As duas causas

Complexidade é causada por **dependências** e por **obscuridade**.

### Dependências

- Existe uma dependência quando um trecho de código **não pode ser entendido e modificado isoladamente**: ele se relaciona com outro código, que precisa ser considerado ou alterado junto.
- Exemplo: a assinatura de um método cria dependência entre sua implementação e cada chamador; mudar a assinatura obriga a mudar todos eles. Um protocolo de rede cria dependência entre quem envia e quem recebe.
- Dependências são parte fundamental do software e **não podem ser eliminadas**. O objetivo é **reduzir o número** de dependências e **tornar as restantes simples e óbvias**.

### Obscuridade

- Ocorre quando **informação importante não é óbvia**.
- Exemplos: uma variável com nome tão genérico que não carrega significado (`time`, `data`); uma unidade de medida que não está documentada; uma dependência entre dois módulos que não é visível em lugar nenhum; **inconsistência** (o mesmo nome usado para coisas diferentes, ou a mesma coisa feita de jeitos diferentes).
- Obscuridade anda junto com dependências: é comum uma dependência existir sem ser óbvia.
- **A necessidade de documentação extensa costuma ser um sinal de alerta de que o design não está certo.** A melhor forma de reduzir obscuridade é simplificar o design; documentação vem depois.

### Mapa causa → sintoma

```text
Dependências ──► amplificação de mudança
             └─► carga cognitiva
Obscuridade  ──► incógnitas desconhecidas
             └─► carga cognitiva
```

---

## 4. A complexidade é incremental

- Complexidade não vem de um único erro catastrófico. Ela se **acumula** a partir de centenas ou milhares de pequenas dependências e obscuridades.
- Cada uma, isoladamente, parece inofensiva ("é só uma dependência a mais"). Juntas, tornam o sistema difícil de mudar.
- Por ser incremental, é difícil de controlar e fácil de justificar. Por isso é preciso uma postura de **tolerância zero**: tratar cada pequena complexidade adicionada como um problema real.
- Depois de acumulada, a complexidade é difícil de remover: consertar uma única dependência ou obscuridade quase não muda nada.

---

## Red flags

- A mesma decisão ou valor aparece em vários lugares (amplificação de mudança).
- Para usar um módulo é preciso entender detalhes da implementação dele (carga cognitiva).
- Uma mudança "funcionou" mas quebrou algo distante e sem relação aparente (incógnita desconhecida).
- Um trecho só pode ser entendido lendo outro trecho (dependência não óbvia).
- A explicação de um design exige um documento extenso para fazer sentido (obscuridade).

---

## Como aplicar

Para cada alternativa de design, perguntar e registrar:

1. **Amplificação**: que tipo de mudança provável neste sistema exigiria editar vários lugares?
2. **Carga cognitiva**: o que alguém de fora precisa saber para usar este módulo? Isso pode ser reduzido?
3. **Incógnitas desconhecidas**: existe alguma dependência que não fica visível no código ou na interface?
4. **Dependências**: quantas são criadas, e cada uma é simples e óbvia?
5. **Obscuridade**: nomes, unidades, invariantes e ordens de chamada estão claros onde precisam estar?
6. **Ponderação pelo uso**: a complexidade que sobra está concentrada em partes raramente tocadas?

Use estes termos ao comunicar trade-offs ao humano: são precisos e comparáveis.

---

## Relações

- A postura necessária para combater a complexidade incremental: [strategic-programming.md](strategic-programming.md).
- A principal ferramenta estrutural contra dependências: [deep-modules.md](deep-modules.md) e [information-hiding.md](information-hiding.md).
- A principal ferramenta contra obscuridade: [obvious-code.md](obvious-code.md).
