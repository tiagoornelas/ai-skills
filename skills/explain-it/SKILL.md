---
name: explain-it
description: >-
  Explains code, files, flows, or technical concepts as if to a junior
  colleague who just joined the project and has no context on the business or
  on the applications themselves: starts from the problem the business solves,
  defines every domain term and project-specific name, and only then descends
  into the code. Leverages visualize-it for graphical diagrams.
disable-model-invocation: true
argument-hint: "[what to explain — by default the last discussed topic]"
---

# Explain It

Educational skill for explaining components, architectures, workflows, and technical decisions to someone who has just arrived.

---

## 1. Audience

The reader is a **junior developer on their first days in the project**:

- **Knows**: general programming, the language basics, Git, and what an API or a database is.
- **Does not know**: the business, its users and vocabulary, which applications exist, how they talk to each other, or why the code is shaped the way it is.

Every explanation is written for that reader. If a sentence only makes sense to someone who already knows the project, it is not done yet.

---

## 2. Operational Principles

- **Business before code**: open with the real-world problem: who uses this, what they are trying to achieve, and what goes wrong without it. Code comes after the reader knows why it exists.
- **Outside in**: business → applications → module → file → function. Never start at a line of code.
- **Define on first use**: every domain term, acronym, internal name (service, queue, table, feature flag), and project convention gets a plain-language definition the first time it appears. Never assume a name explains itself.
- **Concrete example**: walk through one realistic case (a specific user doing a specific thing) instead of describing the flow only in abstract terms.
- **Say why, not only what**: when the code looks odd, explain the reason (business rule, legacy constraint, past incident). If the reason is unknown, say so instead of inventing one.
- **No condescension**: do not explain general programming concepts the reader already knows; spend the words on project and business context.
- **Grounded**: base claims on the code, docs, and history actually read. Mark inferences as inferences.
- **Visuals**: invoke the [`visualize-it`](../visualize-it/SKILL.md) skill whenever explaining structural relationships, call sequences, or state machines.
- Respond in the same language the user is communicating in during the session.

---

## 3. Explanation Structure

1. **Target of Explanation**: if no argument is provided, explain the last component, file, or flow discussed in the conversation.
2. **Business Context**: 2 to 4 sentences on the problem this part of the system solves, for whom, and where it sits in the product.
3. **What It Is**: 1 to 2 sentences on the component's role among the applications, in plain words.
4. **Structural View / Flow (Visual)**: diagram via `visualize-it`, in the format its destination rule dictates (terminal-native in conversation), showing how it interacts with surrounding applications and modules, followed by one concrete example traced through it.
5. **Glossary**: short table of the domain terms and internal names used, each with a one-line definition.
6. **Key Nuances & Pitfalls**: edge cases, critical business rules, failure modes, and the traps a newcomer is most likely to fall into.
7. **Where to Go Next**: 2 to 4 files, docs, or flows worth reading next, each with why it matters.
8. **Takeaway Summary**: concise bullet-point conclusion.

---

## 4. Success Validation

- [ ] Target identified, and the explanation opens with the business problem before any code.
- [ ] Every domain term, acronym, and internal name is defined on first use and listed in the glossary.
- [ ] A concrete example is traced through the flow.
- [ ] Includes visual representation via [`visualize-it`](../visualize-it/SKILL.md) for structural relationships, sequences, or state models.
- [ ] Nuances, critical rules, and newcomer pitfalls highlighted; unknown reasons are stated as unknown, not invented.
- [ ] No explanation of general programming basics the reader already knows.
- [ ] Ends with next reading suggestions and a concise bullet-point takeaway.
