---
name: automate-me
description: >-
  Turns how the user actually works into a personal mode skill
  (<handle>-mode) that agents follow: mines the user's recent agent sessions
  for recurring preferences and corrections, asks a few structured questions
  for what the history does not show, clusters the signals into short
  operational sections, and drafts or updates the skill with the user until
  it reads like them. Runs only when the user invokes /automate-me, to create,
  update, or refresh their mode skill.
disable-model-invocation: true
---

# Automate Me

The output is one `<handle>-mode` skill (`jay-mode`, `priya-mode`) holding the user's own working conventions. It builds on the skills and global instructions the user already has and never restates them: a mode skill holds only what is specific to this user and not written anywhere else.

## 0. Check for an Existing Mode Skill

The handle is the user's first name or chosen identifier: ask once when the conversation does not show it. Look for a `*-mode/SKILL.md` matching the user's handle in the harness skills directories and in the repository the user keeps their skills in (the target of the installed skill symlinks, `readlink -f`). If one exists, update it unless the user asked to start fresh; in update mode:

- Step 1 mines only sessions after the skill's last edit (`git log -1 --format=%cI -- <path>`, or the file's modification time outside git).
- Step 2 asks what changed or is missing, not what to capture from zero.
- Step 4 edits the file where it is: keep sections the new evidence does not contradict, revise those it does, and add a section only for a genuinely new rule.

## 1. Mine the History

- Read only the current project's sessions, in the folder where the harness keeps transcripts (the location table of [`reflect`](../reflect/SKILL.md#1-locate-the-transcript)); never cross into other projects, whose sessions may hold private work. A mode built from one project reflects that project: suggest running it from the user's main one.
- Split the last two to four weeks into three slices and send one read-only subagent per slice, in one turn, per [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md). Each returns a short list of patterns with pointers to the moments that show them.
- Signals worth hunting: response preferences (length, tone, format, "say it more simply" corrections); delegation habits (subagents, models, parallelism); verification posture (what "done" means, tests versus live runs); code and prose discipline; process conventions (worktrees, commits, pull requests, review); and meta preferences (fixing skills mid-task, proposing new ones).
- A pattern seen in two or more slices is strong; a lone signal is usually dropped. A preference stated once and contradicted elsewhere is noise.

## 2. Ask the User

History misses intent that has not come up yet. Ask one or two structured multiple-choice rounds of four to six options each, through the harness's question tool when it has one: first which areas matter most, then specifics in the chosen areas. Close with one open question for anything the options missed. Never a list of twenty questions.

## 3. Cluster

Group the signals into sections, using only those with a specific, non-default rule: response style, autonomy, understanding before changing, subagents, code and prose discipline, review and verification, process, and skills. "Communicate clearly" is not a section; "short paragraphs, tables when comparing options, bullets only for parallel items" is. Skip a section the user has nothing specific for.

## 4. Draft

Write the skill with [`prompt-engineering`](../prompt-engineering/SKILL.md), after reading the user's global instructions and memory so nothing they already say is repeated:

- **Placement** (new skills only): ask the user where it lives, recommending the repository they keep their skills in, else the harness's personal skills directory.
- **Frontmatter**: `name: <handle>-mode`; a `description` that triggers on the user's name, `/<handle>-mode`, and "work in their style", never on generic phrases such as "write code"; `disable-model-invocation: true` unless the user wants the mode on every turn.
- **Body**: operational imperatives addressed to "the user", referencing the skills and rules the user relies on by name instead of pasting them.

## 5. Iterate and Land

- Show the draft and revise with the user until it reads like them; expect several rounds, and cut each round.
- In a repository, land it as a delivery per [`agentic-parallel-work`](../agentic-parallel-work/SKILL.md), with [`commit`](../commit/SKILL.md) and [`pull-request`](../pull-request/SKILL.md). In a personal directory, write it once the user approves the draft. A new skill is linked into the harnesses by the user's install step (for this repository, `./scripts/setup-global.sh`).
- Judge it with the user ("does it read like you? what is missing?"), not with a benchmark: a mode skill is subjective.

Not for a task-specific skill or one narrow workflow ("how I write commit messages"): that is a regular skill, written with `prompt-engineering` and no mining.

---

## Success Validation

- [ ] Only the current project's sessions were mined, in parallel slices, and only patterns seen in two or more slices or confirmed by the user were kept.
- [ ] The user answered at most two structured rounds and one open question.
- [ ] Every section holds a specific, non-default rule; nothing restates the global instructions, memory, or another skill.
- [ ] The skill was written with `prompt-engineering`, triggers on the user's handle, and is manual unless the user asked otherwise.
- [ ] The user chose where it lives and approved the draft before it was written or delivered.
- [ ] An existing mode skill was updated in place, keeping the sections new evidence did not contradict.
