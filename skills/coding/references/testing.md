# Testing: What Constitutes a Good Test

> **Central thesis**: the fundamental unit of a test is an **observable behavior through a public interface**, not a class or method. The test configures real state, invokes the public interface, and asserts the observable outcome, without inspecting internal mechanisms. A good test **breaks only when observable behavior changes**, and never because of internal refactorings that callers outside the module cannot detect.

---

## When to consult

- When writing automated tests (workflow detailed in [test-driven-development.md](test-driven-development.md)).
- When reviewing tests, whether written by agents or humans.

---

## 1. Test Altitude

| Altitude | Definition | When to Use |
| :--- | :--- | :--- |
| **Public Interface Behavior** | Invokes a public function or class contract and asserts the result. | Discrete logic with a defined contract: calculations, business rules, transformations. |
| **Component Integration** | Boots necessary runtime environment (in-memory database, DI context) and invokes the subsystem through its public interface, allowing internal collaborators to interact freely. | Behaviors emerging from collaboration across internal parts of a module. |

- **Never expose internal symbols solely for testing.** Nothing is exported, made public, or accessed via reflection/private property access just so a test can reach it. Internal logic is validated exclusively through the public behavior it produces.
- If an internal component feels impossible to test through the public interface, that signals it is a distinct module waiting to be extracted. Creating that module is an architectural design decision: Human Layer.

---

## 2. Tests Break Only When Behavior Changes

Do not make assertions on:

- **Text**: prompt wording, visual UI labels, error strings, copy.
- **Structure**: markup trees, internal call sequences, private variable names, internal data formats.
- **Snapshots** of DOM trees, markup, or internal representations. Snapshots are only acceptable when the captured payload **is** the observable contract (e.g., the public JSON response of a REST endpoint).

In frontend tests, query elements by **role** (`role`) when unique on screen, without matching on transient label text. When non-unique, use a **stable identifier** (`data-testid`). Assert on the **observable effect** of the interaction (what happens after clicking), not on the presence of decorative copy.

```ts
// Brittle: breaks whenever copy changes, with zero behavioral change
expect(screen.getByText("Save changes")).toBeInTheDocument();

// Robust: selects by semantic role and asserts observable effect
await user.click(screen.getByRole("button"));
expect(await api.savedProfile()).toEqual(editedProfile);
```

---

## 3. Test Doubles Only at Boundaries Outside Your Control

- Use test doubles (fakes, stubs, mocks) strictly for components outside your runtime control: external third-party services, network I/O, system clock, randomness, LLM APIs.
- **Internal collaborators run for real.** Mocking internal classes tightly couples tests to implementation details, causing tests to break during harmless refactorings.
- Prefer fakes that implement domain ports (e.g., an in-memory repository implementation) over mock frameworks verifying call counts. See [dependency-direction.md](../../software-designing/references/dependency-direction.md).

---

## 4. Leverage Existing Project Infrastructure

- Author tests using the frameworks, runner types, and conventions **already established in the project**. If integration tests with a database exist, leverage them.
- If a specific testing tier does not exist in the repository and creating it is outside task scope, operate strictly within available testing tiers.
- **Introducing new test infrastructure** (new test runners, containerized test databases, end-to-end browser harnesses) is never a side effect of a coding task. It is a Human Layer scoping decision.

---

## 5. What Should Not Be Code-Tested

Do not write automated unit/integration tests for:

- **LLM prompt content** and agent instructions;
- **visual UI layout** and marketing copy;
- **static configuration** files;
- **declarative glue code** lacking domain logic.

Test what the system **does** with these inputs. For instance: test how an LLM output is parsed, validated, and routed, using a stubbed LLM response. Behaviors that cannot be verified via code are **declared**: what the behavior is, why it is not code-testable, how it was verified, and steps for human validation.

**Prompt evals** are distinct from code tests. Do not create or edit evals unless explicitly requested by the user.

---

## 6. Selecting What to Test

- **Test for risk, not vanity coverage.** Concentrate automated tests where failure has the highest likelihood and severity. Imperfect tests that run reliably beat exhaustive test suites that never get written.
- **Explore edge cases**: empty inputs, zero, negative numbers, invalid payloads, collection boundary limits.
- **Every bug begins with a reproducing test**.

---

## 7. Test Structure and Quality

- **Fresh fixture per test.** No shared mutable state between test cases; execution order must never matter.
- **One behavior per test**, with a descriptive name declaring both the scenario and expected outcome.
- **Fast execution**, encouraging frequent runs.
- **Deterministic**: zero dependency on real wall-clock time, external networks, or race conditions.

---

## Red Flags

- Assertions checking prompt strings, button copy, or HTML markup.
- Functions, properties, or methods exported or broadened to public visibility solely for testing.
- Mocking internal collaborators or verifying internal function call sequences.
- Tests breaking during refactoring despite observable behavior remaining identical.
- New test infrastructure introduced as part of an unrelated task.
- Shared mutable fixtures; tests failing when executed in random order.
- A test that has never failed.
- Snapshot testing of layout markup.

---

## How to Apply

- **When writing**: choose the right altitude, use existing project infrastructure, test through public interfaces, and restrict test doubles to external boundaries.
- **When reviewing**: tests tightly coupled to text, structure, or internals represent concrete maintenance risk (they will break during refactoring) and warrant correction. Untested high-risk behaviors similarly warrant action.

---

## Relationships

- How the agent executes TDD: [test-driven-development.md](test-driven-development.md).
- Refactoring under green tests: [refactoring-principles.md](refactoring-principles.md).
- Ports and in-memory test doubles: [dependency-direction.md](../../software-designing/references/dependency-direction.md).
- Public interfaces as contracts: [deep-modules.md](../../software-designing/references/deep-modules.md).
