# The Law of Parsimony & Pattern Heuristics

> **Central thesis**: Design patterns are not building blocks to assemble upfront; they are solutions to specific, recurring design tensions. When introduced without a real tension, patterns become **accidental complexity**—introducing indirection, boilerplate, shallow classes, and cognitive friction for zero return.

---

## 1. The Trap of "Patternitis" (Overengineering)

Patternitis occurs when an engineer or AI agent chooses a design pattern *before* understanding the problem or as a default way to organize code. Symptoms include:
- Creating factories for objects that only have a single concrete implementation and never vary.
- Wrapping a simple 10-line algorithm inside 4 strategy classes and an interface.
- Creating single-method commands when a callback function or direct method call suffices.
- Adding abstract facades over systems that only have two simple methods.

### The Golden Rule
> **Prefer the simplest mechanism that makes the code correct, obvious, and easy to change.** If a language primitive (function, closure, plain object, module) solves the problem cleanly, introducing a pattern is a design defect.

---

## 2. Modern Language Evolution vs. Classic GoF Patterns

Many GoF design patterns were invented in the 1990s as workarounds for limitations in early object-oriented languages (like C++ or Java 1.0) that lacked first-class functions, lambdas, closures, reflection, or pattern matching.

In modern languages (TypeScript, Python, Go, Rust, modern Java/C#):

| Classic Pattern | Why It Was Needed | Modern Language Primitive |
| :--- | :--- | :--- |
| **Strategy** | Passing behavior to an object required an interface and concrete classes. | First-class functions, lambdas, or closures passed as arguments. |
| **Command** | Encapsulating an executable action required an object with an `execute()` method. | Zero-argument closures, thunks, or coroutines (`() => void`). |
| **Iterator** | Traversing a custom collection required an external stateful cursor object. | Native language iterators / generators (`Symbol.iterator`, `yield`, `Iterable`). |
| **Template Method** | Invariant flow with customizable steps required class inheritance and abstract methods. | Higher-order function accepting step callbacks as arguments or options bag. |
| **Singleton** | Controlling global access in pure OOP where everything must be a class. | Module-level singleton instance, file-scoped constant, or Dependency Injection container. |
| **Observer** | Decoupling state changes required explicit observer and subject interfaces. | Event emitters, signals, reactive streams, or simple callback arrays. |
| **State** | Managing complex state transitions without giant `switch` statements. | Discriminated unions with pattern matching, or a transition lookup map/table. |
| **Visitor** | Adding operations across class hierarchies without modifying them. | Algebraic data types (sum types) with exhaustive pattern matching. |

---

## 3. The Parsimony Gate Checklist

Before proposing or implementing any design pattern, verify the following three criteria:

### Criterion 1: Concrete Variation Axis
- Can you name the exact dimension along which this code will vary independently?
- Examples of real variation axes:
  - "We must support 3 different payment processors whose APIs change independently." (Justifies Adapter).
  - "We must parse 4 distinct file formats producing the same internal domain AST." (Justifies Factory Method or Strategy).
- Examples of fake/speculative axes:
  - "Maybe someday we will switch from PostgreSQL to MongoDB." (YAGNI; does not justify full Abstract Factory abstraction layer unless actively planned).
  - "What if we need to undo this action later?" (Premature Command pattern).

### Criterion 2: Depth of the Resulting Abstraction
- Does the pattern make the module **deep** (small, simple interface covering rich functionality), or does it create **shallow classitis** (lots of tiny classes where interface equals implementation)?
- If the pattern introduces more lines of boilerplate and glue than actual business logic, discard it.

### Criterion 3: Refactoring Over Preemptive Design
- Follow the Rule of Three:
  1. Write it cleanly the first time using direct code.
  2. If a similar variation arises a second time, observe the duplication.
  3. When it arises a third time, refactor towards the pattern.

---

## 4. When a Pattern IS Justified

A design pattern is justified when:
1. **The language primitive lacks needed lifecycle or state**: A closure is great for a stateless algorithm (Strategy), but if the strategy needs to hold state, expose lifecycle methods (`init`, `teardown`), or be serialized, a dedicated class/interface structure becomes warranted.
2. **Recursive composition is natural**: Trees of UI widgets, AST nodes, or permission rules naturally benefit from the **Composite** pattern.
3. **Decoupling across architectural boundaries**: When business rules must communicate with infrastructure without depending on it (Dependency Inversion), **Adapter** or **Facade** provides an explicit, testable contract.
4. **Coordinating complex multi-object choreography**: When 6 subsystems communicate in an entangled N×N mesh, a **Mediator** pulls complexity downward and restores order.
