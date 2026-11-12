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

**Below the tree**, one line each, only when present: `rule` for a business rule changed (before and after), `data` for production data deleted, rewritten, or sent to a new third party (and how it is undone). Then always a closing `unchanged` line naming what did not happen ("no rule changed · no data deleted, rewritten, or sent out · walls intact"), so silence never hides an omission.

**Never on the card**: methods, signatures, files, helpers, internal refactors, tests, commits, and counts. When one of these changes a behavior, contract, boundary, or risk, the card shows that consequence.

**Last line**, outside the tree: `⚖️ <N> to ratify`, or `nothing to ratify`. Each `?` and `!` leaf, and each `?` rule, opens one [decision to ratify](human-facing-communication.md#presenting-decisions-taken), ordered by cost to reverse.

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

rule       ? PDFs deleted after 90 days (was: kept) · hard to reverse: deleted PDFs are gone
unchanged  no data rewritten or sent out · walls intact
⚖️ 4 to ratify
```

A change that brings in nothing prints only `unchanged` and `nothing to ratify`.

## 4. PR Line

Every PR is written the same way, in any message about the work:

```text
<emoji> <repo>#<number> · <short name> · [draft · ][conflict · ]CI <state> · agent <state> · proof <state> · you <state>
<emoji> <repo>#<number> · <short name> · merged · proof <state>
```

- **`<repo>`** is the repository name without its owner (`web-app#212`). **`<short name>`** is two to four words naming what the PR changes.
- **`draft`** and **`conflict`** appear only when true.
- **CI**: the worst state among its checks: `failing`, `running`, `cancelled`, `ok`; `—` when it has none.
- **agent**: the author's self-review on the PR head: `ok` (a clean branch-mode `agent-self-review`), or `—` for no record.
- **proof**: the [evidence](../../provide-evidence/references/evidence-dossier.md) of the PR head: `ok` (all six lines ✅ for the current head), `failing` (a line is ❌), `outdated` (it proves an earlier commit), or `—` for no record.
- **you**: the human's review: `ok` (approved), `changes` (changes requested), `pending` (ready for them: CI ok, agent ok, proof ok), or `—` for no record. Without `proof ok` it is never `pending`.
- **Leading emoji**, the worst that applies: ❌ conflict, CI failing, or proof failing · ⏳ CI running, agent review missing, or proof outdated or missing · 👀 proven and waiting for the human's review · ✅ proven and approved, ready to merge.
- **Merged** PRs use the second form; its emoji is ✅ only with `proof ok`, ⚠️ otherwise.
- A missing note reads "no record" (`—`), never "not reviewed": its absence on this machine proves nothing.

## 5. Success Validation

- [ ] The card was printed only in a plan, at delivery, or on demand.
- [ ] It was a tree of the system's places with one leaf per high-level thing brought in, each with its mark, a product-level name, and its kind; nothing below that level appeared.
- [ ] Rule changes and data deleted, rewritten, or sent out had their lines, and the `unchanged` line closed the card.
- [ ] Every `?` and `!` item was counted on the last line and opened a decision to ratify, ordered by cost to reverse.
- [ ] Every word was in the language of where the card appeared, with no emoji inside the tree.
