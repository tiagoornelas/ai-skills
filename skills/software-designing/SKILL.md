---
name: software-designing
description: >-
  Acts as the lead software architect and designer: analyzes problems, designs
  solutions (modules, boundaries, layers, interfaces, contracts, and failure
  modes), and drives key architectural decisions with the human via the Human
  Layer. Triggered by humans or peer agents whenever facing design or
  architecture decisions at any scale—a new system, module, API, refactoring,
  modifications to existing code, or critical review of a proposed design.
---

# Software Designing

The generalist software architect of the ecosystem. Applies to any context where software design and architecture add value: from a single public function to a distributed system, from a greenfield project to surgical changes in legacy codebases.

---

## 1. Core Principle

> **The primary goal of design is to minimize system complexity**, that is, anything that makes the system hard to understand and modify.

Every judgment within this skill reduces to one fundamental question: **which alternative makes the system, as a whole, simpler to understand and change?** The references in [`references/`](references/) serve as analytical lenses to answer this question with rigor.

The agent takes the **lead role**: it does not passively wait for a pre-made design to validate. It investigates, proposes, contrasts alternatives, and recommends. **However, decisions belonging to the Human Layer strictly belong to the human** (see [`ai-assisted-software-development`](../ai-assisted-software-development/SKILL.md)): the agent prepares and articulates them, and the human decides.

---

## 2. Activation Modes

| Triggered by | Behavior |
| :--- | :--- |
| **Human** | Drives an interactive design session: investigates, presents alternatives and recommendations, and **requests decisions** on each Human Layer item before finalizing the design. |
| **Peer agent** | Produces a **Design Brief** (Section 5). Autonomously decides only what belongs to the Agent Layer; anything touching contracts, boundaries, dependency direction, or behavior is flagged as **pending human decision**, accompanied by a recommendation. The calling agent must escalate these pending items to the human before implementation. |

In both modes, the received context must be preserved verbatim (*ipsis litteris*) during delegation or reporting.

---

## 3. Workflow

### Step 1: Frame the Problem
- What real problem is being solved, for whom, and under what constraints?
- Who consumes the result (humans, peer modules, external services)?
- If code exists: **read the current design before proposing anything** (modules, contracts, dependencies, hidden design choices).
- Information gaps that only the human can clarify (business rules, priorities, domain constraints) become explicit questions. Never invent answers.

### Step 2: Diagnose Complexity
- Pinpoint where complexity resides (or would emerge) using the vocabulary of [nature-of-complexity.md](references/nature-of-complexity.md): change amplification, cognitive load, unknown unknowns; dependencies and obscurity.
- In existing code, review the red flags table (Section 4).

### Step 3: Design at Least Two Alternatives
- Never lock in the first idea. Follow [`design-it-twice`](../design-it-twice/SKILL.md) to formulate **at least two radically different alternatives** and compare them. For high-impact decisions, it executes this skill once per alternative in isolated contexts.
- **Exception**: when this skill is invoked *by* `design-it-twice` for a specific design axis, do **not** generate alternatives; develop the best possible design within the assigned axis.
- For each alternative, draft **interfaces first** (what each module promises, in a few concise sentences) before internal structure.

### Step 4: Evaluate Through the Design Lenses
Apply relevant references (Section 4). At a minimum, evaluate each alternative against:
- **Depth**: is each module's interface substantially simpler than its implementation? → [deep-modules.md](references/deep-modules.md)
- **Information Hiding**: does each design decision have a single owner? → [information-hiding.md](references/information-hiding.md)
- **Generality**: do interfaces speak the module's own concepts rather than caller concepts (except infrastructure gateways, which speak the domain's vocabulary)? → [general-purpose-modules.md](references/general-purpose-modules.md)
- **Layers**: does each layer provide a distinct abstraction? → [different-layer-different-abstraction.md](references/different-layer-different-abstraction.md)
- **Where complexity lives**: is complexity absorbed by modules or leaked to callers? → [pull-complexity-downwards.md](references/pull-complexity-downwards.md)
- **Boundaries**: does joining or separating reduce total system complexity? → [together-or-apart.md](references/together-or-apart.md)
- **Failure modes**: which errors can be defined out of existence? → [define-errors-out-of-existence.md](references/define-errors-out-of-existence.md)
- **Obviousness**: are names, consistency, and flows immediately clear? → [obvious-code.md](references/obvious-code.md)
- **Dependency Direction**: does every boundary crossing between business logic and infrastructure point toward the business logic? → [dependency-direction.md](references/dependency-direction.md)
- **Evolution** (for existing code): does the outcome look as though the new change had been planned from the start? → [strategic-programming.md](references/strategic-programming.md) (Section 5)

### Step 5: Recommend and Communicate via the Human Layer
- Select a recommendation and justify it using concepts from the reference lenses (e.g., "Alternative B eliminates format leakage between reader and writer").
- Present to the human **only** what belongs to the Human Layer: modules and responsibilities, dependency direction, contracts and failure modes, behaviors, and trade-offs.
- **Visualize** with [`visualize-it`](../visualize-it/SKILL.md): module map with explicit dependency direction and interface cards for each new or altered contract.
- List **pending decisions** explicitly, each with options, risk/cost of each option, and an agent recommendation.
- **Cost is relative, never schedule-based**: compare options in terms of complexity, risk, and change footprint (e.g., "Option B modifies three modules; Option A modifies only one"). Do not estimate days or craft phased release timelines—project scheduling is outside the scope of software design.

### Step 6: Finalize and Record
- Consolidate human decisions into a concise **decision record**: context, considered alternatives, decision, consequences.
- Handoff the design for implementation via [`coding`](../coding/SKILL.md).

---

## 4. References (Loaded On-Demand)

Load only the references needed for the specific design decision.

| Reference | Load when… |
| :--- | :--- |
| [nature-of-complexity.md](references/nature-of-complexity.md) | Diagnosing or justifying why one design is superior. **Foundation for all other references.** |
| [strategic-programming.md](references/strategic-programming.md) | Under pressure for quick shortcuts, deciding how much to invest in design, or modifying existing systems. |
| [deep-modules.md](references/deep-modules.md) | Defining or reviewing modules, classes, services, or APIs. |
| [information-hiding.md](references/information-hiding.md) | Deciding what each module knows and reveals, or encountering temporal decomposition. |
| [general-purpose-modules.md](references/general-purpose-modules.md) | Designing interfaces, or finding special cases scattered across the codebase. |
| [different-layer-different-abstraction.md](references/different-layer-different-abstraction.md) | Designing layered architectures, wrappers, decorators, or pass-through parameters. |
| [pull-complexity-downwards.md](references/pull-complexity-downwards.md) | Tempted to let callers handle complexity (exceptions, configuration, prerequisites). |
| [together-or-apart.md](references/together-or-apart.md) | Deciding boundaries: whether to split, join, extract, or merge. |
| [define-errors-out-of-existence.md](references/define-errors-out-of-existence.md) | Defining failure modes, errors, or exceptions in a contract. |
| [obvious-code.md](references/obvious-code.md) | Choosing names, contract types, event-driven flows, or reviewing design readability. |
| [dependency-direction.md](references/dependency-direction.md) | Defining dependency direction, decoupling business rules from infrastructure (persistence, UI, frameworks, providers), or deciding when to defer detail choices. |

### Red Flags → Reference Mapping

| Red flag | Reference |
| :--- | :--- |
| Shallow module (interface ≈ implementation), "classitis" | [deep-modules.md](references/deep-modules.md) |
| Information leakage, temporal decomposition, exposed internal representation | [information-hiding.md](references/information-hiding.md) |
| Mixing special with general, single-use methods | [general-purpose-modules.md](references/general-purpose-modules.md) |
| Pass-through method, pass-through variable, shallow decorators | [different-layer-different-abstraction.md](references/different-layer-different-abstraction.md) |
| Exposed configuration without need, "caller must…" | [pull-complexity-downwards.md](references/pull-complexity-downwards.md) |
| Duplicated design decisions, modules always modified together | [together-or-apart.md](references/together-or-apart.md) |
| Exception overload, repetitive handling logic | [define-errors-out-of-existence.md](references/define-errors-out-of-existence.md) |
| Tactical patch, special case to accommodate change | [strategic-programming.md](references/strategic-programming.md) |
| Non-obvious code, vague name, generic container | [obvious-code.md](references/obvious-code.md) |
| Business rule aware of database, framework, or vendor; core untestable without infra | [dependency-direction.md](references/dependency-direction.md) |

---

## 5. Output Format: Design Brief

```markdown
## Problem
<1–3 sentences: what is being solved, for whom, constraints>

## Alternatives Considered
| Alternative | Core Idea | Complexity Introduced | Complexity Eliminated |

## Recommendation
<chosen alternative + justification using reference concepts>

## Module Map
<diagram via visualize-it — explicit dependency direction>

## Contracts
<interface card per new/modified module: promises, encapsulated knowledge, failure modes>

## Pending Decisions (Human Layer)
| # | Decision | Options | Recommendation | Cost of Error |

## Decided by Agent (Agent Layer)
<internal implementation choices already resolved, one line each — for traceability>
```

---

## 6. Success Validation

A design is complete only when:

- [ ] At least **two alternatives** were evaluated via [`design-it-twice`](../design-it-twice/SKILL.md), with a recommendation grounded in complexity analysis (unless this run evaluates a single axis requested by `design-it-twice`).
- [ ] Each module has an **interface described in a few sentences** and is **deep** (interface is substantially simpler than what it encapsulates).
- [ ] Every relevant design decision has **a single owner module** (no leakage).
- [ ] **Failure modes** for each contract passed through elimination techniques, and remaining ones are explicit.
- [ ] **Dependency direction** is diagrammed and points toward business rules ([dependency-direction.md](references/dependency-direction.md)).
- [ ] No red flag from Section 4 was left unaddressed or unjustified.
- [ ] All **Human Layer decisions** were determined by the human (interactive mode) or marked as pending (agent mode).
- [ ] A reader who did not participate in the conversation can understand the design purely from the module map and contracts.
