# Modules Should Be Deep

> **Central thesis**: the best modules are those whose **interface is substantially simpler than their implementation**. A deep module provides powerful functionality behind a small, focused interface, hiding complexity from the rest of the system.

---

## When to consult

- When defining new modules, classes, services, packages, or public functions.
- When evaluating whether a decomposition creates too many (and excessively shallow) components.
- When reviewing a proposed interface to decide if it "pays for itself".

---

## 1. Modular Design

- The goal of modular design is to decompose a system into **relatively independent modules**, such that a developer only needs to understand a small fraction of the total system complexity to work on any single module.
- A "module" is any code unit with an **interface and an implementation**: a class, subsystem, service, function, or package.
- Total independence is impossible: modules interact by calling each other's functions, inevitably creating dependencies. The goal is to **minimize them**.

### Interface vs. Implementation

- **Interface**: everything a developer working in *another* module needs to know to use this one. Describes **what** the module does, not **how**.
- **Implementation**: the internal code that fulfills the promises of the interface.
- A developer working inside a module needs to understand its interface and implementation, plus the interfaces of any modules it calls. They do **not** need to understand the implementations of those other modules.

### Formal vs. Informal Interface Components

- **Formal**: explicitly specified in code (signatures, parameter names and types, return types, exceptions). Verified by the compiler or runtime.
- **Informal**: high-level behavior, side effects, call order constraints ("call `a` before `b`"), and invariants. Documented in comments and specifications, this is usually **larger and more complex** than the formal interface.
- A well-specified interface reduces **unknown unknowns**: it tells callers precisely what they need to know to use the module correctly.

### Multiple Implementations of an Interface

- When an interface has multiple implementations (adapters, drivers, providers, in-memory test doubles), **all must fulfill the complete contract**, formal and informal. Callers using the interface must not need to know which implementation they received.
- Any implementation requiring extra preconditions, offering fewer guarantees, throwing "not supported", or changing side effects **violates the contract**, even if function signatures match.
- The red flag is a caller inspecting the concrete type or origin of the implementation to decide how to behave. Every such branch represents internal implementation knowledge leaking outward. Absorb differences inside the implementation or via dedicated adapters instead of scattering checks across callers (see [pull-complexity-downwards.md](pull-complexity-downwards.md)).

---

## 2. Abstraction

- An abstraction is a **simplified view of an entity that omits unimportant details**. Modules provide abstractions through their interfaces.
- The more unimportant details omitted, the better. But a detail can only be omitted **if it is truly unimportant** to the caller.
- Two ways to fail:
  1. **Including unimportant details**: the abstraction becomes cluttered, inflating cognitive load for callers.
  2. **Omitting important details**: creates obscurity. Callers lack necessary information. This is a **false abstraction**: it looks simple on the surface, but is deceptively difficult to use correctly.
- Example: a file system hides disk block allocation algorithms; callers reading and writing files do not care. But the moment data hits durable non-volatile storage **does matter** in certain scenarios (e.g., a database needing crash-consistency guarantees), so the interface must expose an explicit `flush`/`fsync` mechanism.

---

## 3. Depth: The Rectangle Metaphor

```text
Deep Module                      Shallow Module
┌──────┐  ← interface (cost)     ┌──────────────────────┐ ← interface (cost)
│      │                         │                      │
│      │                         └──────────────────────┘
│      │  ← functionality          ↑ little functionality
│      │     (benefit)
│      │
└──────┘
```

- Area represents the delivered functionality (benefit). The top edge represents the interface (cost in complexity imposed on callers).
- **Depth = benefit ÷ cost.** The best modules deliver massive functionality through a compact interface.

### Canonical Examples of Deep Modules

- **Unix File I/O**: five fundamental system calls (`open`, `read`, `write`, `lseek`, `close`) with straightforward signatures. Behind them, the kernel encapsulates hundreds of thousands of lines: on-disk structures, directories, path resolution, permissions, block scheduling, buffer caching, and device drivers. This implementation evolved radically over decades without altering the interface.
- **Garbage Collectors**: have virtually **no interface**. They operate invisibly and actually *reduce* total system interface by eliminating explicit memory deallocation calls.

### Shallow Modules

- A shallow module has a relatively complex interface compared to the functionality it encapsulates. It contributes little to combating complexity: the benefit of not having to read the implementation is cancelled out by the cost of learning and navigating the interface.
- Example: a linked list class hiding only a few lines of pointer manipulation behind an interface almost as complex as the implementation itself.
- Extreme example of a shallow method:

  ```java
  private void addNullValueForAttribute(String attribute) {
      data.put(attribute, null);
  }
  ```

  Provides no abstraction whatsoever: the entire functionality is exposed in the interface. Thinking about calling the method is just as costly as thinking about the code it contains, while adding another symbol to learn and navigate.

---

## 4. "Classitis"

- Conventional wisdom often pushes classes (and functions) to be as small as possible: "split anything over N lines".
- Taken to extremes, this causes **classitis**: an explosion of tiny, shallow classes. Each looks simple in isolation, but the system as a whole becomes drastically more complex: interfaces proliferate, and every interface carries a cost. It also breeds boilerplate pass-through code.
- Example: in classic Java I/O, reading serialized objects from a file required chaining three separate stream classes:

  ```java
  FileInputStream fileStream = new FileInputStream(fileName);
  BufferedInputStream bufferedStream = new BufferedInputStream(fileStream);
  ObjectInputStream objectStream = new ObjectInputStream(bufferedStream);
  ```

  Buffering, which virtually every caller needs, had to be explicitly requested. Forgetting it caused silent performance degradation. Buffering should have been the **default**, with an option to disable it for the rare cases where it wasn't wanted.
- **Principle**: interfaces should make the **common case as simple as possible**. If nearly every user of a class requires a feature, provide it by default.
- By contrast, Unix designers made the common case simple: sequential I/O is default; random access is available (`lseek`), but sequential readers never need to think about it.

---

## Red Flags

- **Shallow module**: interface complexity is comparable to implementation complexity.
- A feature required by almost every caller that must be manually configured or activated.
- Clusters of small classes or functions that only make sense together, each with its own interface.
- A simple formal interface masking a complex informal interface (undocumented order requirements, hidden side effects).
- An abstraction that omits information callers genuinely need (false abstraction).
- Callers inspecting concrete types or origins to branch on behavior.

---

## How to Apply

For each proposed module:

1. **Write the interface first** (signatures + informal behavior in 1–2 sentences). If you cannot describe it succinctly, the module boundary is likely flawed.
2. **Compare interface and implementation**: is the interface dramatically simpler than what it hides? If not, consider merging with a peer module or moving more responsibility inside.
3. **Identify the common case** and ensure it is effortless to use without mandatory configuration rituals.
4. **Count total interfaces** across the entire design, not just lines per file: fewer, deeper modules are consistently superior to a sprawling collection of shallow ones.
5. **Verify the abstraction**: was critical information omitted? Were trivial details exposed?

When presenting to the human, format each module as an interface card (via [`visualize-it`](../../visualize-it/SKILL.md)): what it promises, what it encapsulates, and why it qualifies as deep.

---

## Relationships

- What makes a module deep is the knowledge it encapsulates: [information-hiding.md](information-hiding.md).
- General-purpose interfaces tend to be deeper: [general-purpose-modules.md](general-purpose-modules.md).
- When to split or combine modules: [together-or-apart.md](together-or-apart.md).
- Exceptions are part of the interface and make it shallower: [define-errors-out-of-existence.md](define-errors-out-of-existence.md).
- Ports decoupling business rules from infrastructure, and their swappable implementations: [dependency-direction.md](dependency-direction.md).
