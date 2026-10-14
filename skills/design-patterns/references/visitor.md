# Visitor

> **Behavioral Pattern** — Refactoring Guru Catalog
> Lets you separate algorithms from the objects on which they operate.

---

## 1. Intent & Core Mechanism

Uses double dispatch to add new operations to an existing class hierarchy without modifying any of those classes. Each element class implements an `accept(visitor)` method that invokes `visitor.visitElement(this)`, enabling the visitor to execute type-specific algorithms (e.g., exporting an AST to XML, JSON, or bytecode).

---

## 2. When Justified

- You need to perform an operation on all elements of a complex object structure (e.g., an Abstract Syntax Tree), and the object structure rarely changes, but you frequently need to define new operations over the structure.
- You want to clean up auxiliary operations from the business logic classes of the object structure.

---

## 3. Parsimony Filter & Simpler Alternatives

> **WARNING: Visitor is one of the most complex GoF patterns. If your language supports pattern matching or sum types, do NOT use Visitor.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| Modern TypeScript, Rust, Python 3.10+, Scala | Pattern matching on discriminated unions / algebraic data types. |
| Single auxiliary operation | A function with a simple `switch(node.type)` statement. |
| Object structure whose classes change frequently | Keep operations directly inside the classes; Visitor requires updating all visitor interfaces every time a node class is added. |

**The Trap**: Implementing the convoluted double dispatch of Visitor in languages where structural pattern matching or function tables solve the expression problem effortlessly.

---

## 4. Structure & Contracts

```text
┌───────────────────────────────┐          ┌───────────────────────────────┐
│       Visitor (Contract)      │          │       Element (Contract)      │
├───────────────────────────────┤          ├───────────────────────────────┤
│ + visitConcreteA(A): void     │          │ + accept(Visitor): void       │
│ + visitConcreteB(B): void     │          └───────────────▲───────────────┘
└───────────────▲───────────────┘                          │
                │                                  ┌───────┴───────┐
        ┌───────┴───────┐                          │               │
┌───────┴───────┐ ┌─────┴───────┐           ┌──────┴───────┐ ┌─────┴───────┐
│ ExportXmlVis  │ │ ExportJson  │           │ ElementA     │ │ ElementB    │
└───────────────┘ └─────────────┘           ├──────────────┤ ├─────────────┤
                                            │ + accept(v)  │ │ + accept(v) │
                                            └──────────────┘ └─────────────┘
```

- **Visitor**: Declares a `visit` method for each concrete element class in the object structure.
- **ConcreteVisitors**: Implement several versions of the same algorithm tailored for all element classes.
- **Element**: Declares the `accept(visitor)` method.
- **ConcreteElements**: Implement `accept` by redirecting the call to the matching visitor method (`visitor.visitConcreteA(this)`).

---

## 5. Downsides & Accidental Complexity

- **Fragility to class hierarchy changes**: Every time a new element class is added or removed, you must update the Visitor interface and all existing concrete visitor classes.
- **Encapsulation breakdown**: Visitors frequently require access to private fields or internal state of elements to perform their work.
