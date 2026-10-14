# Template Method

> **Behavioral Pattern** — Refactoring Guru Catalog
> Defines the skeleton of an algorithm in the superclass but lets subclasses override specific steps of the algorithm without changing its overall structure.

---

## 1. Intent & Core Mechanism

Breaks an algorithm into a series of steps, turns these steps into methods, and puts a series of calls to these methods inside a single "template method". The template method is final/invariant in the base class, while specific steps can be abstract or have default implementations that subclasses override.

---

## 2. When Justified

- You want to let clients extend only particular steps of an algorithm, but not the whole algorithm or its structure.
- You have several classes that contain almost identical algorithms with only minor differences.

---

## 3. Parsimony Filter & Simpler Alternatives

> **Template Method relies on class inheritance, which tightly couples subclasses to superclasses. Prefer composition or callback parameters.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| Customizable steps | Pass hook functions / callbacks into a runner function: `executeWorkflow({ beforeStep, stepOverride })`. |
| Algorithm variation | Strategy pattern (composition) over Template Method (inheritance). |
| Standard pipeline processing | Array of step functions executed in sequence. |

**The Trap**: Deep inheritance hierarchies where overriding a step in a subclass unexpectedly breaks invariants in the base template method.

---

## 4. Structure & Contracts

```text
┌─────────────────────────────────┐
│        AbstractClass            │
├─────────────────────────────────┤
│ + templateMethod(): void        │──┐ (calls step1, step2, hook)
├─────────────────────────────────┤  │
│ # step1(): void (abstract)      │<─┘
│ # step2(): void (abstract)      │
│ # hook(): void (optional)       │
└────────────────▲────────────────┘
                 │
       ┌─────────┴─────────┐
       │                   │
┌──────┴──────────┐ ┌──────┴──────────┐
│ ConcreteClassA  │ │ ConcreteClassB  │
├─────────────────┤ ├─────────────────┤
│ # step1()       │ │ # step1()       │
│ # step2()       │ │ # step2()       │
└─────────────────┘ └─────────────────┘
```

- **AbstractClass**: Declares step methods and the core `templateMethod()` that orchestrates the execution order.
- **ConcreteClasses**: Override step methods to implement custom step behavior.

---

## 5. Downsides & Accidental Complexity

- **Liskov Substitution violations**: Subclasses risk violating the expected contracts or invariants of the superclass.
- **Maintenance fragility**: As the algorithm skeleton evolves, modifying steps often breaks existing subclasses across the codebase.
