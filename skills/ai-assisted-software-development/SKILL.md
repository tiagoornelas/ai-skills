---
name: ai-assisted-software-development
description: >-
  Core principles of governance and division of responsibilities in AI-assisted development. Defines the boundary between the Human Layer (governance, architecture, and contracts) and the Agent Layer (internal implementation, automation, and self-review).
---

# AI-Assisted Software Development

Guidelines and principles for the division of labor between humans and AI agents.

---

## 1. The Throughput and Focus Problem

AI agents generate code faster than any human developer can read line by line. Attempting to inspect all generated code turns the human into an inefficient bottleneck.

The sustainable solution is to **strictly divide labor into two distinct layers**:
- The **human** focuses exclusively on what is expensive to get wrong and cheap to review (architecture, contracts, and behaviors).
- The **agent** assumes full responsibility for code quality below contracts, self-validating through automated testing and **self-review**.

---

## 2. The Human Layer

The sphere of human governance and decision-making. **Only what belongs to this layer should be reported to the developer.**

### Human Responsibilities:
- **Systems and Modules**: Which components exist, their responsibilities, and their boundaries.
- **Dependency Direction**: Ensuring dependencies point toward business rules (policy never depends on infrastructure details or frameworks). See [dependency-direction.md](../software-designing/references/dependency-direction.md).
- **Contracts and Public Interfaces**: What each module promises to its consumers (signatures, guarantees, and failure modes).
- **Behaviors (Definition of Done)**: Validation of acceptance criteria observable by the user or API consumer.
- **Trade-offs and Manual Verifications**: Business judgment and execution of checks that cannot be automated.

---

## 3. The Agent Layer

Everything that resides below boundaries and contracts. **The human should not be burdened with routine inspection of this level.**

### Agent Responsibilities:
- **Internal Implementation**: Control flow, loops, private helper functions, and algorithms.
- **Internal Data Structures**: Choice of internal types, collections, and caching mechanisms.
- **Mechanical Hygiene**: Formatting, linter compliance, static typing, and elimination of accidental complexity.
- **Test Coverage (BDD/TDD)**: Writing tests that deterministically prove every DoD behavior.
- **Recursive Self-Correction**: Performing its own **`agent-self-review`**, correcting flaws until all criteria are clean before submitting to the human.

---

## 4. The Boundary Test

Whenever in doubt about which layer a decision belongs to, apply this test:

> **"Would changing this require renegotiating a contract with external callers, or could it be rewritten tomorrow without anyone outside the module noticing?"**
> - If it requires renegotiating a contract or changing a business rule → **Human Layer**.
> - If it can be changed internally with zero external impact → **Agent Layer**.

---

## 5. Derived Operational Workflows

This theory guides two complementary execution workflows:

1. **[`agent-self-review`](../agent-self-review/SKILL.md)**: Executed autonomously by the agent. The agent inspects its own implementation (linter/types, DoD coverage, and tests), recursively fixing issues until approved.
2. **[`human-review`](../human-review/SKILL.md)**: Invoked by the human developer on demand. The agent synthesizes the delivery strictly at the human governance level (dependency map, modified interfaces, and DoD validation table).

---

## 6. Success Validation

- [ ] The boundary between the Human Layer and Agent Layer was respected.
- [ ] Decisions regarding modules, contracts, dependency direction, or DoD behaviors were brought to the human.
- [ ] Internal details below contracts were resolved autonomously by the agent with tests and self-review.
- [ ] No local or unversioned paths were exposed in shared artifacts.
