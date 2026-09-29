# Sem Referências Locais em Artefatos Compartilhados

> **Tese central**: um artefato que outra pessoa vai ler (commit, PR, comentário de revisão, issue, relatório, handoff para um colega) só pode apontar para o que **essa pessoa consegue abrir**.

---

## Quando consultar

- Ao escrever qualquer texto que sai da máquina: mensagem de commit, descrição de PR, comentário de revisão, issue, tarefa, relatório, mensagem para um colega.

---

## A regra

Nunca cite:

- caminhos da máquina (`/Users/...`, `~/...`, `C:\...`);
- pastas e arquivos que costumam ficar fora do controle de versão (`docs/tickets/`, `docs/prd/`, `docs/research/`, qualquer coisa no `.gitignore`);
- ids de tickets que só existem localmente.

No lugar disso:

- aponte para a **issue vinculada** (Jira, GitHub Issues, Linear) ou para um PR, commit ou página que o leitor consegue abrir;
- ou **reescreva a informação** com suas palavras, no próprio artefato.

Caminhos de arquivos **versionados no repositório** (ex.: `src/billing/invoice.ts:42`) são permitidos: quem lê o PR ou o commit tem acesso a eles.
