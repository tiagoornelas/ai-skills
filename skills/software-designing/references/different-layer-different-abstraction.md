# Different Layer, Different Abstraction

> **Central thesis**: in a well-designed system, **each layer provides a distinctly different abstraction** from the layers above and below it. If two adjacent layers share similar abstractions, there is likely a flaw in the system's decomposition.

---

## When to consult

- When designing layered architectures (UI → application → domain → infrastructure; controller → service → repository; etc.).
- When identifying pass-through methods, wrappers, and decorators.
- When noticing a parameter traversing a long chain of functions without being used by them.

---

## 1. Layers with Distinct Abstractions

- Software systems are composed of layers: higher layers leverage the facilities of lower ones. Each layer must provide a **different** abstraction.
- Examples:
  - **File System**: the top layer provides the *file* abstraction (variable-length stream of bytes); the middle layer manages a memory *buffer cache* of fixed-size blocks; the bottom layer consists of *device drivers* transferring blocks between storage devices and memory.
  - **Network Protocols**: TCP provides a reliable, ordered *byte stream*; the layer beneath transports variable-sized, best-effort *packets* without delivery guarantees.
- If adjacent layers feature nearly identical abstractions, the separation likely fails to pay for itself.

---

## 2. Pass-Through Methods

- A pass-through method does little more than forward its invocation to another method with an identical or near-identical signature.

  ```java
  public class TextDocument ... {
      private TextArea textArea;
      public Character getLastTypedCharacter() {
          return textArea.getLastTypedCharacter();
      }
      public int getCursorOffset() {
          return textArea.getCursorOffset();
      }
      public void insertString(String textToInsert, int offset) {
          textArea.insertString(textToInsert, offset);
      }
  }
  ```

- Pass-through methods make classes **shallower**: they inflate interface surface area without increasing functionality. They also introduce tight coupling: if the lower method signature changes, the wrapper must change in lockstep.
- They signal **confusion in the division of responsibilities** between classes.
- **Remediation**:
  1. Expose the lower-level class directly to callers of the upper class, removing the pass-through methods entirely.
  2. Redistribute responsibilities between classes so each has a distinct, cohesive role.
  3. If the classes cannot be cleanly separated, **merge them**.

### When Duplicated Signatures Are Justified

- Methods sharing signatures are not always an anti-pattern. What matters is that **each method contributes significant new value**.
- **Dispatchers**: a method that inspects arguments to route execution to one of several target handlers (e.g., a web router selecting a controller by URL path). Signatures may match targets, but the dispatcher delivers a vital capability: routing decisions.
- **Multiple implementations of an interface** (e.g., diverse disk drivers implementing an OS storage contract). They sit at the **same layer** and do not call each other. This reduces cognitive load: mastering one gives familiarity with all others.

---

## 3. Decorators

- The decorator (or wrapper) pattern wraps an existing object to augment its behavior while preserving a matching or similar API. Example: `BufferedInputStream` wraps an `InputStream` to provide buffering over the same interface.
- While intended to decouple specialized additions from a general core, decorators **tend to be shallow**: they introduce substantial pass-through boilerplate for modest added functionality.
- Before introducing a decorator, consider:
  1. Adding the capability **directly into the base class**, if it is relatively general-purpose, logically cohesive with the base class, or needed by most use cases. (Buffering in I/O should be the default.)
  2. If the feature is specialized to a specific caller, **merge it directly into that caller** rather than creating an intermediate wrapper.
  3. **Merge with an existing decorator** instead of adding another layer: yields a deeper decorator rather than multiple shallow wrappers.
  4. Implement the feature as an **independent class** that does not wrap the base abstraction. Example: window scrolling can be implemented independently alongside a window rather than intercepting every window rendering call.

---

## 4. Interface vs. Implementation

- A class's interface should typically be **different** from its internal implementation: internal data structures should not dictate the exposed abstraction.
- Example: in a text editor, internal text storage might naturally be an array of lines. If the class exposes a line-oriented interface (`getLine`, `putLine`), common operations (inserting or deleting characters spanning line breaks) force callers to perform tedious line-splitting and concatenation arithmetic. A **character-oriented interface** (`insert`, `delete` by coordinate/offset) is far simpler for callers and cleanly encapsulates line-splitting mechanics internally.
- If the interface mirrors the implementation, the class is shallow.

---

## 5. Pass-Through Variables

- A pass-through variable is handed down through a long chain of intermediate functions. Intermediate functions never use the value; they exist solely to shuttle it to downstream callees.
- Inflates complexity: every intermediary must know about the variable. Adding another parameter requires modifying every method signature along the chain.

```text
main(cert) → m1(…, cert) → m2(…, cert) → m3(…, cert) → openSocket(cert)
             (unused)       (unused)       (unused)       (used)
```

- Remediation strategies:
  1. Check if a **shared object** already links the top and bottom of the chain (something both already access) and store the information there.
  2. Use a **global variable**. Avoids pass-through plumbing, but creates drawbacks: precludes multiple system instances within a process and introduces invisible dependencies.
  3. Use a **context object** (the industry-standard solution): encapsulates application-wide runtime state (configuration options, shared subsystems, telemetry counters) with one instance per system lifecycle. References to the context reside in instance variables of core objects, so they **do not need to be passed as function arguments** on every call. New shared state can be added to the context without modifying method signatures.
- Context objects require discipline: without it, they degenerate into an untyped junk drawer. Recommendations: context properties should ideally be **immutable** (preventing concurrency races), and the rationale for each property must be explicit.

---

## 6. Net Complexity Benefit

Every added design artifact (an interface, argument, class, or abstraction layer) introduces complexity because developers must learn it. **For any design element to justify its existence, it must eliminate more complexity than it introduces.**

---

## Red Flags

- **Pass-through method**: a method that does nothing beyond forwarding arguments to another method with a matching signature.
- Adjacent layers with nearly identical vocabulary and operations (e.g., `Service.create()` doing nothing but calling `Repository.create()`).
- Chained decorators or wrappers, each adding minuscule functionality.
- An interface that directly exposes the internal data representation.
- A parameter passed through multiple functions without being read or modified by them.

---

## How to Apply

1. For each architectural layer, write **one sentence** summarizing the abstraction it provides. If two adjacent layers share the same description, reconsider the boundary.
2. Search for pass-through methods and decide whether to expose, redistribute, or merge.
3. For every proposed decorator/wrapper, evaluate the four alternatives before adopting it.
4. Ensure each module's interface is expressed in caller concepts, not internal storage structures.
5. Identify pass-through variables and introduce a context object or shared state where appropriate.

When presenting to the human, diagram the layers (via [`visualize-it`](../../visualize-it/SKILL.md)), annotating the unique abstraction of each layer alongside explicit dependency direction.

---

## Relationships

- Pass-through methods and wrappers are symptoms of shallow modules: [deep-modules.md](deep-modules.md).
- Where complexity should live across layers: [pull-complexity-downwards.md](pull-complexity-downwards.md).
- When to merge layers: [together-or-apart.md](together-or-apart.md).
