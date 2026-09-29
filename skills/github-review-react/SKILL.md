---
name: github-review-react
description: >-
  Responds to review comments left by a teammate on the user's GitHub Pull Request:
  collects pending comments, evaluates each for validity and feasibility,
  visualizes problems and proposed solutions, collaborates with the user to
  determine whether to accept, adjust, defer, or reject, applies accepted
  modifications via the coding skill in traceable commits, and crafts courteous,
  concise replies referencing the fix commit or rejection rationale.
disable-model-invocation: true
argument-hint: "[PR number/URL — by default, current branch's PR]"
---

# GitHub Review React

The counterpart to [`github-code-review`](../github-code-review/SKILL.md): here the PR belongs **to the user**, and a peer provided the review. The deliverable is **every pending review comment assigned a clear disposition**, accepted changes implemented, and a polished reply prepared for each thread.

> A review comment is neither an order nor an attack. It is evaluated purely on **merit**: does the issue genuinely exist? Does the suggested change resolve it? Does it belong in this PR? The reviewer may have context the agent lacks; the agent may have inspected implementation details more closely. **The decision belongs to the user.**

---

## 1. Collect Review Comments

```bash
gh pr view <pr> --json number,title,body,url,author,headRefName,baseRefName,reviews,comments
```

Fetch line comments and thread status (resolved, outdated) via GraphQL:

```bash
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

Record for each item **its origin and reply target**. By default, replies go **directly to the original comment** (exceptions detailed in §6):

| Origin | Preserved Context | How to Reply |
| :--- | :--- | :--- |
| **Line thread** (`reviewThreads`) | thread `id` and `databaseId` of the **first** comment | Inline reply within the thread. |
| **Review body** (`reviews[].body`) | reviewer login and review `url` | *Quote reply* in main PR conversation. |
| **Conversation comment** (`comments`) | author login and comment `url` | *Quote reply* in main PR conversation. |

> GitHub does not natively thread responses inside general conversation comments or review bodies. The equivalent pattern is GitHub's *quote reply*: open by quoting the key sentence, mentioning the reviewer, and linking the original comment (see §6).

- Evaluate **unresolved threads** and general review comments (review bodies and conversation comments).
- Ignore comments authored by the user themselves, except as conversation context.
- **Outdated threads** (`isOutdated`) are included with a note: code may have shifted, so verify whether the feedback remains relevant.

Prepare working tree: confirm working tree is clean and local branch is up to date (`gh pr checkout <pr>`). If dirty, notify the user and stop.

Locate the specification (linked issue, PR description) and project rules (`AGENTS.md`/`CLAUDE.md`, `docs/rules/`, `CONTRIBUTING.md`): these provide the criteria to judge whether a suggestion belongs.

---

## 2. Understand and Evaluate Each Comment

For each comment, read the current code at the indicated location (not just `diffHunk`) and surrounding context. Answer:

1. **What is requested?** Summarize in one sentence. Categorize type: 🐛 bug · 🏗️ design · 🧪 test · 🧹 readability · 🎨 style/nit · ❓ question · 👍 praise.
2. **Is it valid?** Does the reported problem truly exist? Reproduce the scenario, trace data flow, or draft a test that demonstrates it. Never accept or reject based purely on authority.
3. **Is it applicable?** Does it fit within this PR's scope? Does it conflict with project rules, the specification, or another comment? What is the implementation risk and cost?
4. **Is the suggested solution optimal?** Frequently the concern is valid while the proposed implementation is sub-optimal; an alternative clean solution may exist.

Use references from [`coding`](../coding/SKILL.md) and [`software-designing`](../software-designing/SKILL.md). Documented repository rules always take precedence over general preferences.

Disposition recommendation per comment:

| Disposition | When to Apply |
| :---: | :--- |
| ✅ **Accept** | Valid, applicable, and suggested solution is effective. |
| 🔀 **Accept with Adjustment** | Concern is valid, but an alternative approach resolves it better. State what and why. |
| 📌 **Defer** | Valid, but outside current PR scope. Becomes a follow-up tracking issue. |
| ❌ **Reject** | Not valid (issue does not exist or is already handled) or cost outweighs benefit. Concrete rationale mandatory. |
| 💬 **Reply Only** | Question, clarification, or praise: requires no code changes. |

---

## 3. Present and Discuss

One structured card per comment, ordered by thread appearance in diff:

```markdown
### #1 · 🐛 `src/billing/invoice.ts:42` — @reviewer

> <concise quote from original comment>

**Requested:** <one line>
**Current Code:**
<minimal snippet>

**Assessment:** <validity and applicability in 1–3 sentences with concrete scenario>
**Recommendation:** ✅ Accept — <what to change, in one line>
```

When an item is structural (dependency, boundary, flow), illustrate before/after using [`visualize-it`](../visualize-it/SKILL.md).

Conclude with summary table:

```markdown
| # | Location | Type | Reviewer | Recommendation |
| :-: | :--- | :-: | :--- | :-: |
| 1 | `src/billing/invoice.ts:42` | 🐛 | @reviewer | ✅ |
| 2 | `src/billing/tax.ts:10` | 🎨 | @reviewer | ❌ |

✅ N · 🔀 N · 📌 N · ❌ N · 💬 N
```

Discuss with user and resolve questions. The user can adjust any disposition. **Zero code changes are applied until the user finalizes the list.**

---

## 4. Plan Changes

Once dispositions are approved, propose an execution plan:

- **One commit per comment** (or per group addressing the exact same point), allowing each reply to reference a precise commit SHA.
- Order: 🐛 bugs first, then 🏗️/🧪 architecture and tests, finally 🧹/🎨 readability and polish. Dependent changes follow dependency order.
- For each 📌 deferred item, draft a concise follow-up issue (title and 2 lines), created only upon user confirmation.

Confirm the plan with the user.

---

## 5. Implement Changes

For each planned item:

1. Implement via [`coding`](../coding/SKILL.md): test-first when addressing behaviors (🐛, 🧪), refactor safely when addressing structure or readability.
2. Run [`agent-self-review`](../agent-self-review/SKILL.md) over modifications and iterate until clean.
3. Commit via [`commit`](../commit/SKILL.md) and **record the commit SHA** alongside the comment number.

If during implementation a change proves significantly more complex or risky than anticipated, pause and return to the user: disposition can transition to 📌 or 🔀.

**Push only with confirmation**: replies reference commit SHAs, which must exist on remote prior to publishing replies.

---

## 6. Author Replies

One reply per thread, matching the language of the review (or reviewer's language). Draft and pass through [`humanize-writing`](../humanize-writing/SKILL.md): these are read by teammates.

| Disposition | Response Template |
| :---: | :--- |
| ✅ | `Addressed in <sha>: <what changed, in one sentence>.` |
| 🔀 | `Good catch. Took a slightly different approach in <sha>: <what was done>, because <rationale>. Resolves <the concern> cleanly.` |
| 📌 | `Makes sense, but outside the scope of this PR. Opened <issue link> to track separately.` |
| ❌ | `Keeping this as-is: <concrete rationale in 1–2 sentences>. Open to exploring if you have a specific failure scenario in mind.` |
| 💬 | Direct answer to the question in a few clear sentences. |

Guidelines:

- **Direct and concise**: 1 to 3 sentences. No boilerplate thank-yous on every reply; no apologies for code.
- **Courteous without conceding merit**: a ❌ rejection states objective rationale (scenario cannot happen because X; repository guideline Y specifies otherwise; cost is Z) and keeps dialogue open. Never sounds defensive.
- **Short SHAs** (7 characters): GitHub auto-links them.
- **[No local references](../ai-assisted-software-development/references/no-local-references.md)**, **no signatures**, and zero AI co-authorship tags.
- Technical terms, identifiers, and snippets remain in their original form.
- **Replying to conversation comments or review bodies** (no inline thread): use *quote reply* format, quoting the key sentence, mentioning author, and linking original comment:

  ```markdown
  > <short quote of original comment>

  @<reviewer> <reply following template> ([comment](<url of original comment>))
  ```

  If a single general comment raises multiple points, address all in one unified quote reply with distinct blockquotes.
- **Standalone comment strictly as exception**: replying directly is standard. A new standalone conversation comment is only appropriate when communicating information not tied to a single comment (e.g. summary of post-review changes, cross-cutting notice).

Present all replies together for review, grouped by thread, displaying location, origin, disposition, and delivery channel.

---

## 7. Publish

Never publish automatically. Upon explicit user request, show the exact payload and, after confirmation:

```bash
# Line thread: reply INSIDE thread (threadId = id from §1)
gh api graphql -f threadId='<thread_id>' -f body='<reply>' -f query='
mutation($threadId:ID!,$body:String!){
  addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$threadId, body:$body}){
    comment{ url }
  }
}'
# REST alternative (comment_id = databaseId of FIRST comment in thread, never a reply)
gh api repos/<owner>/<repo>/pulls/<pr>/comments/<comment_id>/replies -f body='<reply>'

# Conversation comment or review body: quote reply
gh pr comment <pr> --body-file <file with quote reply>
```

- **Reply where the comment lives**: line threads get replies in-thread; conversation comments get quote replies.
- **Post-publish verification**: verify the reply attached correctly to the thread or conversation.
- **Do not resolve threads unilaterally**: in many teams, the reviewer resolves threads. Ask the user.
- Offer to re-request review (`gh pr edit <pr> --add-reviewer <login>`) when accepted changes are pushed.
- Follow-up issues (📌) are created with confirmation prior to publishing replies referencing them.

---

## 8. Success Validation

- [ ] Unresolved threads and review comments collected; outdated ones verified against current code.
- [ ] Every comment categorized with validity, applicability, and user-approved disposition.
- [ ] Every ❌ rejection has concrete rationale, and every 🔀 adjustment explains why the alternative resolves the concern.
- [ ] Accepted modifications implemented via `coding`, passed `agent-self-review`, and committed with recorded SHA.
- [ ] Every thread has a concise, courteous, humanized reply free of local paths and signatures.
- [ ] Replies delivered to original locations (in-thread for line comments; quote reply for review bodies/comments).
- [ ] Zero items published to GitHub (push, replies, issues, thread resolutions) without explicit request and confirmation.
