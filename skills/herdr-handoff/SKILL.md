---
name: herdr-handoff
description: >-
  Hands off the active conversation to new agent sessions in the Herdr App,
  organized as teams: new work becomes a space led by a Leader tab, with tab
  agents in further tabs. Adopts an existing space as a team when needed, gives
  each code-writing agent its own Git worktree by default, writes handoff files
  to the team folder, and starts each agent from its file. Built for the Herdr
  App (herdr-app + hc), not the Herdr terminal multiplexer (`herdr` CLI).
  Triggered strictly upon explicit user request while running inside the Herdr
  App, including the user's approval of a split proposed by a Leader, and by
  any team tab (Leader or tab agent) starting a sub-agent within its approved
  mission.
disable-model-invocation: true
argument-hint: "[streams, layout, space, and harness for each agent]"
---

# Herdr Handoff

Forks the current work into agent sessions while leaving the calling terminal's work untouched. The Herdr App owns the layout (`herdr-app`); herdr-core runs the agents (`hc`); Git owns new worktrees. A stream is one agent with one mission. A space is a team working on one cohesive piece of work, led by the agent in its `Leader` tab running [`herdr-team-lead`](../herdr-team-lead/SKILL.md); its durable files live in the team folder ([team-folder.md](../herdr-team-lead/references/team-folder.md)).

> **Herdr App only.** This skill drives the Herdr App: `herdr-app` (window: spaces, tabs, panes) and `hc` (herdr-core: terminals and agents). It never uses the `herdr` CLI of the Herdr terminal multiplexer, which talks to a different session.

## 1. Preconditions and Plan

- Require `HC_TERMINAL_ID` to be set and both `hc` and `herdr-app` on `PATH`. Otherwise report that the session is outside the Herdr App and stop. Use only this machine; never pass `--on` or `--machine`.
- Treat the installed CLIs as the syntax authority: load `hc --skill` and `herdr-app --skill` unless already in context, and confirm argument names with `herdr-app commands` and `hc <command> --help`. Parse IDs from JSON responses.
- Find the calling space and tab from `hc get "$HC_TERMINAL_ID"`: labels `herdr.space` and `herdr.tab`. Read names and layout with `herdr-app ls`.
- An explicit layout from the user (named space, tab, or split) wins over the defaults below. Split a tab into panes only when requested. Different agents may use different checkouts.
- Resolve the team layout from where the handoff runs. Inside a space, the default is a tab agent of that space's team: work stays in the team it came from, and a new team is an explicit choice.

  | Situation | Layout |
  | :--- | :--- |
  | The work does not continue the calling space's work (it is unrelated to its team's objective, or the caller sits in a general-purpose space), or the user asks for a new team | Create a space named for the work. Its first tab, named `Leader`, runs a new Leader with `herdr-team-lead` as lead skill, even for a single stream. When the split is already clear in the conversation, also create one tab per stream; otherwise create only the Leader, which proposes the split. |
  | The streams join a space that has a `leader.md` | The team exists: add each stream as a tab agent. |
  | The streams join the caller's own space, which has no `leader.md` | Adopt it: the caller is coordinating, so it becomes the Leader (Section 1.1), then add the tab agents. |
  | The streams join a space without `leader.md`, and another tab seems to be coordinating it | Ask the user which tab leads, then adopt with that tab as Leader. |

- Use a named space when requested: match its name in `herdr-app ls`, create it once if absent, and ask only if several match.
- Use the calling harness's command from `hc get "$HC_TERMINAL_ID"` (`foreground.argv[0]`, for example `claude`) unless the user names another. Wrap with `env TERM=xterm-256color` when launching via `hc run` so that terminal tools (such as `agy`) detect color support instead of falling back to monochrome under herdr-core's default `TERM=dumb`. Codex must run with `--no-daemon`. Pass other native flags only when explicitly requested.
- Choose each stream's kind from the work it will do, before it starts; the user may override it:

  | Work | Kind | Shape |
  | :--- | :--- | :--- |
  | Writes code in its own worktree, or is responsible for a delivery in a pull request | **Tab agent** ("tab" for short) | Own tab in the space, its own handoff file, started with `--no-parent --outlive-parent`; lives until the user ends it; tab agents are kept terminals that can be resumed after a restart |
  | Writes no code: a review, an investigation, a check, running commands and tests, ending in one report | **Sub-agent** | Child of the team tab that creates it, in a tab of its own named `↳ <name>` so it counts in the space, brief in its start prompt or a file, ended and removed by its creator once its report is in (removing it closes its tab); sub-agents end with their creator and are not kept |
  | An investigation that turns into code | The sub-agent reports to its creator and is removed; the code goes to a **tab agent** per Section 3.1 | — |

  The kind never depends on a guess at how long the work will take. A sub-agent never writes code. A Leader writes no code, yet takes the tab agent's shape (own tab, no parent, outlives its creator) because it coordinates the space. Only the Leader creates tab agents, and only after the user approves; a tab agent that needs another code stream mid-work asks its Leader, who brings it to the user. Any team tab may create sub-agents under Section 3.1.
- Give each stream a specific mission. Record a lead skill and arguments when the mission calls for one. Choose short, semantic names in the user's language for created spaces and tabs; use a unique terminal-name slug (`[a-z0-9_-]{1,32}`, unique among live terminals in `hc ls`) for each agent.
- Resolve operational details from the request and context without approval. Ask only for essential missing information, conflicting instructions, or a requested preview. If showing a plan, use a Unicode box-drawing diagram that marks the calling space and tab as unchanged and identifies every new resource.

### 1.1. Adopt a Space

- If the agent becoming Leader is itself writing code in that space, ask the user before adopting: a Leader does not write code.
- Rename the Leader's tab to `Leader` with `herdr-app do tab.rename --id <tab> --name Leader` and move it first with `herdr-app do tab.move --id <tab> --index 1`.
- Write `leader.md` in the team folder, in the format of [team-folder.md](../herdr-team-lead/references/team-folder.md), from what the conversation and the space show; mark inferences as ❓.
- When the caller becomes Leader, read `herdr-team-lead` and continue under it after this handoff. When another tab becomes Leader, tell it through [`herdr-talk`](../herdr-talk/SKILL.md) (Notify) to read `herdr-team-lead` at its absolute path and its `leader.md`.

## 2. Prepare Checkouts

For **each new agent that will write code**, create a separate Git worktree, even if it is the only writer. Read-only streams, including a Leader, use their requested directory or the calling directory. If the user explicitly requests an existing worktree, use it; warn when another agent is already writing there.

- Find the main worktree with `git worktree list --porcelain`. Put new worktrees in sibling directories named for the repository and work; choose an unused path and branch rather than silently reusing one.
- Follow the branch naming and base-selection rules in [`git-branch`](../git-branch/SKILL.md), **not** its checkout-changing execution workflow. For independent work, resolve the default branch, fetch its remote, and use the updated remote-tracking ref as the base; use a different base for an explicit dependency. If the repository has no remote, use its local default branch. Never switch the calling checkout.
- Create with `git worktree add -b <branch> <path> <base-ref>`. If mandatory project instructions prescribe another creation procedure, follow them. Never use the Herdr App's own worktree feature (the `worktree` mod behind "New worktree"): it turns each checkout into a separate space nested under its repository, which breaks a space organized around one piece of work that spans several repositories.
- If checkout preparation fails, report the affected stream and continue independent streams. If a later Herdr App step fails, keep any created Git worktree and report its path and branch so the user can resume or clean it later.

## 3. Write and Start Each Stream

Read [`../handoff/SKILL.md`](../handoff/SKILL.md) and apply its **Document Content** and **Write and Deliver** sections, except that files go to the team folder `~/.herdr-teams/<space-id>/` instead of the temporary directory. Write one handoff file per tab agent, named `handoff-<agent-name>.md`, with that stream's mission as its Next Session Goal; a new Leader's handoff is that team's `leader.md`, in the format of [team-folder.md](../herdr-team-lead/references/team-folder.md). For a worktree stream, set Source to its actual worktree path and branch.

Every tab agent's handoff names its Leader's address and states the **tab agent contract**; list `herdr-talk` in its Recommended Skills, and list `herdr-handoff` with the note that it applies only to starting sub-agents (Section 3.1), since only the Leader creates tab agents. A Leader's handoff lists `herdr-team-lead` as its lead skill. The tab agent contract:

- **The Leader owns the space's state.** Decisions, blockers, and deliveries go to the Leader through `herdr-talk`, never as a report to the user.
- **Announce before building.** Anything that would start to run, cost, store data, or hold permissions in production and was not in the approved split goes to the Leader before it is built, for the Leader to classify with [the boundary test](../ai-assisted-software-development/SKILL.md#4-the-boundary-test); a business rule or anything that deletes or rewrites production data is always a decision for the user.
- **The user may talk to any tab.** When the user decides something or acts in the tab agent's tab, the tab agent notifies the Leader at once (`herdr-talk` Notify: "the user decided X in this tab"), so the Leader never asks for it again.
- **Write for the user only where the user writes.** In its own tab, the tab agent addresses the user only after the user has written there; otherwise its reports go to the Leader.
- **Deliver with evidence.** A delivery to the Leader carries its [change card](../ai-assisted-software-development/references/change-card.md) (every new thing with where it lives, rules, data, pattern, walls), the author lines of the [evidence dossier](../provide-evidence/references/evidence-dossier.md) ((a) why, (b) architecture, listing every new structure: folder, module, client, configuration variable, cross-cutting mechanism), each with its [claim, why it convinces, and proof](../provide-evidence/references/evidence-dossier.md#every-line-convinces-claim-why-proof), and the `agent-self-review` verdict; the Leader verifies it with `provide-evidence` for lines (c)–(f).

Every code-writing stream's Recommended Skills always lists the delivery workflow, whatever the mission: `coding` for code changes, `agent-self-review` before delivery, `commit` for every commit, `github-pull-request` for opening a pull request, and `git-branch` with the note that the stream's branch already exists and the skill applies only to any additional branch. This keeps branches, commits, and pull requests from new agents within the standard.

**Start prompt.** Each agent's first message tells it to read its handoff file. If it has a lead skill, prefix the prompt with that skill's command when its harness supports it; otherwise use a plain prompt with the handoff path. Put this prompt in the start command itself: a message sent to a booting agent can be dropped.

**Start each tab agent** with `hc run`, which makes its terminal visible as a new tab of the space through the `herdr.space` label:

```bash
hc run --bg --json --name <agent-name> --cwd <dir> --outlive-parent --no-parent \
  --label herdr.space=<space-id> env TERM=xterm-256color <command> "<start prompt>"
```

- `--outlive-parent` is mandatory: without it, the agent ends when the agent that started it ends.
- `--no-parent` is mandatory for tab agents and Leaders alike. The app's Agents sidebar nests every live child under its parent even when the child has its own tab, while also listing that tab, so a tab agent with a parent appears twice. The cost: herdr-core no longer notifies the Leader when a tab agent blocks, errors, or exits, so the Leader checks its tab agents itself ([`herdr-team-lead`](../herdr-team-lead/SKILL.md#2-guidance), Coordinate tab agents).
- Then find the new terminal's tab in `herdr-app ls` and name it with `herdr-app do tab.rename --id <tab> --name <label>`.

**New team.** Create the space with `herdr-app do space.new --name <name> --folder <dir>`; it returns `space`, `tab`, and `terminal` and starts a plain shell in that first tab. Start the Leader with `hc run` as above, rename its tab to `Leader`, then close the initial shell tab with `herdr-app do tab.close --id <initial tab> --confirmed true` after checking in `herdr-app ls` that it holds only that shell. The Leader's tab is then first. Create the Leader before any tab agent, and record the Leader's address (terminal name) in every tab agent's handoff. If the Leader fails to start, stop creating that team: leave the new space and its shell tab in place, and report the space name so the user can retry or close it.

**Start each sub-agent** per Section 3.1.

**Requested split.** Only when the user asks for panes in one tab, add `--label herdr.tab=<tab-id>` to `hc run`; the terminal then opens as a split of that tab.

### 3.1. Sub-agents

Any tab of a team, the Leader or a tab agent, may start a sub-agent. The creator runs this from its own terminal, so it stays the sub-agent's parent (herdr-core notifies it when the sub-agent blocks, errors, or exits), and the `herdr.space` label gives the sub-agent a tab in the space:

```bash
hc run --bg --json --name <agent-name> --cwd <dir> --label herdr.space=<space-id> \
  env TERM=xterm-256color <command> "<brief, or the path of its brief file, plus: you write no code and start no agents; report with hc send <creator-address> when done or stuck>"
```

1. **Name its tab first.** Right after `hc run`, find the sub-agent's tab in `herdr-app ls` (it opens with a default name, possibly before the creator's tab) and rename it with `herdr-app do tab.rename --id <tab> --name "↳ <name>"`. `hc rm` closes that tab when the creator removes the sub-agent. With a parent and a tab, the sub-agent appears twice in the app's Agents sidebar (as its own tab and under its creator); that is accepted, because the tab is what makes it visible and counted in the space.
2. **Within the creator's approved mission only.** A sub-agent never widens scope or settles a Human Layer decision; those still go from a tab agent to the Leader, and from the Leader to the user.
3. **A sub-agent creates no agents**, neither sub-agents nor tab agents; its brief says so.
4. **The creator owns its sub-agent.** It receives the report (and herdr-core's note if the sub-agent blocks, errors, or exits), uses it, then ends and removes the sub-agent with `hc kill <agent-name>` and `hc rm <agent-name>`. No finished sub-agent is left behind.
5. **A sub-agent writes no code**; its brief says so. When its work turns into code (an investigation finds the fix), it reports to its creator and is removed; when the code fits the creating tab agent's mission, that tab agent writes it, otherwise it becomes a new tab agent, which only the Leader creates, after the user approves.
6. **Sub-agents are not recorded in `leader.md`.** They show as `↳ <name>` tabs of the space while they run.

- Without `--outlive-parent` a sub-agent ends with its creator, which suits work that ends in one report.
- The user can watch or talk to a sub-agent in its `↳` tab.
- To end an agent, use `hc kill`. `hc send <agent> "/exit"` does not end it: `hc send` wraps the text as an `<hc from=…>` message, which the agent only reads. A graceful exit needs keystrokes: `hc keys <agent> / e x i t`, then `hc keys <agent> enter`.

**Pick-up check.** Run `hc wait <agent-name> --timeout 60` and inspect `hc get <agent-name>`. `working`, `idle`, or `done` after its first turn means the work was picked up. On `blocked` (for example a folder-trust dialog) or `error`, read `hc read <agent-name> --lines 40`, leave the tab open, and report the needed action to the user; never answer the dialog yourself. Do not restart or re-prompt automatically. Continue other streams.

## 4. Report

Open with one plain sentence per stream: what it will deliver for the user's goal and which decisions may come back, described in system terms ([human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md)). Then give one row per stream with agent, role (Leader, tab agent, or sub-agent), harness, space/tab, terminal address, handoff path, worktree/branch if any, and status. State whether a space was created or adopted as a team. Report failures and any checkout created before a failed Herdr App step. Worktree cleanup is outside this skill.

## 5. Success Validation

- [ ] Herdr App environment (`HC_TERMINAL_ID`, `hc`, `herdr-app`) and CLI syntax were verified; the `herdr` terminal CLI was not used; the calling tab stayed untouched, except for a `Leader` rename and move during adoption.
- [ ] New work got a space whose first tab is a `Leader` running `herdr-team-lead`, with the initial shell tab closed; a space without `leader.md` was adopted per Section 1.1, asking the user when the Leader was ambiguous or was writing code.
- [ ] Handoff files and `leader.md` were written to the team folder keyed by space ID; every tab agent's handoff names its Leader, states the tab agent contract (Leader owns state, announce before building, notify the Leader of the user's decisions in the tab agent's tab, write for the user only where the user writes, deliver with evidence), and lists `herdr-talk` and `herdr-handoff` (for sub-agents).
- [ ] Every new code writer has its own Git worktree unless the user explicitly requested reuse.
- [ ] Branch naming and base follow `git-branch`, without switching the calling checkout; mandatory project instructions were respected.
- [ ] Every code-writing stream's handoff lists `coding`, `agent-self-review`, `commit`, `github-pull-request`, and `git-branch` with absolute `SKILL.md` paths.
- [ ] Each stream's kind fits its work: tab agents and the Leader were started with `--outlive-parent`, `--no-parent`, the `herdr.space` label, and a semantically named tab; only the Leader created tab agents. Every agent has a unique name and its start prompt in the start command.
- [ ] Each sub-agent was started by a team tab within its approved mission, as a child of that tab with the `herdr.space` label and a `↳ <name>` tab, for work that writes no code, with a brief that forbids writing code and starting agents and names where to report; the creator ended and removed it after its report.
- [ ] Every stream reached a picked-up state or a reported failure; no dialog was answered and nothing was retried automatically.
- [ ] The report covers every stream and retained checkout, with no automatic cleanup.
