---
name: herdr-scope
description: >-
  Takes a critical look, on demand and from any Herdr App tab, at everything
  the user is leading across all active spaces and helps them prioritize: the
  fronts ordered by impact, each with a scope-review verdict (continue,
  reduce, stop, or merge with another space) and its justification; what
  need not be done (stalled, duplicated across spaces, maintenance cost above
  benefit); where the user's attention went compared with where the impact
  is, measured by the dated decisions recorded in each leader.md; and
  one queue, ordered by impact, of everything that depends on the user now
  (pending decisions, notices, user-only actions, agents blocked or in error,
  PRs awaiting their review, their own open PRs), one owner per subject.
  Read-only: it recommends and the user decides; it never writes a leader.md
  or messages an agent. Built for the Herdr App (herdr-app + hc), not the
  Herdr terminal multiplexer (`herdr` CLI). Triggered strictly when the user
  asks to prioritize, review the scope of, or see what depends on them across
  their Herdr spaces.
disable-model-invocation: true
argument-hint: "[space name to focus, optional]"
---

# Herdr Scope

The user leads several Herdr App spaces at once. Each Leader sees only its own space; this skill answers what none of them can: **"of everything I am leading, what has the most impact, what need not be done at all, is my attention where the impact is, and where does anyone need me now?"** It applies [`scope-review`](../scope-review/SKILL.md) across spaces and reads, lists, and recommends. Acting happens in each space, with its Leader.

> **Herdr App only.** This skill reads the Herdr App: `herdr-app` (window: spaces, tabs, panes) and `hc` (herdr-core: terminals and agents). It never uses the `herdr` CLI of the Herdr terminal multiplexer, which talks to a different session.

## 1. Preconditions

- Require `hc` and `herdr-app` on `PATH`. Otherwise report that the session is outside the Herdr App and stop. Use only this machine; never pass `--on` or `--machine`.
- Treat the installed CLIs as the syntax authority: load `hc --skill` and `herdr-app --skill` unless already in context, and parse state from JSON responses.
- **Read only.** Never send a message, answer a dialog, rename a tab, or write a file, `leader.md` included. When a record looks stale or wrong, report it; fixing it is that space's Leader's job.
- **It recommends; the user decides.** Every verdict is a recommendation in the [Human Layer](../ai-assisted-software-development/SKILL.md): stopping, reducing, or merging a front is the user's call.

## 2. Gather

A **front** is one active team: a team folder `~/.herdr-teams/<space-id>/` ([team-folder.md](../herdr-team-lead/references/team-folder.md)) whose `leader.md` says `State: active` and whose space exists in `herdr-app ls`, matched by the folder's space id or, when the space was renamed or recreated, by the `Space:` name in its `leader.md`. An active team whose space no longer exists is not a front, but its pending items still enter the queue, each marked *space closed — reopen or conclude*; it is never only a footer count. Concluded team folders without a live space are counted once in the closing line. A space without `leader.md` is not a front but still shows its blocked or errored agents in the queue.

Observe in parallel where the harness allows it; nothing here needs to ask an agent.

| Fact | Source |
| :--- | :--- |
| Spaces, tabs, and each terminal's status | `herdr-app ls`; `hc ls --json` (status `blocked` or `error`, with `where`) |
| Each front's objective, tasks, next steps | `leader.md`: Objective, Tasks and Issues, Next Steps |
| Each front's pending items and when they opened | `leader.md` Pending Decisions (`opened` times, `↪` reference lines) |
| The user's attention per front | `leader.md` Decisions & Rationale entries, by the date in each ([team-folder.md](../herdr-team-lead/references/team-folder.md#2-leadermd) requires an ISO prefix): count entries per day over the last seven days. Accept `YYYY-MM-DD`, `DD/MM/YYYY`, and `DD/MM` (year of the record's `Updated` line, else the current year); only entries with no date are counted apart as undated, never dated by guess |
| Tracker priority | the priority of each task referenced in Tasks and Issues, through whatever the harness reaches (a CLI such as `gh`, or a connected integration); unreachable reads "priority unavailable" |
| Stalled work | no tab `working` in the space, and no commit on its agents' branches and no `Updated` in the last three days |
| PRs per front | each agent's branch (`git -C <cwd> branch --show-current`) matched with `gh pr list --head <branch> --json number,title,url,state,isDraft,statusCheckRollup` |
| PRs awaiting the user's review | `gh search prs --review-requested=@me --state=open --json repository,number,title,url` |
| The user's open PRs | `gh search prs --author=@me --state=open --json repository,number,title,url,isDraft` |

When `gh` is missing or not authenticated, say the PR part was skipped; never guess PR states.

## 3. Judge

**Impact.** Rank fronts by what each delivers for the business: the `leader.md` objective, weighted by the tracker priority of its tasks when referenced. Any impact not backed by a tracker priority or an explicit statement in `leader.md` is an inference and is marked *(inferred)*.

**Shallow pass on every front.** For each front, a short `scope-review` judgment from what was gathered: marginal benefit of finishing it against its remaining cost and [maintenance commitment](../software-designing/references/maintenance-commitment.md), and one verdict: **continue**, **reduce** (to what smaller thing), **stop**, or **merge with** another space (which). Justify it in one line.

**Deep pass on at most three fronts.** Pick the up-to-three most suspicious: stalled, duplicated across spaces (overlapping objective, branches, or PRs), or receiving much attention for little impact. For each, run [`scope-review`](../scope-review/SKILL.md) in full, in parallel sub-agents when the harness allows ([subagent delegation](../ai-assisted-software-development/references/subagent-delegation.md)); brief each with the front's `leader.md`, its PRs, this section verbatim, and that it is read-only (no writes, no messages), and ask for the verdict, its justification, the lost value if cut, and the uncertainty. In a Herdr App session, a sub-agent follows the sub-agent rules of [`herdr-handoff`](../herdr-handoff/SKILL.md#31-sub-agents): its creator ends and removes it after its report.

**Attention vs. impact.** Compare each front's share of the user's recorded attention (dated decisions per day) with its impact rank, and show each front's undated count ("undated: N") when non-zero. Flag a front whose attention rank is two or more places above its impact rank, and a high-impact front with no recorded attention in the window. Attention measured from records misses conversation the Leader did not record: say so once.

**What depends on the user.** One subject, one item, under the [one owner per subject](../herdr-team-lead/references/team-folder.md#2-leadermd) rule (earliest `opened`, then space name), naming the other spaces that raised it; `↪` reference lines are never items. Order the queue by the impact of the front it unblocks, not by age. Each item keeps the time it was recorded (`opened`); a record without `opened` falls back to its team's `Updated` and says *(time inferred)*. When a team's `leader.md` was last updated more than a day ago, its items stay and add *(recorded <n> days ago, may be out of date)*.

## 4. Write the Output

Entirely in the user's session language, following [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md) and the status vocabulary of [panel-format.md](../herdr-team-lead/references/panel-format.md#2-status-vocabulary). Situate every front in product terms: the reader arrives from another space with none of its context. Fixed words below are placeholders to translate.

````markdown
## 🎯 <Scope across spaces> · <date and time>

**❓ <5 items depend on you in 3 spaces>**   or   **✅ <Nothing depends on you in any space>**   (add "· <1 notice proceeds at 14:00 unless you object>" when there is one)

**<one-line conclusion: where the impact is, and the single most important cut or shift>**

### <Fronts by impact>
1. <space name> · <what it delivers, for whom> · <impact: high | medium | low> <(inferred)>
   <verdict: continue | reduce to X | stop | merge with Y> — <justification> <· deep review>
2. …

### <What need not be done>
- 🟡 <space or part of it> · <stalled since date | duplicates Y | costs more to keep than it returns> → <recommendation>

### <Your attention vs. impact>
- ⚠️ <space>: <n decisions in 7 days> · impact rank <k> · <undated: N> → <what that suggests>
- ⚠️ <space>: impact rank 1 · no recorded attention in 7 days

### <What depends on you now>
1. ❓ <decision, in system terms> · <space> · go to tab <Leader> · <why yours> · <easy | hard> · <recorded on date and time>
   <or, for a team whose space is gone: · space closed — reopen or conclude>
2. 👀 <repo>#<n> · <short name> · <space or "outside the spaces">
3. ✋ <agent role> is stopped at a dialog: <what it asks> · go to tab <tab name>
4. ⚠️ <notice: what will appear> · <space> · <proceeds at time unless you object>
<+N more, in <spaces>: ask for the full queue>

<Your open PRs: repo#n short name (space), one plain line>
<Spaces with nothing for you · concluded team folders without a live space · skipped sources: one plain line>
````

- **First line, always**: how many numbered items depend on the user and in how many spaces, or that nothing does. It counts ❓, 👀, and ✋ items only; ⚠️ notices are named after the count, since they proceed without an answer.
- **Conclusion next**, one bold line.
- **Fronts**: every active front, highest impact first; at most two lines each; the deep-review ones say so.
- **What need not be done** lists only fronts or parts with a concrete signal (stalled, duplicated, cost above benefit); omit the block when none.
- **What depends on you now** is one numbered queue across spaces, ordered by impact, showing at most the top seven items followed by "+N more" with their spaces (the full queue on request); every item names the space and the tab to open; ✋ items say why only the user can; ⚠️ notices show their deadline. The user's own open PRs are context, not queue items, and a PR already listed as 👀 is not repeated.
- When the user named a space, judge only that front in depth but keep the queue across all spaces.

## 5. Success Validation

- [ ] Herdr App environment verified, without the `herdr` terminal CLI or `--on`; nothing was written, sent, answered, or renamed; sub-agents started were ended and removed.
- [ ] Fronts were exactly the active teams with a live space (matched by id, or by `leader.md` name after a rename); active teams whose space is gone had their pending items in the queue, marked space closed; every front got a shallow verdict (continue, reduce, stop, merge) with a justification, and at most three got a deep `scope-review`.
- [ ] Impact came from the `leader.md` objective and tracker priority; inferences were marked.
- [ ] What need not be done listed only fronts with a concrete signal.
- [ ] Attention was measured from dated `leader.md` Decisions & Rationale entries per day (ISO, `DD/MM/YYYY`, or `DD/MM`), truly undated entries were reported as "undated: N" and never guessed, compared with impact rank, and its blind spot was stated.
- [ ] The output opened with the line counting what depends on the user across spaces; the queue held one item per subject, ordered by impact, at most seven shown then "+N more", each with its recorded time (or *(time inferred)*), with space and tab for each; PRs awaiting review, blocked or errored agents, pending decisions, notices, and user-only actions were all read; skipped sources were named.
- [ ] Everything was in the user's language, recommendations only; the user decides.
