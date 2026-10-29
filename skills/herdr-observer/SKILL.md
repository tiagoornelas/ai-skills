---
name: herdr-observer
description: >-
  Builds, on demand, a highly visual local HTML report of all work in progress
  across Herdr workspaces, written in the user's language and understandable
  at a glance: what needs the user now, what each team is doing, agents and
  their status, pull requests with mergeability, CI, agent-review and
  human-review state, associated tasks or issues in whatever tracker the user
  uses, done, in progress, and next, and what changed since the last refresh.
  Observes passively, asks agents only when a fact cannot be observed, and
  never makes agents report to it. Supports named views filtered to the
  workspaces the user lists. Triggered when the user asks to observe,
  visualize, or refresh the panel of Herdr work.
argument-hint: "[view name] [workspaces to include or exclude]"
---

# Herdr Observer

A passive, on-demand observer. Each run gathers the current state of Herdr work and writes a visual report the user understands at a glance. Agents are never told the observer exists and never send it anything unprompted; the observer's footprint on their flow is at most one consolidated message per agent, and only under the rules of Section 4.

The report serves the user's understanding, so the observer judges what matters the way [`ai-assisted-software-development`](../ai-assisted-software-development/SKILL.md) defines it (Human Layer first) and gives context the way [`explain-it`](../explain-it/SKILL.md) does (business before code, terms defined on first use).

## 1. Preconditions and View

- Require the `herdr` CLI to answer `herdr workspace list`. Use only the local session; never pass `--machine`. Treat the installed CLI as the syntax authority: load `herdr --skill` unless already in context.
- A **view** is a name plus a workspace filter, stored at `~/.herdr-teams/observer/<view>/` (`index.html` for the user, `state.json` as the observer's own memory):
  - No filter and no name: view `all`, every workspace.
  - The user lists workspaces to include or exclude (by label or ID): apply exactly that filter. Never infer, classify, or extend it. If the user gave no name for a filtered view, ask for one short name once.
  - "Refresh" (or a view name alone): reuse the filter stored in that view's `state.json`. Without a view name and with several views on disk, ask which one.
- Read the previous `state.json` of the view, if any.

## 2. Observe

Gather cheap, authoritative sources first; reach for expensive ones only to fill gaps. When the harness supports subagents and there are several workspaces, gather one workspace per subagent in parallel, passing this section verbatim.

| Fact | Source |
| :--- | :--- |
| Workspaces, tabs, agents, harness, status, directory | `herdr api snapshot` (one call) |
| Team intent: objective, Leader, members' missions, next steps, pending decisions, task references | `leader.md` and `handoff-*.md` in the team folder ([team-folder.md](../herdr-team-lead/references/team-folder.md)) |
| Repository, branch, worktree per agent | `git -C <agent cwd>` (`rev-parse --show-toplevel`, `branch --show-current`, `remote get-url`) |
| PRs per branch: number, title, body, state, mergeability, CI | `gh pr list --head <branch> --state all --json number,title,body,url,state,isDraft,mergeable,statusCheckRollup,headRefOid` |
| Review by the agent | a `self-review` git note on the PR head, or on an ancestor after the merge-base |
| Review by the user, and its recommendation | `git notes --ref=human-review show <PR head>` |
| What an agent is doing, only when intent is missing | `herdr agent read <agent> --source recent --lines 40` |

**Tasks and issues, tool-agnostic.** Start from references declared in `leader.md`. Without them, infer keys and URLs from branch names, PR titles and bodies, commit subjects, and the repository's `AGENTS.md` or contribution docs. Determine where the user tracks work from those references and from the tools the harness can reach (CLIs such as `gh`, or connected integrations), then read each task's current status there and look for cross-references between trackers (a ticket cited in an issue, an issue linked from a PR). A task whose tool cannot be reached is shown with its reference and no status, never with a guessed one.

Do not parse agents' session transcripts. Never copy secrets or credentials from terminal output into the report.

Compare declared intent with observed reality (for example, `leader.md` lists a member that no longer exists, or a next step whose PR already merged) and note each divergence.

## 3. Write the Report

1. Write `index.html` following [panel-guide.md](references/panel-guide.md): the user's language end to end, system terms instead of handles, a "Needs you now" block first, then the team list beside the focused team, styled with [`resources/panel.css`](resources/panel.css).
2. Write `state.json` as the observer's private memory for the next run: the view's filter and refresh time, a short summary of each workspace (teams, agents and statuses, PRs and their states, task statuses), and the keys of divergences already notified. Its shape is the observer's own choice; nothing else reads it.
3. Compare with the previous `state.json` to write the "Since last refresh" lines.
4. On a view's first report, open `index.html` in the default browser (`open` on macOS, `xdg-open` on Linux); afterwards, tell the user to reload it.

## 4. Ask and Notify

The observer only contacts agents through [`herdr-talk`](../herdr-talk/SKILL.md), and only when all of these hold:

- **Ask** only for a fact that cannot be observed and that the report needs (for example, the next step of a team with no `leader.md` and no readable terminal context). Ask the team's Leader when there is one, otherwise the member concerned.
- **Notify** a Leader of divergences between `leader.md` and observed reality not notified before. No reply is requested; record the divergence in `state.json` so it is never sent again.
- Contact only agents whose status is `idle`; never interrupt `working` or `blocked` agents. Send at most one consolidated message per agent per refresh.
- In an Ask, the reply rule asks for one reply to that message only and states that no further updates should be sent.

Never instruct any agent to report to the observer, to update anything on a schedule, or to remember the observer. If an Ask is pending when the report is due, write it with the gap stated plainly and update when the reply arrives.

## 5. Report in the Conversation

Tell the user, per [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md), the report path and the "Needs you now" items, plus any agent contacted and why. The HTML holds the rest.

## 6. Success Validation

- [ ] Herdr CLI answered; the view's name and filter came from the user or its stored `state.json`, never from inference.
- [ ] Facts came from cheap sources first; terminal output was read only to fill gaps; no session transcript was parsed.
- [ ] The report is entirely in the user's language, names things by what they are, and passes the cold-read test of the panel guide.
- [ ] "Needs you now" lists every decision, block, pending user review, and PR ready to merge; Human Layer items lead each team.
- [ ] Status uses the guide's emoji-and-word chips; only inferred facts are marked; tasks show real tracker status or none.
- [ ] The HTML is self-contained, uses `panel.css` verbatim, and escapes text taken from PRs, tasks, or terminals.
- [ ] Agents were contacted only under Section 4: idle only, one consolidated message each, no repeated divergence notices, no instruction to report back.
