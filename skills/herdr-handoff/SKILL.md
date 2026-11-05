---
name: herdr-handoff
description: >-
  Hands off the active conversation to new agent sessions in the Herdr App,
  organized as teams: new work becomes a space led by a Leader tab, with member
  agents in further tabs. Adopts an existing space as a team when needed, gives
  each code-writing agent its own Git worktree by default, writes handoff files
  to the team folder, and starts each agent from its file. Built for the Herdr
  App (herdr-app + hc), not the Herdr terminal multiplexer (`herdr` CLI).
  Triggered strictly upon explicit user request while running inside the Herdr
  App, including the user's approval of a split proposed by a Leader, and by
  any team tab (Leader or member) starting a task within its approved mission.
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
- Resolve the team layout from where the handoff runs. Inside a space, the default is a member of that space's team: work stays in the team it came from, and a new team is an explicit choice.

  | Situation | Layout |
  | :--- | :--- |
  | The work does not continue the calling space's work (it is unrelated to its team's objective, or the caller sits in a general-purpose space), or the user asks for a new team | Create a space named for the task. Its first tab, named `Leader`, runs a new Leader with `herdr-team-lead` as lead skill, even for a single stream. When the split is already clear in the conversation, also create one tab per member; otherwise create only the Leader, which proposes the split. |
  | The streams join a space that has a `leader.md` | The team exists: add each stream as a member tab. |
  | The streams join the caller's own space, which has no `leader.md` | Adopt it: the caller is coordinating, so it becomes the Leader (Section 1.1), then add the member tabs. |
  | The streams join a space without `leader.md`, and another tab seems to be coordinating it | Ask the user which tab leads, then adopt with that tab as Leader. |

- Use a named space when requested: match its name in `herdr-app ls`, create it once if absent, and ask only if several match.
- Use the calling harness's command from `hc get "$HC_TERMINAL_ID"` (`foreground.argv[0]`, for example `claude`) unless the user names another. Wrap with `env TERM=xterm-256color` when launching via `hc run` so that terminal tools (such as `agy`) detect color support instead of falling back to monochrome under herdr-core's default `TERM=dumb`. Codex must run with `--no-daemon`. Pass other native flags only when explicitly requested.
- Choose each stream's kind; the user may override it:

  | Kind | When | Shape |
  | :--- | :--- | :--- |
  | **Member** | Long-running work the user follows and may talk to directly: writing code, owning a branch or pull request, work lasting more than one session | Own tab in the space, its own handoff file, no parent, lives until the user ends it |
  | **Task** | Short, disposable work that ends in one report: a review, an investigation, a check | Sub-agent of the team tab that creates it, with no tab (listed under its creator in the app's Agents sidebar), brief in its start prompt or a file, ended and removed by its creator once its report is in |

  A Leader is always a member-kind stream with its own tab. Only the Leader creates members, and only after the user approves the split; any team tab may create tasks under Section 3.1.
- Give each stream a specific mission. Record a lead skill and arguments when the mission calls for one. Choose short, semantic names in the user's language for created spaces and tabs; use a unique terminal-name slug (`[a-z0-9_-]{1,32}`, unique among live terminals in `hc ls`) for each agent.
- Resolve operational details from the request and context without approval. Ask only for essential missing information, conflicting instructions, or a requested preview. If showing a plan, use a Unicode box-drawing diagram that marks the calling space and tab as unchanged and identifies every new resource.

### 1.1. Adopt a Space

- If the agent becoming Leader is itself writing code in that space, ask the user before adopting: a Leader does not write code.
- Rename the Leader's tab to `Leader` with `herdr-app do tab.rename --id <tab> --name Leader` and move it first with `herdr-app do tab.move --id <tab> --index 1`.
- Write `leader.md` in the team folder, in the format of [team-folder.md](../herdr-team-lead/references/team-folder.md), from what the conversation and the space show; mark inferences as ❓.
- When the caller becomes Leader, read `herdr-team-lead` and continue under it after this handoff. When another tab becomes Leader, tell it through [`herdr-talk`](../herdr-talk/SKILL.md) (Notify) to read `herdr-team-lead` at its absolute path and its `leader.md`.

## 2. Prepare Checkouts

For **each new agent that will write code**, create a separate Git worktree, even if it is the only writer. Read-only streams, including a Leader, use their requested directory or the calling directory. If the user explicitly requests an existing worktree, use it; warn when another agent is already writing there.

- Find the main worktree with `git worktree list --porcelain`. Put new worktrees in sibling directories named for the repository and task; choose an unused path and branch rather than silently reusing one.
- Follow the branch naming and base-selection rules in [`git-branch`](../git-branch/SKILL.md), **not** its checkout-changing execution workflow. For independent work, resolve the default branch, fetch its remote, and use the updated remote-tracking ref as the base; use a different base for an explicit dependency. If the repository has no remote, use its local default branch. Never switch the calling checkout.
- Create with `git worktree add -b <branch> <path> <base-ref>`. If mandatory project instructions prescribe another creation procedure, follow them. Never use the Herdr App's own worktree feature (the `worktree` mod behind "New worktree"): it turns each checkout into a separate space nested under its repository, which breaks a space organized around one task that spans several repositories.
- If checkout preparation fails, report the affected stream and continue independent streams. If a later Herdr App step fails, keep any created Git worktree and report its path and branch so the user can resume or clean it later.

## 3. Write and Start Each Stream

Read [`../handoff/SKILL.md`](../handoff/SKILL.md) and apply its **Document Content** and **Write and Deliver** sections, except that files go to the team folder `~/.herdr-teams/<space-id>/` instead of the temporary directory. Write one handoff file per member, named `handoff-<agent-name>.md`, with that stream's mission as its Next Session Goal; a new Leader's handoff is that team's `leader.md`, in the format of [team-folder.md](../herdr-team-lead/references/team-folder.md). For a worktree stream, set Source to its actual worktree path and branch.

Every member's handoff names its Leader's address and states the **member contract**; list `herdr-talk` in its Recommended Skills, and list `herdr-handoff` with the note that it applies only to starting tasks (Section 3.1), since only the Leader creates members. A Leader's handoff lists `herdr-team-lead` as its lead skill. The member contract:

- **The Leader owns the space's state.** Decisions, blockers, and deliveries go to the Leader through `herdr-talk`, never as a report to the user.
- **Announce before building.** Anything that would start to run, cost, store data, or hold permissions in production and was not in the approved split goes to the Leader before it is built, for the Leader to classify with [the boundary test](../ai-assisted-software-development/SKILL.md#4-the-boundary-test); a business rule or anything that deletes or rewrites production data is always a decision for the user.
- **The user may talk to any tab.** When the user decides something or acts in the member's tab, the member notifies the Leader at once (`herdr-talk` Notify: "the user decided X in this tab"), so the Leader never asks for it again.
- **Write for the user only where the user writes.** In its own tab, the member addresses the user only after the user has written there; otherwise its reports go to the Leader.
- **Deliver with evidence.** A delivery to the Leader carries the author lines of the [evidence dossier](../ai-assisted-software-development/references/evidence-dossier.md) ((a) why, (b) architecture) and the `agent-self-review` verdict; the Leader obtains lines (c)–(e) from an independent reviewer.

Every code-writing stream's Recommended Skills always lists the delivery workflow, whatever the mission: `coding` for code changes, `agent-self-review` before delivery, `commit` for every commit, `github-pull-request` for opening a pull request, and `git-branch` with the note that the stream's branch already exists and the skill applies only to any additional branch. This keeps branches, commits, and pull requests from new agents within the standard.

**Start prompt.** Each agent's first message tells it to read its handoff file. If it has a lead skill, prefix the prompt with that skill's command when its harness supports it; otherwise use a plain prompt with the handoff path. Put this prompt in the start command itself: a message sent to a booting agent can be dropped.

**Start each member** with `hc run`, which makes its terminal visible as a new tab of the space through the `herdr.space` label:

```bash
hc run --bg --json --name <agent-name> --cwd <dir> --outlive-parent --no-parent \
  --label herdr.space=<space-id> env TERM=xterm-256color <command> "<start prompt>"
```

- `--outlive-parent` is mandatory: without it, the agent ends when the agent that started it ends.
- `--no-parent` is mandatory for members and Leaders alike. The app's Agents sidebar nests every live child under its parent even when the child has its own tab, while also listing that tab, so a member with a parent appears twice. The cost: herdr-core no longer notifies the Leader when a member blocks, errors, or exits, so the Leader checks its members itself ([`herdr-team-lead`](../herdr-team-lead/SKILL.md), Coordinate Members).
- Then find the new terminal's tab in `herdr-app ls` and name it with `herdr-app do tab.rename --id <tab> --name <label>`.

**New team.** Create the space with `herdr-app do space.new --name <name> --folder <dir>`; it returns `space`, `tab`, and `terminal` and starts a plain shell in that first tab. Start the Leader with `hc run` as above, rename its tab to `Leader`, then close the initial shell tab with `herdr-app do tab.close --id <initial tab> --confirmed true` after checking in `herdr-app ls` that it holds only that shell. The Leader's tab is then first. Create the Leader before any member, and record the Leader's address (terminal name) in every member's handoff. If the Leader fails to start, stop creating that team: leave the new space and its shell tab in place, and report the space name so the user can retry or close it.

**Start each task** per Section 3.1.

**Requested split.** Only when the user asks for panes in one tab, add `--label herdr.tab=<tab-id>` to `hc run`; the terminal then opens as a split of that tab.

### 3.1. Tasks

Any tab of a team, the Leader or a member, may start a task. The creator runs this from its own terminal, so it becomes the task's parent by default; the task carries no `herdr.space` label and so gets no tab:

```bash
hc run --bg --json --name <agent-name> --cwd <dir> \
  env TERM=xterm-256color <command> "<brief, or the path of its brief file, plus: you start no agents; report with hc send <creator-address> when done or stuck>"
```

1. **Within the creator's approved mission only.** A task never widens scope or settles a Human Layer decision; those still go from a member to the Leader, and from the Leader to the user.
2. **A task creates no agents**, neither tasks nor members; its brief says so.
3. **The creator owns its task.** It receives the report (and herdr-core's note if the task blocks, errors, or exits), uses it, then ends and removes the task with `hc kill <agent-name>` and `hc rm <agent-name>`. No finished task is left behind.
4. **A task that writes code uses its own worktree** (Section 2), never its creator's.
5. **Tasks are not recorded in `leader.md`.** The Leader sees them nested under their creator in the app's Agents sidebar.

- Without `--outlive-parent` a task ends with its creator, which suits disposable work.
- If the user wants to watch or talk to a task, show it with `herdr-app do agent.focus --terminal <address>`, or give it a tab by asking the Leader to restart it as a member.
- To end an agent, use `hc kill`. `hc send <agent> "/exit"` does not end it: `hc send` wraps the text as an `<hc from=…>` message, which the agent only reads. A graceful exit needs keystrokes: `hc keys <agent> / e x i t`, then `hc keys <agent> enter`.

**Pick-up check.** Run `hc wait <agent-name> --timeout 60` and inspect `hc get <agent-name>`. `working`, `idle`, or `done` after its first turn means the work was picked up. On `blocked` (for example a folder-trust dialog) or `error`, read `hc read <agent-name> --lines 40`, leave the tab open, and report the needed action to the user; never answer the dialog yourself. Do not restart or re-prompt automatically. Continue other streams.

## 4. Report

Open with one plain sentence per stream: what it will deliver for the user's goal and which decisions may come back, described in system terms ([human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md)). Then give one row per stream with agent, role (Leader, member, or task), harness, space/tab, terminal address, handoff path, worktree/branch if any, and status. State whether a space was created or adopted as a team. Report failures and any checkout created before a failed Herdr App step. Worktree cleanup is outside this skill.

## 5. Success Validation

- [ ] Herdr App environment (`HC_TERMINAL_ID`, `hc`, `herdr-app`) and CLI syntax were verified; the `herdr` terminal CLI was not used; the calling tab stayed untouched, except for a `Leader` rename and move during adoption.
- [ ] New work got a space whose first tab is a `Leader` running `herdr-team-lead`, with the initial shell tab closed; a space without `leader.md` was adopted per Section 1.1, asking the user when the Leader was ambiguous or was writing code.
- [ ] Handoff files and `leader.md` were written to the team folder keyed by space ID; every member's handoff names its Leader, states the member contract (Leader owns state, announce before building, notify the Leader of the user's decisions in the member's tab, write for the user only where the user writes, deliver with evidence), and lists `herdr-talk` and `herdr-handoff` (for tasks).
- [ ] Every new code writer has its own Git worktree unless the user explicitly requested reuse.
- [ ] Branch naming and base follow `git-branch`, without switching the calling checkout; mandatory project instructions were respected.
- [ ] Every code-writing stream's handoff lists `coding`, `agent-self-review`, `commit`, `github-pull-request`, and `git-branch` with absolute `SKILL.md` paths.
- [ ] Each stream's kind fits its work: members and the Leader were started with `--outlive-parent`, `--no-parent`, the `herdr.space` label, and a semantically named tab; only the Leader created members. Every agent has a unique name and its start prompt in the start command.
- [ ] Each task was started by a team tab within its approved mission, as a tab-less sub-agent of that tab, with a brief that forbids starting agents and names where to report; a code-writing task has its own worktree; the creator ended and removed it after its report.
- [ ] Every stream reached a picked-up state or a reported failure; no dialog was answered and nothing was retried automatically.
- [ ] The report covers every stream and retained checkout, with no automatic cleanup.
