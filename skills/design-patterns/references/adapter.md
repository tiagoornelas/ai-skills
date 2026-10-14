# Adapter

> **Structural Pattern** — Refactoring Guru Catalog
> Allows objects with incompatible interfaces to collaborate.

---

## 1. Intent & Core Mechanism

Translates the interface of one existing class or external service into another interface expected by client code. It wraps an "Adaptee" object and exposes a "Target" interface, converting calls, arguments, and data structures between the two.

---

## 2. When Justified

- You want to use an existing 3rd-party library, legacy class, or external API, but its interface does not match the rest of your domain or application code.
- You want to reuse several existing subclasses that lack some common functionality that cannot be added to the superclass (object adapter).
- Clean Architecture / Hexagonal Architecture: Adapting external infrastructure drivers to domain ports.

---

## 3. Parsimony Filter & Simpler Alternatives

> **Do not create an Adapter class when a simple mapping function or inline translation suffices.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| Simple data transformation | A pure transformation function: `const adapted = transformToTarget(source)`. |
| Single function mismatch | An arrow function or lambda wrapper: `const targetFn = (data) => service.fetch({ query: data })`. |
| You control both sides of the code | Refactor the callee to conform to the target interface directly instead of adding an adapter layer. |

**The Trap**: Creating nested adapters over adapters for minor parameter naming differences.

---

## 4. Structure & Contracts

```text
┌────────────────────┐          ┌────────────────────┐
│  Client (Domain)   │─────────>│  Target (Contract) │
└────────────────────┘          ├────────────────────┤
                                │ + request(): void  │
                                └─────────▲──────────┘
                                          │
                                ┌─────────┴──────────┐
                                │      Adapter       │
                                ├────────────────────┤
                                │ - adaptee: Adaptee │
                                ├────────────────────┤
                                │ + request(): void  │──┐
                                └────────────────────┘  │ calls
                                                        ▼
                                ┌─────────────────────────────┐
                                │      Adaptee (Vendor)       │
                                ├─────────────────────────────┤
                                │ + specificRequest(): void   │
                                └─────────────────────────────┘
```

- **Target / Port**: The interface required by domain business logic.
- **Client**: Collaborates with objects conforming to the Target interface.
- **Adaptee**: The existing service, SDK, or legacy module with the incompatible interface.
- **Adapter**: Implements Target and translates requests to Adaptee method calls.

---

## 5. Downsides & Accidental Complexity

- **Indirection overhead**: Every call traverses an extra layer of abstraction.
- **Leaky abstractions**: If the Adaptee throws vendor-specific exceptions or leaks internal data representations, the adapter fails its purpose unless errors and data are translated into domain concepts.
