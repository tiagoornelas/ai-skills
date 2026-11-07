---
name: pr-code-review
description: >-
  Reviews a pull request (a teammate's or the user's own; on GitHub, through
  the gh CLI) or a diff from a fixed reference point, as a thin adapter over
  two base skills: human-review for what changed, where it lives, and what the
  user must decide, and provide-evidence for whether it is proven. Adds the
  pull-request mechanics: the comparison baseline, re-review of prior feedback
  against incremental commits, a recommended verdict, and accepted findings
  turned into humanized line comments ready to paste or publish on
  confirmation. Deeper review axes run only on request. Used on demand when
  the user asks to review or re-review a pull request or diff.
disable-model-invocation: true
argument-hint: "[PR number/URL, branch, SHA, or base ref] [--re-review]"
---

# PR Code Review

For reviewing a pull request (on GitHub, through `gh`) or any diff from a fixed base, whoever wrote it. The deliverable is **helping the user decide** (approve or request changes) and **the specific points they will comment on**. This skill owns only the pull-request mechanics; the review itself is [`human-review`](../human-review/SKILL.md) and the proof is [`provide-evidence`](../provide-evidence/SKILL.md). Nothing is modified: everything becomes a finding, and the user chooses what to comment on.

## 1. Establish the Comparison Baseline

Use the reference provided by the user: PR number/URL, SHA, branch, tag, `main`, `HEAD~5`, optionally with `--re-review`.

### 1.1. Fresh Review Baseline
- **GitHub PR**: `gh pr view <pr> --json number,title,body,baseRefName,headRefName,url,author` and `gh pr diff <pr>`. The PR base is the fixed point.
- **Local Ref**: `git diff <fixed-ref>...HEAD` (triple-dot, against merge-base) and `git log <fixed-ref>..HEAD --oneline`.

Capture the diff **once**. Verify that the reference resolves and that the diff is non-empty **before** creating subagents: invalid refs must fail here, not inside subagent threads.

### 1.2. Re-review Mode (`--re-review` or follow-up prompt)
When the user indicates a re-review (via `--re-review` flag or session prompt):

1. **Collect Previous Review Threads and Comments**:
   Fetch PR reviews, conversation comments, and line threads via GraphQL:
   ```bash
   gh pr view <pr> --json number,title,body,baseRefName,headRefName,url,author,reviews,comments
   gh api graphql -F owner=<owner> -F repo=<repo> -F pr=<pr> -f query='
   query($owner:String!,$repo:String!,$pr:Int!){
     repository(owner:$owner,name:$repo){
       pullRequest(number:$pr){
         reviewThreads(first:100){ nodes{
           id isResolved isOutdated path line
           comments(first:50){ nodes{ databaseId url author{login} body diffHunk createdAt } }
         }}
       }
     }
   }'
   ```
2. **Identify Incremental Commits**:
   Determine commits added since the previous review round (`git log <previous-head>..HEAD --oneline` or commits committed after the latest previous review timestamp).
3. **Audit Previous Findings (Resolution Matrix)**:
   For every previous thread and feedback item, inspect current code and author responses:
   - 🟢 **Resolved**: Problem was fixed in code and verified in the diff.
   - 🔀 **Adjusted**: Addressed via an alternative sound approach; rationale verified.
   - 🔴 **Unresolved**: Problem remains unaddressed or new fix is defective.
   - 💬 **Discussed / Deferred**: Acknowledged without code change, or deferred with tracking issue.
4. **Scope for Evaluation Axes**:
   The review, and any requested axes, evaluate the **incremental diff** (`<previous-head>..HEAD`), plus targeted inspection of lines altered to resolve previous comments. This prevents re-debating settled code while catching regressions, scope creep, or defects in newly added commits.

## 2. Review

1. Apply [`human-review`](../human-review/SKILL.md) once to the baseline: one sentence on what changes for whom, the change card, the user's decisions, and only the findings with a consequence. Reuse that investigation for every follow-up.
2. Show the proof with [`provide-evidence`](../provide-evidence/SKILL.md) (show, read-only): the PR line and its evidence lines as recorded, or that none exists.
3. **Deeper review only on request.** Systematic Agent Layer review, a full multi-axis review, or selected axes follow [review-axes.md](references/review-axes.md), after and beside the guide's assessment, never instead of it.

Disclose missing business context and what was not covered; ask only when it changes the recommendation. Never infer the expected requirements from the implementation alone.

## 3. Severity

Every finding carries one badge:

- 🔴 **Critical**: breaks a requirement, introduces a bug, fails build or test tooling, or violates a mandatory rule. Must not be merged as is.
- 🟡 **Warning**: a real concern, not blocking, worth discussing before merge.
- 🟢 **Suggestion**: a minor improvement **with a concrete scenario**. Style preferences without a concrete consequence are never reported.

Documented rule violations in a peer's PR are 🔴 or 🟡 by impact. An evidence-backed architectural concern may require a Human Layer decision before merge even without a current bug.

## 4. Present and Discuss

Open with the guide's output and the proof, then the findings by severity, each with `file:line`. The blocks below are examples; their fixed words are written in the user's session language.

In **Re-review Mode**, open the report with the resolution audit table before presenting findings on the incremental commits:

```markdown
### 📋 Previous Review Resolution Matrix

| # | Location | Original Finding | Author Response / Commit | Resolution Status |
| :-: | :--- | :--- | :--- | :---: |
| 1 | `src/billing/invoice.ts:42` | Missing lock timeout | Added `SET lock_timeout = '2s'` in `abc1234` | 🟢 Resolved |
| 2 | `src/users/repo.ts:15` | N+1 query on roles | Eager loaded roles with `includes(:roles)` | 🟢 Resolved |
| 3 | `src/orders/service.ts:88` | Unbounded list query | Author noted pagination deferred to follow-up | 💬 Deferred |
| 4 | `src/auth/jwt.ts:24` | Token validation flaw | No commit addressing this | 🔴 Unresolved |

🟢 N Resolved · 🔀 N Adjusted · 💬 N Deferred · 🔴 N Unresolved
```

Conclude with summary and **recommended verdict**:

```markdown
## 📊 Summary

🔴 Critical:   N   — requires attention prior to merge (or unresolved prior blocker)
🟡 Warning:    N   — worth discussing
🟢 Suggestion: N   — optional

Highest-risk axis: **<axis>** (<key finding in one line>)   ← only when the review axes ran

**Suggested Verdict:** ✅ Approve | 🔁 Request changes
<single sentence rationale>
```

Verdict rule: a critical defect, a material unresolved decision, or a failing proof → **Request changes**, with the reason. Incomplete evidence → state the limitation and what remains to verify, never an automatic approval. **Approve** only within the reviewed scope when nothing material remains; a focused Human Layer review does not certify unreviewed Agent Layer quality. **The verdict belongs to the user**; accepted concessions are respected unless new evidence changes their premises. The summary and rationale are for discussion with the user, who may promote, demote, or discard findings; they are not a general PR review comment.

When the PR was authored by the agent pipeline (the user's own work), tag each accepted Agent Layer finding with its escape cause per [escape-classification.md](../agent-self-review/references/escape-classification.md) and add the one-line tally to the summary.

---

## 5. Format Accepted Points into Comments

As the user discusses each finding, establish whether they accept it and draft its line comment then. Do not wait for the final verdict to prepare accepted point-by-point comments. Ask for the user's final verdict when the review is ready to submit. Only accepted findings become review comments: never publish the unfiltered report.

### 5.1. Line Comments

For each accepted finding, generate a ready-to-paste comment in the language of the PR/repository (or user session language). Draft and pass through the [`unslop`](../unslop/SKILL.md) skill before presenting: comments are read by teammates, and formulaic AI phrasing damages collaborative rapport.

<comment-template>

**File:** `path/to/file.ext`
**Line:** N (or range N-M)

{{professional, collaborative explanation covering the *why*: concrete failure scenario, maintenance risk, or cost}}

{{if a specific code snippet or approach was agreed upon: include it here at the end in a code block}}

</comment-template>

### 5.2. General Review Comment (Only on Explicit Request)

By default, leave the overall review body empty for both **Approve** and **Request changes**. Line comments and existing thread replies carry the accepted feedback; do not repeat them in a general review comment. Draft a general review body only if the user explicitly requests one, aligned with their chosen verdict, and run it through `unslop`.

### 5.3. Thread Replies in Re-review Mode

When conducting a re-review, findings often continue existing unresolved conversations:
- **Unresolved threads**: Draft replies to be posted directly into the existing review thread (`addPullRequestReviewThreadReply` with `threadId`), stating concisely why the point remains unresolved or what remains defective.
- **New findings on incremental commits**: Format as standard line comments per Section 5.1.

### Comment Guidelines

- **Exact file and line.** If the finding lacks precise location, inspect the diff. Never guess.
- **[No local references](../ai-assisted-software-development/references/no-local-references.md)**. Reference linked issues (Jira/GitHub), or rephrase requirements.
- **Professional and collaborative.** Phrase as observations for discussion, not unilateral demands. Prefer *"we might consider"* over *"you should have"*.
- **Explain the why**, not merely what.
- **No speculative fixes.** If no solution was discussed, conclude with the explanation.
- **No signature lines.** Zero co-authorship tags, AI disclaimers, or footers.
- Technical terms, code identifiers, and snippets remain in their original form.
- Present in the order findings were discussed, ready to copy.

## 6. Publishing

Never publish automatically. If the user explicitly requests publication, display the exact payload, including the verdict, each accepted line comment or thread reply, and the general review body only when explicitly requested; publish strictly upon confirmation. Use a submission method that supports the accepted point-by-point comments and an empty review body. If the GitHub interface rejects an empty body for **Request changes**, explain that constraint and ask the user how to proceed; do not invent a summary or silently switch the verdict.

---

## 7. Success Validation

- [ ] The diff was captured once and validated; the user's working tree stayed untouched.
- [ ] The review came from `human-review` and the proof from `provide-evidence`, not re-derived here; deeper axes ran only on request.
- [ ] In re-review mode, every prior feedback item got a resolution status and only the incremental diff was evaluated.
- [ ] Every finding had `file:line` and a severity badge; on the user's own work, accepted Agent Layer findings carry their escape cause and the summary its tally; the recommended verdict followed the verdict rule and the user decided.
- [ ] Only accepted findings became humanized comments, with exact locations and no AI footers; no general review body unless requested.
- [ ] Nothing was published without an explicit request and confirmation.
