# Iterator

> **Behavioral Pattern** — Refactoring Guru Catalog
> Lets you traverse elements of a collection without exposing its underlying representation (list, stack, tree, graph, etc.).

---

## 1. Intent & Core Mechanism

Extracts the traversal behavior of a collection into a separate object called an **iterator**. The iterator tracks the current position and how many elements remain, providing a standardized traversal protocol (`hasNext()`, `next()`).

---

## 2. When Justified

- Your collection has a complex data structure under the hood (e.g., B-Tree, Graph, SkipList), but you want to hide its complexity from clients for security or convenience.
- You need multiple independent traversals running simultaneously over the same collection.
- You want to provide a uniform interface for traversing diverse data structures.

---

## 3. Parsimony Filter & Simpler Alternatives

> **WARNING: Almost all modern programming languages have native iterator protocols and generator functions. Do not implement manual Iterator classes unless building low-level custom collection primitives.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| JavaScript / TypeScript | Generators (`function* () { yield item; }`) and the `[Symbol.iterator]` protocol (`for..of`). |
| Python | Generator functions (`yield`) and `__iter__()` / `__next__()`. |
| C# | `yield return` and `IEnumerable<T>`. |
| Standard collections | Built-in array traversal methods: `.forEach()`, `.map()`, `.filter()`. |

**The Trap**: Writing verbose `MyCustomIterator` classes with manual index counters when a simple 3-line generator function produces an identical, idiomatic iterator.

---

## 4. Structure & Contracts

```text
┌─────────────────────────┐          ┌─────────────────────────┐
│  IterableCollection     │          │   Iterator (Contract)   │
├─────────────────────────┤          ├─────────────────────────┤
│ + createIterator(): Iter│─────────>│ + getNext(): Element    │
└────────────▲────────────┘          │ + hasMore(): boolean    │
             │                       └───────────▲─────────────┘
┌────────────┴────────────┐                      │
│   ConcreteCollection    │          ┌───────────┴─────────────┐
├─────────────────────────┤          │    ConcreteIterator     │
│ + createIterator(): Iter├─────────>│ - collection: Col       │
└─────────────────────────┘          │ - iterationState: int   │
                                     └─────────────────────────┘
```

- **Iterator**: Defines traversal operations (`getNext()`, `hasMore()`).
- **ConcreteIterator**: Implements traversal algorithm for a specific collection and tracks state.
- **IterableCollection**: Declares a factory method for getting iterators compatible with the collection.

---

## 5. Downsides & Accidental Complexity

- **Overkill for simple data structures**: Using an iterator pattern for standard sequential arrays or lists is redundant and slow.
- **Concurrent modification hazards**: If the collection is modified while an iterator is actively traversing it, unpredictable errors or invalid states occur unless fail-fast checks are implemented.
