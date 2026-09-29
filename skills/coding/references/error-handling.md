# Error Handling in Implementation

> **Central thesis**: error handling must not obscure core business logic nor allow failures to pass silently. This reference addresses **how to implement** error handling in code. **Which** failure modes a public contract exposes is an architectural design decision belonging to the Human Layer: see [define-errors-out-of-existence.md](../../software-designing/references/define-errors-out-of-existence.md).

---

## When to consult

- When authoring code prone to failure (I/O, network calls, external input, third-party libraries).
- When reviewing `try/catch` blocks, error return values, `null` checks, and error messages in a diff.

---

## 1. Idiomatic Mechanisms

- Leverage the error mechanism **idiomatic to the language and repository**: exceptions, `Result`/`Maybe`/`Either` monads, or explicit error return values. Repository conventions take precedence.
- Regardless of the mechanism chosen: ensure the **happy path remains readable**, and callers are never forced to check return codes that can be silently ignored. Favor mechanisms enforced by the compiler or type system.

---

## 2. First, Define the Error Out of Existence

- Before writing error-handling logic, evaluate whether the error condition needs to exist at all: adjust semantics, return an empty collection, or leverage a special-case object. Techniques are detailed in [define-errors-out-of-existence.md](../../software-designing/references/define-errors-out-of-existence.md).

---

## 3. Do Not Return or Pass Null

- Returning `null`/`None`/`nil` forces every caller to remember null checks; a single omission causes failures far from the root cause.
- Prefer empty collections, a null-object/special-case instance, or idiomatic optional types.
- Never pass null as a function argument unless the interface explicitly specifies it as valid input.

---

## 4. Contextual Error Messages

- The error message must specify **which operation failed**, with relevant input context, and why. "Failed to process" helps no one.
- Preserve the root cause (exception chaining, wrapped errors) rather than discarding it.
- Never leak sensitive credentials, tokens, or PII into error strings.

---

## 5. Never Swallow Errors

- Empty `catch` blocks, `except: pass`, and passive logging without handling obscure critical failures.
- Catch strictly what you can meaningfully handle at the current altitude. Allow everything else to propagate upward.

---

## 6. Decouple Error Handling from Core Logic

- A `try` block should not intermingle business algorithms with recovery logic. Extract the domain algorithm into a clean function, keeping the `try` block restricted to invocation and handling.
- Keep `try` blocks as narrow as possible, scoping only the operations that can fail.

---

## 7. Third-Party Vendor Errors

- At the boundary where code integrates with external libraries or SDKs, translate foreign exceptions into the errors defined by the module's domain contract. Vendor-specific errors must not leak into core application logic.

---

## Red Flags

- Empty `catch` blocks, `except: pass`, or logging an error without making a recovery or termination decision.
- Functions returning `null` to signal failure or absence.
- Generic error messages omitting the operation context and cause.
- Discarding root-cause exceptions when re-throwing.
- Sprawling `try` blocks tangling business logic with error traps.
- Identical error checks replicated across multiple call sites.
- Third-party library exceptions bubbling untamed through domain logic.

---

## How to Apply

- **When writing**: attempt to define errors away; where errors are inevitable, use idiomatic mechanisms, provide rich context, avoid nulls, and handle errors strictly where actionable recovery is possible.
- **When reviewing**: swallowed errors, gratuitous null returns, and lost root causes represent concrete failure scenarios (silent bugs, remote failures) and warrant remediation.
- If remediation alters the failure modes exposed by a public contract, that is an architectural decision: escalate to the Human Layer.

---

## Relationships

- Exposing contract failure modes and defining them out of existence: [define-errors-out-of-existence.md](../../software-designing/references/define-errors-out-of-existence.md).
- Functions that fulfill their explicit promises: [functions.md](functions.md).
- Special-case objects replacing defensive checks: [code-smells.md](code-smells.md).
