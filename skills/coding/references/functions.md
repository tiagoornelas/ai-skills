# Functions

> **Central thesis**: a good function does **what its name promises**, can be understood **without reading other functions**, and features a signature that clearly indicates how to call it. Between the camp of tiny two-line functions and the camp of sprawling monolithic routines, the position here is balanced: **extraction aids comprehension when the extracted piece is independent**, and harms comprehension when it merely scatters logic that must be read together.

---

## When to consult

- When authoring or decomposing functions and methods.
- When reviewing functions in a code diff.
- *Scope note*: this reference covers internal functions. Splitting or merging public interfaces alters contracts: Human Layer (see [deep-modules.md](../../software-designing/references/deep-modules.md)).

---

## 1. Function Size and Extraction

| Dimension | Extreme A | Extreme B | This Standard |
| :--- | :--- | :--- | :--- |
| **Size** | Tiny functions of only a few lines. | Line count virtually never matters. | Line count alone is non-decisive. Independence is the governing test. |
| **"Do One Thing"** | Dogmatic rule, applied until nothing left to extract. | Irrelevant criterion. | The function does what its name promises, with zero hidden side effects. |
| **Abstraction Levels** | Single level of abstraction per function, strictly cascading. | Irrelevant criterion. | Mixed abstraction levels signal an opportunity for extraction, but independence decides. |

### When to Extract

- **Extract an independent subtask**: explicit inputs, explicit outputs, fully understandable without reading the caller, and vice-versa. This enhances readability even within deep modules.
- **Extract identical logic** that represents the same underlying domain decision (see [together-or-apart.md](../../software-designing/references/together-or-apart.md)).

### When Not to Extract

- **Conjoined logic**: if pieces communicate via shared mutable state or depend strictly on call sequence, extraction merely scatters complexity. The reader must keep jumping across functions.
- **Solely for size**: a long function with a clean signature and clear sequential blocks can remain unified.

```python
# Conjoined: each step depends on implicit state set by the previous
def process(order):
    self._validate(order)        # populates self._valid_items
    self._apply_discounts()      # reads self._valid_items, populates self._total
    self._record()               # reads self._total

# Independent: each part is self-contained and clear
def process(order):
    items = valid_items(order)
    total = total_with_discounts(items, order.customer)
    record_sale(order.id, total)
```

---

## 2. The Function Does What Its Name Promises

- **Zero hidden side effects**: `checkPassword()` that also creates a login session promises one thing and performs two. Either the name reflects both actions, or the side effect is removed.
- **Separate queries from commands**: a function returns information or mutates state, never both.
- **No output arguments**: return results rather than mutating input objects. If a function must mutate an object, it should be a method on that object.

---

## 3. Function Arguments

- **No dogmatic parameter limit.** A deep function may require several parameters. A high parameter count is a **signal** that:
  - parameters form a cohesive domain concept (bundle into a parameter object or pass an existing entity);
  - a parameter could be derived internally from others;
  - the function has too many responsibilities.
- **Never replace explicit parameters with hidden state** (setting instance fields prior to calling a method): the signature appears smaller, but methods become tightly coupled to execution order.
- **Avoid flag arguments**: boolean or mode literals (`true`, `"fast"`) passed to select internal behavior indicate two distinct functions tangled into one. Split them into separate functions, unless the flag originates from dynamic runtime data.

---

## Red Flags

- Function whose name fails to declare everything it does.
- Function returning a query value while mutating state.
- Output parameters mutated in place.
- Flag arguments passed as hardcoded literals.
- Conjoined functions that can only be understood by reading them in sequence.
- Function parameters replaced by stateful instance fields populated before invocation.
- An extraction that leaves the original function harder to understand than before.

---

## How to Apply

- **When writing**: design functions around explicit promises; extract strictly independent subtasks.
- **When reviewing**: hidden side effects, queries that mutate state, and conjoined functions have concrete maintenance risks and warrant correction. Splitting a readable sequential function solely due to line count lacks a concrete failure scenario: do not flag it.

---

## Relationships

- Depth matters more than length: [deep-modules.md](../../software-designing/references/deep-modules.md).
- Grouping vs. separating logic: [together-or-apart.md](../../software-designing/references/together-or-apart.md).
- Function naming rules: [naming.md](naming.md).
- Error handling in implementation: [error-handling.md](error-handling.md).
- Additional smells and refactoring patterns: [code-smells.md](code-smells.md).
