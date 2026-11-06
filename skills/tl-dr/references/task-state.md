# Task State

> **Central thesis**: one task reads in about ten lines, in the order the user acts on it: first whether anything depends on them, then the issue, the PRs, and the conversations around it. Every line is derived from its source when asked, never kept anywhere. Skills that show a task ([`tl-dr`](../SKILL.md), [`coordinator`](../../coordinator/SKILL.md)) use this format.

---

## When to consult

- Showing the state of one task, or of each task in an overview.

---

## 1. Sources

A task is one delivery: its issue, its PRs (one per repository, the same branch name, per [`agentic-parallel-work`](../../agentic-parallel-work/references/branch-and-worktrees.md)), the threads about it, and the agent sessions working on it. Read each where [its facts live](../../ai-assisted-software-development/SKILL.md#6-where-a-tasks-facts-live):

| Line | Read from |
| :--- | :--- |
| Issue | The tracker the repository or context points to (key in the branch, commits, or PR): status, and the acceptance criteria met when the PR or issue says so. |
| PRs | The code host (`gh pr view`, `gh pr checks`) and the evidence notes on each PR head, written as the [PR line](../../ai-assisted-software-development/references/change-card.md#5-pr-line). |
| Plan | The count line of the change card in the main PR's body, copied as it is. |
| Threads | Unresolved review threads of each PR; chat or tracker threads the issue or PR links, or the user names. |
| Agent sessions | When the Herdr App is active, the terminals using the task's worktrees and their state, per [`herdr`](../../herdr/SKILL.md#2-read-the-state). |

Every source is optional. One the session cannot reach becomes a closing `skipped` line saying which and why; nothing from it is guessed.

## 2. Lines

In the user's session language; the plan symbols and the PR line's fields stay as they are.

1. **Header**: the task in product terms, then whether anything depends on the user: `❓ N depend on you`, plus each notice and its deadline, or `✅ nothing depends on you`.
2. **What depends on the user**, one line each, marked per the [emoji vocabulary](../../ai-assisted-software-development/references/human-facing-communication.md#4-emojis-as-signals): ❓ a decision still open (a `?` line of the card, a question to the user in the issue or a thread), with its options, the recommendation, and whether it blocks merge, as the card's [`?` lines](../../ai-assisted-software-development/references/change-card.md#2-the-plan) carry them · 👀 a PR whose line reads `you pending`, or a review requested from the user · ✋ an agent stopped at a dialog, with the tab to open · ⚠️ a notice that proceeds at a deadline unless the user objects.
3. **Issue**: key · status · acceptance criteria met, when known. One line per issue.
4. **Plan**: the change card's count line, when the main PR has a card.
5. **PRs**: one [PR line](../../ai-assisted-software-development/references/change-card.md#5-pr-line) each.
6. **Threads**: where · what is open, in one phrase · whose move (yours, the author's, a reviewer's). Resolved threads are only counted.
7. **Closing**: `next` (the agent's next step, 🤖, or ⏸️ with what it waits for) and `skipped`, each only when it has content.

Lines with nothing to say are left out. Past about ten lines, group the rest ("+3 resolved threads"). A line not read from a source is marked *(inferred)*; a missing note reads `—`, never "not reviewed".

## 3. Example

A fictional task across three repositories:

```text
Export invoices as PDF · ❓ 2 depend on you · 1 notice Fri 12:00
❓ delete PDFs after 90 days, or keep them forever? · blocks merge · I recommend 90 days
👀 web-app#212 is ready for your review · proven on its current commit
⚠️ bucket storage, about $4 a month · goes ahead Fri 12:00 unless you object
issue   BILL-142 · in progress · 3 of 4 acceptance criteria met
Plan: 9 +  2 ~  0 -  2 ?  1 !  2 draft PRs, 1 awaiting your review
⏳ billing-api#88 · invoice PDF export · draft · CI ok · agent ok · proof — · you —
👀 web-app#212 · download PDF button · CI ok · agent ok · proof ok · you pending
⏳ infra#41 · invoice PDF bucket · draft · CI running · agent — · proof — · you —
thread  web-app#212 review · layout of the PDF header · author's move
thread  team chat · support asked when PDFs ship · your move
next    🤖 billing-api#88 runs its proof once infra#41 is green
```

## 4. Success Validation

- [ ] The header said whether anything depends on the user, and those items came first, each with its mark and what it unblocks.
- [ ] Issues, the plan count line, PR lines, and open threads followed, each read from its source when asked, PRs exactly in the PR line format.
- [ ] No line was guessed: inferences were marked, missing notes read `—`, unreachable sources were named on the `skipped` line.
- [ ] The state fit in about ten lines, in the user's language, with empty lines left out.
