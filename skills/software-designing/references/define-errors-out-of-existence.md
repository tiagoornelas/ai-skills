# Define Errors Out of Existence

> **Central thesis**: exception handling is one of the worst sources of complexity in software. The most effective way to eliminate this complexity is to **reduce the number of places where exceptions must be handled**, ideally by redefining operation semantics so that the error condition ceases to exist.

---

## When to consult

- When defining failure modes in a contract (errors, exceptions, return codes).
- When an interface enumerates many potential exceptions or error branches.
- When architecting fault-tolerant recovery in distributed systems.
- When discovering special-case branches scattered across business logic.

---

## 1. Why Exceptions Add Outsized Complexity

- An "exception" here refers to any non-standard condition altering normal execution flow: language exceptions, error codes, special status returns.
- They arise from diverse sources: callers passing invalid arguments or misconfiguration; callees unable to fulfill requests (I/O failures, resource exhaustion); in distributed networks, packets dropping, latency spikes, server crashes; internal bugs or unhandled edge cases.
- **Handling is difficult**: developers must decide whether to attempt recovery or abort and unwind. Aborting requires rolling back partial mutations to preserve system invariants. Recovery attempts frequently trigger secondary failures (exceptions during recovery).
- **Handling code rarely executes**, allowing bugs in error-handling paths to lie dormant for months, only detonating during active production incidents.
- **Throwing is easy; handling is hard.** This asymmetry creates a dangerous incentive to throw exceptions for every minor inconvenience.
- Syntactic clutter (`try/catch` cascades) fragments code flow and obscures the happy path.

### Exception Overload

- Developers frequently throw exceptions for situations they could easily absorb internally, simply to offload responsibility ("if I'm unsure what to do, I'll throw"). Compounded by the misconception that "more explicit errors equal higher robustness".
- **The exceptions a module throws are an inseparable part of its public interface.** A module with numerous thrown exceptions has a complex, shallow interface.
- Every thrown exception pushes complexity upward onto all callers (the exact opposite of [pull-complexity-downwards.md](pull-complexity-downwards.md)).

---

## 2. The Four Techniques

### 2.1. Define Errors Out of Existence

Redefine operation semantics so that the error condition becomes a valid, normal state.

- **`unset` in Tcl**: originally unsetting an undefined variable threw an error. But `unset` is primarily used to clean up temporary state, and callers rarely know if the variable was instantiated. Callers were forced to wrap every call in error traps. A superior definition: **`unset` guarantees the variable no longer exists**. If it didn't exist in the first place, the postcondition is already satisfied: no error.
- **File Deletion**: in Windows, attempting to delete an open file fails with an error, requiring users or applications to hunt down file lock handles. In Unix, an open file can be deleted immediately: its directory entry is removed instantly (invisible to new processes), while data blocks persist until the last holding process terminates. Neither side requires error handling.
- **`substring` in Java vs. Python**: Java throws `IndexOutOfBoundsException` if offsets exceed string boundaries, forcing callers to clamp bounds beforehand. Python string slices **clamp gracefully**: out-of-range bounds yield the overlapping slice (or empty string). Call sites are dramatically cleaner with zero loss in utility.

### 2.2. Mask Exceptions

Detect and resolve the condition **at a low level** so upper architectural layers never need to know it occurred.

- **TCP**: dropped packets are detected and retransmitted by the transport layer. Applications receive a reliable byte stream and remain oblivious to transient packet loss.
- **NFS**: if a file server becomes unreachable, client drivers do not bubble up I/O errors; they retry indefinitely until the server recovers. Applications simply pause. While potentially causing latency pauses, this is far superior to forcing thousands of client applications to independently invent distributed retry policies.
- Masking exceptions is an application of **pulling complexity downwards**: the masking module absorbs complexity, relieving all downstream callers.

### 2.3. Aggregate Exceptions

Handle numerous diverse exceptions with **a single centralized recovery handler** rather than fragmented ad-hoc handlers at every call site.

- **Web Routers and Missing Parameters**: instead of each HTTP handler checking and trapping missing query parameters, the parameter extraction utility throws a standardized bad-request exception. A **top-level dispatcher/middleware** intercepts it and formats the appropriate 400 response. Individual controllers contain zero error-handling boilerplate.
- Aggregation is the structural opposite of catching exceptions as close as possible to the throw site. It concentrates handling where **a single policy** governs many failure modes.
- **Promote rare exceptions to common ones**: in a distributed storage cluster, handling a corrupted data chunk by treating the hosting node as dead leverages the existing, rigorously tested node-recovery machinery. One battle-tested failover path replaces custom recovery code for obscure edge cases.

### 2.4. Just Crash

- For certain catastrophic conditions, **attempting recovery is not worth the complexity**. The simplest and safest strategy is to log rich diagnostic telemetry and terminate the process.
- Examples: out-of-memory errors in standard applications (an allocator that aborts rather than returning null spares every caller from null checks); unexpected disk corruption; broken internal invariants signaling bugs.
- Applies strictly to **rare, non-recoverable errors**. Applicability depends on domain: a replicated distributed storage engine must **not** crash on local I/O failure; it should failover to replicas.

---

## 3. Define Special Cases Out of Existence

- The same philosophy applies to edge cases: they scatter branching logic and impair readability.
- Example: in a text editor, treating "no text selection" as a null special state requires conditional checks before every selection operation. If a selection **always exists** and simply has a length of zero when collapsed, all selection commands execute uniformly without conditional branches.
- Whenever possible, design the **normal flow** to encompass boundary conditions seamlessly.

---

## 4. Taking It Too Far

- Defining errors out of existence or masking them is only appropriate if **callers do not genuinely need that information**.
- Example: a network layer that silently swallows **all** transmission failures without notifying callers would be disastrous, as applications must know when external commands fail in order to maintain business consistency.
- Exercise sound engineering judgment: expose exceptions when callers legitimately require them to make control decisions; in those cases, exceptions must be **explicitly declared in the contract**.

---

## Red Flags

- A public interface throwing a sprawling catalog of distinct exceptions or error codes.
- Callers consistently catching the same exception and executing identical recovery logic (signals the error should be absorbed or defined away).
- Identical error-handling logic replicated across dozens of handlers (candidate for aggregation).
- Callers repeatedly validating preconditions prior to method invocation (signals poorly defined semantics).
- Special sentinel states ("uninitialized", "none") requiring checks at every consumption point.

---

## How to Apply

For every failure mode in a contract, evaluate in sequence:

1. **Can I redefine the operation so this condition is not an error?** (idempotency, "ensure X exists", boundary clamping, empty collections instead of nulls).
2. **Can I mask the condition internally?** (retries, fallbacks, local healing), provided callers do not need the event for decision-making.
3. **Can I aggregate handling at a higher architectural level?** (middleware, dispatchers, existing health recovery mechanisms).
4. **Is recovery unwarranted, making termination with diagnostics preferable?**
5. Only then: **expose the exception in the public contract**, documented with actionable information callers need to recover.

Remaining failure modes are **Human Layer decisions**: present them on interface cards, documenting both preserved errors and those successfully defined out of existence.

---

## Relationships

- Exceptions as interface surface area and module depth: [deep-modules.md](deep-modules.md).
- Masking as pulling complexity downwards: [pull-complexity-downwards.md](pull-complexity-downwards.md).
- Eliminating special cases: [general-purpose-modules.md](general-purpose-modules.md).
