# Report Format

> **Central thesis**: the user should understand the state of the work at a glance, and know in its first line whether anything depends on them. Whenever that state changes, the Leader shows the same **Panel**: a first line saying what depends on the user, then up to four short blocks in a fixed order (what's next, with the user's items first; what is blocked; what is in progress; the PRs). The full report is that same Panel followed by the same kind of one-line items for tabs, tasks, and PRs, each with one more line of detail. Same shapes, same order, more depth; never a dump of fields.

---

## 1. Writing Rules

- **The user's session language, end to end**, with standard technical terms in English (*pull request*, *merge*, *CI*, *draft*). Headings below are placeholders: write them in the user's language.
- **One line per item.** Every item, in the Panel and in the report, is one scannable line: a status emoji, a short identifier, and `·`-separated facts. Detail goes on at most one indented line below it, and only in the full report.
- **System terms, not handles.** Apply [human-facing communication](../../ai-assisted-software-development/references/human-facing-communication.md): name each tab by its role, each task by what it delivers, each PR by what it changes. A PR number or task key appears only as a lookup key next to a short name.
- **Context for the directing architect.** Write the objective and every detail line per [Briefing a Change](../../ai-assisted-software-development/references/human-facing-communication.md#3-briefing-a-change): situate each part of the product before naming it, and say what changes for whom rather than which mechanism changed.
- **Human Layer first.** Per [`ai-assisted-software-development`](../../ai-assisted-software-development/SKILL.md), decisions, reviews the user owes, and production risks lead; test counts, commit lists, and file names stay out unless they block something.
- **Mark only what is uncertain.** An inferred fact gets *(inferred)* in italics; observed facts carry no marker. A missing review note reads "no record" (`—` in a PR line), never "not reviewed": its absence on this machine proves nothing.
- **Directing-architect test.** Each block must make sense to someone who knows the product but not its code, arriving from another tab two hours later.

## 2. Status Vocabulary

One emoji per line, at its start, always followed by words; the same emoji always means the same thing.

| Emoji | Meaning |
| :---: | :--- |
| ✅ | Done, merged, ready to merge, or reviewed |
| ⏳ | In progress, including work waiting for another stream or task of the team to finish |
| ❓ | A decision the user must make |
| 👀 | A review the user owes |
| ✋ | An action only the user can take: log in, validate in a browser, answer an agent's dialog, run a command the agent may not run |
| ⏸️ | Blocked: waiting for something that neither the user nor any agent can do now |
| ❌ | Failing: a PR conflict or failing CI, an agent in error |
| ➡️ | A next step for an agent |
| 📋 | Pending, not started |
| ⚪ | Idle, or no information |
| ⭐ | The Leader's tab |

### What "blocked" means

An item is **blocked** (⏸️) only when nobody in the conversation can move it now: neither the user nor any agent. Typical cases: a time that must pass (turn a service off one day after the migration), logs or metrics that must settle before reading them, another team that must fix something, a third party that must answer. Each blocked line says what it waits for and when or by whom it is expected to end.

Not blocked:

- **Waiting for the user** (a decision, a review, a login, a validation): it is a user item (❓, 👀, ✋) in **What's next**.
- **Waiting for another stream or task of the team to finish**: it is **in progress** (⏳); the dependency goes in its "where it stands" line.
- **A failing CI, a conflict, or an error an agent can fix**: it is in progress for that agent, or a next step (➡️) when nobody has picked it up yet.
- **An agent stopped at a dialog** (herdr-core state `blocked`): only the user can answer it, so it is a user action (✋).

### PR Line

Every PR, in the Panel and in the report, is written the same way:

```text
<emoji> <repo>#<number> · <short name> · [draft · ][conflict · ]CI <state> · agent <state> · you <state>
```

- **`<repo>`** is the repository name without its owner (`calculojuridico-web#212`). **`<short name>`** is two to four words naming what the PR changes ("invoice API", "billing screen").
- **`draft`** and **`conflict`** appear only when true.
- **CI**: `ok`, `failing`, `running`, or `—` (no checks).
- **agent** (the agent's self-review note on the PR head): `ok`, or `—` for no record.
- **you** (the user's review note): `ok` (approved), `changes` (changes requested), `pending` (no note yet and the PR is ready for the user: not a draft, CI ok, agent ok), or `—` for no record.
- **Leading emoji**, the worst that applies: ❌ conflict or CI failing · 👀 the user owes the review · ⏳ draft, CI running, or agent review missing · ✅ ready to merge.
- Merged PRs collapse into one final line: `✅ merged: <repo>#<n>, <repo>#<n>`. Closed, unmerged PRs are left out.

## 3. The Panel

The canonical state of the space. It is the first section of the full report, and the Leader shows it whenever that state changes (see [When to Show It](#when-to-show-it) and [`herdr-team-lead`](../../herdr-team-lead/SKILL.md)).

````markdown
### 🧭 <space name> · <Panel> · <time>

**❓ <2 items depend on you: 1 and 2>**   or   **✅ <Nothing depends on you now>**

<🔔 What changed: one sentence after an event, or up to three lines since the user's last message>

**➡️ <What's next>**
1. ❓ **<You> · <subject>:** <the decision> → <what it unblocks>. <Recommendation: option>.
2. 👀 **<You> · <subject>:** <the review> → <what it unblocks>.
3. ➡️ <step> · <who> · <after what>

**⏸️ <Blocked>**
- ⏸️ **<work>:** <what it waits for> · <when, or who outside the conversation resolves it>

**⏳ <In progress>**

| <Work> | <Who> | <Where it stands> |
| :--- | :--- | :--- |
| <what it delivers> | <tab role> | ⏳ <one line, including what it waits for inside the team> |

**PRs**
- ❌ <repo>#<n> · <short name> · conflict · CI failing · agent ok · you —
- 👀 <repo>#<n> · <short name> · CI ok · agent ok · you pending
- ✅ merged: <repo>#<n>

<Nothing blocked · No PRs: one plain line, only when some block is empty>
````

- **First line, always.** The Panel opens with one bold line that answers "do I need to act?": how many items of **What's next** depend on the user and their numbers (❓), or that nothing depends on the user now (✅). It counts every ❓, 👀, and ✋ item and nothing else.
- **What changed** names the event in system terms ("the billing tab finished the invoice API and opened its PR"), never the member's raw message. When the Panel answers the user's first message after changes they did not see, it lists up to three lines of what changed since their previous message instead (see "Since the user's last message" in [`herdr-team-lead`](../../herdr-team-lead/SKILL.md#2-role)). Omit it when nothing changed.
- **What's next** is one numbered queue, so the user can answer by number. It merges what depends on the user with the agents' next steps:
  - **The user's items first**, in bold and prefixed with the word for "you" in the user's language: decisions (❓), reviews the user owes (👀), and actions only the user can take (✋), ordered by what each unblocks, each with the Leader's recommendation. The full decision card goes below the Panel when the decision is new or the user asks for it.
  - **Then the agents' steps** (➡️): the ordered steps that move the objective forward after the current work, from `leader.md` Next Steps reconciled with what was observed, each with who does it and what it waits for. At most five agent steps; the full list lives in `leader.md`.
  - An item appears once: a step that waits for a user item names that item's number ("after 1") instead of repeating it.
- **Blocked** holds only work that nobody can move now, as defined in [What "blocked" means](#what-blocked-means). Work waiting for the user lives in **What's next**, and work waiting for the team lives in **In progress**, never here.
- **In progress** holds one row per active work stream, not per task: what it delivers, which tab runs it, and where it stands in one line, including any stream or task of the team it waits for. Finished work leaves the Panel; it shows up in the full report.
- **PRs** lists every PR of the space (opened from its agents' branches or referenced in `leader.md`), one [PR line](#pr-line) each, ordered ❌, 👀, ⏳, ✅, merged last. It repeats PRs already cited above on purpose: it is the one place to read every PR's state.
- **Fixed order, no empty blocks.** The blocks always appear in this order. An empty block is omitted, heading included, and the Panel ends with one plain line, without emoji, naming every empty block in the same order ("Nothing next · Nothing blocked · Nothing in progress · No PRs"). When nothing is empty, that line does not appear. The first line is never omitted.

### When to Show It

Show the Panel when the state of the work changed since the last Panel the user saw: a member message, a change the Leader observed (a PR, a CI run, a tab's state), or a decision, blocker, work stream, next step, or PR that opened or closed. A change the user made in the same exchange (an answer, an item dropped) counts only when it alters other blocks; the user already knows what they just said.

Omit the Panel when the user is talking with the Leader about something (a question, an explanation, a decision card the user asked to have explained) and nothing changed: repeating an identical Panel only buries the answer. The full report always includes it.

## 4. The Full Report

The report is the Panel plus three detail blocks built from the same one-line items. Nothing else: no counts table, no wide tables.

````markdown
## 🧭 <space name> · <report title> · <date and time>

**<Objective>:** <one or two sentences on what the team delivers and why> · <tracker>: <epic or main task> (<key>) <status>

<The Panel, Section 3>

### <Tabs>
- ⭐ <Leader tab> · <state> · <what it is doing or waiting for>
- ⏳ <tab role> · <state> · <what it is doing or waiting for>

### <Tasks>
- ⏳ <key> · <what it delivers> · <tracker status>
  ➡️ <what actually moves it forward>

### <PRs>
```text
<merge order: Unicode box-drawing diagram, no emojis, only when PRs depend on each other>
```
- ❌ <repo>#<n> · <short name> · conflict · CI failing · agent ok · you —
  <what it changes for whom> · <what blocks it, or what is left before merging>

<Closing remarks: at most three bullets, optional>
````

## 5. Section Rules

- **Header**: objective from `leader.md` when present, otherwise inferred and marked; the tracker part shows the epic or main task and its real status, and is dropped when there is none.
- **Panel**: built per Section 3 from the facts of the detail blocks of the same report. Keep "What changed" only when the report is the user's first look at changes since their last message.
- **Tabs**: one line per tab in tab order, Leader marked ⭐; the state combines the herdr-core agent status with what the agent is waiting for (an agent that finished its delivery is ✅, not ⚪; an agent stopped at a dialog is ✋). No detail line.
- **Tasks**: one line per task in the tracker scope (the epic's children, or the tasks referenced by `leader.md`), done first, pending (📋) last. The detail line states what actually moves the task forward, which often differs from the tracker status; when it does, the next step wins and the gap is noted in the closing remarks. Done tasks get no detail line.
  - **Untracked work**: a tab or PR linked to no task gets a final line `⚪ no task · <the work it covers>`.
  - **No task at all**: when no task reference was found anywhere, the block is one line, `📋 No task registered in any tracker`, with a suggestion to register the work with [`report-work`](../../report-work/SKILL.md).
  - A task whose tracker could not be reached is not untracked: it keeps its line with its reference and `⚪ status unavailable`.
- **PRs**: the merge order diagram appears only when PRs depend on each other. Then the same [PR lines](#pr-line) as the Panel, in merge order when there is one, each open PR with one detail line: what it changes for whom, and what blocks it or is left before merging. Merged PRs stay on one collapsed line.
- **Closing remarks** (optional, at most three bullets): divergences between `leader.md` and reality, and stale tracker statuses worth fixing.
