---
name: explain-it
description: >-
  Explains code, files, flows, or technical concepts as if to a junior
  colleague who just joined the project and has no context on the business or
  on the applications themselves: starts from the problem the business solves,
  defines every domain term and project-specific name, and only then descends
  into the code. Leverages visualize-it to draw flows and states. Used on
  demand when the user asks for an explanation, and by human-review when the
  user points at a part of a change.
disable-model-invocation: true
argument-hint: "[what to explain — by default the last discussed topic]"
---

# Explain It

---

## 1. Audience

The reader is a **junior developer on their first days in the project**, reading in the user's session language:

- **Knows**: general programming, the language basics, Git, and what an API or a database is.
- **Does not know**: the business, its users and vocabulary, which applications exist, how they talk to each other, or why the code is shaped the way it is.

Every explanation is written for that reader. If a sentence only makes sense to someone who already knows the project, it is not done yet.

---

## 2. Operational Principles

- **Business before code**: open with the real-world problem: who uses this, what they are trying to achieve, and what goes wrong without it. Code comes after the reader knows why it exists.
- **Shared context principles**: apply [Giving context](../ai-assisted-software-development/references/human-facing-communication.md#giving-context) (outside in, situate before naming, concrete before and after, say why or say it is unknown, no condescension, grounded). This reader also lacks the business, so domain terms are defined too, not only internal names.
- **Reasons the code does not state**: when the explanation needs why the code is shaped this way and the code does not say, investigate it with [`why`](../why/SKILL.md) instead of guessing.
- **Visuals**: invoke the [`visualize-it`](../visualize-it/SKILL.md) skill whenever explaining a flow across parts of the system or the states a user sees; this reader needs the code names, so give them beside the drawing, keyed by step.

---

## 3. Explanation Structure

1. **Target of Explanation**: if no argument is provided, explain the last component, file, or flow discussed in the conversation.
2. **Business Context**: 2 to 4 sentences on the problem this part of the system solves, for whom, and where it sits in the product.
3. **What It Is**: 1 to 2 sentences on the component's role among the applications, in plain words.
4. **Flow (Visual)**: a swimlane of the flow via `visualize-it`, in the format its destination rule dictates (terminal-native in conversation), showing how it interacts with surrounding applications and modules, followed by one concrete example traced through it.
5. **Glossary**: short table of the domain terms and internal names used, each with a one-line definition.
6. **Key Nuances & Pitfalls**: edge cases, critical business rules, failure modes, and the traps a newcomer is most likely to fall into.
7. **Where to Go Next**: 2 to 4 files, docs, or flows worth reading next, each with why it matters.
8. **Takeaway Summary**: concise bullet-point conclusion.

---

## 4. Success Validation

- [ ] Target identified, and the explanation opens with the business problem before any code.
- [ ] Every domain term, acronym, and internal name is defined on first use and listed in the glossary; general programming basics the reader already knows are not explained.
- [ ] A concrete example is traced through the flow.
- [ ] Includes a [`visualize-it`](../visualize-it/SKILL.md) drawing for flows or user-visible states.
- [ ] Nuances, critical rules, and newcomer pitfalls highlighted; unknown reasons are stated as unknown, not invented.
- [ ] Ends with next reading suggestions and a concise bullet-point takeaway.
