# Retries and Concurrency

> **Central thesis**: code that mutates state runs where crashes, restarts, retries, and concurrent actors are normal. Every such operation converges to the same end state however many times it runs and wherever the previous run stopped, and no two actors write the same state unless one shared writer is a real invariant.

---

## When to consult

- Writing commands, jobs, scripts, backfills, lifecycle steps, or processing loops that mutate state.
- When two processes, workers, requests, or agents might write the same file, row, key, branch, or object.

---

## 1. Make Operations Idempotent

- **Derive each step from the state that exists**, not from what the previous run meant to do: read the current state, compare it with the goal, and apply only the difference. A repeat then finds nothing left to do.
- **Make leftovers recognizable as stale.** A lock, temporary file, half-written record, or claimed job left by a crashed run must be judged stale by evidence that holds wherever the run stopped: a lease with an expiry, an owner that can be checked. A marker the next run cannot judge turns every crash into manual cleanup.
- **Write atomically**: write to a temporary path and rename it into place; compare artifacts by content, not by creation order; use upserts or unique keys so a repeated insert is rejected or merged.

**The test**: what happens if this runs twice in a row, and if the previous run crashed at every possible point? If any answer is "it depends on what was left behind", add a reconciliation step.

## 2. Separate Before Serializing Shared State

1. **Find the shared mutable state**: files both read and write, branches both push to, keys or rows both update.
2. **Eliminate the sharing by default.** Ask whether the actors need one canonical object or are publishing independent facts. Give each its own file, key, row, or directory, and merge only where the facts are read. Two workers writing their own field into one `state.json` still share it; `indexer-state.json` and `metrics-state.json` do not.
3. **Serialize structurally only when one shared writer is a real invariant**: a lock with an owner, sequential phases, a single-writer process, or an atomic compare-and-swap. Conventions and instructions are not concurrency control, and "we need a lock" is a design smell to check before it is the answer.

---

## Red Flags

- A multi-step mutation with no answer for "what is left behind if step *k* fails?".
- A rerun that duplicates rows, re-sends messages, or fails on its own leftovers.
- A lock or flag file with no way to tell whether its owner is still alive.
- Two actors writing different fields of the same file, row, or object.

---

## Relationships

- Batching and resuming data backfills: [database-and-migrations.md](database-and-migrations.md) (Section 2.3).
- Redefining operations so failure is not an error: [define-errors-out-of-existence.md](../../software-designing/references/define-errors-out-of-existence.md).
- Agents never sharing a writer: [`agentic-parallel-work`](../../agentic-parallel-work/SKILL.md).
