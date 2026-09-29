# Better Together or Apart?

> **Central thesis**: the fundamental question of software design is whether two capabilities belong together or in separate places. The goal is to **reduce total system complexity**, not the complexity of any single piece in isolation. Subdividing carries real costs and is not always justified.

---

## When to consult

- When deciding whether a responsibility belongs in a new module/class/service/function or an existing one.
- When reviewing decompositions with an excessive number of tiny components (or an overgrown monolith).
- When encountering duplicate code.

---

## 1. The Costs of Subdividing

Decomposing a system into smaller pieces seems to simplify each piece, but subdivision introduces brand-new complexity:

1. **More components**: harder to navigate, discover, and track. Each component introduces an interface, and every interface imposes cognitive load.
2. **Management boilerplate**: overhead required to wire components together (parameter marshaling, synchronization, communication glue).
3. **Distance**: related logic is physically separated. If components are truly independent, this separation is beneficial; if they are coupled, developers must juggle between files, and subtle dependencies can be easily missed.
4. **Duplication**: logic once unified in one place can become duplicated across subdivided components.

Bringing related logic together is generally beneficial; grouping unrelated concerns together is detrimental.

---

## 2. When to Bring Together

Signals that two pieces of logic should live together:

- **Shared information**: both depend on the same underlying knowledge. Example: reading an HTTP request and parsing its headers both depend on HTTP wire format; splitting them causes information leakage.
- **Used together bidirectionally**: callers using one almost invariably use the other, and vice versa. The relationship must be **bidirectional**. Example: a disk block cache almost always accompanies disk access, and the cache is only used with disk access.
- **Conceptual overlap**: both fall under a cohesive higher-level abstraction (e.g., substring search and regex search are both "text search").
- **Hard to understand one without reading the other.**

### Merge if it Simplifies the Interface

- When two modules are combined, the resulting unified interface is often **simpler** than the sum of the two original interfaces. This occurs frequently when modules implement facets of a single solution.
- Example: integrating buffering directly into a file reader makes buffering automatic, removing the need for callers to even know buffering exists.
- Merging also eliminates parameter passing between the two modules.

### Merge to Eliminate Duplication

- When the same code pattern appears repeatedly, the right abstraction has likely not been discovered yet.
- **Applies strictly when duplicates represent the same underlying design decision**: identical domain knowledge that changes for the exact same business reason. In this case, duplication is information leakage and must have a single owner.
- Code that looks **similar purely by coincidence**, in modules that evolve for independent reasons, is not duplicate code. Forcing them together creates an artificial dependency: a change requested by one domain contaminates the other. Keep coincidental duplicates separate.
- Test: **"If one copy changes, does the other copy inevitably require the exact same change?"** If yes, merge. If no, or if uncertain, keep them apart.
- Options: extract duplicated logic into a standalone function (justified if the logic is substantial and yields a clean interface); or restructure the flow so logic only needs to execute in one place.

---

## 3. When to Separate

### Decouple General-Purpose Machinery from Specialized Logic

- If a module encapsulates a mechanism capable of serving multiple purposes, it should expose **only** that general mechanism. Specialized logic tailored to a single use case belongs in higher layers.
- Example: an **undo/redo** manager. The action history stack (tracking items, moving forward and backward) is general and independent of action types. Details of how to revert specific actions (text edits, selections, styles) belong in the respective action handlers registered into the history. Mixing them would tightly couple the history stack to every feature in the application.
- In general, lower layers tend to be general-purpose, while upper layers are specialized.

### Examples of Poor Merging and Separation

- **Text cursor and selection**: initially implemented as separate classes, but intimately coupled (the cursor position is always one of the selection bounds). Callers had to manipulate both in tandem. Merging them into a single selection object simplified the system.
- **Dedicated logging class for network errors**: a standalone class with one method per error type, each invoked from a single call site. Separation hid nothing; it merely forced readers to jump across files to see what was logged. Better to log **directly at the site** where the error is detected.

---

## 4. Splitting and Merging Functions

- The same criteria apply within modules: **depth and independence matter far more than line count**. Guidelines for internal functions (when to extract, conjoined functions) are detailed in [functions.md](../../coding/references/functions.md).
- Splitting a **public** function into two, or merging two into one, alters the public contract: apply the interface simplification rule (Section 2) as a deliberate architectural decision.

---

## Red Flags

- **Repetition**: the same (or nearly identical) code appears in multiple places, representing the same design decision.
- Merging code that evolves for independent reasons merely because syntax looks similar.
- **Special-general mixture**: a general mechanism polluted with specialized logic for a specific caller.
- Separate modules that are always modified in lockstep.
- A new module that has only one caller and encapsulates zero hidden knowledge.

---

## How to Apply

For every proposed boundary (split or merge):

1. **Do they share information?** If yes, they belong together.
2. **Are they used together bidirectionally?** If yes, they belong together.
3. **Does merging simplify the public interface or eliminate data passing?** If yes, merge.
4. **Do they change for the same reason?** Similar code that changes for different reasons must stay separate.
5. **Is general machinery tangled with specialized use cases?** Separate them.
6. **Can each side be understood in complete isolation?** If not, the boundary is misplaced.
7. **Which choice reduces total system complexity?** This is the decisive test, not the size of any single file.

When presenting to the human, contrast the chosen boundary with the rejected alternative, stating the decisive criterion explicitly.

---

## Relationships

- Information sharing and leakage: [information-hiding.md](information-hiding.md).
- Depth as primary criterion: [deep-modules.md](deep-modules.md).
- Separating general-purpose from specialized logic: [general-purpose-modules.md](general-purpose-modules.md).
- Extracting and merging internal functions: [functions.md](../../coding/references/functions.md).
- The boundary between business rules and infrastructure details: [dependency-direction.md](dependency-direction.md).
