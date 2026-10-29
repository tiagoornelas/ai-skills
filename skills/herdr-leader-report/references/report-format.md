# Report Format

> **Central thesis**: the user should never have to rebuild the state of the work in their head. Every Leader message about the work carries the same **Panel**, four blocks in a fixed order (what needs the user, what is blocked, what is in progress, what comes next), and the full report is that Panel followed by the details. Only the content changes, never the shape. It is written for the user, in their language and in system terms, never as a dump of fields.

---

## 1. Writing Rules

- **The user's session language, end to end**, with standard technical terms in English (*pull request*, *merge*, *CI*, *draft*). Headings below are placeholders: write them in the user's language.
- **System terms, not handles.** Apply [human-facing communication](../../ai-assisted-software-development/references/human-facing-communication.md): name each tab by its role, each task by what it delivers, each PR by what it changes. A PR number or task key appears only as a lookup key in parentheses or as a short column value.
- **Context like a newcomer needs it.** Write the objective and every "what it changes" cell following the principles of [`explain-it`](../../explain-it/SKILL.md): business before code, project names defined on first use.
- **Human Layer first.** Per [`ai-assisted-software-development`](../../ai-assisted-software-development/SKILL.md), decisions, reviews the user owes, and production risks lead; test counts, commit lists, and file names stay out unless they block something.
- **Mark only what is uncertain.** An inferred fact gets *(inferred)* in italics; observed facts carry no marker. A missing review note reads "no record", never "not reviewed": its absence on this machine proves nothing.
- **Cold-read test.** Each block must make sense to someone arriving from another tab two hours later.

## 2. Status Vocabulary

One emoji per cell or item, always followed by words; the same emoji always means the same thing.

| Emoji | Meaning |
| :---: | :--- |
| ✅ | Done, delivered, mergeable, CI passing, or reviewed |
| ⏳ | In progress, or waiting on another piece of work |
| ❓ | Waiting for a decision from the user |
| 👀 | Waiting for the user's review |
| ❌ | Blocked or failing |
| ➡️ | Next step |
| 📅 | Scheduled for a known date |
| 📋 | Pending, not started |
| ⚪ | Idle, no CI, or no record |
| ⭐ | The Leader's tab |

## 3. The Panel

The canonical state of the workspace. It is the first section of the full report, and the Leader repeats it in every message about the work (see [`herdr-team-lead`](../../herdr-team-lead/SKILL.md)).

````markdown
### 🧭 <workspace label> · <Panel> · <time>

<🔔 What just changed: one sentence, only when the Panel follows an event>

**❓ <Needs you>**
1. ❓ **<subject>:** <the decision or review needed> → <what it unblocks>. <Recommendation: option>.

**❌ <Blocked>**
- ❌ **<work>:** <what blocks it> · <who or what unblocks it>

**⏳ <In progress>**

| <Work> | <Who> | <Where it stands> |
| :--- | :--- | :--- |
| <what it delivers> | <tab role> | ⏳ <one line> |

**➡️ <Next steps>**
1. ➡️ <step> · <who> · <after what>
````

- **Always the four blocks, always in this order.** An empty block stays, with one line saying so ("nothing", "no blocks"): a fixed shape is what makes the Panel scannable.
- **Needs you** holds every pending decision (❓), review the user owes (👀), and scheduled action that needs the user (📅), numbered and ordered by what each unblocks, so the user can answer by number. One line each with the Leader's recommendation; the full decision card goes below the Panel when the decision is new or the user asks for it.
- **Blocked** holds work that cannot advance because of something other than the user (a failing CI, another stream, an external dependency). Work blocked by the user lives in **Needs you** only, never in both.
- **In progress** holds one row per active work stream, not per task: what it delivers, which tab runs it, and where it stands in one line. Finished work leaves the Panel; it shows up in the full report's tables.
- **Next steps** comes from `leader.md` Next Steps reconciled with what was observed: the ordered steps that move the objective forward after the current work, each with who does it and what it waits for. At most five; the full list lives in `leader.md`.
- **What just changed** names the event in system terms ("the billing tab finished the invoice API and opened its PR"), never the member's raw message.

## 4. The Full Report

````markdown
## 🧭 <workspace label> · <report title> · <date and time>

**<Objective>:** <one or two sentences on what the team delivers and why>. <Tracker>: *<epic or main task title>* (<key>) · <status emoji and words>.

<The Panel, Section 3, as section 1>

| <Tasks> | <PRs> | <Tabs> |
| :--- | :--- | :--- |
| ✅ <n> done · ⏳ <n> in progress · 📋 <n> pending | <n> open (<n> draft) · <n> merged | <n> agents: <short breakdown by state> |

### 2 · <Tabs>

| # | <Tab> | <State> | <What it is doing or waiting for> |
| :-: | :--- | :--- | :--- |
| 1 | ⭐ <Leader tab> | <emoji words> | <one line> |

### 3 · <Tasks>

| <State> | <Task (tracker)> | <Where the work is> | <Next step> |
| :---: | :--- | :--- | :--- |

### 4 · <PRs>

**<Merge order>**

```text
<Unicode box-drawing dependency diagram, no emojis>
```

| PR | <What it changes> | Merge | CI | <Reviewed by the agent> | <Your review> |
| :--- | :--- | :---: | :---: | :---: | :---: |
````

## 5. Section Rules

- **Header**: objective from `leader.md` when present, otherwise inferred and marked; the tracker line shows the epic or main task and its real status.
- **Panel**: built per Section 3 from the facts of Sections 2–4 of the same report; omit "What just changed". The counts table below it comes from the same sections.
- **Tabs**: one row per tab in tab order, Leader marked ⭐; the state combines the Herdr agent status with what the agent is waiting for (an agent that finished its delivery is ✅, not ⚪).
- **Tasks**: one row per task in the tracker scope (the epic's children, or the tasks referenced by `leader.md`), pending ones last. "Next step" states what actually moves it forward, which often differs from the tracker status; when it does, the next step wins and the gap is noted in the closing remarks.
  - **Untracked work**: a tab or PR linked to no task gets a final row marked ⚪ "no task", naming the work it covers.
  - **No task at all**: when no task reference was found anywhere, replace the table with one line, `📋 No task registered in any tracker`, and suggest registering the work with [`report-work`](../../report-work/SKILL.md); the counts table's Tasks cell reads "none registered".
  - A task whose tracker could not be reached is not untracked: it keeps its row with its reference and ⚪ "status unavailable".
- **PRs**: the merge order diagram appears when PRs depend on each other; omit it otherwise. One row per PR, prefixed by its repository role ("Backend #71"), `· draft` when applicable; columns use the vocabulary above.
- **Closing remarks** (optional, at most three bullets): divergences between `leader.md` and reality, and stale tracker statuses worth fixing.
