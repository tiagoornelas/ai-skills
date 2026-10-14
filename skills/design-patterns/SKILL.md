---
name: design-patterns
description: >-
  Guides the selection and application of classic design patterns from the
  Refactoring Guru catalog under strict parsimony: prioritizes simpler language
  primitives, functions, and direct composition, applying patterns only when
  justified by a concrete variation axis. Triggered when designing or refactoring
  object structures, creation workflows, or behavioral interactions.
---

# Design Patterns

A curated catalog of classic design patterns based on the [Refactoring Guru](https://refactoring.guru/design-patterns/catalog) catalog, governed by the **Law of Parsimony**.

---

## 1. Core Principle: The Law of Parsimony

> **Patterns are remedies for specific structural tensions, not goals in themselves.** Applying a pattern without a concrete variation axis introduces accidental complexity, indirection, and cognitive bloat (*patternitis*).

Before introducing any pattern, the agent and developer must pass through the **Parsimony Gate**:

1. **Identify the concrete variation axis**: What exact change or extension is currently difficult or error-prone? If this cannot be stated in one clear sentence, **reject the pattern**.
2. **Exhaust modern language primitives first**: Can first-class functions, closures, plain objects/records, modules, algebraic data types, or built-in language protocols solve this cleanly? If yes, **use the primitive, not the pattern**.
3. **Refactor towards patterns, do not design preemptively**: Prefer starting with direct, simple code. Introduce a pattern only when structural tension emerges repeatedly in passing code.

See [references/parsimony-and-heuristics.md](references/parsimony-and-heuristics.md) for deep analysis of overengineering and modern alternatives.

---

## 2. Selection Matrix

### Creational Patterns
Use when object creation logic leaks knowledge across boundaries, or construction of complex graphs becomes repetitive and fragile.

| Pressure / Symptom | Candidate Pattern | Simpler Language Alternative | Reference |
| :--- | :--- | :--- | :--- |
| Callers need objects without coupling to concrete classes | **Factory Method** | Pure factory function or direct constructor | [factory-method.md](references/factory-method.md) |
| System needs families of related products without depending on concrete classes | **Abstract Factory** | Configuration object of factory functions or modules | [abstract-factory.md](references/abstract-factory.md) |
| Constructing complex objects requires a long constructor parameter list or step-by-step setup | **Builder** | Parameter object, options bag, or named arguments | [builder.md](references/builder.md) |
| Object creation is expensive and new instances duplicate existing ones | **Prototype** | Shallow/deep clone function or copy method | [prototype.md](references/prototype.md) |
| Exactly one instance of a class must exist with global access | **Singleton** | Module-level constant or dependency injection | [singleton.md](references/singleton.md) |

### Structural Patterns
Use when composing classes and objects into larger structures while keeping relationships flexible and interfaces deep.

| Pressure / Symptom | Candidate Pattern | Simpler Language Alternative | Reference |
| :--- | :--- | :--- | :--- |
| Incompatible interfaces between calling code and an external dependency or service | **Adapter** | Thin wrapper function or mapping function | [adapter.md](references/adapter.md) |
| Orthogonal dimensions of variation (e.g., abstractions and platforms) multiplying classes | **Bridge** | Passing platform implementation callback or strategy | [bridge.md](references/bridge.md) |
| Tree structures where clients must treat individual objects and compositions uniformly | **Composite** | Recursive data structures or algebraic data types | [composite.md](references/composite.md) |
| Dynamically adding responsibilities to objects without class inheritance explosion | **Decorator** | Function composition or pipeline wrappers | [decorator.md](references/decorator.md) |
| Complex subsystem requires a simple, unified public boundary | **Facade** | Single entry-point module exposing high-level functions | [facade.md](references/facade.md) |
| Massive number of fine-grained objects causing excessive memory usage | **Flyweight** | Shared immutable lookup table or interning cache | [flyweight.md](references/flyweight.md) |
| Controlling access, lazy loading, caching, or logging for a sensitive resource | **Proxy** | Interceptor function, wrapper closure, or language Proxy | [proxy.md](references/proxy.md) |

### Behavioral Patterns
Use when managing communication, algorithms, state, and responsibility distribution between objects.

| Pressure / Symptom | Candidate Pattern | Simpler Language Alternative | Reference |
| :--- | :--- | :--- | :--- |
| Request must pass through a dynamic sequence of handlers | **Chain of Responsibility** | Array/pipeline of filter functions (middleware) | [chain-of-responsibility.md](references/chain-of-responsibility.md) |
| Operations need to be queued, logged, delayed, or undone as first-class values | **Command** | Zero-argument closures or thunks (`() => void`) | [command.md](references/command.md) |
| Sequential traversal of complex data structures without exposing internal representation | **Iterator** | Built-in language iterators / generators (`for..of`, `yield`) | [iterator.md](references/iterator.md) |
| Tight chaotic coupling between many collaborating components | **Mediator** | Event emitter or central coordinator controller | [mediator.md](references/mediator.md) |
| Capturing and restoring an object's internal state without violating encapsulation | **Memento** | Immutable snapshots or serialized state | [memento.md](references/memento.md) |
| One-to-many dependency where state changes notify interested subscribers | **Observer** | Event emitter, signal, or callback list | [observer.md](references/observer.md) |
| Object behavior changes completely based on internal state transitions | **State** | State machine lookup table or discriminated union | [state.md](references/state.md) |
| Multiple interchangeable variations of an algorithm needed at runtime | **Strategy** | Higher-order function passing the algorithm callback | [strategy.md](references/strategy.md) |
| Invariant algorithm skeleton with specific customizable steps in subclasses | **Template Method** | Function receiving hooks/callbacks as parameters | [template-method.md](references/template-method.md) |
| Adding operations to a stable object hierarchy without modifying its classes | **Visitor** | Pattern matching or function dispatch table | [visitor.md](references/visitor.md) |

---

## 3. Rules for Applying Patterns

When a pattern passes the Parsimony Gate:
1. **Design Deep Interfaces**: The pattern's presence must simplify life for callers, not leak its internal machinery. If applying a pattern causes callers to instantiate 5 companion classes, it is a shallow, failed design.
2. **Respect Dependency Direction**: Interfaces of structural and behavioral patterns belong to the consumer or domain, not to infrastructure or vendor libraries (see [`software-designing`](../software-designing/SKILL.md)).
3. **Keep Roles Focused**: Do not merge unrelated patterns into an unreadable hybrid.
4. **Name Intent, Not Merely Pattern**: Prefer domain-meaningful names (e.g., `PaymentGateway` over `PaymentAdapter`, `RouteOptimizer` over `RouteStrategy`) unless the pattern name enhances obviousness for maintainers.

---

## 4. References (Loaded On-Demand)

| Reference | Category | Load when... |
| :--- | :--- | :--- |
| [parsimony-and-heuristics.md](references/parsimony-and-heuristics.md) | Core | Evaluating whether to use any pattern or suspecting overengineering. |
| [factory-method.md](references/factory-method.md) | Creational | Delegating object creation to subclasses or decoupled factories. |
| [abstract-factory.md](references/abstract-factory.md) | Creational | Creating families of related or dependent objects. |
| [builder.md](references/builder.md) | Creational | Constructing complex step-by-step representations. |
| [prototype.md](references/prototype.md) | Creational | Cloning existing instances instead of building from scratch. |
| [singleton.md](references/singleton.md) | Creational | Ensuring a single instance with controlled access. |
| [adapter.md](references/adapter.md) | Structural | Bridging incompatible interfaces between caller and callee. |
| [bridge.md](references/bridge.md) | Structural | Decoupling abstraction from implementation along two dimensions. |
| [composite.md](references/composite.md) | Structural | Composing nested tree structures with uniform leaf/branch interfaces. |
| [decorator.md](references/decorator.md) | Structural | Dynamically attaching responsibilities to objects. |
| [facade.md](references/facade.md) | Structural | Providing a simplified high-level interface to a complex subsystem. |
| [flyweight.md](references/flyweight.md) | Structural | Sharing common state across vast numbers of fine-grained instances. |
| [proxy.md](references/proxy.md) | Structural | Providing a surrogate or placeholder to control access to an object. |
| [chain-of-responsibility.md](references/chain-of-responsibility.md) | Behavioral | Passing requests along a dynamic chain of potential handlers. |
| [command.md](references/command.md) | Behavioral | Encapsulating requests as objects for queuing, undo, or scheduling. |
| [iterator.md](references/iterator.md) | Behavioral | Traversing elements of a collection without exposing underlying structure. |
| [mediator.md](references/mediator.md) | Behavioral | Reducing chaotic dependencies among collaborating components. |
| [memento.md](references/memento.md) | Behavioral | Saving and restoring object state snapshots without breaking encapsulation. |
| [observer.md](references/observer.md) | Behavioral | Establishing a publish-subscribe notification mechanism. |
| [state.md](references/state.md) | Behavioral | Altering object behavior when its internal state transitions. |
| [strategy.md](references/strategy.md) | Behavioral | Defining a family of interchangeable algorithms. |
| [template-method.md](references/template-method.md) | Behavioral | Defining algorithm skeleton while deferring specific steps. |
| [visitor.md](references/visitor.md) | Behavioral | Separating algorithms from the object structures on which they operate. |

---

## 5. Success Validation

A design pattern application is successful only when:

- [ ] The **Parsimony Gate** was evaluated: a simpler language primitive (function, closure, module, built-in) was explicitly considered and proven inadequate.
- [ ] A **concrete variation axis** or maintenance problem is identified and documented.
- [ ] The consuming code's interface remains **deep and clean**—no plumbing or boilerplate leaked to callers.
- [ ] **Dependency direction** is preserved (dependencies point towards business rules).
- [ ] The pattern does not introduce needless classes when a single function suffices.
