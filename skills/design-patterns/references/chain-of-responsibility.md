# Chain of Responsibility

> **Behavioral Pattern** — Refactoring Guru Catalog
> Lets you pass requests along a chain of handlers. Upon receiving a request, each handler decides either to process the request or to pass it to the next handler in the chain.

---

## 1. Intent & Core Mechanism

Decouples senders of a request from its receivers by allowing multiple objects a chance to handle the request. Handlers are linked into a sequential chain; a request travels down the chain until a handler processes it or the end of the chain is reached.

---

## 2. When Justified

- Multiple objects can handle a request, and the handler isn't known a priori or must be determined dynamically.
- You want to issue a request to one of several objects without specifying the receiver explicitly.
- The set of handlers and their order should be configurable at runtime.

---

## 3. Parsimony Filter & Simpler Alternatives

> **Do not build a linked-list of handler classes when an array of middleware functions accomplishes the exact same flow.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| HTTP or request processing | An array of middleware/interceptor functions iterated with a loop or `next()` callback. |
| Fixed sequence of validation rules | A list of validator functions evaluated sequentially: `validators.find(fn => !fn(input))`. |
| Single condition dispatcher | A simple `switch` or `if/else` ladder, or a strategy lookup map. |

**The Trap**: Writing full Handler classes with `.setNext()` linked references for simple sequential validations.

---

## 4. Structure & Contracts

```text
┌─────────────────────────────────┐
│        Handler (Contract)       │
├─────────────────────────────────┤
│ + setNext(Handler): Handler     │
│ + handle(request): Response     │
└────────────────▲────────────────┘
                 │
       ┌─────────┴─────────┐
       │                   │
┌──────┴──────────┐ ┌──────┴──────────┐
│ ConcreteHandlerA│ │ ConcreteHandlerB│
├─────────────────┤ ├─────────────────┤
│ + handle(...)   │ │ + handle(...)   │
└─────────────────┘ └─────────────────┘
```

- **Handler**: Declares common interface for all concrete handlers. Typically includes a reference to `nextHandler`.
- **BaseHandler**: Optional boilerplate class managing the next reference.
- **ConcreteHandlers**: Check if they can handle the request. If yes, process; if not (or in addition), forward to `nextHandler.handle()`.

---

## 5. Downsides & Accidental Complexity

- **Unfulfilled requests**: A request can fall off the end of the chain without ever being handled if no handler claims it, requiring fallback logic.
- **Hidden performance cost**: In long chains, traversing dozens of handlers for every request adds execution overhead and complicates debugging.
