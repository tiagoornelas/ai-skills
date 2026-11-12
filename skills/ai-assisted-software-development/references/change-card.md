# Change Card

> **Central thesis**: the human directing architect ratifies the high-level things a change brings into the system (a module, a package, infrastructure, an entity) and nothing below them. The change card shows only those, as a tree of the system with each new thing hanging where it lives, so the human sees in a glance what enters and what is theirs to ratify. It is the visual form of [the three tiers](../SKILL.md#4-the-boundary-test): tier 1 never appears; tiers 2 and 3 do.

---

## 1. When It Is Printed

- **In a design or split plan**: one card per delivery, from what it will add.
- **At delivery**, inside the [delivery report](human-facing-communication.md#3-the-delivery-report), and in the PR body's What Changes section ([`pull-request`](../../pull-request/SKILL.md)).
- **On demand**, through [`human-review`](../../human-review/SKILL.md) or [`provide-evidence`](../../provide-evidence/SKILL.md).

Between those moments, a message names the change in one line and does not repeat the card.

## 2. The Tree

The places of the system are the branches: the repository, or in a single repository its top-level area (`backend`, `web-app`, `infra`, `db`, `deps`). Each thing the change brings in is a leaf under the place it lives, with one mark, a product-level name, and its kind:

| Mark | Meaning |
| :---: | :--- |
| `+` | New, and ratified or following an existing sibling. |
| `~` | Changed: an existing thing whose role, reach, or configuration changes. |
| `-` | Removed. |
| `?` | Decided by the agent and awaiting ratification; ends with its cost to reverse when it is hard. |
| `!` | Out of the project's pattern, crossing a boundary, contract, or dependency direction, weakening a rule or test, or provisional; says what it departs from, and ends with `to ratify`. |

**What earns a leaf**: module or folder · library or package · infrastructure (service, database, queue, bucket, cloud function, secret or permission, recurring cost) · entity or table · route or endpoint · job or schedule · client to another system · configuration variable or flag · cross-cutting mechanism (authentication, timeouts, retries, logging, error handling, data access) · screen · prompt or agent tool. A new client, variable, or mechanism earns its leaf even inside an existing folder, so nothing built on the side hides.

**After the tree**, in plain sentences of the reader's language, outside the text block: each business rule that changes, with before and after; each kind of production data deleted, rewritten, or sent to a new third party, with how it is undone; then one sentence on what does not change (rules, data, boundaries, contracts), so silence never hides an omission. No fixed labels.

**Never on the card**: methods, signatures, files, helpers, internal refactors, tests, commits, and counts. When one of these changes a behavior, contract, boundary, or risk, the card shows that consequence.

**Last line**: `⚖️ <N> to ratify`, or `nothing to ratify`. Each `?` and `!` leaf, and each rule change, opens one [decision to ratify](human-facing-communication.md#presenting-decisions-taken), ordered by cost to reverse.

Every word is in the language of where the card appears: the session's in conversation, the PR's in its body. Inside the tree, only one-column marks; no emoji.

## 3. Example

A fictional delivery, in a plain text block so the tree stays aligned:

```text
billing-api
├─ invoices
│  └─ + PDF export             module
├─ db
│  └─ ? exported invoices      table · easy to reverse
├─ deps
│  └─ + PDF library            package
└─ jobs
   └─ ! PDF rendering job      job · layout inside the job; other documents use the templates folder · to ratify
infra
└─ ? invoice PDF bucket        bucket · about $4 a month
web-app
└─ + "Download PDF" button     screen
```

Exported PDFs are now deleted after 90 days; before, they were kept forever. Nothing else changes: no data is rewritten or sent out, and boundaries and contracts stay as they were.

⚖️ 5 to ratify

A change that brings in nothing prints only the sentence on what does not change and `nothing to ratify`.

## 4. PR Line

Every PR is written the same way, in any message about the work: its steps in the order they happen, each with its mark; the first step that is not ✅ is where the PR stands.

```text
<repo>#<number>  <short name>  <mark> CI ─ <mark> agent ─ <mark> proof ─ <mark> you[ ─ ✅ merged]   [<note>]
```

- **`<repo>`** is the repository name without its owner (`web-app#212`). **`<short name>`** is two to four words naming what the PR changes. Align the steps when several PRs are listed.
- **Marks**: ✅ done · ⏳ running · ❌ failed · ⚠️ outdated (it covers an earlier commit) · ⬜ not yet · 👀 the human's turn.
- **CI**: the worst state among its checks (a cancelled check is ❌); ⬜ when it has none. A conflict also marks CI ❌, with the note `conflict`, because the PR cannot merge as it is. **agent**: ✅ only for a clean branch-mode `agent-self-review` on the head. **proof**: ✅ only when all six [evidence](../../provide-evidence/references/evidence-dossier.md) lines are ✅ for the head. **you**: 👀 when the human owes the review or ratification, ✅ when approved, ❌ when changes were requested; never 👀 before the proof is ✅.
- **Merged**: the trail ends in `✅ merged` and keeps the proof's own mark, so a PR merged with ⬜ or ⚠️ proof shows it.
- **Note**, only when it matters, in a few words: `draft`, `conflict`, what failed, or what the outdated proof covers.
- A missing note on the head reads ⬜, never "not reviewed": its absence on this machine proves nothing.

```text
billing-api#88  invoice PDF export   ⏳ CI ─ ⬜ agent ─ ⬜ proof ─ ⬜ you
web-app#212     download PDF button  ✅ CI ─ ✅ agent ─ ✅ proof ─ 👀 you
infra#41        invoice PDF bucket   ✅ CI ─ ✅ agent ─ ⚠️ proof ─ ⬜ you   proof covers an earlier commit
```

## 5. Success Validation

- [ ] The card was printed only in a plan, at delivery, or on demand.
- [ ] It was a tree of the system's places with one leaf per high-level thing brought in, each with its mark, a product-level name, and its kind; nothing below that level appeared.
- [ ] Rule changes, data deleted, rewritten, or sent out, and what does not change were plain sentences in the reader's language, with no fixed labels.
- [ ] Every `?` and `!` item was counted on the last line and opened a decision to ratify, ordered by cost to reverse.
- [ ] Every word was in the language of where the card appeared, with no emoji inside the tree.
