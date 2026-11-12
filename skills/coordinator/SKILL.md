---
name: coordinator
description: >-
  Acts as the user's personal assistant across all their work, on demand,
  stateless, and read-only: gathers their tasks from the sources the session
  reaches (code host, issue tracker, team chat, Herdr App, or others the user
  names), shows first what depends on them, then the next focus with its
  reason, the deliveries being built and those waiting for review, and each
  task's state; offers to report or update tasks and suggests a cleanup when
  branches and worktrees pile up. Triggered when the user asks what needs
  them, what to focus on next, how their work is going, to prioritize across
  tasks, or for an overview of everything in flight.
argument-hint: "[focus: a project, a period, or 'priorities'; sources to use or skip]"
---

# Coordinator

The user runs several deliveries at once and cannot read every tab, PR, and thread. When asked, the coordinator reads them for the user and answers three questions: what needs me now, what should I focus on next, and how does each task stand.

## 1. Rules

- **On demand and stateless**: every run derives everything again from the sources, where [a task's facts live](../ai-assisted-software-development/SKILL.md#6-where-a-tasks-facts-live). It keeps no file, registry, or memory of previous runs.
- **Read-only**: it never sends a message, comments, changes a status, answers a dialog, or asks an agent or a person for an update. When something needs another person or agent, it tells the user who and what, and the user acts. Writing happens only through the skill that owns it ([`report-work`](../report-work/SKILL.md), [`git-cleanup`](../git-cleanup/SKILL.md)), after the user says go.
- **It recommends; the user decides** every priority, cut, and postponement. Everything is in the user's session language, each task named in product terms.

## 2. Collect

Use every source the session reaches, plus any the user names; skip the ones the user excludes. Each source is optional: one that cannot be reached is named on the `skipped` line, and nothing from it is guessed.

| Source | What it gives |
| :--- | :--- |
| Code host (GitHub: `gh search prs --author=@me --state=open`, `--review-requested=@me`) | The user's open PRs and the PRs awaiting their review, read per the [PR line](../ai-assisted-software-development/references/change-card.md#4-pr-line). |
| Issue tracker (Jira, GitHub Issues, Linear…) | Issues assigned to the user in progress or next, their status and priority. |
| Team chat (Slack…) | Threads from the last seven days where the user was asked something and has not answered. |
| Herdr App, when active per [`herdr`](../herdr/SKILL.md#1-preconditions) | Live agent sessions, their state, and the worktree each uses. |
| Git, in the repositories the user works in | Branches and worktrees, and which are merged. |

Group everything into tasks: a task is one delivery, joining its issue, its PRs (same branch name across repositories, per [`agentic-parallel-work`](../agentic-parallel-work/SKILL.md)), its threads, and its sessions. What matches no task is shown under its source.

## 3. Judge

- **What depends on the user**: the ⚖️, 👀, and 💪 items of every task's [task state](../tl-dr/references/task-state.md), one per subject, ordered by what each unblocks, decisions to ratify by cost to reverse. At most seven, then "+N more".
- **Next focus**: one task and why, from the three standing questions of [`scope-review`](../scope-review/SKILL.md#three-standing-questions) applied to the open tasks in one line each, with any task worth reducing, postponing, or stopping. On request ("priorities", or a named task), run `scope-review` in full on up to three tasks with a concrete signal: stalled, overlapping another task, or much effort for little impact.
- **In flight**: the deliveries being built against the [limit](../agentic-parallel-work/SKILL.md#5-limits) of `agentic-parallel-work`, and the pile waiting for the user's review, oldest first, with stacked deliveries under the one they build on.
- **Offers**, one line each and only when the signal is present:
  - Work without an issue, or an issue whose status lags its PR (merged, still "in progress"): offer [`report-work`](../report-work/SKILL.md) to report or update those tasks.
  - Branches or worktrees whose PR merged or closed, five or more in a repository, or any older than two weeks: suggest [`git-cleanup`](../git-cleanup/SKILL.md) in that repository.

## 4. Write

The layout is an example; its content is mandatory. A fictional overview:

```text
Your work · Fri 14:20 · 3 depend on you in 2 tasks

1. ⚖️ Export invoices as PDF: decided PDFs deleted after 90 days · hard to reverse: deleted PDFs are gone
2. 👀 Export invoices as PDF: web-app#212 is ready for your review · proven on its current commit
3. 💪 Customer import: the agent in tab "import" stopped at a permission dialog · open that tab

Next focus: Export invoices as PDF · ratifying 1 and reviewing 2 ships it this week; the import waits for a CSV sample from support anyway.
In flight: 2 being built · limit 2–4 · 1 waits for your review (item 2).

<the task state of each task, in the task-state format>

Offers: 🤖 update 2 issues behind their merged PRs (report-work) · 🤖 clean up 6 merged branches and 4 worktrees in web-app (git-cleanup)
skipped: team chat (no access in this session)
```

- **First line, always**: how many items depend on the user and in how many tasks, or `✅ nothing depends on you`.
- Each task follows the [task state](../tl-dr/references/task-state.md) format; with more than four tasks, those with nothing for the user show only their header line.

---

## Success Validation

- [ ] Everything was derived from the sources in this run; nothing was written, sent, answered, or asked of any agent or person, and no state was kept.
- [ ] Unreachable or excluded sources were named on the `skipped` line, with nothing from them guessed.
- [ ] The output opened with what depends on the user, one item per subject, ordered by what it unblocks, at most seven then "+N more".
- [ ] The next focus came with its reason from the `scope-review` questions, deliveries being built were counted against the `agentic-parallel-work` limit, and the waiting pile was shown.
- [ ] Each task followed the task-state format; `report-work` and `git-cleanup` were offered only on their signals and run only after the user's go.
- [ ] Everything was in the user's session language, as recommendations.
