# Report Format

> **Central thesis**: the report is predictable. Every run has the same four sections in the same order, so the user knows where to look; only the content changes. It is written for the user, in their language and in system terms, never as a dump of fields.

---

## 1. Writing Rules

- **The user's session language, end to end**, with standard technical terms in English (*pull request*, *merge*, *CI*, *draft*). Headings below are placeholders: write them in the user's language.
- **System terms, not handles.** Apply [human-facing communication](../../ai-assisted-software-development/references/human-facing-communication.md): name each tab by its role, each task by what it delivers, each PR by what it changes. A PR number or task key appears only as a lookup key in parentheses or as a short column value.
- **Context like a newcomer needs it.** Write the objective and every "what it changes" cell following the principles of [`explain-it`](../../explain-it/SKILL.md): business before code, project names defined on first use.
- **Human Layer first.** Per [`ai-assisted-software-development`](../../ai-assisted-software-development/SKILL.md), decisions, reviews the user owes, and production risks lead; test counts, commit lists, and file names stay out unless they block something.
- **Mark only what is uncertain.** An inferred fact gets *(inferred)* in italics; observed facts carry no marker. A missing review note reads "no record", never "not reviewed": its absence on this machine proves nothing.
- **Cold-read test.** Each section must make sense to someone arriving from another tab two hours later.

## 2. Status Vocabulary

One emoji per cell, always followed by words; the same emoji always means the same thing.

| Emoji | Meaning |
| :---: | :--- |
| ✅ | Done, delivered, mergeable, CI passing, or reviewed |
| ⏳ | In progress, or waiting on another piece of work |
| ❓ | Waiting for a decision from the user |
| 👀 | Waiting for the user's review |
| ❌ | Blocked or failing |
| 📅 | Scheduled for a known date |
| 📋 | Pending, not started |
| ⚪ | Idle, no CI, or no record |
| ⭐ | The Leader's tab |

## 3. Structure

````markdown
## 🧭 <workspace label> · <report title> · <date and time>

**<Objective>:** <one or two sentences on what the team delivers and why>. <Tracker>: *<epic or main task title>* (<key>) · <status emoji and words>.

### 1 · <Overview>

| <Tasks> | <PRs> | <Tabs> |
| :--- | :--- | :--- |
| ✅ <n> done · ⏳ <n> in progress · 📋 <n> pending | <n> open (<n> draft) · <n> merged | <n> agents: <short breakdown by state> |

**❓ <Needs you now>**
- <emoji> **<subject>:** <one sentence: what is needed from the user and what it unblocks>

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

## 4. Section Rules

- **Header**: objective from `leader.md` when present, otherwise inferred and marked; the tracker line shows the epic or main task and its real status.
- **Overview**: counts come from Sections 2–4 of the same report. **Needs you now** gathers, across all sections, every pending decision, review the user owes, blocked item, and scheduled action that needs the user, ordered by what each unblocks. When nothing needs the user, say so in one line.
- **Tabs**: one row per tab in tab order, Leader marked ⭐; the state combines the Herdr agent status with what the agent is waiting for (an agent that finished its delivery is ✅, not ⚪).
- **Tasks**: one row per task in the tracker scope (the epic's children, or the tasks referenced by `leader.md`), pending ones last. "Next step" states what actually moves it forward, which often differs from the tracker status; when it does, the next step wins and the gap is noted in the closing remarks.
  - **Untracked work**: a tab or PR linked to no task gets a final row marked ⚪ "no task", naming the work it covers.
  - **No task at all**: when no task reference was found anywhere, replace the table with one line, `📋 No task registered in any tracker`, and suggest registering the work with [`report-work`](../../report-work/SKILL.md); the Overview's Tasks cell reads "none registered".
  - A task whose tracker could not be reached is not untracked: it keeps its row with its reference and ⚪ "status unavailable".
- **PRs**: the merge order diagram appears when PRs depend on each other; omit it otherwise. One row per PR, prefixed by its repository role ("Backend #71"), `· draft` when applicable; columns use the vocabulary above.
- **Closing remarks** (optional, at most three bullets): divergences between `leader.md` and reality, and stale tracker statuses worth fixing.
