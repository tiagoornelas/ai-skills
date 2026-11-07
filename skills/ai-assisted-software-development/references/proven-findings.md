# Proven Findings

> **Central thesis**: a review finding that says the code misbehaves convinces only when a run shows it. A finding that reads right is not evidence: plausible findings sound equally convincing whether they are true or not, and each false one costs the author a fix and the reviewer's credibility.

---

## When to consult

- Reporting findings in any review: an agent's self-review, a review of someone else's pull request, or the independent reviewer of a delivery.

---

## 1. Prove Behavior Claims by a Run

- A finding that claims the code misbehaves (wrong output, a crash, a regression, a broken contract, bad data) is proven by running something against the real code: a failing test, a reproduction script, or command output that shows the wrong behavior.
- Report each proven finding with the exact command, the output it printed, and the output the intent requires.
- Keep reproductions in a scratch location, outside the delivery, unless one becomes the regression test.
- Merge findings that share a root cause. "No findings" is a valid result.

## 2. When No Run Is Possible

- Try to prove every behavior claim, critical ones included. When proving it needs something out of reach (production data, a third-party system, a race that will not trigger), report the finding as **unproven**, with what would prove it.
- An unproven finding is reported, never fixed on speculation, and never blocks, except a credible critical risk as [`agent-self-review`](../../agent-self-review/SKILL.md) defines it (Section 2): data loss or corruption, security exposure, irreversible side effects, or failure of a required behavior. Missing one costs more than reviewing a false one.

## 3. Findings That Are Not Behavior Claims

Findings about structure, readability, or the cost of future changes are not proven by a run: they keep their own rule, a concrete failure scenario stated in one sentence.

---

## Relationships

- How far each kind of proof convinces: the certainty ladder in the [evidence dossier](../../provide-evidence/references/evidence-dossier.md#every-line-convinces-claim-why-proof).
- Classifying findings in a self-review: [`agent-self-review`](../../agent-self-review/SKILL.md) (Section 2).
- Severity in a pull request review: [`pr-code-review`](../../pr-code-review/SKILL.md) (Section 3).
