---
name: provide-evidence
description: >-
  Owns the evidence of a delivery, for any pull request or branch (one's own
  or someone else's), in any project and harness. Two actions: "show the
  proof" (default, read-only) gives a one-line verdict, the objective, and per
  PR the change card's plan and the six evidence dossier lines (a)–(f), each
  with its claim and its proof and, under every failing line, what is missing
  and who acts; "verify and produce what is missing" runs the dossier's
  independent reviewer, which rebuilds the inventory of new things from the
  diff, compares it with the change card, and attests lines (c)–(f) for the
  current commit. Verify runs only when the user asks for it or when the
  writer of a delivery is about to present it to the user. Triggered when the
  user asks for the evidence, the proof, or whether a delivery is done, or
  when a writer is about to present a delivery as ready.
argument-hint: "[PR number, URL, or branch] [verify]"
---

# Provide Evidence

The user needs to know at once: **is the work done, what does it add to the system and where, and what proves it?** This skill answers from observation and shows the proof itself, not a count of it. Evidence must convince: every line carries its claim, why it convinces, and its proof, an argument that cites what it rests on or a real proof the user can open or re-run, per the [evidence dossier](references/evidence-dossier.md), which this skill owns.

## 1. Scope and Action

- **Scope**: the PR or branch given as argument; without one, the PR of the current branch (`gh pr view --json number`); without a PR, the current branch itself, compared with its base. Any PR works, whoever wrote it.
- **Show the proof** (default): read-only. Never run tests, fix, commit, push, merge, write a note or file, or message an agent.
- **Verify and produce what is missing**: only when the user asks for it, or when the writer of a delivery is about to present it to the user as ready, run the [independent reviewer](#4-verify) for the current head, in any harness, per the [evidence dossier](references/evidence-dossier.md#when-to-consult).
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
| The change card | always, for every PR, the inventory of new things **rebuilt** from the diff, schema, and infrastructure files, in the kinds of the [change card](../ai-assisted-software-development/references/change-card.md) (for a large PR, from `git diff --name-status` plus the full diff of only the schema, migration, job, route, secret, configuration, and client files, saying so); and the card presented with the delivery (in the conversation, the issue, or the `evidence` note), when there is one. Each item's approval comes from the issue or the conversation, otherwise "no record" |
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

Under every ❌, one line says **what is missing and who acts**: 🤖 the agent that closes it, or ✋ the user only when only the user can, with the reason.

**Output**, entirely in the user's session language, per [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md); the layout is an example, the content is mandatory. On this screen ✅ prints as ✓ and ❌ as ✗, one column wide so the lines stay aligned:

````text
🧾 <repository and branch> · <Evidence> · <time>
<verdict line>
<Objective>: <one or two sentences, or "not verifiable"> · <task and status, or "unavailable">

── <repo>#<n> · <short name>
<the plan of the change card>
<rebuilt from the diff: matches the plan | differs: <each item missing from either side>>
<base moved after the proof: no | yes: what, by whom, when>

<Proof>: <N> ✓  <N> ✗  <commit> <proven commit>[ · <the PR is at <head>: outdated>]
  ✓ <letter> <name>   <claim>   <proof>
  ✗ <letter> <name>   <what is missing>   <proof so far>
      🖼 <context> · <folder> · <what its images show>   (under f, one per context)
      → 🤖 <who>: <what closes it>   or   → ✋ <you>: <action> (<only you because: reason>)

<uncommitted files, or nothing uncommitted>
📋 <No task registered: suggest report-work, when no task reference exists>
➡️ <the user's one next action>   or   <Nothing depends on you now; next: <agent step>>
````

The proof block of a fictional delivery:

```text
Proof: 4 ✓  2 ✗  commit 5b699b1
  ✓ a why                   exported by hand today     issue #301: support asks weekly
  ✓ b architecture          9 new things, all on plan  rebuilt inventory matches
  ✓ c no wall knocked down  contracts, tests intact    git diff main...5b699b1 -- api/ test/ → empty
  ✗ d nothing on the side   PDF layout inside the job  others use app/templates/
      → 🤖 author: move the layout to app/templates/, beside the receipt template
  ✓ e no catastrophe        flag off; one table added  revert: git revert 5b699b1
  ✗ f tested and works      end-to-end run missing     CI run 1432: 212 passed
      → 🤖 reviewer: export one invoice in the review app on 5b699b1, with screenshots
```

- **Verdict first, one line**: ✅ "proven on the current version; only your review is left" (six ✅ for the current head, complete card, base not moved, author branch-clean); ⚠️ "not proven: <the gaps>" (any ❌, outdated note, draft, conflict, failing CI, base moved, or a card item without approval); ⏳ "not done: <what is still running>"; ✅ "delivery proven; objective not verifiable" when there is no objective to check against.
- **One plan per PR**, open PRs first. A merged PR in scope gets a collapsed plan: its count line, its PR line, and its proven state; the six lines only when one is ❌. A branch without a PR shows its branch and head as the state.
- **The six lines always**, each with its claim and its proof: a link, a command with its real result, or the cited file, in words that say why it convinces. Never a bare mark; the `Proof` count never stands in for the lines. When the user points at a line, give its full argument from the note. Visual proof prints each context folder with one line on what it shows.
- **No task registered**: when no task reference exists in the branch, the commits, or the conversation, suggest registering the work with [`report-work`](../report-work/SKILL.md).
- **Closing line**: the user's next action, or that nothing depends on them and the agents' next step.
- When the verdict is not ✅ and the action was "show", end with one offer to verify (Section 4), saying what it costs (minutes; it runs tests and a real execution).

## 4. Verify

Only on the user's request or before the writer presents a delivery (Section 1), run the dossier's [independent reviewer](references/evidence-dossier.md#2-the-independent-reviewer) for the current head, as a subagent per [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md), briefed with the change, its change card, and the [reviewer questions](references/evidence-dossier.md#reviewer-questions), never the author's answers.

- **A delivery from an agent** reaches the reviewer only with a clean branch-mode `agent-self-review` on its head; without one, it goes back to its author. **Someone else's PR** may be verified without one: the card says "author's review: no record".
- The reviewer rebuilds the inventory of new things, produces its proof (screenshots per context for a user-visible change) in the [evidence folder](references/evidence-dossier.md#where-artifacts-live), and stores the six lines as a local `evidence` note (never pushed); then show the updated card and lines (Section 3).
- Any ❌ after verification follows the dossier's [no ❌, no merge request](references/evidence-dossier.md#1-the-six-lines) rule.
- A delivery gets at most two review rounds, and only some findings block, per the [limits of `agentic-parallel-work`](../agentic-parallel-work/SKILL.md#4-limits); a third verify on the same delivery is the user's call.

## 5. Success Validation

- [ ] Show wrote nothing; verify ran only on the user's request or before the writer presented a delivery, after a branch-clean self-review for an agent's delivery, and stored a local note only.
- [ ] The output opened with one verdict line and the objective, then, per PR, the change card's plan compared with the inventory rebuilt from the diff (undeclared clients, variables, or mechanisms as `!` lines), and whether the base moved.
- [ ] The `Proof` count named the proven commit against the current head, and all six lines followed, each with its claim and its proof (image contexts one line each); bare results, a missing or mismatched card in (b), or a real run of another commit in (f) were ❌, each with what is missing and who acts.
- [ ] A missing note read "no record on this machine"; a note on an older commit read "outdated: proves X, the PR is at Y"; a note in the older five-line format was mapped, its (d) "no record"; an incremental or ancestor self-review was not branch-clean.
- [ ] The validation environment's commit was read from the environment when the project records how, and any ❌ followed the dossier's no-merge rule.
- [ ] Everything was in the user's language; no secrets were copied.
