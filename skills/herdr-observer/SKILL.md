---
name: herdr-observer
description: >-
  Builds, on demand, a local HTML panel showing all work in progress across
  Herdr workspaces: teams, agents and their status, pull requests with
  mergeability, CI, agent-review and human-review state, associated tasks or
  issues in whatever tracker the user uses, what is done, in progress, and
  next, pending decisions, and what changed since the last refresh. Observes
  passively, asks agents only when a fact cannot be observed, and never makes
  agents report to it. Supports named views filtered to the workspaces the
  user lists. Triggered when the user asks to observe, visualize, or refresh
  the panel of Herdr work.
argument-hint: "[view name] [workspaces to include or exclude]"
---

# Herdr Observer

A passive, on-demand observer. Each run gathers the current state of Herdr work, writes a view's `state.json`, and renders it into a fixed local HTML panel. Agents are never told the observer exists and never send it anything unprompted; the observer's footprint on their flow is at most one consolidated message per agent, and only under the rules of Section 4.

## 1. Preconditions and View

- Require the `herdr` CLI to answer `herdr workspace list`. Use only the local session; never pass `--machine`. Treat the installed CLI as the syntax authority: load `herdr --skill` unless already in context.
- A **view** is a name plus a workspace filter, stored at `~/.herdr-teams/observer/<view>/` (`state.json` and `index.html`):
  - No filter and no name: view `todos`, every workspace.
  - The user lists workspaces to include or exclude (by label or ID): apply exactly that filter. Never infer, classify, or extend it. If the user gave no name for a filtered view, ask for one short name once.
  - "Refresh" (or a view name alone): reuse the filter stored in that view's `state.json`. Without a view name and with several views on disk, ask which one.
- Read the previous `state.json` of the view, if any: it feeds "what changed" and divergence deduplication.

## 2. Observe

Gather cheap, authoritative sources first; reach for expensive ones only to fill gaps. When the harness supports subagents and there are several workspaces, gather one workspace per subagent in parallel, passing this section verbatim.

| Fact | Source |
| :--- | :--- |
| Workspaces, tabs, agents, harness, status, directory | `herdr api snapshot` (one call) |
| Team intent: objective, Leader, members' missions, next steps, pending decisions, task references | `leader.md` and `handoff-*.md` in the team folder ([team-folder.md](../herdr-team-lead/references/team-folder.md)) |
| Repository, branch, worktree per agent | `git -C <agent cwd>` (`rev-parse --show-toplevel`, `branch --show-current`, `remote get-url`) |
| PRs per branch: number, title, state, mergeability, CI | `gh pr list --head <branch> --state all --json number,title,url,state,isDraft,mergeable,statusCheckRollup,headRefOid` |
| agent-review | `git notes --ref=self-review` on the PR head or its ancestors after the merge-base |
| human-review and its recommendation | `git notes --ref=human-review show <PR head>` |
| What an agent is doing, only when intent is missing | `herdr agent read <agent> --source recent --lines 40` |

**Tasks and issues, tool-agnostic.** Start from references declared in `leader.md`. Without them, infer keys and URLs from branch names, PR titles and bodies, commit subjects, and the repository's `AGENTS.md` or contribution docs. Determine where the user tracks work from those references and from the tools the harness can reach (CLIs such as `gh`, or connected integrations), then read each task's current status there and look for cross-references between trackers (a ticket cited in an issue, an issue linked from a PR). A task whose tool cannot be reached is shown with its reference and no status, never with a guessed one.

Do not parse agents' session transcripts. Respect privacy: never copy secrets or credentials from terminal output into the panel.

Build `state.json` per [panel-data.md](references/panel-data.md), tagging every non-raw fact as `observed`, `declared`, or `inferred`. Compare declared intent with observed reality (for example, `leader.md` lists a member that no longer exists, or a next step whose PR already merged) and record each mismatch in `divergences` with a stable key.

## 3. Render

1. `mkdir -p ~/.herdr-teams/observer/<view>` and write `state.json` there.
2. Run `python3 <this skill's directory>/scripts/render.py <state.json> <index.html>`.
3. On a view's first render, open `index.html` in the default browser (`open` on macOS, `xdg-open` on Linux); afterwards, tell the user to reload it.

The panel lists teams with attention signals (decisions, blocks, divergences) beside the detail of the selected team: its agents, done / now / next columns, PRs with their review state, and tasks. Workspaces without team activity sit in a compact section; concluded teams are collapsed. The overview is the product; "what changed" is a secondary line.

## 4. Ask and Notify

The observer only contacts agents through [`herdr-talk`](../herdr-talk/SKILL.md), and only when all of these hold:

- **Ask** only for a fact that cannot be observed and that the panel needs (for example, the next step of a team with no `leader.md` and no readable terminal context). Ask the team's Leader when there is one, otherwise the member concerned.
- **Notify** a Leader of divergences between `leader.md` and observed reality whose keys were not notified before. No reply is requested; record `notified_at` so the same divergence is never sent again.
- Contact only agents whose status is `idle`; never interrupt `working` or `blocked` agents. Send at most one consolidated message per agent per refresh.
- In an Ask, the reply rule asks for one reply to that message only and states that no further updates should be sent.

Never instruct any agent to report to the observer, to update anything on a schedule, or to remember the observer. If an Ask is pending when the panel is due, render with the gap marked and update when the reply arrives.

## 5. Report

Tell the user, per [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md), the panel path and only what needs attention: pending decisions, blocked agents, PRs ready to merge, divergences notified, and any agent contacted and why. The panel holds the rest.

## 6. Success Validation

- [ ] Herdr CLI answered; the view's name and filter came from the user or its stored `state.json`, never from inference.
- [ ] Facts came from cheap sources first; terminal output was read only to fill gaps; no session transcript was parsed.
- [ ] Every non-raw fact carries its provenance; tasks show real tracker status or none.
- [ ] `state.json` follows `panel-data.md` and `index.html` was rendered by `scripts/render.py`.
- [ ] Agents were contacted only under Section 4: idle only, one consolidated message each, no repeated divergence notices, no instruction to report back.
- [ ] The user received the panel path and the attention points in system terms.
