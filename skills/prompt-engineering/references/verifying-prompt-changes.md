# Verifying Prompt Changes

> **Central thesis**: a prompt change is proven by behavior, not by wording. Reading the diff shows that a sentence exists, not that the model now acts differently or that nothing else broke.

---

## When to consult

- After writing a prompt change, before reporting it.

---

## 1. Cold Read

Read the final prompt top to bottom as the model would: without the conversation that produced it. Flag anything that only makes sense to someone who saw the discussion, and search the loaded sources for leftovers of the old text. Remove or rewrite each one.

For larger changes, have a fresh agent with no context do this read and report what it finds unclear or contradictory.

## 2. Behavior Check

Scale this to the change: a value substitution or a pure removal of redundancy needs only the cold read; a change in behavior needs the scenarios below.

Pick a small fixed set of scenarios, all fictitious:

- the behavior the change targets;
- a variation of it with other names and situations, to confirm the rule generalizes;
- a neighboring case that must stay the same;
- a case where the new rule must not fire.

Run each scenario against the prompt before and after the change when a way to run it exists (an eval suite, a playground, a fresh agent given the prompt). Model output varies: repeat runs before calling a difference real. Without a way to run them, say so in the report and do not claim the behavior is fixed.

Create or edit prompt evals only when the user asks; follow the project's testing rules (see [`coding` testing](../../coding/references/testing.md)). Tests never assert prompt wording: they freeze the text and block future pruning.

For a skill, list the questions it must answer and the requests that must trigger it, and check that the edited version still answers and triggers on all of them.

## 3. Size Check

Measure the prompt before and after (characters, lines, or the project's token counter). When the project enforces a token budget, run its check. Raising a budget is the user's decision, never a way to pass the check.

## 4. Report

Report the change as a behavior diff, in the user's terms:

- what the model did before and does now;
- what was removed or rewritten, and what was added, with why each added sentence was needed;
- the size delta;
- how it was verified, or that it was not.
