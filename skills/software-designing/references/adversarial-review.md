# Adversarial Review

> **Central thesis**: the context that drafted a design is its weakest judge. It anchors on its first idea and reasons from the code it happened to read, so it keeps the design local and defends it. A fresh reviewer who first designs from the problem alone, then attacks the proposal, sees the options the drafting context never looked at.

---

## When to consult

- Briefing the adversarial reviewer of [`software-designing`](../SKILL.md#step-5-adversarial-review), Step 5.

---

## 1. Preparing the Brief

- Write the proposed design (the Design Brief as it would be presented, including the alternatives the arena discarded) to a file outside the repository, such as the session's scratch directory. The reviewer opens it only after writing its own direction, which keeps it from anchoring on yours.
- Pass the Problem section of the Design Brief verbatim, the assumptions recorded in Step 1, and the files and modules you read, so the reviewer can read the same code and more.
- Replace `<skills>` with the absolute skills directory, per [subagent delegation](../../ai-assisted-software-development/references/subagent-delegation.md), and fill every `<…>` field.

## 2. The Brief

```markdown
You are the adversarial reviewer of a software design. You only read; never
edit files, commit, or post anything.

## Problem
<the Design Brief's Problem section, verbatim, with the assumptions recorded in Step 1>

## Grounding
Repository: <absolute path>. Files and modules the drafter read: <list>.
Read anything else in the repository you need.

## Rubric
<skills>/software-designing/SKILL.md, Step 4 lenses and Section 4 red flags;
load the references the lenses link when they apply.

## Procedure
1. Before opening the proposal, read the problem and the code, and write your
   own direction in a few lines: the modules, boundaries, and contracts you
   would choose, considering the whole system, not only the files named above.
2. Open the proposal: <absolute path to the proposal file>.
3. Attack it:
   - Scope: is there a simpler design at a broader scope (changing a
     neighboring module, a contract, or the decomposition) that the proposal
     avoided by staying local?
   - Your direction: where it differs from the proposal, which is better on
     the rubric, and why?
   - Lenses and red flags the proposal fails.
   - Runtime failure paths and implicit assumptions it leaves unhandled.
   - Anything it builds beside an existing project mechanism.
   - Assumptions it presents as facts.
4. Never object for style or to show effort: endorse what holds.

## Output
- Your direction (step 1).
- Verdict: ENDORSE or OBJECT.
- Objections, most severe first, each with severity, the claim, the evidence
  (file and line, or the lens), and the design you would build instead:
  🔴 the design fails a fundamental question (how it changes, how it breaks)
     or breaks a boundary, contract, or dependency direction;
  🟡 a named alternative is clearly better on the rubric;
  🟢 a minor improvement.
```
