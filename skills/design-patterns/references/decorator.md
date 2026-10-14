# Decorator

> **Structural Pattern** — Refactoring Guru Catalog
> Lets you attach new behaviors to objects by placing these objects inside special wrapper objects that contain the behaviors.

---

## 1. Intent & Core Mechanism

Enables dynamic extension of an object's behavior at runtime through composition instead of static subclassing. The Decorator wraps a Target object, implements the same interface, forwards the primary calls, and adds behavior before or after delegation.

---

## 2. When Justified

- You need to assign extra responsibilities to objects dynamically and transparently (without affecting other objects of the same class).
- Extension by subclassing is impractical or impossible due to an explosion of permutations (e.g., `CompressedEncryptedLoggedNotifier`).
- Clean separation of cross-cutting concerns (caching, logging, retry, encryption) from core domain logic.

---

## 3. Parsimony Filter & Simpler Alternatives

> **Do not build a full Decorator class hierarchy when simple function wrappers or middleware chains suffice.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| A single function or API endpoint | Higher-order functions: `withLogging(fn)`, `withRetry(fn)`. |
| HTTP or request pipeline | Standard middleware pipelines (e.g., Express/Koa middleware, Axios interceptors). |
| Static behavior known at compile time | Direct inheritance or single-responsibility helper classes. |

**The Trap**: Writing shallow decorators that do nothing except pass through calls, adding stack trace depth without meaningful abstraction.

---

## 4. Structure & Contracts

```text
┌────────────────────────────────┐
│      Component (Contract)      │
├────────────────────────────────┤
│ + execute(): void              │
└───────────────▲────────────────┘
                │
        ┌───────┴───────┐
        │               │
┌───────┴───────┐ ┌─────┴────────────────┐
│ ConcreteComp  │ │ BaseDecorator        │
├───────────────┤ ├──────────────────────┤
│ + execute()   │ │ - wrappee: Component │
└───────────────┘ ├──────────────────────┤
                  │ + execute() (forward)│
                  └──────▲───────────────┘
                         │
                 ┌───────┴────────┐
                 │                │
          ┌──────┴───────┐ ┌──────┴───────┐
          │ LoggingDec   │ │ AuthDec      │
          └──────────────┘ └──────────────┘
```

- **Component**: Interface common to both the wrapper and the wrapped objects.
- **ConcreteComponent**: Base object providing core behavior.
- **BaseDecorator**: Holds a reference to a wrapped `Component` and delegates operations.
- **ConcreteDecorators**: Add extra behaviors dynamically before or after delegating.

---

## 5. Downsides & Accidental Complexity

- **Order dependency**: Decorators often depend on the order in which they are nested (e.g., Encrypt then Compress vs. Compress then Encrypt).
- **Identity mismatch**: An object and its decorator are not identity-equal (`wrapped !== original`), breaking code that relies on object identity.
- **Debugging difficulty**: Multi-layer nested decorators result in long, difficult-to-trace call stacks.
