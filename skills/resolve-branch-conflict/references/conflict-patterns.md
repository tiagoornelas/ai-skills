# Padrões de Conflito

Catálogo usado pela seção 3 do [`SKILL.md`](../SKILL.md) para classificar cada ponto de conflito, e pela seção 6 para resolvê-lo. Um padrão diz **como reconhecer** o conflito e **qual resolução** preserva os dois lados.

---

## 🟢 Mecânicos

| Padrão | Como reconhecer | Resolução |
| :--- | :--- | :--- |
| **Adições vizinhas** | Os dois lados adicionam linhas independentes no mesmo lugar: imports, entradas de lista, rotas, chaves de config, casos de `switch`. | Manter as duas, na ordem que a convenção do arquivo pede (alfabética, por grupo). Sem duplicatas. |
| **Formatação × conteúdo** | Um lado só reformatou (ou o formatador mudou) e o outro mudou conteúdo. | Pegar o conteúdo e rodar o formatador do projeto. |
| **Arquivo gerado** | Código gerado, snapshots de build, clientes de API, esquemas compilados. | Resolver as fontes e **regenerar**. Nunca mesclar à mão. |
| **Lockfile** | `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `poetry.lock`, `Gemfile.lock`, `go.sum` etc. | Resolver o manifesto (`package.json`, `pyproject.toml`...), depois regenerar o lock com o gerenciador. Se as duas versões de uma dependência diferem, é 🟡. |
| **Mudança idêntica** | Os dois lados fizeram a mesma alteração (cherry-pick, correção repetida). | Manter uma. |
| **Remoção × nada** | Um lado removeu código que o outro não tocou, mas o contexto vizinho mudou. | Aplicar a remoção. Se o outro lado passou a usar o código removido, é ⚠️. |

---

## 🟡 Composição

| Padrão | Como reconhecer | Resolução |
| :--- | :--- | :--- |
| **Mesma função, preocupações diferentes** | Um lado adicionou validação, outro adicionou log, cache ou normalização na mesma função. | Compor na ordem que faz sentido para o domínio (ex.: normalizar → validar → persistir). Explicitar a ordem na proposta. |
| **Parâmetro novo dos dois lados** | Os dois adicionaram parâmetros ou campos à mesma assinatura ou estrutura. | Manter os dois; atualizar todas as chamadas dos dois lados. |
| **Versões diferentes de uma dependência** | Os dois lados subiram a mesma dependência para versões distintas. | Usar a maior compatível com o código dos dois lados; rodar os testes de ambos. |
| **Edição × movimentação** | Um lado moveu ou extraiu um trecho (para outro arquivo ou função); o outro editou o trecho no lugar antigo. | Aplicar a edição no lugar novo. O Git mostra conflito no lugar antigo, ou nenhum: confira sempre. |
| **Migrações paralelas** | Os dois lados criaram migrações de banco com a mesma sequência ou mexendo na mesma tabela. | Reordenar/renumerar conforme a ferramenta de migração; se tocam as mesmas colunas, é 🔴. |

---

## 🔴 Intenções em choque

| Padrão | Como reconhecer | Opções típicas para o usuário |
| :--- | :--- | :--- |
| **Refatoração × extensão** | Um lado reestruturou (novo módulo, nova abstração), o outro estendeu a estrutura antiga. | Portar a extensão para a estrutura nova (geralmente recomendado) · adiar a refatoração. |
| **Abstrações gêmeas** | Os dois lados criaram, em paralelo, conceitos para a mesma coisa (dois helpers, dois tipos, dois serviços). | Unificar num só (qual nome, qual interface) · manter os dois com fronteira clara, se forem de fato coisas diferentes. |
| **Regras contraditórias** | As duas mudanças implementam regras de negócio que não podem valer ao mesmo tempo. | Não é decisão técnica: levar ao usuário, que pode precisar consultar produto ou os autores. |
| **Contrato alterado dos dois lados** | Os dois mudaram a mesma interface pública, endpoint ou esquema de formas diferentes. | Um contrato que atende aos dois consumidores · versionar · escolher um e adaptar o outro. Passar por `software-designing`. |
| **Remoção × uso** | Um lado removeu uma funcionalidade; o outro passou a depender dela. | Manter a remoção e reescrever o uso · desfazer a remoção. Perguntar por que foi removida. |

---

## ⚠️ Semânticos (sem conflito textual)

O merge "passa", mas o resultado quebra ou muda de comportamento. Procure ativamente quando um lado alterou:

- **Nome ou assinatura** de função, método, classe, variável exportada: busque usos novos do nome antigo no outro lado.
- **Formato de dado**: campo renomeado, tipo mudado, JSON de resposta alterado, evento com outro payload.
- **Esquema de banco**: coluna renomeada ou removida, restrição nova (ex.: `NOT NULL`) que o código novo do outro lado não respeita.
- **Comportamento padrão**: valor default, ordem de execução, flag ligada/desligada, tratamento de erro (passou a lançar exceção, deixou de retornar `null`).
- **Configuração e ambiente**: variável de ambiente renomeada, chave de config movida.
- **Invariantes implícitas**: um lado passou a assumir algo (lista ordenada, id sempre presente) que o outro deixou de garantir.

Receita de detecção:

```bash
# símbolos alterados ou removidos por um lado
git diff <merge-base> <lado-A> | grep -E '^-' | <extrair identificadores>

# usos desses símbolos no código novo do outro lado
git diff <merge-base> <lado-B> | grep -E '^\+' | grep -E '<símbolo>'
```

Depois do merge, a prova final é rodar build, verificador de tipos e os testes dos dois lados. Em linguagens sem verificação estática forte, escreva ou rode um teste que exercite o ponto ⚠️.
