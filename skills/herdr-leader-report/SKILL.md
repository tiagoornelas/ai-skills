---
name: herdr-leader-report
description: >-
  Reports, on demand, the state of the work in the current Herdr App space in
  a fixed, glanceable terminal format, in the user's language: a Panel whose
  first line says what depends on the user, then one numbered queue of what's
  next with the user's items first, what is blocked on something nobody can do
  now, what is in progress, and a one-line state per pull request with what it
  adds to the system; then what changed and what appeared in the system since
  the user's last message, and one line per delivery with its evidence. The
  Panel format is also the one the Leader shows whenever something changes for
  the user. Gathered
  by observing the Herdr App, git, pull requests, review notes, and the task tracker
  the team uses, asking members only for what cannot be observed. Meant to be
  run by the space's Leader; works in any space, with or without a team
  folder. Built for the Herdr App (herdr-app + hc), not the Herdr terminal
  multiplexer (`herdr` CLI). Triggered strictly when the user asks for the
  report.
disable-model-invocation: true
argument-hint: "[focus, e.g. a task or PR, optional]"
---

# Herdr Leader Report

A command the user gives to a space's Leader: "tell me where this work stands". It produces one report about **this space only**, always in the same structure ([report-format.md](references/report-format.md)), so the user can scan any team the same way. Its first section, the **Panel**, is the canonical state of the work that the Leader also shows whenever something changes for the user; the rest says what changed and what appeared in the system since the user's last message, and where each delivery stands with its evidence, without repeating the Panel. The report is pulled by the user; nobody pushes status to anyone.

> **Herdr App only.** This skill reads the Herdr App: `herdr-app` (window: spaces, tabs, panes) and `hc` (herdr-core: terminals and agents). It never uses the `herdr` CLI of the Herdr terminal multiplexer, which talks to a different session.

## 1. Preconditions

- Require `HC_TERMINAL_ID` to be set and both `hc` and `herdr-app` on `PATH`. Otherwise report that the session is outside the Herdr App and stop. Use only this machine; never pass `--on` or `--machine`.
- Treat the installed CLIs as the syntax authority: load `hc --skill` and `herdr-app --skill` unless already in context, and parse state from JSON responses.
- The scope is this terminal's space: the `herdr.space` label in `hc get "$HC_TERMINAL_ID"`. Read its team folder per [team-folder.md](../herdr-team-lead/references/team-folder.md) when it exists; without it, infer the objective and next steps and mark them as inferred.

## 2. Gather

Observe first, cheapest sources first; in a large space, gather in parallel with subagents when the harness supports them, passing this section verbatim.

| Fact | Source |
| :--- | :--- |
| Tabs, agents, harness, status, directory | `herdr-app ls` (that space: tabs in order, terminals, status) and `hc get <terminal>` (`foreground.argv`, `foreground.cwd`) |
| Objective, members' missions, next steps, pending decisions, task references | `leader.md` and `handoff-*.md` |
| What an agent did or is waiting for | `hc read <terminal> --lines 40` |
| Repository and branch per agent | `git -C <agent cwd>` (`rev-parse --show-toplevel`, `branch --show-current`, `remote get-url`) |
| PRs per branch, and the PRs they depend on | `gh pr list --head <branch> --state all --json number,title,body,url,state,isDraft,mergeable,statusCheckRollup,headRefOid`; dependencies stated in PR bodies |
| Reviewed by the agent | a `self-review` git note on the PR head, or on an ancestor after the merge-base |
| The user's review and its recommendation | `git notes --ref=human-review show <PR head>` |
| What a PR adds to the system (component, permission or secret, business rule, cost) | the PR body and diff (new jobs, schedules, migrations, routes, secrets, IAM, infrastructure files), checked against the notices and approvals in `leader.md` |
| Evidence of each delivery | `git notes --ref=evidence show <PR head>` ([evidence dossier](../ai-assisted-software-development/references/evidence-dossier.md#2-the-independent-reviewer)); a note only on an older commit of the branch counts as outdated, and no note reads `—` (no record) |
| What changed since the user's last message | this conversation from the user's previous message on, `leader.md` Decisions & Rationale, and PRs opened or merged in that window |

**Tasks, tool-agnostic.** Start from the references in `leader.md`. Without them, take keys and links from PR bodies, branch names, and commit subjects. Read each task's current status, and its siblings under the same epic, from whatever tracker those references point to, through the tools the harness can reach (a CLI such as `gh`, or a connected integration). A task whose tracker cannot be reached is listed with its reference and no status, never a guessed one. Record which tabs and PRs have no task reference: the report shows untracked work explicitly.

Do not parse session transcripts. Never copy secrets or credentials from terminal output into the report.

**Asking members.** Only when a fact the report needs cannot be observed, ask through [`herdr-talk`](../herdr-talk/SKILL.md): only `idle` members, one consolidated question each, with a reply rule for a single answer. Never interrupt a `working` or `blocked` member; report the gap instead.

## 3. Write the Report

Write the report in the conversation following [report-format.md](references/report-format.md). Judge what matters per [`ai-assisted-software-development`](../ai-assisted-software-development/SKILL.md) and give context per [Briefing a Change](../ai-assisted-software-development/references/human-facing-communication.md#3-briefing-a-change). When the user named a focus, keep the Panel and every block, and expand only the focused delivery beyond its detail line.

If the report shows `leader.md` diverging from reality and the Leader is running it, update `leader.md` per [`herdr-team-lead`](../herdr-team-lead/SKILL.md) after the report and say so in its closing remarks.

## 4. Success Validation

- [ ] Herdr App environment verified, without the `herdr` terminal CLI; the report covers only the current space.
- [ ] Facts came from observation first; members were asked only for unobservable facts, only when idle, once each.
- [ ] The report is the Panel followed by What changed since your last message and Deliveries, entirely in the user's language (fixed template words included), one line per item with at most one detail line, and no tab list, counts table, or wide tables.
- [ ] What changed counts from the user's previous message, at most eight lines, and lists every component, permission or secret, business rule, or cost that appeared in that window; anything that appeared without a prior notice or approval is marked ⚠️.
- [ ] Every delivery shows its task status or "no task", its PR, and how many of its five evidence lines are proven, with any "no" named on its detail line.
- [ ] The Panel opens with the line saying how many items depend on the user and which, or that none does; then shows its non-empty blocks in order (what's next, blocked, in progress, PRs); empty blocks are omitted and named together in one plain closing line without emoji.
- [ ] "What's next" is one numbered queue: every decision, review the user owes, action only the user can take (with why only the user can), and tier-2 notice (with its deadline) comes first, in bold, each with a recommendation; the agents' steps follow, marked 🤖, and no item appears twice.
- [ ] "Blocked" holds only work that neither the user nor any agent can move now (a time to pass, logs to settle, another team or a third party); work waiting for the user is in "What's next", and work waiting for the team is "In progress".
- [ ] Every PR uses the same PR line (repository#number, short name, draft and conflict when true, CI, agent review, the user's review), followed by its what-appears line when it adds something to the system.
- [ ] Untracked work is visible: deliveries without a task say so, or the report states that no task is registered.
- [ ] Only inferred facts are marked; a missing review note reads "no record".
