# Report Format

> **Central thesis**: the user should understand the state of the work at a glance, and know in its first line whether anything depends on them. Whenever that state changes for the user, the Leader shows the same **Panel**: a first line saying what depends on the user, then up to four short blocks in a fixed order (what's next, with the user's items first; what is blocked; what is in progress; the PRs). The full report does not repeat the Panel deeper: it is the Panel plus what changed and what appeared in the system since the user's last message, and the state of each delivery with its evidence. Never a dump of fields.

---

## 1. Writing Rules

- **The user's session language, end to end**, with standard technical terms in English (*pull request*, *merge*, *CI*, *draft*). Every fixed word in the templates below is a placeholder, not a literal: headings, block names, the first line, the closing line of empty blocks, and the words of the PR line (`agent`, `you`, `ok`, `pending`, `changes`, `conflict`, `merged`). In Portuguese, for example, the PR line reads `CI ok · agente ok · você pendente` and the closing line `Nada bloqueado · Nenhum PR`.
- **One line per item.** Every item, in the Panel and in the report, is one scannable line: a status emoji, a short identifier, and `·`-separated facts. Detail goes on at most one indented line below it, and only in the full report; the one exception is a PR's [what appears](#what-appears) line, which the Panel shows too.
- **System terms, not handles.** Apply [human-facing communication](../../ai-assisted-software-development/references/human-facing-communication.md): name each tab by its role, each task by what it delivers, each PR by what it changes. A PR number or task key appears only as a lookup key next to a short name.
- **Context for the directing architect.** Write the objective and every detail line per [Briefing a Change](../../ai-assisted-software-development/references/human-facing-communication.md#3-briefing-a-change): situate each part of the product before naming it, and say what changes for whom rather than which mechanism changed.
- **Human Layer first.** Per [`ai-assisted-software-development`](../../ai-assisted-software-development/SKILL.md), decisions, reviews the user owes, and production risks lead; test counts, commit lists, and file names stay out unless they block something.
- **Mark only what is uncertain.** An inferred fact gets *(inferred)* in italics; observed facts carry no marker. A missing review note reads "no record" (`—` in a PR line), never "not reviewed": its absence on this machine proves nothing.
- **Directing-architect test.** Each block must make sense to someone who knows the product but not its code, arriving from another tab two hours later.

## 2. Status Vocabulary

One emoji per line, at its start, always followed by words; the same emoji always means the same thing. The report uses the shared vocabulary of [human-facing communication](../../ai-assisted-software-development/references/human-facing-communication.md#4-emojis-as-signals), including its **who acts** markers, with these meanings in a space:

| Emoji | Meaning in the report |
| :---: | :--- |
| ✅ | Done, merged, ready to merge, or reviewed |
| ⏳ | In progress, including work waiting for another stream or task of the team to finish |
| ❓ | A decision the user must make: a choice, with options and a recommendation |
| 👀 | A review the user owes |
| ✋ | An action only the user can take, with nothing to choose: log in, validate in a browser, answer an agent's dialog, run a command the agent may not run. Listed only after an agent tried it, always with "only you because: <reason>" |
| ⚠️ | An attention point: a tier-2 notice (something new will appear in the system and the Leader proceeds at the stated time unless the user objects), or a surprise the user should notice |
| 🤖 | A next step an agent takes, without the user |
| ⏸️ | Blocked: waiting for something that neither the user nor any agent can do now |
| ❌ | Failing: a PR conflict or failing CI, an agent in error |

Markers specific to this format:

| Emoji | Meaning |
| :---: | :--- |
| 📋 | Pending, not started |
| ⚪ | Idle, or no information |
| 🏗️ | What a PR or a planned stream adds to the system (see [What appears](#what-appears)) |

### What "blocked" means

An item is **blocked** (⏸️) only when nobody in the conversation can move it now: neither the user nor any agent. Typical cases: a time that must pass (turn a service off one day after the migration), logs or metrics that must settle before reading them, another team that must fix something, a third party that must answer. Each blocked line says what it waits for and when or by whom it is expected to end.

Not blocked:

- **Waiting for the user** (a decision, a review, a login, a validation): it is a user item (❓, 👀, ✋) in **What's next**.
- **Waiting for another stream or task of the team to finish**: it is **in progress** (⏳); the dependency goes in its "where it stands" line.
- **A failing CI, a conflict, or an error an agent can fix**: it is in progress for that agent, or an agent's next step (🤖) when nobody has picked it up yet.
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

### What Appears

An open PR that adds something to the system carries one indented line below its PR line, in closed categories only, so the user sees new components and rule changes without reading code:

```text
  🏗️ <Creates>: <component> · <Permission>: <permission or secret> · <Rule>: <business rule change> · <Cost>: <recurring cost>
```

- Example: `🏗️ Creates: daily 2am schedule + internal purge route · Rule: expired sessions are deleted in batches` (the rule and the deletion were tier-3 decisions the user answered).
- Only the four categories: a **component** (job, schedule, table, queue, route, service), a **permission or secret**, a **business rule**, a **cost**. Internal details never appear here.
- Omit the line when the PR adds nothing in these categories, and omit empty categories. Each item was approved with the split, announced before it was built (tier 2), or decided by the user (tier 3: every business rule and anything that deletes or rewrites data); one that was not is a ⚠️ attention point in "What changed".

## 3. The Panel

The canonical state of the space. It is the first section of the full report, and the Leader shows it whenever something changes for the user (see [When to Show It](#when-to-show-it) and [`herdr-team-lead`](../../herdr-team-lead/SKILL.md)).

````markdown
### 🧭 <space name> · <Panel> · <time>

**❓ <2 items depend on you: 1 and 2>**   or   **✅ <Nothing depends on you now>**   (add "· <1 notice proceeds at 14:00 unless you object: 3>" when there is one)

<🔔 What changed: one sentence after an event, or up to three lines since the user's last message>

**➡️ <What's next>**
1. ❓ **<You> · <subject>:** <the decision> → <what it unblocks>. <Recommendation: option>.
2. 👀 **<You> · <subject>:** <the review> → <what it unblocks>.
3. ⚠️ **<You> · <notice>:** <what will appear> · <proceeds at time unless you object>.
4. 🤖 <step> · <which tab> · <after what>

**⏸️ <Blocked>**
- ⏸️ **<work>:** <what it waits for> · <when, or who outside the conversation resolves it>

**⏳ <In progress>**

| <Work> | <Who> | <Where it stands> |
| :--- | :--- | :--- |
| <what it delivers> | <tab role> | ⏳ <one line, including what it waits for inside the team> |

**PRs**
- ❌ <repo>#<n> · <short name> · <conflict> · CI <failing> · <agent> <ok> · <you> —
- 👀 <repo>#<n> · <short name> · CI <ok> · <agent> <ok> · <you> <pending>
  🏗️ <Creates>: <component> · <Rule>: <business rule change>
- ✅ <merged>: <repo>#<n>

<Nothing blocked · No PRs: one plain line, only when some block is empty>
````

- **First line, always.** The Panel opens with one bold line that answers "do I need to act?": how many items of **What's next** depend on the user and their numbers (❓), or that nothing depends on the user now (✅). It counts every ❓, 👀, and ✋ item and nothing else; open ⚠️ notices are named after the count with their deadline, since they need no answer.
- **What changed** names the event in system terms ("the billing tab finished the invoice API and opened its PR"), never the member's raw message. When the Panel answers the user's first message after changes they did not see, it lists up to three lines of what changed since their previous message instead (see "Since the user's last message" in [`herdr-team-lead`](../../herdr-team-lead/SKILL.md#2-role)). Omit it when nothing changed.
- **What's next** is one numbered queue, so the user can answer by number. It merges what depends on the user with the agents' next steps:
  - **The user's items first**, in bold and prefixed with the word for "you" in the user's language: decisions (❓), reviews the user owes (👀), actions only the user can take (✋, with why only the user can), and tier-2 notices (⚠️, with their deadline), ordered by what each unblocks, each with the Leader's recommendation. The full decision card or notice goes below the Panel when it is new or the user asks for it. After a gap, each item restates its subject in one sentence; never "decision 2" or "option B" alone.
  - **Then the agents' steps** (🤖): the ordered steps that move the objective forward after the current work, from `leader.md` Next Steps reconciled with what was observed, each with who does it and what it waits for. At most five agent steps; the full list lives in `leader.md`.
  - An item appears once: a step that waits for a user item names that item's number ("after 1") instead of repeating it.
- **Blocked** holds only work that nobody can move now, as defined in [What "blocked" means](#what-blocked-means). Work waiting for the user lives in **What's next**, and work waiting for the team lives in **In progress**, never here.
- **In progress** holds one row per active work stream, not per task: what it delivers, which tab runs it, and where it stands in one line, including any stream or task of the team it waits for. Finished work leaves the Panel; it shows up in the full report.
- **PRs** lists every PR of the space (opened from its agents' branches or referenced in `leader.md`), one [PR line](#pr-line) each, ordered ❌, 👀, ⏳, ✅, merged last, each open PR followed by its [what appears](#what-appears) line when it has one. It repeats PRs already cited above on purpose: it is the one place to read every PR's state.
- **Fixed order, no empty blocks.** The blocks always appear in this order. An empty block is omitted, heading included, and the Panel ends with one plain line, without emoji, naming every empty block in the same order ("Nothing next · Nothing blocked · Nothing in progress · No PRs"). When nothing is empty, that line does not appear. The first line is never omitted.

### When to Show It

This section is the one home of when the Leader writes to the user about the work, and how that message is laid out; other skills link here.

**Triggers.** The Leader writes to the user, with the Panel, only when one of these happened since the last Panel the user saw:

1. a decision for the user or a tier-2 notice opened;
2. a delivery is ready, with its [evidence dossier](../../ai-assisted-software-development/references/evidence-dossier.md);
3. a blocker appeared, including a member `blocked` or in `error`;
4. the scope changed;
5. the user wrote after changes they had not seen.

**Silence otherwise.** Progress and agent-to-agent exchanges with no consequence for the user (with members, tasks, or other spaces' Leaders, including a question the Leader answered itself) update the Leader silently; they reach the user in the next Panel's "What changed", never in a message of their own. A change the user made in the same exchange (an answer, an item dropped) counts only when it alters other blocks; the user already knows what they just said. When several events arrive close together, they make one message with one Panel.

**Layout.** One line on what just changed, in system terms; then the Panel; then, below it, the full decision card or notice for each item that is new.

Omit the Panel when the user is talking with the Leader about something (a question, an explanation, a decision card the user asked to have explained) and nothing changed: repeating an identical Panel only buries the answer. The full report always includes it.

Members never fill that gap with reports of their own: they write to their Leader, and to the user only in a tab where the user has written (the member contract of [`herdr-handoff`](../../herdr-handoff/SKILL.md#3-write-and-start-each-stream)).

## 4. The Full Report

The report answers "what changed for me and where is each delivery?". It is the Panel plus two blocks; it does not list tabs or repeat the Panel's items with more detail.

````markdown
## 🧭 <space name> · <report title> · <date and time>

**<Objective>:** <one or two sentences on what the team delivers and why> · <tracker>: <epic or main task> (<key>) <status>

<The Panel, Section 3, without its "What changed" line>

### <What changed since your last message>
- ✅ <event, in system terms: a delivery merged, a decision closed, a stream finished>
- ⚠️ <what surprised or diverged: a component that appeared without a notice, a plan that changed>
- 🏗️ <what appeared in the system: the what-appears items of PRs merged or opened since then>

### <Deliveries>
- ⏳ <what it delivers> · <task key, tracker status, or "no task"> · <repo>#<n> · <evidence> <n>/5
  <what it changes for whom> · <what is left before the user can accept it, or which evidence line is a no and why>

<Closing remarks: at most three bullets, optional>
````

## 5. Section Rules

- **Header**: objective from `leader.md` when present, otherwise inferred and marked; the tracker part shows the epic or main task and its real status, and is dropped when there is none.
- **Panel**: built per Section 3 from the same gather. Its "What changed" line is left out: the report's own block carries it.
- **What changed since your last message**: counted from the user's previous message in this conversation, not from the last Panel. At most eight lines, most consequential first: deliveries, decisions closed (including those the user made in a member's tab), notices that proceeded, blockers that appeared or ended, scope changes, and the [what appears](#what-appears) items of every PR opened or merged in that window. Progress with no consequence for the user stays out. When nothing changed, the block is one line saying so.
- **Deliveries**: one line per delivery (a PR, or a stream's result when it has no PR) in the tracker scope or referenced by `leader.md`, open first (in merge order when they depend on each other), merged last on one collapsed line. It carries the task reference and its real tracker status (or `⚪ status unavailable` when the tracker cannot be reached, or "no task" for untracked work), the PR, and how many of the five [evidence dossier](../../ai-assisted-software-development/references/evidence-dossier.md) lines are proven. The detail line says what the delivery changes for whom and what is left, naming any evidence line that is a no. When no task reference exists anywhere, close the block with `📋 No task registered in any tracker` and a suggestion to register the work with [`report-work`](../../report-work/SKILL.md).
- **Closing remarks** (optional, at most three bullets): divergences between `leader.md` and reality, and stale tracker statuses worth fixing.
