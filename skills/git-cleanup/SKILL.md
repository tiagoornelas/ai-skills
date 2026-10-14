---
name: git-cleanup
description: >-
  Cleans up the local repository: syncs the default branch with the remote,
  lists every local branch and worktree (including Herdr-managed worktrees)
  with a short summary of its work, recommends which to remove (merged or
  stale work) and which to keep (recent work, open pull request, or active
  agent), lets the user freely edit that list, and removes only what the
  user explicitly approves. Triggered when the user asks to clean, prune,
  or tidy local branches or worktrees.
argument-hint: "[recent-work window in days, default 14]"
---

# Git Cleanup

Removes useless local branches and worktrees without losing work the user still wants. The agent proposes, the user decides: nothing is removed before the user approves the final list.

**Scope is local only.** Remote branches, pull requests, and the stash are never touched.

---

## 1. Preconditions

- Confirm the directory is a Git repository and locate the **main worktree** (first entry of `git worktree list --porcelain`). Run every command from it.
- Resolve the remote (`origin` unless the repository only has another one) and the **default branch** from `git symbolic-ref --short refs/remotes/<remote>/HEAD`, stripping the `<remote>/` prefix (fall back to `main`, then `master`).
- Check whether the GitHub CLI is authenticated (`gh auth status`). Without it, open pull requests cannot be detected: say so, and keep every branch that has commits not in the default branch (status **PR unknown**).
- Check whether Herdr is active (`test "${HERDR_ENV:-}" = 1 && command -v herdr >/dev/null 2>&1`). When active, record `$HERDR_WORKSPACE_ID` as the protected active session. When absent or disabled, operate as standard Git/GH CLI.

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
| Open pull requests | `gh pr list --state open --limit 500 --json number,title,headRefName` |
| Merged pull requests | `gh pr list --state merged --limit 500 --json number,title,headRefName,headRefOid` |
| Commits not in the default branch | `git log --oneline <remote>/<default>..<branch>` |
| Herdr worktrees & workspaces (when Herdr is active) | `herdr worktree list` and `herdr workspace list` |

When Herdr is active, correlate each Git worktree path with Herdr worktree entries (`.result.worktrees[].path`). If matched, look up its `open_workspace_id` in `herdr workspace list` to obtain the workspace `label` and `agent_status` (`working`, `idle`, `done`).

### 3.1. Is the Work Merged?

A branch counts as **merged** when any of these hold:

1. **Ancestry**: `git merge-base --is-ancestor <branch> <remote>/<default>`.
2. **Merged pull request**: a merged PR has `headRefName` equal to the branch and its `headRefOid` equals the branch tip, or the tip is an ancestor of it.
3. **Squash or rebase merge** (checked only when ancestry fails): the branch's combined diff already exists in the default branch:
   ```bash
   base=$(git merge-base <remote>/<default> <branch>)
   probe=$(git commit-tree "<branch>^{tree}" -p "$base" -m probe)
   git cherry <remote>/<default> "$probe"   # a leading "-" means already applied
   ```

An upstream marked `[gone]` is only a hint, never proof of merge.

### 3.2. Summary of the Work

Write one short phrase (at most ~8 words, in the user's session language) saying **what the work is**, not its status. Sources, in order: the PR title, the subjects of the commits unique to the branch, the latest commit subjects, the branch name.

---

## 4. Classify

Evaluate each branch together with the worktree that checks it out: they form one row. Detached-HEAD worktrees and prunable worktree entries get their own rows.

**Keep** when at least one holds, and name the reason:

| Reason | Rule |
| :--- | :--- |
| **Open PR** | An open pull request has this branch as its head. |
| **Recent work** | Last commit within the window (argument, default **14 days**). |
| **Uncommitted changes** | The worktree has staged, unstaged, or untracked files. They cannot be recovered after removal. |
| **Active agent in Herdr** | A Herdr workspace associated with this worktree has `agent_status: "working"`. Removing it would abort an in-flight agent task. |
| **Protected** | Default branch, or the branch/worktree/Herdr workspace (`$HERDR_WORKSPACE_ID`) the calling session is running in. Never removable, even on request. |

**Clean** everything else, split by risk so the user sees what would be lost:

- ✅ **Merged**: the work is in the default branch. Safe.
- ⚠️ **Unmerged**: stale work not in the default branch. Show the count of unique commits and whether they exist on the remote (`pushed` / `local only`).
- 🧹 **Prunable**: a worktree entry whose directory no longer exists.

---

## 5. Present the List

Show both groups with **continuous numbering**, so the user can refer to rows by number. Keep the table compact:

```text
Default branch master: updated 3 commits (fast-forward) ✓

CLEAN (recommended)
 #  Branch                     Worktree                          Last commit  Status              Work
 1  feat/login-sso             —                                 2026-08-02   ✅ merged (#41)     SSO login via Google
 2  fix/date-parse             ../app-date-fix [herdr:wAZ "fix"] 2026-07-19   ✅ merged (squash)  Date parsing in reports
 3  spike/cache-redis          —                                 2026-05-30   ⚠️ 2 commits, local Redis cache experiment
 4  (detached)                 ../app-tmp                        2026-06-11   🧹 prunable          —

KEEP
 #  Branch                     Worktree                          Last commit  Reason              Work
 5  feat/billing-export        ../app-billing [herdr:wAX "bill"] 2026-10-12   active agent        CSV export of invoices
 6  fix/null-avatar            —                                 2026-09-01   open PR #57         Avatar fallback for null
 7  master                     (main)                            2026-10-14   protected           —
```

When a worktree is linked to an open Herdr workspace, annotate the **Worktree** column with its workspace ID and label: `../path [herdr:<id> "<label>"]`.

Then ask the user to approve or edit the list. Accept free-form edits ("clean 5 and 6", "keep 3", "remove only the worktree of 2"):

- Moving a **Keep** row to **Clean** is allowed, except for protected rows. When the moved row has uncommitted changes or unmerged commits, state exactly what will be lost.
- A row can be cleaned partially: worktree only, or branch only (a branch checked out in a worktree requires removing that worktree first).
- After any edit, show the updated **Clean** list and ask again. Proceed only on an explicit approval of the final list.

---

## 6. Execute

Process the approved rows in this order, one command per item, never stopping the whole run on a single failure:

1. **Record recovery data** for every branch before touching it: name and tip SHA.
2. **Worktrees**:
   - **Herdr worktree** (associated with an open Herdr workspace): `herdr worktree remove --workspace <id>`. Add `--force` only for a worktree the user approved knowing it had uncommitted changes. This atomically removes the worktree checkout and closes its Herdr workspace along with any child tabs.
   - **Plain Git worktree**: `git worktree remove <path>`. Use `--force` only for a worktree the user approved knowing it had uncommitted changes.
   - **Prunable entries**: `git worktree prune`.
3. **Branches**: `git branch -d <branch>`. If Git refuses because it does not see the work as merged (squash merges, unmerged rows), use `git branch -D <branch>` only for rows the user approved in that state.

Never run `git reset`, `git clean`, `git push --delete`, or any command on the remote.

---

## 7. Report

- One line per removed item, plus every failure with its reason.
- A **recovery block** for each deleted branch: `git branch <name> <sha>` (valid while the commits are reachable through the reflog, typically 30–90 days). Removed uncommitted changes are not recoverable; say so if any were removed.
- Final state: remaining branches and worktrees, and the default branch position against the remote.

---

## 8. Success Validation

- [ ] The default branch was fetched and fast-forwarded (or the reason it could not be is reported); history was never rewritten.
- [ ] Every local branch and every worktree appeared in exactly one group, with a short work summary.
- [ ] Keep reasons were limited to open PR, recent work, uncommitted changes, active agent in Herdr, or protected; unmerged and dirty items were flagged with what would be lost.
- [ ] Nothing was removed before the user explicitly approved the final list; every edit was reflected and re-confirmed.
- [ ] Protected rows (default branch, calling session's branch, worktree, and Herdr workspace, main worktree) were never removed.
- [ ] Active agents in Herdr (`agent_status: "working"`) were kept unless the user explicitly chose otherwise.
- [ ] Herdr-managed worktrees were removed via `herdr worktree remove --workspace <id>`, avoiding orphaned workspaces or zombie tabs.
- [ ] `--force` and `-D` were used only on rows approved in that state.
- [ ] Nothing on the remote was modified.
- [ ] The report lists every removal, every failure, and a recovery command for each deleted branch.
