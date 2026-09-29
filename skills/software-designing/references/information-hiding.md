# Information Hiding (and Leakage)

> **Central thesis**: every module should encapsulate **knowledge that represents design decisions**. That knowledge is embedded within the implementation and **does not appear in the interface**. It is the single most important technique for creating deep modules.

---

## When to consult

- When deciding what each module "knows" and what it reveals.
- When noticing that a change in format, protocol, or business rule requires updating multiple modules.
- When decomposing a pipeline into steps (risk of temporal decomposition).
- When designing API return values, public data structures, and default values.

---

## 1. What is Information Hiding

- Encapsulated knowledge usually concerns **how** a mechanism is implemented. Examples:
  - How to store data in a B-tree and retrieve it efficiently.
  - How to map a file's logical blocks to physical disk blocks.
  - How the TCP protocol is implemented.
  - How to schedule threads across multiple processor cores.
  - How to parse JSON documents.
- Hidden information spans data structures, algorithms, low-level details (page size), and high-level assumptions (the assumption that most files are small).

### Why it Reduces Complexity

1. **Simplifies interfaces**: the interface reflects an abstract, simplified view and omits operational details. This minimizes cognitive load for callers.
2. **Streamlines evolution**: if a detail is encapsulated, external modules cannot depend on it. A design change touching that detail impacts **only one module**.

### What Information Hiding is Not

- **Making variables private is not, by itself, information hiding.** If a class provides public getters and setters for every private field, the internal representation remains effectively exposed.
- **Partial hiding has real value**: if a capability is only needed by a minority of callers and accessed via specialized methods, it remains hidden from common workflows, reducing cognitive load for the majority.

---

## 2. Information Leakage

- The inverse of information hiding: occurs when **a single design decision is reflected across multiple modules**. This couples them: any change to that decision forces updates to every affected module.
- If information appears in a module's public interface, it has leaked by definition. Simpler interfaces inherently leak less.
- **Back-door leakage**: knowledge can leak even without appearing in formal interfaces. Example: two classes that independently understand the same file format—one reads, one writes. Neither interface mentions the format, yet both are coupled to it. This leakage is especially hazardous because it is invisible.
- **Remediation**:
  - If affected classes are small and tightly bound to that information, **merge them** into a single cohesive class.
  - Alternatively, **extract** the information from all of them into a new dedicated class that encapsulates it behind an abstract interface.

---

## 3. Temporal Decomposition

- A frequent driver of information leakage. In temporal decomposition, the system's structure **mirrors the chronological execution order** of operations.
- Example: an application reads a file in a specific format, modifies its content, and writes it back. Temporal decomposition yields three classes: Reader, Modifier, Writer. Reader and Writer **both know the file format**: leakage. The clean design merges reading and writing mechanisms into a single module that owns the file format.
- Developers easily fall into this trap because chronological order is top-of-mind when writing procedural code.
- **Rule**: when designing modules, focus on the **knowledge required to perform each task**, not the sequence in which tasks execute.
- Execution sequence matters and will exist somewhere in the application, but it should not dictate module boundaries unless those boundaries naturally align with information hiding (e.g., stages operating on completely disjoint sets of knowledge).

---

## 4. Case Study: An HTTP Server

Designing a lightweight HTTP server highlights common traps and effective patterns:

- **Excessively shallow classes**: separating network request reading into one class and request parsing into another. Both must know substantial parts of HTTP wire format (e.g., parsing headers like `Content-Length` to determine where the body ends). Result: leakage. A unified class that reads and parses eliminates this coupling.
- **Request parameters**: an effective interface hides whether a parameter arrived via query string or body payload, returning clean, **decoded** values:

  ```java
  public String getParameter(String name) { ... }
  public int getIntParameter(String name) { ... }
  ```

  This encapsulates wire encoding and parameter source, while the integer helper additionally absorbs parsing and error handling.
- **Exposing internal representation** is a red flag: returning the internal `Map` of parameters leaks implementation details, allows external mutation, and locks the class into that specific structure.
- **Defaults**: response interfaces should provide defaults for ubiquitous requirements (protocol version, Date headers), sparing callers routine configuration rituals. Sensible defaults are a form of partial information hiding that reinforces **making the common case simple**. The best capability is one the user benefits from without needing to know it exists.

---

## 5. Information Hiding Within a Class

- The principle applies **internally**. Private methods should encapsulate specific sub-tasks so the rest of the class does not depend on their internal mechanics.
- Minimize the blast radius of instance variables. If a variable is accessed across numerous methods, they become tightly coupled; if access is localized to a few helper methods, coupling drops significantly.

---

## 6. Taking It Too Far

- Hiding information only makes sense if the knowledge is **unnecessary outside the module**. If callers genuinely require information to make decisions, it must not be hidden.
- Example: if module performance hinges on configuration parameters and different deployments have conflicting throughput requirements, those knobs must be exposed. However, the overarching goal should be to **minimize** external configuration needs: it is far better for a module to auto-tune than to force callers to supply tuning parameters (see [pull-complexity-downwards.md](pull-complexity-downwards.md)).
- Recognize what information callers genuinely require and ensure it is clearly exposed in the contract.

---

## Red Flags

- **Information leakage**: the same design decision (format, protocol, rule, data structure) is mirrored across multiple modules.
- **Temporal decomposition**: module boundaries follow execution steps (read → process → write), and modules share underlying domain knowledge.
- **Exposing internal representation**: getters/setters for every field, returning mutable internal collections, or leaking storage types in public signatures.
- **Overexposure**: an API forces mainstream callers to learn rarely used parameters and configuration rituals.

---

## How to Apply

1. **Enumerate design decisions** for the problem (wire formats, protocols, algorithms, business invariants, assumptions) and assign each to **exactly one** owner module.
2. **Scan for multi-owner decisions**: each instance represents leakage. Propose merging classes or extracting a dedicated owner module.
3. **Be skeptical of step-named modules** (`Reader`, `Processor`, `Writer`, `Step1`...). Examine the knowledge each consumes; if they share knowledge, consolidate them.
4. **Inspect public interfaces** for leaked representation (mutable objects, infrastructure types, persistence details).
5. **Establish defaults** for everything the common case needs.
6. **Validate what callers truly need**: information that callers legitimately depend on must be made explicit in the contract.

When presenting to the human, state clearly for each module: **what it encapsulates** (design decisions) and **what it guarantees** (contract).

---

## Relationships

- Information hiding is what provides depth to a module: [deep-modules.md](deep-modules.md).
- General-purpose interfaces encapsulate better: [general-purpose-modules.md](general-purpose-modules.md).
- Shared knowledge is the strongest justification for combining modules: [together-or-apart.md](together-or-apart.md).
