---
name: provide-evidence
description: >-
  Shows, on demand, whether a delivery is really done and proven, in any
  project and harness: a one-line verdict first, the objective, then one card
  per pull request with its state, author, the user's review, what it adds to
  the system and how each item was approved, whether the proven version is the
  PR's current version and whether the base branch moved after the proof, and
  the six evidence dossier lines in full, each with the artifact that proves
  it, with what is missing and who acts under every failing line. Outside the
  Herdr App it covers the PR or branch given (or the current branch's PR) and
  may offer to run the dossier's independent reviewer when lines (c)–(f) are
  missing or outdated; inside the Herdr App it covers every delivery of a
  space, with its leader.md objective, approvals, and tab states. Otherwise
  read-only. Triggered strictly when the user asks for the evidence, the proof,
  or whether a delivery is done.
disable-model-invocation: true
argument-hint: "[PR number, URL, or branch; in the Herdr App: space name or id, optionally a PR]"
---

# Provide Evidence

The user needs to know at once: **is the work done, where is the PR, and what proves it?** This skill answers from observation and shows the proof itself, not a count of it. Evidence is not saying, it is showing: every line of every delivery carries the artifact the user can open or re-run, per the [evidence dossier](../ai-assisted-software-development/references/evidence-dossier.md).

## 1. Mode and Scope

- **Herdr mode** when `HC_TERMINAL_ID` is set and both `hc` and `herdr-app` are on `PATH`: apply Section 2 as well. It reads the Herdr App (`herdr-app` and `hc`), never the `herdr` CLI of the Herdr terminal multiplexer, and only this machine (never `--on` or `--machine`).
- **Standalone mode** otherwise. The scope is the PR or branch given as argument; without one, the PR of the current branch (`gh pr view --json number`); without a PR, the current branch itself, compared with its base.
- **Read only.** Never run tests, fix, commit, push, merge, write a note or file, or message an agent. The one exception is the [offer](#5-offer-the-independent-reviewer) at the end of standalone mode, and only on the user's yes.
- When `gh` is missing or not authenticated, show what git alone proves and say the PR part was skipped; never guess PR states.

## 2. Inside the Herdr App

- **The space.** When the user names a space, match it in `herdr-app ls` by name or `sp…` id, or by the `Space:` name in a team folder's `leader.md` (a space renamed since), and use its id. Otherwise use this terminal's space, the `herdr.space` label in `hc get "$HC_TERMINAL_ID"`. A terminal without that label (a sub-agent, a terminal outside any space) and no space named, or a name matching several spaces: ask the user which space, listing the spaces from `herdr-app ls`, and stop until answered.
- **Scope is every delivery of the space**: each tab agent's branch and each PR referenced in its `leader.md`. A PR named in the argument is expanded; the others stay as cards.
- Load `hc --skill` and `herdr-app --skill` unless already in context, and parse state from JSON responses. Read the team folder per [team-folder.md](../herdr-team-lead/references/team-folder.md) when it exists.
- **Never start the reviewer here.** Producing evidence is the Leader's delivery duty ([`herdr-team-lead`](../herdr-team-lead/SKILL.md)): run in the Leader's tab, the Leader then acts on each gap under its own rules; run in a tab agent's tab, the output is for the user, who wrote there.

## 3. Gather

Observe in parallel where the harness allows it.

| Fact | Source |
| :--- | :--- |
| PR state | `gh pr view <pr> --json number,title,url,state,isDraft,mergeable,statusCheckRollup,headRefOid,baseRefName,author,body` |
| Objective | the issue linked from the PR body, or the PR body; otherwise "not verifiable". In Herdr mode, `leader.md` Objective first |
| Task status | each task referenced in the PR (or `leader.md`), from whatever tracker it points to through the tools the harness reaches; an unreachable tracker reads "status unavailable", never a guessed status |
| Author's review | `git notes --ref=self-review show <head>` (its first words are `increment clean` or `branch clean`): only a `branch clean` note on the head counts |
| The user's review | `git notes --ref=human-review show <head>`, and the user's reviews on the PR: `gh pr view <pr> --json reviews` filtered by the login from `gh api user --jq .login` (approved, changes requested, commented, and on which commit) |
| Evidence | `git notes --ref=evidence show <head>`; when absent, the newest `evidence` note on an earlier commit of the branch (`git log --format=%H <base>..<head>`, then `git notes --ref=evidence show <commit>`) |
| Artifacts the note cites | the links, commands, and local file paths inside the note; check each local file exists |
| Base moved after the proof | `git fetch origin <base>`, then `git log --format='%h %an %cI %s' <proven commit>..origin/<base>`: commits dated after the note's attestation time moved the base after the proof; name the author and PR of each |
| What the PR adds to the system | the PR body and diff (new jobs, schedules, migrations, routes, secrets, IAM, infrastructure files), in the closed categories of the [what appears](../herdr-team-lead/references/panel-format.md#what-appears) line |
| How each added item was approved | the issue and PR (a decision recorded there, with its date); otherwise "no record". In Herdr mode, `leader.md`: the approved split, tier-2 notices, and the user's decisions in Decisions & Rationale and Pending Decisions, with their dates |
| Uncommitted files | `git status --porcelain` in the current checkout; in Herdr mode, in each tab agent's worktree (`hc get <terminal>` `foreground.cwd`) |
| Tabs and their states | Herdr mode only: `herdr-app ls` (that space) and `hc ls --label herdr.space=<space-id> --json` |
| Validation environment's deployed commit | only when the project (or `leader.md`) records how to read it: a deploy URL, a status endpoint, a CI environment; otherwise "not observable" |

**Re-check before printing.** Read each PR's `headRefOid` again right before writing; if it moved during the gather, mark that card's evidence as outdated for the new head.

Do not parse session transcripts. Never copy secrets or credentials from terminal output, notes, or logs into the output.

## 4. Judge and Write

### Judge each line

For every PR, take the six lines from its evidence note and judge each per the dossier's [artifact rule](../ai-assisted-software-development/references/evidence-dossier.md#proof-is-an-artifact-not-prose):

- ✅ only when the line's artifact **proves that line's claim** and is reachable (a local file exists; a link is well-formed). An artifact that exists but does not prove the claim is ❌ "artifact does not prove it":
  - (a) links the issue, request, or decision that motivates the change, and the scope conclusion for what was left out;
  - (b) a module map or diff stat that shows the modules named, each new component with its approval (matching the card's what-appears tags), and the list of new structures;
  - (c) the diff or check of the contract, rule, and test files it names;
  - (d) for each new structure, the existing sibling it follows (path), the search that found none (command and result), or the link to a human decision recorded before the change approving the deviation;
  - (e) names the affected flows and data traced in the diff, and a revert or rollback path that was checked (run, or dry-run, against this change), not a bare command;
  - (f) the output of the checks and the file or log of a real run of the attested commit.
- ❌ when the line is an assertion without an artifact, says "no", cites a file that is missing, or is absent from the note ("no record in the note").
- Line (f) is ❌ when its real run executed a commit other than the proven one; name the version it ran on. When the validation environment is observable and runs another commit, say so.
- **A five-line note** predates line (d): read its (c), (d), (e) as (c), (e), (f), and show (d) as ❌ "no record (older note format)".
- **No note on this machine** reads "no record on this machine", never "not reviewed": its absence here proves nothing.
- **A note only on an older commit** reads "outdated: proves `<X>`, the PR is at `<Y>`"; its lines are shown greyed as history, and the card's lines count as ❌.
- **Author's review**: an incremental self-review, or one on an ancestor of the head, does not satisfy the branch-clean gate; say which it is.

Under every ❌, one line says **what is missing and who acts**: 🤖 the agent that closes it, or ✋ the user only when only the user can, with the reason.

### Write the output

Entirely in the user's session language, following [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md) and the status vocabulary and [PR line](../herdr-team-lead/references/panel-format.md#pr-line) words of [panel-format.md](../herdr-team-lead/references/panel-format.md). Every fixed word below is a placeholder to translate. A plain terminal layout, about 100 columns, no tables.

````text
🧾 <space name, or repository and branch> · <Evidence> · <time>
<verdict line>
   <only when not proven: the gaps, in one line>
<Objective>: <one or two sentences, or "not verifiable"> · <tracker key and status, or "status unavailable", when referenced>

── <repo>#<n> · <short name> ─────────────────────────────────────────
   <open | draft | merged> · CI <worst state> · <conflict | no conflict> · <by tab role> (<PR author>) · <your review: pending | ok | changes | —>
   🏗️ <the what-appears line, each item tagged: (in the approved split) | (notice <date>) | (decided by you <date>) | (no record) | ⚠️ (appeared without notice)>
   <proven version> <short> = <current PR version> · <base moved after the proof: no | yes: <what, by whom, when>>
   ✅ (a) <Why>: <problem> · <left out>: <what> — <artifact>
   ✅ (b) <Architecture>: <touches> · <new> — <artifact>
   ✅ (c) <Nothing knocked down>: <what was checked> — <artifact> · <reviewer>
   ✅ (d) <Nothing built on the side>: <each new structure follows what> — <artifact> · <reviewer>
   ✅ (e) <No catastrophe>: <data, undo> — <artifact> · <reviewer>
   ❌ (f) <Works>: <checks> · <real run on X, where> — <artifact>
      → 🤖 <who>: <what closes it>   or   → ✋ <you>: <action> (<only you because: reason>)

<Team: tabs working, or none (Herdr mode)> · <uncommitted files, or nothing uncommitted>
⚠️ <contradiction between leader.md and reality, when any (Herdr mode)>
📋 <No task registered: suggest report-work, when no task reference exists anywhere>
➡️ <the one next action, when it is the user's: e.g. 👀 review and merge #29>   or   <Nothing depends on you now; next: <agent step>>
````

- **Verdict first, one line**, chosen from what the cards show:
  - ✅ "proven on the current version; only your review is left" (every open PR has six ✅ for its current head, the base did not move after the proof, and the author's review is branch-clean);
  - ⚠️ "looks done but is not proven: <the gaps>" (any ❌, outdated note, draft, conflict, failing CI, base moved after the proof, or an item that appeared without notice);
  - ⏳ "not done: <what is still running>" (tabs working or PRs not yet opened for a stream);
  - ✅ "delivery proven; objective completion not verifiable" (cards proven but no objective to check them against).
- **CI** is the worst state among the PR's checks: failing > running > cancelled > ok; `—` when it has none.
- **Your review** comes from the `human-review` note and the user's PR reviews; a review on an older commit says so.
- **What appears** sits right under the PR state line, in the closed categories and format of the [what appears](../herdr-team-lead/references/panel-format.md#what-appears) line. Each item is tagged with how it was approved: in the approved split (Herdr mode), a notice (its date), decided by the user (its date), or "no record" when standalone mode finds no approval in the issue or PR. In Herdr mode, an item with no approval is ⚠️ "appeared without notice" and makes the verdict ⚠️. Omit the line when the PR adds nothing in those categories.
- **One card per PR**, open PRs first, merged PRs collapsed into one final line with their proven state. A branch without a PR gets a card with its branch and head instead of the PR line.
- **The six lines always in full**, each with its artifact as it appears in the note (link, `command` → output excerpt, local path). Never a bare count such as "6/6" or "4 of 6".
- **Base moved after the proof** names what moved it and who authored it, so the user knows whether to ask for a new proof.
- **Facts last**: uncommitted files; in Herdr mode, tabs still working and any contradiction with `leader.md` (a next step already done, a tab gone, a PR merged that it still says to follow).
- **No task registered**: when no task reference exists in the PR, its branch, its commits, or `leader.md`, say so and suggest registering the work with [`report-work`](../report-work/SKILL.md).
- **Closing line**: the one next action when it is the user's; when nothing is, say so plainly and name the agents' next step.
- Situate every term in the product, per [Briefing a Change](../ai-assisted-software-development/references/human-facing-communication.md#3-briefing-a-change); never relay an agent's raw words.

## 5. Offer the Independent Reviewer

Standalone mode only. When lines (c)–(f) of a card are missing or outdated for its current head, end the output with one offer: run the dossier's [independent reviewer](../ai-assisted-software-development/references/evidence-dossier.md#2-the-independent-reviewer) for that commit, as a subagent per [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md), briefed with the change and the dossier's [reviewer questions](../ai-assisted-software-development/references/evidence-dossier.md#reviewer-questions). Say what it costs (minutes, and it runs tests and a real execution) and that it needs a clean branch-mode `agent-self-review` on the head first; when that is missing, say so instead of offering.

Run it only on the user's explicit yes, following the dossier: the reviewer produces the artifacts, stores the six lines as a local `evidence` note, and the skill then shows the updated card. In Herdr mode, never offer: the Leader starts reviewers.

## 6. Success Validation

- [ ] The mode was detected; in Herdr mode, the `herdr` terminal CLI and `--on` were not used, and the space was the one named (by name, id, or `leader.md` name) or this terminal's, or the user was asked.
- [ ] Nothing was written, run, merged, or messaged, except a reviewer the user explicitly accepted in standalone mode.
- [ ] The output opened with one verdict line, then the objective (or "not verifiable"), then one card per PR or branch, then facts.
- [ ] Each card showed state, CI (worst check), conflict, author, the user's review (note and PR reviews), the what-appears line when the PR adds something (each item tagged with its approval, "no record", or ⚠️ appeared without notice), the proven version against the current head, and whether the base moved after the proof, with who moved it.
- [ ] Each card showed all six lines in full (a five-line note mapped to the new letters, its (d) as no record) with their artifacts; no count stood in for them; lines without an artifact, with an artifact that does not prove their claim, missing from the note, or with a real run of another commit were ❌, naming the version it ran on.
- [ ] Every ❌ carried what is missing and who acts; ✋ only with why only the user can.
- [ ] A missing note read "no record on this machine"; a note on an older commit read "outdated: proves X, PR is at Y"; an incremental or ancestor self-review did not count as branch-clean.
- [ ] An unreachable tracker read "status unavailable"; untracked work suggested `report-work`; the closing line named the user's next action or said nothing depends on them.
- [ ] PR heads were re-checked right before printing; the validation environment's commit was shown or said "not observable".
- [ ] In standalone mode, missing or outdated (c)–(f) ended with the reviewer offer (or the missing self-review named); in Herdr mode, no offer.
- [ ] Everything was in the user's language, fixed template words included; no secrets were copied.
