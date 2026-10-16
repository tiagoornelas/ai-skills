# Interface Card: Format

> Full format for the interface card rules in [`../SKILL.md`](../SKILL.md) (Section 3). A card answers three questions for one component: what it exposes, what this change did to that interface, and (in its contract layer) what it guarantees.

---

## 1. Who Gets a Card

| Component | Card? |
| :--- | :--- |
| Public interface is new or altered | Yes |
| Interface unchanged, but the change calls it | Yes, marked as unchanged, listing only the methods used |
| Entry point or infrastructure adapter without a new public interface | No |

Render cards in the order the module map is read: business rules first, then contracts.

---

## 2. Anatomy

```markdown
#### <symbol> <Friendly name> <change badge>
`<CodeName>` · <N> methods · <M> in scope

- <badge> `<method in scope>` · <annotation>
- ...

<out-of-scope methods: named or counted>
```

| Part | Rule |
| :--- | :--- |
| Title | Type symbol and friendly name exactly as on the map, plus the change badge. Unchanged components read `· unchanged` instead of a badge. |
| Size line | Code name, total methods after the change, and how many are in scope. A new component omits `· M in scope`: all of it is in scope. |
| Methods in scope | Fixed order: 🔧 altered (`· before: <old signature>`), 🆕 new, 🗑️ removed (struck through), then used without modification (`· _used by this change_`). |
| New component | Lists its methods without per-method badges. |
| Signatures | Parameter names and a simplified return (`→ Invoice[]`); drop generics, wrappers (`Promise<…>`, `Result<…>`), and full type paths. |
| Out of scope | **≤ 3**: name them on one line. **> 3**: count only. Names only, never signatures. |

Write labels (`methods`, `in scope`, `before`, `used by this change`) in the reader's language: the session language in conversation, the team or repository language in a pull request.

---

## 3. Destination Variants

Cards are plain Markdown in every destination; they are never boxes or tables. Lists keep emojis aligned, so cards use the emoji badges even in the terminal. Only the out-of-scope line changes, because terminals do not render HTML.

### Rendered Markdown (GitHub, docs, artifacts)

```markdown
#### ◇ Invoices 🔧
`InvoiceRepository` · 12 methods · 3 in scope

- 🔧 `markReminded(id, at, channel)` · before: `markReminded(id, at)`
- 🆕 `findOverdue(asOf) → Invoice[]`
- 🗑️ ~~`findPendingReminders()`~~
- `findById(id) → Invoice` · _used by this change_

<details><summary><sub>+9 methods out of scope</sub></summary>

`save` · `delete` · `findByCustomer` · `findByPeriod` · `countOpen` · `sumOpen` · `archive` · `restore` · `exists`

</details>

#### ◇ Customers · unchanged
`CustomerDirectory` · 3 methods · 1 in scope

- `billingContact(customerId) → Contact` · _used by this change_

<sub>Out of scope: `findById` · `search`</sub>
```

Leave a blank line after `<summary>` and before `</details>`, or GitHub will not render the Markdown inside.

### Terminal

Same structure without HTML:

```markdown
#### ◇ Invoices 🔧
`InvoiceRepository` · 12 methods · 3 in scope

- 🔧 `markReminded(id, at, channel)` · before: `markReminded(id, at)`
- 🆕 `findOverdue(asOf) → Invoice[]`
- 🗑️ ~~`findPendingReminders()`~~
- `findById(id) → Invoice` · _used by this change_

_+9 methods out of scope_
```

With three or fewer out-of-scope methods, the last line names them instead, as in the `Customers` card above, without the `<sub>` tag.

---

## 4. Contract Layer

Appended below the methods when [`../SKILL.md`](../SKILL.md) (Section 3) requires it: always in design work, and in reviews only for new or altered contracts whose guarantees or failure modes changed.

```markdown
> - **Promises:** returns invoices overdue as of a date, oldest first; never null.
> - **Hides:** the storage query and what "overdue" means in storage terms.
> - **Failure modes:** `StorageUnavailable` (safe to retry) · no overdue invoices is an empty list, not an error.
```

| Line | Content |
| :--- | :--- |
| Promises | Observable behavior callers rely on, in one sentence. |
| Hides | The knowledge this component owns so callers do not have to (why it is deep). |
| Failure modes | Errors preserved in the contract and conditions defined out of existence. |

Keep each line to one sentence; longer explanations belong in the text around the card.
