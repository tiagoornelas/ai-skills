---
name: agent-self-review
description: >-
  Autonomous quality gate executed by the coding agent on its own work prior to
  human review. Audits static tooling, project rules, Definition of Done (DoD)
  coverage, test sanity, and code quality below contracts over everything
  committed since the last clean checkpoint (increment mode) or over the whole
  branch before a pull request is opened (branch mode), in a self-correction
  loop with an iteration budget and round limit, until approved.
---

# Agent Self-Review

Pre-human quality gate executed autonomously by the coding agent.

---

## 1. Operational Principle

The goal is to ensure zero mechanical defects, typing errors, linter regressions, project rule violations, or unverified DoD behaviors reach the human developer.

The goal is **not** flawless aesthetic perfection. The goal is code that is **correct, covered, and devoid of high-cost defects**. Marginal stylistic improvements never justify an additional loop iteration. The agent focuses on the 80/20 rule: apply the few highest-impact corrections and stop.

The "zero-tolerance" posture from [`software-designing`](../software-designing/SKILL.md) applies to **architectural design decisions**. Below contracts, the budget rules in Section 5 apply.

The operational cycle is **evaluate → fix → re-evaluate**, adhering to convergence rules in Section 5.

---

## 2. Finding Classifications

Every discovered finding falls into one of four distinct categories. The category determines the exact action to take.

| Category | Definition | Action |
| :--- | :--- | :--- |
| **Blocking** | Objective and deterministic: tool or test failure, violation of a documented project rule stated as a checkable obligation (Phase 2), unsafe database migration (table-locking DDL per `database-and-migrations.md`), DoD behavior lacking test coverage and lacking explicit declaration. | Always fix. |
| **Should fix** | Subjective judgment **with a concrete failure scenario**: able to articulate in a single sentence what probable bug, expensive future change, or reader confusion it causes. Includes violations of vague or preference-worded rules ("prefer", "avoid", "when possible"). | Fix within the budget (Section 5) or justify in one line why it remains. |
| **Discard** | Judgment lacking a concrete scenario, personal style preference, "could be slightly cleaner". | Do not fix and do not record. |
| **Escalate** | The remediation would alter a public contract, module boundary, or dependency direction; or a checkable rule has no automated check (Phase 2). | Do not apply. Record as a pending Human Layer decision. |

When uncertain between **Should fix** and **Discard**: if a concrete failure scenario does not come to mind immediately, discard it.

---

## 3. Scope

The scope is a **git range**, never a description of the work. An author-written summary ("Change: … Files: …") may orient the review, but it never defines what is inspected: code the summary omits is still in scope.

### 3.1. Increment Mode (default)

Inspect everything since the **last clean checkpoint**: `<checkpoint>..HEAD` plus uncommitted changes (`git diff HEAD`). This includes merges authored in the session, commits made by subagents or background agents, and code written after a previous run started.

- **Checkpoint**: the nearest ancestor of `HEAD` carrying a self-review note (Section 6):
  ```bash
  for c in $(git rev-list HEAD); do
    git notes --ref=self-review show "$c" >/dev/null 2>&1 && echo "$c" && break
  done
  ```
- **No checkpoint found**: fall back to the merge-base with the branch the work will merge into (`git merge-base HEAD origin/<base>`).
- Merge commits: inspect the merge result (`git diff <checkpoint>..HEAD`), not each parent separately; conflict resolutions and code brought in by the merge that this branch did not author are out of scope.

### 3.2. Branch Mode (once, before a pull request)

Inspect the full branch diff against its merge-base with the target branch. Run it **once** before a pull request is opened or marked ready, and again only if commits land after it. Its purpose is what increment runs cannot see: issues that emerge across commits (the same logic duplicated by different increments, rules drifting between commits, a merge that reintroduced a violation).

- Phases 1–3 run in full over the branch diff.
- Phases 4–5 do not re-judge each line: increment runs already did. They look strictly for **cross-commit** concerns: duplicated logic or queries introduced by different commits, inconsistent patterns for the same problem, dead code left behind by later commits.
- If the branch diff exceeds 60 changed files, run Phases 4–5 only over files changed in more than one commit, and state that limit in the verdict.

### 3.3. Pre-existing Code

- Pre-existing defects in code the range did not touch are out of scope, even if genuine.
- Exception: if a pre-existing issue causes project build/lint tooling to fail, treat it as **Escalate**, rather than scope-creeping cleanup.

---

## 4. Verification Phases

### Phase 1: Static Tooling and Tests (Objective → Blocking)
- Run project linters, static type checkers (`tsc`, `mypy`, etc.), and automated test suites.
- Resolve any syntax error, formatting defect, typing mismatch, or broken test. Never silence alerts with suppression directives without imperative justification.

### Phase 2: Project Rules and Migration Safety (Objective → Blocking)

Build a **rule ledger** once per run, then check every file in scope against it.

1. **Enumerate rule sources**: repository `AGENTS.md`/`CLAUDE.md` and every file they point to, every file under `docs/rules/`, and `CONTRIBUTING.md`/`CODING_STANDARDS.md` if present. List them by name.
2. **Select by applicability**: keep a rule file when its subject matches any path in scope (language, layer, directory, file type). **Test files are in scope**: testing, documentation, and language rules apply to them as much as to production code.
3. **Read each selected file in full.** Never sample a rule file with `head`, `tail`, or `grep`: a rule past the cut-off is a rule never applied.
4. **Extract checkable rules**: short entries of the form *rule → where it applies → how to check it*. Rules worded as preferences ("prefer", "avoid", "when possible") are recorded as judgment rules: violating them is **Should fix**, never Blocking.
5. **Check** every file in scope against every applicable ledger entry.

Reporting obligations:
- Every violation cites the rule **verbatim** (quoted text, rule file and section) and the `file:line` that breaks it.
- Every claimed exception quotes the exception clause that permits it. If no clause can be quoted, the exception does not exist and the violation stands. This applies with equal force to code written by the agent in this run.
- **Mechanizable rules**: when a rule can be checked by a linter, formatter, semgrep pattern, or test-framework setting that the project does not yet run, record one **Escalate** entry per rule proposing that automated check. Do not build the tooling. Each rule is escalated once, not once per violation.

**Migration Safety**: if database schema migrations or DDL files were added or modified, audit them against [database-and-migrations.md](../coding/references/database-and-migrations.md). Any table-locking DDL on active tables, missing `lock_timeout`, non-concurrent index creation, or destructive single-step schema change is **Blocking**. General quality judgments belong in Phase 5.

### Phase 3: BDD Definition of Done Coverage (Objective → Blocking)
For each requirement or acceptance criterion of the task:
1. **Verified via code**: confirm an automated test verifies the behavior through the public interface, adhering to [testing.md](../coding/references/testing.md). Tests verifying internal details or adjacent concerns do not qualify as coverage.
2. **Untestable via code**: if the behavior cannot be code-tested ([testing.md](../coding/references/testing.md), Section 5), explicitly declare:
   - what the behavior is;
   - why it cannot be tested via code;
   - how it was verified through alternative means;
   - step-by-step instructions for human manual validation.

3. **Missing infrastructure**: if the behavior could only be tested with infrastructure the project currently lacks, declare it per Item 2 and flag the missing infrastructure as **Escalate**. Do not build the infrastructure.

> 🚨 Any DoD behavior lacking automated tests and lacking an explicit declaration is **Blocking**.

### Phase 4: Test Suite Sanity (Judgment → Should fix)
- Apply [testing.md](../coding/references/testing.md) to the tests in scope. Tests prone to breaking during refactoring without behavior change (coupled to text copy, markup structure, CSS class names, or internals), or exposing private symbols solely for testing, are **Should fix**, subject to the Section 5 budget.

### Phase 5: Code Quality and Query Performance (Judgment → Should fix)
- **Failure-path questions first.** Before judging style or structure, answer these over the code in scope; each "yes, and nothing handles it" is a candidate finding with a ready-made failure scenario:
  1. **Partial failure**: in an operation of several steps that mutate state (files, config, lock files, remote resources, database rows), what is left behind if step *k* fails?
  2. **Delimiters and boundaries**: in parsers, stream handlers, and text protocols, what happens when the delimiter appears inside the payload, or the input is truncated or empty?
  3. **Silent fallbacks**: when an optional value is missing, does the code widen its scope (whole session instead of current turn, all records instead of one) or pick an arbitrary element (`[0]` where the latest was meant)?
  4. **Per-event cost**: in handlers that run per keystroke, per stream chunk, or per render, is work proportional to total history rather than to the event?
  5. **Guards on identifiers**: does a safety check trust a value the caller controls (a name, a flag) instead of the property it is meant to protect?
- Then apply [`coding`](../coding/SKILL.md) references (naming, functions, comments, error handling, code smells, and [database-and-migrations.md](../coding/references/database-and-migrations.md)) to the code in scope, prioritized by impact:
  1. **Operational and bug risk**: hot-path N+1 queries, unindexed filter/join predicates on growing tables, long transactions wrapping external I/O per `database-and-migrations.md`, and severe code smells per [code-smells.md](../coding/references/code-smells.md).
  2. **Change cost**: architectural rigidity below contracts, duplicated logic or queries, missing pagination limits.
  3. **Readability**: function bloat, obscure naming, dead code.
- Category mapping per Section 2: concrete scenario → **Should fix**; no concrete scenario → **Discard**; touches contract/boundary → **Escalate**.
- All remediations adhere to [refactoring-principles.md](../coding/references/refactoring-principles.md): preserved behavior, green tests.
- Architectural smells at module or contract scale are always **Escalate**, never local refactorings.

---

## 5. Loop and Convergence

### Phase Ordering
Execute objective phases (1, 2, 3) first and resolve all **Blocking** issues. Only then execute judgment phases (4, 5) on the stabilized code.

### Budget
- Maximum of **5 Should fix remediations** per run, combining Phases 4 and 5, prioritized strictly by impact.
- Judgment findings exceeding the budget are **discarded**, not deferred.

### Re-evaluation
- After applying fixes, re-run Phases **1 and 3** in their entirety (they are fast and deterministic).
- Re-run Phase **2** against the existing rule ledger, over the lines changed by the fixes. Do not rebuild the ledger or re-read rule files. Fixes are code like any other: a fix that breaks a ledger rule is Blocking.
- Phases **4 and 5 do not run again**.
- **Zero second-order judgment findings**: judgment smells introduced by a remediation never trigger an additional round of Phases 4–5. Objective violations (Phases 1–3) introduced by a remediation are still Blocking.

### Iteration Limit
- Maximum of **3 rounds** of evaluate → fix → re-evaluate.
- If **Blocking** issues persist after round 3, stop. Document the roadblock (what is failing, what was attempted) as a pending blocker for the human. Do not loop indefinitely.

### Anti-Oscillation
- If a proposed fix would revert a previous fix, or contradicts a decision already finalized in this review, **preserve the current implementation** and move forward.

### Commit Traceability
- Self-review fixes are separate commits, authored after the implementation commit, adhering to [`commit`](../commit/SKILL.md). Never fold them into the implementation commit, even when the work was not yet committed when the review began: commit the implementation first.

---

## 6. Verdict

The deliverable is **clean** at the agent layer when:

- zero **Blocking** issues exist (or persistent blockers are documented after round 3);
- every reported **Should fix** was remediated or justified in a single sentence;
- every **Escalate** finding is logged as a pending Human Layer decision.

Record a concise traceability log: the reviewed range and mode, the rule files in the ledger, what was fixed, what was justified, and what was escalated. Discarded findings are not recorded.

**Checkpoint**: when the verdict is clean (or blockers are documented after round 3) and all work is committed, mark `HEAD` so the next increment starts there:

```bash
git notes --ref=self-review add -f -m "<increment|branch> clean <ISO-8601 date>" HEAD
```

The note stays local (git does not push notes by default) and never alters commit history.

---

## 7. Escape Classification

When a later review (peer review, [`github-code-review`](../github-code-review/SKILL.md), or [`github-review-react`](../github-review-react/SKILL.md)) accepts a rules or code-quality finding on code this pipeline authored, classify why self-review let it through. The classification guides the fix: only some causes are fixed by reviewing harder.

| Cause | Meaning | Remedy |
| :--- | :--- | :--- |
| **Coverage** | No self-review run covered the commit (merge, subagent commit, code written after the run). | Run increment mode from the checkpoint; run branch mode before the PR. |
| **Rule unread** | The rule file was never in the ledger, or was sampled. | Ledger enumeration and applicability (Phase 2). |
| **Rule relaxed** | The rule was read, but an exception was claimed without a quotable clause. | Verbatim citation obligation (Phase 2). |
| **Mechanizable** | The rule is checkable by tooling the project does not run. | Escalate the automated check; it then belongs to Phase 1. |
| **Judgment** | The finding needs judgment the run lacked (performance, concurrency, parsing). | Failure-path questions (Phase 5); otherwise accept as peer-review territory. |
| **Pre-existing** | The code predates the branch or was authored by someone else. | None: out of scope by design. |

Report the tally in one line (e.g., `Escapes: coverage 2 · rule unread 1 · judgment 1`). Do not open a self-review round over the escaped findings: they are fixed through the reviewing skill's own flow.

---

## 8. Success Validation

- [ ] Scope was a git range (increment from the checkpoint, or branch against the merge-base), including merges and subagent commits; never an author-written summary.
- [ ] Objective phases (1–3) executed prior to judgment phases (4–5).
- [ ] The rule ledger lists every applicable rule file, each read in full; test files were checked against it.
- [ ] Every rule violation and every claimed exception quotes the rule text.
- [ ] Mechanizable rules without automated checks were escalated once each.
- [ ] Failure-path questions answered before code-quality judgment.
- [ ] Maximum 5 Should fix remediations applied across at most 3 iteration rounds.
- [ ] Fixes were re-checked against Phases 1–3; zero new judgment rounds opened for second-order findings.
- [ ] Zero contract, boundary, or dependency direction changes applied: all were escalated.
- [ ] Schema migrations and queries audited against [database-and-migrations.md](../coding/references/database-and-migrations.md) if database code was modified.
- [ ] Automated tests pass following the final remediation commit, fixes committed separately, and the checkpoint note recorded on `HEAD`.
- [ ] In branch mode, ran at most once per head commit, with Phases 4–5 restricted to cross-commit concerns.
