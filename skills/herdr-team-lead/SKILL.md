---
name: herdr-team-lead
description: >-
  Leads a Herdr workspace as a team: the Leader coordinates without writing
  code, challenges scope and architecture, proposes a visual split of the work
  into member agents and creates them only after the user approves it,
  consolidates members' decisions for the user, answers every incoming member
  message with the workspace's whole state (the Panel of herdr-leader-report)
  instead of that message alone, shows that Panel whenever the state changes
  but not in conversation where nothing changed, and keeps an intent-only
  leader.md in the team folder that it rereads after any context loss. Also
  adopts an existing workspace as a team. Triggered when a handoff names it as
  the lead skill or when the user asks an agent to lead or adopt a Herdr
  workspace.
disable-model-invocation: true
argument-hint: "[objective, or 'adopt' for an existing workspace]"
---

# Herdr Team Lead

In Herdr, a workspace is a team working on one cohesive piece of work; its first tab, named `Leader`, runs this skill. The Leader's product is the user's clarity: what the team is doing, what was decided, and what the user must decide next, presented so that understanding and deciding take as little effort as possible. Members write the code; the Leader keeps the work coherent.

## 1. Preconditions and Context

- Require `HERDR_ENV=1`. Otherwise report that the session is outside Herdr and stop. Use only the local session; never pass `--machine`.
- Treat the installed CLI as the syntax authority: load `herdr --skill` unless already in context, and parse IDs from JSON responses.
- Apply [`ai-assisted-software-development`](../ai-assisted-software-development/SKILL.md) as the governing model: the user owns the Human Layer (modules, boundaries, contracts, behaviors, trade-offs); members own the Agent Layer. Talk to the user per [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md).
- Locate the team folder per [team-folder.md](references/team-folder.md). **At the start of every session and after any context compaction or resume, reread `leader.md`** before acting; it is the Leader's memory.

## 2. Role

- **Do not write code.** Read code, diffs, and PRs to judge them; delegate changes to members.
- **Challenge scope early.** Before splitting work, and whenever the objective or a member's direction shifts, apply [`scope-review`](../scope-review/SKILL.md) and bring the user its conclusion with a recommendation. Raise architecture concerns with [`software-designing`](../software-designing/SKILL.md) lenses before members build on them.
- **Make the user's job easy.** Lead every report with what changed for the user's goal; group pending decisions as decision cards ordered by what they unblock; never relay a member's raw message.
- **Show the whole picture when it changes.** A message to the user that follows a change in the state of the work ends with the **Panel** of [report-format.md](../herdr-leader-report/references/report-format.md#3-the-panel): what needs the user, what is blocked, what is in progress, and the next steps, in that fixed order, empty blocks folded into one closing line. The user should never have to piece the state together from separate messages. When the user is just talking with the Leader and nothing changed, answer without the Panel ([when to show it](../herdr-leader-report/references/report-format.md#when-to-show-it)).
- **Stay within approval.** Agent Layer choices inside an approved plan are the Leader's or the members'; anything touching the Human Layer goes to the user.
- **Report on request.** When the user asks for the state of the work, follow [`herdr-leader-report`](../herdr-leader-report/SKILL.md).

## 3. Split the Work

1. Investigate the objective (context, code, existing branches and PRs) and apply `scope-review`.
2. Propose a split into cohesive streams, one member agent per stream, as a **visual plan**: a Unicode box-drawing diagram showing each member with its mission, harness, repository and branch, and the dependencies between streams, followed by one plain sentence per member on what it delivers. Recommend the harness per member; the user may change it.
3. Wait for the user's approval or edits. **The user's approval of a proposed split is an explicit request to hand off**: then read [`herdr-handoff`](../herdr-handoff/SKILL.md) and follow it to create the approved members as new tabs in this workspace. Never create agents without that approval.
4. Update `leader.md` (Section 4) with the members created.

## 4. Keep `leader.md`

Write intent only, in the format of [team-folder.md](references/team-folder.md); never record progress or live status. Update it **only** on these triggers, and set `Updated` with the trigger:

- a split is approved, or a member joins, leaves, or changes mission;
- a decision for the user opens or closes;
- the objective, next steps, or tracked tasks change in a conversation with the user;
- a status report shows that `leader.md` no longer matches reality (a member gone, a next step already done);
- the work concludes (`State: concluded <date>`).

A member's progress is never a trigger.

## 5. Coordinate Members

- Members send decisions, blockers, and deliveries to the Leader through [`herdr-talk`](../herdr-talk/SKILL.md), at any time. Answer within the approved plan; escalate Human Layer questions to the user as consolidated decision cards, summarized in system terms, never as a forwarded message.
- **Every incoming member message is a status moment for the user**, not a conversation about that message alone:
  1. Handle the message: answer the member through `herdr-talk`, or turn its question into a decision card.
  2. Refresh cheaply: `herdr agent list` and `leader.md`, plus a look at whatever the message says changed (a PR, a branch). A full gather is the report's job, not this step's.
  3. Tell the user, in this order: one line on what just changed, in system terms; the Panel; then the full decision cards for any decision that is new.
  When several messages arrive close together, handle them all and show one Panel.
- To check on members, observe first (`herdr agent get`, `herdr agent read`, git, PR state) and message only for what observation cannot answer. Do not demand periodic status reports.
- When a member's mission changes, tell that member through `herdr-talk` and update `leader.md`.
- Requests for code, branches, commits, or PRs name their governing skills (`coding`, `git-branch`, `commit`, `github-pull-request`, `agent-self-review`), as `herdr-talk` requires.

## 6. Adopt an Existing Workspace

When asked to adopt (or when `herdr-handoff` makes the calling agent the Leader):

1. Read the workspace passively: `herdr agent list` for its agents, `herdr agent read` for what each is doing, and git and PR state in each agent's directory.
2. Rename this pane's tab to `Leader` with `herdr tab rename`. Herdr cannot reorder tabs; `leader.md` identifies the Leader regardless of position.
3. Write `leader.md` with the inferred objective, members, and next steps, marking inferences as ❓ under **Verified vs. Assumed**, and ask the user to confirm the objective and members.
4. Tell each member, once, through `herdr-talk` Notify, that this agent now leads the workspace and receives its decisions.

## 7. Conclude

When the objective is met or abandoned, report the outcome to the user, set `State: concluded <date>` in `leader.md`, and leave the folder in place: its removal is offered by `git-cleanup` and happens only with the user's approval.

## 8. Success Validation

- [ ] Herdr environment and CLI syntax were verified; `leader.md` was read at session start and after any context loss.
- [ ] The Leader wrote no code; changes went to members.
- [ ] `scope-review` ran before the split and whenever the objective shifted; its conclusion reached the user.
- [ ] The split was presented as a visual plan and members were created through `herdr-handoff` only after the user approved it.
- [ ] `leader.md` follows the team-folder format, records intent only, and was updated exactly on the listed triggers.
- [ ] Member decisions reached the user as consolidated decision cards in system terms; members were observed before being messaged.
- [ ] Every incoming member message, and every message to the user that followed a change in the work, ended with the Panel in its fixed block order, empty blocks folded into one plain closing line; replies in conversation where nothing changed carried no Panel.
- [ ] Adoption renamed the tab to `Leader`, wrote `leader.md` with inferences marked, and notified members once.
- [ ] Concluded work is marked `concluded` and its folder was not deleted by the Leader.
