# Factory Method

> **Creational Pattern** — Refactoring Guru Catalog
> Provides an interface for creating objects in a superclass, but allows subclasses or specialized creators to alter the type of objects that will be created.

---

## 1. Intent & Core Mechanism

Decouples the code that uses an object (client) from the concrete class instantiated. Instead of calling `new ConcreteProduct()`, client code calls a creator method (`createProduct()`) that returns an instance conforming to a common `Product` interface.

---

## 2. When Justified

- You do not know beforehand the exact types and dependencies of the objects your code should work with.
- You want to provide users of your library or framework with a way to extend its internal components by substituting default implementations.
- Object construction involves complex initialization logic that should not be duplicated across callers.

---

## 3. Parsimony Filter & Simpler Alternatives

> **Do not use Factory Method if construction does not vary across subclasses or runtime environments.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| A single concrete implementation that rarely changes | Direct constructor invocation (`new Product()`). |
| Variations selected by a simple type parameter | A standalone factory function (`createProduct(type: string)`). |
| Dynamic instantiation based on configuration | A dictionary/map of constructor functions (`const registry = { typeA: () => new ProductA() }`). |

**The Trap**: Creating abstract creator classes and concrete sub-creators for a single product hierarchy. This creates shallow class proliferation.

---

## 4. Structure & Contracts

```text
┌─────────────────────────┐          ┌─────────────────────────┐
│     Creator (Base)      │          │     Product (Contract)  │
├─────────────────────────┤          ├─────────────────────────┤
│ + createProduct(): Prod │─────────>│ + operation(): void     │
│ + someOperation(): void │          └───────────▲─────────────┘
└───────────▲─────────────┘                      │
            │                                    │
┌───────────┴─────────────┐          ┌───────────┴─────────────┐
│    ConcreteCreatorA     │          │    ConcreteProductA     │
├─────────────────────────┤          ├─────────────────────────┤
│ + createProduct(): Prod ├─────────>│ + operation(): void     │
└─────────────────────────┘          └─────────────────────────┘
```

- **Product**: Declares the common interface for all objects created by the factory.
- **ConcreteProduct**: Specific implementations of the Product interface.
- **Creator**: Declares the factory method. Often contains core business logic relying on the Product.
- **ConcreteCreator**: Overrides the factory method to return a specific ConcreteProduct.

---

## 5. Downsides & Accidental Complexity

- **Subclass explosion**: Code may become complicated because you need to introduce new creator subclasses just to create new product subclasses.
- **Indirection**: Tracing which concrete class is instantiated requires navigating creator inheritance hierarchies.
