# Bridge

> **Structural Pattern** — Refactoring Guru Catalog
> Lets you split a large class or a set of closely related classes into two separate hierarchies—abstraction and implementation—which can be developed independently of each other.

---

## 1. Intent & Core Mechanism

Prevents a Cartesian product explosion of subclasses when a domain varies along two independent dimensions (e.g., `Shape` [Circle, Square] and `Renderer` [Vector, Raster]). Instead of `VectorCircle`, `RasterCircle`, `VectorSquare`, `RasterSquare`, `Shape` holds a reference to a `Renderer` interface and delegates rendering calls.

---

## 2. When Justified

- You want to divide and organize a monolithic class that has multiple orthogonal variants of some functionality (e.g., working with different database servers, OS platforms, or GUI frameworks).
- You need to switch implementations at runtime.
- You want changes in the implementation of an abstraction to have no impact on clients.

---

## 3. Parsimony Filter & Simpler Alternatives

> **Do not use Bridge if you do not have two independently expanding dimensions of variation.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| Only one dimension varying | Simple interface inheritance or Strategy pattern. |
| Platform-specific logic | Conditional compilation, environment modules, or simple dependency injection. |
| Fixed permutations known at compile time | Parameterized types or plain function composition. |

**The Trap**: Confusing Bridge with Strategy or Adapter. Bridge is designed upfront to let abstractions and implementations evolve independently; Adapter is added retroactively to make existing incompatible interfaces work together.

---

## 4. Structure & Contracts

```text
┌───────────────────────────┐         ┌───────────────────────────┐
│        Abstraction        │         │ Implementation (Contract) │
├───────────────────────────┤         ├───────────────────────────┤
│ - impl: Implementation    │────────>│ + devMethod1(): void      │
├───────────────────────────┤         │ + devMethod2(): void      │
│ + feature(): void         │         └─────────────▲─────────────┘
└─────────────▲─────────────┘                       │
              │                            ┌────────┴────────┐
┌─────────────┴─────────────┐              │                 │
│    RefinedAbstraction     │       ┌──────┴──────┐   ┌──────┴──────┐
├───────────────────────────┤       │ ConcreteImpA│   │ ConcreteImpB│
│ + advancedFeature(): void │       └─────────────┘   └─────────────┘
└───────────────────────────┘
```

- **Abstraction**: High-level control layer; delegates platform/primitive work to Implementation.
- **RefinedAbstraction**: Extends the high-level control logic.
- **Implementation**: Low-level interface defining primitive operations.
- **ConcreteImplementation**: Platform- or driver-specific code.

---

## 5. Downsides & Accidental Complexity

- **High conceptual overhead**: Hard to grasp and introduce into an existing codebase without significant refactoring.
- **Misapplication**: Often overused when simple composition or passing a callback strategy would suffice.
