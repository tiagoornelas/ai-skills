---
name: herdr-scope-review
description: >-
  Applies scope-review across every active Herdr App space the user leads,
  from any tab: collects the fronts (spaces with their leader.md, or with
  gaps when it is missing), gives each the three scope-review answers (worth
  doing, what first, what not to do) with a do, reduce, postpone, or stop
  verdict, and ends with one queue, ordered by impact, of everything that
  depends on the user now (pending decisions, notices, user-only actions,
  agents blocked or in error, PRs awaiting their review), one owner per
  subject. Quick by default; "review priorities" goes deep. Read-only: it
  recommends and the user decides. Built for the Herdr App (herdr-app + hc),
  not the Herdr terminal multiplexer (`herdr` CLI). Triggered strictly when
  the user asks to prioritize, review the scope of, or see what depends on
  them across their Herdr spaces.
disable-model-invocation: true
argument-hint: "[space name to focus, or 'review priorities']"
---

# Herdr Scope Review

The user leads several Herdr App spaces at once; each Leader sees only its own. This skill collects them and applies [`scope-review`](../scope-review/SKILL.md) across them, with no criteria of its own, then shows where anyone needs the user now. Acting happens in each space, with its Leader.

> **Herdr App only.** It reads `herdr-app` (spaces, tabs) and `hc` (terminals and agents) of this machine, never the `herdr` CLI of the Herdr terminal multiplexer, `--on`, or `--machine`. Load `hc --skill` and `herdr-app --skill` unless already in context.

## 1. Rules

- Require `hc` and `herdr-app` on `PATH`; otherwise report that the session is outside the Herdr App and stop.
- **Read only.** Never send a message, answer a dialog, rename a tab, or write a file, `leader.md` included. A stale or wrong record is reported; fixing it is that space's Leader's job.
- **It recommends; the user decides** every stop, reduction, postponement, or merge of fronts.

## 2. Collect

- **Fronts**: every space in `herdr-app ls` with agents, matched to its team folder `~/.herdr-teams/<space-id>/` ([team-folder.md](../herdr-team-lead/references/team-folder.md)) by id, or by the `Space:` name in a `leader.md` after a rename. A space without `leader.md` is still a front, shown with its gaps ("no leader.md: objective unknown"), from its tabs, branches, and PRs.
- **Teams whose space is gone**: an active `leader.md` with no live space is not a front, but its pending items stay in the queue, marked *space closed — reopen or conclude*. Concluded folders are counted once in the closing line.
- **Per front**: objective, tasks, and next steps from `leader.md`; pending items with their `opened` times; tab states (`hc ls --json`: `blocked` or `error`); each agent's branch and its PR (`gh pr list --head <branch> --json number,title,url,state,isDraft,statusCheckRollup`); the tracker priority of referenced tasks when reachable ("priority unavailable" otherwise).
- **Across spaces**: PRs awaiting the user's review (`gh search prs --review-requested=@me --state=open`) and the user's own open PRs (`gh search prs --author=@me --state=open`). Without `gh`, say the PR part was skipped.

## 3. Judge

- **Quick (default)**: for each front, the three [`scope-review`](../scope-review/SKILL.md#three-standing-questions) answers in one line and its verdict, from what was collected. Impact comes from the objective and tracker priority; anything else is marked *(inferred)*.
- **Deep ("review priorities", or a named space)**: run `scope-review` in full on the named front, or on up to three fronts with a concrete signal (stalled with no tab working and no commit in three days, overlapping another space, or much activity for little impact), in sub-agents when the harness allows, under [`herdr-handoff`](../herdr-handoff/SKILL.md#31-sub-agents)'s sub-agent rules, each briefed read-only.
- **Attention and impact**: when a front visibly absorbs the user's decisions while delivering little, or a high-impact front has none, say so in one qualitative line marked *(inferred)*. No counts.
- **What depends on the user**: one item per subject, under the [one owner per subject](../herdr-team-lead/references/team-folder.md#2-leadermd) rule; `↪` reference lines are never items. Order by the impact of the front it unblocks. Each item keeps its `opened` time, or its team's `Updated` with *(time inferred)*.

## 4. Write

In the user's session language, per [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md), situating each front in product terms. The layout is an example; the content is mandatory.

````markdown
## 🎯 <Scope across spaces> · <date and time>

**❓ <5 items depend on you in 3 spaces>**   or   **✅ <Nothing depends on you in any space>**   (add "· <1 notice proceeds at 14:00 unless you object>")

**<one-line conclusion: where the impact is, and the single most important cut or shift>**

### <Fronts by impact>
1. <space> · <what it delivers, for whom> · <impact> <(inferred)>
   <worth doing · first because … · can leave out …, losing …> → <do | reduce to X | postpone until Y | stop>

### <What depends on you now>
1. ❓ <decision, in system terms> · <space> · go to tab <Leader> · <recorded on date and time>
2. 👀 <repo>#<n> · <short name> · <space or "outside the spaces">
3. ✋ <agent role> is stopped at a dialog: <what it asks> · go to tab <tab name>
<+N more, in <spaces>: ask for the full queue>

<Your open PRs · spaces with nothing for you · concluded folders · skipped sources: one plain line each>
````

- **First line, always**: how many ❓, 👀, and ✋ items depend on the user and in how many spaces, or that nothing does; ⚠️ notices are named after the count with their deadline.
- The queue shows at most seven items, then "+N more"; every item names its space and the tab to open.

## 5. Success Validation

- [ ] Only the Herdr App of this machine was read; nothing was written, sent, answered, or renamed; sub-agents started were ended and removed.
- [ ] Every live space was a front, those without `leader.md` shown with their gaps; teams whose space is gone kept their pending items in the queue, marked space closed.
- [ ] Each front got the three `scope-review` answers and a do, reduce, postpone, or stop verdict, with inferences marked; deep review ran only on request.
- [ ] Attention versus impact, when noted, was one qualitative line marked inferred, with no counts.
- [ ] The output opened with what depends on the user; the queue held one item per subject, ordered by impact, at most seven then "+N more", each with space, tab, and recorded time.
- [ ] Everything was in the user's language, as recommendations; the user decides.
