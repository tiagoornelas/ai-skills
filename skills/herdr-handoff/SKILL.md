---
name: herdr-handoff
description: >-
  Hands off the active conversation to one or more new AI agent sessions inside
  Herdr: writes one handoff document per stream, opens semantically named tabs
  (in the current workspace by default, or in a named or new workspace), optionally
  splits a tab into two side-by-side or stacked agents, isolates code-writing
  streams in Herdr worktree workspaces, starts the requested harness in each pane,
  and prompts it to resume from its handoff. Triggered strictly upon explicit user
  request while running inside Herdr.
disable-model-invocation: true
argument-hint: "[streams, layout, workspace, and harness for each pane]"
---

# Herdr Handoff

Forks work out of the current session into new agent panes, each one driven by its own handoff document. The calling session stays where it is: it keeps its focus, its tab, and its context.

---

## 1. Preconditions

- Verify the agent runs inside a Herdr-managed pane: `test "${HERDR_ENV:-}" = 1`. If it fails, say so and stop. Never control a Herdr session from outside it.
- **The installed binary is the authority for command syntax.** Load `herdr --skill` unless a Herdr skill is already in context, and check `herdr <group> --help` before using an unfamiliar option. The commands in this skill show intent, not a frozen contract.
- Only the local session is in scope. Commands targeting saved SSH machines (`--machine`) are not supported: a handoff file written to the local temporary directory does not exist on the remote host.

---

## 2. Plan the Streams

Turn the user's request into a plan. A **stream** is one agent with one mission, living in one pane.

| Dimension | Default | User may request |
| :--- | :--- | :--- |
| **Workspace** | Current workspace (`$HERDR_WORKSPACE_ID`) | A workspace by name (see below) |
| **Tab** | One new tab per stream | Two streams sharing a tab |
| **Split** | — | `right` (side by side) or `down` (stacked) |
| **Harness** | Same as the calling session | A different harness per pane |
| **Native flags** | None | Explicit flags (permission mode, model, …) |
| **Directory** | Calling session's working directory | Another directory |

**Resolve a named workspace** by matching its label in `herdr workspace list`: one match → use it; no match → create it with that label; several matches → ask the user.

**Layout limits**: at most **two agents per tab**. More streams become more tabs. All tabs created by one request are kept together in the same workspace. Never rename, move, or close the calling tab.

**Detect the calling harness** from `herdr agent get "$HERDR_PANE_ID"` (field `.result.agent.agent`, e.g. `claude`, `codex`, `agy`). Valid kinds are listed by `herdr agent start --help`.

**Never infer native flags.** Permission modes in particular are never inherited silently: pass only what the user asked for.

### 2.1. Isolate Code-Writing Streams

When **more than one agent will write code** in the same repository, and the calling session counts as one of them, each new code-writing stream gets its own worktree workspace through `herdr worktree create` (with `--branch`, `--base`, `--label`, `--no-focus`). Name the branch and pick its base following the [`git-branch`](../git-branch/SKILL.md) skill.

A worktree stream always lives in its own workspace, which Herdr groups with the primary one. Splits inside a shared tab are therefore reserved for streams that do not write code (review, research, investigation). If the user insists on two writers in the same tab, warn them that they will share one checkout, then follow their decision.

The skill only **creates** worktrees: it never removes them. The final report lists each removal command, and the user cleans up.

### 2.2. Missions

Every stream needs a specific mission. If the user did not give one per pane, propose a split of the work and wait for confirmation.

When one skill drives a mission (e.g. `resolve-branch-conflict 146`), record it as the stream's **lead skill**, with its arguments. Section 4 starts the agent through it.

### 2.3. Names

Names must be semantic, short, and consistent across the request:

- **Workspace and tab labels**: lowercase, 2–4 words, in the user's session language (e.g. `review pr 153`, `fix display name`).
- **Agent names**: a slug of the mission matching `[a-z][a-z0-9_-]{0,31}`, unique among live agents (`herdr agent list`), e.g. `pr-review`.
- **Pane labels**: the agent name.

Every workspace, tab, and pane the skill creates gets its label. Herdr fills unlabeled ones with defaults (`1` for a new workspace's first tab, the harness name for a pane), which say nothing about the stream.

### 2.4. Confirm Only What Was Inferred

If the request fully specifies the plan, proceed. If the skill inferred anything (missions, lead skills, worktree isolation, branch names, harness, workspace creation), show the plan as a Unicode box-drawing diagram and wait for the user's go-ahead.

**Make the calling session unmistakable.** Always draw the calling workspace and tab, even though nothing in them changes, so the user can locate the new streams relative to where they are:

- The calling workspace header carries `◉ CURRENT WORKSPACE`; every other workspace header carries `✚ new` (or `✚ new · worktree · <branch>`).
- The calling tab uses **double-line borders** (`╔ ═ ╗`) and `◉ YOU ARE HERE (untouched)`; new tabs use single-line borders and `✚ new`.
- A new tab inside the current workspace sits under the current workspace header.
- End with a one-line legend: `◉ current session · ✚ will be created`.

```text
━━ workspace: ai-skills ◉ CURRENT WORKSPACE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
╔═ tab: plan handoff ◉ YOU ARE HERE (untouched) ════════════════════════════╗
║ this session · claude                                                     ║
╚═══════════════════════════════════════════════════════════════════════════╝
┌─ tab: review pr 153 ✚ new ────────┬───────────────────────────────┐
│ pr-review · claude                │ pr-second-opinion · codex     │
│ mission: review the diff          │ mission: challenge the review │
│ lead skill: github-code-review 153│                               │
└───────────────────────────────────┴───────────────────────────────┘

━━ workspace: fix display name ✚ new · worktree · fix/user-display-name ━━━━
┌─ tab: fix display name ✚ new ─────────────────────────────────────┐
│ display-fix · claude · mission: implement the fix                 │
└───────────────────────────────────────────────────────────────────┘

◉ current session · ✚ will be created
```

Resolve the calling workspace and tab labels from `herdr workspace get "$HERDR_WORKSPACE_ID"` and the tab of `$HERDR_PANE_ID` (check `herdr pane get --help` for the field), never from memory.

---

## 3. Write One Handoff per Stream

Read [`../handoff/SKILL.md`](../handoff/SKILL.md) and follow its **Document Content** and **Write and Deliver** sections for each stream:

- One document per stream, calibrated to **that stream's mission** (the mission is the handoff's "Next Session Goal"). Shared context is restated briefly in each file.
- Name each file after its agent name (e.g. `handoff-pr-review.md`) in the operating system temporary directory.
- For worktree streams, set **Source** to the worktree path and branch, not the calling directory.

---

## 4. Open the Layout and Start the Agents

Keep the user's focus in the calling pane: pass `--no-focus` to every creation command. Parse every ID from the JSON responses; never derive it.

1. **Create the container** for each stream:
   - Tab: `herdr tab create --workspace <id> --label <label> --cwd <dir> --no-focus` → `.result.root_pane`.
   - New workspace: `herdr workspace create --label <label> --cwd <dir> --no-focus` → `.result.root_pane`.
   - Worktree workspace: `herdr worktree create … --label <label> --no-focus` → read its root pane from the response.

   A new workspace (plain or worktree) opens with a first tab labeled `1`: rename it with `herdr tab rename <tab-id> <label>`, taking the tab ID from the root pane.
2. **Split** when two streams share a tab: `herdr pane split <root-pane> --direction right|down --cwd <dir> --no-focus` → `.result.pane`.
3. **Label** each stream's pane with its agent name: `herdr pane rename <pane-id> <agent-name>`. The label survives `agent start`.
4. **Start** the harness in each pane: `herdr agent start <agent-name> --kind <kind> --pane <pane-id> [-- <native-flags>]`.
5. **Prompt** each agent to read its file, not a pasted summary:
   ```bash
   herdr agent prompt <agent-name> "Read <absolute-handoff-path> and resume the work it describes." \
     --wait --until working --until blocked --timeout 30000
   ```
   For a stream with a lead skill, open the prompt with the skill's command so the harness loads it, even when the skill is restricted to user invocation:
   ```bash
   herdr agent prompt <agent-name> "/<lead-skill> <args> Before starting, read <absolute-handoff-path> and resume the work it describes." \
     --wait --until working --until blocked --timeout 30000
   ```
   Herdr types the prompt as user input, so `claude` and `agy` expand `/<skill>` like a command typed by the user. For other harnesses, check how they invoke skills; if unsure, use the plain prompt: the handoff's skill paths still let the agent load the skill.

   Wait only until the agent picks the work up. Do not wait for it to finish.

### 4.1. Failures

Never retry automatically: a timeout or a stall does not prove the prompt was not delivered, and a repeated prompt can duplicate work.

On `agent_not_ready`, `agent_blocked`, `agent_prompt_stalled`, `timeout`, or a `blocked` state (trust dialogs, login, approvals), leave the pane open. Read its state with `herdr agent get` and `herdr agent read <agent-name> --source recent-unwrapped --lines 60`, then report what the user must do. Continue with the remaining streams.

---

## 5. Report

End with a compact table, one row per stream:

| Agent | Harness | Workspace / Tab | Pane | Handoff | Worktree / Branch | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |

Then add:

- A notice that the handoff files live in a temporary directory and may disappear on reboot.
- For each worktree created, the removal command for the user to run once the work is merged (`herdr worktree remove --workspace <id>`, without `--force`).
- For each failed stream, the action the user must take.

---

## 6. Success Validation

- [ ] Running inside Herdr was verified before any control command; no `--machine` command was issued.
- [ ] Every created workspace, tab, and pane used `--no-focus`; the calling tab was left untouched.
- [ ] Missions and every other inferred choice were confirmed by the user before anything was opened.
- [ ] The plan diagram, when shown, highlights the calling workspace (`◉ CURRENT WORKSPACE`) and calling tab (double-line border, `◉ YOU ARE HERE`), and marks everything to be created with `✚ new`.
- [ ] Each stream has its own handoff file, written per the `handoff` skill, with the stream's mission as its goal.
- [ ] Code-writing streams running alongside another writer live in their own worktree workspace; branch names follow `git-branch`.
- [ ] No tab holds more than two agents; every created workspace, tab, and pane carries a semantic label (no `1` tab, no pane named after its harness), consistent with the agent names.
- [ ] Each handoff lists its recommended skills with absolute `SKILL.md` paths; each stream with a lead skill was prompted with that skill's command.
- [ ] Each agent ran the requested harness, received no flags the user did not ask for, and reached `working` (or was reported as failed without retry).
- [ ] The final report lists every stream, the temporary-file notice, and the worktree removal commands.
