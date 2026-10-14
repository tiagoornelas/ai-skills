# State

> **Behavioral Pattern** — Refactoring Guru Catalog
> Lets an object alter its behavior when its internal state changes. It appears as if the object changed its class.

---

## 1. Intent & Core Mechanism

Extracts state-dependent behaviors into separate classes representing individual states (e.g., `Draft`, `Moderation`, `Published` for a Document). The primary object (Context) delegates all state-specific method calls to an active State object, switching its current State reference when transitions occur.

---

## 2. When Justified

- You have an object that behaves differently depending on its current state, the number of states is enormous (>= 4), and the state-specific code changes frequently.
- You have a class polluted with massive conditionals (`if/else` or `switch`) that alter how the class's methods behave according to current field values.
- You have lots of duplicate code across similar states and transitions.

---

## 3. Parsimony Filter & Simpler Alternatives

> **Do not use the State pattern for simple 2- or 3-state flags or when a state machine lookup table suffices.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| 2 or 3 simple states (e.g., active/inactive, loading/ready) | A simple boolean flag or concise enum check. |
| Deterministic state transitions | A state transition table / dictionary: `transitions[currentState][event] -> nextState`. |
| TypeScript / Rust | Discriminated unions / sum types with pattern matching. |
| Production state machine | Lightweight state machine libraries (e.g., XState, Stateless) instead of manual class graphs. |

**The Trap**: Creating 5 state classes and an interface for a simple toggle button that only alternates between on and off.

---

## 4. Structure & Contracts

```text
┌───────────────────────────────┐          ┌───────────────────────────────┐
│            Context            │          │        State (Contract)       │
├───────────────────────────────┤          ├───────────────────────────────┤
│ - state: State                │─────────>│ + handleActionA(): void       │
├───────────────────────────────┤          │ + handleActionB(): void       │
│ + changeState(State): void    │          └───────────────▲───────────────┘
│ + actionA(): void             │                          │
│ + actionB(): void             │                  ┌───────┴───────┐
└───────────────────────────────┘                  │               │
                                            ┌──────┴───────┐ ┌─────┴───────┐
                                            │ StateDraft   │ │ StateReview │
                                            └──────────────┘ └─────────────┘
```

- **Context**: Stores a reference to one of the concrete state objects and delegates state-specific work to it.
- **State**: Declares methods for all state-specific behaviors.
- **ConcreteStates**: Provide their own implementation of state-specific methods and can trigger state transitions on Context.

---

## 5. Downsides & Accidental Complexity

- **Overkill for simple state machines**: If the state machine has few states or rarely changes, introducing the State pattern is excessive engineering.
- **Coupling between states**: States often need to know about each other to trigger transitions, creating circular class dependencies.
