---
name: github-code-review
description: >-
  Reviews a teammate's GitHub Pull Request (or a diff from a fixed reference point)
  with a focused Human Layer assessment by default and optional deeper review axes
  (quality & rules, behaviors & tests, architecture, code quality, and database & migrations). Supports re-review mode to track resolution of
  prior feedback against incremental commits. The skill discusses findings with the user,
  recommends approval or change requests, and formats accepted points into humanized review
  comments ready to paste into GitHub.
disable-model-invocation: true
argument-hint: "[PR number/URL, branch, SHA, or base ref] [--re-review]"
---

# GitHub Code Review

For reviewing a GitHub PR or any diff from a fixed base, including a teammate's work or the user's own delivery. The deliverable is not the raw review itself; it is **assisting the user in deciding** (approve or request changes) and **identifying the specific points they will comment on**.

> This skill applies the same standards to a teammate's code that the development pipeline applies internally: the mechanical rigor of [`agent-self-review`](../agent-self-review/SKILL.md) and the architectural governance of [`human-review`](../human-review/SKILL.md). The difference is that here **nothing is modified unilaterally**: everything becomes a finding, and the user chooses what to comment on.

## Review Depth

For an unqualified review request, establish the baseline below and apply [human-review](../human-review/SKILL.md) once: actual business decisions, trade-offs, maintenance commitments, architectural diagnosis, and scope/value assessment. This works regardless of authorship. Reuse that investigation for any follow-up.

Systematic Agent Layer review, full multi-axis review, or selected axes are available when requested. The detailed axis workflow below applies to that requested scope; it is not a prerequisite for a focused Human Layer review. Create an isolated checkout only when execution requires it; a read-only diff analysis needs none. Load relevant references selectively. Use subagents for requested depth where useful, not automatically for every review.

For focused review, use human-review's selective presentation, coverage limits, and decision-oriented ordering rather than the full per-axis report. Missing business context is disclosed; ask only if it changes the recommendation. Never infer expected requirements solely from the implementation. Optional batch triage prioritizes deeper review and does not certify PRs.

For requested multi-axis review, preserve the business/decision assessment from `human-review` as the opening synthesis and reuse its architecture evidence. Delegate only the remaining requested work; do not repeat that assessment in each axis. Up to five axes can execute via **parallel subagents**:

| Axis | Origin | Core Question |
| :--- | :--- | :--- |
| 🔧 **Quality and Rules** | `agent-self-review` phases 1–2 | Does code pass project tooling and follow documented repository rules? |
| ✅ **Behaviors and Tests** | `agent-self-review` phases 3–4 + `human-review` DoD table | Does the change fulfill requirements, with each behavior verified by refactor-proof tests? |
| 🏗️ **Architecture and Contracts** | `human-review` + `software-designing` references | Are modules, boundaries, dependency direction, and contracts architecturally sound? |
| 🧹 **Code Quality** | `agent-self-review` phase 5 + `coding` references | Is newly added code below contracts clean, obvious, and maintainable? |
| 🗄️ **Database and Migrations** | `coding` references ([database-and-migrations.md](../coding/references/database-and-migrations.md)) | Are queries efficient and schema migrations safe from table locks and downtime? |

---

## 1. Establish the Comparison Baseline

Use the reference provided by the user: PR number/URL, SHA, branch, tag, `main`, `HEAD~5`, optionally with `--re-review`.

### 1.1. Fresh Review Baseline
- **GitHub PR**: `gh pr view <pr> --json number,title,body,baseRefName,headRefName,url,author` and `gh pr diff <pr>`. The PR base is the fixed point.
- **Local Ref**: `git diff <fixed-ref>...HEAD` (triple-dot, against merge-base) and `git log <fixed-ref>..HEAD --oneline`.

Capture the diff **once**. Verify that the reference resolves and that the diff is non-empty **before** creating subagents: invalid refs must fail here, not inside subagent threads.

### 1.2. Re-review Mode (`--re-review` or follow-up prompt)
When the user indicates a re-review (via `--re-review` flag or session prompt):

1. **Collect Previous Review Threads and Comments**:
   Fetch PR reviews, conversation comments, and line threads via GraphQL:
   ```bash
   gh pr view <pr> --json number,title,body,baseRefName,headRefName,url,author,reviews,comments
   gh api graphql -F owner=<owner> -F repo=<repo> -F pr=<pr> -f query='
   query($owner:String!,$repo:String!,$pr:Int!){
     repository(owner:$owner,name:$repo){
       pullRequest(number:$pr){
         reviewThreads(first:100){ nodes{
           id isResolved isOutdated path line
           comments(first:50){ nodes{ databaseId url author{login} body diffHunk createdAt } }
         }}
       }
     }
   }'
   ```
2. **Identify Incremental Commits**:
   Determine commits added since the previous review round (`git log <previous-head>..HEAD --oneline` or commits committed after the latest previous review timestamp).
3. **Audit Previous Findings (Resolution Matrix)**:
   For every previous thread and feedback item, inspect current code and author responses:
   - 🟢 **Resolved**: Problem was fixed in code and verified in the diff.
   - 🔀 **Adjusted**: Addressed via an alternative sound approach; rationale verified.
   - 🔴 **Unresolved**: Problem remains unaddressed or new fix is defective.
   - 💬 **Discussed / Deferred**: Acknowledged without code change, or deferred with tracking issue.
4. **Scope for Evaluation Axes**:
   The parallel subagent axes evaluate the **incremental diff** (`<previous-head>..HEAD`), plus targeted inspection of lines altered to resolve previous comments. This prevents re-debating settled code while catching regressions, scope creep, or defects in newly added commits.

When Axis 🔧 is requested and will run test and lint tooling, create an isolated worktree of the PR code **without altering the user's working tree**:

```bash
git fetch origin pull/<pr>/head:review/<pr>
git worktree add ../<repo>-review-<pr> review/<pr>
```

Pass the worktree path to subagents. Upon completing the review, clean it up (`git worktree remove`) and delete the local `review/<pr>` branch.

---

## 2. Locate the Specification (DoD)

In order: issues referenced in the PR body or commit messages (Jira, GitHub, Linear) → path provided by the user → PRD, blueprint, or ticket in `docs/` matching the branch or feature → ask the user.

Extract a **list of expected behaviors** (acceptance criteria). If no specification exists, state that explicitly in the report: Axis ✅ then evaluates test suite sanity and apparent scope. **Never invent a specification out of thin air from the diff.**

---

## 3. Identify Intended Architecture

Axis 🏗️ needs to know what the design *ought* to be; otherwise review degenerates into subjective personal preference. Check, in order:

1. an existing architectural blueprint, ADR, or design doc for this domain;
2. established patterns in surrounding code that this change should remain consistent with;
3. in the absence of both, general design principles in [`software-designing/references/`](../software-designing/references/).

State which source was referenced. "Inconsistent with the module structure used throughout this package" is a vastly stronger finding than "I would have designed it differently".

---

## 4. Severity Scale

Every finding across all axes receives one of these badges for scannability:

- 🔴 **Critical**: breaks a requirement, introduces a bug, fails build/test tooling, or violates a mandatory rule. Must not be merged as-is. Equivalent to **Blocking** in `agent-self-review`.
- 🟡 **Warning**: real concern, non-blocking, warrants discussion prior to merge. Equivalent to **Should fix** in `agent-self-review`.
- 🟢 **Suggestion**: minor improvement **with a concrete scenario**. Style preferences lacking concrete failure scenarios are never reported on any axis.

*Calibration*: in `agent-self-review`, rule violations are blocking because the agent fixes them immediately. Here, this is a peer's PR. **Documented rule violations** can be 🔴 or 🟡 based on impact. **Design preferences** without concrete consequences are discarded. Evidence-backed architectural concerns can require a Human Layer decision before merge even without a current bug; severity reflects impact, not merely whether a failure already occurred.

---

## 5. Gather Repository Rules

Consolidate documentation on repository coding guidelines: repository `AGENTS.md`/`CLAUDE.md`, user global rules, files under `docs/rules/`, and `CODING_STANDARDS.md` or `CONTRIBUTING.md`. References from the [`coding`](../coding/SKILL.md) skill are not repo rules: they serve Axis 🧹.

- **The repository prevails**: documented project rules always override general standards; if a rule endorses a pattern that general guidelines discourage, discard the finding.
- **Do not duplicate automated tooling**: ignore issues already flagged by linters and formatters; those surface through Phase 1.

---

## 6. Launch the Subagents in Parallel (Up to Five)

Send a single prompt launching subagents concurrently using the harness subagent tool (see [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md); in Claude Code, `Agent` with `general-purpose` type). In briefs below, `<skills>` represents the skills folder: replace with the absolute path before sending. Embed the **Section 4 severity scale** in each brief. Subagents never modify code.

**🔧 Quality and Rules**: pass diff command, commit list, worktree path, Section 5 rule sources, and severity scale. Brief:
> *"Apply phases 1 and 2 of `<skills>/agent-self-review/SKILL.md` to this PR, without fixing anything. (a) In the worktree, run linters, typecheckers, and tests; if unable to run, use `gh pr checks <pr>` and state that. Report strictly failures introduced or touched by the diff. (b) Report every diff location violating a documented project rule, citing file and rule. Do not report code smells or general design judgments: those belong to another axis. Cite `file:line` for all findings. Prefix each finding with its severity emoji (🔴/🟡/🟢). Max 400 words."*

**✅ Behaviors and Tests**: pass diff command, commit list, Section 2 behavior list, and severity scale, instructing to first read `<skills>/coding/references/testing.md`. Brief:
> *"Apply phases 3 and 4 of `<skills>/agent-self-review/SKILL.md` to this PR, without fixing anything. For each behavior, classify using the DoD legend from `<skills>/human-review/SKILL.md` (Verification and decision section): ✅, 🔎, 👤 (state manual validation steps), or 🚨. Report findings: (a) implemented behavior that is testable but lacks adequate tests (🟡); (b) behavior in diff that was not requested (scope creep); (c) tests in diff violating `testing.md` (coupled to text, markup, or internals; exposed private symbols; mocked internal collaborators), with concrete failure scenarios. Cite requirement and `file:line`. Prefix each finding with severity emoji (🔴/🟡/🟢). Max 400 words."*

**🏗️ Architecture and Contracts**: pass diff command, commit list, Section 3 intended architecture, and severity scale, instructing to first read `<skills>/human-review/SKILL.md` and relevant files in `<skills>/software-designing/references/`. Brief:
> *"Review the architectural design of the diff, not syntax or business logic. Following `human-review`, report: (a) new, modified, or removed modules and dependency direction, with a module map in `visualize-it` notation, highlighting any arrows pointing away from business rules; (b) public interfaces and contracts created or altered: promises and failure modes; (c) architectural concerns prioritized by impact: describe the issue, concrete scenario (what breaks or becomes rigid), and suggested direction using reference concepts (shallow module, information leakage, pass-through method); (d) strengths to preserve. Balance trade-offs. Cite files, functions, lines. Prefix concerns with severity emoji (🔴/🟡/🟢); strengths carry no emoji. Max 500 words."*

**🧹 Code Quality**: pass diff command, commit list, Section 5 project rules, and severity scale, instructing to read relevant files in `<skills>/coding/references/`. Brief:
> *"Apply Phase 5 of `<skills>/agent-self-review/SKILL.md` to this PR, without fixing anything. Inspect strictly lines added or altered by the diff. Report **at most 5** findings (naming, functions, comments, error handling, or code smells), prioritized by impact per `code-smells.md` (bug risk → change cost → readability). For each: the issue, concrete failure scenario, suggested refactoring by name, and `file:line`. Discard items lacking concrete scenarios, style preferences, or anything covered by linters. Do not report module-scale architectural smells: those belong to the architecture axis. Maximum severity 🟡. Max 300 words."*

**🗄️ Database and Migrations** (Conditional):
Inspect whether the diff touches migration scripts (e.g. `migrations/`, `db/`, `*.sql`), schema files, ORM entities/repositories, query builders, or GraphQL resolvers.
- **If touched**: launch the subagent with diff command, commit list, and severity scale, instructing to first read `<skills>/coding/references/database-and-migrations.md`. Brief:
  > *"Apply `<skills>/coding/references/database-and-migrations.md` to this PR diff, without modifying code. Inspect schema migrations, DDL scripts, SQL queries, and ORM access patterns. Report: (a) Migration risks: table locks, missing `lock_timeout`, non-concurrent index creation (`CREATE INDEX CONCURRENTLY`), destructive single-step schema changes (🔴 Critical); (b) Query performance: N+1 query patterns in loops/endpoints, unindexed foreign keys or filter predicates on growing tables, unbounded queries lacking `LIMIT`, long-running transactions wrapping external I/O (🟡 Warning); (c) Optimization suggestions: compound index column ordering, cursor/keyset pagination (🟢 Suggestion). Cite `file:line` for all findings. Prefix each finding with severity emoji (🔴/🟡/🟢). Max 400 words."*
- **If untouched**: skip launching this subagent. Under the axis heading in the Section 7 report, output: `*Skipped: no database migrations or queries touched by diff.*`

---

## 7. Present and Discuss

Format the report for quick scanning. **Never combine or re-order findings across axes**: a PR might pass on tooling while failing on architecture; separation prevents masking.

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

<module map via visualize-it>

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

In **Re-review Mode**, open the report with the resolution audit table before presenting findings on the incremental commits:

```markdown
### 📋 Previous Review Resolution Matrix

| # | Location | Original Finding | Author Response / Commit | Resolution Status |
| :-: | :--- | :--- | :--- | :---: |
| 1 | `src/billing/invoice.ts:42` | Missing lock timeout | Added `SET lock_timeout = '2s'` in `abc1234` | 🟢 Resolved |
| 2 | `src/users/repo.ts:15` | N+1 query on roles | Eager loaded roles with `includes(:roles)` | 🟢 Resolved |
| 3 | `src/orders/service.ts:88` | Unbounded list query | Author noted pagination deferred to follow-up | 💬 Deferred |
| 4 | `src/auth/jwt.ts:24` | Token validation flaw | No commit addressing this | 🔴 Unresolved |

🟢 N Resolved · 🔀 N Adjusted · 💬 N Deferred · 🔴 N Unresolved
```

Conclude with summary and **recommended verdict**:

```markdown
## 📊 Summary

🔴 Critical:   N   — requires attention prior to merge (or unresolved prior blocker)
🟡 Warning:    N   — worth discussing
🟢 Suggestion: N   — optional

Highest-risk axis: **<axis>** (<key finding in one line>)

**Suggested Verdict:** ✅ Approve | 🔁 Request changes
<single sentence rationale>
```

Verdict rule: a critical defect or a material unresolved architectural/business decision that makes the current change unsuitable → **Request changes**, with the reason explicit. Incomplete evidence → state the limitation and pending verification, not automatic approval. Recommend **Approve** only within the reviewed scope when no material impediment remains. A focused Human Layer review does not certify unreviewed Agent Layer quality. **The verdict belongs to the user**; accepted concessions are respected unless new evidence changes their premises. The report summary and rationale are for discussion with the user, not a general PR review comment.

Engage in conversation and answer questions. The user may promote, demote, or discard findings.

When the PR was authored by the agent pipeline (the user's own work), tag each **accepted** 🔧, ✅, and 🧹 finding with its escape cause per [escape-classification.md](../agent-self-review/references/escape-classification.md) and add the one-line tally to the summary.

---

## 8. Format Accepted Points into Comments

As the user discusses each finding, establish whether they accept it and draft its line comment then. Do not wait for the final verdict to prepare accepted point-by-point comments. Ask for the user's final verdict when the review is ready to submit. Only accepted findings become review comments: never publish the unfiltered report.

### 8.1. Line Comments

For each accepted finding, generate a ready-to-paste comment in the language of the PR/repository (or user session language). Draft and pass through the [`humanize-writing`](../humanize-writing/SKILL.md) skill before presenting: comments are read by teammates, and formulaic AI phrasing damages collaborative rapport.

<comment-template>

**File:** `path/to/file.ext`
**Line:** N (or range N-M)

{{professional, collaborative explanation covering the *why*: concrete failure scenario, maintenance risk, or cost}}

{{if a specific code snippet or approach was agreed upon: include it here at the end in a code block}}

</comment-template>

### 8.2. General Review Comment (Only on Explicit Request)

By default, leave the overall review body empty for both **Approve** and **Request changes**. Line comments and existing thread replies carry the accepted feedback; do not repeat them in a general review comment. Draft a general review body only if the user explicitly requests one, aligned with their chosen verdict.

Run any requested general review body through `humanize-writing`.

### 8.3. Thread Replies in Re-review Mode

When conducting a re-review, findings often continue existing unresolved conversations:
- **Unresolved threads**: Draft replies to be posted directly into the existing review thread (`addPullRequestReviewThreadReply` with `threadId`), stating concisely why the point remains unresolved or what remains defective.
- **New findings on incremental commits**: Format as standard line comments per Section 8.1.

### Comment Guidelines

- **Exact file and line.** If the finding lacks precise location, inspect the diff. Never guess.
- **[No local references](../ai-assisted-software-development/references/no-local-references.md)**. Reference linked issues (Jira/GitHub), or rephrase requirements.
- **Professional and collaborative.** Phrase as observations for discussion, not unilateral demands. Prefer *"we might consider"* over *"you should have"*.
- **Explain the why**, not merely what.
- **No speculative fixes.** If no solution was discussed, conclude with the explanation.
- **No signature lines.** Zero co-authorship tags, AI disclaimers, or footers.
- Technical terms, code identifiers, and snippets remain in their original form.
- Present in the order findings were discussed, ready to copy.

### Publishing

Never publish automatically. If the user explicitly requests publication, display the exact payload, including the verdict, each accepted line comment or thread reply, and the general review body only when explicitly requested; publish strictly upon confirmation. Submit **Approve** or **Request changes** without a general body by default. Use a submission method that supports the accepted point-by-point comments and an empty review body. If the GitHub interface rejects an empty body for **Request changes**, explain that constraint and ask the user how to proceed; do not invent a summary or silently switch the verdict.

---

## 9. Success Validation

- [ ] Diff captured once and validated before any delegation; user's working tree untouched, any review worktree removed.
- [ ] Review depth matches the request: focused Human Layer by default, systematic Agent Layer/selected axes/full review when requested; coverage is explicit.
- [ ] In re-review mode, Previous Review Resolution Matrix audited every prior feedback item and incremental diff was evaluated without re-debating settled points.
- [ ] When systematic database review was requested, migration/query risks were audited against `database-and-migrations.md`; focal review discloses any remaining coverage limits.
- [ ] Every finding contains `file:line` and severity badge; zero cross-axis contamination.
- [ ] Axis 🏗️ declares which intended architecture baseline was used.
- [ ] Recommended verdict adheres to Section 7 rules, with final verdict determined by user.
- [ ] On agent-authored PRs, accepted 🔧, ✅, and 🧹 findings carry an escape-cause tally.
- [ ] Only user-accepted findings became comments, with exact line locations, humanized, and free of AI co-authorship footers.
- [ ] Approve or Request changes has no general review body unless the user explicitly requested one; accepted feedback stays in line comments or thread replies.
- [ ] Zero content published to GitHub without explicit request and confirmation.
