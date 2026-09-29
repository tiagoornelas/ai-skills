# Naming

> **Central thesis**: a good name explains **what the element is and why it exists**, sparing the reader from inspecting the implementation to figure it out. This reference covers **internal** names (variables, functions, classes, and private fields). Public contract names are architectural decisions: see [obvious-code.md](../../software-designing/references/obvious-code.md).

---

## When to consult

- When naming any internal identifier.
- When reviewing names in a code diff.
- Whenever struggling to find an appropriate name.

---

## 1. Rules

- **Reveal intent**: the name states why the symbol exists, what it does, and how it is used. If a name requires a comment, it fails to reveal intent.
- **Avoid disinformation**: never choose a name suggesting something contradictory (`accountList` for a map or set, `isValid` that mutates state as a side effect).
- **Make meaningful distinctions**: avoid `data1`/`data2`, and eliminate noise words that add zero disambiguation (`Info`, `Data`, `Object`, `Manager`, `Helper`). `Product` and `ProductInfo` side by side fail to convey how they differ.
- **Length proportional to scope**: a single letter `i` in a tiny three-line loop is fine; a variable referenced across an entire module requires an unambiguous, searchable name.
- **One word per concept**: pick one term from `fetch`, `get`, and `retrieve`, and apply it consistently for the same conceptual operation.
- **One concept per word**: never reuse the same word for two different semantics. If `add` performs arithmetic addition in one context, do not use `add` to append an item to a collection elsewhere.
- **Problem and solution domain**: use business domain terms for business logic, and standard computer science terminology (`queue`, `visitor`, `cache`) for technical infrastructure.
- **Meaningful context without redundancy**: `state` alone is ambiguous; inside an `Address` entity, `state` is clear. Do not prefix every variable with the enclosing module or project name.
- **Grammatical form**: classes and types are nouns; functions are verbs; booleans are predicates (`isActive`, `hasItems`).

Repository conventions (prefixes, casing, naming language) take precedence over these rules.

---

## 2. Difficult Names Signal Design Smells

- When finding a concise and precise name is difficult, the underlying element likely has multiple responsibilities or lacks a well-defined purpose. Before accepting a vague name, re-evaluate what the component actually does (see [functions.md](functions.md)).

---

## Red Flags

- Generic catch-all names (`data`, `info`, `result`, `temp`, `obj`, `handle`) outside minimal local scopes.
- Names that falsely imply capabilities or types the code does not possess.
- The same concept named differently across files, or the same name applied to disparate concepts.
- Arbitrary noise words used to distinguish related symbols.
- Cryptic abbreviations that only the original author understands.

---

## How to Apply

- **When writing**: name for intent; if stuck, re-evaluate the responsibility.
- **When reviewing**: a name that is **misleading** (suggests what it is not) or **inconsistent** with existing repository vocabulary has a concrete maintenance scenario and warrants correction. A name that is merely stylistic or mildly sub-optimal lacks a concrete failure scenario: do not flag it.

---

## Relationships

- Public contract names and architectural consistency: [obvious-code.md](../../software-designing/references/obvious-code.md).
- Names that eliminate the need for comments: [comments.md](comments.md).
- Functions that resist naming: [functions.md](functions.md).
