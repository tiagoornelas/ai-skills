---
name: software-designing
description: >-
  Acts as the lead software architect and designer: analyzes problems, designs
  solutions (modules, boundaries, layers, interfaces, contracts, and failure
  modes), and takes key architectural decisions for the human to ratify via
  the Human Layer, settling the hard ones with an arena of competing
  sketches, and submitting every design holding a Human Layer decision to an
  adversarial review by a fresh subagent whose objections outweigh the
  drafter's. Triggered by humans or peer agents whenever facing design or
  architecture decisions at any scale—a new system, module, API, refactoring,
  modifications to existing code, or critical review of a proposed design.
---

# Software Designing

---

## 1. Core Principle

> **The primary goal of design is to minimize system complexity**, that is, anything that makes the system hard to understand and modify.

Every judgment within this skill reduces to one fundamental question: **which alternative makes the system, as a whole, simpler to understand and change?** The references in [`references/`](references/) serve as analytical lenses to answer this question with rigor.

The agent takes the **lead role**: it does not passively wait for a pre-made design to validate. It investigates, contrasts alternatives, and decides. **The human keeps the final word on the Human Layer** (see [`ai-assisted-software-development`](../ai-assisted-software-development/SKILL.md#decided-by-the-agent-ratified-at-delivery)): inside a delivery, the agent decides by the human's principles and presents each decision for ratification.

---

## 2. Activation Modes

| Triggered by | Behavior |
| :--- | :--- |
| **Human, in a design session** | Drives an interactive session the human asked for: investigates, presents alternatives and recommendations, and lets the human decide each Human Layer item in the conversation. |
| **Inside a delivery** (the writer or a peer agent) | Produces a **Design Brief** (Section 5). Decides every item, Human Layer included; anything touching contracts, boundaries, dependency direction, or behavior is a **decision to ratify**, presented at delivery. |

In both modes, the received context must be preserved verbatim (*ipsis litteris*) during delegation or reporting.

---

## 3. Workflow

### Step 1: Frame the Problem
- What real problem is being solved, for whom, and under what constraints?
- Who consumes the result (humans, peer modules, external services)?
- If code exists: **read the current design before proposing anything** (modules, contracts, dependencies, hidden design choices).
- Information gaps only the human could close (business rules, priorities, domain constraints): in a design session, ask; inside a delivery, take the most defensible reading and record it as a decision to ratify, marked low confidence. Never present an assumption as a fact.

### Step 2: Diagnose Complexity
- Pinpoint where complexity resides (or would emerge) using the vocabulary of [nature-of-complexity.md](references/nature-of-complexity.md): change amplification, cognitive load, unknown unknowns; dependencies and obscurity.
- In existing code, review the red flags table (Section 4).

### Step 3: Compare Alternatives Proportionally
- For a design being finalized, weigh at least two materially different alternatives in your own analysis; the arena below is the subagent version, reserved for Human Layer decisions without a project pattern. A focal diagnosis can recommend a plausible direction without producing multiple complete designs.
- **Arena** for a Human Layer decision (system decomposition, module interface, API contract, data model, core mechanism) the project has no established way to settle, or when asked; the theory is in [design-it-twice.md](references/design-it-twice.md). A choice the project already settles follows [its pattern](#nothing-built-on-the-side); an internal choice needs no arena; a question a run can answer (performance, layout, behavior) goes to a disposable [`prototype`](../prototype/SKILL.md), and a new component the answer implies is still a decision to ratify.
  1. Frame once: the shared grounding (the current design, read in Step 1), the Step 4 lenses as the rubric, and every assumption recorded as a decision instead of asked.
  2. Pick two **radically different premises** (unit of abstraction, where knowledge lives, sync vs. events, mutable state vs. event log, one deep module vs. separate services); drop any that only renames the same decomposition.
  3. Give each premise to its own subagent in the calling harness, launched together with the same verbatim framing ([subagent delegation](../ai-assisted-software-development/references/subagent-delegation.md)), because a context that drafted one alternative anchors on it. Each returns a **sketch**: types, signatures, and module structure with empty bodies, never a full implementation. Other models or harnesses join only when the human asks, through [`brainstorm`](../brainstorm/SKILL.md).
  4. Compare both on the same criteria: ease of use for callers first, then simplicity, generality, efficiency of the implementation, failure modes, and relative cost. Pick one, grafting a strength of the other only when it fits the chosen shape (the result passes the Step 4 lenses again); when both are weak, redesign from their weaknesses once, then present the problem as ill-defined among the decisions at delivery.
  5. Implement only the chosen sketch, after its adversarial review (Step 5), and record the decision and its reason for ratification (Step 6).
- **When a brief assigns one design premise**, develop the best design within it and generate no alternatives.
- Reuse decisions already ratified in the session.
- For each alternative, draft **interfaces first** (what each module promises, in a few concise sentences) before internal structure.

### Step 4: Evaluate Through the Design Lenses
Apply the relevant lenses below (Section 4). Keep a focused assessment proportional; a complete design evaluates the applicable lenses rather than loading every reference automatically:
- **Two Fundamental Questions**: how will this software change tomorrow, and how will it break at runtime? → [changeability-and-fragility.md](references/changeability-and-fragility.md)
- **Maintenance commitment**: what recurring obligations does the solution impose across the system, and which are avoidable? → [maintenance-commitment.md](references/maintenance-commitment.md)
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
- **Nothing built on the side**: does each new thing follow the project's established way of doing that kind of thing? → [below](#nothing-built-on-the-side)
- **Patterns**: whenever the design involves object structure, object creation, or behavior between objects, load [`design-patterns`](../design-patterns/SKILL.md) and apply a pattern only when it passes its Parsimony Gate.

### Nothing Built on the Side

Before introducing a folder, module, client, configuration variable, or cross-cutting mechanism (authentication, timeouts, retries, logging, error handling, data access), find how the project already does that kind of thing and follow it. A parallel structure, a duplicated mechanism, or a departure from an established convention is a Human Layer decision: take it only when the project's way cannot serve, and show it as a `!` line with its reason, to ratify. Typical cases built on the side: an HTTP client with its own timeout and retry beside the project's shared transport; a dedicated configuration variable where the project has a convention for that kind of setting; a new folder for something whose siblings live elsewhere. The [change card](../ai-assisted-software-development/references/change-card.md) shows the result for each new thing, and line (d) of the [evidence dossier](../provide-evidence/references/evidence-dossier.md) proves it.

### Step 5: Adversarial Review

A design holding any Human Layer decision passes one adversarial review before it is built or, in a design session, before you present your recommendation. A design with only Agent Layer choices skips it, and so does an arena sketch or an adversarial review you were briefed to produce: the agent that called you runs it. This review is separate from the delivery's independent review and does not count toward its rounds. The context that drafted a design anchors on it and reasons from the code it happened to read, so the reviewer's objections outweigh your own judgment.

1. Launch one fresh subagent in the calling harness, on the harness's default model, briefed with [adversarial-review.md](references/adversarial-review.md).
2. Adopt each 🔴 and 🟡 objection: revise the design and pass the Step 4 lenses again. When you disagree with one, it still wins: build the reviewer's position (in a design session, recommend it) and present the disagreement as a decision to ratify, with both positions and their reasons. 🟢 objections are yours to weigh.
3. When the design changed, one more fresh subagent reviews the revised version with the same brief; adopt or build its 🔴 and 🟡 objections as in item 2, presenting each disagreement; the result is not reviewed again.

### Step 6: Decide and Present via the Human Layer
- Justify the design that survived Step 5 using concepts from the reference lenses (e.g., "Alternative B eliminates format leakage between reader and writer").
- Present to the human **only** what belongs to the Human Layer: modules and responsibilities, dependency direction, contracts and failure modes, behaviors, and trade-offs.
- **Show** what the design adds and where as a [change card](../ai-assisted-software-development/references/change-card.md) plan (a dependency pointing away from business rules is a `!` line), the main flow as a [`visualize-it`](../visualize-it/SKILL.md) swimlane, and each new or altered contract in system terms: who calls it, what crosses, what it promises and hides, and how it fails. No method names or signatures.
- List the **decisions taken** explicitly, ordered by cost to reverse after merge, each [presented for ratification](../ai-assisted-software-development/references/human-facing-communication.md#presenting-decisions-taken) with its reason and evidence; inside a delivery, the alternatives that lost are not shown, except a disagreement from the adversarial review, shown with both positions.
- **Cost is relative, never schedule-based**: compare options in terms of complexity, risk, and change footprint (e.g., "Option B modifies three modules; Option A modifies only one"). Do not estimate days or craft phased release timelines—project scheduling is outside the scope of software design.

### Step 7: Finalize and Record
- Summarize decisions and consequences in the conversation; write a persistent decision record when requested or required by the project.
- Continue implementation via [`coding`](../coding/SKILL.md); a separate handoff, session, or command is optional.

---

## 4. References (Loaded On-Demand)

| Reference | Load when… |
| :--- | :--- |
| [nature-of-complexity.md](references/nature-of-complexity.md) | Diagnosing or justifying why one design is superior. **Foundation for all other references.** |
| [changeability-and-fragility.md](references/changeability-and-fragility.md) | Grounding architectural design and code review in the two foundational questions: future evolution cost vs. runtime failure paths. |
| [maintenance-commitment.md](references/maintenance-commitment.md) | Assessing ongoing obligations to sustain, operate, or evolve the system, including costs shifted to consumers. |
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
| [design-it-twice.md](references/design-it-twice.md) | Running the arena, or judging whether the alternatives compared are radically different. |
| [adversarial-review.md](references/adversarial-review.md) | Briefing the adversarial reviewer (Step 5). |
| [`design-patterns`](../design-patterns/SKILL.md) | The design involves object structure, creation, or behavior (Step 4). |

### Red Flags → Reference Mapping

| Red flag | Reference |
| :--- | :--- |
| Shallow module (interface ≈ implementation), "classitis" | [deep-modules.md](references/deep-modules.md) |
| Information leakage, temporal decomposition, exposed internal representation | [information-hiding.md](references/information-hiding.md) |
| Mixing special with general, single-use methods | [general-purpose-modules.md](references/general-purpose-modules.md) |
| Pass-through method, pass-through variable, shallow decorators | [different-layer-different-abstraction.md](references/different-layer-different-abstraction.md) |
| Exposed configuration without need, "caller must…" | [pull-complexity-downwards.md](references/pull-complexity-downwards.md) |
| Duplicated design decisions, modules always modified together | [together-or-apart.md](references/together-or-apart.md) |
| Shotgun surgery across modules for a single business change | [changeability-and-fragility.md](references/changeability-and-fragility.md), [together-or-apart.md](references/together-or-apart.md) |
| Happy-path myopia, unhandled runtime fragility, unexamined implicit assumptions | [changeability-and-fragility.md](references/changeability-and-fragility.md), [define-errors-out-of-existence.md](references/define-errors-out-of-existence.md) |
| Exception overload, repetitive handling logic | [define-errors-out-of-existence.md](references/define-errors-out-of-existence.md) |
| Tactical patch, special case to accommodate change | [strategic-programming.md](references/strategic-programming.md), [maintenance-commitment.md](references/maintenance-commitment.md) |
| Non-obvious code, vague name, generic container | [obvious-code.md](references/obvious-code.md) |
| Business rule aware of database, framework, or vendor; core untestable without infra | [dependency-direction.md](references/dependency-direction.md) |
| Premature abstraction, patternitis, overengineering | [`design-patterns`](../design-patterns/SKILL.md) |

---

## 5. Output Format: Design Brief

Use this structure for a substantial design brief; omit irrelevant sections in a focused assessment. For explicit discovery/refactoring requests, use [improve-architecture](../improve-architecture/SKILL.md). For an independent scope/value discussion, use [scope-review](../scope-review/SKILL.md). These are entry points, not required stages of every design. Its headings are written in the reader's language: the user's session language, or the language of the calling agent's brief.

```markdown
## Problem
<1–3 sentences: what is being solved, for whom, constraints>

## Design
<chosen design + justification using reference concepts>

## Plan
<change card plan: what the design adds and where; a dependency pointing away from business rules is a `!` line>

## How It Works
<swimlane of the main flow via visualize-it>

## Contracts
<per new or altered contract, in system terms: who calls it, what crosses, what it promises and hides, how it fails>

## Decisions to Ratify (Human Layer)
| # | Decision | Why | Evidence | Cost to Reverse After Merge |

## Decided by Agent (Agent Layer)
<internal implementation choices already resolved, one line each — for traceability>
```

---

## 6. Success Validation

A design is complete only when:

- [ ] Alternatives match the decision depth: a Human Layer decision with no project pattern went through the arena (two radically different sketches by subagents in the calling harness, compared on the same criteria), only the chosen sketch was implemented, and a project pattern or an empirical question did not trigger it.
- [ ] Both **fundamental questions** were evaluated: plausible future change vectors are localized, and runtime failure paths and implicit assumptions are surfaced and contained ([changeability-and-fragility.md](references/changeability-and-fragility.md)).
- [ ] Each module has an **interface described in a few sentences**, is **deep** (interface substantially simpler than what it encapsulates), and is the **single owner** of each design decision it holds (no leakage).
- [ ] **Failure modes** for each contract passed through elimination techniques and the remaining ones are explicit; **dependency direction** points toward business rules, any exception a `!` line on the plan ([dependency-direction.md](references/dependency-direction.md)).
- [ ] Every design holding a **Human Layer decision** passed the adversarial review, each 🔴 and 🟡 objection adopted, or, when you disagreed, built (recommended in a design session) and shown with both positions; each decision was decided by the human (design session) or recorded as a decision to ratify, ordered by cost to reverse (inside a delivery).
- [ ] No red flag from Section 4 was left unaddressed or unjustified, and a reader who did not participate in the conversation can understand the design purely from the plan, the flow, and the contracts.
