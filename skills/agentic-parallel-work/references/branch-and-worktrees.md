# Branch and Worktrees

> **Central thesis**: every delivery gets its own checkout of each repository it touches, all on one branch name, so parallel deliveries never share files and a reader recognizes the pieces of one delivery anywhere by that name.

---

## When to consult

- Starting a delivery: creating its branch and worktrees.
- Adding a repository to a delivery in flight.
- Opening the PRs of a delivery that spans several repositories.

---

## 1. Branch Name

Concise, lowercase, kebab-case:

| The delivery has | Pattern | Examples |
| :--- | :--- | :--- |
| A tracker issue | `<ISSUE-KEY>-<short-slug>` | `PROJ-89-user-profile-api`, `gh-42-fix-redirect-loop` |
| No issue | `<type>/<short-slug>`, type in `feat`, `fix`, `refactor`, `chore`, `perf`, `docs` | `feat/invoice-pdf-export`, `fix/oauth-token-expiration` |

The same name is used in every repository of the delivery.

## 2. Base Branch

- **Independent delivery**: the repository's default branch, taken from the remote after a fetch (`origin/<default>`), never a stale local copy. Without a remote, the local default branch.
- **Dependent delivery** (stacked on work not merged yet): the dependency's branch. Its PR is opened against that branch and says it is stacked and must merge after it.

## 3. Creating the Worktrees

Never switch the checkout the session was started in: other work may live there. For each repository of the delivery:

```bash
git -C <repo> fetch origin
git -C <repo> worktree add -b <branch> ../<repo>-<short-slug> origin/<default>
```

- Work inside the new worktree with absolute paths or `git -C <worktree>`.
- When the harness creates worktrees itself, use that feature and keep the branch name above.
- When the user asks to work in the current checkout, first confirm `git status` is clean, then `git switch -c <branch> origin/<default>`.

## 4. One Delivery, Several Repositories

- One PR per repository, all from the same branch name, each opened with [`pull-request`](../../pull-request/SKILL.md).
- Each PR links the others; the merge order follows the dependencies (for example, the backend first, compatible with the current frontend), and a PR that must wait for another names it as a dependency.

## 5. Conflicts and Cleanup

- Two deliveries that collide on the same files are resolved with [`resolve-branch-conflict`](../../resolve-branch-conflict/SKILL.md), which keeps what both intended.
- Finished worktrees and branches are removed with [`git-cleanup`](../../git-cleanup/SKILL.md), only with the user's approval.
