# Changeability and Fragility: The Two Architectural Lenses

> **Central thesis**: all software design, architecture, and code review decisions converge on two foundational questions: **how will this software need to change tomorrow** (and what will that change cost?), and **how and along what paths will this code break** (what implicit assumptions will fail at runtime?). Neglecting the first yields rigid systems resistant to evolution; neglecting the second yields fragile systems prone to catastrophic runtime failure.

---

## When to consult

- During architectural design: when synthesizing and contrasting alternatives in [`software-designing`](../SKILL.md) and [`design-it-twice`](../../design-it-twice/SKILL.md).
- During code review: as the primary mental rubric in PR reviews (`github-code-review`), human delivery reviews (`human-review`), and automated self-review (`agent-self-review`).
- Before modifying or refactoring existing modules: to evaluate change blast radius and hidden runtime hazards.

---

## 1. The Two-Question Axiom

Software systems exist in two dimensions: **time** (how they evolve across future modifications) and **execution** (how they behave across runtime conditions). Design quality is measured entirely along these two axes.

```text
                           ┌────────────────────────────┐
                           │   Architectural Decision   │
                           │       or Code Review       │
                           └─────────────┬──────────────┘
                                         │
                 ┌───────────────────────┴───────────────────────┐
                 ▼                                               ▼
     ┌───────────────────────┐                       ┌───────────────────────┐
     │      QUESTION 1       │                       │      QUESTION 2       │
     │      Changeability    │                       │       Fragility       │
     │  "How will it change  │                       │   "How will it break  │
     │  and at what cost?"   │                       │    and along what     │
     │                       │                       │        paths?"        │
     └───────────┬───────────┘                       └───────────┬───────────┘
                 │                                               │
                 ▼                                               ▼
         Evolution Axis                                   Runtime Axis
      • Change amplification                           • Implicit assumptions
      • Coupling & leakage                             • Unhandled edge cases
      • Blast radius of edits                          • Cascading failures
```

### The danger of one without the other

- **Changeability without Fragility Analysis**: creates flexible, hyper-configurable abstractions that break under real-world loads, race conditions, edge cases, and unexpected input. The design looks elegant on paper but detonates in production.
- **Fragility Analysis without Changeability**: produces defensive, tightly coupled code with defensive checks scattered everywhere and no clean seams. The system is resilient today, but modifying any behavior requires touching dozens of files (shotgun surgery).

A great design balances both: **boundaries that isolate future change** and **contracts that make failure modes explicit and contained**.

---

## 2. Question 1: How Will This Code Need to Change? (Changeability)

Every piece of software will undergo modification. The fundamental question is: **when that change occurs, how localized, predictable, and low-risk will it be?**

### 2.1. Plausible Change Vectors vs. Speculative Over-Engineering

Designing for change does not mean anticipating every imaginable future requirement:
- **Speculative over-engineering (YAGNI violation)**: inventing layers of indirection, dynamic plugin registries, or configurable factories for requirements nobody asked for. This increases cognitive load today for zero guaranteed benefit (see [strategic-programming.md](strategic-programming.md)).
- **Strategic changeability**: identifying **inherent axes of change** in the business domain and ensuring they do not bleed across architectural boundaries.

| Domain Axis | High Change Likelihood | Low Change Likelihood | Design Action |
| :--- | :--- | :--- | :--- |
| **Business policies** | Pricing tiers, validation rules, workflow transitions | Core entity identities | Encapsulate policies behind clean interfaces; keep entities independent of ephemeral policy details. |
| **External integrations** | Third-party APIs, vendor schemas, SDK versions | Internal domain concepts | Isolate behind domain ports and gateways ([dependency-direction.md](dependency-direction.md)). |
| **Infrastructure & storage** | Cache mechanisms, DB drivers, message brokers | Business transaction invariants | Shield business rules from storage specifics. |

### 2.2. The Blast Radius Test (Change Amplification)

To evaluate a proposed change, ask:
> *"If requirement X changes, how many modules, files, and tests must be modified?"*

- If a single logical requirement change requires touching 5 different files across 3 layers, the design suffers from **change amplification** and **shotgun surgery** (see [nature-of-complexity.md](nature-of-complexity.md) and [together-or-apart.md](together-or-apart.md)).
- The goal is **one change, one place**: every design decision has a single module as its owner ([information-hiding.md](information-hiding.md)).

### 2.3. Code Review Rubric for Changeability

During code review or self-review, inspect the diff through these prompts:
1. **Leaky Representations**: does caller code depend on internal structures or formats that will force caller updates if the callee evolves?
2. **Hardcoded Assumptions**: are business constants, format assumptions, or external provider details scattered across general logic?
3. **Temporal Decomposition**: is logic split according to execution steps rather than informational cohesion, forcing changes in the sequence to touch every step?

---

## 3. Question 2: How Will This Code Break? (Fragility)

Software rarely breaks where developers intentionally planned. It breaks along the lines of **implicit, unverified assumptions** that fail silently in production.

### 3.1. Surfacing Implicit Assumptions

Every bug is an unverified assumption made by the author. To find fragility, systematically challenge:

| Category | Implicit Assumption (The Trap) | Reality (The Failure Path) |
| :--- | :--- | :--- |
| **Temporal / Ordering** | "Method `init()` is always called before `process()`." | A concurrent thread or new caller invokes `process()` directly, leading to null pointer dereference. |
| **Environment & I/O** | "Network calls respond within 200ms and never drop." | Latency spikes, requests queue indefinitely, thread pools exhaust, upstream times out. |
| **State & Concurrency** | "This operation executes atomically without interleaved state mutations." | Two concurrent requests enter the branch simultaneously, producing a race condition or double-spend. |
| **Data Invariants** | "Incoming payload always contains field `user_id` and non-empty list `items`." | Upstream sends null or empty array, triggering unhandled exceptions deep in the stack. |
| **Resource Limits** | "Payloads fit comfortably in memory." | A customer uploads a 500MB payload, triggering an Out-Of-Memory (OOM) crash. |

### 3.2. Designing for Failure Containment

Once failure paths are exposed:
1. **Define Errors Out of Existence First**: can the operation be redefined so that the error condition is a valid normal case rather than an exception? (See [define-errors-out-of-existence.md](define-errors-out-of-existence.md)).
2. **Contain the Blast Radius**: if a non-critical component fails (e.g., analytics logging or notification webhook), does it take down the core transaction? Core business transactions must survive auxiliary subsystem failures.
3. **Make Failure Modes Explicit**: do not hide failure behind generic null returns or empty catch blocks. Contracts must explicitly state what failures are possible and how callers are expected to respond.

### 3.3. Code Review Rubric for Fragility

During code review or self-review, inspect the diff through these prompts:
1. **Happy-Path Myopia**: does this PR only work under ideal conditions? Where are the timeout, retry, cancellation, and validation branches?
2. **Swallowed Failures**: are exceptions caught and silently logged without alerting callers or restoring invariants?
3. **State Corruption on Partial Failure**: if step 2 of 3 fails, is partial state cleaned up or rolled back, or does the system remain in an inconsistent state?

---

## 4. The Dual Lens Matrix

| Phase | Question 1: Changeability | Question 2: Fragility |
| :--- | :--- | :--- |
| **Architectural Design** *(Human Layer)* | • Where are the module boundaries?<br>• Do boundaries protect core business rules from volatile infrastructure?<br>• Does each decision have a single owner module? | • What are the system-wide failure modes?<br>• Can errors be defined out of existence?<br>• What is the failure containment boundary / blast radius? |
| **Implementation** *(Agent Layer)* | • Are helper functions cohesive below the contract?<br>• Are internal representations easily swappable without touching public signatures? | • Are inputs validated at the boundary?<br>• Are invariants enforced before mutations?<br>• Are resources (connections, files, locks) guaranteed to be released? |
| **Code Review** *(Human & Peer Review)* | • If business rule X changes tomorrow, how many files will need to be touched?<br>• Does caller code leak callee internals? | • What implicit assumptions exist in this code?<br>• What happens if the network drops, payload is empty, or execution order changes? |

---

## 5. Red Flags

### Red Flags for Changeability (Question 1)
- **Shotgun Surgery**: a single logical change forces synchronous updates across unrelated files.
- **Leaky Abstraction**: callers must know internal data formats or SQL schemas to consume a service.
- **Pass-through Parameters**: parameters threaded through multiple layers merely to reach a distant callee (see [different-layer-different-abstraction.md](different-layer-different-abstraction.md)).
- **Duplicated Business Knowledge**: the same calculation or validation rule repeated across multiple modules.

### Red Flags for Fragility (Question 2)
- **Happy-Path Only**: absence of tests or code paths for network failure, timeout, invalid payload, or empty results.
- **Swallowed Exceptions**: `catch (e) { /* do nothing */ }` or returning `null` when a failure occurred, masking root causes.
- **Invisible Temporal Dependencies**: methods that must be called in a strict undisclosed sequence.
- **Unbounded Operations**: unbounded in-memory collections, queries without limits, or HTTP calls without timeouts.
- **Unprotected Mutations**: state updates across multiple entities without transaction guarantees or rollback mechanisms.

---

## 6. Reviewer Audit Checklist

Before approving any architectural design or code delivery, confirm:

- [ ] **Changeability**: Identified likely axes of business change; verified that modifying them touches only the owner module.
- [ ] **Decoupled Contracts**: Callers depend solely on the contract abstraction, not on internal implementation details.
- [ ] **Implicit Assumptions Surfaced**: Systematically challenged ordering, concurrency, network reliability, and data invariant assumptions.
- [ ] **Error Semantics**: Evaluated whether errors can be defined out of existence before introducing complex recovery logic.
- [ ] **Blast Radius Contained**: Subsystem failures are isolated; core transactions do not crash due to auxiliary service outages.
- [ ] **No Swallowed Failures**: Errors either fail fast with actionable diagnostics or recover with state invariants fully preserved.
