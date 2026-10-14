# Abstract Factory

> **Creational Pattern** — Refactoring Guru Catalog
> Lets you produce families of related or dependent objects without specifying their concrete classes.

---

## 1. Intent & Core Mechanism

Provides an interface for creating all distinct products belonging to a product family (e.g., UI buttons, checkboxes, windows for macOS vs. Windows). Clients work exclusively with abstract interfaces for both factories and products, ensuring consistent family pairings.

---

## 2. When Justified

- Your system must be independent of how its products are created, composed, and represented.
- The system must be configured with one of multiple families of products, and products within a family are designed to work together (mixing families is invalid).
- You want to enforce consistency across a family of products across multiple runtime environments (e.g., cross-platform rendering, multi-cloud storage).

---

## 3. Parsimony Filter & Simpler Alternatives

> **Do not use Abstract Factory if you do not have multiple, cohesive families of products.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| Independent, unrelated product variants | Separate Factory Functions for each type. |
| A single environment or platform | Plain direct construction; no factories needed. |
| Modern modules / dynamic imports | Platform-specific module exports with identical interface signatures (`import * as ui from './platforms/' + platform`). |

**The Trap**: Implementing Abstract Factory when only one product family exists "just in case" a second platform is added in the future.

---

## 4. Structure & Contracts

```text
┌─────────────────────────────────┐
│     AbstractFactory (Contract)  │
├─────────────────────────────────┤
│ + createButton(): Button        │
│ + createCheckbox(): Checkbox    │
└────────────────▲────────────────┘
                 │
       ┌─────────┴─────────┐
       │                   │
┌──────┴──────────┐ ┌──────┴──────────┐
│ MacFactory      │ │ WinFactory      │
├─────────────────┤ ├─────────────────┤
│ + createButton  │ │ + createButton  │
│ + createCheckbox│ │ + createCheckbox│
└─────────────────┘ └─────────────────┘
```

- **AbstractFactory**: Declares creation methods for each product in the family.
- **ConcreteFactories**: Implement creation methods producing specific variants of products.
- **AbstractProducts**: Common interfaces for each distinct product type (`Button`, `Checkbox`).
- **ConcreteProducts**: Specific implementations grouped by family variant.

---

## 5. Downsides & Accidental Complexity

- **Interface rigidity**: Adding a new product type to the family requires changing the `AbstractFactory` interface and updating all concrete factory classes.
- **Overhead**: Introducing dozens of interfaces and classes for small features causes cognitive overload.
