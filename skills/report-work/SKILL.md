---
name: report-work
description: >-
  Understands the work the user is actively doing or has completed
  (conversation, commits, diffs, branches, PRs) and reports it as concise
  actionable tasks with titles and descriptions in the user's session language,
  optionally organized into contexts/epics, parent tasks, and relationships;
  also brings the status of existing tasks up to date with that work and helps
  organize them (regroup, link, merge duplicates, close stale ones).
  Tool-agnostic: updates the status of existing tasks (epics excepted) on its
  own and reports it; creates, edits, reorganizes, or changes an epic's status
  in a tracker (Jira, GitHub Issues, Linear, markdown file, etc.) only after
  the user approves it.
  Triggered when the user asks to report, log, document, or convert work into
  tickets/tasks, whether the entire scope or a slice of it, or to update,
  sync, or tidy the status and structure of tasks already created.
argument-hint: "[slice of work to report — by default, current session's work]"
---

# Report Work

Inverts the traditional task creation sequence: **first you do the work to understand what genuinely needs to be done, then you report the work as actionable tasks.** Tasks written after the work describe reality rather than speculation.

---

## 1. Core Principle

> The skill **understands and drafts**; the user **decides where and how to persist**, except the status of existing non-epic tasks, which the skill moves and reports.

- **Tool-agnostic**: produces a neutral, clean task representation. Zero tracker-specific fields, statuses, or rituals are assumed until instructed by the user.
- **Status moves on its own; everything else waits for approval**: the status of an existing task that is not an epic is updated as soon as the evidence supports it, and reported (task, from → to, evidence) so the user can move it back. Every creation, content edit, reorganization, and epic status change is shown as a change list (what, where, from → to) and written only after the user approves that list.
- **Reports evidence**: every task is grounded in real evidence (conversations, commits, diffs, PRs). Nothing is fabricated to pad out the backlog.

---

## 2. Workflow

### Step 1: Delimit the Slice
Determine **which work** to report:
1. **Explicit target in prompt** (e.g., "only authentication", "what I committed on this branch", "PR #42", the tasks [`coordinator`](../coordinator/SKILL.md) offered to report) → use it.
2. **No explicit target** → use work discussed and performed **in the current conversation**.
3. **Ambiguous** (session spans unrelated tasks, or zero work occurred in chat) → ask which slice to report, presenting identified options.

Declare the selected slice in one line before proceeding, and the mode: **report** new tasks, **update** existing ones, or both. Update applies when the user names existing tasks, an epic, or a tracker, or when the slice's evidence links issues (branch, commits, conversation).

### Step 2: Gather Evidence
Inspect strictly what is needed for the slice:
- **Conversation**: objectives, decisions made, obstacles resolved, outstanding items.
- **Git**: `git log <base>..HEAD --oneline`, `git diff <base>...HEAD --stat` and diffs of relevant files; involved branches.
- **PRs/issues** (if present): title, description, linked tickets (e.g. `gh pr view`).
- **Files** touched, when diffs alone do not convey intent.
- **Existing tasks** (update mode): read their current status, parent, and links from the tracker, through its tool skill when one exists. Reading is free; nothing is written here.

### Step 3: Understand the Work
Before drafting, clarify:
- What **underlying problem or goal** motivated the work?
- What **observable outcomes** were delivered (behaviors, capabilities, bug fixes)?
- What was **completed**, what is **in progress**, and what **remains pending**, discovered along the way?
- Do **natural groupings** exist (a broader milestone composed of multiple parts)?

### Step 4: Slice into Tasks
- **One task = one verifiable outcome** that makes standalone sense to whoever reads it in the issue tracker. Slice by **delivered capability**, not by file, layer, or commit.
- Minor commits for the same outcome merge into one task; a commit delivering two distinct capabilities splits into two tasks.
- **Unfinished work discovered during implementation** (technical debt, discovered bug, next step) becomes a task with *To Do* status: this is the primary value of doing work before reporting.
- Do not create tasks for mechanical hygiene without standalone value (linting, variable renames) unless requested. That belongs inside the task that motivated it.

### Step 5: Structure Hierarchy and Relationships (When Meaningful)
- **Context/Epic**: use when tasks serve a shared broader initiative. If the user indicates an existing epic, associate tasks with it rather than creating a new one.
- **Parent Task → Subtasks**: use when an outcome is too large for a single ticket, but parts are not distinct epics.
- **Task Relationships**: `blocks` / `is blocked by`, `relates to`, `duplicates`.
- Use **temporary keys** (`E1`, `T1`, `T1.1`) to express relationships before real IDs exist.
- Without natural grouping → flat list. **Never force hierarchy.**

### Step 6: Update and Organize Existing Tasks (Update Mode)
Compare each existing task with the evidence:
- **Status**: apply the status the evidence supports to each non-epic task, and propose it for an epic (a merged PR → done; an open PR → in review or in progress, per the tracker's own status names), never further than the evidence goes. Closing a task because its work is done is a status change; closing one the work made obsolete is organization.
- **Organization**: propose regrouping under an epic or parent, linking related or blocking tasks, merging duplicates, splitting a task that holds two outcomes, and closing tasks the work made obsolete, each with its reason.
- New work the existing tasks do not cover becomes a new task (Steps 4, 5, and 7).

### Step 7: Draft Tasks
Follow the Section 3 format and Section 4 writing guidelines.

### Step 8: Present and Await
Apply the status changes of existing non-epic tasks and report them; then present the new tasks and the rest of the change list, and **stop**. Conclude by asking for approval and, when the destination is not yet known, how the user wishes to save them: e.g., target tool, project key, existing epic, issue types, labels, assignee, sprint, or file export format.

User requested edits (merging, splitting, rewriting, shifting hierarchy) are applied and the updated set re-presented until approved.

### Step 9: Save per User Instruction
When destination instructions arrive:
- If a specific tool skill exists (e.g., Jira skill), load it and adhere to its rules.
- **Confirm prior to writing** anything beyond a non-epic status change: display what will be created or changed, where, and with what fields or from → to values, and write only what the user approved.
- Create in relational order (epic → parent → subtasks → links), replacing temporary keys with real tracking IDs.
- Present a final mapping table: `Temporary Key → Real ID / Link` for new tasks and, in update mode, `Change → Result (applied / failed, link)`.

---

## 3. Output Format

The layout is an example; its headings, labels, and status values are written in the user's session language (statuses as the tracker names them, once known).

```markdown
## Reported Slice
<one line: what was considered and evidence sources>

## E1 — <Context / Epic Title>              ← strictly if grouped
<1–2 sentences: shared objective of enclosed tasks>

### T1 — <Task Title>
**Status:** Completed | In Progress | To Do
**Parent:** E1        **Relations:** blocks T2   ← omit empty metadata

**Context:** <why this task exists — problem or goal, 1–2 sentences>

**Scope:** <what was (or will be) done in terms of outcome — 1–3 sentences or brief bullets>

**Acceptance Criteria:**
- <observable, verifiable behavior>
- <...>

**Notes:** <notable decisions, technical constraints, risks — optional>

#### T1.1 — <Subtask Title>                  ← strictly if subtask exists
...
```

In update mode, the change list:

```markdown
## Changes to Existing Tasks
| Task | Change | From → To | Evidence |
| :--- | :--- | :--- | :--- |
| PROJ-12 | status | In Progress → Done | PR #48 merged |
| PROJ-15 | parent | — → PROJ-10 | same export feature |
```

After tasks:

```markdown
## Summary
| Key | Title | Type | Status | Parent | Relations |

**How would you like to save these tasks?** (tool, project, existing epic, fields, format...)
```

---

## 4. Writing Guidelines

- **Language**: User session language by default; follow another language if explicitly requested. Keep technical terms, identifiers, and code in their original form.
- **Title**: imperative and specific, up to ~70 characters, describing the outcome (e.g., *"Enable Google OAuth login"*, *"Fix shipping cost calculation for multi-item carts"*). No type prefixes, tracking keys, or emojis.
- **Concise Description**: readers must grasp the task in under a minute. Cut filler that does not clarify why, what, or how to verify.
- **Outcomes, Not Mechanics**: describe capabilities and behaviors (Human Layer). Internal implementation minutiae (private helper names, directory paths) belong strictly when essential to task comprehension.
- **Verifiable Acceptance Criteria**: each criterion is independently checkable. For completed tasks, describe what was delivered; for to-do tasks, describe what defines "done".
- **[No local references](../ai-assisted-software-development/references/no-local-references.md)**. Public PR, commit, and issue links are encouraged.
- **Zero Fabrication**: if required information is absent from evidence (e.g. underlying business driver), ask or flag as pending rather than assuming.
- **Honest Status**: *Completed* strictly with concrete evidence of delivery; when in doubt, *In Progress*.

---

## 5. Success Validation

- [ ] Reported slice declared and matches request (or session context without explicit target).
- [ ] Every task features title, status, context, scope, and verifiable acceptance criteria backed by real evidence.
- [ ] Each task represents a single verifiable outcome; zero tasks per file or per commit.
- [ ] In-flight and outstanding discoveries captured as *To Do*.
- [ ] Hierarchy and relationships exist strictly where natural groupings occur; temporary keys resolve consistently.
- [ ] Existing tasks got only the status and organization changes their evidence supports; non-epic status changes were applied and reported, and nothing else was written before the user approved the exact change list.
