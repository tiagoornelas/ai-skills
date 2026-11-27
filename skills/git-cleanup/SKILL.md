---
name: git-cleanup
description: >-
  Cleans up the local repository: syncs the default branch with the remote,
  lists every local branch and worktree (noting Herdr App agents that use it)
  with a short summary of its work, removes on its own what it recommends
  removing (closed or merged pull requests and stale work), keeps what still
  matters (open pull request, recent work without a pull request, uncommitted
  changes, or an open Herdr pane), then reports both and offers to restore a
  removed item or remove a kept one. Triggered
  when the user asks to clean, prune, or tidy local branches or worktrees.
argument-hint: "[recent-work window in days, default 14]"
---

# Git Cleanup

Removes useless local branches and worktrees without losing work the user still wants. The agent removes what it recommends without asking, because every removal it makes on its own can be restored; it then reports what it removed and kept, and the user restores or removes more.

Worktrees follow [`agentic-parallel-work`](../agentic-parallel-work/SKILL.md): a delivery has one worktree per repository, all on the same branch name, so a row's branch may have siblings in other repositories that finish together.

**Scope is local only.** Remote branches, pull requests, and the stash are never touched.

---

## 1. Preconditions

- Confirm the directory is a Git repository and locate the **main worktree** (first entry of `git worktree list --porcelain`). Run every command from it (`git -C <main>`), even when the session runs inside a linked worktree.
- Record the **calling session's location**: the worktree it runs in (`git rev-parse --show-toplevel`) and its branch (`git branch --show-current`). They can be cleaned like any other row; section 5 explains how.
- Resolve the remote (`origin` unless the repository only has another one) and the **default branch** from `git symbolic-ref --short refs/remotes/<remote>/HEAD`, stripping the `<remote>/` prefix (fall back to `main`, then `master`).
- Check whether the GitHub CLI is authenticated (`gh auth status`). Without it, pull request state cannot be detected: say so, and keep every branch that has commits not in the default branch (status **PR unknown**).
- When the Herdr App is active per [`herdr`](../herdr/SKILL.md#1-preconditions), record `$HC_TERMINAL_ID` as the session's own terminal, with its pane, tab, and space from `herdr-app ls`. When absent, operate as standard Git/GH CLI.

---

## 2. Sync the Default Branch

Run this before any analysis: merge detection depends on an up-to-date default branch.

1. `git fetch --prune <remote>`.
2. Fast-forward the local default branch, never rewriting it:
   - Checked out in a worktree → `git -C <that-worktree> pull --ff-only`, only if that worktree is clean.
   - Not checked out anywhere → `git fetch <remote> <default>:<default>`.
3. If the fast-forward fails (diverged history, dirty worktree), do not force it. Report the reason and continue the analysis against `<remote>/<default>`.

---

## 3. Collect the Facts

Gather everything up front, in as few calls as possible:

| Fact | Command |
| :--- | :--- |
| Branches, tips, upstream, last commit date | `git for-each-ref refs/heads --format='%(refname:short)\|%(objectname)\|%(upstream:short)\|%(upstream:track)\|%(committerdate:iso-strict)'` |
| Worktrees, their branch, prunable entries | `git worktree list --porcelain` |
| Uncommitted changes per worktree | `git -C <path> status --porcelain` |
| Pull requests in every state | `gh pr list --state all --limit 500 --json number,title,state,headRefName,headRefOid` |
| Commits not in the default branch | `git log --oneline <remote>/<default>..<branch>` |
| Herdr App spaces, tabs, panes & terminals (when the Herdr App is active) | `herdr-app ls`, `hc ls`, `hc get <terminal>` |

When the Herdr App is active, correlate **every** Git worktree path with live terminals from `hc ls`. A terminal uses a worktree as [`herdr`](../herdr/SKILL.md#2-read-the-state) defines it. Record terminal address and name, its pane, tab, and space (from `herdr-app ls`), its program (`foreground.argv`), and `status.state`. Worktrees created by the Herdr App's own worktree feature live under `~/.herdr/worktrees/<repo>/<branch>` and are shown as their own space; they are still plain Git worktrees. When every terminal of such a space uses the worktree, record that space too: removing the checkout leaves the space open, so its closing (`herdr-app do space.close --id <space> --confirmed true`) is shown with the row and done with its panes (section 7).

### 3.1. Which Pull Request Belongs to the Branch?

A pull request belongs to a branch when its `headRefName` equals the branch name, or when the branch is a local PR checkout named `pr-<N>` and PR #N exists. When several match (a reused branch name), the open one wins; otherwise take the highest number. Its `state` (`OPEN`, `MERGED`, `CLOSED`) drives the classification.

For a **merged** PR, also check whether the branch moved on after it: the tip has **commits after the PR** when `git merge-base --is-ancestor <branch> <headRefOid>` fails. Count them with `git rev-list --count <headRefOid>..<branch>`. If `headRefOid` is not available locally, run the squash check of 3.2 instead: commits count as after the PR only when that check also fails, and their count is reported as unknown.

### 3.2. Is the Work Merged?

A branch counts as **merged** when any of these hold:

1. **Ancestry**: `git merge-base --is-ancestor <branch> <remote>/<default>`.
2. **Merged pull request**: its PR (3.1) is merged and the tip has no commits after it.
3. **Squash or rebase merge** (checked only when ancestry fails): the branch's combined diff already exists in the default branch:
   ```bash
   base=$(git merge-base <remote>/<default> <branch>)
   probe=$(git commit-tree "<branch>^{tree}" -p "$base" -m probe)
   git cherry <remote>/<default> "$probe"   # a leading "-" means already applied
   ```

An upstream marked `[gone]` is only a hint, never proof of merge.

### 3.3. Summary of the Work

Write one short phrase (at most ~8 words, in the user's session language) saying **what the work is**, not its status. Sources, in order: the PR title, the subjects of the commits unique to the branch, the latest commit subjects, the branch name.

---

## 4. Classify

Evaluate each branch together with the worktree that checks it out: they form one row. Detached-HEAD worktrees and prunable worktree entries get their own rows.

The pull request state is the main signal: an open PR keeps the work, a closed PR (merged or not) proves it was finished or abandoned. Recency only protects work that never got a PR.

**Keep** when at least one holds, and name the reason:

| Reason | Rule |
| :--- | :--- |
| **Open PR** | The branch's pull request (3.1) is open. |
| **Recent work** | The branch has no pull request, is not merged (3.2), and its last commit is within the window (argument, default **14 days**). |
| **Commits after merged PR** | The branch's PR is merged, but the tip has commits after it (3.1). Show their count and whether they are `pushed` or `local only`. |
| **PR unknown** | `gh` is unavailable and the branch has commits not in the default branch. |
| **Uncommitted changes** | The worktree has staged, unstaged, or untracked files. They cannot be recovered after removal. |
| **Open Herdr pane** | A Herdr App terminal uses this worktree, including the session's own. Removing it would close the pane or pull the directory from under its agent. |
| **Default branch** | The default branch and the main worktree. Never removable, even on request. |

**Clean** everything else, including recent work whose PR is closed, split by risk so the report shows what was removed:

- ✅ **Merged**: the work is in the default branch (merged PR, ancestry, or squash). Safe.
- ⚠️ **Closed PR, unmerged**: the PR was closed without merge. Show the count of unique commits and whether they exist on the remote (`pushed` / `local only`).
- ⚠️ **Unmerged, no PR**: stale work outside the window. Same details as above.
- ⚠️ **Detached HEAD**: a worktree with no branch whose HEAD is not in the default branch. Same details as above; use ✅ when it is.
- 🧹 **Prunable**: a worktree entry whose directory no longer exists.

## 5. Clean the Recommended Rows

Remove every **Clean** row without asking, one command per item, never stopping the whole run on a single failure:

1. **Record recovery data** before touching anything: each branch's name and tip SHA, and each worktree's path and branch.
2. **Step out of what is in use**:
   - **Branch checked out in the main worktree**: `git -C <main> switch <default>`, only if the main worktree is clean (otherwise skip that branch and report why). If the default branch is checked out in another worktree, use `git -C <main> switch --detach <remote>/<default>`.
   - **Session running inside a worktree to remove**: `cd <main>` first and keep running commands from there.
3. **Worktrees**: `git worktree remove <path>` (never `--force`: a dirty worktree is a Keep row); `git worktree prune` for prunable entries.
4. **Branches**: `git branch -d <branch>`; when Git refuses because it does not see the work as merged (squash merge, closed PR, stale work), `git branch -D <branch>`, since the recovery data restores it.

Never run `git reset`, `git clean`, `git push --delete`, or any command on the remote.

---

## 6. Report and Offer

Show what was removed and what was kept, with **continuous numbering** so the user can refer to rows by number, and the group names and headers in the user's session language:

```text
Default branch master: updated 3 commits (fast-forward) ✓

REMOVED
 #  Branch                     Worktree                          Last commit  Status                            Work
 1  feat/login-sso             (main) → switched to master       2026-10-13   ✅ merged (#41)                   SSO login via Google
 2  spike/cache-redis          ../app-redis                      2026-10-10   ⚠️ closed #39, 2 commits, pushed  Redis cache experiment
 3  chore/old-lint             —                                 2026-05-30   ⚠️ no PR, 1 commit, local only    Stricter lint rules
 4  (detached)                 ../app-tmp                        2026-06-11   🧹 prunable                       —

KEPT
 #  Branch                     Worktree                          Last commit  Reason                            Work
 5  fix/date-parse             ../app-date-fix [herdr:t4 "fix"]  2026-10-12   open Herdr pane (idle), merged #44  Date parsing in reports
 6  fix/null-avatar            —                                 2026-09-01   open PR #57                       Avatar fallback for null
 7  feat/chips-input           —                                 2026-10-14   merged #49, +4 commits            Chips below the input
 8  master                     (main)                            2026-10-14   default branch                    —

Restore:  git branch spike/cache-redis 4f2a9c1   …
```

- Every failure appears with its reason.
- A kept worktree used by Herdr App terminals shows each terminal's address and tab name, `../path [herdr:<terminal> "<tab>"]`, with its agent state and the PR state the row would have otherwise.
- The **restore block** holds `git branch <name> <sha>` per removed branch, and `git worktree add <path> <branch>` per removed worktree; a branch stays restorable while its commits are in the reflog (typically 30 to 90 days).

End with two questions: restore any removed row, and remove any kept row.

---

## 7. Restore or Remove More

- **Restore**: run the row's restore commands. A prunable entry is not restored.
- **Remove a kept row**, as section 5 does, on the user's answer:
  - State first what is lost when the row has uncommitted changes (unrecoverable; removed with `--force`), unmerged commits, or commits after a merged PR.
  - An open Herdr pane is closed with `herdr-app do pane.close --pane <pane-id>` only when the answer names the pane closing; a `working` or `blocked` agent needs its own explicit yes. Recheck `hc ls` right before closing.
  - The session's own terminal is never closed by the session: hand the user `herdr-app do pane.close --pane <pane-id>`, `git worktree remove <path>`, and `git -C <main> branch -d|-D <branch>` to run from another checkout after ending it.
  - The default branch and the main worktree are never removed, even on request.
- A row can be handled partially: worktree only, or branch only (a branch checked out in a linked worktree needs that worktree removed first).

---

## 8. Success Validation

- [ ] The default branch was fetched and fast-forwarded (or the reason it could not be is reported); history was never rewritten, and nothing on the remote was modified.
- [ ] Every local branch and worktree appeared in exactly one group with a short work summary; each branch was matched to its PR by head name or `pr-<N>`, and the PR state drove the classification.
- [ ] Keep reasons were limited to the table's list; closed PRs were cleaned even with recent commits; closed-unmerged, stale, and detached rows showed what was removed.
- [ ] Only Clean rows were removed without asking, never with `--force` and never closing a Herdr pane; the default branch and the main worktree were never removed.
- [ ] A branch in use by the main worktree was switched away only from a clean worktree, and the session left a worktree before removing it.
- [ ] The report listed every removal, every kept row with its reason, every failure, and a restore command per removed branch and worktree, then asked what to restore and what else to remove; a pane closed later had its explicit yes (working agents separately), and the `herdr` terminal CLI was never used.
