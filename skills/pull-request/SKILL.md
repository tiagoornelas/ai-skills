---
name: pull-request
description: >-
  Formats and opens pull requests (on GitHub, through the gh CLI) focused on
  high-level review: a direct executive summary at the top, the change card's
  plan of what is new and where it lives, a swimlane via visualize-it when a
  flow across the system changes, and issue linkage verification.
---

# Pull Request

Skill for structuring, documenting, and opening pull requests, on GitHub through the GitHub CLI (`gh`).

---

## 1. Pull Request Principles

- **Designed for the Reviewer**: The reviewer must understand the purpose of the PR within the first 5 seconds of reading.
- **Focus on High-Level Review**: Grounded in the philosophy of [`ai-assisted-software-development`](../ai-assisted-software-development/SKILL.md) and [`human-review`](../human-review/SKILL.md). Do not clutter the PR with internal implementation minutiae already validated by [`agent-self-review`](../agent-self-review/SKILL.md).
- **The change card first**: right after the summary, the body carries the change's [change card](../ai-assisted-software-development/references/change-card.md) plan, complete with its `state` line, so the reviewer sees what is new and where it lives before anything else. This skill cites the card; it never redefines it.
- **A flow only when it changed**: when the PR changes how a flow crosses places of the system, a [`visualize-it`](../visualize-it/SKILL.md) swimlane, in Mermaid, shows it. No module map, interface, or method signature.

---

## 2. Issue Linkage and Traceability

The issue holds the objective and acceptance criteria, and the PR body holds the user's decisions and the change card, per [where a task's facts live](../ai-assisted-software-development/SKILL.md#6-where-a-tasks-facts-live). A missing issue never blocks the PR.

### Agent Workflow:
1. **If an issue exists in context** (Jira, GitHub Issues, Linear, etc.):
   - Link the identifier and URL in the PR traceability section.
   - Link every issue the PR resolves, not only the main one.
2. **If no issue exists**: proceed without an issue link; the objective and acceptance criteria stay in the conversation.
3. **A delivery across repositories** opens one PR per repository from the same branch name; the main PR carries the change card and the merge order, and every PR links the others under Related PRs, per [branch-and-worktrees.md](../agentic-parallel-work/references/branch-and-worktrees.md#4-one-delivery-several-repositories).

### Supporting References

Beyond the issue, the traceability section records where the work came from and what it connects to, so any reader can follow the trail without asking:

| Reference | What it links |
| :--- | :--- |
| **Origin** | The report or discussion that started the work (user report, support thread, team conversation). |
| **Error** | The monitored error or alert the PR addresses. |
| **Related PRs** | Companion changes in other repositories or layers. |
| **Other** | Design docs, decision records, mockups, recordings, dashboards, or queries. |

- **Gather available links** from the conversation, branch, commits, and issue description or comments when accessible. Omit references whose links are unavailable; do not pause PR creation to request them.
- **Label every link** with what it is (e.g., `[support report on checkout failure](<url>)`), never a bare URL.
- **Include only lines that have a link**: omit empty categories instead of writing "N/A".
- Every link must be reachable by the reader ([no-local-references](../ai-assisted-software-development/references/no-local-references.md)).

---

## 3. PR Title Format

```text
Type/Concise Description
```
*Accepted Types:* `Feat/`, `Fix/`, `Refactor/`, `Chore/`, `Perf/`, `Docs/`.
*Examples:*
- `Feat/Refresh token authentication and key rotation`
- `Fix/Intermittent timeout on payment gateway call`
- `Refactor/Isolate order repository persistence`

> **Convention note**: PR titles use a PascalCase prefix followed by a description in the team/repository language for triage on GitHub, while individual commits strictly adhere to English Conventional Commits (`feat(auth): ...`).

---

## 4. PR Description Template (Body)

Use the structure below:

> **Body language**: all prose and section headings in the description, plus the DoD table header and legend, use the team/repository language (same rule as the title). The template headings below are placeholders: translate them. Keep technical terms (`Definition of Done`, `breaking changes`) and code identifiers as is. Do not copy the language of previous PRs if it conflicts with this rule.

````markdown
## Summary
[In 1 to 3 direct sentences, explain what this PR does and why it exists from the reader's perspective: where in the product it acts, what users or the system experienced before, and what happens now. Situate every screen, state, or internal layer before naming it (see the Briefing a Change section of the ai-assisted-software-development human-facing-communication reference).]

---

## Change Card

```text
[The change card's plan of this PR, per the change-card reference of ai-assisted-software-development: the count line, one line per thing, and the closing lines with the state. Inside a text block: GitHub renders it monospace, so its columns stay aligned.]
```

---

## Traceability & Issue
- **Issue**: [Link and issue key, e.g.: `#42` or `PROJ-123`] (short summary of the issue)
- **Origin**: [Labeled link to the report or discussion that started the work]
- **Error**: [Labeled link to the monitored error or alert]
- **Related PRs**: [Labeled links, e.g.: `#1235 (frontend)`]
- **Other**: [Labeled links to docs, decision records, mockups, recordings, dashboards]
<!-- Keep only the lines that have a link. Omit this section if there are no links. -->

---

## Decisions & Trade-offs
[When material, explain actual business rules/restrictions, contracts created or altered (who calls, what crosses, what it promises, how it fails, in system terms), consequential trade-offs, assumptions, and maintenance commitments introduced by the change. Derive this from the implementation and reuse existing human-review findings; do not run a separate review just to fill this section. Omit if there is nothing material.]

---

## How It Works
<!-- Only when the PR changes a flow across places of the system: a swimlane via visualize-it, as a Mermaid sequenceDiagram, followed by at most two sentences on what to notice. Omit otherwise. -->

---

## Delivered Behaviors (Definition of Done)

Status table mapping implemented behaviors to verification status, adhering to the [Definition of Done legend](../ai-assisted-software-development/references/human-facing-communication.md#definition-of-done-legend):

| Status | Delivered Behavior | Verification | Action for Reviewer |
| :---: | :--- | :--- | :--- |
| ✅ | Reject expired tokens with HTTP 401 | Unit test in `tests/auth.test.ts` | None (covered by test) |
| 🔎 | Dispatch confirmation email via real provider | Not code-testable; verified in staging | Optional to test |
| 👤 | Responsive layout for login form | Requires visual inspection | Open `/login` and verify on mobile (375px) |

*Legend: ✅ Covered by automated test · 🔎 Not code-testable, verified via alternative means · 👤 Requires manual human validation · 🚨 Missing or unverified*

---

## Impact & Breaking Changes
- [Describe API contract breaks, database migrations, or new environment variables. If none, write "None"].
````

### Screenshot (Optional)

When the diff changes the user-facing presentation layer (screens, components, styles, layouts), add a `Screenshot` section with one embedded image if an accessible image URL is already available. Otherwise omit the section and mention after creating the PR that the developer may add a screenshot in GitHub. Do not pause to request one.

GitHub CLI and API cannot upload images into a PR body, so do not try to attach image files. Never commit images to the repository or upload them to third-party hosts just to embed them.

---

## 5. PR Creation Workflow

1. **Branch Self-Review**:
   - If the branch carries code authored by the agent pipeline, run [`agent-self-review`](../agent-self-review/SKILL.md) in **branch mode** (Section 3.2) unless `HEAD` already carries a `branch` self-review note. Resolve its Blocking findings before continuing; list its Escalate findings for the developer.
2. **Check the Facts Agree**: the objective and acceptance criteria (issue or conversation), the user's decisions, and the change card describe the same change; fix the one that drifted before opening, and carry the decisions into the body.
3. **Ensure Remote is Up to Date**:
   - Verify all commits are recorded, each following [`commit`](../commit/SKILL.md), and push the branch:
     ```bash
     git push -u origin <branch-name>
     ```
4. **Create the PR**:
   - Prepare and verify the title and body, then open the PR without a separate approval prompt or preview. The user's request to open the PR authorizes creation of the draft.
   - Run the command via GitHub CLI:
     ```bash
     gh pr create --draft --title "<title>" --body-file <body-file>
     ```
   - Create as `--draft` unless the user explicitly requests ready for review.
5. **Output**:
   - Return the clickable GitHub PR link.
   - For a visible UI change without an embedded screenshot, mention that the developer may add one through GitHub's web interface.

---

## 6. Success Validation

- [ ] Agent-authored branches passed `agent-self-review` in branch mode before the PR was opened.
- [ ] Existing issues and supporting references were linked with descriptive labels, with no empty categories; no issue did not block creation; the PRs of a multi-repository delivery link each other and the main one carries the card and merge order.
- [ ] Objective, acceptance criteria, decisions, and change card were checked against each other before opening.
- [ ] Title follows `Type/Description`; headings, DoD table header, and legend are in the team/repository language.
- [ ] Body has the summary, the change card's plan with its `state` line in a text block, a swimlane (via `visualize-it`) only when a flow changed, and the DoD table with its legend.
- [ ] The PR was opened (defaulting to `--draft`) and its clickable link returned; for a visible UI change, an available screenshot was embedded or the developer was reminded one can be added.
