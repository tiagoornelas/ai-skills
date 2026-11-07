---
name: automate-me
description: >-
  Turns how the user actually works into skill changes agents follow: mines
  the user's recent agent sessions for recurring preferences and corrections,
  asks a few structured questions for what the history does not show,
  clusters the signals into specific rules, and proposes where each belongs,
  an edit to an existing skill or a new skill the user names, writing nothing
  until the user approves. Runs only when the user invokes /automate-me.
disable-model-invocation: true
---

# Automate Me

The output is a proposal, not a file: each specific way the user works that no skill, global instruction, or memory states yet, with where it should live. Nothing is created or edited until the user approves it; a proposal may edit existing skills, create new ones, or end with nothing to change.

## 0. Read What Already Exists

Read the user's global instructions, memory, and the descriptions of the skills installed in the harness skills directories, plus the repository the user keeps their skills in (the target of the installed skill symlinks, `readlink -f`). Before routing a rule in step 3, read in full, references included, every skill it might belong to. A rule already written anywhere is never proposed again. When the user asks to refresh a skill an earlier run produced, step 1 mines only sessions after that skill's last edit (`git log -1 --format=%cI -- <path>`, or the file's modification time outside git), and step 2 asks what changed rather than what to capture from zero.

## 1. Mine the History

- Read only the current project's sessions, in the folder where the harness keeps transcripts (the location table of [`reflect`](../reflect/SKILL.md#1-locate-the-transcript)); never cross into other projects, whose sessions may hold private work. Sessions from one project reflect that project: suggest running from the user's main one.
- Split the last two to four weeks into three slices and send one read-only subagent per slice, in one turn, per [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md). Each returns a short list of patterns with pointers to the moments that show them.
- Signals worth hunting: response preferences (length, tone, format, "say it more simply" corrections); delegation habits (subagents, models, parallelism); verification posture (what "done" means, tests versus live runs); code and prose discipline; process conventions (worktrees, commits, pull requests, review); and meta preferences (fixing skills mid-task, proposing new ones).
- A pattern seen in two or more slices is strong; a lone signal is usually dropped. A preference stated once and contradicted elsewhere is noise.

## 2. Ask the User

History misses intent that has not come up yet. Ask one or two structured multiple-choice rounds of four to six options each, through the harness's question tool when it has one: first which areas matter most, then specifics in the chosen areas. Close with one open question for anything the options missed. Never a list of twenty questions.

## 3. Cluster and Route

Group the signals into rules, keeping only those that are specific and non-default: "communicate clearly" is not a rule; "short paragraphs, tables when comparing options, bullets only for parallel items" is. Route each rule:

- **An existing skill** when the rule refines what that skill already governs (a commit preference goes to the commit skill).
- **The global instructions** when the rule must hold in every session (response style, reporting), since a skill acts only when it runs.
- **A new skill** for each coherent group of rules nothing else covers; a stray rule with no home is listed as such, not forced into a skill.

## 4. Propose and Decide

Present the proposal in the user's language, one row per rule: the rule, the evidence behind it (slices or the user's answer), and its destination. For each existing file, show the edit, drafted with [`prompt-engineering`](../prompt-engineering/SKILL.md) (rewrite its governing text before adding). For a new skill, show its draft, where it would live (recommending the repository the user keeps their skills in), and two or three name suggestions drawn from what it does; the user picks one or names it freely. Never derive a name from a pattern such as the user's handle. Revise with the user until each row reads like them ("does it read like you? what is missing?"); the user may approve, redirect, or drop any row. When no rule survives step 3, say so and stop.

## 5. Write and Land

- Write only the approved rows, as approved. A new skill references the skills and rules the user relies on by name instead of pasting them, and is manual (`disable-model-invocation: true`) unless the user wants it automatic.
- In a repository, land it as a delivery per [`agentic-parallel-work`](../agentic-parallel-work/SKILL.md), with [`commit`](../commit/SKILL.md) and [`pull-request`](../pull-request/SKILL.md); in a personal directory, write it once the user approves. A new skill is linked into the harnesses by the user's install step (for this repository, `./scripts/setup-global.sh`).

Not for one narrow workflow the user already knows they want ("how I write commit messages"): that is a direct edit or a regular skill, written with `prompt-engineering` and no mining.

---

## Success Validation

- [ ] Only the current project's sessions were mined, in parallel slices, and only patterns seen in two or more slices or confirmed by the user were kept.
- [ ] The user answered at most two structured rounds and one open question.
- [ ] Every proposed rule is specific and non-default, and none restates the global instructions, memory, or an installed skill.
- [ ] Each rule was routed to an existing skill, the global instructions, or a coherent new skill, and a new skill's name was chosen by the user from suggestions or freely, never from a template.
- [ ] Every edit and new skill was drafted with `prompt-engineering` and shown, with its location, before anything was written.
- [ ] Only rows the user approved were written, and in a repository they landed as a delivery.
