---
name: brainstorm
description: >-
  Gathers independent opinions on one open question from several models or
  harnesses (Claude Code, Codex, Cursor, Antigravity, or subagents): the
  same brief goes to each, each writes its own answer without seeing the
  others, and the caller compares them into convergences, divergences, and a
  recommendation. Runs the harness CLIs headless, or in Herdr App tabs the
  user can watch. Triggered when the user asks for a brainstorm, several
  opinions, other models' views, or a comparison of how different models
  would approach a question.
argument-hint: "[question] [harnesses or models to ask]"
---

# Brainstorm

Several models answering the same question alone give a wider spread of ideas than one model, and their agreement is a signal. Models that read each other converge on each other instead of on the facts, so participants never see one another's answers and never debate: this is the "several independent opinions" case of [`agentic-parallel-work`](../agentic-parallel-work/SKILL.md#3-choosing-how-to-run-something).

## 1. When It Pays

An open question with several defensible answers: a design direction, an approach, a name, a research angle. A question the code, the docs, or a command can answer is investigated instead. Each participant costs one full model run: ask three by default, in one round.

## 2. Write One Brief

Create a new folder in the operating system's temporary directory, outside any repository, and write `brief.md` there, the same file for every participant:

- The question, and what a good answer lets the user decide.
- Every fact a participant needs, since it has none of this conversation: what each handle means, absolute paths of the files to read, constraints, and what is already ruled out.
- The problem, never the caller's own leaning: a brief that hints at an answer gets that answer back.
- The answer's shape: recommendation first, then reasons, risks, confidence, and what would change its mind.
- Read-only: participants change no file outside their own answer.

## 3. Run Them in Parallel

Participants are the harnesses or models the user names; otherwise three of the installed ones. The caller may add its own answer only if it writes it before reading any other.

- **Herdr App active** (per [`herdr`](../herdr/SKILL.md#1-preconditions)): one collected run per participant in its own tab, per [`herdr`](../herdr/SKILL.md#3-open-a-tab-or-space-with-an-agent), each told to read the brief and write its answer to `<folder>/<participant>.md`.
- **Otherwise, headless**: all at once in the background, from the folder the question is about, standard input closed, each answer captured from standard output:

  | Harness | Command |
  | :--- | :--- |
  | Claude Code | `claude -p "<prompt>" > <folder>/claude.md` |
  | Codex | `codex exec --skip-git-repo-check --ephemeral -s read-only -o <folder>/codex.md "<prompt>"` |
  | Cursor | `cursor-agent -p --trust --output-format text "<prompt>" > <folder>/cursor.md` |
  | Antigravity | `agy -p "<prompt>" > <folder>/agy.md`, through `<user's shell> -ic` when `agy` is a shell alias |

  `<prompt>` is "Read <folder>/brief.md and answer it." Pass a model flag only when the user names a model.
- **No harness CLI**, or the user prefers it: one subagent per participant, briefed with the same file, answering once.

Wait for every run to end before reading any answer. A run that fails or produces nothing is reported with its error; the others still count. After the runs, check that the project's `git status` is unchanged and report any change to the user.

## 4. Synthesize

Read every answer, then write in the user's session language, bottom line first:

- **Recommendation**, with the reason, and the one condition that would change it.
- **Convergences**: points two or more participants reached on their own. Agreement is a signal, not proof: the models share much of their training.
- **Divergences**: who holds what, and what would settle each one: a fact to check (check it when cheap) or the user's choice (a decision card).
- **Unique ideas** worth keeping, each with its participant.
- **Participants**: who answered, who failed, and the folder with the answer files.

A claim that drives the recommendation is verified first, or marked as not verified. A second round runs only when the user asks: a new brief built from the open divergences, still without anyone's answers.

---

## Success Validation

- [ ] Every participant got the same brief, with the facts it needed and no hint of the caller's leaning.
- [ ] Participants ran in parallel, alone, and never saw or answered each other; none changed the project.
- [ ] Every answer was read only after all runs ended; failed runs were reported.
- [ ] The synthesis opened with a recommendation, then convergences, divergences with what settles each, and unique ideas, attributed by participant.
- [ ] Claims driving the recommendation were verified or marked as not verified.
- [ ] Herdr tabs were used only when the Herdr App was active, and collected runs were ended after their answers were read.
