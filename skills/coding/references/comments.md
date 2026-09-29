# Comments

> **Central thesis**: explain intent **first through code**—via expressive names, types, and structure. Comment only what the code cannot state directly: the why, the design intent, and the non-obvious. Every comment must be **direct and concise**. An unnecessary comment is noise; an outdated comment is actively harmful.

---

## When to consult

- When authoring or modifying code.
- When reviewing comments in a code diff.

---

## 1. Explain Yourself in Code First

- Before writing a comment explaining **what** a block of code does, make the comment unnecessary: choose a clearer name ([naming.md](naming.md)), extract an independent helper ([functions.md](functions.md)), introduce an explanatory variable, or define a domain type.
- Comment only when clean code still leaves crucial context unsaid.

---

## 2. What to Comment

Strictly what is non-obvious from reading the code itself:

- **Public interfaces** (consumed by other modules): a concise docstring stating the contract—what it guarantees, side effects, failure modes, preconditions, units of measurement. Never describe implementation details.
- **The why** behind counter-intuitive decisions: working around an external vendor bug, operating system quirk, subtle business rule, or profiled performance optimization.
- **Consequence warnings**: what breaks if a specific line is altered.
- **Invariants and assumptions** that cannot be encoded in types or assertions.
- **Indirect flows**: when and by whom an event handler, hook, or callback is triggered.

**Internal, private functions do not take ritualistic docstrings.** If they require lengthy explanations, improve names and signatures first. If non-obvious context remains (an unavoidable side effect or unit), a single-line comment is sufficient.

---

## 3. What Not to Comment

- **Redundant comments**: repeating what the code already says.
- **Misleading comments**: stating something contradictory to current code behavior.
- **Obligatory boilerplate**: docstrings on private helpers that simply restate function names and parameters.
- **Change logs**: author names, timestamps, modification history (this belongs in git).
- **Commented-out code**: delete it. History is preserved in version control.
- **Banner markers**: visual dividers, section banners, block-end markers.
- **Non-local commentary**: comments describing distant parts of the system, which rot as soon as that other component evolves.

---

## 4. Keeping Comments Accurate

- **Locality**: interface comments live alongside declarations; implementation comments live directly adjacent to the relevant lines. The greater the physical distance, the faster comments rot.
- **In the code, not in the commit**: if knowledge is needed to understand or maintain code in the future, it belongs in the source code. Commit messages summarize and reference.
- **Single Source of Truth**: document each decision in one place—the most obvious place for maintainers. Everywhere else, link or reference.
- **Intent and invariants outlive mechanics**: comments explaining "why" remain accurate far longer than step-by-step descriptions of "how".
- **Review comments in diffs**: any functional behavior change must be accompanied by updates to all comments describing that behavior.

---

## Red Flags

- Comments explaining what confusing code does instead of cleaning up the code.
- Comments that contradict code behavior.
- Diffs altering behavior without updating corresponding comments.
- Public interfaces lacking documentation of contracts, preconditions, or side effects.
- The rationale for a strange workaround exists only in a ticket or PR description.
- Meaningless docstrings on private methods echoing parameter names.
- Dead, commented-out code blocks.

---

## How to Apply

- **When writing**: clarify the code first; then document remaining non-obvious context in concise, precise terms.
- **When reviewing**: a **misleading or outdated** comment presents a concrete failure scenario (the next maintainer will be misled) and warrants immediate correction. Redundant comments lack a concrete failure scenario: do not write them, but do not block PRs solely on benign stylistic noise.

---

## Relationships

- Self-documenting names: [naming.md](naming.md).
- Extracting functions to clarify intent: [functions.md](functions.md).
- Obscurity and required reader context: [obvious-code.md](../../software-designing/references/obvious-code.md).
- The informal contract of an interface: [deep-modules.md](../../software-designing/references/deep-modules.md).
