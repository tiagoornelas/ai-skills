# Observer

> **Behavioral Pattern** — Refactoring Guru Catalog
> Lets you define a subscription mechanism to notify multiple objects about any events that happen to the object they're observing.

---

## 1. Intent & Core Mechanism

Establishes a one-to-many dependency between a **Publisher** (Subject) and multiple **Subscribers** (Observers). When an event occurs or state changes in the publisher, it iterates through its subscriber list and calls a notification method on each subscriber without coupling to their concrete classes.

---

## 2. When Justified

- Changes to the state of one object may require changing other objects, and the actual set of objects is unknown beforehand or changes dynamically.
- An object should be able to notify other objects without making assumptions about who these objects are (loose coupling).

---

## 3. Parsimony Filter & Simpler Alternatives

> **Do not write custom Subject/Observer interface hierarchies when built-in event emitters, reactive signals, or callback lists exist.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| Node.js / Browser events | Standard `EventEmitter` or `EventTarget` (`addEventListener`). |
| Reactive UI frameworks | Signals, observables (RxJS), or state stores (Redux, Zustand, Vue Reactivity). |
| Single listener / delegate | Passing a single callback function (`onComplete: () => void`). |

**The Trap**: Writing rigid `IObserver` and `ISubject` classes with synchronized vector collections in languages where events and lambdas are first-class language citizens.

---

## 4. Structure & Contracts

```text
┌───────────────────────────────┐
│     Publisher (Subject)       │
├───────────────────────────────┤
│ - subscribers: Subscriber[]   │
├───────────────────────────────┤
│ + subscribe(s: Subscriber)    │
│ + unsubscribe(s: Subscriber)  │
│ + notifySubscribers(): void   │──┐ iterates & notifies
└───────────────────────────────┘  │
                                   ▼
                        ┌───────────────────────────────┐
                        │     Subscriber (Contract)     │
                        ├───────────────────────────────┤
                        │ + update(context): void       │
                        └───────────────▲───────────────┘
                                        │
                                ┌───────┴───────┐
                                │               │
                         ┌──────┴───────┐ ┌─────┴────────┐
                         │ ConcreteSubA │ │ ConcreteSubB │
                         └──────────────┘ └──────────────┘
```

- **Publisher**: Manages subscription list and dispatches notifications when interesting events occur.
- **Subscriber**: Common interface defining the `update()` notification method.
- **ConcreteSubscribers**: Perform custom actions in response to publisher notifications.

---

## 5. Downsides & Accidental Complexity

- **Memory leaks ("Lapsed Listener Problem")**: If subscribers fail to unsubscribe when no longer needed, the publisher retains strong references to them, preventing garbage collection.
- **Unpredictable execution order**: Subscribers should never assume they are notified in any particular order.
