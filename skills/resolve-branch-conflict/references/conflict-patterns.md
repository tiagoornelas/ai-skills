# Conflict Patterns

Catalog used by Section 3 of [`SKILL.md`](../SKILL.md) to classify conflict points, and by Section 6 to resolve them. Each pattern details **how to recognize** the conflict and **which resolution strategy** preserves both sides.

---

## 🟢 Mechanical

| Pattern | How to Recognize | Resolution |
| :--- | :--- | :--- |
| **Adjacent Additions** | Both sides append independent lines in the same location: imports, list items, routes, config keys, `switch` cases. | Retain both, ordered per file convention (alphabetical, grouped). Eliminate duplicates. |
| **Formatting vs. Content** | One side reformatted code (or prettier/linter changed) while the other modified logic. | Accept the content changes and re-run project code formatter. |
| **Generated Files** | Code generation output, build artifacts, generated API clients, compiled schemas. | Resolve underlying source inputs and **regenerate**. Never merge by hand. |
| **Lockfiles** | `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `poetry.lock`, `Gemfile.lock`, `go.sum`, etc. | Resolve manifest (`package.json`, `pyproject.toml`), then regenerate lockfile via native package manager. If version requirements diverge, treat as 🟡. |
| **Identical Change** | Both sides applied the exact same change (cherry-pick, duplicated bugfix). | Keep one. |
| **Deletion vs. Context** | One side removed code untouched by the other, but adjacent lines shifted. | Apply deletion. If the other side added calls to the removed code, treat as ⚠️. |

---

## 🟡 Composition

| Pattern | How to Recognize | Resolution |
| :--- | :--- | :--- |
| **Same Function, Different Concerns** | One side added validation; the other added logging, caching, or normalization in the same function. | Compose in domain-logical order (e.g.: normalize → validate → persist). State execution order in proposal. |
| **New Parameter on Both Sides** | Both sides added parameters or fields to the same function signature or struct. | Retain both; update all callers across both branches. |
| **Different Dependency Versions** | Both branches upgraded the same library to different versions. | Adopt the highest version compatible with both branches; run tests from both sides. |
| **Edit vs. Move/Extract** | One side extracted logic into a helper/module; the other edited it in the original location. | Port the edits into the new location. Git may show conflict in old location or none: always verify. |
| **Parallel Database Migrations** | Both sides created schema migrations sharing sequence numbers or modifying the same table. | Re-sequence migrations per migration framework conventions; if modifying the same columns, treat as 🔴. |

---

## 🔴 Clashing Intent

| Pattern | How to Recognize | Typical Options for User |
| :--- | :--- | :--- |
| **Refactoring vs. Extension** | One side restructured architecture; the other built features on the legacy structure. | Port feature onto new architecture (recommended default) · defer refactoring. |
| **Twin Abstractions** | Both sides created competing concepts for the same responsibility (two helpers, two domain types, two clients). | Unify into one (select name and interface) · keep both with distinct boundaries if responsibilities truly differ. |
| **Contradictory Business Rules** | The two changes enforce mutually exclusive business rules. | Business decision: escalate to user, who may consult product owners or authors. |
| **Contract Altered on Both Sides** | Both sides modified the same public interface, endpoint, or schema incompatibly. | Design unified contract satisfying both clients · version contract · adapt one side. Pass through `software-designing`. |
| **Deletion vs. Usage** | One side removed a feature; the other introduced new dependencies on it. | Preserve deletion and rewrite caller · restore feature. Inquire why it was removed. |

---

## ⚠️ Semantic Conflicts (Zero Textual Markers)

Merge completes cleanly, but runtime behavior breaks or alters unexpectedly. Actively audit whenever one side modified:

- **Name or signature** of an exported function, method, class, or variable: search for new invocations of the legacy name in the other branch.
- **Data formats**: renamed properties, changed types, modified response JSON, event payloads.
- **Database schemas**: renamed/dropped columns, new constraints (e.g. `NOT NULL`) unhandled by new code on the other side.
- **Default behaviors**: modified defaults, changed execution sequence, toggled feature flags, altered error policies (throwing exceptions instead of returning `null`).
- **Configuration & environment**: renamed environment variables, relocated config keys.
- **Implicit invariants**: one side assumes a precondition (sorted collections, non-empty IDs) that the other side ceased guaranteeing.

Detection Recipe:

```bash
# symbols modified or dropped by side A
git diff <merge-base> <side-A> | grep -E '^-' | <extract identifiers>

# usages of those symbols in new code introduced by side B
git diff <merge-base> <side-B> | grep -E '^\+' | grep -E '<symbol>'
```

Post-merge verification: run build, type checks, and complete test suites from both branches. In dynamically typed languages, write or run a targeted integration test exercising the ⚠️ semantic boundary.
