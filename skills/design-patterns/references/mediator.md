# Mediator

> **Behavioral Pattern** — Refactoring Guru Catalog
> Lets you reduce chaotic dependencies between objects. The pattern restricts direct communications between the objects and forces them to collaborate only via a mediator object.

---

## 1. Intent & Core Mechanism

Prevents an N×N mesh of tight coupling among collaborating components (e.g., UI dialog components where changing a checkbox enables a text input, hides a button, and updates a label). Components notify the Mediator of events, and the Mediator coordinates all reacting components.

---

## 2. When Justified

- It is hard to change some classes because they are tightly coupled to a dozen of other classes.
- You can't reuse a component in a different program because it's too dependent on other components.
- You find yourself creating lots of proper subclasses just to reuse some basic behavior in different contexts.

---

## 3. Parsimony Filter & Simpler Alternatives

> **Do not use a Mediator if components only communicate with one or two neighbors.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| Simple pub/sub decoupling | An Event Bus or Event Emitter (`emitter.emit('event')`). |
| Modern UI frameworks (React, Vue, Svelte) | Declarative state management (stores, signals, or context) instead of imperative mediator objects. |
| Direct 1-to-1 dependency | Direct method calls or callbacks between the two components. |

**The Trap**: Creating a centralized Mediator that turns into a massive, unmaintainable "God Object" containing all application logic.

---

## 4. Structure & Contracts

```text
┌─────────────────────────────────┐
│       Mediator (Contract)       │
├─────────────────────────────────┤
│ + notify(sender, event): void   │
└────────────────▲────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
┌───────┴────────┐ ┌──────┴───────────────┐
│ ConcreteMed    │ │ Component (Contract) │
├────────────────┤ ├──────────────────────┤
│ - compA: CompA │ │ - mediator: Mediator │
│ - compB: CompB │ ├──────────────────────┤
├────────────────┤ │ + operation(): void  │
│ + notify(...)  │ └──────▲────────▲──────┘
└───────┬────────┘        │        │
        │ directs         │        │
        └─────────────────┴────────┘
```

- **Component**: Various business classes that contain business logic. Each holds a reference to a Mediator.
- **Mediator**: Interface declaring communication methods with components (usually a generic `notify(sender, event)`).
- **ConcreteMediator**: Encapsulates relations between various components.

---

## 5. Downsides & Accidental Complexity

- **God Object evolution**: Over time, a mediator easily absorbs responsibilities that belong in individual components, becoming bloated and difficult to modify.
