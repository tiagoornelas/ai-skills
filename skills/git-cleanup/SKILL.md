---
name: git-cleanup
description: >-
  Cleans up the local repository: syncs the default branch with the remote,
  lists every local branch and worktree (noting Herdr App agents that use it)
  with a short summary of its work, recommends which to keep (open pull
  request, recent work without a pull request, or active agent) and which to
  remove (closed or merged pull requests and everything else), lets the user
  freely edit that list, and removes only what the user explicitly approves,
  even when the branch or worktree is the one currently in use. Triggered
  when the user asks to clean, prune, or tidy local branches or worktrees.
argument-hint: "[recent-work window in days, default 14]"
---

# Git Cleanup

Removes useless local branches and worktrees without losing work the user still wants. The agent proposes, the user decides: nothing is removed before the user approves the final list.

Worktrees follow [`agentic-parallel-work`](../agentic-parallel-work/SKILL.md): a delivery has one worktree per repository, all on the same branch name, so a row's branch may have siblings in other repositories that finish together.

**Scope is local only.** Remote branches, pull requests, and the stash are never touched.

---

## 1. Preconditions

- Confirm the directory is a Git repository and locate the **main worktree** (first entry of `git worktree list --porcelain`). Run every command from it (`git -C <main>`), even when the session runs inside a linked worktree.
- Record the **calling session's location**: the worktree it runs in (`git rev-parse --show-toplevel`) and its branch (`git branch --show-current`). They can be cleaned like any other row; section 6 explains how.
- Resolve the remote (`origin` unless the repository only has another one) and the **default branch** from `git symbolic-ref --short refs/remotes/<remote>/HEAD`, stripping the `<remote>/` prefix (fall back to `main`, then `master`).
- Check whether the GitHub CLI is authenticated (`gh auth status`). Without it, pull request state cannot be detected: say so, and keep every branch that has commits not in the default branch (status **PR unknown**).
- Check whether the Herdr App is active (`test -n "${HC_TERMINAL_ID:-}" && command -v hc >/dev/null 2>&1 && command -v herdr-app >/dev/null 2>&1`). When active, read its state per [`herdr`](../herdr/SKILL.md), and record `$HC_TERMINAL_ID` as the session's own terminal, with its pane, tab, and space from `herdr-app ls`. When absent, operate as standard Git/GH CLI.

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

When the Herdr App is active, correlate **every** Git worktree path with live terminals from `hc ls`. A terminal uses a worktree when its `cwd` or its `foreground.cwd` (from `hc get <terminal>`) equals that path or lies beneath it; compare path components, not string prefixes. Record terminal address and name, its pane, tab, and space (from `herdr-app ls`), its program (`foreground.argv`), and `status.state`. Worktrees created by the Herdr App's own worktree feature live under `~/.herdr/worktrees/<repo>/<branch>` and are shown as their own space; they are still plain Git worktrees. When every terminal of such a space uses the worktree, record that space too: removing the checkout leaves the space open, so its closing (`herdr-app do space.close --id <space> --confirmed true`) is disclosed and approved with the row.

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
| **Active agent in Herdr** | Any Herdr App terminal using this worktree has status `working` or `blocked`. Removing it would abort an in-flight agent task. |
| **Default branch** | The default branch and the main worktree. Never removable, even on request. |

**Clean** everything else, including recent work whose PR is closed, split by risk so the user sees what would be lost:

- ✅ **Merged**: the work is in the default branch (merged PR, ancestry, or squash). Safe.
- ⚠️ **Closed PR, unmerged**: the PR was closed without merge. Show the count of unique commits and whether they exist on the remote (`pushed` / `local only`).
- ⚠️ **Unmerged, no PR**: stale work outside the window. Same details as above.
- ⚠️ **Detached HEAD**: a worktree with no branch whose HEAD is not in the default branch. Same details as above; use ✅ when it is.
- 🧹 **Prunable**: a worktree entry whose directory no longer exists.

Flag rows that need special handling at execution (section 6), so the user knows before approving:

- `→ switch to <default>`: the branch is checked out in the main worktree, which stays.
- `current session`: the calling session runs in this worktree.
- `open Herdr panes`: list every Herdr App pane (with its terminal, tab, and space) that will close. Mark `working` agents and the calling terminal.
- `this session's terminal`: closing it is handed to the user as a command after this session ends.

---

## 5. Present the List

Show both groups with **continuous numbering**, so the user can refer to rows by number. Keep the table compact:

```text
Default branch master: updated 3 commits (fast-forward) ✓

CLEAN (recommended)
 #  Branch                     Worktree                          Last commit  Status                     Work
 1  feat/login-sso             (main) → switch to master         2026-10-13   ✅ merged (#41)            SSO login via Google
 2  fix/date-parse             ../app-date-fix [herdr:t4 "fix"]  2026-10-12   ✅ merged (#44, squash)    Date parsing in reports
 3  spike/cache-redis          ../app-redis [current session]    2026-10-10   ⚠️ closed #39, 2 commits, pushed  Redis cache experiment
 4  chore/old-lint             —                                 2026-05-30   ⚠️ no PR, 1 commit, local only    Stricter lint rules
 5  (detached)                 ../app-tmp                        2026-06-11   🧹 prunable                —

KEEP
 #  Branch                     Worktree                          Last commit  Reason                     Work
 6  feat/billing-export        ../app-billing [herdr:t7 "bill"]  2026-10-12   active agent               CSV export of invoices
 7  fix/null-avatar            —                                 2026-09-01   open PR #57                Avatar fallback for null
 8  feat/chips-input           —                                 2026-10-14   merged #49, +4 commits     Chips below the input
 9  feat/csv-import            —                                 2026-10-09   recent work, no PR         CSV import of clients
10  master                     (main)                            2026-10-14   default branch             —
```

When a worktree is used by Herdr App terminals, annotate the **Worktree** column with each terminal's address and its tab name: `../path [herdr:<terminal> "<tab>"]`. Show the affected agent states, and disclose the tabs and spaces those panes belong to. Do not infer that closing the last pane leaves its tab or space open.

Then ask the user to approve or edit the list. Accept free-form edits ("clean 6 and 7", "keep 3", "remove only the worktree of 2"):

- Moving a **Keep** row to **Clean** is allowed, except for the default branch and the main worktree. When the moved row has uncommitted changes, unmerged commits, or commits after a merged PR, state exactly what will be lost.
- Approval to remove a worktree with open Herdr panes must explicitly include closing the listed panes. If any listed agent is `working`, obtain separate, explicit approval to interrupt that agent. A general approval of the Clean list does not authorize either action.
- A row can be cleaned partially: worktree only, or branch only (a branch checked out in a linked worktree requires removing that worktree first; one checked out in the main worktree requires switching it to the default branch).
- After any edit, show the updated **Clean** list and ask again. Proceed only on an explicit approval of the final list.

---

## 6. Execute

Process the approved rows in this order, one command per item, never stopping the whole run on a single failure:

1. **Record recovery data** for every branch before touching it: name and tip SHA.
2. **Step out of what is in use**:
   - **Branch checked out in the main worktree**: `git -C <main> switch <default>`, only if the main worktree is clean (otherwise report the failure and skip that branch). If the default branch is checked out in another worktree, use `git -C <main> switch --detach <remote>/<default>`.
   - **Session's own Herdr App terminal would close**: skip that worktree and branch here, even if the pane's current directory is elsewhere; section 7 hands the user commands to run from another checkout after ending this session.
   - **Session running inside another worktree to remove**: move its working directory to the main worktree (`cd <main>`) before removal and keep running commands from there.
   - **Other open Herdr App panes**: after the explicit approvals in section 5, close the listed panes with `herdr-app do pane.close --pane <pane-id>`, which ends their terminals. Recheck terminals and agent state (`hc ls`) immediately before closing; if new terminals or working agents appear, stop that row and obtain updated approval.
3. **Worktrees**:
   - **Plain Git worktree**: `git worktree remove <path>`. Use `--force` only for a worktree the user approved knowing it had uncommitted changes.
   - **Prunable entries**: `git worktree prune`.
4. **Branches**: `git branch -d <branch>`. If Git refuses because it does not see the work as merged (squash merges, closed PRs, commits after a merged PR, stale work), use `git branch -D <branch>` only for rows the user approved in that state.

Never run `git reset`, `git clean`, `git push --delete`, or any command on the remote.

---

## 7. Report

- One line per removed item, plus every failure with its reason.
- A **recovery block** for each deleted branch: `git branch <name> <sha>` (valid while the commits are reachable through the reflog, typically 30–90 days). Removed uncommitted changes are not recoverable; say so if any were removed.
- Final state: remaining branches and worktrees, and the default branch position against the remote.
- When the session's own Herdr App terminal must close, provide the approved commands for the user to run from another checkout after ending this session: `herdr-app do pane.close --pane <pane-id>`, `git worktree remove <path>`, followed by the approved `git -C <main> branch -d|-D <branch>`. Include its branch in the recovery block.

---

## 8. Success Validation

- [ ] The default branch was fetched and fast-forwarded (or the reason it could not be is reported); history was never rewritten, and nothing on the remote was modified.
- [ ] Every local branch and worktree appeared in exactly one group with a short work summary; each branch was matched to its PR by head name or `pr-<N>`, and the PR state drove the classification.
- [ ] Keep reasons were limited to the table's list; closed PRs were recommended for cleaning even with recent commits; closed-unmerged, stale, detached, and dirty items were flagged with what would be lost.
- [ ] Nothing was removed before the user explicitly approved the final list; every edit was re-confirmed; `--force` and `-D` were used only on rows approved in that state; the default branch and the main worktree were never removed.
- [ ] A branch in use by the main worktree was switched away only from a clean worktree; the session left a worktree before removing it; Herdr App terminals were matched by path, affected panes disclosed, closed only with explicit approval (working agents separately, state rechecked), the session's own terminal handed to the user as commands, and the `herdr` terminal CLI never used.
- [ ] The report lists every removal, every failure, and a recovery command for each deleted branch.
