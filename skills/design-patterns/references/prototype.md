# Prototype

> **Creational Pattern** — Refactoring Guru Catalog
> Lets you copy existing objects without making your code dependent on their concrete classes.

---

## 1. Intent & Core Mechanism

Delegates the cloning process to the actual objects that are being cloned. Declares a common `clone()` interface so client code can duplicate an object without coupling to its private fields or concrete class type.

---

## 2. When Justified

- Your code should not depend on the concrete classes of objects that you need to copy (e.g., handling polymorphic objects passed as generic interfaces).
- You want to reduce the number of subclasses that only differ in the way they initialize their respective objects (preset configuration prototypes).
- Object instantiation requires expensive operations (database queries, network requests, complex parsing) that can be avoided by cloning a pre-populated template.

---

## 3. Parsimony Filter & Simpler Alternatives

> **Do not implement a formal Prototype class hierarchy if shallow copying or standard serialization satisfies the need.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| Simple plain objects without complex circular references | Modern clone built-ins: `structuredClone(obj)` in JS/TS, `copy.deepcopy()` in Python. |
| Value objects with copy methods | Direct spread operations: `{ ...state, modifiedField }`. |
| Factory registry | Storing creation parameter presets in a configuration dictionary rather than active prototype instances. |

**The Trap**: Writing custom `clone()` methods across complex class graphs that get out of date whenever a new field is added.

---

## 4. Structure & Contracts

```text
┌───────────────────────────┐
│    Prototype (Contract)   │
├───────────────────────────┤
│ + clone(): Prototype      │
└─────────────▲─────────────┘
              │
     ┌────────┴────────┐
     │                 │
┌────┴────────────┐ ┌──┴────────────┐
│ ConcreteProtoA  │ │ ConcreteProtoB │
├─────────────────┤ ├─────────────────┤
│ + clone(): Prod │ │ + clone(): Prod │
└─────────────────┘ └─────────────────┘
```

- **Prototype**: Declares the cloning method (`clone()`).
- **ConcretePrototype**: Implements the cloning method, copying internal fields (including private state).

---

## 5. Downsides & Accidental Complexity

- **Circular references**: Cloning complex objects that have circular references or external resource handles (sockets, open file descriptors) is notoriously error-prone.
- **Deep vs. Shallow confusion**: Ambiguity about whether referenced nested objects are copied or shared leads to insidious shared-mutation bugs.
