---
name: herdr-leader-report
description: >-
  Reports, on demand, the state of the work in the current Herdr workspace in
  a fixed, visual terminal format: a Panel with what needs the user's
  decision, what is blocked, what is in progress, and the next steps, then
  every tab, every task, and every pull request with its state. The Panel
  format is also the one the Leader repeats in every message about the work. Gathered
  by observing Herdr, git, pull requests, review notes, and the task tracker
  the team uses, asking members only for what cannot be observed. Meant to be
  run by the workspace's Leader; works in any workspace, with or without a
  team folder. Triggered strictly when the user asks for the report.
disable-model-invocation: true
argument-hint: "[focus, e.g. a task or PR, optional]"
---

# Herdr Leader Report

A command the user gives to a workspace's Leader: "tell me where this work stands". It produces one report about **this workspace only**, always in the same structure ([report-format.md](references/report-format.md)), so the user can scan any team the same way. Its first section, the **Panel**, is the canonical state of the work that the Leader also repeats in every message about it. The report is pulled by the user; nobody pushes status to anyone.

## 1. Preconditions

- Require `HERDR_ENV=1`. Otherwise report that the session is outside Herdr and stop. Use only the local session; never pass `--machine`.
- Treat the installed CLI as the syntax authority: load `herdr --skill` unless already in context, and parse state from JSON responses.
- The scope is `$HERDR_WORKSPACE_ID`. Read its team folder per [team-folder.md](../herdr-team-lead/references/team-folder.md) when it exists; without it, infer the objective and next steps and mark them as inferred.

## 2. Gather

Observe first, cheapest sources first; in a large workspace, gather in parallel with subagents when the harness supports them, passing this section verbatim.

| Fact | Source |
| :--- | :--- |
| Tabs, agents, harness, status, directory | `herdr tab list --workspace <id>` and `herdr agent list` |
| Objective, members' missions, next steps, pending decisions, task references | `leader.md` and `handoff-*.md` |
| What an agent did or is waiting for | `herdr agent read <agent> --source recent-unwrapped --lines 40` |
| Repository and branch per agent | `git -C <agent cwd>` (`rev-parse --show-toplevel`, `branch --show-current`, `remote get-url`) |
| PRs per branch, and the PRs they depend on | `gh pr list --head <branch> --state all --json number,title,body,url,state,isDraft,mergeable,statusCheckRollup,headRefOid`; dependencies stated in PR bodies |
| Reviewed by the agent | a `self-review` git note on the PR head, or on an ancestor after the merge-base |
| The user's review and its recommendation | `git notes --ref=human-review show <PR head>` |

**Tasks, tool-agnostic.** Start from the references in `leader.md`. Without them, take keys and links from PR bodies, branch names, and commit subjects. Read each task's current status, and its siblings under the same epic, from whatever tracker those references point to, through the tools the harness can reach (a CLI such as `gh`, or a connected integration). A task whose tracker cannot be reached is listed with its reference and no status, never a guessed one. Record which tabs and PRs have no task reference: the report shows untracked work explicitly.

Do not parse session transcripts. Never copy secrets or credentials from terminal output into the report.

**Asking members.** Only when a fact the report needs cannot be observed, ask through [`herdr-talk`](../herdr-talk/SKILL.md): only `idle` members, one consolidated question each, with a reply rule for a single answer. Never interrupt a `working` or `blocked` member; report the gap instead.

## 3. Write the Report

Write the report in the conversation following [report-format.md](references/report-format.md). Judge what matters per [`ai-assisted-software-development`](../ai-assisted-software-development/SKILL.md) and give context per [`explain-it`](../explain-it/SKILL.md). When the user named a focus, keep all four sections and the four Panel blocks, and expand the focused item.

If the report shows `leader.md` diverging from reality and the Leader is running it, update `leader.md` per [`herdr-team-lead`](../herdr-team-lead/SKILL.md) after the report and say so in its closing remarks.

## 4. Success Validation

- [ ] Herdr environment verified; the report covers only the current workspace.
- [ ] Facts came from observation first; members were asked only for unobservable facts, only when idle, once each.
- [ ] The report has the four sections in order, in the user's language, using the status vocabulary of the format.
- [ ] The Panel has its four blocks in order (needs you, blocked, in progress, next steps), none omitted; empty ones say so in one line.
- [ ] "Needs you" lists, numbered, every decision, review the user owes, and scheduled action that needs the user, each with a recommendation; blocks not caused by the user appear only under "Blocked".
- [ ] Every task shows its real tracker status or none, and its actual next step; every PR shows mergeability, CI, and both review signals.
- [ ] Untracked work is visible: tabs and PRs without a task are listed as such, or the report states that no task is registered.
- [ ] Only inferred facts are marked; a missing review note reads "no record".
