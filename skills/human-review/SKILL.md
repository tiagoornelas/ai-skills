---
name: human-review
description: >-
  Assists the human developer in reviewing deliverables strictly at the Human
  Layer (architecture, dependency direction, interface contracts, and DoD
  behaviors). Invoked on demand by the user.
---

# Human Review

Assistance for high-level human review and deliberation.

---

## 1. Core Principle

The agent **does not perform the human review; it prepares it**. Approval and judgment are the exclusive prerogative of the human.

The agent's role is to make the deliverable visible at the **Human Layer**, filtering out low-level implementation noise already validated by [`agent-self-review`](../agent-self-review/SKILL.md).

> 🎨 **Mandatory Native Visualization**: This skill natively invokes [`visualize-it`](../visualize-it/SKILL.md). The human must be able to *see* boundaries, dependencies, and contracts through diagrams (ASCII or Mermaid), not merely read textual descriptions.

---

## 2. Presentation Structure for the Human

When invoked, this skill generates a structured presentation containing:

### 1. Module and Dependency Map (via `visualize-it`)
- Render the component map with [`visualize-it`](../visualize-it/SKILL.md) notation, highlighting what changed, dependency direction (confirming arrows point inward toward business rules), and any architectural deviations.

### 2. Contracts and Public Interfaces
- Public interfaces, endpoints, types, and signatures created or altered.
- What each contract guarantees and its failure modes.

### 3. Behavior Validation Table (DoD)
Present a direct table mapping each acceptance criterion. This is the **canonical legend** for DoD statuses across skills:

| Status | Meaning |
| :---: | :--- |
| ✅ | Covered by an automated test verifying behavior through the public interface. |
| 🔎 | Not code-testable; verified by alternative means, with method disclosed. |
| 👤 | Requires manual human validation. |
| 🚨 | Missing, or lacking both test coverage and declaration. |

| Status | Delivered Behavior (DoD) | Verification Evidence | Action for Human |
| :---: | :--- | :--- | :--- |
| ✅ | Interest calculation rules | Unit test in `tests/interest.test.ts` | No action required |
| 🔎 | Welcome email dispatched via real vendor | Not code-testable; verified in staging with dispatch logs | Optional to inspect |
| 👤 | Responsive visual layout on mobile | Not code-testable | Manually verify in browser viewport (375px) |
| 🚨 | Acceptance Criterion X unverified | No test and no declaration | **Critical blocker for human evaluation** |

### 4. Items Requiring Human Decision
Highlight at the conclusion strictly what demands human judgment:
- Behaviors flagged for manual verification (👤);
- Architectural trade-offs or new public contracts to approve;
- Unresolved business domain questions.

---

## 3. Success Validation

- [ ] Presentation contains strictly Human Layer concerns (architecture, contracts, behaviors).
- [ ] Module map and dependency direction diagrammed via [`visualize-it`](../visualize-it/SKILL.md).
- [ ] Every DoD behavior mapped in the table using canonical status indicators (✅, 🔎, 👤, 🚨) with clear evidence.
- [ ] Strictly items demanding genuine human deliberation were highlighted for decision.
