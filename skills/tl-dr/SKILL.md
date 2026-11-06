---
name: tl-dr
description: >-
  Tells the user in a few lines only what matters to them, in two modes.
  Task glance: one task (its issues, PRs, threads, and agent sessions) in
  about ten lines, starting with what depends on the user; it owns the task
  state format other skills reuse. Digest: from an AI answer, a linked
  thread, PR, or document, or pasted text, the bottom line up front (what to
  know, decide, or do) with the one line of context it needs, fact kept apart
  from claim, or a plain statement that nothing requires anything from the
  user. Read-only; whether a delivery is proven is provide-evidence's job,
  and reviewing a change is human-review's. Triggered when the user asks for
  a tl;dr, the gist, a digest, "what do I need from this", or how a task or
  PR stands, or faces a long text they do not want to read.
argument-hint: "[task, issue, PR, link, or text; nothing = the last long answer]"
---

# TL;DR

The user's attention is the budget. Say what they must know, decide, or do, and leave out what they can skip. The criterion is relevance to this reader, not compression: a long text may come down to one line, and a short text that changes a decision may need three.

## 1. Choose the Mode

- **Task glance** (Section 2): the input names a task, issue, PR, or branch, or asks how some work stands.
- **Digest** (Section 3): the input is a text: an AI answer (by default, the last long answer in this conversation), a link to a thread, PR, or document, or pasted text.

Both modes only read: they never comment, send, change a status, or answer for the user. A link the session cannot open is named, and the user is asked for the text. Everything is written in the user's session language, with handles kept only as lookup keys beside what they are.

## 2. Task Glance

Show the task in the [task state](references/task-state.md) format, derived from its sources at this moment. When the input matches several tasks, list them in one line each and ask which one.

## 3. Digest

1. **Find what the reader needs from the text**: from the conversation, who the user is in it (author, reviewer, decider, bystander) and what they are working on.
2. **Write the bottom line up front**: one or two sentences saying what the user must know, decide, or do, concretely and with the reason ("Approve the 90-day retention before Friday's release: it keeps storage under $5 a month"), never a description of the text ("The thread discusses retention").
3. **Add the one line of context the bottom line would skip** (Bryan Garner's caveat on BLUF): the condition, risk, or assumption that would change the user's action. Skip it only when there is none.
4. **Then, only when present**: the decision with its options, recommendation, and deadline; the action with who does it and by when.
5. **Keep fact apart from claim**: what the text shows (a link, a test result, a number with its source) is fact; what someone asserts is a claim, written with who said it and "not verified". Never add a fact the text lacks; when the user needs something the text does not say, say it is missing.
6. **When nothing concerns the user**, say so in one sentence with the reason, such as "Nothing here requires anything from you: it restates the plan you approved on Monday."

No headings, no "in summary", and no list of everything the text covers. Writing a reply to the text is [`humanize-writing`](../humanize-writing/SKILL.md)'s job.

A fictional digest of a long thread about invoice PDFs:

```text
Decide the PDF retention before Friday's release: 90 days keeps storage under $5 a month and is what the team recommends.
Context: deleting a PDF also breaks the download link already emailed to that customer.
Options: 90 days (recommended) or 180 days (about $9 a month, fewer broken links).
Claim, not verified: "nobody opens an invoice PDF after 60 days" (Ana, no data cited).
```

## References

| Reference | Load when… |
| :--- | :--- |
| [task-state.md](references/task-state.md) | Showing one task, here or in another skill's overview. |

---

## Success Validation

- [ ] The mode matched the input, and nothing was written, sent, or changed anywhere.
- [ ] A task glance followed [task-state.md](references/task-state.md), opening with what depends on the user.
- [ ] A digest opened with a concrete bottom line for this reader, with its context line when one would change the action, then only the decisions and actions present.
- [ ] Claims carried who made them and "not verified"; nothing absent from the source was presented as fact.
- [ ] When nothing concerned the user, one sentence said so with its reason.
- [ ] Everything was in the user's session language and as short as its content allows.
