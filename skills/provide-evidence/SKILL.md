---
name: provide-evidence
description: >-
  Owns the evidence of a delivery, for any pull request or branch (one's own
  or someone else's), in any project and harness. Two actions: "show the
  proof" (default, read-only) gives a one-line verdict, the objective, and per
  PR the change card and the six evidence dossier lines (a)–(f), each
  with its claim and its proof and, under every failing line, what is missing
  and who acts; "verify and produce what is missing" runs the dossier's
  independent reviewer, which rebuilds the inventory of new things from the
  diff, compares it with the change card, and attests lines (c)–(f) for the
  current commit. Verify runs at the PR-and-proof stage of every delivery,
  before its writer sends the delivery report, and whenever the user asks.
  Triggered when the user asks for the evidence, the proof, or whether a
  delivery is done, and when a delivery's draft PRs are open.
argument-hint: "[PR number, URL, or branch] [verify]"
---

# Provide Evidence

The user needs to know at once: **is the work done, what does it add to the system and where, and what proves it?** This skill answers from observation and shows the proof itself, not a count of it. Evidence must convince: every line carries its claim, why it convinces, and its proof, an argument that cites what it rests on or a real proof the user can open or re-run, per the [evidence dossier](references/evidence-dossier.md), which this skill owns.

## 1. Scope and Action

- **Scope**: the PR or branch given as argument; without one, the PR of the current branch (`gh pr view --json number`); without a PR, the current branch itself, compared with its base. Any PR works, whoever wrote it.
- **Show the proof** (default): read-only. Never run tests, fix, commit, push, merge, write a note or file, or message an agent; when the verdict is not ✅ and this session wrote the delivery, it switches to verify (Section 3).
- **Verify and produce what is missing**: run the [independent reviewer](#4-verify) for the current head, in any harness, at [stage 4](../agentic-parallel-work/SKILL.md#2-the-stages) of every delivery (its draft PRs open, before the delivery report), whenever its writer says it is done or stops working on it, and when the user asks.
- When `gh` is missing or not authenticated, show what git alone proves and say the PR part was skipped; never guess PR states.

## 2. Gather

Observe in parallel where the harness allows it.

| Fact | Source |
| :--- | :--- |
| PR state | `gh pr view <pr> --json number,title,url,state,isDraft,mergeable,statusCheckRollup,headRefOid,baseRefName,author` |
| Objective | the issue referenced by the branch, the commits, or the conversation; for someone else's PR, the issue its description links; otherwise "not verifiable" |
| Task status | each task found for the objective, from whatever tracker it points to through the tools the harness reaches; an unreachable tracker reads "status unavailable" |
| Author's review | `git notes --ref=self-review show <head>`: only a `branch clean` note on the head counts |
| The user's review | `git notes --ref=human-review show <head>`, and the user's reviews on the PR: `gh pr view <pr> --json reviews` filtered by the login from `gh api user --jq .login` |
| Evidence | `git notes --ref=evidence show <head>`; when absent, the newest `evidence` note on an earlier commit of the branch (`git log --format=%H <base>..<head>`) |
| Artifacts the note cites | the links, commands, and local file paths inside the note; check each local file exists |
| Base moved after the proof | `git fetch origin <base>`, then `git log --format='%h %an %cI %s' <proven commit>..origin/<base>`: commits dated after the attestation moved the base; name each one's author and PR |
| The change card | always, for every PR, the inventory of new things **rebuilt** from the diff, schema, and infrastructure files, in the kinds of the [change card](../ai-assisted-software-development/references/change-card.md) (for a large PR, from `git diff --name-status` plus the full diff of only the schema, migration, job, route, secret, configuration, and client files, saying so); and the card presented with the delivery (in the conversation, the issue, or the `evidence` note), when there is one. Each item's ratification comes from the issue or the conversation; otherwise it is a `?` line |
| Uncommitted files | `git status --porcelain` in the current checkout |
| Validation environment's deployed commit | read it, at the time of asking, where the project records how (a deploy URL, a status endpoint, a CI environment); "not observable" when it records none |

**Re-check before printing.** Read each PR's `headRefOid` again right before writing; if it moved, mark that card's evidence as outdated for the new head. Never copy secrets or credentials from output, notes, or logs.

## 3. Judge and Write

For every PR, take the six lines from its evidence note and judge each per the dossier's [claim, why, proof](references/evidence-dossier.md#every-line-convinces-claim-why-proof) rule: ✅ only when the line carries its claim, why it convinces, and a proof that **proves that claim** (an argument whose steps cite the code, diff, or rule, or a reachable real proof); ❌ when it is a bare result, says "no", cites a missing file, does not prove its claim, or is absent from the note.

- Line (b) is ❌ when the change card is missing, or when the card and the rebuilt inventory disagree on what is new.
- **In show too**, without waiting for verify: compare the rebuilt inventory with a presented card, naming every difference; a new client, configuration variable, or cross-cutting mechanism the card does not declare becomes a `!` line *built on the side (undeclared)*, until verify's search shows the sibling it follows.
- Line (f) is ❌ when its real run executed another commit; name the version it ran on, and the validation environment's commit when observable. For a user-visible change, (f) is ❌ without screenshots of the attested commit organized per context ([visual proof](references/evidence-dossier.md#visual-proof)).
- **A five-line note** predates line (d): read its (c), (d), (e) as (c), (e), (f), and show (d) as ❌ "no record (older note format)".
- **No note on this machine** reads "no record on this machine", never "not reviewed".
- **A note only on an older commit** reads "outdated: proves `<X>`, the PR is at `<Y>`", and its lines count as ❌.
- **Author's review**: an incremental self-review, or one on an ancestor of the head, is not branch-clean; say which.

Under every ❌, one line says **what is missing and who acts**: 🤖 the agent that closes it, or 💪 the user only when only the user can, with the reason.

**Output**: Markdown with bold, bullets, and links, per [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md); the change card is its only text block. Every word of it, headings, labels, and the six questions included, is in the user's session language; the `<…>` parts below are placeholders, not text to copy. The layout is an example; the content is mandatory:

````markdown
🧾 **<Evidence> · <delivery name> · <time>**

<verdict: one emoji and one sentence>

**<Objective>:** <one or two sentences, or "not verifiable">. <Tasks and their status, or "unavailable">.

### <✅ | ⚠️> <short name> · [<repo>#<n>](<url>) · commit `<proven commit>` <(current) | (outdated: the PR is at `<head>`)>

<the change card tree, rebuilt from the diff>
<Matches the card presented | Differs: each item missing from either side> · <Base moved after the proof: no | what, by whom, when>

- ✅ **<Why does it exist?>** <the claim> · <its proof: link, command with its real output excerpt, or cited file>
- ✅ **<Is the architecture the declared one?>** …
- ✅ **<Was a wall knocked down?>** …
- ❌ **<Was anything built on the side?>** <what is missing> · <proof so far>
  - 🤖 **<who>:** <what closes it>   or   💪 **<You>:** <action>; <only you, because: reason>.
- ✅ **<Can it cause a catastrophe?>** …
- ✅ **<Was it tested, and does it work?>** … · 🖼 <context>: <what its images show> (`<folder>`)

<Uncommitted files, or nothing uncommitted.>
📋 <No task registered: suggest report-work, when no task reference exists>
➡️ **<Your next step>:** <the user's one action> | <Nothing depends on you now; next: the agent's step>
````

- **Verdict first, one line**: ✅ "proven on the current version; only your review is left" (six ✅ for the current head, complete card, base not moved, author branch-clean); ⚠️ "not proven: <the gaps>" (any ❌, outdated note, conflict, failing CI, base moved, or a tier-2 or tier-3 item neither ratified nor a `?` line on the card); ⏳ "not done: <what is still running>"; ✅ "delivery proven; objective not verifiable" when there is no objective to check against.
- **One section per PR**, open PRs first. A merged PR in scope collapses to its heading and proven state; the six proofs only when one is ❌. A branch without a PR shows its branch and head in the heading.
- **The six proofs always**, one line each: the dossier line's question, its claim, and its proof. Never a bare mark, and never a count in place of the proofs. When the user points at a proof, give its full argument from the note.
- **No task registered**: when no task reference exists in the branch, the commits, or the conversation, suggest registering the work with [`report-work`](../report-work/SKILL.md).
- **Closing line**: the user's next action, or that nothing depends on them and the agents' next step.
- When the verdict is not ✅ and this session wrote the delivery, switch to verify (Section 4) instead of showing the gap; on someone else's PR, end with one offer to verify, saying what it costs (minutes; it runs tests and a real execution).

## 4. Verify

When Section 1 calls for it, run the dossier's [independent reviewer](references/evidence-dossier.md#2-the-independent-reviewer) for the current head, as a subagent per [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md), briefed with the change, its change card, and the [reviewer questions](references/evidence-dossier.md#reviewer-questions), never the author's answers.

- **A delivery from an agent** reaches the reviewer only with a clean branch-mode `agent-self-review` on its head; without one, it goes back to its author. **Someone else's PR** may be verified without one: the card says "author's review: no record".
- The reviewer rebuilds the inventory of new things, produces its proof (screenshots per context for a user-visible change) in the [evidence folder](references/evidence-dossier.md#where-artifacts-live), and stores the six lines as a local `evidence` note (never pushed); then show the updated card and lines (Section 3).
- Any ❌ after verification follows the dossier's [no ❌, no merge request](references/evidence-dossier.md#1-the-six-lines) rule.
- A delivery gets at most two review rounds, and only some findings block, per the [limits of `agentic-parallel-work`](../agentic-parallel-work/SKILL.md#5-limits); a third verify on the same delivery is the user's call.

## 5. Success Validation

- [ ] Show wrote nothing; verify ran at the delivery's PR-and-proof stage, when its writer stopped, or on the user's request, after a branch-clean self-review for an agent's delivery, and stored a local note only.
- [ ] The output opened with one verdict line and the objective, then, per PR, the change card tree compared with the inventory rebuilt from the diff (undeclared clients, variables, or mechanisms as `!` lines), and whether the base moved.
- [ ] Each PR heading named the proven commit against the current head, and all six proofs followed, one line each with its question, claim, and proof (image contexts one line each); bare results, a missing or mismatched card in (b), or a real run of another commit in (f) were ❌, each with what is missing and who acts.
- [ ] A missing note read "no record on this machine"; a note on an older commit read "outdated: proves X, the PR is at Y"; a note in the older five-line format was mapped, its (d) "no record"; an incremental or ancestor self-review was not branch-clean.
- [ ] The validation environment's commit was read from the environment when the project records how, and any ❌ followed the dossier's no-merge rule.
- [ ] The screen was Markdown bullets with the change card as its only text block, every word of it in the user's language; no secrets were copied.
