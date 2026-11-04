---
name: herdr-inbox
description: >-
  Shows, on demand and from any Herdr App tab, one inbox of everything that
  depends on the user across all spaces: decisions and user-only actions each
  team's Leader recorded in its leader.md, agents stopped at a dialog or in
  error, pull requests waiting for the user's review, and the user's own open
  pull requests, grouped by space and numbered in one queue, with where to go
  to act on each. Read-only: it never answers, messages, or changes anything.
  Built for the Herdr App (herdr-app + hc), not the Herdr terminal multiplexer
  (`herdr` CLI). Triggered strictly when the user asks for the inbox, or asks
  what depends on them across spaces.
disable-model-invocation: true
argument-hint: "[space name to focus, optional]"
---

# Herdr Inbox

The user leads several Herdr App spaces at once. Each Leader shows its own Panel ([`herdr-leader-report`](../herdr-leader-report/SKILL.md)), but only inside its space; this skill answers the question no single Leader can: **"where does anyone need me right now?"** It reads, it lists, it says where to go. Acting on an item happens in that space's tab, with its Leader.

> **Herdr App only.** This skill reads the Herdr App: `herdr-app` (window: spaces, tabs, panes) and `hc` (herdr-core: terminals and agents). It never uses the `herdr` CLI of the Herdr terminal multiplexer, which talks to a different session.

## 1. Preconditions

- Require `hc` and `herdr-app` on `PATH`. Otherwise report that the session is outside the Herdr App and stop. Use only this machine; never pass `--on` or `--machine`.
- Treat the installed CLIs as the syntax authority: load `hc --skill` and `herdr-app --skill` unless already in context, and parse state from JSON responses.
- Read only. Never send a message, answer a dialog, rename a tab, or write a file, `leader.md` included. When an item looks stale or wrong, report it; fixing it is the Leader's job in its own space.

## 2. Gather

Observe in parallel where the harness allows it; nothing here needs to ask an agent.

| Fact | Source |
| :--- | :--- |
| Spaces, their tabs, and each terminal's status | `herdr-app ls` |
| Agents stopped at a dialog or in error | `hc ls --json`: status `blocked` or `error`, with `where` (space / tab) |
| Each team's pending decisions and user-only actions, and when they were recorded | `~/.herdr-teams/<space-id>/leader.md` ([team-folder.md](../herdr-team-lead/references/team-folder.md)): the **Pending Decisions** section, and the `Updated` and `State` lines |
| PRs waiting for the user's review | `gh search prs --review-requested=@me --state=open --json repository,number,title,url` |
| The user's own open PRs | `gh search prs --author=@me --state=open --json repository,number,title,url,isDraft` |
| Which space each of the user's PRs belongs to | the branch of each terminal's `cwd` (`git -C <cwd> branch --show-current`) matched to the PR's head branch (`gh pr view <url> --json headRefName,statusCheckRollup`) |

- Only teams whose `leader.md` says `State: active` count; a space without `leader.md` still shows its blocked or errored agents.
- A team folder whose space no longer exists in `herdr-app ls` is not listed; mention their count once in the closing line.
- When `gh` is missing or not authenticated, list the Herdr items and say the PR part was skipped; never guess PR states.

## 3. Write the Inbox

Write in the user's session language, following [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md) and the status vocabulary of [report-format.md](../herdr-leader-report/references/report-format.md#2-status-vocabulary). Situate every item in its product terms: the inbox is read by someone arriving from another space, with none of that team's context.

````markdown
## 📥 <Inbox> · <date and time>

**❓ <5 items depend on you in 3 spaces>**   or   **✅ <Nothing depends on you in any space>**

### <space name> · go to tab <Leader>
1. ❓ <decision, in system terms> · <recorded on date and time>
2. ✋ <action only the user can take> · <recorded on date and time>

### <space name> · go to tab <tab name>
3. ✋ <agent role> is stopped at a dialog: <what it asks, from `hc read <terminal> --lines 20`>

### <Outside the spaces>
4. 👀 <repo>#<n> · <short name> · <who asked for the review>

### <Your open PRs>
- ⏳ <repo>#<n> · <short name> · draft · <space name or "no space">
- ✅ <repo>#<n> · <short name> · CI ok · <space name>

<Spaces with nothing for you: names, in one plain line> · <stale records or skipped sources, in one plain line>
````

- **First line, always**: how many numbered items depend on the user and in how many spaces, or that nothing does. It counts ❓, 👀, and ✋ items only.
- **One numbered queue across spaces**, so the user can refer to an item by number. Spaces are ordered by how long their oldest item has waited, oldest first; inside a space, keep the order of its `leader.md`.
- **Where to go**: every space heading names the tab to open (the Leader's for recorded items, the stopped agent's for dialogs).
- **Stale records**: when a team's `leader.md` was last updated more than a day ago and it lists pending items, keep the items and add *(recorded <n> days ago, may be out of date)*; the user can confirm with that Leader.
- **Your open PRs** are context, not a queue: no numbers, one [PR line](../herdr-leader-report/references/report-format.md#pr-line)-like item each (repository, short name, draft, CI), with its space. A PR already listed under 👀 is not repeated.
- Never relay an agent's raw message; translate it into what the user must do.

When the user named a space, show only that space and keep the first line about all spaces.

## 4. Success Validation

- [ ] Herdr App environment verified, without the `herdr` terminal CLI or `--on`; nothing was written, sent, answered, or renamed.
- [ ] Every active team's `leader.md` Pending Decisions, every `blocked` or `error` agent, and the PRs waiting for the user's review were read; skipped sources are named.
- [ ] The inbox opens with the line counting what depends on the user across spaces, then one numbered queue grouped by space, each heading naming the tab to open.
- [ ] Items are in system terms, with their recording time; records older than a day are marked as possibly stale.
- [ ] The user's open PRs appear once, unnumbered, with their space; PRs waiting for the user's review are not repeated there.
- [ ] Spaces with nothing pending are named in one closing line.
