# Code Smells and Refactorings

> **Central thesis**: a code smell is a **signal** that code has become harder to read or modify than necessary. It is not an absolute prohibition: remediation is only warranted when there is a **concrete scenario** where it causes harm (a probable bug, an expensive future change, or reader confusion). This catalog governs the Agent Layer, below contracts. Module architecture and interface design belong to [`software-designing`](../../software-designing/SKILL.md), which **takes precedence** in any conflict.

---

## When to consult

- In the "refactor" phase following green tests, and during preparatory refactorings.
- When reviewing code below contracts, whether written by yourself or peers.

---

## 1. How to Use This Catalog

- Each smell provides: **signal** (how to recognize it), **why it hurts**, **remediations** (canonical refactoring patterns), and **when not to apply**.
- **Prioritize by impact**, in this order:
  1. bug risk (shared mutable state, commands disguised as queries, missed edge cases);
  2. change cost (likely subsequent changes touching multiple files);
  3. readability (unnecessary cognitive friction for maintainers).
- If you cannot articulate the concrete failure scenario in a single sentence, **discard the finding**.
- Every refactoring must adhere to [refactoring-principles.md](refactoring-principles.md). If a refactoring would alter a public contract or module boundary, do not apply it unilaterally: escalate to the Human Layer.

---

## 2. State and Data

| Smell | Signal | Why it Hurts | Remediations | Do Not Apply When |
| :--- | :--- | :--- | :--- | :--- |
| **Mutable Data** | Variable, field, or structure mutated in multiple places, or mutated by a callee that received it for reading. | Hidden coupling: mutating state in one place breaks distant code without warning. | *Encapsulate Variable*, *Separate Query from Modifier*, *Remove Setting Method*, *Change Reference to Value* | Local short-lived variables where mutation is obvious. |
| **Global Data** | Global variable, mutable singleton, or module state accessible from anywhere. | Any line of code can mutate it; impossible to trace who modified what. | *Encapsulate Variable*, then restrict scope | Immutable constants. |
| **Split-Personality Variable** | The same variable stores different values for distinct purposes across a function (excluding loop accumulators). | Readers must track which role the variable plays at each line. | *Split Variable* | — |
| **Stored Derived Value** | Field caching a value computable from existing state, updated manually. | Prone to falling out of sync with primary state. | *Replace Derived Variable with Query* | Computation is measurably expensive and profiled. |
| **Temporary Field** | Class field populated only during specific operations, empty the rest of the time. | Callers cannot tell when the field holds valid state. | *Extract Class* (internal), *Introduce Special Case*, *Move Function* | — |
| **Exposed Collection** | Getter returns an internal mutable collection directly to callers. | Owner loses control over its internal invariants. | *Encapsulate Collection* | Collection is immutable or a defensive copy. |
| **Inverted Reference vs. Value** | Shared mutable reference that should be an immutable value (money, date range), or duplicated entities that should share identity. | Unintended mutations bleed outward, or changes fail to propagate where expected. | *Change Reference to Value*, *Change Value to Reference* | — |
| **Unnecessary Setter** | Property that should only be initialized upon creation provides a public setter. | Invites inconsistent state mutation after initialization. | *Remove Setting Method* | — |

---

## 3. Conditionals

| Smell | Signal | Why it Hurts | Remediations | Do Not Apply When |
| :--- | :--- | :--- | :--- | :--- |
| **Complex Conditional** | Convoluted boolean expression or bloated branches whose purpose is obscure. | Readers must mentally decipher the boolean formula. | *Decompose Conditional*, *Consolidate Conditional Expression* | Expression is already concise and obvious. |
| **Deep Nesting for Exceptions** | Happy path is buried inside deeply nested `if` blocks. | Obscures the primary execution flow. | *Replace Nested Conditional with Guard Clauses* | Branches represent equal alternatives with no primary path. |
| **Repeated Special Case** | Identical defensive check (null, missing, empty) repeated across multiple callers. | Future callers can easily forget the defensive check. | *Introduce Special Case* (see [define-errors-out-of-existence.md](../../software-designing/references/define-errors-out-of-existence.md)) | Only a single isolated call site exists. |
| **Implicit Assumption** | Code depends on an unstated precondition without runtime verification. | Unknown unknown for future maintainers. | *Introduce Assertion* | Condition depends on external user input: that is validation, not assertion. |
| **Repeated `switch`** | The same `switch` or `if/else` ladder over a type discriminator repeated across **multiple** sites. | Adding a new variant requires hunting down and updating every ladder. | *Replace Conditional with Polymorphism* | An isolated, single clean switch statement: keep it. Polymorphism for a single instance creates shallow classes. |

---

## 4. Functions

Hidden side effects, queries mutating state, output parameters, flag arguments, long parameter lists, and extraction criteria: see [functions.md](functions.md).

---

## 5. Code Placement

| Smell | Signal | Why it Hurts | Remediations | Do Not Apply When |
| :--- | :--- | :--- | :--- | :--- |
| **Feature Envy** | Method invokes more methods and properties on another object than on its own class. | Logic is decoupled from the data it operates on (see [information-hiding.md](../../software-designing/references/information-hiding.md)). | *Move Function*, *Move Field* | Method deliberately coordinates data from multiple objects. If moving crosses a module boundary: Human Layer. |
| **Message Chain** | `a.b().c().d()` repeated across multiple callers. | Callers become coupled to the internal navigation structure. | *Hide Delegate*, *Move Function* | Chain appears only once. Creating delegation adds pass-through methods: only justified when hiding structure from many callers. |
| **Misplaced Statements** | Related logic scattered; declarations far from usage sites; boilerplate repeated before/after calls. | Readers must manually assemble fragmented context. | *Slide Statements*, *Move Statements into Function*, *Move Statements to Callers*, *Replace Inline Code with Function Call* | — |

---

## 6. Control Flow

| Smell | Signal | Why it Hurts | Remediations | Do Not Apply When |
| :--- | :--- | :--- | :--- | :--- |
| **Multi-Tasking Loop** | A single loop computing multiple unrelated outcomes simultaneously. | Difficult to understand and modify tasks independently. | *Split Loop*, *Replace Loop with Pipeline* (if idiomatic to repository) | Profiled, measured performance demands a single pass. |
| **Dead Code** | Unreachable statements, unused parameters, or dead branches. | Wastes mental bandwidth on irrelevant logic. | *Remove Dead Code* (git preserves history) | — |
| **Unnamed Expression** | Complex sub-expression whose semantic meaning must be deduced. | Cognitive load. | *Extract Variable*; inversely, *Inline Variable* when the name adds zero context | — |
| **Convoluted Algorithm** | Complicated custom logic implementing something with a simpler idiomatic solution (including standard library utilities). | Unnecessary cognitive friction without benefit. | *Substitute Algorithm* | — |

---

## 7. Smells Governed by `software-designing`

These smells originate from classic refactoring catalogs, but here are governed strictly by **`software-designing` criteria**:

- **Long Function**: governed by independence criteria in [functions.md](functions.md). Length alone is not a smell.
- **Duplicate Code**: merge only if duplicates represent the exact same design decision and change for the exact same reason. See [together-or-apart.md](../../software-designing/references/together-or-apart.md).
- **Split Phase**: justified when phases handle disjoint knowledge (parsing input vs. computing business result). If phases share identical underlying knowledge (same wire format), it is temporal decomposition. See [information-hiding.md](../../software-designing/references/information-hiding.md).
- **Speculative Generality**: eliminate unused hooks (unused parameters, dead abstract classes). This does not contradict somewhat general-purpose interfaces serving current needs. See [general-purpose-modules.md](../../software-designing/references/general-purpose-modules.md).

---

## 8. Covered by `software-designing`: Do Not Duplicate

| Classic Smell | Architectural Lens |
| :--- | :--- |
| Mysterious Name | [naming.md](naming.md) (internal names) and [obvious-code.md](../../software-designing/references/obvious-code.md) (contract names) |
| Primitive Obsession | [obvious-code.md](../../software-designing/references/obvious-code.md) |
| Middle Man, Lazy Element | [deep-modules.md](../../software-designing/references/deep-modules.md), [different-layer-different-abstraction.md](../../software-designing/references/different-layer-different-abstraction.md) |
| Data Class, Insider Trading | [information-hiding.md](../../software-designing/references/information-hiding.md) |
| Divergent Change, Shotgun Surgery, Large Class | [together-or-apart.md](../../software-designing/references/together-or-apart.md), [nature-of-complexity.md](../../software-designing/references/nature-of-complexity.md) |
| Refused Bequest, Alternative Classes with Different Interfaces | [deep-modules.md](../../software-designing/references/deep-modules.md) (multiple implementations of an interface) |

At module or contract scale, these smells represent architectural decisions belonging to the Human Layer. Internal variable/function naming is the sole exception: detailed in [naming.md](naming.md).

---

## 9. Excluded From This Catalog

Do not report or apply, even if present in classic catalogs:

- **Comments as a smell.** What and how to document is detailed in [comments.md](comments.md).
- ***Replace Function with Command*.** Introduces a shallow class without encapsulating meaningful complexity.

---

## Relationships

- Rules for safe refactoring: [refactoring-principles.md](refactoring-principles.md).
- Functions, naming, comments, and error handling: [functions.md](functions.md), [naming.md](naming.md), [comments.md](comments.md), [error-handling.md](error-handling.md).
- Symptoms and root causes of complexity: [nature-of-complexity.md](../../software-designing/references/nature-of-complexity.md).
- Architectural design lenses taking precedence: [`software-designing`](../../software-designing/SKILL.md).
