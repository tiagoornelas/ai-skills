# General-Purpose Modules Are Deeper

> **Central thesis**: the optimal design is to make modules **"somewhat general-purpose"**: functionality addresses immediate needs, but the **interface** is general enough to support multiple uses. General-purpose interfaces tend to be simpler, deeper, and hide more information than specialized interfaces.

---

## When to consult

- When designing the interface for a new module or API.
- When an interface grows a dedicated method for each UI view or client use case.
- When noticing conditional branches scattered to handle ad-hoc special cases.
- When deciding between "solving only today's narrow problem" and "building a bloated generic framework".

---

## 1. Specialize or Generalize?

- **Specialized approach**: implement exclusively what is needed today. Rationale: future requirements are unknown, and premature generalization breeds dead code.
- **General-purpose approach**: build a comprehensive engine that solves a vast spectrum of hypothetical problems. Rationale: might save time down the road.
- The recommended middle ground: **somewhat general-purpose**.
  - **Functionality** strictly reflects current requirements (never build speculative features).
  - The **interface** avoids coupling to immediate callers; it remains general enough to serve multiple call sites.
  - The interface must be natural and ergonomic for today's needs, without being narrow-minded.
- The most crucial payoff is not future reuse: it is that **a general interface is simpler and deeper right now**.

---

## 2. Canonical Example: A Text Editor's Document Model

In a graphical text editor, the class managing document content (storage and modification) can be architected in two contrasting ways.

### Specialized Interface (Anti-pattern)

Methods that mirror UI user actions:

```java
void backspace(Cursor cursor);
void delete(Cursor cursor);
void deleteSelection(Selection selection);
```

- Every new user interface gesture forces a new method on the text class.
- The text model becomes contaminated with UI concepts (cursors, selections, keyboard keys): information leakage.
- Yields a proliferation of shallow methods, each tied to a single UI widget.
- UI developers face a bloated API surface to learn.

### Somewhat General-Purpose Interface (Superior)

Fundamental text operations agnostic of UI concepts:

```java
void insert(Position position, String newText);
void delete(Position start, Position end);
Position changePosition(Position position, int numChars);
```

User actions are implemented cleanly **on top of** this core abstraction:

```java
// backspace
text.delete(text.changePosition(cursor, -1), cursor);

// delete (Del key)
text.delete(cursor, text.changePosition(cursor, 1));
```

- Fewer methods, each significantly more powerful: the class is much deeper.
- The text engine knows nothing about UI widgets or key bindings: clean decoupling and information hiding.
- UI logic becomes more **obvious**: intent ("delete the character preceding the cursor") is directly expressed.
- Adding UI features requires zero modifications to the text engine.

---

## 3. Generality Leads to Better Information Hiding

- The general approach establishes clean boundaries: the text model does not need to know about cursors or keybindings; the UI does not need to know how text is stored or indexed.
- Specialized methods for each UI edge case tend to be shallow and leak caller concepts downward.

---

## 4. Guiding Questions for Finding the Sweet Spot

1. **What is the simplest interface that covers all current needs?** Reducing method count without sacrificing capability almost always makes an interface more general. *Caution*: reducing methods by inflating parameter counts with flags does not simplify.
2. **In how many situations will this method be used?** If a method is crafted for **only one specific call site**, it is a red flag for over-specialization. Check whether multiple specialized methods can be unified into a single general abstraction.
3. **Is this API ergonomic for current needs?** If callers must write extensive boilerplate to accomplish standard tasks, the abstraction is missing required capabilities. Example: if deleting a text range requires looping over a single-character delete method, the interface is excessively low-level for real-world usage.

---

## 5. Pushing Specialization Upward (and Downward)

- Systems inevitably contain specialized logic. The objective is not to eliminate it, but to **isolate it** from general-purpose machinery.
- Typically, specialization belongs **at the top**: application/UI layers orchestrate specific features using the general mechanisms of lower layers.
- Occasionally, specialization goes **to the bottom**: hardware device drivers, for instance, are highly specialized, but live behind general OS interfaces that upper layers consume transparently.
- Example: an **undo/redo** manager. The general engine tracks action history and handles stack traversal. Specific actions (insert text, alter formatting) provide their own handlers for applying/reverting changes. The core engine knows nothing about text manipulation; text actions know nothing about history stack mechanics.

### Defining Out Special Cases

- Specialization often manifests as scattered edge-case branches. To eliminate them: see [define-errors-out-of-existence.md](define-errors-out-of-existence.md) (Section 3).

---

## Red Flags

- **Special-general mixture**: a general-purpose mechanism contains hardcoded logic tailored to a single specific caller.
- A public method designed for exactly one caller.
- A lower-level module interface referencing upper-layer concepts (e.g., a data model referencing "buttons", "views", or "mouse cursors").
- Every new upper-layer feature requires adding methods to lower layers.
- Conditional branches for special cases scattered throughout core flows.

---

## How to Apply

1. List the **current use cases** of the module.
2. Design the **smallest interface** that completely fulfills all of them, speaking strictly the module's own domain vocabulary.
3. Draft pseudo-code showing **how each current use case consumes this interface**. If any flow is overly verbose, refine the abstraction.
4. Identify specialized details and push them to the layer where they originate (typically upper layers).
5. Search for special cases that can be eliminated by expanding the definition of the normal case.
6. **Do not implement** speculative capabilities: generalize the interface, not the feature scope.

---

## Relationships

- Why smaller, general interfaces are superior: [deep-modules.md](deep-modules.md).
- Text models and UI as distinct layers with different abstractions: [different-layer-different-abstraction.md](different-layer-different-abstraction.md).
- Decoupling general from specialized logic also guides module partitioning: [together-or-apart.md](together-or-apart.md).
- Eliminating special cases follows the same principles as eliminating errors: [define-errors-out-of-existence.md](define-errors-out-of-existence.md).
- Exception at the infrastructure boundary: ports speak the domain's business vocabulary: [dependency-direction.md](dependency-direction.md).
