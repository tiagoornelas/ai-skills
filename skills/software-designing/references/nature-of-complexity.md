# The Nature of Complexity

> **Central thesis**: the greatest limitation in software development is our ability to understand systems. Complexity is **anything related to the structure of a software system that makes it hard to understand and modify**. The work of design is, above all, to recognize complexity and fight it.

---

## When to consult

- Before evaluating any design: this is the foundational vocabulary used across all other design references.
- When justifying to the human **why** one alternative is superior to another.
- When diagnosing code that is "hard to touch" and needing to name the problem with precision.

---

## 1. Practical Definition

Complexity is not size or technical sophistication. It is something the developer **experiences** when trying to achieve a goal:

- If it is hard to understand how a piece of code works, or if a small improvement requires outsized effort, the system is complex.
- If it is easy to understand and modify, the system is simple, even if it is large and performs sophisticated tasks.
- A large, sophisticated system can be simple to work in; a tiny system can be complex.

### Complexity is weighted by activity

Total system complexity can be modeled as the sum of complexity across parts, **weighted by the fraction of time developers spend working in that part**:

```text
C = Σ (c_p × t_p)
```

Key takeaways:

- Isolating complexity in a place where it is rarely seen is **nearly as good as eliminating it**.
- An ugly piece of code that is never touched contributes very little; a mildly confusing piece touched daily contributes enormously.

### The reader is the judge

Complexity is more evident to the reader than to the author. If you wrote code that feels simple to you, but others find it complex, **it is complex**. The role of design is to make code easy to work with **for others**, not for yourself.

---

## 2. The Three Symptoms

| Symptom | Definition | Typical Example |
| :--- | :--- | :--- |
| **Change amplification** | A seemingly simple change requires edits in many different places. | The banner color of a site is explicitly repeated across every template; changing it requires editing all of them. |
| **Cognitive load** | How much a developer needs to know to complete a task. More information to absorb = more time and higher bug risk. | A memory allocation API requiring callers to explicitly free each internal block, or a function with numerous interdependent parameters. |
| **Unknown unknowns** | It is not obvious which parts of the code must change, or what information is needed to make the change correctly. | After centralizing the banner color, some pages use a darkened variation computed ad-hoc; nothing indicates they also need updating. |

- **Unknown unknowns are the worst symptom of complexity.** With change amplification you at least know what to edit; with cognitive load you know what to read. With unknown unknowns, you don't know what you don't know, and you only find out when a bug surfaces.
- **Fewer lines of code does not imply lower cognitive load.** An approach requiring more lines can be simpler if it reduces what the developer must hold in their head.
- A paramount goal of good design is to make the system **obvious**: the developer quickly guesses what to do, and guesses correctly (see [obvious-code.md](obvious-code.md)).

---

## 3. The Two Causes

Complexity is caused by **dependencies** and **obscurity**.

### Dependencies

- A dependency exists when a piece of code **cannot be understood and modified in isolation**: it relates to other code that must be considered or modified concurrently.
- Example: a method signature creates a dependency between its implementation and every caller; changing the signature forces updates to all callers. A network protocol couples senders and receivers.
- Dependencies are fundamental to software and **cannot be eliminated completely**. The goal is to **minimize the number** of dependencies and **make remaining ones simple and obvious**.

### Obscurity

- Occurs when **important information is not obvious**.
- Examples: a variable name so generic that it carries no meaning (`time`, `data`); an undocumented unit of measurement; an invisible dependency between two modules; **inconsistency** (the same term used for different concepts, or the same operation done in disparate ways).
- Obscurity goes hand-in-hand with dependencies: dependencies frequently exist without being obvious.
- **The need for extensive documentation is often a warning sign that the design is suboptimal.** The best way to reduce obscurity is to simplify the design; documentation comes after.

### Cause → Symptom Map

```text
Dependencies ──► change amplification
             └─► cognitive load
Obscurity    ──► unknown unknowns
             └─► cognitive load
```

---

## 4. Complexity is Incremental

- Complexity rarely results from a single catastrophic mistake. It **accumulates** from hundreds or thousands of small dependencies and obscurities.
- Individually, each shortcut seems harmless ("it's just one extra dependency"). Together, they make the system rigid and fragile.
- Because it is incremental, it is difficult to control and easy to rationalize. This demands a **zero-tolerance mindset**: treating every small piece of added complexity as a real problem.
- Once accumulated, complexity is notoriously hard to remove: fixing a single dependency or obscurity barely moves the needle.

---

## Red Flags

- The same decision or value appears in multiple places (change amplification).
- Using a module requires understanding its internal implementation details (cognitive load).
- A change "worked" but unexpectedly broke an unrelated area (unknown unknown).
- Code can only be understood by reading distant, separate code (non-obvious dependency).
- Explaining a design requires an extensive document to make sense (obscurity).

---

## How to Apply

For every design alternative, examine and record:

1. **Amplification**: what likely future changes would require editing multiple places?
2. **Cognitive load**: what must an external caller know to use this module? Can this be reduced?
3. **Unknown unknowns**: are there dependencies not visible in the code or interface?
4. **Dependencies**: how many are introduced, and is each one simple and obvious?
5. **Obscurity**: are names, units, invariants, and call orders unmistakably clear where needed?
6. **Usage weighting**: is remaining complexity concentrated in rarely touched components?

Use these terms when communicating trade-offs to the human: they are precise and objective.

---

## Relationships

- The mindset required to combat incremental complexity: [strategic-programming.md](strategic-programming.md).
- Primary structural defenses against dependencies: [deep-modules.md](deep-modules.md) and [information-hiding.md](information-hiding.md).
- Primary defense against obscurity: [obvious-code.md](obvious-code.md).
