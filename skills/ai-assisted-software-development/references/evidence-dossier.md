# Evidence Dossier

> **Central thesis**: the human supervises by evidence, not by approving every step. Each delivery proves six things in six short lines: it should be done, its architecture is sound, no wall was knocked down to build it, nothing was built on the side of what the project already has, it cannot cause a catastrophe, and it was tested and works. Evidence is not saying, it is showing: every line cites an artifact the human can open or re-run. An author grading itself tends to approve itself, so the last four lines come from an independent reviewer: a fresh context that never saw the author's reasoning, which runs things itself.

---

## When to consult

- Whenever a delivery reaches the human: a pull request ready for their review, a finished stream, a change reported as done. A delivery is always a specific version: the commit at the head of its branch or pull request.
- In a Herdr App team, the Leader assembles it and presents it when the delivery is ready ([`herdr-team-lead`](../../herdr-team-lead/SKILL.md)).
- On demand, [`provide-evidence`](../../provide-evidence/SKILL.md) shows a delivery's dossier as recorded, judges each line against its artifact, and, outside the Herdr App, offers to run the independent reviewer when lines (c)–(f) are missing.

The dossier does not replace the notice that tier 2 requires before building ([the boundary test](../SKILL.md#4-the-boundary-test)) nor the briefing of the change ([Briefing a Change](human-facing-communication.md#3-briefing-a-change)): it is the proof that closes the briefing.

---

## 1. The Six Lines

Each line is a yes or no (✅ or ❌) followed by its proof, in the human's session language and in system terms. A "no" earns detail below its line; a "yes" stays one line. The dossier and its note always carry **all six lines**: an attestation that holds only (c)–(f) leaves (a) and (b) as ❌ "no record".

| Line | Question it answers | Artifact it cites | Built from | Attested by |
| :--- | :--- | :--- | :--- | :--- |
| **(a) Why do it** | Should this exist? The problem it solves and what was deliberately left out. | A link to the issue or request, and to the scope conclusion | [`scope-review`](../../scope-review/SKILL.md) | Author |
| **(b) Architecture** | Which modules it touches, which components are new (tier 2 items, each already announced), and which new structures it introduces (folders, modules, clients, configuration variables, cross-cutting mechanisms). | The module map (diagram or list of touched modules from the diff), each new component with how it was approved (in the approved split, the notice and its date, or the human's decision and its date), and the list of new structures | [`software-designing`](../../software-designing/SKILL.md) | Author |
| **(c) No wall knocked down** | Boundaries, contracts, and dependency direction are intact; no project rule was bypassed; no test was disabled, skipped, or weakened. | The diff of each contract or rule file checked (or the command showing it unchanged), and the diff of the test files | `software-designing` lenses, [`agent-self-review`](../../agent-self-review/SKILL.md) on the author side | Independent reviewer |
| **(d) Nothing built on the side** | Did the change reuse the project's established way of doing each kind of thing it introduces? | For each new structure: the existing sibling it follows (path), or the search showing none exists (command + result), or the recorded human decision approving the deviation (link) | `software-designing` lenses; the author lists new structures in (b) | Independent reviewer |
| **(e) No catastrophe** | What can break, which production data it touches, and how to undo it. | The affected flows and data traced in the diff (files and lines), and the revert or rollback command | [`human-review`](../../human-review/SKILL.md) risk assessment | Independent reviewer |
| **(f) Tested and works** | The checks and tests that ran, and one real run **of the attested commit** with its result. | A CI run URL or a command with an excerpt of its real output, and the screenshot, recording, or log of the real run, naming the commit it ran on and, when one exists, the validation environment | `agent-self-review` on the author side | Independent reviewer |

### Proof Is an Artifact, Not Prose

A line is proven only by something the human can open or re-run without trusting the writer:

- a **link**: a CI run URL, the issue or request, the scope conclusion, a PR comment;
- a **command with an excerpt of its real output**: the command as run, and the few output lines that carry the result (`npm test → 48 passed, 0 failed`), never a summary of it;
- a **file of the real run**: a screenshot, a recording, or a log, by its path in the [evidence folder](#where-artifacts-live);
- a **diff**: of the contract or rule file checked, or of the test files, as a command (`git diff <base>...<commit> -- <path>`) with its excerpt;
- a **module map**: a diagram or list of touched modules, derived from the diff.

A line whose proof is only an assertion ("tests pass", "reviewed", "no risk") is ❌, whatever it claims. **The artifact must prove that line's claim**, not merely exist: a bare list of modules does not prove (b) unless it comes from the diff; a bare revert command does not prove (e) unless the affected flows and data are named and the rollback path was checked against this change; a link to an unrelated issue does not prove (a). An artifact that does not prove its line's claim is ❌. "Tested" without the command and its output, or a "real run" described in words without its file or log, is a no.

### The Real Run Belongs to the Attested Commit

Line (f) holds only when its real run executed the commit the dossier attests. A run of an earlier version is ❌ and names the version it ran on ("real run on `82a3742`, the PR is at `5b699b1`"). When the project has a validation environment (a review app, staging), line (f) names it and the commit it is running; a validation environment running another commit does not prove this one. Static checks and a textual simulation are not a real run.

```markdown
**Evidence · <delivery, in system terms> · <short commit hash>**
- ✅ (a) Why: <problem solved> · left out: <what and why> — <issue link> · <scope conclusion link>
- ✅ (b) Architecture: touches <modules> · new: <each component (in the approved split | notice <date> | decided by <human> <date>), or none> — <module map, or `git diff --stat <base>...<commit>` excerpt>
- ✅ (c) No wall knocked down: <boundaries, contracts, rules, tests intact> — `git diff <base>...<commit> -- <contract or rule file>` → <excerpt, or "no change"> · attested by <reviewer>
- ✅ (d) Nothing built on the side: <each new structure> follows <existing sibling>, or none exists, or approved deviation — <sibling path> · `<search command>` → <result> · <decision link> · attested by <reviewer>
- ❌ (e) No catastrophe: <what can break> · production data: <none or which> · undo: <how> — <files and lines traced> · `<revert command>` · attested by <reviewer>
  <only on ❌: what is missing and who acts>
- ✅ (f) Tested and works: <checks> · real run on <commit> in <where> → <result> — <CI run URL, or `command` → output excerpt> · <path to screenshot or log> · attested by <reviewer>
```

- **Six lines, nothing more.** The dossier is a summary of proof, not a report. The Human Layer explanation of the change stays in its briefing or, on request, in `human-review`.
- **Every line shows its artifact.** Each line ends with at least one [artifact](#proof-is-an-artifact-not-prose); a summary count such as "6/6" never stands in for the lines.
- **A line not yet proven is a no.** Write ❌ with what is missing, never a hopeful ✅.

### Where Artifacts Live

- **The note** (Section 2) holds the six lines with their links, commands, and output excerpts. It stays on this machine: **never push `refs/notes/evidence`** to a remote, and never add it to a push refspec.
- **Files that do not fit in a note** (screenshots, recordings, long logs) go to a local evidence folder outside the repository, one per attested commit, and the note cites them by absolute path. In a Herdr App team, the folder is `~/.herdr-teams/<space-id>/evidence/<short-commit>/` ([team folder](../../herdr-team-lead/references/team-folder.md)); elsewhere, a scratch or temporary folder of the harness, outside the repository. Never write credentials or secrets there; crop or redact screenshots that show them.
- **Shared artifacts never cite these paths.** A PR body, commit, or review comment carries links that anyone can open (a CI run, the PR itself) and, when the human wants a file shared, the file attached to the PR, never a local path ([no local references](no-local-references.md)).

---

## 2. The Independent Reviewer

Lines (c)–(f) are attested by a reviewer that did not write the change and starts from a clean context. The same harness and model are fine: independence comes from what the reviewer does not receive (the author's history, reasoning, and conclusions), not from a different engine.

- **It complements the author's self-review and never replaces it.** A delivery reaches the reviewer only with a clean branch-mode verdict from the author's [`agent-self-review`](../../agent-self-review/SKILL.md); without one, it goes back to the author. The reviewer attests lines (c)–(f) and neither redoes nor waives the quality review below contracts that `agent-self-review` owns.
- **Brief it with the change and the questions, not the answers.** Give it the diff or PR, the issue, the project rules, and the [questions](#reviewer-questions) of lines (c)–(f). Do not send the author's own lines or conversation history: a reviewer handed a conclusion tends to confirm it.
- **It produces the artifacts itself.** For lines (c)–(f) it runs the diffs, the codebase searches, the tests, and the real execution of the attested commit, saves what does not fit in the note to the [evidence folder](#where-artifacts-live), and reports yes or no with those artifacts; it never copies the author's output as its proof. When it cannot produce an artifact (no environment to run in, no access), the line is ❌ with what is missing.
- **It records all six lines.** It takes the author's (a) and (b) as given, checks only that each cites an artifact (otherwise ❌ "no artifact"), and writes them into the note with its own (c)–(f).
- **The attestation belongs to one version.** It names the commit it reviewed, and holds only for that commit.
- **Record it before ending the reviewer.** Store the six lines, with the reviewer and the commit, as a git note on that commit, then end the reviewer:

  ```bash
  git notes --ref=evidence add -f -m "<the six lines, each with its artifacts> · attested by <reviewer> at <ISO date-time>" <commit>
  ```

  The note survives the reviewer and any context loss; anyone presenting the delivery again reads it with `git notes --ref=evidence show <commit>`. It stays local ([where artifacts live](#where-artifacts-live)).
- **When a new review is needed.** Presenting the same commit again reuses its note. Any new commit on the delivery (a fix, a rebase, a merge from the base) needs a new attestation of lines (c)–(f) before the dossier is shown again; until then, the dossier shows the old commit's lines marked as outdated, never as current.
- **Disagreement goes to the dossier.** When the reviewer's answer differs from the author's, the reviewer's answer is the one shown, with the author's fix or rebuttal on the detail line.
- In a Herdr App team, the reviewer is a sub-agent started by the Leader ([`herdr-handoff`](../../herdr-handoff/SKILL.md#31-sub-agents)); elsewhere, a subagent per [subagent-delegation.md](subagent-delegation.md).
- **Old notes keep their letters.** A note written before line (d) existed has five lines; read its (c), (d), (e) as today's (c), (e), (f), and its (d) "nothing built on the side" as ❌ "no record".

### Reviewer Questions

Brief the reviewer with these questions, verbatim, together with the change:

- **(c)** Are boundaries, contracts, and dependency direction intact? Was any project rule bypassed? Was any test disabled, skipped, or weakened? Show the diff of each contract, rule, and test file you checked.
- **(d)** Search the codebase for how the project already does each thing this change introduces. For every new folder, module, client, configuration variable, or cross-cutting mechanism (authentication, timeouts, retries, logging, error handling, data access), name the existing equivalent it follows, or show the search that found none. A parallel structure, a duplicated mechanism, or a departure from an established convention is ❌ unless a human decision recorded before the change approves it. A suggestion, the agent's own plan, or a reviewer's acceptance is not a human decision.
  Typical ❌: an HTTP client with its own timeout and retry beside the project's shared transport; a dedicated configuration variable where the project has a convention for that kind of setting; a new folder for something whose siblings live elsewhere.
- **(e)** What can break, which production data does it touch, and how is it undone? Trace the affected flows and data in the diff and check the revert or rollback path against this change.
- **(f)** Run the checks and tests and one real execution of the attested commit, in the validation environment when one exists. Show the output and the file or log of the real run, naming the commit it ran on.

---

## Success Validation

- [ ] The delivery and its note carried all six lines, each a yes or no with at least one artifact the human can open or re-run (link, command with output excerpt, file of the real run, diff, module map), in the human's language and system terms.
- [ ] Every "no" had a detail line on what is missing and what happens next; nothing unproven was marked yes, and no line rested on an assertion alone.
- [ ] Line (f)'s real run executed the attested commit, named it, and named the validation environment and its commit when one exists.
- [ ] The evidence note stayed local (never pushed); files beyond the note sit in the evidence folder outside the repository and are cited by absolute path; no shared artifact cites a local path.
- [ ] The delivery reached the reviewer only after a clean branch-mode `agent-self-review` verdict from its author; the reviewer complemented that review and did not replace or waive it.
- [ ] Lines (c)–(f) were attested by a reviewer that did not write the change, started from a clean context, was briefed with the change and the reviewer questions, not the author's answers, and produced its artifacts by running things itself.
- [ ] The attestation names the reviewed commit, was stored as an `evidence` git note on it before the reviewer ended, and was redone after any new commit on the delivery.
- [ ] Every new component in line (b) named its approval and had been announced before it was built, and every new structure it lists was checked in line (d) against the project's existing equivalent.
