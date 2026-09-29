# Test-Driven Development by the Agent

> **Central thesis**: the agent implements software in a test-driven manner, **to the extent that the implementation allows**. Testing precedes code whenever an observable behavior and a viable way to test it using existing project infrastructure exist. Where automated testing is infeasible, the agent does not force brittle tests: it declares the behavior and proceeds.

---

## When to consult

- When beginning the implementation of any task.
- When fixing a bug.

---

## 1. Before Writing Code: Test Strategy

For each behavior in the Definition of Done (DoD), decide upfront:

1. **Is it testable via code?** See [testing.md](testing.md), Section 5. LLM prompt text, UI visual layout, static copy, environment configuration, and thin glue code are not.
2. **At what altitude?** Public interface behavior or component integration ([testing.md](testing.md), Section 1).
3. **With which infrastructure?** Strictly using what the project already has in place ([testing.md](testing.md), Section 4).

This step prevents the agent from building unwarranted scaffolding: the testing strategy is locked in beforehand, rather than discovered halfway through attempting to test untestable concerns.

---

## 2. The TDD Cycle

1. **Red**: write the test verifying a single behavior and **run it before implementing**. It must fail, and fail for the expected reason (the feature is not yet implemented, rather than a syntax or setup error). A test that has never failed proves nothing.
2. **Green**: write the minimal code necessary to make the test pass.
3. **Refactor**: with tests green, clean up the newly added code, adhering to [refactoring-principles.md](refactoring-principles.md).

One behavior per cycle. Tests are authored against public interfaces, as if the internal implementation does not yet exist. Consequently, tests have zero coupling to internal mechanics.

---

## 3. Bugs

- Before fixing a bug, write an automated test that reliably reproduces the defect and watch it fail. Then fix the bug.

---

## 4. Where TDD Does Not Apply

- For concerns not testable via code, implement directly and **write the declaration immediately**: state the behavior, explain why it cannot be tested via code, describe how it was verified, and provide step-by-step instructions for human validation.
- Test surrounding logic that is testable (e.g., parsing logic that handles an LLM response, using a stubbed LLM), even if the model core itself is not code-testable.

---

## 5. When Infrastructure is Missing

- If an important behavior would only be testable with infrastructure the project currently lacks, **do not build that infrastructure**.
- Declare the behavior as untestable under current project setup, and log the infrastructure gap as a **pending recommendation for the human**, outlining what capabilities it would unlock.

---

## Red Flags

- Implementation code written prior to writing tests for a testable behavior.
- A test passing on its very first run before any implementation was written.
- Test infrastructure created merely to enable testing a single task behavior.
- Tests written for concerns explicitly flagged as untestable in Section 5 of [testing.md](testing.md).
- Untestable behaviors left without explicit declarations.

---

## Relationships

- What constitutes a high-quality test: [testing.md](testing.md).
- The refactoring phase: [refactoring-principles.md](refactoring-principles.md).
