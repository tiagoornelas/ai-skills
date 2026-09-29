---
name: git-branch
description: >-
  Cria e prepara uma nova branch de trabalho no Git para uma determinada tarefa, aplicando as convenções de nomenclatura e garantindo que a branch base correta seja selecionada e atualizada.
---

# Git Branch

Skill para criação e preparação padronizada de branches de desenvolvimento.

---

## 1. Convenções de Nomenclatura

O nome da branch deve ser conciso, em minúsculas e utilizar hífens como separador (*kebab-case*).

### Padrão 1: Com Issue ou Ticket Formal
Se a tarefa possuir uma chave formal de rastreamento (Jira, GitHub Issues, Linear, etc.):
```text
<CHAVE-DA-ISSUE>-<short-kebab-slug>
```
*Exemplos:*
- `DEV-1423-persist-session-token`
- `gh-42-fix-redirect-loop`
- `PROJ-89-user-profile-api`

### Padrão 2: Sem Chave de Issue
Se não houver uma issue formal vinculada, utilize o prefixo semântico do tipo de trabalho:
```text
<tipo>/<short-kebab-slug>
```
*Tipos aceitos:* `feat`, `fix`, `refactor`, `chore`, `perf`, `docs`.
*Exemplos:*
- `feat/jwt-authentication-middleware`
- `fix/oauth-token-expiration`
- `refactor/extract-query-builder`
- `chore/setup-eslint-rules`

---

## 2. Seleção da Branch Base

1. **Trabalho Independente (Padrão)**:
   - A base é a branch principal do repositório (`main` ou `master`).
   - A branch base deve ser sincronizada com o remoto antes de extrair a nova branch (`git fetch` e `git pull --ff-only`).

2. **Trabalho Empilhado / Dependente (*Stacked Branch*)**:
   - Se o trabalho depender de outra tarefa que já está em desenvolvimento em uma branch própria e ainda não foi mergeada na `main`, a base da nova branch deve ser a **branch dessa dependência**.

---

## 3. Fluxo de Execução

1. **Verificação de Estado**:
   - Execute `git status` para confirmar que a árvore de trabalho está limpa (sem arquivos modificados ou conflitos não commitados).
2. **Definição da Base**:
   - Vá para a branch base e garanta que ela esteja atualizada:
     ```bash
     git checkout <base-branch>
     git pull --ff-only
     ```
3. **Criação da Branch**:
   - Crie e troque para a nova branch seguindo a convenção de nomenclatura:
     ```bash
     git checkout -b <nome-da-branch>
     ```
4. **Confirmação**:
   - Confirme para o desenvolvedor o nome da branch criada e a base de onde ela partiu.

---

## 4. Validação de Sucesso

- [ ] A árvore de trabalho estava limpa antes de criar a branch (`git status`).
- [ ] A branch base foi atualizada com o remoto (`git pull --ff-only`).
- [ ] O nome da branch segue rigorosamente a convenção kebab-case com chave de issue (`DEV-123-slug`) ou tipo semântico (`feat/slug`).
- [ ] A nova branch foi criada e confirmada para o desenvolvedor.
