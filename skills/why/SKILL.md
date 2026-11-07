---
name: why
description: >-
  Investigates why code is the way it is: the motivation, trade-offs,
  incidents, and external constraints behind a piece of code, a pattern, a
  threshold, or a design decision. Builds an anchor from git history and pull
  requests, sends one read-only investigator per evidence source the session
  reaches (source control, issue tracker, documents, team chat,
  observability, error tracking, analytics), and returns a cited answer that
  keeps what the record states apart from what is inferred and what nobody
  knows. Triggered by "why does X work this way", "why did we pick Y",
  regressions, postmortems, or before changing code whose reason is unclear;
  how the code works is explain-it's job.
---

# Why

Code shows what it does, not why it exists. The why lives in commits, pull requests, tickets, documents, and conversations: all incomplete, some contradictory. Investigate like a careful, precise investigator, and never fill a gap with a confident guess, because the user will act on it. The confidence rules are in [epistemics.md](references/epistemics.md).

## 1. Target and Question

The **target** is a piece of code, a pattern, a feature, or a named decision; the **question** is its rationale, a trade-off, a motivating edge case, an external constraint, dead code, or a history sweep. When the target is vague, take the best reading from the conversation (open files, recent edits, what was just discussed), state it in one line, and proceed.

## 2. Code Anchor

Build the seed every investigator receives: file paths and line ranges, key symbols, the commits that touched the target, the pull request numbers in their subjects, and the ticket keys they mention.

```bash
git blame -L <start>,<end> <file>
git log --follow --oneline -20 -- <file>
git log -S '<exact string from the code>' -- <file>
gh pr view <number> --json title,body,author,mergedAt,closingIssuesReferences,comments,reviews
```

## 3. Investigate in Parallel

- **Map the sources the session reaches** to seven evidence categories: source control (always available through git and `gh`), issue tracker, documents, team chat, observability, error tracking, and analytics. Classify each connected tool by its name and description.
- **Send one investigator per available category**, all in one turn, each owning exactly one category (a connector that covers two categories, such as a tracker with a wiki, gets one investigator per category), as read-only subagents per [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md), briefed with [investigator-brief.md](references/investigator-brief.md), the anchor, and the user's question.
- **Skip a category only with a written reason** that appears in the answer: no tool reaches it ("team chat not searchable: no connected tool"), or it is provably irrelevant ("error tracking skipped: a build-time script with no runtime path").
- **Answer inline** only when the anchor's pull request already states the complete answer, and say so.

## 4. Synthesize and Present

Combine the findings yourself, following [epistemics.md](references/epistemics.md), and present in the user's language, situating every term per [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md). The headings are an example; the content is mandatory:

- **The question**, as investigated.
- **The code in question**: where it lives and what it does, in one or two sentences.
- **What the record states**: claims with a direct or converging citation, each cited; sources that contradict each other appear side by side, flagged as a conflict for the user to judge.
- **The user's hypothesis**, when the question carried one: supported, contradicted, or not settled by the evidence.
- **What we can reasonably infer**: interpretations, each with its chain of evidence.
- **Competing hypotheses**: readings that fit equally well, when any exist.
- **What we don't know**: each gap with what was searched and how.
- **Sources consulted**: one line per category, including those that returned nothing or were skipped, with the reason.

When the question precedes a change to this code, close with what to **preserve, change, avoid, and watch** in that change.

---

## Success Validation

- [ ] The anchor (files, symbols, commits, pull requests, tickets) was built before any investigator ran.
- [ ] One read-only investigator ran per available category, every skipped category has a written reason, or the answer says the anchor's pull request answered it completely.
- [ ] Every claim sits in its confidence tier with matching phrasing, and no claim treats code behavior as evidence of intent.
- [ ] Contradictions were shown with both citations, and a hypothesis embedded in the user's question was tested, not confirmed by default.
- [ ] The answer has a "what we don't know" section naming what was searched, and a sources line per category.
- [ ] A question that precedes a change closed with what to preserve, change, avoid, and watch.
