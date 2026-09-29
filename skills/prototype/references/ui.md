# Protótipo de UI

Gere **várias variações de interface radicalmente diferentes**, lado a lado, num único HTML descartável que reproduz o visual real do projeto o mais fielmente possível. É um mockup: nunca é ligado ao app, e nada vai para o repositório.

Se a pergunta é sobre lógica ou estado, e não sobre aparência, é o ramo errado: use [`logic.md`](logic.md).

---

## 1. Quando é a forma certa

- "Como essa página deveria ficar?"
- "Quero ver algumas opções para esse dashboard antes de decidir."
- "Tenta outro layout para a tela de configurações."
- Sempre que o usuário passaria um dia escolhendo entre três mockups vagos na cabeça.

## 2. Por que avulso e lado a lado

Um protótipo ligado à rota real (seletor de variante, parâmetro `?variant=`, rota temporária) deixa código no projeto que precisa ser encontrado e removido depois, e essa remoção nunca é totalmente confiável. Um HTML avulso elimina o problema: nada é criado dentro do projeto, então não há o que limpar. E lado a lado vence alternar uma variante por vez: comparar deve ser uma olhada, não um clique.

---

## 3. Processo

### 3.1. Declarar a pergunta e escolher N

Padrão: **3 variantes**. Acima de 5 elas deixam de ser radicalmente diferentes e viram ruído; esse é o teto.

Escreva o plano em uma linha antes de rascunhar:

> "Três variantes da página de configurações, lado a lado num mockup avulso."

### 3.2. Reproduzir o ambiente real

Antes das variantes, extraia a identidade visual do projeto (cores, escala de espaçamento, tipografia, raios de borda, sombras e a aparência dos componentes compartilhados: botões, cards, inputs, navegação) de onde o projeto as define: variáveis CSS, configuração de tema ou Tailwind, código dos componentes. Copie os valores reais para o `<style>` do mockup, para cada variante parecer parte do app, e não uma página genérica de template.

Se a página tem uma moldura (cabeçalho, menu lateral, navegação) que muda como a variante é lida, aproxime-a também: estática, sem função, só o suficiente para dar contexto honesto. Sem dados reais, sem rotas.

### 3.3. Montar um HTML com as N variantes lado a lado

- Um arquivo, HTML/CSS/JS puro: sem framework, sem bundler, sem servidor, tudo inline, para abrir com duplo clique.
- As N variantes numa linha ou grade responsiva, cada uma num painel rotulado, comparáveis de relance.
- Cada painel com um nome curto e uma linha dizendo o que ele tem de estruturalmente diferente.
- As variantes precisam ser **estruturalmente diferentes**: outro layout, outra hierarquia de informação, outra ação principal, não só outras cores. Se duas saírem parecidas demais, refaça uma com uma restrição explícita ("sem grade de cards").

### 3.4. Salvar fora do repositório e abrir

Grave o arquivo num diretório temporário fora do projeto (o diretório de rascunho da sessão, se o harness tiver um), **nunca** dentro do repositório: o protótipo não pode exigir limpeza no git. Abra para o usuário ou passe o caminho.

### 3.5. Entregar

O usuário escolhe uma favorita ou descreve um híbrido ("o cabeçalho da B com o layout da C"): essa é a decisão de design. O mockup pode ser revisado e reaberto quantas vezes for preciso; ele é descartável por construção.

### 3.6. Registrar a resposta e implementar de verdade

Registre a resposta (qual variante ou híbrido, e por quê) na issue vinculada ou num commit.

A implementação do vencedor é código de produção, no componente ou página real, com os componentes e o design system reais do projeto e com o padrão normal dele (testes, tratamento de erro, acessibilidade), seguindo a skill [`coding`](../../coding/SKILL.md). O mockup é só referência visual, não fonte para copiar: ele aproximou o design system em vez de usá-lo. Apague o arquivo depois de registrar a resposta; como ele nunca esteve no projeto, não há mais nada a remover.

---

## 4. Anti-padrões

- **Variantes que diferem só em cor ou texto.** Isso é ajuste, não protótipo. Variantes de verdade discordam sobre estrutura.
- **Mockup genérico que ignora os tokens reais do projeto.** Impede julgar as variantes "como ficariam de verdade".
- **Ligar o mockup ao app real, a um servidor de desenvolvimento ou a uma rota**, mesmo que temporariamente, "só para ver".
- **Gravar o mockup dentro do repositório.** Ele pertence a fora do projeto, e é isso que torna a limpeza um não-problema.
- **Copiar o markup do mockup para produção.** Reconstrua o vencedor com os componentes e o design system reais.
