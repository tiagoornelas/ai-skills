---
name: git-branch
description: >-
  Creates and sets up a new Git working branch for a given task, enforcing
  naming conventions and ensuring the correct base branch is selected and up to date.
---

# Git Branch

Standardized skill for creating and preparing Git development branches.

---

## 1. Naming Conventions

Branch names must be concise, lowercase, and hyphen-delimited (*kebab-case*).

### Pattern 1: With Formal Issue or Ticket
If the task has a formal tracking key (Jira, GitHub Issues, Linear, etc.):
```text
<ISSUE-KEY>-<short-kebab-slug>
```
*Examples:*
- `DEV-1423-persist-session-token`
- `gh-42-fix-redirect-loop`
- `PROJ-89-user-profile-api`

### Pattern 2: Without Issue Key
If there is no formal linked issue, use the semantic work-type prefix:
```text
<type>/<short-kebab-slug>
```
*Accepted types:* `feat`, `fix`, `refactor`, `chore`, `perf`, `docs`.
*Examples:*
- `feat/jwt-authentication-middleware`
- `fix/oauth-token-expiration`
- `refactor/extract-query-builder`
- `chore/setup-eslint-rules`

---

## 2. Base Branch Selection

1. **Independent Work (Default)**:
   - Base is the repository's default branch (`main` or `master`).
   - The base branch must be synchronized with the remote before creating the new branch (`git fetch` and `git pull --ff-only`).

2. **Stacked / Dependent Work**:
   - If work depends on another in-flight feature branch not yet merged into `main`, the base of the new branch must be that **dependency's branch**.

---

## 3. Execution Workflow

1. **State Verification**:
   - Run `git status` to confirm the working tree is clean (no uncommitted edits or staged changes).
2. **Base Branch Synchronization**:
   - Switch to the base branch and ensure it is up to date:
     ```bash
     git checkout <base-branch>
     git pull --ff-only
     ```
3. **Branch Creation**:
   - Create and switch to the new branch adhering to naming conventions:
     ```bash
     git checkout -b <branch-name>
     ```
4. **Confirmation**:
   - Confirm to the developer the created branch name and its upstream base.

---

## 4. Success Validation

- [ ] Working tree was clean prior to branch creation (`git status`).
- [ ] Base branch was synchronized with remote (`git pull --ff-only`).
- [ ] Branch name adheres strictly to kebab-case with issue key (`DEV-123-slug`) or semantic prefix (`feat/slug`).
- [ ] The new branch was successfully created and reported to the developer.
