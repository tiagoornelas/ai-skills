# Facade

> **Structural Pattern** — Refactoring Guru Catalog
> Provides a simplified interface to a library, a framework, or any other complex set of classes.

---

## 1. Intent & Core Mechanism

Acts as a single, high-level entry point into a complex subsystem. Instead of client code interacting directly with a dozen low-level classes, configurations, and initialization steps, the Facade provides a clean, cohesive interface for the 80% most common use cases.

---

## 2. When Justified

- You need to present a limited, straightforward interface to a complex subsystem.
- You want to structure a subsystem into layers; facades define entry points to each subsystem level and decouple subsystems from one another.
- You want to shield client code from breaking changes in third-party libraries or internal subsystems.

---

## 3. Parsimony Filter & Simpler Alternatives

> **A Facade must be a DEEP interface. If the facade merely renames low-level methods 1:1, it is a useless pass-through layer.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| A subsystem with only 1 or 2 straightforward classes | Direct calls to those classes without a facade. |
| A module in TypeScript/Python/Go | Module exports / index file (`index.ts`) exporting only public functions and hiding internal files. |
| Callers needing full control and low-level knobs | Direct subsystem access; do not force low-level callers through an awkward facade. |

**The Trap**: Turning Facade into a "God Object" that accumulates unrelated logic and becomes a monolithic dependency across the entire project.

---

## 4. Structure & Contracts

```text
┌───────────────────────────────────────────────┐
│                    Client                     │
└───────────────────────┬───────────────────────┘
                        │ uses
                        ▼
┌───────────────────────────────────────────────┐
│                    Facade                     │
├───────────────────────────────────────────────┤
│ + simpleOperation(): void                     │
└─────┬───────────────────┬───────────────────┬─┘
      │ delegates         │ delegates         │ delegates
      ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ SubsystemA  │     │ SubsystemB  │     │ SubsystemC  │
└─────────────┘     └─────────────┘     └─────────────┘
```

- **Facade**: Provides convenient access to specific parts of subsystem functionality. Coordinates subsystem objects.
- **Subsystem Classes**: Implement low-level features. Completely unaware of the facade; they can operate independently.

---

## 5. Downsides & Accidental Complexity

- **God Class Risk**: A facade can easily degrade into an all-knowing mega-class coupled to all classes of an app if not disciplined.
- **Leaked Subsystems**: If clients constantly bypass the facade to touch underlying classes directly, the facade may be poorly designed or unnecessary.
