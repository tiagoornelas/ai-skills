---
name: pull-request
description: >-
  Writes and opens pull requests (on GitHub, through the gh CLI) as the
  delivery document of a finished change, written for the other developers who
  review it before merge and read it later: why the change exists, its
  references, what it adds, changes, or removes and where it lives, the
  decisions taken, how a changed flow works (a visualize-it swimlane), how it
  was tested, and what deploying it needs, readable by anyone who never saw the
  work. Triggered before opening or updating a pull request, or when
  a skill hands off to open one.
---

# Pull Request

A pull request is the permanent record of one change, written for developers who never saw the work happen: the reviewer before merge and whoever reads it years later. To them the work is always finished and ready.

---

## 1. What the Body Holds, and What It Never Holds

- **Holds facts about the change** that stay true after merge: why it exists, what it adds, changes, or removes and where, the decisions taken and their reasons, how a changed flow works, how each behavior was tested, and what it breaks.
- **Never holds the state of the work or the flow that produced it**: draft, CI, review, or proof status; approvals; decisions still open; what is missing; review rounds or follow-up lists; and the vocabulary of the authoring workflow (change card, plan, notice, self-review, agents, sessions). Decisions are taken before the PR is opened; whether the user ratified them lives outside the body.
- **Nothing reads the body back.** No workflow takes state, decisions, or approvals from a PR; those live in the issue, the conversation, or git notes.
- **Updating a PR rewrites the body to describe the change as it now is**, never appends a log of what changed since the last version.
- **Lead with the reader's question**: what this changes, for whom, and why, in the first lines. No implementation detail already settled below the contracts.

---

## 2. Title and Language

- **Title**: the repository's PR title convention, read from its latest pull requests (`gh pr list --state all --limit 20 --json title`). Without one, `Type/Concise description`, with `Feat`, `Fix`, `Refactor`, `Chore`, `Perf`, or `Docs` (e.g. `Fix/Intermittent timeout on payment gateway call`).
- **Language**: the title and the whole body, headings and table headers included, use the language of most of the repository's pull requests; without pull requests, the language of its documentation and commits; English when nothing indicates one. Technical terms and code identifiers stay as they are.
- **Sentences**: the title and every sentence of the body follow [`technical-writing`](../technical-writing/SKILL.md); this skill owns the structure.

---

## 3. References

Every link the reader needs to follow the trail, each labeled with what it is (`[support report on checkout failure](<url>)`), never a bare URL, and reachable by the reader ([no-local-references](../ai-assisted-software-development/references/no-local-references.md)):

| Reference | What it links |
| :--- | :--- |
| **Issue** | Every issue the PR resolves (Jira, GitHub Issues, Linear), with key and a short summary; on GitHub Issues, with the closing keyword (`Fixes #123`) so merging closes it. |
| **Origin** | The report or discussion that started the work. |
| **Alert** | The monitored error or alert the PR addresses. |
| **Related PRs** | Companion changes in other repositories of the same delivery, and any PR that must merge before this one. |
| **Other** | Design docs, decision records, mockups, recordings, dashboards, or queries. |

Gather the links from the conversation, branch, commits, and issue; keep only lines that have one, and do not pause to ask for missing ones. A missing issue never blocks the PR. A delivery across repositories opens one PR per repository from the same branch name, per [branch-and-worktrees.md](../agentic-parallel-work/references/branch-and-worktrees.md#4-one-delivery-several-repositories), each describing its own part and linking the others.

---

## 4. Body Template

When the repository has its own pull request template (`.github/pull_request_template.md` or similar), fill its headings with the content below and keep its order. Otherwise use this layout. The headings are an example, written in the PR's language; the content is mandatory. Omit a section only where it says so. Every word must make sense to a reader who knows nothing of how the change was produced.

````markdown
## Summary
[1 to 3 sentences: where in the product the change acts, what users or the system experienced before, what happens now, and why. Situate every screen, state, or internal layer before naming it.]

## References
- Fixes #123: [one-line summary] · **Origin**: … · **Related PRs**: … · **Other**: …

## What Changes
```text
billing-api
├─ db
│  └─ Added: exported invoices table
└─ jobs
   └─ Added: PDF rendering job. It lays out the PDF itself, while other documents use the templates folder, because …
web-app
└─ Added: "Download PDF" button
```

Exported PDFs are now deleted after 90 days; before, they were kept forever. No data is rewritten or sent out, and the public API, the database schema of existing tables, and permissions are unchanged.
[A tree of the system with each high-level thing the change brings in, changes, or removes hanging where it lives, of the kinds the [change card](../ai-assisted-software-development/references/change-card.md#2-the-tree) lists, each leaf opening with Added, Changed, or Removed; anything that departs from how the project usually does that kind of thing says so in words, with why. Then plain sentences on business rules before and after, data deleted, rewritten, or sent out, and what does not change, named concretely. No counts, approvals, or status.]

## Decisions
[Each decision taken and its reason, ordered by cost to reverse after merge, the hardest first: business rules, contracts created or altered (who calls, what crosses, what it promises, how it fails), consequential trade-offs, assumptions, and maintenance commitments. When there was a real choice, name the alternative not taken and why. Omit when there is nothing material.]

## How It Works
[Only when the change alters a flow across places of the system: a visualize-it swimlane as a Mermaid sequenceDiagram, then at most two sentences on what to notice. Omit otherwise.]

## Testing
| Behavior | How it was verified | How to check |
| :--- | :--- | :--- |
| Expired tokens get HTTP 401 | Automated test `tests/auth.test.ts` | Runs in CI |
| The confirmation email arrives | Manual: sent from staging through the real provider | Not reproducible locally |
| The login form fits a phone screen | Not verified: needs a person to look | Open `/login` at 375px |

[One row per behavior, the verification in words: an automated test named, a manual check and how, or not verified and why. Add a screenshot when the change is visible and an accessible image URL already exists.]

## Deployment and Risk
[Breaking changes, database migrations, new configuration, environment variables, or secrets, deploy order, and how to roll back; "None" when there are none.]
````

The swimlane follows [`visualize-it`](../visualize-it/SKILL.md). GitHub CLI cannot upload images into a PR body: never commit images or upload them to a third-party host to embed them. When a visible change has no screenshot, say after opening that the developer may add one.

---

## 5. Opening the PR

1. **Self-review**: a branch carrying agent-authored code passes [`agent-self-review`](../agent-self-review/SKILL.md) in branch mode first, unless `HEAD` already carries a `branch` self-review note. Resolve its Blocking findings; list its Escalate findings for the developer.
2. **Check the description matches the change**: the summary and decisions agree with the objective and acceptance criteria (issue or conversation), and What Changes matches the diff.
3. **Push** the branch, every commit following [`commit`](../commit/SKILL.md): `git push -u origin <branch-name>`.
4. **Open** without a separate approval prompt (the request to open the PR authorizes it), as a draft unless the user asks for ready for review: `gh pr create --draft --title "<title>" --body-file <body-file>`, adding `--base <branch>` for a PR stacked on the branch it builds on.
5. **Prove and report**: inside a delivery, verify the head with [`provide-evidence`](../provide-evidence/SKILL.md) and send the PR link inside the [delivery report](../ai-assisted-software-development/references/human-facing-communication.md#3-the-delivery-report), never alone; otherwise return the clickable PR link. Add the screenshot reminder when it applies.

---

## 6. Success Validation

- [ ] Agent-authored branches passed `agent-self-review` in branch mode before the PR was opened.
- [ ] The body holds only facts about the change that stay true after merge, readable by anyone: no work status, approval, open decision, follow-up list, workflow vocabulary, or symbol only the author's tooling defines.
- [ ] Summary, References, What Changes (with what does not change), Testing, and Deployment and Risk are present, in the repository's own template when it has one; Decisions and How It Works appear when material; the description matches the diff and the issue.
- [ ] Every reference is a labeled, reachable link, with no empty lines; a multi-repository delivery's PRs link each other.
- [ ] Title and body follow the repository's convention and language, English when nothing indicates one.
- [ ] The PR was opened (draft by default) and, inside a delivery, its link reached the user in the delivery report after verify; the screenshot reminder came for a visible change without one.
