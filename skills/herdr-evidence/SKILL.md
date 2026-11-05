---
name: herdr-evidence
description: >-
  Shows, on demand and from any Herdr App tab, whether the work of its space,
  or of a space the user names, is really done and proven: a one-line verdict first, the objective,
  then one card per pull request with its state, author, whether the proven
  version is the PR's current version and whether the base branch moved after
  the proof, and the five evidence dossier lines in full, each with the
  artifact that proves it (link, command and output excerpt, file of the real
  run), with what is missing and who acts under every failing line; then the
  team's facts (tabs working, uncommitted files) and any contradiction between
  leader.md and reality. Read-only: never starts a reviewer, runs tests,
  fixes, merges, or messages anyone. Works with or without a team folder.
  Built for the Herdr App (herdr-app + hc), not the Herdr terminal multiplexer
  (`herdr` CLI). Triggered strictly when the user asks for the evidence or
  the state of a space's deliveries.
disable-model-invocation: true
argument-hint: "[space name or id, optional] [PR number to focus, optional]"
---

# Herdr Evidence

The user leads many Herdr App spaces. Entering one that looks finished, they need to know at once: **is the work done, where is the PR, and what proves it?** This skill answers for **one space**, from observation, and shows the proof itself, not a count of it. Evidence is not saying, it is showing: every line of every delivery carries the artifact the user can open or re-run, per the [evidence dossier](../ai-assisted-software-development/references/evidence-dossier.md).

> **Herdr App only.** This skill reads the Herdr App: `herdr-app` (window: spaces, tabs, panes) and `hc` (herdr-core: terminals and agents). It never uses the `herdr` CLI of the Herdr terminal multiplexer, which talks to a different session.

## 1. Preconditions

- Require `HC_TERMINAL_ID` to be set and both `hc` and `herdr-app` on `PATH`. Otherwise report that the session is outside the Herdr App and stop. Use only this machine; never pass `--on` or `--machine`.
- Treat the installed CLIs as the syntax authority: load `hc --skill` and `herdr-app --skill` unless already in context, and parse state from JSON responses.
- **The space.** When the user names a space (by name or `sp…` id, matched in `herdr-app ls`), use it; otherwise use this terminal's space, the `herdr.space` label in `hc get "$HC_TERMINAL_ID"`. A terminal without that label (a sub-agent, a terminal outside any space) and no space named: ask the user which space, listing the spaces from `herdr-app ls`, and stop until answered. A name matching several spaces is asked the same way. Read the chosen space's team folder per [team-folder.md](../herdr-team-lead/references/team-folder.md) when it exists; without it, infer the objective and mark it as inferred.
- **Read only.** Never start a reviewer or any agent, run tests, fix, commit, push, merge, write a note or `leader.md`, or message an agent. The skill shows gaps; closing them is someone else's job. Run from the Leader tab, the Leader then acts on each gap under its own rules ([`herdr-team-lead`](../herdr-team-lead/SKILL.md)); run from a tab agent's tab, the output is for the user, who wrote there.

## 2. Gather

Observe in parallel where the harness allows it. When the user named a PR, gather everything but expand only that card. Every fact below is for the chosen space, whichever tab runs the skill.

| Fact | Source |
| :--- | :--- |
| Objective and each tab agent's mission | `leader.md` (Objective, Tab agents, Decisions & Rationale) and `handoff-*.md` |
| Tabs, agents, and states | `herdr-app ls` (that space) and `hc ls --label herdr.space=<space-id> --json` |
| Each agent's worktree | `hc get <terminal>` (`foreground.cwd`), then `git -C <cwd>` `branch --show-current`, `rev-parse HEAD`, `status --porcelain` |
| PRs of the space | per agent branch and per PR referenced in `leader.md`: `gh pr list --head <branch> --state all --json number,title,url,state,isDraft,mergeable,statusCheckRollup,headRefOid,baseRefName,author` |
| Author's review | `git notes --ref=self-review show <PR head>` (its first words are `increment clean` or `branch clean`): only a `branch clean` note on the PR head counts |
| Evidence | `git notes --ref=evidence show <PR head>`; when absent, the newest `evidence` note on an earlier commit of the branch (`git log --format=%H <base>..<head>` then `git notes --ref=evidence show <commit>`) |
| Artifacts the note cites | the links, commands, and local file paths inside the note; check each local file exists |
| Base moved after the proof | `git fetch origin <base>`, then `git log --format='%h %an %cI %s' <proven commit>..origin/<base>`: commits dated after the note's attestation time moved the base after the proof; name the author and PR of each |
| Task status | each task referenced in `leader.md` or the PR, from whatever tracker it points to through the tools the harness reaches; an unreachable tracker reads "status unavailable", never a guessed status |
| Validation environment's deployed commit | only when `leader.md` or the project records how to read it (a deploy URL, a status endpoint, a CI environment); otherwise "not observable" |

**Re-check before printing.** Read each PR's `headRefOid` again right before writing; if it moved during the gather, mark that card's evidence as outdated for the new head.

Do not parse session transcripts. Never copy secrets or credentials from terminal output, notes, or logs into the output.

## 3. Judge Each Line

For every PR, take the five lines from its evidence note and judge each per the dossier's [artifact rule](../ai-assisted-software-development/references/evidence-dossier.md#proof-is-an-artifact-not-prose):

- ✅ only when the line's artifact **proves that line's claim** and is reachable (a local file exists; a link is well-formed). An artifact that exists but does not prove the claim is ❌ "artifact does not prove it":
  - (a) links the issue, request, or decision that motivates the change, and the scope conclusion for what was left out;
  - (b) a module map or diff stat that shows the modules named, and the notice of each new component;
  - (c) the diff or check of the contract, rule, and test files it names;
  - (d) names the affected flows and data traced in the diff, and a revert or rollback path that was checked (run, or dry-run, against this change), not a bare command;
  - (e) the output of the checks and the file or log of a real run of the attested commit.
- ❌ when the line is an assertion without an artifact, says "no", cites a file that is missing, or is absent from the note ("no record in the note").
- Line (e) is ❌ when its real run executed a commit other than the proven one; name the version it ran on. When the validation environment is observable and runs another commit, say so.
- **No note on this machine** reads "no record on this machine", never "not reviewed": its absence here proves nothing.
- **A note only on an older commit** reads "outdated: proves `<X>`, the PR is at `<Y>`"; its lines are shown greyed as history, and the card's lines count as ❌.
- **Author's review**: an incremental self-review, or one on an ancestor of the head, does not satisfy the branch-clean gate; say which it is.

Under every ❌, one line says **what is missing and who acts**: 🤖 the agent (tab or Leader) that closes it, or ✋ the user only when only the user can, with the reason.

## 4. Write the Output

Entirely in the user's session language, following [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md) and the status vocabulary and [PR line](../herdr-team-lead/references/panel-format.md#pr-line) words of [panel-format.md](../herdr-team-lead/references/panel-format.md). Every fixed word below is a placeholder to translate. A plain terminal layout, about 100 columns, no tables.

````text
🧾 <space name> · <Evidence> · <time>
<verdict line>
   <only when not proven: the gaps, in one line>
<Objective>: <one or two sentences> · <tracker key and status, or "status unavailable", when referenced>

── <repo>#<n> · <short name> ─────────────────────────────────────────
   <open | draft | merged> · CI <worst state> · <conflict | no conflict> · <by tab role> (<PR author>) · <your review: pending | ok | changes | —>
   <proven version> <short> = <current PR version> · <base moved after the proof: no | yes: <what, by whom, when>>
   ✅ (a) <Why>: <problem> · <left out>: <what> — <artifact>
   ✅ (b) <Architecture>: <touches> · <new> — <artifact>
   ✅ (c) <Nothing knocked down>: <what was checked> — <artifact> · <reviewer>
   ✅ (d) <No catastrophe>: <data, undo> — <artifact> · <reviewer>
   ❌ (e) <Works>: <checks> · <real run on X, where> — <artifact>
      → 🤖 <who>: <what closes it>   or   → ✋ <you>: <action> (<only you because: reason>)

<Team>: <tabs working, or none> · <uncommitted files per worktree, or nothing uncommitted>
⚠️ <contradiction between leader.md and reality, when any>
➡️ <the one next action, when it is the user's: e.g. 👀 review and merge #29>   or   <Nothing depends on you now; next: <agent step>>
````

- **Verdict first, one line**, chosen from what the cards show:
  - ✅ "proven on the current version; only your review is left" (every open PR has five ✅ for its current head, the base did not move after the proof, and the author's review is branch-clean);
  - ⚠️ "looks done but is not proven: <the gaps>" (any ❌, outdated note, draft, conflict, failing CI, or base moved after the proof);
  - ⏳ "not done: <what is still running>" (tabs working or PRs not yet opened for a stream);
  - ✅ "delivery proven; objective completion not verifiable" (cards proven but no `leader.md` objective or tracker to check them against).
- **CI** is the worst state among the PR's checks: failing > running > cancelled > ok; `—` when it has none.
- **Closing line**: the one next action when it is the user's; when nothing is, say so plainly and name the agents' next step.
- **One card per PR**, open PRs first, merged PRs collapsed into one final line with their proven state. A stream without a PR gets a card with its branch and head instead of the PR line.
- **The five lines always in full**, each with its artifact as it appears in the note (link, `command` → output excerpt, local path). Never a bare "5/5" or "4 of 5".
- **Base moved after the proof** names what moved it and who authored it, so the user knows whether to ask for a new proof.
- **Team facts** come last: tabs still working, uncommitted files per worktree, and any contradiction with `leader.md` (a next step already done, a tab gone, a PR merged that it still says to follow).
- Situate every term in the product, per [Briefing a Change](../ai-assisted-software-development/references/human-facing-communication.md#3-briefing-a-change); never relay an agent's raw words.

## 5. Success Validation

- [ ] Herdr App environment verified, without the `herdr` terminal CLI or `--on`; the output covers only the named space, or this terminal's space; without either, the user was asked which space.
- [ ] Nothing was started, run, fixed, written, merged, or messaged.
- [ ] The output opened with one verdict line, then the objective, then one card per PR (or stream without PR), then team facts and contradictions with `leader.md`.
- [ ] Each card showed state, CI, conflict, author, the user's review, the proven version against the current PR head, and whether the base moved after the proof, with who moved it.
- [ ] Each card showed all five lines in full with their artifacts; no count stood in for them; lines without an artifact, with an artifact that does not prove their claim, missing from the note, or with a real run of another commit were ❌, naming the version it ran on.
- [ ] Every ❌ carried what is missing and who acts; ✋ only with why only the user can.
- [ ] A missing note read "no record on this machine"; a note on an older commit read "outdated: proves X, PR is at Y"; an incremental or ancestor self-review did not count as branch-clean.
- [ ] CI showed the worst check state; an unreachable tracker read "status unavailable"; the closing line named the user's next action or said nothing depends on them.
- [ ] PR heads were re-checked right before printing; the validation environment's commit was shown or said "not observable".
- [ ] Everything was in the user's language, fixed template words included; no secrets were copied.
