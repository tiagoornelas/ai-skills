# Modificando Código Existente

> **Tese central**: o design de um sistema é definido muito mais pela evolução do código do que pelo seu desenho inicial. Ao terminar cada mudança, o sistema deveria ter **a estrutura que teria se tivesse sido projetado desde o início com essa mudança em mente**.

---

## Quando consultar

- Em toda tarefa que altera um sistema existente: nova feature, correção de bug, ajuste de comportamento.
- Quando a solução mais rápida é um "remendo" que encaixa a mudança sem mexer no design.
- Ao decidir se e quanto refatorar como parte de uma tarefa.
- Ao lidar com comentários e documentação afetados por uma mudança.

---

## 1. Permaneça estratégico

- Software é desenvolvido de forma incremental: o design inicial é só o começo, e a maior parte da vida do sistema é gasta em modificações. Isso torna a postura durante as mudanças decisiva (ver [strategic-programming.md](strategic-programming.md)).
- A tentação ao modificar código existente é fazer a **menor mudança possível** que resolva o problema: "não quero mexer no que funciona", "não quero introduzir bugs". Isso é pensamento tático.
- Cada mudança mínima tende a acrescentar um caso especial, uma dependência ou uma obscuridade. Uma após a outra, o sistema degrada.
- **Se você não está melhorando o design, provavelmente está piorando.**

### O objetivo de cada mudança

- Pergunte: **"este é o melhor design possível para o sistema, dado o que sei agora e a mudança que preciso fazer?"**
- Isso pode exigir refatorar partes do código para que a mudança se encaixe de forma natural, em vez de ser "encaixada" à força.
- Ao modificar código, sempre procure uma oportunidade de **melhorar um pouco o design** do sistema no caminho.

### Quando o ideal é caro demais

- Às vezes a refatoração ideal é grande demais para o momento (prazo real, risco alto, escopo muito maior que a tarefa).
- Nesses casos, a pergunta é: **existe uma alternativa quase tão limpa que caiba no tempo disponível?** Muitas vezes existe.
- Se não houver e for preciso ser tático, que isso seja uma **decisão consciente**, e não o padrão. Registre o que ficou pendente e planeje o conserto.

---

## 2. Mantenha comentários atualizados junto com o código

Mudanças no código tendem a deixar comentários e documentação desatualizados. Práticas para evitar:

### Coloque comentários perto do código

- Quanto mais distante um comentário estiver do código que ele descreve, maior a chance de ele não ser atualizado.
- Comentários de interface ficam junto à declaração (assinatura) do que descrevem. Comentários de implementação ficam dentro do corpo, perto do trecho que explicam.
- Evite documentar decisões de implementação em arquivos ou lugares separados, que ninguém verá ao mudar o código.

### Comentários pertencem ao código, não ao log de commits

- É comum explicar uma mudança detalhadamente na mensagem de commit e não no código. Mas quem lê o código depois raramente consulta o histórico de commits.
- Se a informação é necessária para entender ou modificar o código no futuro, ela deve estar **no código**. A mensagem de commit pode resumir e apontar para o comentário.

### Evite duplicação

- Se a mesma informação é documentada em vários lugares, é difícil manter todas as cópias atualizadas.
- **Documente cada decisão uma única vez**, no lugar mais óbvio para quem vai precisar dela. Nos outros lugares, referencie esse ponto ("ver comentário em X").
- Não repita no código de uma camada a documentação de outra camada; referencie.

### Verifique o diff

- Antes de concluir uma mudança, **revise o diff** inteiro para garantir que cada alteração está refletida corretamente na documentação e nos comentários.

### Comentários de mais alto nível duram mais

- Comentários que descrevem **o quê** e **por quê** (intenção, abstração, invariantes) são mais estáveis que comentários que descrevem **como** linha a linha. Eles não precisam mudar a cada ajuste de implementação.

---

## Red flags

- Uma mudança que adiciona um caso especial (`if` para a nova situação) em vez de ajustar a abstração.
- "Não mexe nisso, só adiciona aqui do lado."
- A mesma mudança precisou ser replicada em vários lugares (a estrutura não comportava a mudança).
- O diff altera comportamento mas não toca em nenhum comentário ou documentação relacionada.
- A explicação de por que o código é assim está apenas na mensagem de commit ou no ticket.

---

## Como aplicar

Ao desenhar uma mudança em sistema existente:

1. **Leia o design atual** da área afetada: módulos, contratos, decisões escondidas. Não projete no vazio.
2. **Imagine o design ideal** considerando a nova necessidade, como se o sistema estivesse sendo projetado do zero com ela.
3. **Meça a distância** entre o design atual e o ideal:
   - Pequena → faça a mudança já no formato ideal, incluindo a refatoração necessária.
   - Grande → proponha uma alternativa quase tão limpa que caiba no escopo; se não houver, **escale ao humano** como trade-off explícito (custo agora vs. custo futuro).
4. **Deixe a área melhor** do que encontrou, mesmo que um pouco.
5. **Atualize a documentação no mesmo movimento**: comentários de interface, contratos, decisões. Cada decisão documentada uma única vez, perto do código.
6. **Revise o diff** antes de entregar.

Mudanças de contrato identificadas neste processo são decisões da Camada Humana; refatorações internas que preservam contratos são da Camada do Agente.

---

## Relações

- A postura de investimento: [strategic-programming.md](strategic-programming.md).
- Como a complexidade se acumula a cada mudança tática: [nature-of-complexity.md](nature-of-complexity.md).
- O leitor futuro do código modificado: [obvious-code.md](obvious-code.md).
