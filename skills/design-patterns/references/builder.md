# Builder

> **Creational Pattern** — Refactoring Guru Catalog
> Lets you construct complex objects step by step. Allows producing different types and representations of an object using the same construction process.

---

## 1. Intent & Core Mechanism

Separates the construction of a complex object from its representation. Instead of a massive constructor with dozens of parameters (many optional or nullable), construction happens in staged method calls (`builder.setCPU().setRAM().build()`).

---

## 2. When Justified

- You need to get rid of a "telescoping constructor" (constructors with multiple overloaded parameter permutations).
- Construction involves complex multi-step assembly, order-dependent setup, or recursive object trees (e.g., building a query AST or complex composite UI).
- You want the same construction process to produce different representations (e.g., building HTML vs. Markdown representations of a document).

---

## 3. Parsimony Filter & Simpler Alternatives

> **In modern languages, Builder is often redundant due to named arguments, optional parameters, or options objects.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| TypeScript, Python, or languages with named arguments/object literals | A typed options bag parameter: `createCar({ engine: 'V8', seats: 4 })`. |
| Immutable data structures | Copy-on-write methods (`withEngine(...)`) or language object spread (`{ ...car, engine }`). |
| Simple linear configuration | Direct constructor calls with validated configuration schemas (e.g., Zod, Pydantic). |

**The Trap**: Writing a 60-line `UserBuilder` class with `.withName()`, `.withEmail()`, `.build()` when a single TypeScript `type User = { name: string; email: string; ... }` with a constructor or factory function does the job in 5 lines.

---

## 4. Structure & Contracts

```text
┌──────────────────────┐          ┌──────────────────────┐
│  Director (Optional) │          │  Builder (Contract)  │
├──────────────────────┤          ├──────────────────────┤
│ - builder: Builder   │─────────>│ + reset(): void      │
├──────────────────────┤          │ + setPartA(): void   │
│ + makeMinimal(): void│          │ + setPartB(): void   │
│ + makeFull(): void   │          └──────────▲───────────┘
└──────────────────────┘                     │
                                  ┌──────────┴───────────┐
                                  │   ConcreteBuilder    │
                                  ├──────────────────────┤
                                  │ + getResult(): Prod  │
                                  └──────────────────────┘
```

- **Builder**: Declares product construction steps common to all builders.
- **ConcreteBuilder**: Implements the steps and tracks the constructed product. Provides `getResult()`.
- **Director (Optional)**: Defines the order in which to execute building steps to produce reusable configurations.

---

## 5. Downsides & Accidental Complexity

- **Code bloat**: Creates multiple new classes and duplicate field declarations between the Builder and the Product.
- **Mutable construction state**: If the builder retains state across builds, subtle reuse bugs can occur unless `reset()` is strictly enforced.
