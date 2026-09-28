# Puxe a Complexidade para Baixo

> **Tese central**: é mais importante um módulo ter uma **interface simples** do que uma **implementação simples**. A maioria dos módulos tem muito mais usuários que desenvolvedores; é melhor que os desenvolvedores do módulo sofram do que os usuários.

---

## Quando consultar

- Quando surgir a tentação de "deixar o chamador decidir": lançar uma exceção, expor um parâmetro de configuração, exigir um passo extra.
- Ao decidir em qual camada uma lógica difícil deve morar.
- Ao desenhar APIs públicas, SDKs, bibliotecas internas ou serviços consumidos por vários clientes.

---

## 1. O princípio

- Ao desenvolver um módulo, se surgir uma complexidade inevitável, procure uma forma de **absorvê-la dentro do módulo** em vez de empurrá-la para quem usa.
- Complexidade na implementação de um módulo é paga uma vez, por quem o desenvolve. Complexidade na interface é paga por **cada** usuário, **toda vez** que ele usa o módulo.
- É tentador fazer o contrário. Quando aparece uma condição que não se sabe tratar, o mais fácil é:
  - lançar uma exceção e deixar o chamador lidar;
  - expor um parâmetro de configuração e deixar o administrador escolher;
  - documentar "o chamador deve garantir que...".
- Essas saídas facilitam a vida de quem escreve o módulo hoje, mas **multiplicam** a complexidade: cada chamador precisa lidar com o problema, e geralmente com menos informação do que o módulo tinha.

---

## 2. Exemplo: a classe de texto do editor

- Se a classe de texto expõe uma interface orientada a linhas, cada operação de edição na UI precisa lidar com divisão e junção de linhas. A complexidade subiu para a UI, e se repete em cada operação.
- Uma interface orientada a caracteres **puxa essa complexidade para baixo**: a classe de texto trata linhas internamente uma vez, e toda a UI fica mais simples.

---

## 3. Exemplo: parâmetros de configuração

- Parâmetros de configuração são um exemplo clássico de **empurrar complexidade para cima**. Em vez de determinar um comportamento internamente, a classe exporta um parâmetro e deixa o usuário escolher.
- Eles parecem úteis (o usuário ajusta o sistema às suas necessidades), mas também são uma **desculpa para não resolver problemas difíceis**, passando-os para outra pessoa. Na maioria dos casos o usuário ou administrador tem ainda **menos** condições de escolher o valor certo do que o próprio módulo.
- Exemplo: um protocolo de rede com um parâmetro para o intervalo de retransmissão de requisições perdidas. É melhor o próprio protocolo **medir o tempo de resposta** das requisições bem-sucedidas e calcular um intervalo razoável (por exemplo, um múltiplo do tempo medido). Isso é mais simples para o usuário e se adapta sozinho às condições do ambiente.
- Pergunta-chave antes de exportar um parâmetro: **"os usuários (ou os módulos de nível mais alto) conseguem determinar um valor melhor do que conseguimos determinar aqui?"** Se não, não exponha.
- Quando for inevitável criar um parâmetro, forneça um **valor padrão razoável**, para que o usuário só precise informá-lo em casos excepcionais. Idealmente o módulo calcula o valor automaticamente e o parâmetro existe só para sobrescrever em situações raras.
- Evitar parâmetros de configuração tanto quanto possível.

---

## 4. Levando longe demais

- Puxar complexidade para baixo não significa colocar **tudo** dentro de um único módulo. É preciso discernimento.
- Puxar complexidade para baixo faz mais sentido quando:
  1. a complexidade está **intimamente relacionada à funcionalidade que o módulo já tem**;
  2. puxá-la para baixo resulta em **muitas simplificações** em outros lugares da aplicação;
  3. puxá-la para baixo **simplifica a interface** do módulo.
- Contra-exemplo: adicionar à classe de texto um método `backspace` porque a UI precisa dele. Isso não é puxar complexidade para baixo; é **vazar um conceito da UI** para a classe de texto. Não simplifica a interface (adiciona um método) e só serve a um caller. A funcionalidade de backspace pertence à UI, implementada sobre a interface geral (ver [general-purpose-modules.md](general-purpose-modules.md)).
- O objetivo é **minimizar a complexidade total do sistema**, não mover complexidade de lugar sem critério.

---

## Red flags

- Exceções lançadas por condições que o próprio módulo teria informação para tratar.
- Parâmetros de configuração cujo valor ideal poderia ser calculado internamente.
- Documentação do tipo "o chamador deve sempre..." ou "lembre-se de chamar X antes de Y".
- O mesmo trecho de tratamento repetido em todos os chamadores de um módulo.
- Um módulo "genérico" que exige que cada cliente faça pré e pós-processamento idênticos.

---

## Como aplicar

1. Para cada dificuldade no design (erro, ambiguidade, ajuste fino, ordem de chamada), pergunte: **quem tem mais informação para resolvê-la?** Normalmente é o módulo, não o chamador.
2. Se o módulo pode resolver, resolva dentro dele. Registre na interface **o resultado** (o que é garantido), não o mecanismo.
3. Para cada parâmetro de configuração proposto, aplique a pergunta-chave e prefira cálculo automático com padrão razoável.
4. Verifique os três critérios de "levar longe demais" antes de mover algo para baixo: relação com a funcionalidade existente, simplificação em outros lugares, interface mais simples.
5. Ao reportar ao humano, destaque quais decisões foram **absorvidas** pelo módulo e quais foram **deixadas explicitamente** para o chamador, e por quê. As deixadas para o chamador fazem parte do contrato e são decisões da Camada Humana.

---

## Relações

- Puxar complexidade para baixo é o que torna um módulo profundo: [deep-modules.md](deep-modules.md).
- Mascarar exceções é um caso de puxar complexidade para baixo: [define-errors-out-of-existence.md](define-errors-out-of-existence.md).
- A fronteira entre generalidade e especialização: [general-purpose-modules.md](general-purpose-modules.md).
