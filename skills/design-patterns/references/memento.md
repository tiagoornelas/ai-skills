# Memento

> **Behavioral Pattern** — Refactoring Guru Catalog
> Lets you save and restore the previous state of an object without revealing the details of its implementation.

---

## 1. Intent & Core Mechanism

Enables undo/rollback functionality by capturing a snapshot of an object's internal state into an opaque **Memento** object. The snapshot is stored by an external caretaker (history manager), but only the originating object (Originator) has permission to read the memento's state to restore itself.

---

## 2. When Justified

- You need to produce snapshots of an object's state to be able to restore a previous state of the object (Undo, transaction rollback).
- Direct access to the object's fields/getters/setters would violate encapsulation and expose private implementation details to external callers.

---

## 3. Parsimony Filter & Simpler Alternatives

> **If your application uses immutable state or simple serialization, Memento is redundant.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| Immutable state architectures (Redux, functional state) | Pushing state copies onto a history array (`history.push(currentState)`). |
| Serializable domain objects | Storing JSON / byte snapshots: `JSON.stringify(state)`. |
| Single field rollbacks | Saving the previous primitive value in a local variable before performing an action. |

**The Trap**: Writing complex nested Memento classes with custom access tokens when simple immutable state snapshots accomplish the same safety.

---

## 4. Structure & Contracts

```text
┌───────────────────────────────┐
│          Originator           │
├───────────────────────────────┤
│ - state: State                │
├───────────────────────────────┤
│ + save(): Memento             │────┐ creates
│ + restore(Memento): void      │    │
└───────────────────────────────┘    │
                                     ▼
┌───────────────────────────────┐ ┌───────────────────────────────┐
│           Caretaker           │ │      Memento (Contract)       │
├───────────────────────────────┤ ├───────────────────────────────┤
│ - history: Memento[]          │ │ - state: State (private)      │
├───────────────────────────────┤ ├───────────────────────────────┤
│ + undo(): void                │ │ + getState(): State (hidden)  │
└───────────────────────────────┘ └───────────────────────────────┘
```

- **Originator**: The object whose state needs to be saved and restored. Creates mementos and uses them to restore state.
- **Memento**: Value object acting as a snapshot of the Originator's state. Immutable; prevents modification by Caretaker.
- **Caretaker**: Manages the history of mementos (stores stack, triggers save/undo) without inspecting their contents.

---

## 5. Downsides & Accidental Complexity

- **Memory consumption**: Frequent snapshots of large objects consume massive amounts of RAM unless delta/diff compression is used.
- **Lifecycle management**: Caretakers must diligently prune history stacks to avoid memory leaks.
