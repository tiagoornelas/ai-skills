# Design It Twice

> **Central thesis**: software design is hard, and it is improbable that the first idea for structuring a module or system represents the optimal design. Outcomes improve dramatically when developers consider **multiple options for every high-consequence decision**, ensuring those options are **radically different** from one another.

---

## When to consult

- Prior to locking in any major design decision: system decomposition, module interface, API contract, or core mechanism implementation.
- When the first idea "feels obvious" and no one has explored alternatives.
- When evaluating and contrasting alternative architectures.

---

## 1. The Core Principle

- For every high-impact design decision, never settle on the first idea. Sketch **two or more distinct approaches**, evaluate them side-by-side, and choose or combine the best elements.
- Alternatives must be **radically different**, not superficial variations of the same underlying concept. Minor tweaks explore very little of the design space. Radically different designs deepen understanding of the problem domain, even when they are ultimately discarded.
- This holds true even when one approach appears to be the only plausible path. Sketching an alternative—even one you suspect is sub-optimal—illuminates the specific strengths that make the preferred design superior.

---

## 2. Case Study: Text Model Interface

When designing the core text-handling class for a graphical editor, three radically different abstraction approaches emerge:

1. **Line-Oriented**: methods to insert, delete, and read entire lines.
2. **Character-Oriented**: methods to insert and delete individual characters.
3. **Range-Oriented**: operations over arbitrary character intervals that seamlessly span line boundaries.

Comparison:

- The line-oriented interface forces callers to handle line splitting and concatenation whenever operations cross line boundaries (e.g., deleting a block selection).
- The character-oriented interface forces callers to manage loops for multi-character edits (e.g., deleting a range character-by-character).
- The range-oriented interface accommodates both cleanly, proves significantly more ergonomic for consuming callers, and delivers a much more general-purpose abstraction.

---

## 3. Comparing Alternatives

- Enumerate candid **pros and cons** for each candidate design.
- The single most critical criterion for an interface is **ease of use for the higher-level software consuming it**.
- Additional evaluation factors:
  - Is one interface noticeably **simpler** than the other?
  - Is one interface more **general-purpose**?
  - Does one interface enable a **more efficient implementation**?
- Rigorous comparison almost always exposes hidden trade-offs and weaknesses in every option. This insight is immensely valuable in its own right.

### When No Alternative is Compelling

- Occasionally, none of the proposed alternatives are satisfying. In that case, use the discovered flaws to synthesize a **new design**.
- The optimal architecture is frequently a **hybrid combination** blending the best traits of disparate options, or a novel concept sparked by the comparative analysis.
- If no design feels right, it is a clear indicator that the problem domain is not yet well understood. Invest in clarifying requirements before committing to code.

---

## 4. Architectural Levels of Application

- **Module Interfaces**: the most critical application level.
- **Internal Mechanisms**: applicable to core algorithmic engines where performance and simplicity intersect.
- **System Decomposition**: which modules exist and how domain responsibilities are partitioned.
- **User Interfaces**: workflows, screen layouts, and interaction flows similarly benefit from exploring radically different wireframes.

At every level, designing twice is vastly cheaper than it appears. For a small module, sketching candidate interfaces takes an hour or two—negligible compared to weeks spent implementing and maintaining it. On system-wide architectures, the upfront investment is larger, but the cost of getting it wrong is catastrophic.

---

## 5. The "Smart Person" Trap

- Talented engineers often resist designing twice. Throughout their careers, their initial intuition was frequently "good enough" for standard tasks, breeding overconfidence in their first ideas.
- On large, complex problems, this instinct breaks down: **no one is skilled enough to get hard architectural problems right on the first try**.
- Evaluating multiple alternatives is not a sign of indecision; it is the hallmark of professional craftsmanship.
- Designing twice systematically **hones architectural judgment**: engineers who routinely compare alternatives learn what makes one design cleaner than another, and learn to discard flawed ideas rapidly.

---

## Red Flags

- Only one approach was considered for an important decision.
- "Alternatives" are merely superficial variations of the same idea (identical decomposition with renamed classes).
- A strawman alternative was constructed deliberately weak just to make the favorite look good.
- The evaluation lists only pros for the favorite and only cons for the others.
- The choice was made based on ease of implementation rather than caller ergonomics.

---

## How to Apply

1. Identify **high-impact decisions** (those that are expensive to reverse later).
2. For each, generate **at least two radically different alternatives**, sketched at the interface level.
3. Compare them, prioritizing caller ergonomics, followed by interface simplicity, generality, and efficiency.
4. Select, combine into a hybrid, or iterate to a new design based on discovered flaws.
5. Record rejected alternatives and the explicit rationale for their rejection.
