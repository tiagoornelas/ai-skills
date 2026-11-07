---
name: pull-request
description: >-
  Writes and opens pull requests (on GitHub, through the gh CLI) as the
  delivery document of a finished change, written for the other developers who
  review it before merge and read it later: why the change exists, its
  references, what it adds, changes, or removes and where it lives, the
  decisions taken, how a changed flow works (a visualize-it swimlane), and the
  test evidence. Triggered before opening or updating a pull request, or when
  a skill hands off to open one.
---

# Pull Request

A pull request is the permanent record of one change, written for developers who never saw the work happen: the reviewer before merge and whoever reads it years later. To them the work is always finished and ready.

---

## 1. What the Body Holds, and What It Never Holds

- **Holds facts about the change** that stay true after merge: why it exists, what it adds, changes, or removes and where, the decisions taken and their reasons, how a changed flow works, how each behavior was tested, and what it breaks.
- **Never holds the state of the work or the flow that produced it**: draft, CI, review, or proof status; approvals; decisions still open; what is missing; review rounds or follow-up lists; and the vocabulary of the authoring workflow (change card, plan, notice, self-review, agents, sessions). Open decisions are settled before the PR is opened.
- **Nothing reads the body back.** No workflow takes state, decisions, or approvals from a PR; those live in the issue, the conversation, or git notes.
- **Updating a PR rewrites the body to describe the change as it now is**, never appends a log of what changed since the last version.
- **Lead with the reader's question**: what this changes, for whom, and why, in the first lines. No implementation detail already settled below the contracts.

---

## 2. Title and Language

- **Title**: the repository's PR title convention, read from its latest pull requests (`gh pr list --state all --limit 20 --json title`). Without one, `Type/Concise description`, with `Feat`, `Fix`, `Refactor`, `Chore`, `Perf`, or `Docs` (e.g. `Fix/Intermittent timeout on payment gateway call`).
- **Language**: the title and the whole body, headings and table headers included, use the language of most of the repository's pull requests; without pull requests, the language of its documentation and commits; English when nothing indicates one. Technical terms and code identifiers stay as they are.

---

## 3. References

Every link the reader needs to follow the trail, each labeled with what it is (`[support report on checkout failure](<url>)`), never a bare URL, and reachable by the reader ([no-local-references](../ai-assisted-software-development/references/no-local-references.md)):

| Reference | What it links |
| :--- | :--- |
| **Issue** | Every issue the PR resolves (Jira, GitHub Issues, Linear), with key and a short summary. |
| **Origin** | The report or discussion that started the work. |
| **Error** | The monitored error or alert the PR addresses. |
| **Related PRs** | Companion changes in other repositories of the same delivery, and any PR that must merge before this one. |
| **Other** | Design docs, decision records, mockups, recordings, dashboards, or queries. |

Gather the links from the conversation, branch, commits, and issue; keep only lines that have one, and do not pause to ask for missing ones. A missing issue never blocks the PR. A delivery across repositories opens one PR per repository from the same branch name, per [branch-and-worktrees.md](../agentic-parallel-work/references/branch-and-worktrees.md#4-one-delivery-several-repositories), each describing its own part and linking the others.

---

## 4. Body Template

The layout and the headings are an example, written in the PR's language; the content is mandatory. Omit a section only where it says so.

````markdown
## Summary
[1 to 3 sentences: where in the product the change acts, what users or the system experienced before, what happens now, and why. Situate every screen, state, or internal layer before naming it.]

## References
- **Issue**: [labeled link] · **Origin**: … · **Related PRs**: … · **Other**: …

## What Changes
```text
+  table of exported invoices          table · billing-api
+  "export invoice as PDF" route       route · billing-api
~  invoice page offers the export      screen · web-app
~  PDFs deleted after 90 days          rule · billing-api · was: kept forever
-  manual export script                job · billing-api
!  PDF layout written inside the job   out of pattern · other documents use the templates folder, because …

unchanged  no new service, queue, secret, or client · no data rewritten or sent out · contracts and boundaries intact
```
[One line per thing added (+), changed (~), or removed (-), named in product terms with its kind and the place it lives, covering the [kinds of new things](../ai-assisted-software-development/references/change-card.md#2-the-plan) of the change card; a changed rule shows before and after; `!` marks what departs from the project's pattern or crosses a boundary, with why. The closing `unchanged` line names the kinds with nothing new and states whether contracts and boundaries stayed intact. No counts, approvals, or status.]

## Decisions
[Each decision taken and its reason: business rules, contracts created or altered (who calls, what crosses, what it promises, how it fails), consequential trade-offs, assumptions, and maintenance commitments. Omit when there is nothing material.]

## How It Works
[Only when the change alters a flow across places of the system: a visualize-it swimlane as a Mermaid sequenceDiagram, then at most two sentences on what to notice. Omit otherwise.]

## Test Evidence
| | Behavior | How it was verified | How to check |
| :---: | :--- | :--- | :--- |
| ✅ | Reject expired tokens with HTTP 401 | Unit test in `tests/auth.test.ts` | Covered by the test suite |
| 🔎 | Send the confirmation email via the real provider | Not code-testable; sent from staging | Optional |
| 👤 | Login form fits a phone screen | Visual inspection | Open `/login` at 375px |

[Marks and the legend line below the table follow the Definition of Done legend. Add a screenshot when the change is visible and an accessible image URL already exists.]

## Impact
[Contract breaks, database migrations, new environment variables, and what a deploy or rollback needs; "None" when there are none.]
````

The marks of Test Evidence follow the [Definition of Done legend](../ai-assisted-software-development/references/human-facing-communication.md#definition-of-done-legend); the swimlane follows [`visualize-it`](../visualize-it/SKILL.md). GitHub CLI cannot upload images into a PR body: never commit images or upload them to a third-party host to embed them. When a visible change has no screenshot, say after opening that the developer may add one.

---

## 5. Opening the PR

1. **Self-review**: a branch carrying agent-authored code passes [`agent-self-review`](../agent-self-review/SKILL.md) in branch mode first, unless `HEAD` already carries a `branch` self-review note. Resolve its Blocking findings; list its Escalate findings for the developer.
2. **Check the description matches the change**: the summary and decisions agree with the objective and acceptance criteria (issue or conversation), and What Changes matches the diff.
3. **Push** the branch, every commit following [`commit`](../commit/SKILL.md): `git push -u origin <branch-name>`.
4. **Open** without a separate approval prompt (the request to open the PR authorizes it), as a draft unless the user asks for ready for review: `gh pr create --draft --title "<title>" --body-file <body-file>`.
5. **Return** the clickable PR link, plus the screenshot reminder when it applies.

---

## 6. Success Validation

- [ ] Agent-authored branches passed `agent-self-review` in branch mode before the PR was opened.
- [ ] The body holds only facts about the change that stay true after merge: no work status, approval, open decision, follow-up list, or workflow vocabulary.
- [ ] Summary, References, What Changes (with its `unchanged` line), Test Evidence, and Impact are present; Decisions and How It Works appear when material; the description matches the diff and the issue.
- [ ] Every reference is a labeled, reachable link, with no empty lines; a multi-repository delivery's PRs link each other.
- [ ] Title and body follow the repository's convention and language, English when nothing indicates one.
- [ ] The PR was opened (draft by default) and its link returned, with the screenshot reminder for a visible change without one.
