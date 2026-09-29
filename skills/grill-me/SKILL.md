---
name: grill-me
description: >-
  Relentlessly interviews the user to stress-test a plan, decision, design, or
  idea across any topic and at any stage, until reaching shared understanding
  with zero implicit assumptions. Structures inquiries into a decision tree and
  asks questions in rounds, always accompanied by a recommendation;
  autonomously researches facts the environment answers, leaving decisions to
  the user. Produces no permanent artifacts and belongs to no fixed flow.
  Triggered when the user asks to be grilled, questioned, or stress-tested, or
  when another skill needs to conduct an interactive interview.
argument-hint: "[plan, decision, or idea to stress-test — by default, current topic]"
---

# Grill Me

An interview designed to **rigorously test reasoning before acting**. Applies to anything: a feature, an architecture, a business decision, an article draft, or determining next steps. Requires no git repository, writes no permanent files (the only possible artifact is a disposable prototype, Section 5), and **has no fixed output schema**: what remains is a significantly sharpened idea inside the user's mind.

> **Facts** are the agent's job. **Decisions** belong to the user. An agent that answers its own decision questions breaks the skill.

---

## 1. Frame the Topic

Confirm in a single line what is being stress-tested. Without an explicit argument, use what is currently under discussion in the conversation; if ambiguous, ask.

If the topic is too broad for a single session (multiple independent streams, each with its own decision tree), state that and propose starting with one stream. Sessions spanning hundreds of questions almost invariably reflect scope overload, and inquiry quality degrades as context windows fill.

---

## 2. The Decision Tree

Model the topic as a **decision tree**: each decision branches into dependent choices.

- The **frontier** is the set of decisions whose prerequisites are already resolved: the questions that can be asked **now**, without guessing unmade choices.
- A **round** presents the entire active frontier at once. Two questions never share a round if one depends on the other: the dependent question waits for a subsequent round.
- Every user answer **reshapes the tree**: resolved choices push the frontier outward and unlock downstream questions. Recalculate the frontier after every round; the next round is computed dynamically, never pre-scripted.

The frontier is an exercise in judgment, not a mathematical graph. If an answer reveals that another question in the same round should have been phrased differently, state that and reopen the branch in the following round.

To stress-test rather than merely clarify, actively hunt for branches the user omitted: implicit assumptions, failure modes, edge cases, cost of reversal, secondary stakeholders, and what happens if the foundational premise is flawed.

---

## 3. Round Format

Every question follows this exact block structure, separated by `---`:

```markdown
❓ **Q1** · **<Question Title>**

<Strictly the necessary context to decide, as concise as possible>

- **A)** <option>
- **B)** <option>
- **C)** <option>

➡️ **A**: <single sentence explaining why this option is recommended>

---

❓ **Q2** · **<Question Title>**

<Open-ended question, when discrete choices do not apply>

➡️ <recommended answer, in a single sentence>
```

- **Options in a list**, one per line, lettered. If a question lacks discrete options, ask open-endedly: never invent arbitrary lettered choices.
- **One recommendation per question**, with a single bold letter immediately following `➡️`, followed by **one sentence justifying the choice**. Deeper rationale belongs in the question context above.
- **Letters are the user's shorthand vocabulary**: the user must be able to respond to an entire round with `Q1 A, Q2 C, Q3 no, because...`.
- If the user requests **one question at a time**, adopt that mode for the rest of the session while preserving the block format.

After presenting a round, **stop and wait** for the user's response.

---

## 4. Facts: Research, Do Not Ask

Never ask the user questions the environment can answer. Close both information gaps:

- **What the user knows and the agent does not**: business rationale, unwritten constraints, previous failed attempts, what constitutes "done". The interview uncovers this.
- **What the environment knows and the user does not**: existing code behavior, blast radius of a change, how the system actually behaves (versus how the user remembers it). Read the environment and report facts to the user.

When a frontier question depends on a factual premise:

- **In the local environment** (files, git history, CLI tooling): launch a subagent to inspect it (see [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md)).
- **Outside the environment** (third-party API behavior, library contracts, official specs): launch a subagent to research primary sources (official documentation, source code, specifications) and return with citations. Never guess.
- **Do not block the round**: an in-flight investigation is an unresolved prerequisite. Only questions dependent on that fact wait; the rest of the frontier is presented immediately.

---

## 5. Questions Conversation Cannot Resolve

Some questions can be answered through dialogue. Others cannot, and no amount of interviewing will resolve them.

"A long single-page form or a three-step wizard?", "What should this interaction look like?", and "Does this complex state machine hold up?" are questions that **cannot be resolved purely in conversation**: they require concrete interactive feedback. When one surfaces, **pause the interview**. Build a disposable artifact using the [`prototype`](../prototype/SKILL.md) skill, inspect it collaboratively with the user, then return to the interview and record the answer in a single sentence. The resolution enters the tree as a settled decision, and interviewing resumes.

Insisting on prose debates for interactive questions is where sessions bloat: the agent rephrases, the user guesses, and speculative scope expands to fill the void.

---

## 6. Guarding Against Passivity

The primary failure mode is the user passively agreeing with every recommendation, emerging with an agent-authored plan they merely rubber-stamped. It feels productive because it took a long time, but nothing was genuinely decided.

- **"I don't know" is a valid answer.** Record it as an open decision and propose a resolution path (prototyping, targeted research, consulting an external expert).
- **Weak answers demand polite pushback**: if an answer contradicts an earlier choice, ignores a concrete risk, or rubber-stamps a recommendation on a high-consequence choice without reasoning, challenge it in a sentence and re-examine that branch.
- **Chained approvals on high-impact decisions**: remind the user once that the session's value lies in challenging premises that feel off. Do not repeat this reminder every round.
- **The user controls scope**: they can drill down, skip branches, shift altitude, or conclude at any moment. Follow their lead.

---

## 7. Conclude

The session ends when **the frontier is empty** (all branches explored, zero implicit assumptions) or when the user calls for a stop.

1. Confirm that shared understanding has been reached. **Take zero action on decided items prior to this confirmation**: no code, no formal documents, no tickets.
2. If requested, provide a concise summary: decisions finalized, open questions remaining, and risks cataloged.
3. No mandatory next step exists. If appropriate, suggest in one sentence where work could flow (e.g., [`software-designing`](../software-designing/SKILL.md) for architectural design, [`report-work`](../report-work/SKILL.md) for task tracking), without assuming commitment.

When invoked by another skill, conclude by returning confirmed decisions back to the caller.

---

## 8. Success Validation

- [ ] Topic confirmed in a single sentence; scope fits within a single session (or partitioned).
- [ ] Questions delivered in rounds, each covering the active frontier with zero intra-round dependencies.
- [ ] Every question adheres to the Section 3 format, featuring exactly one recommendation.
- [ ] Zero environment-discoverable facts asked of the user; zero user decisions answered autonomously by the agent.
- [ ] Subsequent rounds unlocked questions that earlier rounds could not ask.
- [ ] Visual or behavioral questions paused the interview and leveraged `prototype` rather than prose debate.
- [ ] Zero downstream actions executed before the user confirmed shared understanding.
