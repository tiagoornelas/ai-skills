# Change Card

> **Central thesis**: the human directing architect cares about a few things in every change and nothing else: what is **new and where it lives**, which **business rules** change, whether each new thing **follows an existing pattern or was built on the side**, whether a **wall was knocked down**, and the state of the work and its proof. The change card shows exactly those, in a fixed, glanceable block, so the human sees them without reading the diff. It is the visual form of [the three tiers](../SKILL.md#4-the-boundary-test): tier 1 never appears; tier 2 appears as new things and where they live; tier 3 appears as rules, walls, things built on the side, and data deleted or rewritten.

---

## 1. When It Is Printed

Only at these moments, never on every reply:

1. **Before building**: in the [notice](human-facing-communication.md#announcing-before-building) of a tier-2 item, and in a plan that splits work among agents (one card per stream, from what the plan will add).
2. **At delivery**: when a change is presented as ready for the human, together with its [evidence](../../provide-evidence/references/evidence-dossier.md).
3. **On demand**: when the human asks to see a change ([`human-review`](../../human-review/SKILL.md)) or its proof ([`provide-evidence`](../../provide-evidence/SKILL.md)).

Between those moments, status messages name the change in one line and do not repeat the card.

## 2. Content (Mandatory)

The layout in Section 3 is an example; this content is not optional.

| Block | What it says |
| :--- | :--- |
| **New and where it lives** | Every new thing that runs, costs, stores data, holds permissions, or creates a place in the code, one per line: **kind · name · where** (path or module), and for infrastructure the file that creates it (the migration, the deploy or infrastructure definition). Each item says how it was approved: *in the approved split*, *notice <date>*, *decided by you <date>*, or ⚠️ *no record*. |
| **Business rule** | Each rule that changes, with a before and after in one line and the human's decision that approved it; or "none". |
| **Data** | Production data the change deletes or rewrites, and how it is undone; or "none". |
| **Pattern** | For each new thing: the existing sibling it follows (path), or ⚠️ *built on the side* with what it duplicates or departs from; see [nothing built on the side](../../software-designing/SKILL.md#nothing-built-on-the-side). |
| **Walls** | Boundaries, contracts, dependency direction, project rules, and tests: "intact", or ⚠️ which one was crossed or weakened and why. |
| **State** | The [PR line](#4-pr-line), whose proof state says whether the proof is for the current version; before a PR exists, the branch or the plan. |

**Kinds of new things**, always all accounted for: database · table · migration · service · cloud function · job or schedule · queue · route or endpoint · secret or permission · recurring cost · folder or module · client (to another system or service) · configuration variable · cross-cutting mechanism (authentication, timeouts, retries, logging, error handling, data access). These are the same structures lines (b) and (d) of the [evidence dossier](../../provide-evidence/references/evidence-dossier.md) check: a new client, configuration variable, or mechanism is listed even when it sits in an existing folder, so one built on the side never gets a clean card. Kinds with nothing new are printed together on one "none" line, so silence never hides an omission.

**Never on the card**: method or function names, signatures, parameters, helpers, internal refactors, lint, test bodies, the order of commits. When one of these changes behavior, a contract, a boundary, or a risk, the card shows that consequence, not the detail.

## 3. Example Layout

In the human's session language; every fixed word is a placeholder to translate.

```text
Invoices · purge expired invoices · notice 2026-11-04
New and where it lives
  table   billing_invoices           db/migrate/20261105_create_billing_invoices.rb   notice 2026-11-04
  job     expired-invoice purge      app/jobs/invoice_purge_job.rb                    decided by you 2026-11-04
  route   DELETE /internal/invoices  config/routes.rb                                 notice 2026-11-04
  none    database, service, cloud function, queue, secret or permission, cost, folder or module,
          client, configuration variable, cross-cutting mechanism
Business rule  invoices expired for 90 days are deleted (was: kept forever) · decided by you 2026-11-04
Data           deletes expired invoices · undo: restore from the daily backup
Pattern        job follows app/jobs/session_purge_job.rb · route follows the other internal routes
Walls          intact
State          👀 web-app#212 · invoice purge · CI ok · agent ok · proof ok · you pending
```

Before building, **State** reads the branch or the plan, and items carry the approval they will have. A change that adds nothing new prints the "none" line and the other blocks; an internal-only change prints only "none" lines and "intact", never its methods.

## 4. PR Line

Every PR is written the same way, on the card and in any message about the work:

```text
<emoji> <repo>#<number> · <short name> · [draft · ][conflict · ]CI <state> · agent <state> · proof <state> · you <state>
```

- **`<repo>`** is the repository name without its owner (`web-app#212`). **`<short name>`** is two to four words naming what the PR changes.
- **`draft`** and **`conflict`** appear only when true.
- **CI**: the worst state among its checks: `failing`, `running`, `cancelled`, `ok`; `—` when it has none.
- **agent**: the author's self-review on the PR head: `ok` (a clean branch-mode `agent-self-review`), or `—` for no record.
- **proof**: the [evidence](../../provide-evidence/references/evidence-dossier.md) of the PR head: `ok` (all six lines ✅ for the current head), `failing` (a line is ❌), `outdated` (it proves an earlier commit), or `—` for no record.
- **you**: the human's review: `ok` (approved), `changes` (changes requested), `pending` (ready for them: not a draft, CI ok, agent ok, proof ok), or `—` for no record. Without `proof ok` it is never `pending`: the work is not ready for the human yet.
- **Leading emoji**, the worst that applies: ❌ conflict, CI failing, or proof failing · ⏳ draft, CI running, agent review missing, or proof outdated or missing · 👀 proven and the human owes the review · ✅ proven and approved, ready to merge. An unproven PR is never 👀 or ✅.
- A missing note reads "no record" (`—`), never "not reviewed": its absence on this machine proves nothing.

## 5. Success Validation

- [ ] The card was printed only before building (notice or split plan), at delivery, or on demand.
- [ ] Every new thing had kind, name, where it lives (and its migration or infrastructure definition), and its approval; every kind with nothing new was on the "none" line.
- [ ] Business rule, data, pattern, and walls were each stated, "none" or "intact" included.
- [ ] No method, signature, helper, internal refactor, lint, test body, or commit order appeared, except as a consequence on behavior, contract, boundary, or risk.
- [ ] The state used the PR line, and at delivery said whether the proof is for the current version.
