# Code Should Be Obvious

> **Central thesis**: obscurity is one of the two root causes of software complexity. Obvious code is code that a developer can read quickly without friction, where their **initial assumptions about behavior are consistently correct**. Software must be engineered for ease of **reading**, not ease of writing.

---

## When to consult

- When establishing names for modules, types, operations, and public fields.
- When choosing public data structures (DTOs, return types, domain events, messages).
- When evaluating event-driven architectures, callbacks, or indirect control flows.
- When verifying whether a proposed design communicates intent clearly to developers who were not in the room.

---

## 1. What "Obvious" Means

- In obvious code, readers do not need to expend mental effort deciphering intent, and are unlikely to introduce regressions when modifying it.
- In non-obvious code, readers spend excessive time deciphering mechanics, or make incorrect assumptions that introduce bugs.
- **Obviousness lives in the mind of the reader.** If a reader finds code non-obvious, it *is* non-obvious, no matter how clear it felt to the author. Do not argue; identify what confused the reader and clarify the design.
- Code achieves obviousness when it provides all **necessary context** without cognitive leaps, and remains **consistent with developer expectations**.

---

## 2. What Makes Code Obvious

- **Precise naming**: across contracts (modules, types, operations, public properties), accurate names clarify intent and reduce the need for explanatory text. If a name is hard to choose, the underlying concept is usually muddled. Naming principles: [naming.md](../../coding/references/naming.md).
- **Consistency**: similar things look similar; different things look different. When readers recognize established patterns, they confidently draw conclusions without exhaustive re-analysis. Naming conventions, code styling, interface shapes, design patterns, and invariants must remain consistent.
- **Self-explaining code**: when the code does not state its intent, reshape it (names, types, tests) instead of commenting; the few comments that survive are listed in [comments.md](../../coding/references/comments.md).

---

## 3. What Makes Code Obscure

- **Event-driven indirection**: control flow is difficult to trace because event handlers are not invoked directly; they are called indirectly by a publish/subscribe bus. It is rarely obvious *when* or *by whom* an event handler is invoked. **Countermeasure**: make the trigger visible in code: name each handler for its trigger and register it where the event is declared.
- **Generic containers**: structures like `Pair<Integer, Boolean>` or generic tuples bundle values without naming them. Callers must parse `.first` and `.second` (or `[0]`, `[1]`), which convey zero semantic meaning. Code is easier to **write**, but much harder to **read**. Always define named domain types with self-documenting fields.
- **Type discrepancies between declaration and allocation**: e.g., declaring a variable as `List<Message>` while instantiating a custom synchronized collection. Readers scan the interface type and may miss critical concurrency or performance characteristics. When the concrete type dictates observable behavior, make it obvious.
- **Violating reader expectations**: e.g., a `main` entry point that returns immediately while background threads continue running detached. Readers expect process termination when `main` completes. When code defies standard expectations, eliminate the anomaly or make it visible in names and types.

---

## 4. Guiding Principle

- Two primary avenues to make code obvious:
  1. **Reduce required context** (clean abstractions, eliminating special cases, deep information hiding).
  2. **Leverage existing knowledge** (consistency with established project patterns and industry idioms), so readers need no new orientation.
- When those are insufficient, **provide missing knowledge directly in code** (expressive types, descriptive names, tests).

---

## Red Flags

- **Non-obvious code**: purpose and mechanics cannot be grasped upon a quick first read.
- **Vague or elusive names** (signals an ambiguous design concept).
- Untyped tuples, generic pairs, and raw nested maps in public contracts.
- Event buses, hooks, or callbacks whose trigger origins and sequencing are not visible in code.
- Inconsistency: the same concept referred to by different terms, or identical names applied to distinct concepts.
- Surprising side effects or unannounced background threads.

---

## How to Apply

When completing a design, review it **as a reader**, not as the author:

1. **Names**: does every module, type, method, and property carry a clear, unambiguous name? Was any name difficult to settle on? (If so, rethink the concept.)
2. **Consistency**: does the design adhere strictly to existing codebase conventions? Where it deviates, is the deviation intentional and recorded where the project keeps decisions?
3. **Strong typing in contracts**: replace generic tuples and primitives with descriptive types.
4. **Indirect flows**: is the trigger sequence for every event, hook, and callback visible in code?
5. **Surprises**: does any behavior contradict standard expectations? Eliminate it or make it explicit in code.
6. **The outsider test**: could a developer who was not in the design conversation understand the system purely from the design brief's change card, flow, and contracts? If extensive verbal explanation is needed, treat that as a design defect.

---

## Relationships

- Obscurity as a root cause of complexity: [nature-of-complexity.md](nature-of-complexity.md).
- Minimizing required context via abstraction: [deep-modules.md](deep-modules.md) and [information-hiding.md](information-hiding.md).
- The comments that survive: [comments.md](../../coding/references/comments.md).
