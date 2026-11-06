# Evidence Dossier

> **Central thesis**: the human supervises by evidence, not by approving every step. Each delivery proves six things in six short lines: it should be done, its architecture is sound, no wall was knocked down to build it, nothing was built on the side of what the project already has, it cannot cause a catastrophe, and it was tested and works. Evidence must convince, not merely report: every line states its claim, why it convinces, and its proof, either an argument that cites what it rests on or a real proof the human can open or re-run. An author grading itself tends to approve itself, so the last four lines come from an independent reviewer: a fresh context that never saw the author's reasoning, which runs things itself.

---

## When to consult

- Whenever a delivery reaches the human: a pull request ready for their review, a finished stream, a change reported as done. A delivery is always a specific version: the commit at the head of its branch or pull request.
- The writer of a delivery, about to present it to the human as ready, has it verified first with [`provide-evidence`](../SKILL.md)'s verify action, and so does anyone when the human asks. Every delivery is presented with its [change card](../../ai-assisted-software-development/references/change-card.md).
- On demand, `provide-evidence` shows any delivery's dossier as recorded and judges each line against its proof, for one's own PRs or anyone else's.

The dossier does not replace the notice that tier 2 requires before building ([the boundary test](../../ai-assisted-software-development/SKILL.md#4-the-boundary-test)) nor the briefing of the change ([Briefing a Change](../../ai-assisted-software-development/references/human-facing-communication.md#3-briefing-a-change)): it is the proof that closes the briefing, next to the change card it proves.

---

## 1. The Six Lines

Each line is a yes or no (✅ or ❌) followed by its claim, why it convinces, and its proof ([below](#every-line-convinces-claim-why-proof)), in the human's session language and in system terms. A "no" earns detail below its line; a "yes" stays one line. The dossier and its note always carry **all six lines**: an attestation that holds only (c)–(f) leaves (a) and (b) as ❌ "no record".

| Line | Question it answers | Proof it cites (argument or real proof) | Built from | Attested by |
| :--- | :--- | :--- | :--- | :--- |
| **(a) Why do it** | Should this exist? The problem it solves and what was deliberately left out. | A link to the issue or request, and to the scope conclusion | [`scope-review`](../../scope-review/SKILL.md) | Author |
| **(b) Architecture** | Which modules it touches, which components are new (tier 2 items, each already announced), and which new structures it introduces (folders, modules, clients, configuration variables, cross-cutting mechanisms). | The touched modules listed from the diff, and the [change card](../../ai-assisted-software-development/references/change-card.md)'s plan: each new thing with where it lives and how it was approved | [`software-designing`](../../software-designing/SKILL.md) | Author; checked by the independent reviewer against the inventory it rebuilds from the diff |
| **(c) No wall knocked down** | Boundaries, contracts, and dependency direction are intact; no project rule was bypassed; no test was disabled, skipped, or weakened. | The diff of each contract or rule file checked (or the command showing it unchanged), and the diff of the test files | `software-designing` lenses, [`agent-self-review`](../../agent-self-review/SKILL.md) on the author side | Independent reviewer |
| **(d) Nothing built on the side** | Did the change reuse the project's established way of doing each kind of thing it introduces? | For each new structure: the existing sibling it follows (path), or the search showing none exists (command + result), or the recorded human decision approving the deviation (link) | The [nothing built on the side](../../software-designing/SKILL.md#nothing-built-on-the-side) lens; the author lists new structures in (b) | Independent reviewer |
| **(e) No catastrophe** | What can break, which production data it touches, and how to undo it. | The affected flows and data traced in the diff (files and lines), and the revert or rollback command | [`human-review`](../../human-review/SKILL.md) risk assessment | Independent reviewer |
| **(f) Tested and works** | The checks and tests that ran, and one real run **of the attested commit** with its result. | A CI run URL or a command with an excerpt of its real output, and the screenshot, recording, or log of the real run, naming the commit it ran on and, when one exists, the validation environment; for a user-visible change, screenshots per context ([visual proof](#visual-proof)) | `agent-self-review` on the author side | Independent reviewer |

### Every Line Convinces: Claim, Why, Proof

A result alone does not convince. Every line carries three parts, so the human can be convinced without trusting the writer and without reading the implementation:

1. **The claim**, in system terms: what is true of this change.
2. **Why it convinces**: one sentence linking the proof to the claim.
3. **The proof**, of one of two kinds:
   - an **argument**: reasoning, step by step, where every step cites what it rests on (the file and line, the diff excerpt, the rule's text, the issue). A human who knows the product can follow it to its conclusion without opening the code: "the purge only reads `expires_at` (`app/jobs/invoice_purge_job.rb:12`), which no other flow writes (`git grep expires_at` → this file and the migration only), so no other data can be deleted";
   - a **real proof**, something the human can open or re-run: a link (a CI run, the issue, the scope conclusion, a PR comment); a command with an excerpt of its real output (`npm test → 48 passed, 0 failed`), never a summary of it; a diff (`git diff <base>...<commit> -- <path>`) with its excerpt; the touched modules listed from the diff; a log, screenshot, or recording of the real run, in the [evidence folder](#where-artifacts-live).

A bare result ("✅ tested", "reviewed", "no risk", "tests pass") is ❌, whatever it claims, and so is an argument whose steps cite nothing. **The proof must prove that line's claim**, not merely exist: a bare list of modules does not prove (b) unless it comes from the diff; a bare revert command does not prove (e) unless the affected flows and data are named and the rollback path was checked against this change; a link to an unrelated issue does not prove (a). Lines (a)–(e) may rest on an argument; line (f) always needs a real proof of the real run.

### Visual Proof

When the change has a user interface or a behavior a user can see, line (f) includes screenshots (or a recording) of the attested commit, taken with [`browser-test`](../../browser-test/SKILL.md), organized by **context**: one flow or screen the human recognizes (`export-report`, `login-error`).

```text
.git/evidence/<commit>/
├── export-report/
│   ├── index.md            what each image shows · commit · environment
│   ├── 01-open-reports.png
│   └── 02-download-done.png
└── login-error/
    ├── index.md
    └── 01-wrong-password.png
```

- One subfolder per context, named with a short slug; images numbered in the order of the steps (`NN-<step>.png`).
- Each subfolder has an `index.md`: one line per image saying what it shows and what it proves, plus the commit it was taken on and the environment (local, review app, staging).
- Line (f) lists the contexts, each with its folder and one line on what it shows.

### The Real Run Belongs to the Attested Commit

Line (f) holds only when its real run executed the commit the dossier attests. A run of an earlier version is ❌ and names the version it ran on ("real run on `82a3742`, the PR is at `5b699b1`"). When the project has a validation environment (a review app, staging), line (f) names it and the commit it is running; a validation environment running another commit does not prove this one. Static checks and a textual simulation are not a real run.

```markdown
**Evidence · <delivery, in system terms> · <short commit hash>**
- ✅ (a) Why: <problem solved> · left out: <what and why> — because <why it convinces> — <issue link> · <scope conclusion link>
- ✅ (b) Architecture: touches <modules> · new: <each component (in the approved split | notice <date> | decided by <human> <date>), or none> — because <why it convinces> — <`git diff --stat <base>...<commit>` excerpt>
- ✅ (c) No wall knocked down: <boundaries, contracts, rules, tests intact> — because <why it convinces> — `git diff <base>...<commit> -- <contract or rule file>` → <excerpt, or "no change"> · attested by <reviewer>
- ✅ (d) Nothing built on the side: <each new structure> follows <existing sibling>, or none exists, or approved deviation — because <why it convinces> — <sibling path> · `<search command>` → <result> · <decision link> · attested by <reviewer>
- ❌ (e) No catastrophe: <what can break> · production data: <none or which> · undo: <how> — because <argument citing the files and lines traced> · `<revert command>` · attested by <reviewer>
  <only on ❌: what is missing and who acts>
- ✅ (f) Tested and works: <checks> · real run on <commit> in <where> → <result> — because <why it convinces> — <CI run URL, or `command` → output excerpt> · <log path> · attested by <reviewer>
  <for a user-visible change, one line per context: <context> · <folder> · <what its images show>>
```

- **Six lines, nothing more.** The dossier is a summary of proof, not a report. The Human Layer explanation of the change stays in its briefing or, on request, in `human-review`.
- **Every line shows its claim, why, and proof** ([above](#every-line-convinces-claim-why-proof)); a summary count such as "6/6" never stands in for the lines.
- **A line not yet proven is a no.** Write ❌ with what is missing, never a hopeful ✅.
- **Presented in full by whoever presents it.** When the evidence or analysis was produced by someone else (a subagent, the independent reviewer), the one presenting it to the human presents the dossier itself, in the human's language, on [`provide-evidence`](../SKILL.md#3-judge-and-write)'s screen: the change card's plan, every line with its claim and its proof inline, and the image contexts; the full argument from the note when the human points at a line. Never a summary, never "see the file", "see the tab", or "see the report", never only paths: links and paths follow the content as lookup keys, they are not the content.
- **No ❌, no merge request.** A delivery with any ❌, a proof of another version, or no change card is never presented as ready and never accompanied by a request to merge; it goes back to whoever closes the gap.

### Where Artifacts Live

- **The note** (Section 2) holds the six lines with their links, commands, and output excerpts. It stays on this machine: **never push `refs/notes/evidence`** to a remote, and never add it to a push refspec.
- **Files that do not fit in a note** (screenshots, recordings, long logs) go to `evidence/<commit>/` inside the repository's shared git directory (`"$(git rev-parse --path-format=absolute --git-common-dir)/evidence/<commit>/"`, `<commit>` being the full hash), with screenshots in one subfolder per context ([visual proof](#visual-proof)). Git never versions it, every worktree of the repository sees the same folder, and it outlives temporary-folder cleanups. The note cites the files by absolute path. Never write credentials or secrets there; crop or redact screenshots that show them.
- **Shared artifacts never cite these paths.** A PR body, commit, or review comment carries links that anyone can open (a CI run, the PR itself) and, when the human wants a file shared, the file attached to the PR, never a local path ([no local references](../../ai-assisted-software-development/references/no-local-references.md)).

---

## 2. The Independent Reviewer

Lines (c)–(f) are attested by a reviewer that did not write the change and starts from a clean context. The same harness and model are fine: independence comes from what the reviewer does not receive (the author's history, reasoning, and conclusions), not from a different engine.

- **It complements the author's self-review and never replaces it.** A delivery reaches the reviewer only with a clean branch-mode verdict from the author's [`agent-self-review`](../../agent-self-review/SKILL.md); without one, it goes back to the author. The reviewer attests lines (c)–(f) and neither redoes nor waives the quality review below contracts that `agent-self-review` owns.
- **Brief it with the change and the questions, not the answers.** Give it the diff or PR, the issue, the project rules, and the [questions](#reviewer-questions) of lines (c)–(f). Do not send the author's own lines or conversation history: a reviewer handed a conclusion tends to confirm it.
- **It produces the proof itself.** For lines (c)–(f) it runs the diffs, the codebase searches, the tests, and the real execution of the attested commit (with screenshots per context for a user-visible change), saves what does not fit in the note to the [evidence folder](#where-artifacts-live), and reports each line as claim, why it convinces, and proof; it never copies the author's output as its proof. When it cannot produce an artifact (no environment to run in, no access), the line is ❌ with what is missing.
- **It rebuilds the inventory of new things.** From the diff, the schema, and the infrastructure files (migrations, deploy and infrastructure definitions, job and route registrations, permission and secret settings), it lists every new thing in the change card's kinds and compares that list with the card that was announced and delivered. A new thing missing from the card, a card item absent from the change, an item without its approval, or no card at all makes (b) ❌ with the mismatch named.
- **It records all six lines.** It takes the author's (a) as given and checks only that it carries a claim, why it convinces, and a proof (otherwise ❌ "no proof"); it takes (b) after the inventory check; it writes them into the note with its own (c)–(f).
- **The attestation belongs to one version.** It names the commit it reviewed, and holds only for that commit.
- **Record it before ending the reviewer.** Store the six lines, with the reviewer and the commit, as a git note on that commit, then end the reviewer:

  ```bash
  git notes --ref=evidence add -f -m "<the six lines, each with its claim, why it convinces, and its proof> · attested by <reviewer> at <ISO date-time>" <commit>
  ```

  The note survives the reviewer and any context loss; anyone presenting the delivery again reads it with `git notes --ref=evidence show <commit>`. It stays local ([where artifacts live](#where-artifacts-live)).
- **When a new review is needed.** Presenting the same commit again reuses its note. Any new commit on the delivery (a fix, a rebase, a merge from the base) needs a new attestation of lines (c)–(f) before the dossier is shown again; until then, the dossier shows the old commit's lines marked as outdated, never as current.
- **Disagreement goes to the dossier.** When the reviewer's answer differs from the author's, the reviewer's answer is the one shown, with the author's fix or rebuttal on the detail line.
- It runs as a subagent per [subagent-delegation.md](../../ai-assisted-software-development/references/subagent-delegation.md), in any harness.
- **Old notes keep their letters.** A note written before line (d) existed has five lines; read its (c), (d), (e) as today's (c), (e), (f), and its (d) "nothing built on the side" as ❌ "no record".

### Reviewer Questions

Brief the reviewer with these questions, verbatim, together with the change and its change card. Answer each with the claim, why it convinces, and the proof: an argument citing the code, diff, or rule it rests on, or a real proof.

- **(b)** From the diff, the schema, and the infrastructure files, list every new database, table, migration, service, cloud function, job or schedule, queue, route or endpoint, secret or permission, recurring cost, folder or module, client, configuration variable, and cross-cutting mechanism, with where it lives. Compare your list with the change card: name every item missing from either side and every item without its approval.
- **(c)** Are boundaries, contracts, and dependency direction intact? Was any project rule bypassed? Was any test disabled, skipped, or weakened? Check each item of the **What I watch** list in the user's global instructions and name any the change breaks. Show the diff of each contract, rule, and test file you checked.
- **(d)** Apply the [nothing built on the side](../../software-designing/SKILL.md#nothing-built-on-the-side) lens: search the codebase for how the project already does each thing this change introduces. For every new folder, module, client, configuration variable, or cross-cutting mechanism (authentication, timeouts, retries, logging, error handling, data access), name the existing equivalent it follows, or show the search that found none. A parallel structure, a duplicated mechanism, or a departure from an established convention is ❌ unless a human decision recorded before the change approves it. A suggestion, the agent's own plan, or a reviewer's acceptance is not a human decision.
  Typical ❌: an HTTP client with its own timeout and retry beside the project's shared transport; a dedicated configuration variable where the project has a convention for that kind of setting; a new folder for something whose siblings live elsewhere.
- **(e)** What can break, which production data does it touch, and how is it undone? Trace the affected flows and data in the diff and check the revert or rollback path against this change.
- **(f)** Run the checks and tests and one real execution of the attested commit, in the validation environment when one exists. Show the output and the file or log of the real run, naming the commit it ran on. When the change has a user interface or user-visible behavior, take screenshots of that commit with `browser-test`, one subfolder per context with its `index.md`, per [visual proof](#visual-proof).

---

## Success Validation

- [ ] The delivery and its note carried all six lines, each a yes or no with its claim, why it convinces, and its proof (an argument citing what it rests on, or a real proof the human can open or re-run), in the human's language and system terms; no line was a bare result.
- [ ] Every "no" had a detail line on what is missing and what happens next; nothing unproven was marked yes.
- [ ] A user-visible change had screenshots of the attested commit in one subfolder per context, each with its `index.md`, listed in line (f).
- [ ] Line (f)'s real run executed the attested commit, named it, and named the validation environment and its commit when one exists.
- [ ] The evidence note stayed local (never pushed); files beyond the note sit in the repository's unversioned `.git/evidence/<commit>/` folder and are cited by absolute path; no shared artifact cites a local path.
- [ ] The delivery reached the reviewer only after a clean branch-mode `agent-self-review` verdict from its author; the reviewer complemented that review and did not replace or waive it.
- [ ] Lines (c)–(f) were attested by a reviewer that did not write the change, started from a clean context, was briefed with the change and the reviewer questions, not the author's answers, and produced its artifacts by running things itself.
- [ ] The attestation names the reviewed commit, was stored as an `evidence` git note on it before the reviewer ended, and was redone after any new commit on the delivery.
- [ ] The reviewer rebuilt the inventory of new things from the diff, schema, and infrastructure files and matched it with the change card; any mismatch, unapproved item, or missing card made (b) ❌ and no merge was requested.
- [ ] Every new structure was checked in line (d) against the project's existing equivalent.
