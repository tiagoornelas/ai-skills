---
name: provide-evidence
description: >-
  Owns the evidence of a delivery, for any pull request or branch (one's own
  or someone else's), in any project and harness. Two actions: "show the
  proof" (default, read-only) gives a one-line verdict, the objective, and per
  PR its change card (what is new and where it lives, rules, data, pattern,
  walls, state) and the six evidence dossier lines in full, each with the
  artifact that proves it and, under every failing line, what is missing and
  who acts; "verify and produce what is missing" runs the dossier's
  independent reviewer, which rebuilds the inventory of new things from the
  diff, schema, and infrastructure files, compares it with the change card,
  and attests lines (c)–(f) for the current commit. Verify runs when the user
  asks for it or when a lead agent (such as a Herdr App Leader) delivers.
  Triggered when the user asks for the evidence, the proof, or whether a
  delivery is done, or when a delivery must be verified before it is
  presented.
argument-hint: "[PR number, URL, or branch] [verify]"
---

# Provide Evidence

The user needs to know at once: **is the work done, what does it add to the system and where, and what proves it?** This skill answers from observation and shows the proof itself, not a count of it. Evidence is not saying, it is showing: every line carries the artifact the user can open or re-run, per the [evidence dossier](references/evidence-dossier.md), which this skill owns.

## 1. Scope and Action

- **Scope**: the PR or branch given as argument; without one, the PR of the current branch (`gh pr view --json number`); without a PR, the current branch itself, compared with its base. Any PR works, whoever wrote it.
- **Show the proof** (default): read-only. Never run tests, fix, commit, push, merge, write a note or file, or message an agent.
- **Verify and produce what is missing**: when the user asks for it, or when a lead agent is about to present a delivery, run the [independent reviewer](#4-verify) for the current head. In any harness; inside or outside the Herdr App.
- When `gh` is missing or not authenticated, show what git alone proves and say the PR part was skipped; never guess PR states.

## 2. Gather

Observe in parallel where the harness allows it.

| Fact | Source |
| :--- | :--- |
| PR state | `gh pr view <pr> --json number,title,url,state,isDraft,mergeable,statusCheckRollup,headRefOid,baseRefName,author,body` |
| Objective | the issue linked from the PR body, or the PR body; otherwise "not verifiable" |
| Task status | each task referenced in the PR, from whatever tracker it points to through the tools the harness reaches; an unreachable tracker reads "status unavailable" |
| Author's review | `git notes --ref=self-review show <head>`: only a `branch clean` note on the head counts |
| The user's review | `git notes --ref=human-review show <head>`, and the user's reviews on the PR: `gh pr view <pr> --json reviews` filtered by the login from `gh api user --jq .login` |
| Evidence | `git notes --ref=evidence show <head>`; when absent, the newest `evidence` note on an earlier commit of the branch (`git log --format=%H <base>..<head>`) |
| Artifacts the note cites | the links, commands, and local file paths inside the note; check each local file exists |
| Base moved after the proof | `git fetch origin <base>`, then `git log --format='%h %an %cI %s' <proven commit>..origin/<base>`: commits dated after the attestation moved the base; name each one's author and PR |
| The change card | always the inventory of new things **rebuilt** from the diff, schema, and infrastructure files, in the kinds of the [change card](../ai-assisted-software-development/references/change-card.md); and the card presented with the delivery (PR body, issue, or the note), when there is one. Each item's approval comes from the issue or PR, otherwise "no record" |
| Uncommitted files | `git status --porcelain` in the current checkout |
| Validation environment's deployed commit | read it where the project, or in a Herdr App space its `leader.md`, records how (a deploy URL, a status endpoint, a CI environment, or the commit itself); "not observable" only when neither records it |

**Re-check before printing.** Read each PR's `headRefOid` again right before writing; if it moved, mark that card's evidence as outdated for the new head. Never copy secrets or credentials from output, notes, or logs.

## 3. Judge and Write

For every PR, take the six lines from its evidence note and judge each per the dossier's [artifact rule](references/evidence-dossier.md#proof-is-an-artifact-not-prose): ✅ only when the line's artifact **proves that line's claim** and is reachable; ❌ when it is an assertion, says "no", cites a missing file, does not prove its claim, or is absent from the note.

- Line (b) is ❌ when the change card is missing, or when the card and the rebuilt inventory disagree on what is new.
- **In show too**, without waiting for verify: print the rebuilt inventory beside a presented card, naming every difference; a new client, configuration variable, or cross-cutting mechanism the card does not declare marks **Pattern** ⚠️ *built on the side (undeclared)*, until verify's search shows the sibling it follows.
- Line (f) is ❌ when its real run executed another commit; name the version it ran on, and the validation environment's commit when observable.
- **A five-line note** predates line (d): read its (c), (d), (e) as (c), (e), (f), and show (d) as ❌ "no record (older note format)".
- **No note on this machine** reads "no record on this machine", never "not reviewed".
- **A note only on an older commit** reads "outdated: proves `<X>`, the PR is at `<Y>`", and its lines count as ❌.
- **Author's review**: an incremental self-review, or one on an ancestor of the head, is not branch-clean; say which.

Under every ❌, one line says **what is missing and who acts**: 🤖 the agent that closes it, or ✋ the user only when only the user can, with the reason.

**Output**, entirely in the user's session language, per [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md); the layout is an example, the content is mandatory:

````text
🧾 <repository and branch> · <Evidence> · <time>
<verdict line>
<Objective>: <one or two sentences, or "not verifiable"> · <task and status, or "status unavailable">

── <repo>#<n> · <short name>
<the change card: new and where it lives (with approvals), business rule, data, pattern, walls, state>
<rebuilt from the diff: matches the card | differs: <each item missing from either side>>
<proven version> <short> = <current version> · <base moved after the proof: no | yes: what, by whom, when>
✅ (a) <Why>: <problem> · <left out>: <what> — <artifact>
✅ (b) <Architecture>: <touches> · <new things match the card> — <artifact>
✅ (c) <Nothing knocked down>: <what was checked> — <artifact> · <reviewer>
✅ (d) <Nothing built on the side>: <each new thing follows what> — <artifact> · <reviewer>
✅ (e) <No catastrophe>: <data, undo> — <artifact> · <reviewer>
❌ (f) <Works>: <checks> · <real run on X, where> — <artifact>
   → 🤖 <who>: <what closes it>   or   → ✋ <you>: <action> (<only you because: reason>)

<uncommitted files, or nothing uncommitted>
📋 <No task registered: suggest report-work, when no task reference exists>
➡️ <the one next action when it is the user's>   or   <Nothing depends on you now; next: <agent step>>
````

- **Verdict first, one line**: ✅ "proven on the current version; only your review is left" (six ✅ for the current head, complete card, base not moved, author branch-clean); ⚠️ "not proven: <the gaps>" (any ❌, outdated note, draft, conflict, failing CI, base moved, or a card item without approval); ⏳ "not done: <what is still running>"; ✅ "delivery proven; objective not verifiable" when there is no objective to check against.
- **One card per PR**, open PRs first. A merged PR in scope gets a collapsed card: its PR line, its new things with where they live (or the "none" line), and its proven state; the six lines only when one is ❌. A branch without a PR shows its branch and head as the state.
- **The six lines always in full**, each with its artifact; never a bare count such as "6/6".
- **No task registered**: when no task reference exists in the PR, its branch, or its commits, suggest registering the work with [`report-work`](../report-work/SKILL.md).
- **Closing line**: the user's next action, or that nothing depends on them and the agents' next step.
- When the verdict is not ✅ and the action was "show", end with one offer to verify (Section 4), saying what it costs (minutes; it runs tests and a real execution).

## 4. Verify

Run the dossier's [independent reviewer](references/evidence-dossier.md#2-the-independent-reviewer) for the current head, as a subagent per [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md), briefed with the change, its change card, and the [reviewer questions](references/evidence-dossier.md#reviewer-questions), never the author's answers.

- **A delivery from an agent** reaches the reviewer only with a clean branch-mode `agent-self-review` on its head; without one, it goes back to its author. **Someone else's PR** may be verified without one: the card says "author's review: no record".
- The reviewer rebuilds the inventory of new things, produces its artifacts, and stores the six lines as a local `evidence` note (never pushed); then show the updated card and lines (Section 3).
- Any ❌ after verification follows the dossier's [no ❌, no merge request](references/evidence-dossier.md#1-the-six-lines) rule.

## 5. Inside the Herdr App (optional)

When `HC_TERMINAL_ID` is set and `hc` and `herdr-app` are on `PATH`, a space may be given instead of a PR: match it in `herdr-app ls` by name or `sp…` id, or by the `Space:` name in a team folder's `leader.md` ([team-folder.md](../herdr-team-lead/references/team-folder.md)); without one, use this terminal's `herdr.space` label, or ask which space when there is none. The scope becomes every delivery of the space (each tab agent's branch and each PR its `leader.md` references), the objective, approvals, and the validation environment's deployed commit (or how to read it) come from its `leader.md` first, and tabs still working and contradictions with `leader.md` are listed among the facts. Use only the Herdr App (`herdr-app`, `hc`) of this machine, never the `herdr` terminal CLI or `--on`. In a space, the verify reviewer is a sub-agent under [`herdr-handoff`](../herdr-handoff/SKILL.md#31-sub-agents)'s rules, with its files in the team folder's evidence folder.

## 6. Success Validation

- [ ] Show wrote nothing; verify ran only on the user's request or a lead agent's delivery, after a branch-clean self-review for an agent's delivery, and stored a local note only.
- [ ] The output opened with one verdict line and the objective, then, per PR, the change card beside the inventory rebuilt from the diff (undeclared clients, variables, or mechanisms marked built on the side), the proven version against the current head, and whether the base moved.
- [ ] All six lines appeared in full with their artifacts; lines without a proving artifact, a missing or mismatched card in (b), or a real run of another commit in (f) were ❌, each with what is missing and who acts.
- [ ] A missing note read "no record on this machine"; a note on an older commit read "outdated: proves X, the PR is at Y"; a note in the older five-line format was mapped, its (d) "no record"; an incremental or ancestor self-review was not branch-clean.
- [ ] The validation environment's commit came from the project or `leader.md` when recorded, and any ❌ followed the dossier's no-merge rule.
- [ ] Everything was in the user's language; no secrets were copied.
