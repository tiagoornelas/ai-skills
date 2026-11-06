# Review Axes

> **Central thesis**: a deeper review, run only when the user asks for systematic Agent Layer review, a full multi-axis review, or selected axes. It adds evidence beside the [`human-review`](../../human-review/SKILL.md) guide and the [`provide-evidence`](../../provide-evidence/SKILL.md) proof, never repeats them, and keeps each axis separate so a pass on one never masks a failure on another.

---

## 1. The Axes

Up to five axes run as **parallel subagents**, after the guide's assessment, which stays the opening synthesis:

| Axis | Origin | Core Question |
| :--- | :--- | :--- |
| 🔧 **Quality and Rules** | `agent-self-review` phases 1–2 | Does code pass project tooling and follow documented repository rules? |
| ✅ **Behaviors and Tests** | `agent-self-review` phases 3–4 + the [Definition of Done legend](../../ai-assisted-software-development/references/human-facing-communication.md#definition-of-done-legend) | Does the change fulfill requirements, with each behavior verified by refactor-proof tests? |
| 🏗️ **Architecture and Contracts** | `human-review` + `software-designing` references | Are modules, boundaries, dependency direction, and contracts architecturally sound? |
| 🧹 **Code Quality** | `agent-self-review` phase 5 + `coding` references | Is newly added code below contracts clean, obvious, and maintainable? |
| 🗄️ **Database and Migrations** | `coding` references ([database-and-migrations.md](../../coding/references/database-and-migrations.md)) | Are queries efficient and schema migrations safe from table locks and downtime? |

When Axis 🔧 is requested and will run test and lint tooling, create an isolated worktree of the PR code **without altering the user's working tree**:

```bash
git fetch origin pull/<pr>/head:review/<pr>
git worktree add ../<repo>-review-<pr> review/<pr>
```

Pass the worktree path to subagents. Upon completing the review, clean it up (`git worktree remove`) and delete the local `review/<pr>` branch.

## 2. Locate the Specification (DoD)

In order: issues referenced in the PR body or commit messages (Jira, GitHub, Linear) → path provided by the user → PRD, blueprint, or ticket in `docs/` matching the branch or feature → ask the user.

Extract a **list of expected behaviors** (acceptance criteria). If no specification exists, state that explicitly in the report: Axis ✅ then evaluates test suite sanity and apparent scope. **Never invent a specification out of thin air from the diff.**

---

## 3. Identify Intended Architecture

Axis 🏗️ needs to know what the design *ought* to be; otherwise review degenerates into subjective personal preference. Check, in order:

1. an existing architectural blueprint, ADR, or design doc for this domain;
2. established patterns in surrounding code that this change should remain consistent with;
3. in the absence of both, general design principles in [`software-designing/references/`](../../software-designing/references/).

State which source was referenced. "Inconsistent with the module structure used throughout this package" is a vastly stronger finding than "I would have designed it differently".

---

## 4. Gather Repository Rules

Consolidate documentation on repository coding guidelines: repository `AGENTS.md`/`CLAUDE.md`, user global rules, files under `docs/rules/`, and `CODING_STANDARDS.md` or `CONTRIBUTING.md`. References from the [`coding`](../../coding/SKILL.md) skill are not repo rules: they serve Axis 🧹.

- **The repository prevails**: documented project rules always override general standards; if a rule endorses a pattern that general guidelines discourage, discard the finding.
- **Do not duplicate automated tooling**: ignore issues already flagged by linters and formatters; those surface through Phase 1.

---

## 5. Launch the Subagents in Parallel (Up to Five)

Send a single prompt launching subagents concurrently using the harness subagent tool (see [subagent-delegation.md](../../ai-assisted-software-development/references/subagent-delegation.md); in Claude Code, `Agent` with `general-purpose` type). In briefs below, `<skills>` represents the skills folder: replace with the absolute path before sending. Embed the [severity scale](../SKILL.md#3-severity) in each brief. Subagents never modify code.

**🔧 Quality and Rules**: pass diff command, commit list, worktree path, Section 4 rule sources, and severity scale. Brief:
> *"Apply phases 1 and 2 of `<skills>/agent-self-review/SKILL.md` to this PR, without fixing anything. (a) In the worktree, run linters, typecheckers, and tests; if unable to run, use `gh pr checks <pr>` and state that. Report strictly failures introduced or touched by the diff. (b) Report every diff location violating a documented project rule, citing file and rule. Do not report code smells or general design judgments: those belong to another axis. Cite `file:line` for all findings. Prefix each finding with its severity emoji (🔴/🟡/🟢). Max 400 words."*

**✅ Behaviors and Tests**: pass diff command, commit list, Section 2 behavior list, and severity scale, instructing to first read `<skills>/coding/references/testing.md`. Brief:
> *"Apply phases 3 and 4 of `<skills>/agent-self-review/SKILL.md` to this PR, without fixing anything. For each behavior, classify using the Definition of Done legend in `<skills>/ai-assisted-software-development/references/human-facing-communication.md`: ✅, 🔎, 👤 (state manual validation steps), or 🚨. Report findings: (a) implemented behavior that is testable but lacks adequate tests (🟡); (b) behavior in diff that was not requested (scope creep); (c) tests in diff violating `testing.md` (coupled to text, markup, or internals; exposed private symbols; mocked internal collaborators), with concrete failure scenarios. Cite requirement and `file:line`. Prefix each finding with severity emoji (🔴/🟡/🟢). Max 400 words."*

**🏗️ Architecture and Contracts**: pass diff command, commit list, Section 3 intended architecture, and severity scale, instructing to first read `<skills>/ai-assisted-software-development/references/change-card.md` and relevant files in `<skills>/software-designing/references/`. Brief:
> *"Review the architectural design of the diff, not syntax or business logic. Report: (a) what is new and where it lives, in the change card's kinds, plus the pattern each new thing follows or departs from, and whether the walls (boundaries, contracts, dependency direction) stay intact, naming any dependency that points away from business rules; (b) contracts created or altered, in system terms: what crosses the boundary, for whom, its promises and failure modes; (c) architectural concerns prioritized by impact: describe the issue, concrete scenario (what breaks or becomes rigid), and suggested direction using reference concepts (shallow module, information leakage, pass-through method); (d) strengths to preserve. Balance trade-offs. Cite files, functions, lines. Prefix concerns with severity emoji (🔴/🟡/🟢); strengths carry no emoji. Max 500 words."*

**🧹 Code Quality**: pass diff command, commit list, Section 4 project rules, and severity scale, instructing to read relevant files in `<skills>/coding/references/`. Brief:
> *"Apply Phase 5 of `<skills>/agent-self-review/SKILL.md` to this PR, without fixing anything. Inspect strictly lines added or altered by the diff. Report **at most 5** findings (naming, functions, comments, error handling, or code smells), prioritized by impact per `code-smells.md` (bug risk → change cost → readability). For each: the issue, concrete failure scenario, suggested refactoring by name, and `file:line`. Discard items lacking concrete scenarios, style preferences, or anything covered by linters. Do not report module-scale architectural smells: those belong to the architecture axis. Maximum severity 🟡. Max 300 words."*

**🗄️ Database and Migrations** (Conditional):
Inspect whether the diff touches migration scripts (e.g. `migrations/`, `db/`, `*.sql`), schema files, ORM entities/repositories, query builders, or GraphQL resolvers.
- **If touched**: launch the subagent with diff command, commit list, and severity scale, instructing to first read `<skills>/coding/references/database-and-migrations.md`. Brief:
  > *"Apply `<skills>/coding/references/database-and-migrations.md` to this PR diff, without modifying code. Inspect schema migrations, DDL scripts, SQL queries, and ORM access patterns. Report: (a) Migration risks: table locks, missing `lock_timeout`, non-concurrent index creation (`CREATE INDEX CONCURRENTLY`), destructive single-step schema changes (🔴 Critical); (b) Query performance: N+1 query patterns in loops/endpoints, unindexed foreign keys or filter predicates on growing tables, unbounded queries lacking `LIMIT`, long-running transactions wrapping external I/O (🟡 Warning); (c) Optimization suggestions: compound index column ordering, cursor/keyset pagination (🟢 Suggestion). Cite `file:line` for all findings. Prefix each finding with severity emoji (🔴/🟡/🟢). Max 400 words."*
- **If untouched**: skip launching this subagent. Under the axis heading in the axis report, output: `*Skipped: no database migrations or queries touched by diff.*`

---

## 6. Axis Report

Format the report for quick scanning. **Never combine or re-order findings across axes**: a PR might pass on tooling while failing on architecture; separation prevents masking. The block below is an example; its fixed words are written in the user's session language.

```markdown
### 🔧 Quality and Rules — 🔴 1 · 🟡 2 · 🟢 0

- 🔴 **<one-line title>** — <why it matters, concrete scenario, file:line>
- 🟡 **<title>** — <detail>

### ✅ Behaviors and Tests — 🔴 0 · 🟡 1 · 🟢 0

| Status | Behavior (DoD) | Evidence | Action for Reviewer |
| :---: | :--- | :--- | :--- |
| ✅ | ... | `tests/...` | None |
| 👤 | ... | Not code-testable | Manually verify: ... |
| 🚨 | ... | Missing | Blocker |

- 🟡 **<title>** — <detail>

### 🏗️ Architecture and Contracts — 🔴 0 · 🟡 1 · 🟢 1

<the change card plan lines of what is new and where; a visualize-it swimlane only when a flow across places changed>

- 🟡 **<title>** — <detail>
- 🟢 **<title>** — <detail>
- ✅ <strength to preserve>

### 🧹 Code Quality — 🔴 0 · 🟡 1 · 🟢 2

- 🟡 **<issue>** — <concrete scenario, suggested refactoring, file:line>
- 🟢 **<issue>** — <detail>

### 🗄️ Database and Migrations — 🔴 0 · 🟡 1 · 🟢 0

- 🟡 **<issue>** — <operational hazard, suggested remediation, file:line>
```

If an axis was skipped (missing spec, unable to run tooling, or no database changes touched), state that in a single line under the heading without omitting the heading (e.g. `*Skipped: no database migrations or queries touched by diff.*`).

---

## 7. Success Validation

- [ ] Axes ran only on request, after the guide's assessment, without repeating it.
- [ ] Every finding has `file:line` and a severity badge, with zero cross-axis contamination; skipped axes say why.
- [ ] Axis 🏗️ named the intended architecture baseline it used.
- [ ] Database risks were audited against `database-and-migrations.md` when the diff touched them.
- [ ] Any review worktree was removed and the user's working tree stayed untouched.
