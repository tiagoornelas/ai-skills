# Strategy

> **Behavioral Pattern** — Refactoring Guru Catalog
> Lets you define a family of algorithms, put each of them into a separate class, and make their objects interchangeable.

---

## 1. Intent & Core Mechanism

Enables switching the algorithm or strategy used by an object at runtime. The Context class maintains a reference to a Strategy interface; algorithms are encapsulated in separate strategy classes that clients can swap without modifying the Context.

---

## 2. When Justified

- You want to use different variants of an algorithm within an object and be able to switch from one algorithm to another during runtime.
- You have a lot of similar classes that only differ in the way they execute some behavior.
- You want to isolate the business logic of a class from the algorithmic implementation details.
- A class defines a massive conditional operator that switches between different variants of the same algorithm.

---

## 3. Parsimony Filter & Simpler Alternatives

> **In modern languages with first-class functions, Strategy is almost always better implemented as a higher-order function receiving a callback.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| Stateless algorithm (sorting, calculation, filtering) | Pass a function / lambda directly: `calculateTotal(items, taxCalculatorFn)`. |
| Fixed algorithm options | A dictionary mapping string keys to functions: `const strategies = { creditCard: payWithCard, paypal: payWithPaypal }`. |
| Algorithms that do not require state or lifecycle hooks | A pure function instead of a class implementing an interface. |

**The Trap**: Creating a separate class file for every 3-line mathematical formula just to satisfy textbook OOP Strategy examples.

---

## 4. Structure & Contracts

```text
┌───────────────────────────────┐          ┌───────────────────────────────┐
│            Context            │          │      Strategy (Contract)      │
├───────────────────────────────┤          ├───────────────────────────────┤
│ - strategy: Strategy          │─────────>│ + execute(data): Result       │
├───────────────────────────────┤          └───────────────▲───────────────┘
│ + setStrategy(Strategy)       │                          │
│ + executeAlgorithm(): Result  │                  ┌───────┴───────┐
└───────────────────────────────┘                  │               │
                                            ┌──────┴───────┐ ┌─────┴───────┐
                                            │ ConcreteStrA │ │ ConcreteStrB │
                                            └──────────────┘ └─────────────┘
```

- **Context**: Maintains a reference to a concrete strategy and communicates with it via the Strategy interface.
- **Strategy**: Common interface declaring the execution method implemented by all algorithms.
- **ConcreteStrategies**: Implement distinct variations of the algorithm.

---

## 5. Downsides & Accidental Complexity

- **Client awareness**: Clients must be aware of how strategies differ in order to choose the right one.
- **Shallow classes**: In languages with first-class functions, strategy classes with a single method are the epitome of shallow classes.
