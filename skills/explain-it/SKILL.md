---
name: explain-it
description: >-
  Explains code, files, flows, or technical concepts in an educational, visual,
  and structured manner, as if mentoring a developer new to the project.
  Leverages visualize-it for graphical diagrams.
disable-model-invocation: true
argument-hint: "[what to explain — by default the last discussed topic]"
---

# Explain It

Educational skill for explaining components, architectures, workflows, and technical decisions.

---

## 1. Operational Principle

Explain the subject focusing on **clarity, intentionality, and structure**:
- Be educational and direct, avoiding uncontextualized technical jargon.
- Use visuals: invoke the [`visualize-it`](../visualize-it/SKILL.md) skill whenever explaining structural relationships, call sequences, or state machines.
- Respond in the same language the user is communicating in during the session.

---

## 2. Explanation Structure

1. **Target of Explanation**: If no argument is provided, explain the last component, file, or flow discussed in the conversation.
2. **What It Is and Core Purpose**: 1 to 2 sentence summary explaining the component's role in the wider system.
3. **Structural View / Flow (Visual)**: ASCII or Mermaid diagram (via `visualize-it`) displaying how it interacts with surrounding modules.
4. **Key Nuances & Pitfalls**: Edge cases, critical business rules, failure modes, or common traps.
5. **Takeaway Summary**: Concise bullet-point conclusion.

---

## 3. Success Validation

- [ ] Target identified and contextualized in 1–2 sentences.
- [ ] Includes visual representation via [`visualize-it`](../visualize-it/SKILL.md) for structural relationships, sequences, or state models.
- [ ] Nuances and critical rules highlighted without unnecessary jargon.
- [ ] Explanation concludes with a concise bullet-point takeaway.
