# Domain Models and Types

> **Central thesis**: encode the domain in a data structure and in types, not in conditionals scattered across files. A structure that matches the domain makes invalid states unrepresentable and deletes branches. Choosing it at write time is cheap; recovering it later reads as a refactor and gets deferred.

---

## When to consult

- Before writing stateful logic or code that branches on a kind, status, or phase.
- When designing types or a function signature, in any language with a type system.
- When parsing data that enters from outside the program.

---

## 1. Name the Data Shape First

Before writing logic, name the shape and pick the structure that fits the domain and its access patterns:

- A **state machine** instead of scattered booleans, phases, or lifecycle checks.
- A **typed model** instead of loose parameters or repeated shape assumptions.
- A **map, registry, lookup table, or discriminated union** instead of branching spread across files.
- A **reducer or command/event model** instead of ad hoc state mutations.
- A **module organized around one body of domain knowledge** instead of a sequence such as load, validate, transform, save: execution order is not ownership ([information-hiding.md](../../software-designing/references/information-hiding.md)).
- A **queue, cache, index, graph, tree, or normalized collection** where the access pattern calls for it.

When none fits, write down what the code must never allow and how the data is read, then find the structure that encodes exactly that.

Do not force an abstraction: keep boring code when the current shape is clear, local, and unlikely to grow. An abstraction earns its place only by removing branches, duplicated rules, invalid states, or lifecycle risk.

## 2. Let the Type System Reject Mistakes

- **Make illegal states unrepresentable**: two fields that must change together become one variant of a union, not two independent fields.
- **Give semantic primitives their own types**: a `UserId` and an `OrderId` are not interchangeable even if both are strings. Use the language's newtype or branded type; validate once at creation and trust the type downstream.
- **Parse external data at the boundary**: payloads, JSON, messages, CLI arguments, config files, environment variables, and database rows are untyped until a parse function turns them into the typed model. Inside the boundary, trust the types ([dependency-direction.md](../../software-designing/references/dependency-direction.md)).
- **Handle every variant exhaustively**, so adding a variant fails compilation wherever it is not handled.
- **Derive types from the authoritative schema** (OpenAPI, GraphQL, protocol buffers, migrations) instead of hand-writing a parallel type that drifts.

---

## Red Flags

- A new feature adds one more branch to an existing if/else chain.
- A second boolean that must stay in sync with the first.
- Modules named after phases that repeat the same domain rules across steps.
- Two parameters of the same primitive type that callers can swap without a compile error.
- External data used without a parse step.

---

## Relationships

- Repeated switches over a discriminator: [code-smells.md](code-smells.md).
- Generic containers and primitive obsession at the contract level: [obvious-code.md](../../software-designing/references/obvious-code.md).
- Defining special cases out of existence: [define-errors-out-of-existence.md](../../software-designing/references/define-errors-out-of-existence.md).
- Behavior with explicit states, prototyped before building: [`prototype`](../../prototype/SKILL.md).
