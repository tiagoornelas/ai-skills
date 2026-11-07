---
name: correct
description: >-
  Finds the mistakes agents keep repeating in a repository and makes each one
  impossible, fixing it at the highest level that works: architecture, then
  types, then a lint or CI check whose error names the fix, then a test, and
  written agent rules last. Proves each new check fails on a real past
  mistake and keeps a table pairing each rule with what enforces it.
  Triggered by /correct, when the user corrects an agent for the same mistake
  a second time, or when an agent catches itself writing the same instruction
  a second time.
---

# Correct

Change the repository so the next agent cannot make the mistake again. A written rule fails silently when an agent skips it; a structure, type, or check fails loudly. So a lesson becomes text only when nothing can enforce it.

Assume every contributor is an agent that sees only the files it opened, copies the nearest example, and takes the shortest path that compiles. Design the repository so a change that looks right from one file is right for the whole repository.

## 1. Find the Mistake Classes

Read recent commits, reverts, review comments, the agent instruction files (AGENTS.md, CLAUDE.md, rule files), and comments that explain workarounds. Group the mistakes into classes. A class counts once it has happened twice; the correction the user just made counts as one occurrence.

## 2. Fix Each Class at the Highest Level That Works

1. **Eliminate it with architecture.** Give each piece of state one owner and each task one supported way. Hide internals so the wrong import fails. Replace hand-synced lists with one source of truth. Delete old ways and dead code an agent would copy.
2. **Enforce it with types**, so the bad state cannot be written ([domain models and types](../coding/references/domain-models-and-types.md)).
3. **Add a lint or CI check** when bad code still compiles, with an error message that names the file, type, or function to use instead. If the pattern is already common, fail only when a change adds more.
4. **Test the behavior.** Fix or delete any test that still passes when the behavior it checks breaks, or that fails when only the internals change.
5. **Write an agent rule last**, only for judgment calls nothing can check, following [`prompt-engineering`](../prompt-engineering/SKILL.md).

A fix at level 1, or one that alters a contract or module boundary, is a Human Layer decision: take it through [`software-designing`](../software-designing/SKILL.md) and present it for ratification. A new check, CI job, or lint dependency is a new thing on the delivery's [change card](../ai-assisted-software-development/references/change-card.md).

## 3. Fix and Prove

- Work as a delivery per [`agentic-parallel-work`](../agentic-parallel-work/SKILL.md), under [`coding`](../coding/SKILL.md), fixing the most frequent classes first, one commit each per [`commit`](../commit/SKILL.md), and pass [`agent-self-review`](../agent-self-review/SKILL.md) before delivering.
- Prove each new check fails on a real past mistake: check out or reproduce the offending code and show the check's failing output.
- Run the same command locally and in CI.
- An exception goes on the offending line with a reason, an expiry date, and the user's approval.

## 4. Keep the Rule Table

Keep a table in the project's agent instruction file that pairs each rule with what enforces it (a module, type, lint rule, check, test, or "judgment, no check").

- When the user corrects you, fix the mistake; once its class has recurred, fix it at the highest level and add the rule to the table.
- If the rule was already there and nothing enforces it, that is a repeat: fix it at the highest level in the same change.
- Drop a rule once its mistake can no longer happen.

## 5. Report

For each class: the occurrences that prove it, the level chosen, why a higher level did not work, and the failing output that proves the new check, in the user's language.

---

## Success Validation

- [ ] Each class was backed by at least two real occurrences.
- [ ] Each class was fixed at the highest level that works, and the report says why each higher level did not.
- [ ] Every new check was shown failing on a real past mistake and runs the same locally and in CI.
- [ ] Architecture or contract changes were decided through `software-designing` and presented for ratification, and new checks appeared on the change card.
- [ ] The rule table pairs each rule with its enforcer, and rules whose mistake can no longer happen were dropped.
- [ ] Written rules were added only for judgment calls, following `prompt-engineering`.
