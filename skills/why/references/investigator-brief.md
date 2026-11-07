# Investigator Brief

> **Central thesis**: each investigator goes deep on one source and returns evidence, not conclusions, so the caller can weigh all sources together. Send the brief verbatim, with the placeholders filled and the search tips for the investigator's category.

---

## When to consult

- Briefing each investigator of `why`, step 3.

---

## Brief

> You are investigating the history and motivation behind a piece of code. Other investigators search other sources in parallel, and the caller combines the findings. Go deep on your assigned source only. Do not modify, post, or create anything.
>
> **Question**: `<the user's question>`
> **Code anchor**: `<files and line ranges>` · `<key symbols>` · `<commits touching it, newest first>` · `<pull request numbers>` · `<ticket keys>`
> **Your source**: `<category and tool>` · `<search tips for that category, below>`
>
> 1. Cast a wide net first, then narrow.
> 2. Read each pull request, ticket, document, or thread in full: the key evidence is often in a comment or follow-up.
> 3. Follow links within your source only; record a link into another source under "leads".
> 4. Quote verbatim, with the exact location (pull request, ticket, URL, commit, file and line), author, and date.
> 5. Record every query you ran, verbatim: an empty search is a finding.
> 6. Record contradictions; never drop the item that does not fit.
>
> Claim intent only where an author stated it: code behavior and style are not evidence of intent. Keep ambiguity ambiguous, and never present evidence about one thing as an answer about another. Gather; do not conclude. If your tool is not authenticated or not reachable, stop and report that the source was not searchable.
>
> Return: **Source** · **What I searched** · **Direct evidence** (quote, location, author and date, relevance) · **Indirect evidence** (what it is, location, what it suggests, alternative readings) · **Contradictions** · **Gaps** (what was searched and not found) · **Leads** for other sources.

## Search Tips by Category

| Category | Where the why hides | How to search |
| :--- | :--- | :--- |
| **Source control** | Commit messages, pull request descriptions and reviews, tests that encode the motivating edge case, decision records, changelogs | `git log --follow -p`, `git log -S` and `-G` for the exact string or pattern, `git blame`, files changed in the same commits, `rg` for decision records, and test names near the symbol |
| **Issue tracker** | The product or business reason, often outside engineering | The ticket keys from the anchor first, then the symbol, feature, or error string; read parents, subtasks, and comments |
| **Documents** | Design rationale written before the code | Feature and component names, and documents the pull requests link; note each document's date against the commit |
| **Team chat** | Deliberation that never reached a document | Messages from the pull request author around its merge date, the pull request URL, and error strings; always read the whole thread; a joke is not a decision; note retention limits and unsearchable direct messages |
| **Observability** | The runtime reality behind timeouts, retries, and limits | Monitors, dashboards, and metrics named after the service or symbol around the commit date |
| **Error tracking** | The exceptions behind guards, catches, and retries | The error type and message the code handles, and issues first seen shortly before the commit |
| **Analytics** | Experiment results, data migrations, and where a number came from | Flags and experiments named in the code, and tables the change reads or writes |

When the target looks defensive (null checks, retries, timeouts, rate limits, feature flags, out-of-memory handling), also search your source for incidents and postmortems around the commit date: incident labels in the tracker, incident channels in chat, and "fix for incident", revert, and re-apply commits in git.
