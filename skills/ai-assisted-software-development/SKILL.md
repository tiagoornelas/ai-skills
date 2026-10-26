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
- **Business Decisions and Trade-offs**: Behavior, restrictions, assumptions, value versus scope, and continuing [maintenance commitment](../software-designing/references/maintenance-commitment.md). Agents investigate and recommend; humans decide.

Agents bring this layer to the human in the human's terms (the system's concepts, not agent handles such as PR numbers or coined labels), each decision as a self-contained card with a recommendation. See [human-facing-communication.md](references/human-facing-communication.md).
- **Manual Verifications**: Execution of checks that cannot be automated.

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

This theory guides complementary workflows and independently callable entry points:

1. **[`agent-self-review`](../agent-self-review/SKILL.md)**: Executed autonomously by the agent. The agent inspects its own implementation (linter/types, DoD coverage, and tests), recursively fixing issues until approved.
2. **[`human-review`](../human-review/SKILL.md)**: On-demand critical assessment of own or third-party changes: business decisions and consequences first, then architecture, contracts, and verification. Systematic Agent Layer review is a separate requested scope for third-party work.
3. **[`scope-review`](../scope-review/SKILL.md)** and **[`improve-architecture`](../improve-architecture/SKILL.md)**: Independently callable entry points for scope/value decisions and architectural improvement. Reuse shared evidence; these are not mandatory stages.

During ordinary work, briefly surface material architectural or scope opportunities already encountered, normally at delivery and earlier only if they compromise the current solution. Broad scans, deeper investigations, artifacts, and follow-up sessions stay on demand. An observation does not expand implementation scope or create a backlog.

---

## 6. Success Validation

- [ ] The boundary between the Human Layer and Agent Layer was respected.
- [ ] Decisions regarding modules, contracts, dependency direction, or DoD behaviors were brought to the human.
- [ ] Internal details below contracts were resolved autonomously by the agent with tests and self-review.
- [ ] No local or unversioned paths were exposed in shared artifacts.
- [ ] Messages to the human passed the cold-read test of [human-facing-communication.md](references/human-facing-communication.md), and each pending decision was a self-contained card.
