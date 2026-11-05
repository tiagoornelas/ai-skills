# Evidence Dossier

> **Central thesis**: the human supervises by evidence, not by approving every step. Each delivery proves five things in five short lines: it should be done, its architecture is sound, no wall was knocked down to build it, it cannot cause a catastrophe, and it was tested and works. An author grading itself tends to approve itself, so the last three lines come from an independent reviewer.

---

## When to consult

- Whenever a delivery reaches the human: a pull request ready for their review, a finished stream, a change reported as done. A delivery is always a specific version: the commit at the head of its branch or pull request.
- In a Herdr App team, the Leader assembles it and presents it when the delivery is ready ([`herdr-team-lead`](../../herdr-team-lead/SKILL.md)).

The dossier does not replace the notice that tier 2 requires before building ([the boundary test](../SKILL.md#4-the-boundary-test)) nor the briefing of the change ([Briefing a Change](human-facing-communication.md#3-briefing-a-change)): it is the proof that closes the briefing.

---

## 1. The Five Lines

Each line is a yes or no (✅ or ❌) followed by its proof, in the human's session language and in system terms. A "no" earns detail below its line; a "yes" stays one line.

| Line | Question it answers | Proof it cites | Built from | Attested by |
| :--- | :--- | :--- | :--- | :--- |
| **(a) Why do it** | Should this exist? The problem it solves and what was deliberately left out. | The issue or request, and the scope conclusion | [`scope-review`](../../scope-review/SKILL.md) | Author |
| **(b) Architecture** | Which modules it touches and which components are new (tier 2 items, each already announced). | The module map or the list of new components | [`software-designing`](../../software-designing/SKILL.md) | Author |
| **(c) No wall knocked down** | Boundaries, contracts, and dependency direction are intact; no project rule was bypassed; no test was disabled, skipped, or weakened. | Diff checks, contracts compared, rule files consulted | `software-designing` lenses, [`agent-self-review`](../../agent-self-review/SKILL.md) on the author side | Independent reviewer |
| **(d) No catastrophe** | What can break, which production data it touches, and how to undo it. | Affected flows and data, the rollback or revert path | [`human-review`](../../human-review/SKILL.md) risk assessment | Independent reviewer |
| **(e) Tested and works** | The checks and tests that ran, and one real run with its result. | Commands or CI runs, and the observed result of a real execution | `agent-self-review` on the author side | Independent reviewer |

```markdown
**Evidence · <delivery, in system terms> · <short commit hash>**
- ✅ (a) Why: <problem solved> · left out: <what and why> — <proof>
- ✅ (b) Architecture: touches <modules> · new: <components, or none> — <proof>
- ✅ (c) No wall knocked down: <boundaries, contracts, rules, tests intact> — <proof> · attested by <reviewer>
- ❌ (d) No catastrophe: <what can break> · production data: <none or which> · undo: <how> — <proof> · attested by <reviewer>
  <only on ❌: what is missing and what happens next>
- ✅ (e) Tested and works: <checks> · real run: <what ran where → result> — <proof> · attested by <reviewer>
```

- **Five lines, nothing more.** The dossier is a summary of proof, not a report. The Human Layer explanation of the change stays in its briefing or, on request, in `human-review`.
- **Proof, not assertion.** Each line names something the human could check: a command and its result, a CI run, a file of rules, a diagram. "Tested" without saying what ran is a no.
- **A line not yet proven is a no.** Write ❌ with what is missing, never a hopeful ✅.

---

## 2. The Independent Reviewer

Lines (c)–(e) are attested by a reviewer that did not write the change, preferably running on another model or harness.

- **Brief it with the change and the questions, not the answers.** Give it the diff or PR, the issue, the project rules, and the questions of lines (c)–(e). Do not send the author's own lines: a reviewer handed a conclusion tends to confirm it.
- **It reports yes or no with proof for each line**, and runs what it needs to (tests, a real execution) rather than trusting the author's output.
- **The attestation belongs to one version.** It names the commit it reviewed, and holds only for that commit.
- **Record it before ending the reviewer.** Store the five lines, with the reviewer and the commit, as a git note on that commit, then end the reviewer:

  ```bash
  git notes --ref=evidence add -f -m "<the five lines> · attested by <reviewer> at <ISO date-time>" <commit>
  ```

  The note survives the reviewer and any context loss; anyone presenting the delivery again reads it with `git notes --ref=evidence show <commit>`.
- **When a new review is needed.** Presenting the same commit again reuses its note. Any new commit on the delivery (a fix, a rebase, a merge from the base) needs a new attestation of lines (c)–(e) before the dossier is shown again; until then, the dossier shows the old commit's lines marked as outdated, never as current.
- **Disagreement goes to the dossier.** When the reviewer's answer differs from the author's, the reviewer's answer is the one shown, with the author's fix or rebuttal on the detail line.
- In a Herdr App team, the reviewer is a task started by the Leader ([`herdr-handoff`](../../herdr-handoff/SKILL.md#31-tasks)); elsewhere, a subagent per [subagent-delegation.md](subagent-delegation.md).

---

## Success Validation

- [ ] The delivery carried exactly five lines, each a yes or no with a checkable proof, in the human's language and system terms.
- [ ] Every "no" had a detail line on what is missing and what happens next; nothing unproven was marked yes.
- [ ] Lines (c)–(e) were attested by a reviewer that did not write the change, briefed with the change and the questions, not the author's answers.
- [ ] The attestation names the reviewed commit, was stored as an `evidence` git note on it before the reviewer ended, and was redone after any new commit on the delivery.
- [ ] Every new component in line (b) had been announced before it was built.
