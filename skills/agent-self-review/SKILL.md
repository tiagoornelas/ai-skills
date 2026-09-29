---
name: agent-self-review
description: >-
  Autonomous quality gate executed by the coding agent on its own work prior to
  human review. Audits static tooling, project rules, Definition of Done (DoD)
  coverage, test sanity, and code quality below contracts, in a self-correction
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
| **Blocking** | Objective and deterministic: tool or test failure, documented project rule violation, DoD behavior lacking test coverage and lacking explicit declaration. | Always fix. |
| **Should fix** | Subjective judgment **with a concrete failure scenario**: able to articulate in a single sentence what probable bug, expensive future change, or reader confusion it causes. | Fix within the budget (Section 5) or justify in one line why it remains. |
| **Discard** | Judgment lacking a concrete scenario, personal style preference, "could be slightly cleaner". | Do not fix and do not record. |
| **Escalate** | The remediation would alter a public contract, module boundary, or dependency direction. | Do not apply. Record as a pending Human Layer decision. |

When uncertain between **Should fix** and **Discard**: if a concrete failure scenario does not come to mind immediately, discard it.

---

## 3. Scope

- Inspect **strictly what the current task created or altered**. Pre-existing defects in untouched files are out of scope, even if genuine.
- Exception: if a pre-existing issue causes project build/lint tooling to fail, treat it as **Escalate**, rather than scope-creeping cleanup.

---

## 4. Verification Phases

### Phase 1: Static Tooling and Tests (Objective → Blocking)
- Run project linters, static type checkers (`tsc`, `mypy`, etc.), and automated test suites.
- Resolve any syntax error, formatting defect, typing mismatch, or broken test. Never silence alerts with suppression directives without imperative justification.

### Phase 2: Project Rules (Objective → Blocking)
- Inspect documented guidelines: repository `AGENTS.md`/`CLAUDE.md` and rules under `docs/rules/`, if present.
- Violating a **documented** project rule is **Blocking**. General quality judgments belong in Phase 5.

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
- Apply [testing.md](../coding/references/testing.md) to the task's tests. Tests prone to breaking during refactoring without behavior change (coupled to text copy, markup structure, or internals), or exposing private symbols solely for testing, are **Should fix**, subject to the Section 5 budget.

### Phase 5: Code Quality (Judgment → Should fix)
- Apply [`coding`](../coding/SKILL.md) references (naming, functions, comments, error handling, code smells) to modified code, prioritized by impact per [code-smells.md](../coding/references/code-smells.md) (bug risk → change cost → readability).
- Category mapping per Section 2: concrete scenario → **Should fix**; no concrete scenario → **Discard**; touches contract/boundary → **Escalate**.
- All remediations adhere to [refactoring-principles.md](../coding/references/refactoring-principles.md): preserved behavior, green tests.
- Architectural smells at module or contract scale are always **Escalate**, never local refactorings.

---

## 5. Loop and Convergence

### Phase Ordering
Execute objective phases (1, 2, 3) first and resolve all **Blocking** issues. Only then execute judgment phases (4, 5) on the stabilized code.

### Budget
- Maximum of **5 Should fix remediations** per task, combining Phases 4 and 5, prioritized strictly by impact.
- Judgment findings exceeding the budget are **discarded**, not deferred.

### Re-evaluation
- After applying fixes, re-run Phases **1, 2, and 3** in their entirety (they are fast and deterministic).
- Phases **4 and 5 do not run again** over the whole codebase. Verify only that modified lines continue satisfying Phases 1–3.
- **Zero second-order findings**: smells introduced by a remediation never trigger an additional round of judgment review.

### Iteration Limit
- Maximum of **3 rounds** of evaluate → fix → re-evaluate.
- If **Blocking** issues persist after round 3, stop. Document the roadblock (what is failing, what was attempted) as a pending blocker for the human. Do not loop indefinitely.

### Anti-Oscillation
- If a proposed fix would revert a previous fix, or contradicts a decision already finalized in this review, **preserve the current implementation** and move forward.

### Commit Traceability
- Self-review fixes are separate commits, authored after the implementation commit, adhering to [`commit`](../commit/SKILL.md).

---

## 6. Verdict

The deliverable is **clean** at the agent layer when:

- zero **Blocking** issues exist (or persistent blockers are documented after round 3);
- every reported **Should fix** was remediated or justified in a single sentence;
- every **Escalate** finding is logged as a pending Human Layer decision.

Record a concise traceability log: what was fixed, what was justified, and what was escalated. Discarded findings are not recorded.

---

## 7. Success Validation

- [ ] Objective phases (1–3) executed prior to judgment phases (4–5).
- [ ] Strictly the task's modified code was evaluated.
- [ ] Maximum 5 Should fix remediations applied across at most 3 iteration rounds.
- [ ] Zero new rounds opened for second-order findings.
- [ ] Zero contract, boundary, or dependency direction changes applied: all were escalated.
- [ ] Automated tests pass following the final remediation commit.
