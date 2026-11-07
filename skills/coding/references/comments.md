# Comments

> **Central thesis**: code explains itself. A comment is a failure to express intent in code (Robert C. Martin, *Clean Code*): it is not compiled, not tested, and rots the moment the code changes. Write no comment unless it belongs to the short list in Section 2; reshape the code instead.

---

## When to consult

- When authoring or modifying code.
- When reviewing comments in a code diff.

---

## 1. Scope and Precedence

- **The diff only**: the policy applies to code the change writes or touches. Comments elsewhere stay as they are.
- **The repository's rules win**: when a project rule, linter, or language convention requires comments or docstrings (a mandated docstring style, for instance), follow it.

## 2. The Only Comments That Survive

- **Legal and license headers.**
- **Behavior forced by something we cannot change**: an external dependency, vendor, platform, or protocol, ideally with a link to the issue or specification. A surprise in our own code is not on this list: reshape the code.
- **Public API contracts** consumed outside the module or repository: what the interface guarantees, its preconditions, side effects, and failure modes, never its implementation.
- **Tool directives** such as formatter or linter pragmas, under Section 4.

When unsure whether a comment fits the list, delete it.

## 3. Turn Every Other Comment into Code

| The comment explains | Make the code say it |
| :--- | :--- |
| What a block does | Extract a function named for it ([functions.md](functions.md)); extract an explanatory variable ([naming.md](naming.md)). |
| A business rule ("legacy plans get no discount") | A named predicate or function: `if client.is_on_legacy_plan()`. |
| An invariant or assumption | A type that cannot hold the bad state ([domain-models-and-types.md](domain-models-and-types.md)) or an assertion. |
| A warning ("do not remove", "must run before X") | A test that fails when the constraint breaks, or a type, assertion, or check that enforces it. |
| Who triggers a handler | Name the handler for its trigger and register it where the event is declared. |
| A step in a test or script | The assertion message or log string: `assert(ok, 'persisted across restart')`. |
| History, authorship, or dead code | Nothing: git holds it. Delete it. |

A workaround that needs a paragraph to justify it means the code is wrong: fix the root cause ([debugging.md](debugging.md)).

## 4. Suppressions

`eslint-disable`, `@ts-ignore`, `@ts-expect-error`, `# noqa`, `# type: ignore`, and similar suppressions are comments that silence a check. Keep one only when its rule is style-only or wrong for this exact line. When the rule catches real bugs or protects correctness or safety, remove the suppression and fix the code.

## 5. Keeping Surviving Comments Accurate

- Place a contract comment beside its declaration and a forced-behavior comment beside the line it explains.
- A behavior change updates every surviving comment that describes that behavior.

---

## Red Flags

- A comment explaining what our own code does or why it is shaped that way.
- A "do not change" or "important" comment with no test or check behind it.
- Commented-out code, banners, change logs, or docstrings that restate a private function's name and parameters.
- A suppression on a rule that protects correctness.

---

## How to Apply

- **When writing**: reshape the code until no comment is needed; keep only what Section 2 lists.
- **When reviewing your own or an agent's change**: every comment the diff adds outside Section 2 is a finding to fix by reshaping the code; a misleading or outdated comment is fixed at once.
- **When reviewing someone else's pull request**: report comments only when the repository's rules forbid or require them; otherwise this policy is a personal preference, not a finding. A misleading or outdated comment is a finding in any review: it misleads the next reader.

---

## Relationships

- Self-documenting names: [naming.md](naming.md).
- Extracting functions to state intent: [functions.md](functions.md).
- Obscurity and required reader context: [obvious-code.md](../../software-designing/references/obvious-code.md).
- The contract of an interface: [deep-modules.md](../../software-designing/references/deep-modules.md).
