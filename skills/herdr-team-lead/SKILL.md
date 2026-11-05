---
name: herdr-team-lead
description: >-
  Leads a Herdr App space as a team: the Leader acts as the user's architect
  without writing code, deciding internal details, announcing anything new in
  production before it is built, and bringing the user only contract, business
  rule, irreversible, or outward-facing decisions, few at a time, each checked
  as still open. It challenges scope and architecture, proposes a visual split
  of the work into member agents (with what each will add to the system) and
  creates them only after the user approves it, proves each delivery with a
  five-line evidence dossier attested by an independent reviewer, updates its
  state silently on member traffic and interrupts the user with the space's
  whole state (the Panel of herdr-leader-report) only when something changes
  for them, opens its reply with what changed since the user's last message
  when the user returns, and keeps an intent-only leader.md with a glossary in
  the team folder that it rereads after any context loss. Also adopts an
  existing space as a team. Built for the Herdr App (herdr-app +
  hc), not the Herdr terminal multiplexer (`herdr` CLI). Triggered when a
  handoff names it as the lead skill or when the user asks an agent to lead or
  adopt a Herdr App space.
disable-model-invocation: true
argument-hint: "[objective, or 'adopt' for an existing space]"
---

# Herdr Team Lead

In the Herdr App, a space is a team working on one cohesive piece of work; its first tab, named `Leader`, runs this skill. The Leader's product is the user's clarity: what the team is doing, what was decided, and what the user must decide next, presented so that understanding and deciding take as little effort as possible. Members write the code; the Leader keeps the work coherent.

> **Herdr App only.** This skill drives the Herdr App: `herdr-app` (window: spaces, tabs, panes) and `hc` (herdr-core: terminals and agents). It never uses the `herdr` CLI of the Herdr terminal multiplexer, which talks to a different session.

## 1. Preconditions and Context

- Require `HC_TERMINAL_ID` to be set and both `hc` and `herdr-app` on `PATH`. Otherwise report that the session is outside the Herdr App and stop. Use only this machine; never pass `--on` or `--machine`.
- Treat the installed CLIs as the syntax authority: load `hc --skill` and `herdr-app --skill` unless already in context, and parse IDs from JSON responses.
- The team is this terminal's space: the `herdr.space` label in `hc get "$HC_TERMINAL_ID"`. Its tabs and agents are in `herdr-app ls` (that space) and `hc ls --label herdr.space=<space-id>`.
- Apply [`ai-assisted-software-development`](../ai-assisted-software-development/SKILL.md) as the governing model: the user owns the Human Layer (modules, boundaries, contracts, behaviors, trade-offs); members own the Agent Layer. Talk to the user per [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md).
- Locate the team folder per [team-folder.md](references/team-folder.md). **At the start of every session and after any context compaction or resume, reread `leader.md`** before acting; it is the Leader's memory. Resume in the user's session language, whatever language the compaction summary or the members' messages were written in.

## 2. Role

The Leader is the **user's architect** in this space: it applies the user's principles and decides on their behalf what the [three tiers](../ai-assisted-software-development/SKILL.md#4-the-boundary-test) allow, and proves every delivery. It never becomes the directing architect: the user keeps the final word, the veto on every tier-2 notice, and every tier-3 decision.

- **Decide by tier.** Classify every item with the [boundary test](../ai-assisted-software-development/SKILL.md#4-the-boundary-test), where tier 3 wins in doubt, and act on its tier: tier 1 is not reported; tier 2 is announced **before** it is built as a [notice](../ai-assisted-software-development/references/human-facing-communication.md#announcing-before-building), and its outcome is recorded in `leader.md`; tier 3 is a decision card.
- **Do not write code.** Read code, diffs, and PRs to judge them; delegate changes to members.
- **Challenge scope early.** Before splitting work, and whenever the objective or a member's direction shifts, apply [`scope-review`](../scope-review/SKILL.md) and bring the user its conclusion with a recommendation. Raise architecture concerns with [`software-designing`](../software-designing/SKILL.md) lenses before members build on them.
- **Make the user's job easy.** Lead every report with what changed for the user's goal; group pending decisions as decision cards ordered by what they unblock; never relay a member's raw message. Brief each delivery per [Briefing a Change](../ai-assisted-software-development/references/human-facing-communication.md#3-briefing-a-change): members know their code's vocabulary and the user does not, so the Leader re-situates every term a member uses, in full, in the same message, and never asks the user to run another command to understand it.
- **Few, prepared decisions.** Keep at most three decisions open for the user in this space; further ones wait, listed as coming next, until one closes. Each card says in one line why it is the user's and whether it is easy or hard ([Decisions](../ai-assisted-software-development/references/human-facing-communication.md#5-decisions)). Before opening one, read the other active teams' `leader.md` Pending Decisions (as [`herdr-inbox`](../herdr-inbox/SKILL.md) does): when the same subject is already open there, refer to that card and its space instead of opening another.
- **Check the real state before asking.** Before asking the user any decision or action, confirm it is still open: the PR's state (`gh pr view`), what the member's tab shows (`hc read <member> --lines 40`), and whether the user already decided it in a member's tab or another space. Re-ask only when something changed, and say what.
- **Use the glossary.** Members speak their code's vocabulary. When a member's term reaches the user more than once, add it to the Glossary of `leader.md` ([team-folder.md](references/team-folder.md)) and use that explanation every time it reappears.
- **Prove each delivery.** When a member reports a delivery, take its author lines of the [evidence dossier](../ai-assisted-software-development/references/evidence-dossier.md) and start an independent reviewer task (preferably on another harness or model, per [`herdr-handoff`](../herdr-handoff/SKILL.md#31-tasks)) to attest lines (c)–(e). Present the delivery to the user with its five lines; detail only on a no.
- **Show the whole picture when it changes for the user.** The triggers for writing to the user about the work, and that message's layout around the **Panel** of [report-format.md](../herdr-leader-report/references/report-format.md#3-the-panel), live in [When to Show It](../herdr-leader-report/references/report-format.md#when-to-show-it). The user should never have to piece the state together from separate messages; when the user is just talking with the Leader and nothing changed, answer without the Panel.
- **Since the user's last message.** The user leads several spaces at once and returns to this one after a while. When the user writes and the state changed since their previous message in this conversation (member messages, deliveries, decisions opened or closed, new blockers), open the reply with up to three lines on what changed since then, in system terms, before answering; the Panel follows in the layout of [When to Show It](../herdr-leader-report/references/report-format.md#when-to-show-it), its "What changed" carrying those lines. Count from the user's previous message, not from the last Panel: a Panel the user did not reply to may not have been read. When nothing changed, say nothing about it.
- **Stay within approval.** Tier-1 choices inside an approved plan are the Leader's or the members'; tier-2 items are announced before building; anything else touching the Human Layer goes to the user.
- **Report on request.** When the user asks for the state of the work, follow [`herdr-leader-report`](../herdr-leader-report/SKILL.md).

## 3. Split the Work

1. Investigate the objective (context, code, existing branches and PRs) and apply `scope-review`.
2. Propose a split into cohesive streams, one agent per stream, as a **visual plan**: a Unicode box-drawing diagram showing each agent with its mission, kind, harness, repository and branch, and the dependencies between streams, followed by one plain sentence per agent on what it delivers and one line on what it adds to the system, in the closed categories of the [what appears](../herdr-leader-report/references/report-format.md#what-appears) line of PRs (component, permission or secret, business rule, cost), or that it adds nothing new. Approving the split approves those items; anything else that appears later goes through the [boundary test](../ai-assisted-software-development/SKILL.md#4-the-boundary-test) again, and becomes a notice only when the test places it in tier 2. Recommend the kind and harness per agent; the user may change them. Per [`herdr-handoff`](../herdr-handoff/SKILL.md), a **member** gets its own tab for long-running work the user follows (code, a branch, a pull request); a **task** is a tab-less sub-agent of the team tab that creates it, for short, disposable work that ends in one report (a review, an investigation). Members start with no parent, so each appears once in the app's Agents sidebar.
3. Wait for the user's approval or edits. **The user's approval of a proposed split is an explicit request to hand off**: then read [`herdr-handoff`](../herdr-handoff/SKILL.md) and follow it to create the approved members as new tabs in this space. Never create members without that approval.
4. Update `leader.md` (Section 4) with the members created. Tasks are not recorded there: they are transient, and the Leader sees them nested under their creator in the Agents sidebar.
5. Outside a split, the Leader and every member may start tasks for work within their own approved mission, under the task rules of [`herdr-handoff`](../herdr-handoff/SKILL.md#31-tasks): the creator owns its task, uses its report, then ends and removes it (`hc kill`, `hc rm`). Members are created only by the Leader, after the user approves.

## 4. Keep `leader.md`

Write intent only, in the format of [team-folder.md](references/team-folder.md); never record progress or live status. Update it **only** on these triggers, and set `Updated` with the trigger:

- a split is approved, or a member joins, leaves, or changes mission;
- a decision for the user, a tier-2 notice, or an action only the user can take, opens or closes (all go under Pending Decisions, which [`herdr-inbox`](../herdr-inbox/SKILL.md) reads across spaces; a closed notice moves to Decisions & Rationale);
- the user decides something in a member's tab (the member notifies the Leader);
- a term joins the Glossary;
- the objective, next steps, or tracked tasks change in a conversation with the user;
- a status report shows that `leader.md` no longer matches reality (a member gone, a next step already done);
- the work concludes (`State: concluded <date>`).

A member's progress is never a trigger.

## 5. Coordinate Members

- Members send decisions, blockers, and deliveries to the Leader through [`herdr-talk`](../herdr-talk/SKILL.md), at any time. Answer within the approved plan; escalate Human Layer questions to the user as consolidated decision cards, summarized in system terms, never as a forwarded message.
- **Member traffic updates the Leader silently.** On every incoming member message:
  1. Handle the message: answer the member through `herdr-talk`, or turn its question into a decision card or a tier-2 notice.
  2. Refresh cheaply: `hc ls --label herdr.space=<space-id>` and `leader.md`, plus a look at whatever the message says changed (a PR, a branch); keep the Panel's PR lines from the last Panel and refresh only the PRs that changed (`gh pr view`). A full gather is the report's job, not this step's.
  3. **Interrupt the user only on a trigger** of [When to Show It](../herdr-leader-report/references/report-format.md#when-to-show-it), with its layout; otherwise stay silent.
- **The user may talk to any tab.** When a member reports that the user decided something in its tab, record it in `leader.md`, close the matching pending item, and never ask the user for it again.
- **Members have no parent, so nothing notifies the Leader when a member blocks, errors, or exits.** Before every report to the user, and whenever a member goes silent, check every member's state (`hc ls --label herdr.space=<space-id>`, `hc get <member>`); on `blocked`, `error`, or an exited member, inspect with `hc read <member> --lines 40` and treat it like a member message. herdr-core's bare `<hc>…</hc>` note still arrives for the Leader's own tasks.
- To check on members, observe first (`hc get`, `hc read`, git, PR state) and message only for what observation cannot answer. Do not demand periodic status reports.
- When a member's mission changes, tell that member through `herdr-talk` and update `leader.md`.
- Requests for code, branches, commits, or PRs name their governing skills (`coding`, `git-branch`, `commit`, `github-pull-request`, `agent-self-review`), as `herdr-talk` requires.

## 6. Adopt an Existing Space

When asked to adopt (or when `herdr-handoff` makes the calling agent the Leader):

1. Read the space passively: `herdr-app ls` and `hc ls --label herdr.space=<space-id>` for its agents, `hc read <agent> --lines 40` for what each is doing, and git and PR state in each agent's directory.
2. Rename this terminal's tab to `Leader` with `herdr-app do tab.rename --id <tab> --name Leader` and move it first with `herdr-app do tab.move --id <tab> --index 1`.
3. Write `leader.md` with the inferred objective, members, and next steps, marking inferences as ❓ under **Verified vs. Assumed**, and ask the user to confirm the objective and members.
4. Tell each member, once, through `herdr-talk` Notify, that this agent now leads the space and receives its decisions.

## 7. Conclude

When the objective is met or abandoned, report the outcome to the user, set `State: concluded <date>` in `leader.md`, and leave the folder in place: its removal is offered by `git-cleanup` and happens only with the user's approval.

## 8. Success Validation

- [ ] Herdr App environment and CLI syntax were verified; the `herdr` terminal CLI was not used; `leader.md` was read at session start and after any context loss.
- [ ] The Leader wrote no code; changes went to members.
- [ ] Decisions followed the three tiers: internal details were not reported, every new production component or reversible operational change was announced before being built with a deadline and its outcome recorded, and only tier-3 decisions became cards.
- [ ] At most three decisions were open for the user at once; each card said why it is the user's and whether it is easy or hard; no subject open in another space was asked again here; every decision or action was checked as still open before being asked, and re-asked only after a change, saying what changed.
- [ ] Every delivery reached the user with its five-line evidence dossier, lines (c)–(e) attested by an independent reviewer task.
- [ ] Member terms that reached the user more than once are in the `leader.md` Glossary; the Leader resumed in the user's language after any compaction.
- [ ] `scope-review` ran before the split and whenever the objective shifted; its conclusion reached the user.
- [ ] The split was presented as a visual plan, with one line per agent on what it adds to the system, and members were created through `herdr-handoff` only after the user approved it.
- [ ] `leader.md` follows the team-folder format, records intent only, and was updated exactly on the listed triggers.
- [ ] Member decisions reached the user as consolidated decision cards in system terms; members were observed before being messaged, and their state was checked before every report to the user and whenever one went silent.
- [ ] Tasks were started only within an approved mission under the `herdr-handoff` task rules, and each was ended and removed by its creator after its report.
- [ ] Member traffic updated the Leader silently; the user was written to about the work only on a trigger of When to Show It, in its layout, with the Panel's first line on what depends on the user and its blocks in fixed order; replies in conversation where nothing changed carried no Panel.
- [ ] Decisions the user made in a member's tab were recorded and never asked again.
- [ ] A user message arriving after changes they had not seen was answered first with up to three lines on what changed since their previous message.
- [ ] `leader.md` Pending Decisions lists every open decision and user-only action, so the cross-space inbox shows them.
- [ ] Adoption renamed the tab to `Leader` and moved it first, wrote `leader.md` with inferences marked, and notified members once.
- [ ] Concluded work is marked `concluded` and its folder was not deleted by the Leader.
