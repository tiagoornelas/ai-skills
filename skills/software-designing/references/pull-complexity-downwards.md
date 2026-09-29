# Pull Complexity Downwards

> **Central thesis**: it is far more important for a module to have a **simple interface** than a **simple implementation**. Most modules have vastly more users than maintainers; it is preferable for module authors to absorb complexity once than for callers to suffer repeatedly.

---

## When to consult

- When facing the temptation to "let the caller handle it": throwing an exception, exporting a configuration knob, requiring manual setup sequences.
- When deciding which architectural layer should own tricky logic.
- When designing public APIs, SDKs, shared internal packages, or services consumed by multiple teams.

---

## 1. The Core Principle

- When building a module, if an unavoidable complexity arises, actively seek ways to **absorb it internally** instead of passing the burden upward to callers.
- Implementation complexity is paid once by the author. Interface complexity is paid by **every single caller, every single time** they invoke the module.
- The path of least resistance is often the opposite. When encountering an unhandled edge case, the easiest tactical move is:
  - throw an exception and let callers figure out how to recover;
  - expose a configuration property and force administrators to tune it;
  - write documentation stating "callers must ensure that...".
- These shortcuts make life easier for the module author today, but **multiply systemic complexity**: every caller must implement error-handling or configuration glue, typically with far less context than the module had internally.

---

## 2. Example: Text Model vs. View

- If a text model exposes a line-oriented API, every UI editing action must coordinate string splitting and joining across line breaks. Complexity is pushed upward into the UI and duplicated across actions.
- A character-oriented interface **pulls that complexity downwards**: the text engine manages line breaks and indexing internally once, making the entire UI significantly cleaner.

---

## 3. Example: Configuration Parameters

- Configuration properties are a canonical example of **pushing complexity upwards**. Rather than determining appropriate behavior dynamically, the module exports a knob and delegates the decision to the user.
- While superficially appealing ("empowering users to tune the system"), they are often an **excuse to dodge difficult engineering trade-offs**. In reality, callers or sysadmins have far **less** context to pick the optimal value than the module itself.
- Example: a network transport protocol with a static retransmission timeout knob. It is vastly superior for the protocol to **measure round-trip latencies** of successful requests dynamically and calculate an adaptive timeout. This eliminates configuration overhead for users while adapting gracefully to changing network conditions.
- Governing test before introducing a configuration parameter: **"Can users (or higher-level callers) genuinely determine a better value than we can compute automatically here?"** If not, do not expose it.
- When a configuration parameter is strictly unavoidable, provide a **sensible default**, ensuring users only need to touch it in extreme scenarios. Ideally, the system auto-tunes itself and configuration serves only as an emergency override.
- Eliminate configuration knobs wherever possible.

---

## 4. Taking It Too Far

- Pulling complexity downwards does not mean turning one module into a bloated monolith. Good judgment is required.
- Pulling complexity downwards makes sense when:
  1. the complexity is **intimately related to the module's core mission**;
  2. absorbing it yields **widespread simplifications** across many call sites;
  3. pulling it downward **simplifies the module's interface**.
- Counter-example: adding a dedicated `backspace` method to a text model because a UI widget needs it. That is not pulling complexity downward; it is **leaking UI concepts** into the domain model. It bloats the interface and serves only one client. Backspace behavior belongs in the UI, composed cleanly over the general text editing API (see [general-purpose-modules.md](general-purpose-modules.md)).
- The goal is to **minimize total system complexity**, not to blindly shuffle complexity around.

---

## Red Flags

- Throwing exceptions for conditions that the module itself has sufficient context to handle cleanly.
- Configuration parameters whose optimal value could be computed or auto-tuned internally.
- Documentation stating "the caller must always ensure..." or "remember to call X before Y".
- Identical error-handling or defensive checks replicated across every caller of a module.
- A "generic" module that forces every client to implement identical pre- and post-processing rituals.

---

## How to Apply

1. For each design dilemma (error handling, ambiguity, parameter tuning, invocation order), ask: **who possesses the most information to resolve it cleanly?** It is almost always the module, not the caller.
2. If the module can resolve it, handle it internally. State **the guarantee** in the interface, not the internal mechanics.
3. For every proposed configuration parameter, apply the governing test and favor auto-tuning with sensible defaults.
4. Verify the three boundary criteria before pulling complexity down: relationship to core mission, systemic simplifications, and cleaner interface.
5. When presenting to the human, highlight which decisions were **absorbed** by the module and which were **deliberately delegated** to callers, and why. Caller-delegated decisions form the public contract and belong to the Human Layer.

---

## Relationships

- Pulling complexity downwards is what makes modules deep: [deep-modules.md](deep-modules.md).
- Masking exceptions is a prime example of pulling complexity downward: [define-errors-out-of-existence.md](define-errors-out-of-existence.md).
- Decoupling general capabilities from specialized use cases: [general-purpose-modules.md](general-purpose-modules.md).
