# Working Code Isn't Enough: Strategic vs. Tactical Programming

> **Central thesis**: the primary goal cannot be merely "making it work". The primary goal must be to **produce a great design that also happens to work**. Good design does not happen by accident: it is a continuous, small investment made in every single task.

---

## When to consult

- Whenever there is pressure to "just get it working" or take a shortcut "just this once".
- When deciding how much design effort to invest in a task.
- When explaining the long-term cost of a quick tactical fix to the human.
- In every task that modifies an existing system (Section 5).

---

## 1. Tactical Programming

- In tactical programming, the main focus is **making something work**: shipping a new feature or fixing a bug as quickly as possible.
- It feels pragmatic, but it is short-sighted. Tactical developers optimize solely for immediate task completion and do not spend time seeking the cleanest design.
- Every tactical patch introduces a sliver of complexity: a quick hack here, an extra dependency there. Each feels justifiable ("just this once", "we'll clean it up later").
- Because complexity is incremental (see [nature-of-complexity.md](nature-of-complexity.md)), these shortcuts compound. The system quickly becomes resistant to change, and **"later" never arrives**: the next task is equally urgent.
- By the time the problem is acknowledged, remediating it requires an enormous overhaul, making the next tactical shortcut seem like the only viable option.

### The "Tactical Tornado"

- Many organizations have a developer who churns out code much faster than anyone else, but does so entirely tactically.
- Management sometimes hails them as heroes because they ship features rapidly.
- They leave behind a trail of devastation: developers who follow must clean up the mess, and their progress appears sluggish compared to the "hero".

---

## 2. Strategic Programming

- The starting point is realizing that **working code is not enough**. Introducing unnecessary complexity to finish sooner is unacceptable.
- The highest priority is the **long-term structure** of the system. Most code in any system is written by extending existing foundations; today's most important job is making future extensions easy.
- Requires an **investment mindset**: spending a little time now to improve design, knowing it will pay dividends in sustained velocity later.

### Proactive Investments

- Rather than seizing the first workable idea, exploring alternative designs and selecting the cleanest one ([`design-it-twice`](../../design-it-twice/SKILL.md)).
- Anticipating how the system is likely to evolve and designing flexibility into those dimensions.
- Thoroughly documenting contracts and design rationale (how to write comments: [comments.md](../../coding/references/comments.md)).

### Reactive Investments

- Regardless of skill, design flaws inevitably emerge. When discovering a design flaw, **never ignore it or patch around it**: set aside time to fix it cleanly.
- In strategic programming, the system continuously improves over time rather than steadily degrading.

---

## 3. How Much to Invest?

- Massive upfront design (attempting to architect the entire system before writing code) fails: deep understanding of the problem only surfaces during construction.
- The sweet spot is **small, continuous investments**. A practical benchmark is dedicating **roughly 10–20% of total development time** to design investments.
- This is small enough to avoid derailing delivery schedules, yet large enough that velocity benefits compound rapidly: within months, strategic development outpaces tactical development and keeps accelerating, while tactical velocity grinds to a halt.

```text
accumulated progress
  ▲                          ╱  strategic
  │                       ╱
  │                    ╱ ─ ─ ─ ─ ─  tactical (plateaus)
  │              ─ ─╱
  │         ─ ─  ╱
  │      ─     ╱
  │   ─     ╱
  │ ─    ╱
  │─  ╱
  └──────────────────────────────► time
```

Early on, tactical programming seems faster; soon, strategic programming overtakes it and the gap widens indefinitely.

---

## 4. Startups, Deadlines, and Technical Debt

- The most common justification for tactical shortcuts is deadline pressure: "we must ship now, we'll refactor later".
- In practice, once a codebase degenerates into spaghetti, **remediating it is almost impossible**. Development friction remains permanently high.
- **Technical debt** is rarely paid off in lump sums. The "interest payments" (sluggish velocity, regression bugs, painful onboarding) are levied on every subsequent ticket.
- Code quality directly affects an organization's ability to attract and retain strong engineers: talented engineers care deeply about craftsmanship and design.
- Teams that start with "move fast and break things" invariably pivot when the codebase becomes an anchor; teams with a strong design culture maintain steady velocity over years.

---

## 5. Modifying Existing Code

- A system's architecture is shaped far more by incremental changes than by its initial blueprint. When completing any change, the system should end up with **the structure it would have had if it had been designed from scratch with this new capability in mind**.
- The temptation is to make the **smallest possible edit** ("don't touch what already works"). Each minimal edit tends to introduce a special case, a hidden dependency, or obscure logic. **If you are not actively improving the design, you are almost certainly degrading it.**
- The governing question for every modification: **"Is this the best possible design for the system, given what I know now and the change I need to introduce?"**

When designing a change:

1. **Read the current design** in the affected area: modules, contracts, encapsulated decisions.
2. **Envision the ideal design** accommodating the new requirement, as if building it greenfield today.
3. **Gauge the delta** between current and ideal:
   - Small → implement the ideal design directly, including necessary refactorings.
   - Large → find a nearly-as-clean alternative that fits within scope; if none exists, **escalate to the human** as an explicit trade-off (cost now vs. cost later).
4. **Improve along the way, within the scope touched by the task**: refactoring scope follows [refactoring-principles.md](../../coding/references/refactoring-principles.md).
5. **Update contract documentation and rationale simultaneously**, adhering to [comments.md](../../coding/references/comments.md).

Contract modifications identified in this process are Human Layer decisions; internal refactorings that preserve contracts belong to the Agent Layer.

---

## Red Flags

- Rationalizing that "it's just this once" or "we'll fix it later".
- A patch that works around a design flaw instead of resolving it.
- Selecting a solution merely because it was the first idea that worked, without evaluating alternatives.
- Changes requiring tribal knowledge ("don't forget to also update X") to avoid breaking.
- Measuring productivity solely by immediate output velocity of the current task.
- Introducing a special case (a new `if` branch for the edge case) instead of adjusting the underlying abstraction.
- "Don't touch that, just tack on a new handler next to it."
- Replicating the same change across multiple call sites (the architecture failed to absorb the change).

---

## How to Apply

In every design task, the agent must:

1. **Reject accidental complexity**: if the quickest path introduces avoidable dependencies or obscurity, formulate the clean alternative and its true cost.
2. **Evaluate alternatives** before locking in a solution, following [`design-it-twice`](../../design-it-twice/SKILL.md).
3. **Plan for the next change**: what is the most probable subsequent enhancement in this domain? Does the design make it effortless?
4. **Fix instead of work around** whenever encountering a design flaw along the path, provided it falls within the code touched by the task and within a sensible investment budget (~10–20%). If the remediation exceeds scope, **escalate to the human** as an explicit trade-off with clear trade-off analysis.
5. **Make debt explicit**: when a tactical compromise is deliberately chosen by the human, document the decision and the outstanding cleanup.

---

## Relationships

- What accumulates during tactical programming: [nature-of-complexity.md](nature-of-complexity.md).
- The future reader of modified code: [obvious-code.md](obvious-code.md).
