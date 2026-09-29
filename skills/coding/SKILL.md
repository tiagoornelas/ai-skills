---
name: coding
description: >-
  Instructions and guidelines for implementing, writing, testing, and
  refactoring software code. Must be triggered whenever developing or modifying
  code in any project.
---

# Coding

Baseline skill for software implementation standards.

## Purpose
Centralize engineering guidelines, quality standards, and operational workflows for writing and modifying code.

## Activation Context
- Implementing new features.
- Bug fixing and refactoring.
- Writing and executing automated tests.

## Testing
Implement test-driven development following [test-driven-development.md](references/test-driven-development.md), governed by criteria in [testing.md](references/testing.md).

## Refactoring
Refactor before modifying code that is difficult to change, and after every passing test, restricted to the code touched by the current task, following [refactoring-principles.md](references/refactoring-principles.md).

## References

| Reference | Load when… |
| :--- | :--- |
| [test-driven-development.md](references/test-driven-development.md) | Beginning to implement a task or fix a bug. |
| [testing.md](references/testing.md) | Writing or reviewing tests. |
| [refactoring-principles.md](references/refactoring-principles.md) | Refactoring, or evaluating whether a structural improvement is worth the investment now. |
| [naming.md](references/naming.md) | Naming variables, functions, classes, or internal fields. |
| [functions.md](references/functions.md) | Writing, splitting, or reviewing functions. |
| [comments.md](references/comments.md) | Writing, maintaining, or reviewing comments. |
| [error-handling.md](references/error-handling.md) | Code may fail (I/O, network, external input, third-party services), or dealing with `try/catch`, error returns, or nullable types. |
| [code-smells.md](references/code-smells.md) | Evaluating or cleaning up code below contracts (conditionals, state, internal data, code placement). |

## Quality Gate
Upon completing code changes, the agent must execute the [`agent-self-review`](../agent-self-review/SKILL.md) skill and iterate until its code and tests achieve a clean verdict.

---

## Success Validation

- [ ] Implementation was test-driven (TDD) adhering to [test-driven-development.md](references/test-driven-development.md).
- [ ] Tests verify observable behavior through public interfaces adhering to [testing.md](references/testing.md).
- [ ] Refactorings preserved behavior with green tests adhering to [refactoring-principles.md](references/refactoring-principles.md).
- [ ] All modifications passed the [`agent-self-review`](../agent-self-review/SKILL.md) quality gate with a clean verdict.
