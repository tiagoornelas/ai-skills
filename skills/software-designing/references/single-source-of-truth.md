# Single Source of Truth

> **Central thesis**: every fact the system relies on (a piece of data, a state, a configuration value, a business rule, a decision) has exactly one authoritative place. Everything else reads it there, derives it from there, or links to it. Two places that can each claim the fact will eventually disagree, and no one can tell which one is right.

---

## When to consult

- When the same fact would be stored, written, or stated in more than one place: two tables, two services, a cache, a status file, a copied constant, a rule repeated in two documents.
- When a field could be computed from data the system already has.
- When two components each hold a copy of something and must "stay in sync".

---

## 1. One Authority per Fact

- **Name the authority.** For each fact, one module, table, service, or document owns it: only the owner writes it, and the owner's version wins any disagreement.
- **Derive instead of storing.** A value computed from facts the system already holds is computed when needed. Store it only when computing it is too expensive or impossible later, and then it is a copy (Section 2).
- **Link instead of restating.** In documents, prompts, and configuration, a rule lives in one file and every other file points to it. A restated rule drifts the first time only one copy is edited.
- This is the "single, unambiguous, authoritative representation" of every piece of knowledge from Hunt and Thomas's DRY principle. It applies to knowledge, not text: code that looks alike by coincidence is not a second source ([together-or-apart.md](together-or-apart.md), Section 2). For a design decision hidden inside code, the owner is the module that hides it ([information-hiding.md](information-hiding.md)).

## 2. When a Copy Is Justified

Performance, availability, an offline client, or a boundary between services can justify a copy. A justified copy states three things:

1. **Which side is the authority**, and that the copy never writes back except through it.
2. **How the copy follows the authority**: an event it consumes, an expiry time, or a recomputation it runs.
3. **What a reader of the copy accepts**: how stale it may be, and what happens when it is wrong.

A copy without these three is a second source of truth.

## 3. Red Flags

| Red flag | Direction |
| :--- | :--- |
| Two places can each be updated, and a job or a person reconciles them | Pick the authority; make the other read it or follow it one way |
| A stored field duplicates what other fields already determine (a `total` beside its items, a `status` beside its dates) | Compute it, or treat it as a copy with a recomputation rule |
| A registry, status file, or summary kept beside the thing it describes | Derive it from the thing on demand |
| A constant, rule, or limit repeated in code, configuration, and documentation | Keep it in one place; the others import it or link to it |
| A bug fixed in one copy reappears from another | The fact had two sources; remove one |

## 4. Proportion

A single source is not a single file for everything. Independent policies that happen to share a value today keep separate owners, and a deliberate compatibility copy during a migration is fine while it has an end date. The question is always the same: if this fact changes, how many places must change, and who decides which one is right?
