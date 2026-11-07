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

For ordinary implementation, **restrict refactoring to the code touched by the current task**. An explicitly requested architectural improvement defines its own agreed scope, including the affected modules; see [improve-architecture](../../improve-architecture/SKILL.md). Refactoring adjacent, unrelated files expands diff size, elevates regression risk, and inflates review costs.

---

## 3. Subtract, Migrate, Delete

The default direction of every change is toward less code. Each line kept is a line every future reader and agent must understand.

- **Subtract before you add.** Before building, remove dead code, redundant validators, unused parameters, and stale references in the code the task touches, then build on the simpler base. Write no guard, parser, or validator beyond what the requirement demands; design for observed usage, not speculative cases.
- **Migrate callers, then delete the old API, in the same change.** When a new internal API replaces an old one, move every caller and delete the old API together. Tests assert the new contract; tests that only protected the old implementation are deleted. No adapter, shim, or deprecated wrapper stays "for safety".
- **Converge on the end state.** In a planned rewrite or migration, write no temporary compatibility code to keep intermediate states working: reach the target design and verify the whole change, statically and at runtime, before delivering it.

**Boundary**: this applies to internal APIs below contracts, whose callers all change in the same delivery. A contract or boundary between modules, an API consumed outside the repository, or a database schema read by code still running during a deploy keeps a backward-compatible transition ([database-and-migrations.md](database-and-migrations.md), Section 2.2), and changing it is a Human Layer decision (Section 5).

---

## 4. When Not to Refactor

- The code works, does not need modification, and no one needs to understand it today.
- The component is slated for rewrite or deprecation in the immediate future.
- Automated tests are absent, and creating them exceeds the value of the refactoring.
- The change reflects personal stylistic preference without a concrete maintenance or readability scenario.

---

## 5. Refactoring and the Human Layer

- Autonomous internal refactoring takes place strictly **below contracts**. Any modification detectable by callers outside the module (public signatures, cross-module responsibilities, architectural boundaries, dependency direction) can be architectural refactoring when product behavior is preserved, but it is a Human Layer concern, governed by the boundary test in [`ai-assisted-software-development`](../../ai-assisted-software-development/SKILL.md) (Section 4). Decide it through [`software-designing`](../../software-designing/SKILL.md) and present it for ratification.

---

## 6. Performance

- Author clean, obvious code first. Optimize later, strictly where **profiling and benchmarking** prove it is necessary, and isolate the optimization. Vet every number before acting on it: [measuring-performance.md](measuring-performance.md).

---

## Relationships

- What to refactor and concrete remediation patterns: [code-smells.md](code-smells.md).
- Why internal structure matters: [nature-of-complexity.md](../../software-designing/references/nature-of-complexity.md).
- Modifying existing systems at the architectural level: [strategic-programming.md](../../software-designing/references/strategic-programming.md) (Section 5).
- Separating refactoring commits from feature commits: [`commit`](../../commit/SKILL.md).
