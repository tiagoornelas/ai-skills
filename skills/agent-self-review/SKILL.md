---
name: agent-self-review
description: >-
  Autonomous quality gate executed by the coding agent on its own work prior to
  human review. Audits static tooling, project rules, Definition of Done (DoD)
  coverage, test sanity, and code quality below contracts over everything
  committed since the last clean checkpoint (increment mode) or over the whole
  branch before a pull request is opened (branch mode), in a self-correction
  loop that budgets discretionary improvements while keeping critical defects and
  project standards outside the budget.
---

# Agent Self-Review

Pre-human quality gate executed autonomously by the coding agent.

---

## 1. Operational Principle

The goal is to ensure zero mechanical defects, typing errors, linter regressions, project rule violations, or unverified DoD behaviors reach the human developer.

The goal is **not** flawless aesthetic perfection. The goal is code that is **correct, covered, and devoid of high-cost defects**. Marginal stylistic improvements never justify an additional loop iteration. The agent focuses on the 80/20 rule: apply the few highest-impact corrections and stop.

The "zero-tolerance" posture from [`software-designing`](../software-designing/SKILL.md) applies to **architectural design decisions**. Below contracts, the Section 5 budget applies only to discretionary improvements; critical defects and project standards remain mandatory.

The operational cycle is **evaluate → fix → re-evaluate**, adhering to convergence rules in Section 5.

---

## 2. Finding Classifications

Every discovered finding falls into one of four distinct categories. The category determines the exact action to take.

| Category | Definition | Action |
| :--- | :--- | :--- |
| **Blocking** | Tool or test failure; violation of an applicable documented project rule, including a preference-worded standard (Phase 2); unsafe database migration; DoD behavior lacking test coverage and lacking explicit declaration; or a critical defect with a concrete failure scenario. Critical means a credible path to data loss or corruption, security exposure, irreversible side effects, or failure of a required behavior. Deterministic proof is not required for a credible critical risk. | Fix regardless of budget. If unresolved, report a blocked verdict. |
| **Should fix** | Judgment **with a concrete failure scenario** that does not meet the Blocking criteria: a probable lower-impact bug, expensive future change, or reader confusion. | Fix within the budget (Section 5) or justify in one line why it remains. |
| **Discard** | Judgment lacking a concrete scenario, personal style preference, "could be slightly cleaner". | Do not fix and do not record. |
| **Escalate** | The remediation would alter a public contract, module boundary, or dependency direction; or a checkable rule has no automated check (Phase 2). | Do not apply. Record as a pending Human Layer decision. If a Blocking finding needs that decision, the verdict stays blocked. |

Classify severity before applying any budget. When uncertain whether a credible scenario is critical, keep it Blocking until evidence rules out the critical impact. When uncertain between **Should fix** and **Discard**: if a concrete failure scenario does not come to mind immediately, discard it.

---

## 3. Scope

The scope is a **git range**, never a description of the work. An author-written summary ("Change: … Files: …") may orient the review, but it never defines what is inspected: code the summary omits is still in scope.

### 3.1. Increment Mode (default)

Inspect everything since the **last clean checkpoint**: `<checkpoint>..HEAD` plus uncommitted changes (`git diff HEAD`). This includes merges authored in the session, commits made by subagents or background agents, and code written after a previous run started.

- **Checkpoint**: the nearest ancestor of `HEAD` carrying a self-review note (Section 6):
  ```bash
  git rev-list HEAD | grep -Fx -f <(git notes --ref=self-review list | cut -d' ' -f2) | head -1
  ```
- **No checkpoint found**: fall back to the merge-base with the branch the work will merge into (`git merge-base HEAD origin/<base>`).
- Merge commits: inspect the merge result (`git diff <checkpoint>..HEAD`), not each parent separately; conflict resolutions and code brought in by the merge that this branch did not author are out of scope.

### 3.2. Branch Mode (once, before a pull request)

Inspect the full branch diff against its merge-base with the target branch. Run it **once** before a pull request is opened or marked ready, and again only if commits land after it. Its purpose is what increment runs cannot see: issues that emerge across commits (the same logic duplicated by different increments, rules drifting between commits, a merge that reintroduced a violation).

- Phases 1–3 and 4a run in full over the branch diff.
- Phases 4b–5 do not re-judge each line: increment runs already did. They look strictly for **cross-commit** concerns: duplicated logic or queries introduced by different commits, inconsistent patterns for the same problem, dead code left behind by later commits.
- If the branch diff exceeds 60 changed files, run Phases 4b–5 only over files changed in more than one commit, and state that limit in the verdict.

### 3.3. Pre-existing Code

- Pre-existing defects in code the range did not touch are out of scope, even if genuine.
- Exception: if a pre-existing issue causes project build/lint tooling to fail, treat it as **Escalate**, rather than scope-creeping cleanup.

---

## 4. Verification Phases

### Phase 1: Static Tooling and Tests (Objective → Blocking)
- Run project linters, static type checkers (`tsc`, `mypy`, etc.), and automated test suites.
- Resolve any syntax error, formatting defect, typing mismatch, or broken test. Never silence alerts with suppression directives without imperative justification.

### Phase 2: Project Rules and Migration Safety (Mandatory → Blocking)

Build a **rule ledger** once per run, then check every file in scope against it.

1. **Enumerate rule sources**: repository `AGENTS.md`/`CLAUDE.md` and every file they point to, every file under `docs/rules/`, and `CONTRIBUTING.md`/`CODING_STANDARDS.md` if present. List them by name.
2. **Select by applicability**: keep a rule file when its subject matches any path in scope (language, layer, directory, file type). **Test files are in scope**: testing, documentation, and language rules apply to them as much as to production code.
3. **Read each selected file in full.** Never sample a rule file with `head`, `tail`, or `grep`: a rule past the cut-off is a rule never applied.
4. **Extract rules**: short entries of the form *rule → where it applies → how to check it*. For preference-worded standards ("prefer", "avoid", "when possible"), record the conditions under which an alternative is allowed. Apply judgment to decide whether a violation exists; once identified, it is **Blocking** and budget-exempt. If the rule's meaning cannot be resolved from the source, escalate the ambiguity and keep the verdict blocked until the Human Layer decides.
5. **Check** every file in scope against every applicable ledger entry.

Reporting obligations:
- Every violation cites the rule **verbatim** (quoted text, rule file and section) and the `file:line` that breaks it.
- Every claimed exception quotes the exception clause that permits it. If no clause can be quoted, the exception does not exist and the violation stands. This applies with equal force to code written by the agent in this run.
- **Mechanizable rules**: when a rule can be checked by a linter, formatter, semgrep pattern, or test-framework setting that the project does not yet run, record one **Escalate** entry per rule proposing that automated check. Do not build the tooling. Each rule is escalated once, not once per violation.

**Migration Safety**: if database schema migrations or DDL files were added or modified, audit them against [database-and-migrations.md](../coding/references/database-and-migrations.md). Any table-locking DDL on active tables, missing `lock_timeout`, non-concurrent index creation, or destructive single-step schema change is **Blocking**. General quality judgments belong in Phase 5.

### Phase 3: BDD Definition of Done Coverage (Objective → Blocking)
For each requirement or acceptance criterion of the task:
1. **Verified via code**: name the test that verifies the behavior through the public interface (`file::test name`, not just a file), adhering to [testing.md](../coding/references/testing.md), and answer in one line: *if this behavior were removed, which assertion would fail?* Tests verifying internal details, adjacent concerns, or the behavior only indirectly do not qualify as coverage. Reason about it; never run mutation testing.
   - **Claims of enforcement** ("at most N", "never", "always", "rejected when"): name the code that enforces the claim (schema, validator, guard). A claim enforced only by prompt prose or documentation is not ✅.
   - **Wiring**: when a behavior exists only because something is registered or composed (plugin list, route table, dependency container, event subscription), ask *if the registration line were deleted, which test would fail?* If none, the behavior lacks coverage: test it through the composed entry point, not the glue in isolation.
2. **Untestable via code**: if the behavior cannot be code-tested ([testing.md](../coding/references/testing.md), Section 5), explicitly declare the following. A behavior that could be enforced by code (a limit a schema can express, a rule a validator can check) is testable: declaring it untestable is not allowed; if enforcing it requires a contract change, the behavior stays uncovered and the change is **Escalate**.
   - what the behavior is;
   - why it cannot be tested via code;
   - how it was verified through alternative means;
   - step-by-step instructions for human manual validation.

3. **Missing infrastructure**: if the behavior could only be tested with infrastructure the project currently lacks, declare it per Item 2 and flag the missing infrastructure as **Escalate**. Do not build the infrastructure.

4. **Removed tests**: list the test cases the range deletes, once per run:
   ```bash
   git diff -U0 <range> | grep -E '^-\s*(it|test|describe)(\.\w+)*\(|^-\s*(async\s+)?def test_'
   ```
   Each removed case needs a destination: the behavior was removed on purpose (cite the DoD item or decision), a named replacement test covers it, or it is declared per Item 2. A removed test with no destination is **Blocking**. Above 30 removed cases, group them by file.

> 🚨 Any DoD behavior lacking automated tests and lacking an explicit declaration is **Blocking**.

### Phase 4: Test Suite Sanity

Apply [testing.md](../coding/references/testing.md) to the tests in scope. Project testing rules (Phase 2 ledger) prevail over `testing.md` where they conflict: cite the project rule and do not "fix" a test toward the general guideline, or the next review reverts it.

**4a. Objective checks (Blocking)**, on test lines added or altered in the range:
- a production symbol that is private by convention or visibility (`_name`, `#field`, non-exported) imported or accessed by a test;
- a spy, mock, or monkeypatch replacing an internal collaborator (a module, store method, or class this codebase owns) instead of a boundary listed in `testing.md` Section 3;
- a sentinel stand-in (`object()`, `{}` cast to a type, bare `MagicMock()`) where the real collaborator or a fake implementing its port could run.

When no public path exists to reach the behavior, the remedy is a module extraction: **Escalate** instead (`testing.md` Section 1). A pattern the range only extends, already present in the file before the range, is pre-existing (Section 3.3).

**4b. Judgment checks (Should fix)**: tests prone to breaking during refactoring without behavior change (asserting copy, markup structure, CSS class names, log text, or collection sizes that are not the contract), subject to the Section 5 budget.

### Phase 5: Code Quality and Query Performance (Judgment → Blocking or Should fix)
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
- Category mapping per Section 2: credible critical scenario → **Blocking**; other concrete scenario → **Should fix**; no concrete scenario → **Discard**; touches contract/boundary → **Escalate**, with a blocked verdict if the underlying finding is Blocking.
- All remediations adhere to [refactoring-principles.md](../coding/references/refactoring-principles.md): preserved behavior, green tests.
- Architectural smells at module or contract scale are always **Escalate**, never local refactorings.

---

## 5. Loop and Convergence

### Phase Ordering
Execute objective checks (Phases 1, 2, 3, and 4a) first. Then execute judgment checks (4b, 5), classify critical scenarios and project rule violations as **Blocking**, and resolve all Blocking issues before discretionary Should fix remediations. A later discovery of a Blocking issue interrupts discretionary work.

### Budget
- Maximum of **5 Should fix remediations** per run, combining Phases 4b and 5, prioritized strictly by impact. Blocking findings, including critical risks and project standards, never consume this budget and cannot be listed as over budget or justified away.
- Judgment findings exceeding the budget are not deferred; they are named in a single line of the verdict (`Over budget: <title>, <title>`), so the human sees what was left.
- A finding classified **Should fix** never disappears silently: it ends as fixed, justified in one line, or over budget.

### Re-evaluation
- After applying fixes, re-run Phases **1 and 3** in their entirety (they are fast and deterministic).
- Re-run Phase **2** against the existing rule ledger, over the lines changed by the fixes. Do not rebuild the ledger or re-read rule files. Fixes are code like any other: a fix that breaks a ledger rule is Blocking.
- Re-run Phase **4a** over test lines changed by the fixes. Do not repeat the full Phases **4b and 5** review; inspect the fixes for critical defects as specified below.
- **Zero second-order discretionary findings**: do not repeat the full Phases 4b–5 review for marginal improvements. Still inspect every remediation for newly introduced critical defects or project rule violations; those remain Blocking, as do objective violations from Phases 1–3 and 4a.

### Iteration Limit
- Maximum of **3 rounds** of evaluate → fix → re-evaluate. This is a stopping limit on autonomous attempts, never an acceptance threshold for Blocking findings.
- If **Blocking** issues persist after round 3, stop with a **blocked** verdict. Document each unresolved finding, its impact, and what was attempted; request the necessary Human Layer decision or help. Do not deliver the code as clean, open or mark a pull request ready, or create a clean checkpoint. A later run must review the unresolved scope again.

### Anti-Oscillation
- If a proposed fix would revert a previous fix, or contradicts a decision already finalized in this review, **preserve the current implementation** and move forward only for discretionary findings. For Blocking findings, stop with a blocked verdict and document the conflict.

### Commit Traceability
- Self-review fixes are separate commits, authored after the implementation commit, adhering to [`commit`](../commit/SKILL.md). Never fold them into the implementation commit, even when the work was not yet committed when the review began: commit the implementation first.

---

## 6. Verdict

The deliverable is **clean** at the agent layer when:

- zero **Blocking** issues exist;
- every reported **Should fix** was remediated, justified in a single sentence, or named as over budget;
- every **Escalate** finding is logged as a pending Human Layer decision.

Record a concise traceability log: the reviewed range and mode, the rule files in the ledger, the DoD table with named tests, the removed-test destinations, what was fixed, what was justified, what was over budget, and what was escalated. Findings classified **Discard** are not recorded.

**Evidence of execution**: a phase without its evidence in the log (Phase 1 commands and results, Phase 2 ledger, Phase 3 table and removed-test list, Phases 4–5 files examined) did not run, and the verdict is not clean. When the review is delegated to a subagent, its brief carries the absolute path to this skill, and a report lacking this evidence is rejected, not relayed.

**Open escalations** are carried forward: branch mode lists every Escalate recorded on the branch that the human has not resolved, so it reaches the pull request instead of being lost in an earlier run.

**Checkpoint**: only when the verdict is clean and all work is committed, mark `HEAD` so the next increment starts there. A blocked verdict never creates or updates a clean checkpoint:

```bash
git notes --ref=self-review add -f -m "<increment|branch> clean <ISO-8601 date>" \
  -m "Escalate: <title>" HEAD   # one -m per open escalation, if any
```

Branch mode collects the open escalations recorded on the branch with `git log --notes=self-review --format=%N <merge-base>..HEAD | grep '^Escalate:'`.

The note stays local (git does not push notes by default) and never alters commit history.

---

## 7. Escape Classification

When a later review accepts a rules, tests, or code-quality finding on code this pipeline authored, the reviewing skill classifies why self-review let it through, per [escape-classification.md](references/escape-classification.md). Escaped findings never open a self-review round of their own.

---

## 8. Success Validation

- [ ] Scope was a git range (increment from the checkpoint, or branch against the merge-base), including merges and subagent commits; never an author-written summary.
- [ ] Objective checks (Phases 1–3, 4a) executed prior to judgment checks (4b, 5).
- [ ] The rule ledger lists every applicable rule file, each read in full; test files were checked against it.
- [ ] Every rule violation and every claimed exception quotes the rule text.
- [ ] Mechanizable rules without automated checks were escalated once each.
- [ ] Every ✅ DoD behavior names its test and the assertion that would fail without it; enforcement claims name the enforcing code; wiring behaviors have a test through the composed entry point.
- [ ] Every removed test case has a destination (removed behavior, named replacement, or declaration).
- [ ] Phase 4a objective checks ran on added test lines; project testing rules prevailed over `testing.md` where they conflict.
- [ ] Failure-path questions answered before code-quality judgment.
- [ ] Maximum 5 Should fix remediations applied across at most 3 iteration rounds; every Should fix ended fixed, justified, or named as over budget; no critical defect or project rule violation used that budget.
- [ ] The log carries evidence for every phase; delegated runs without that evidence were rejected.
- [ ] Fixes were re-checked against Phases 1–3 and 4a and inspected for new critical defects and project rule violations; no new discretionary judgment rounds opened.
- [ ] Zero contract, boundary, or dependency direction changes applied: all were escalated.
- [ ] Schema migrations and queries audited against [database-and-migrations.md](../coding/references/database-and-migrations.md) if database code was modified.
- [ ] Automated tests pass following the final remediation commit; fixes are committed separately; a clean checkpoint note is recorded on `HEAD` only when zero Blocking findings remain.
- [ ] In branch mode, ran at most once per head commit, with Phases 4b–5 restricted to cross-commit concerns.
