# Composite

> **Structural Pattern** — Refactoring Guru Catalog
> Lets you compose objects into tree structures and then work with these structures as if they were individual objects.

---

## 1. Intent & Core Mechanism

Solves hierarchical part-whole problems by having both individual objects (Leaves) and containers of objects (Composites) implement the same common `Component` interface. Calling a method on a Composite propagates the call recursively down to all its children.

---

## 2. When Justified

- The core data model of your application can naturally be represented as a tree structure (e.g., UI component hierarchies, filesystem folders/files, graphic scene graphs, compound financial products).
- Client code should treat both simple and complex compound elements uniformly, without knowing whether an item is a leaf or a branch.

---

## 3. Parsimony Filter & Simpler Alternatives

> **Do not use Composite if your data structure is a flat list or does not require recursive operations.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| A flat list of items | A simple collection/array and standard iterative methods (`map`, `filter`, `reduce`). |
| Heterogeneous tree where operations differ radically by node type | Tagged/discriminated unions with a recursive traversal function. |
| Read-only nested JSON / data structure | Plain objects and recursive functions rather than stateful class hierarchies. |

**The Trap**: Exposing container management methods (`add`, `remove`, `getChildren`) on the common `Component` interface, forcing `Leaf` nodes to throw dummy "unsupported operation" exceptions.

---

## 4. Structure & Contracts

```text
┌─────────────────────────────────┐
│       Component (Contract)      │
├─────────────────────────────────┤
│ + execute(): void               │
└────────────────▲────────────────┘
                 │
       ┌─────────┴─────────┐
       │                   │
┌──────┴──────────┐ ┌──────┴──────────┐
│      Leaf       │ │    Composite    │
├─────────────────┤ ├─────────────────┤
│ + execute()     │ │ - children: []  │
└─────────────────┘ ├─────────────────┤
                    │ + add(Component)│
                    │ + execute()     │──┐ (loops children)
                    └─────────────────┘  │
                             ▲           │
                             └───────────┘
```

- **Component**: Common interface declaring operations for both simple and complex objects.
- **Leaf**: Basic element that does not have children. Performs the actual work.
- **Composite**: Element containing children (Leaves or other Composites). Delegates work to children and compiles results.

---

## 5. Downsides & Accidental Complexity

- **Overly generic interface**: Providing a common interface for classes whose functionality differs too much can violate the Interface Segregation Principle.
- **Type safety erosion**: It becomes difficult to restrict which components can be added as children of specific composites at compile time without runtime checks.
