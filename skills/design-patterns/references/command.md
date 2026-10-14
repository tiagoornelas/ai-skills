# Command

> **Behavioral Pattern** — Refactoring Guru Catalog
> Turns a request into a stand-alone object that contains all information about the request. This transformation lets you pass requests as method arguments, delay or queue a request's execution, and support undoable operations.

---

## 1. Intent & Core Mechanism

Encapsulates an action, its target receiver, and parameters into a single executable object conforming to an interface with an `execute()` (and optionally `undo()`) method. Decouples the invoker (UI button, scheduler, queue) from the business logic executing the request.

---

## 2. When Justified

- You want to parameterize UI elements or API controllers with operations (e.g., a toolbar button that can trigger Cut, Copy, or Paste).
- You need to queue operations, schedule their execution across threads or background workers, or send them over the network.
- You need reversible operations (Undo/Redo history stack).

---

## 3. Parsimony Filter & Simpler Alternatives

> **If you only need to pass behavior around without undo or serialization, use a closure or function callback.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| Simple event handling / callback | Plain anonymous functions or closures: `button.onClick = () => saveDocument()`. |
| Task queue without undo | Passing an array of async functions: `const queue: Array<() => Promise<void>> = []`. |
| Redux / Event Sourcing | Plain data action objects with a reducer function (`{ type: 'SAVE_DOC', payload: ... }`). |

**The Trap**: Creating a separate class for every single user action in an application when simple function callbacks or action objects are 10x more concise.

---

## 4. Structure & Contracts

```text
┌─────────────────────────┐          ┌─────────────────────────┐
│         Invoker         │          │    Command (Contract)   │
├─────────────────────────┤          ├─────────────────────────┤
│ - command: Command      │─────────>│ + execute(): void       │
├─────────────────────────┤          │ + undo(): void (opt)    │
│ + setCommand(Command)   │          └───────────▲─────────────┘
│ + executeCommand()      │                      │
└─────────────────────────┘          ┌───────────┴─────────────┐
                                     │     ConcreteCommand     │
                                     ├─────────────────────────┤
                                     │ - receiver: Receiver    │
                                     │ - params: Params        │
                                     ├─────────────────────────┤
                                     │ + execute(): void       │──┐ calls
                                     └─────────────────────────┘  │ receiver
                                                                  ▼
                                     ┌─────────────────────────┐
                                     │        Receiver         │
                                     ├─────────────────────────┤
                                     │ + action(): void        │
                                     └─────────────────────────┘
```

- **Command**: Declares the `execute()` (and optionally `undo()`) method.
- **ConcreteCommand**: Holds parameters and a reference to the Receiver; invokes receiver methods upon execution.
- **Invoker**: Triggers the command (e.g., UI component, Queue manager).
- **Receiver**: The business object that actually performs the work.

---

## 5. Downsides & Accidental Complexity

- **Class proliferation**: Every single operation requires a new class, expanding codebase size and cognitive friction.
- **State synchronization in Undo**: Restoring state accurately after failed commands or concurrent changes can be difficult without full state snapshots (Memento).
