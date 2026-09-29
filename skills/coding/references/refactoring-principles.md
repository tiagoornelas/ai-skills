# Refactoring Principles

> **Central thesis**: refactoring is **altering internal code structure without changing observable behavior**. Refactoring is only safe when executed in small, incremental steps, with green tests before and after, and never conflated with functional behavior changes.

---

## When to consult

- Before modifying existing code that is difficult to change.
- In the "refactor" phase of the red → green → refactor cycle.
- When resolving a code smell finding (see [code-smells.md](code-smells.md)).
- When deciding whether a structural refactoring is worth the investment right now.

---

## 1. Rules

- **Preserve observable behavior.** If observable behavior changes, it is not a refactoring: it is a feature modification, requiring its own tests and Definition of Done.
- **Green tests before and after.** If the affected area lacks automated tests verifying behavior, author them first, or do not refactor.
- **Small steps.** Every micro-step leaves the test suite green. If a step breaks tests, revert the step immediately rather than debugging across a large diff.
- **Two distinct hats.** At any given moment, you are either adding new behavior or refactoring. Never combine both in the same step, and never in the same commit.

---

## 2. When to Refactor

- **Preparatory refactoring**: before introducing a change, restructure the code to make the change easy; then, make the easy change. This yields the highest return on investment.
- **Comprehension refactoring**: if deciphering a piece of code required significant effort, embed that understanding into the code (clearer naming, decomposing confusing conditionals).
- **Post-green cleanup**: during the "refactor" step of TDD, clean up the implementation code just written.

In all cases, **restrict refactoring to the code touched by the current task**. Refactoring adjacent, unrelated files expands diff size, elevates regression risk, and inflates review costs.

---

## 3. When Not to Refactor

- The code works, does not need modification, and no one needs to understand it today.
- The component is slated for rewrite or deprecation in the immediate future.
- Automated tests are absent, and creating them exceeds the value of the refactoring.
- The change reflects personal stylistic preference without a concrete maintenance or readability scenario.

---

## 4. Refactoring and the Human Layer

- Agent-driven refactoring takes place strictly **below contracts**. Any modification detectable by callers outside the module (public signatures, cross-module responsibilities, architectural boundaries, dependency direction) is not refactoring: it is a Human Layer concern, governed by the boundary test in [`ai-assisted-software-development`](../../ai-assisted-software-development/SKILL.md) (Section 4). Do not alter unilaterally; escalate via [`software-designing`](../../software-designing/SKILL.md).

---

## 5. Performance

- Author clean, obvious code first. Optimize later, strictly where **profiling and benchmarking** prove it is necessary, and isolate the optimization.

---

## Relationships

- What to refactor and concrete remediation patterns: [code-smells.md](code-smells.md).
- Why internal structure matters: [nature-of-complexity.md](../../software-designing/references/nature-of-complexity.md).
- Modifying existing systems at the architectural level: [strategic-programming.md](../../software-designing/references/strategic-programming.md) (Section 5).
- Separating refactoring commits from feature commits: [`commit`](../../commit/SKILL.md).
