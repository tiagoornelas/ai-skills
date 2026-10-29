---
name: herdr-handoff
description: >-
  Hands off the active conversation to new agent sessions in Herdr, organized
  as teams: new work becomes a workspace led by a Leader tab, with member
  agents in further tabs. Adopts an existing workspace as a team when needed,
  gives each code-writing agent its own Git worktree by default, writes
  handoff files to the team folder, and prompts each agent from its file.
  Triggered strictly upon explicit user request while running inside Herdr,
  including the user's approval of a split proposed by a Leader.
disable-model-invocation: true
argument-hint: "[streams, layout, workspace, and harness for each pane]"
---

# Herdr Handoff

Forks the current work into agent sessions while leaving the calling pane's work untouched. Herdr owns the layout; Git owns new worktrees. A stream is one agent, one mission, and one pane. A workspace is a team working on one cohesive piece of work, led by the agent in its `Leader` tab running [`herdr-team-lead`](../herdr-team-lead/SKILL.md); its durable files live in the team folder ([team-folder.md](../herdr-team-lead/references/team-folder.md)).

## 1. Preconditions and Plan

- Require `HERDR_ENV=1`. Otherwise report that the session is outside Herdr and stop. Use only the local session; never pass `--machine`.
- Treat the installed CLI as the syntax authority: load `herdr --skill` unless already in context, and inspect help for unfamiliar commands or flags. Parse IDs from JSON responses.
- An explicit layout from the user (named workspace, tab, or split) wins over the defaults below. Split a tab into panes only when requested. Different panes may use different checkouts.
- Resolve the team layout from where the handoff runs:

  | Situation | Layout |
  | :--- | :--- |
  | New work, or the caller sits outside the team that will do it | Create a workspace labeled with the task. Its first tab, labeled `Leader`, runs a new Leader with `herdr-team-lead` as lead skill, even for a single stream. When the split is already clear in the conversation, also create one tab per member; otherwise create only the Leader, which proposes the split. |
  | The target workspace has a `leader.md` | The team exists: add each stream as a member tab. |
  | The target workspace has no `leader.md` and the caller runs inside it | Adopt it: the caller is coordinating, so it becomes the Leader (Section 1.1), then add the member tabs. |
  | The target workspace has no `leader.md`, and another tab seems to be coordinating it | Ask the user which tab leads, then adopt with that tab as Leader. |

- Use a named workspace when requested: match its label in `herdr workspace list`, create it once if absent, and ask only if several match.
- Use the calling harness from `herdr agent get "$HERDR_PANE_ID"` unless the user names another. Pass native flags only when explicitly requested. Preserve the calling tab and focus with `--no-focus` on every creation command.
- Give each stream a specific mission. Record a lead skill and arguments when the mission calls for one. Choose short, semantic labels in the user's language for created workspaces and tabs; use a unique agent-name slug (`[a-z][a-z0-9_-]{0,31}`) for its pane.
- Resolve operational details from the request and context without approval. Ask only for essential missing information, conflicting instructions, or a requested preview. If showing a plan, use a Unicode box-drawing diagram that marks the calling workspace and tab as unchanged and identifies every new resource.

### 1.1. Adopt a Workspace

- If the agent becoming Leader is itself writing code in that workspace, ask the user before adopting: a Leader does not write code.
- Rename the Leader's tab to `Leader` with `herdr tab rename`. Herdr cannot reorder tabs, so an adopted Leader keeps its position; `leader.md` identifies it.
- Write `leader.md` in the team folder, in the format of [team-folder.md](../herdr-team-lead/references/team-folder.md), from what the conversation and the workspace show; mark inferences as ❓.
- When the caller becomes Leader, read `herdr-team-lead` and continue under it after this handoff. When another tab becomes Leader, tell it through [`herdr-talk`](../herdr-talk/SKILL.md) (Notify) to read `herdr-team-lead` at its absolute path and its `leader.md`.

## 2. Prepare Checkouts

For **each new agent that will write code**, create a separate Git worktree, even if it is the only writer. Read-only streams, including a Leader, use their requested directory or the calling directory. If the user explicitly requests an existing worktree, use it; warn when another agent is already writing there.

- Find the main worktree with `git worktree list --porcelain`. Put new worktrees in sibling directories named for the repository and task; choose an unused path and branch rather than silently reusing one.
- Follow the branch naming and base-selection rules in [`git-branch`](../git-branch/SKILL.md), **not** its checkout-changing execution workflow. For independent work, resolve the default branch, fetch its remote, and use the updated remote-tracking ref as the base; use a different base for an explicit dependency. If the repository has no remote, use its local default branch. Never switch the calling checkout.
- Create with `git worktree add -b <branch> <path> <base-ref>`. If mandatory project instructions prescribe another creation procedure, follow them; do not use `herdr worktree create`.
- If checkout preparation fails, report the affected stream and continue independent streams. If a later Herdr step fails, keep any created Git worktree and report its path and branch so the user can resume or clean it later.

## 3. Write and Start Each Stream

Read [`../handoff/SKILL.md`](../handoff/SKILL.md) and apply its **Document Content** and **Write and Deliver** sections, except that files go to the team folder `~/.herdr-teams/<workspace-id>/` instead of the temporary directory. Write one handoff file per member, named `handoff-<agent-name>.md`, with that stream's mission as its Next Session Goal; a new Leader's handoff is that team's `leader.md`, in the format of [team-folder.md](../herdr-team-lead/references/team-folder.md). For a worktree stream, set Source to its actual worktree path and branch.

Every member's handoff names its Leader's address and states that decisions and blockers go to the Leader through `herdr-talk`; list `herdr-talk` in its Recommended Skills. A Leader's handoff lists `herdr-team-lead` as its lead skill.

Every code-writing stream's Recommended Skills always lists the delivery workflow, whatever the mission: `coding` for code changes, `agent-self-review` before delivery, `commit` for every commit, `github-pull-request` for opening a pull request, and `git-branch` with the note that the stream's branch already exists and the skill applies only to any additional branch. This keeps branches, commits, and pull requests from new panes within the standard.

Create the layout with `herdr workspace create --label <label> --cwd <dir> --no-focus` or `herdr tab create --workspace <id> --label <label> --cwd <dir> --no-focus`, creating a new team's `Leader` tab before any member tab. For a requested split, use `herdr pane split <pane-id> --direction right|down --cwd <dir> --no-focus`. Rename a new workspace's default `1` tab to `Leader` with `herdr tab rename` and each pane with `herdr pane rename`; obtain all IDs from the command responses. Start each agent with `herdr agent start <name> --kind <kind> --pane <pane-id> [-- <requested-native-flags>]`.

Prompt each agent to read its handoff file. If it has a lead skill, prefix the prompt with that skill's command when its harness supports it; otherwise use a plain prompt with the handoff path. Use `herdr agent prompt <name> <prompt> --wait --until working --until blocked --timeout 30000` and wait only until the work is picked up.

Do not retry a failed or timed-out prompt automatically. On a blocked or uncertain state, inspect `herdr agent get` and recent `herdr agent read` output, leave the pane open, and report the needed action. Continue other streams.

## 4. Report

Open with one plain sentence per stream: what it will deliver for the user's goal and which decisions may come back, described in system terms ([human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md)). Then give one row per stream with agent, role (Leader or member), harness, workspace/tab, pane, handoff path, worktree/branch if any, and status. State whether a workspace was created or adopted as a team. Report failures and any checkout created before a failed Herdr step. Worktree cleanup is outside this skill.

## 5. Success Validation

- [ ] Herdr environment and local CLI syntax were verified; the calling tab and focus stayed untouched, except for a `Leader` rename during adoption.
- [ ] New work got a workspace whose first tab is a `Leader` running `herdr-team-lead`; a workspace without `leader.md` was adopted per Section 1.1, asking the user when the Leader was ambiguous or was writing code.
- [ ] Handoff files and `leader.md` were written to the team folder; every member's handoff names its Leader and lists `herdr-talk`.
- [ ] Every new code writer has its own Git worktree unless the user explicitly requested reuse; no Herdr worktree was created.
- [ ] Branch naming and base follow `git-branch`, without switching the calling checkout; mandatory project instructions were respected.
- [ ] Every code-writing stream's handoff lists `coding`, `agent-self-review`, `commit`, `github-pull-request`, and `git-branch` with absolute `SKILL.md` paths.
- [ ] Every stream has a mission-specific handoff file, semantic layout labels, the requested harness and flags, and a prompt that reached `working` or a reported failure.
- [ ] The report covers every stream and retained checkout, with no automatic retry or cleanup.
