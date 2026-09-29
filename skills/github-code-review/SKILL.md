---
name: github-code-review
description: >-
  Reviews a teammate's GitHub Pull Request (or a diff from a fixed reference point)
  by combining criteria from agent-self-review (tooling, project rules, DoD coverage,
  test sanity, code quality) with human-review (modules, dependency direction, contracts,
  and behaviors). Evaluation axes run across parallel subagents. The skill then
  discusses findings with the user, recommends approval or change requests, and formats
  accepted points into humanized review comments ready to paste into GitHub.
disable-model-invocation: true
argument-hint: "[PR number/URL, branch, SHA, or base ref]"
---

# GitHub Code Review

For reviewing **other people's work**: a teammate's PR, or any diff from a fixed base. The deliverable is not the raw review itself; it is **assisting the user in deciding** (approve or request changes) and **identifying the specific points they will comment on**.

> This skill applies the same standards to a teammate's code that the development pipeline applies internally: the mechanical rigor of [`agent-self-review`](../agent-self-review/SKILL.md) and the architectural governance of [`human-review`](../human-review/SKILL.md). The difference is that here **nothing is modified unilaterally**: everything becomes a finding, and the user chooses what to comment on.

Four review axes, executed via **parallel subagents** to prevent context contamination:

| Axis | Origin | Core Question |
| :--- | :--- | :--- |
| 🔧 **Quality and Rules** | `agent-self-review` phases 1–2 | Does code pass project tooling and follow documented repository rules? |
| ✅ **Behaviors and Tests** | `agent-self-review` phases 3–4 + `human-review` DoD table | Does the change fulfill requirements, with each behavior verified by refactor-proof tests? |
| 🏗️ **Architecture and Contracts** | `human-review` + `software-designing` references | Are modules, boundaries, dependency direction, and contracts architecturally sound? |
| 🧹 **Code Quality** | `agent-self-review` phase 5 + `coding` references | Is newly added code below contracts clean, obvious, and maintainable? |

---

## 1. Establish the Comparison Baseline

Use the reference provided by the user: PR number/URL, SHA, branch, tag, `main`, `HEAD~5`.

- **GitHub PR**: `gh pr view <pr> --json number,title,body,baseRefName,headRefName,url,author` and `gh pr diff <pr>`. The PR base is the fixed point.
- **Local Ref**: `git diff <fixed-ref>...HEAD` (triple-dot, against merge-base) and `git log <fixed-ref>..HEAD --oneline`.

Capture the diff **once**. Verify that the reference resolves and that the diff is non-empty **before** creating subagents: invalid refs must fail here, not inside subagent threads.

To allow Axis 🔧 to run test and lint tooling, create an isolated worktree of the PR code **without altering the user's working tree**:

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

*Calibration*: in `agent-self-review`, rule violations are blocking because the agent fixes them immediately. Here, this is a peer's PR. **Documented rule violations** can be 🔴 or 🟡 based on impact. **Design red flags** (from `coding` or `software-designing`) are subjective evaluations and **never exceed 🟡**, unless they trigger a demonstrable failure.

---

## 5. Gather Repository Rules

Consolidate documentation on repository coding guidelines: repository `AGENTS.md`/`CLAUDE.md`, user global rules, files under `docs/rules/`, and `CODING_STANDARDS.md` or `CONTRIBUTING.md`. References from the [`coding`](../coding/SKILL.md) skill are not repo rules: they serve Axis 🧹.

- **The repository prevails**: documented project rules always override general standards; if a rule endorses a pattern that general guidelines discourage, discard the finding.
- **Do not duplicate automated tooling**: ignore issues already flagged by linters and formatters; those surface through Phase 1.

---

## 6. Launch the Four Subagents in Parallel

Send a single prompt launching four subagents concurrently using the harness subagent tool (see [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md); in Claude Code, `Agent` with `general-purpose` type). In briefs below, `<skills>` represents the skills folder: replace with the absolute path before sending. Embed the **Section 4 severity scale** in each brief. Subagents never modify code.

**🔧 Quality and Rules**: pass diff command, commit list, worktree path, Section 5 rule sources, and severity scale. Brief:
> *"Apply phases 1 and 2 of `<skills>/agent-self-review/SKILL.md` to this PR, without fixing anything. (a) In the worktree, run linters, typecheckers, and tests; if unable to run, use `gh pr checks <pr>` and state that. Report strictly failures introduced or touched by the diff. (b) Report every diff location violating a documented project rule, citing file and rule. Do not report code smells or general design judgments: those belong to another axis. Cite `file:line` for all findings. Prefix each finding with its severity emoji (🔴/🟡/🟢). Max 400 words."*

**✅ Behaviors and Tests**: pass diff command, commit list, Section 2 behavior list, and severity scale, instructing to first read `<skills>/coding/references/testing.md`. Brief:
> *"Apply phases 3 and 4 of `<skills>/agent-self-review/SKILL.md` to this PR, without fixing anything. For each behavior, classify using the DoD legend from `<skills>/human-review/SKILL.md` (Section 2.3): ✅, 🔎, 👤 (state manual validation steps), or 🚨. Report findings: (a) implemented behavior that is testable but lacks adequate tests (🟡); (b) behavior in diff that was not requested (scope creep); (c) tests in diff violating `testing.md` (coupled to text, markup, or internals; exposed private symbols; mocked internal collaborators), with concrete failure scenarios. Cite requirement and `file:line`. Prefix each finding with severity emoji (🔴/🟡/🟢). Max 400 words."*

**🏗️ Architecture and Contracts**: pass diff command, commit list, Section 3 intended architecture, and severity scale, instructing to first read `<skills>/human-review/SKILL.md` and all files in `<skills>/software-designing/references/`. Brief:
> *"Review the architectural design of the diff, not syntax or business logic. Following `human-review`, report: (a) new, modified, or removed modules and dependency direction, with a module map in `visualize-it` notation, highlighting any arrows pointing away from business rules; (b) public interfaces and contracts created or altered: promises and failure modes; (c) architectural concerns prioritized by impact: describe the issue, concrete scenario (what breaks or becomes rigid), and suggested direction using reference concepts (shallow module, information leakage, pass-through method); (d) strengths to preserve. Balance trade-offs. Cite files, functions, lines. Prefix concerns with severity emoji (🔴/🟡/🟢); strengths carry no emoji. Max 500 words."*

**🧹 Code Quality**: pass diff command, commit list, Section 5 project rules, and severity scale, instructing to first read files in `<skills>/coding/references/`. Brief:
> *"Apply Phase 5 of `<skills>/agent-self-review/SKILL.md` to this PR, without fixing anything. Inspect strictly lines added or altered by the diff. Report **at most 5** findings (naming, functions, comments, error handling, or code smells), prioritized by impact per `code-smells.md` (bug risk → change cost → readability). For each: the issue, concrete failure scenario, suggested refactoring by name, and `file:line`. Discard items lacking concrete scenarios, style preferences, or anything covered by linters. Do not report module-scale architectural smells: those belong to the architecture axis. Maximum severity 🟡. Max 300 words."*

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
```

If an axis was skipped (missing spec, unable to run tooling), state that in a single line under the heading without omitting the heading.

Conclude with summary and **recommended verdict**:

```markdown
## 📊 Summary

🔴 Critical:   N   — requires attention prior to merge
🟡 Warning:    N   — worth discussing
🟢 Suggestion: N   — optional

Highest-risk axis: **<axis>** (<key finding in one line>)

**Suggested Verdict:** ✅ Approve | 💬 Approve with comments | 🔁 Request changes
<single sentence rationale>
```

Verdict rule: any 🔴 (or 🚨 in DoD table) → **Request changes**; strictly 🟡/🟢 → **Approve with comments**; clean → **Approve**. This is a recommendation: **the verdict belongs to the user**.

Engage in conversation and answer questions. The user may promote, demote, or discard findings.

---

## 8. Format Accepted Points into Comments

When the user is ready, **ask which findings they consider valid and what final verdict they choose.** Only accepted findings become review comments: never publish the unfiltered report.

### 8.1. Line Comments

For each accepted finding, generate a ready-to-paste comment in the language of the PR/repository (or user session language). Draft and pass through the [`humanize-writing`](../humanize-writing/SKILL.md) skill before presenting: comments are read by teammates, and formulaic AI phrasing damages collaborative rapport.

<comment-template>

**File:** `path/to/file.ext`
**Line:** N (or range N-M)

{{professional, collaborative explanation covering the *why*: concrete failure scenario, maintenance risk, or cost}}

{{if a specific code snippet or approach was agreed upon: include it here at the end in a code block}}

</comment-template>

### 8.2. General Review Summary Comment

A concise summary for the overall PR review body, aligned with the user's verdict:
- **Approve**: acknowledges what was done well (leverage strengths from Axis 🏗️) in 2–3 sentences.
- **Approve with comments**: notes that comments are non-blocking suggestions.
- **Request changes**: summarizes in brief prose what needs remediation prior to merge (accepted 🔴 findings) and links to line comments.

Run through `humanize-writing`.

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

Never publish automatically. If the user explicitly requests publication, display the exact payload and invoke `gh pr review <pr>` with `--approve`, `--comment`, or `--request-changes`, strictly upon confirmation.

---

## 9. Success Validation

- [ ] Diff captured once and validated prior to subagents; user's working tree untouched, review worktree removed.
- [ ] Four axes executed (or omissions declared), each with severity breakdown.
- [ ] Every finding contains `file:line` and severity badge; zero cross-axis contamination.
- [ ] Axis 🏗️ declares which intended architecture baseline was used.
- [ ] Recommended verdict adheres to Section 7 rules, with final verdict determined by user.
- [ ] Only user-accepted findings became comments, with exact line locations, humanized, and free of AI co-authorship footers.
- [ ] Zero content published to GitHub without explicit request and confirmation.
