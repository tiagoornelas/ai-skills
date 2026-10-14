# Singleton

> **Creational Pattern** — Refactoring Guru Catalog
> Lets you ensure that a class has only one instance, while providing a global access point to this instance.

---

## 1. Intent & Core Mechanism

Ensures a class has only a single instance in the application lifetime (e.g., database connection pool, logger, hardware controller) and provides a global access method (typically `getInstance()`), hiding the private constructor.

---

## 2. When Justified

- Exactly one instance of a resource must be available to clients across the system, and creating multiple instances would cause hardware conflicts, data corruption, or severe resource exhaustion.
- You need strictly controlled access to that single instance.

---

## 3. Parsimony Filter & Simpler Alternatives

> **WARNING: Singleton is considered an anti-pattern in modern software engineering when used simply as a glorified global variable.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| Node.js, Python, or Go module systems | Module-scoped instantiation (`export const db = new DatabaseClient()`). Modules are cached singletons by default. |
| Dependency Injection (DI) | Registering the service as a `Singleton` scope in the DI container. This preserves testability and constructor injection. |
| Global configuration | Passing immutable configuration objects explicitly down the call tree or via context. |

**The Trap**: Mutable singletons destroy unit testing by leaking state between tests, hiding dependencies, and creating thread-safety / concurrency race conditions.

---

## 4. Structure & Contracts

```text
┌───────────────────────────────┐
│           Singleton           │
├───────────────────────────────┤
│ - instance: Singleton (static)│
├───────────────────────────────┤
│ - constructor() (private)     │
│ + getInstance(): Singleton    │
│ + businessLogic(): void       │
└───────────────────────────────┘
```

- **private constructor**: Prevents direct instantiation with `new`.
- **static instance**: Holds the single cached reference.
- **static getInstance()**: Lazy or eager accessor providing access to the unique instance.

---

## 5. Downsides & Accidental Complexity

- **Violates Single Responsibility Principle**: The pattern solves two problems simultaneously: managing its own lifecycle/uniqueness AND performing business logic.
- **Coupling & Untestability**: Callers become tightly coupled to the concrete Singleton class; mocking it in isolated unit tests requires dirty reflection or monkey-patching.
- **Multithreading hazards**: Requires careful double-checked locking or synchronization in multi-threaded environments to avoid creating duplicate instances.
