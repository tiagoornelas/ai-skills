# Debugging

> **Central thesis**: fix the fault, not the place where it surfaced. The symptom is where a wrong state became visible; the root cause is the first place the system did something it should not do, or failed to handle a state it should handle. A symptom fix hides the evidence and leaves the fault free to surface elsewhere.

---

## When to consult

- Investigating a bug, a failing test, or behavior that contradicts expectations.
- When a fix did not work and another is about to be written.

---

## 1. Find the Root Cause

- **Reproduce first**, as an automated test when the project allows it ([test-driven-development.md](test-driven-development.md), Section 3).
- **Instrument instead of guessing.** Read the actual error and the actual state as the code runs; add logging or a probe when state is unclear.
- **Ask "why" at each step** until the answer is a wrong decision in the code, not a consequence of an earlier one.
- **Ask whether the triggering state is legitimate.** If the system may be in that state, the code that broke on it is the root cause and handling the state there is the fix. If the state should never exist, a check where it broke hides the bug: find what produced the state. Guards, retries, swallowed errors, clamped values, and discarded state are the usual ways to hide a bug.
- **Failing only after a restart** points to persisted state first: config files, caches, lock files, serialized state.

## 2. Attack the Premise

When two fixes that share one premise have failed the same check, suspect the premise, not the fixes: each failure is evidence against the belief it assumed.

1. Write the premise down: the one sentence every failed fix assumed.
2. Before any further fix, test it with an observation that would come out differently if the premise were false. Look at how the failures are distributed, not only at their size.
3. If the evidence contradicts the premise, look for what the failures share that the premise did not predict. If it confirms the premise, ask the next "why": the earlier fixes may have treated a consequence.
4. Remove the condition that causes the failure instead of adding a mechanism that cleans up after it.

## 3. Fix the Pattern

- **Fix every instance of the fault**, not only the one reported: search for the same pattern and fix them all within the task's scope; report the rest.
- **A workaround that needs a paragraph to justify it means the code is wrong.** Fix the code ([comments.md](comments.md)).
- **When the deciding fact took a deep dig to find**, propose the cheap, always-on signal (a log line, a metric, an assertion) that would have shown it at first look.

---

## Red Flags

- A fix that adds a guard, retry, or default where the bad state appeared, without explaining where the state came from.
- A third fix built on the premise two failed fixes already shared.
- A fix with no failing reproduction before it and no passing one after it.

---

## Relationships

- Reproducing a bug as a failing test: [test-driven-development.md](test-driven-development.md).
- Not swallowing or masking errors: [error-handling.md](error-handling.md).
- Partial failures and retries that leave bad state: [retries-and-concurrency.md](retries-and-concurrency.md).
