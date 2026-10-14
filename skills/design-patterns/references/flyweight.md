# Flyweight

> **Structural Pattern** — Refactoring Guru Catalog
> Lets you fit more objects into the available amount of RAM by sharing common parts of state between multiple objects instead of keeping all of the data in each object.

---

## 1. Intent & Core Mechanism

Separates an object's state into **intrinsic state** (constant, context-independent data shared across many objects) and **extrinsic state** (context-dependent, mutable data passed into flyweight methods from the outside). Shared intrinsic state is stored once in a Flyweight pool.

---

## 2. When Justified

- The program spawns a massive number of similar objects (tens/hundreds of thousands, e.g., particles, text editor glyphs, game entities).
- Available RAM is severely constrained and memory profiling confirms object allocation is the primary bottleneck.
- Objects contain duplicate state that can be extracted and shared across instances.

---

## 3. Parsimony Filter & Simpler Alternatives

> **WARNING: Premature Flyweight optimization makes code significantly harder to understand and maintain. Only apply after profiling proves severe memory pressure.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| Normal object counts (< 10,000 instances) | Plain standard objects with all state encapsulated together. |
| Repetitive string or enum values | String interning, enums, or numeric IDs. |
| Read-only database lookup entities | A simple cache or lookup Map/Dictionary. |

**The Trap**: Extracting state into flyweights without measuring memory usage, adding complex factory pools and passing extrinsic state everywhere for trivial memory savings.

---

## 4. Structure & Contracts

```text
┌──────────────────────────────────────────────┐
│               FlyweightFactory               │
├──────────────────────────────────────────────┤
│ - cache: Map<key, Flyweight>                 │
├──────────────────────────────────────────────┤
│ + getFlyweight(intrinsicState): Flyweight    │
└──────────────────────┬───────────────────────┘
                       │ returns shared
                       ▼
┌──────────────────────────────────────────────┐
│                  Flyweight                   │
├──────────────────────────────────────────────┤
│ - intrinsicState: Data (immutable, shared)   │
├──────────────────────────────────────────────┤
│ + operation(extrinsicState): void            │
└──────────────────────────────────────────────┘
```

- **Flyweight**: Contains the intrinsic state shared by many objects. Methods accept extrinsic state from callers.
- **FlyweightFactory**: Manages the pool of existing flyweights, returning existing instances or creating new ones.
- **Context / Client**: Stores or calculates the extrinsic state (unique to each instance, like coordinates) and passes it to the flyweight.

---

## 5. Downsides & Accidental Complexity

- **Inverted encapsulation**: Extrinsic state is shifted onto callers, forcing callers to track coordinates, sizes, or context.
- **CPU vs. RAM trade-off**: Trading RAM for CPU cycles, as context must be calculated and passed on every operation.
