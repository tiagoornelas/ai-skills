# Change Card

> **Central thesis**: the human directing architect cares about a few things in every change and nothing else: what is **new and where it lives**, which **business rules** change, whether each new thing **follows an existing pattern or was built on the side**, whether a **wall was knocked down**, and the state of the work and its proof. The change card shows exactly those as a **plan**, in the style of an infrastructure plan: one count line checkable in a second, then one line per thing. It is the visual form of [the three tiers](../SKILL.md#4-the-boundary-test): tier 1 never appears; tier 2 appears as new things and where they live; tier 3 appears as rules, data deleted or rewritten, things built on the side, and walls knocked down.

---

## 1. When It Is Printed

Only at these moments, never on every reply:

1. **Before building**: in the [notice](human-facing-communication.md#announcing-before-building) of a tier-2 item, and in a plan that splits work into deliveries (one card per delivery, from what the plan will add).
2. **At delivery**: when a change is presented as ready for the human, together with its [evidence](../../provide-evidence/references/evidence-dossier.md).
3. **On demand**: when the human asks to see a change ([`human-review`](../../human-review/SKILL.md)) or its proof ([`provide-evidence`](../../provide-evidence/SKILL.md)).

Between those moments, status messages name the change in one line and do not repeat the card.

## 2. The Plan

The layout in Section 3 is an example; this content is not optional. Every word of it is written in the human's session language; the symbols stay as they are.

**Count line**, first: `Plan: N +  N ~  N -  N ?  N !  <state>`, the number of lines carrying each symbol, then the state in a few words ("3 draft PRs, nothing merged").

**One line per thing**, grouped by symbol in that order, three columns:

| Column | What it says |
| :--- | :--- |
| **Symbol** | `+` new · `~` changed · `-` removed · `?` the human's to decide · `!` out of pattern, crosses a wall, or provisional. |
| **What** | A product-level noun the human recognizes ("table of exported invoices", "Download PDF button"), never a method, class, or file name. |
| **Kind · place** | The kind of thing and the place of the system it lives in (`table · billing-api`, `screen · web-app`, `flag · billing-api · off`). In a delivery across repositories, the place is the repository. |

What each part of the change becomes on the plan:

| Part | On the plan |
| :--- | :--- |
| **New and where it lives** | A `+` line per new thing of the kinds below; the [where it lives](#4-where-it-lives-optional-detail) detail gives its folder or file, and for infrastructure the file that creates it (migration, deploy or infrastructure definition). |
| **Approval** | `+` and `~` lines are approved: in the approved split, by a notice whose deadline passed, or by the human's decision; the `approved` closing line says which. An item with no record, or a notice still running, is a `?` line. |
| **The human's decisions** | A `?` line carries its options, or the default that applies without an answer, the recommendation, and whether it blocks merge ("90 days (recommended) or kept forever · blocks merge", "goes ahead Fri 12:00 unless you object"). The `?` lines are the upfront list of the decisions; each opens as a [decision card](human-facing-communication.md#every-decision-fully-explained). |
| **Business rule** | A `~` line of kind `rule` with before and after ("expired invoices deleted after 90 days (was: kept)"), or a `?` line while undecided. |
| **Data** | A line of kind `data` for production data deleted or rewritten (with how it is undone) and for data sent to a new third party or processor (what leaves, to whom). Deleting or rewriting production data is always the human's decision ([tier 3](../SKILL.md#4-the-boundary-test)). |
| **Pattern** | A thing without `!` follows an existing sibling; a thing [built on the side](../../software-designing/SKILL.md#nothing-built-on-the-side) is a `!` line saying what it duplicates or departs from. |
| **Walls** | Boundaries, contracts, dependency direction, project rules, and tests crossed or weakened are `!` lines saying which and why. |
| **State** | The `<state>` of the count line, and a `state` closing line with one [PR line](#5-pr-line) per PR; before a PR exists, the branch or the plan. |

**Closing lines**, after the things: `order` (merge order, when there is more than one PR), `missing` (what is left before the delivery is done), `approved`, `unchanged` (every kind below with nothing new; "no rule changed" when there is no `rule` line; "no data deleted, rewritten, or sent out" for each of those with no `data` line; and "walls intact" when no `!` line crosses a wall; it may wrap), and `state`. Omit `order` and `missing` when empty; the others always appear, so silence never hides an omission.

**Kinds of new things**, always all accounted for, on a line or in `unchanged`: database · table · migration · service · cloud function · job or schedule · queue · route or endpoint · secret or permission · recurring cost · folder or module · client (to another system or service) · library · configuration variable or flag · cross-cutting mechanism (authentication, timeouts, retries, logging, error handling, data access) · screen · prompt or agent tool. These are the structures lines (b) and (d) of the [evidence dossier](../../provide-evidence/references/evidence-dossier.md) check: a new client, configuration variable, or mechanism is listed even when it sits in an existing folder, so one built on the side never gets a clean card.

**Never on the plan**: method or function names, signatures, parameters, helpers, internal refactors, lint, test bodies, the order of commits. When one of these changes behavior, a contract, a boundary, or a risk, the plan shows that consequence, not the detail.

**Marks**: where the destination colors text, only `?` and `!` lines carry color; elsewhere the symbol carries the meaning. No emoji inside the card except the leading emoji of a PR line.

## 3. Example

A fictional delivery across three repositories, in a plain text block so the columns stay aligned:

```text
Plan: 9 +  2 ~  0 -  2 ?  1 !  3 draft PRs, nothing merged

  +  table of exported invoices         table · billing-api
  +  migration creating that table      migration · billing-api
  +  "export invoice as PDF" route      route · billing-api
  +  PDF rendering job                  job · billing-api
  +  PDF library                        library · billing-api
  +  flag for the PDF export            flag · billing-api · off
  +  storage bucket for the PDFs        bucket · infra
  +  "Download PDF" button              screen · web-app
  +  "preparing your PDF" notice        screen · web-app
  ~  invoice page offers the export     screen · web-app
  ~  deploy passes the new flag         deploy · billing-api
  ?  PDFs deleted after 90 days         rule · 90 days (recommended) or kept forever · blocks merge
  ?  bucket storage, about $4 a month   cost · goes ahead Fri 12:00 unless you object (recommended)
  !  PDF layout written inside the job  out of pattern · other documents use the templates folder

  order      infra → billing-api → web-app
  missing    end-to-end run in the review app · turning the flag on
  approved   the split of 2026-11-04
  unchanged  no new database, service, cloud function, queue, secret or permission, client,
             folder or module, cross-cutting mechanism, or prompt or agent tool
             no data rewritten or sent to third parties · walls intact
  state      ⏳ billing-api#88 · invoice PDF export · draft · CI ok · agent ok · proof — · you —
             ⏳ web-app#212 · download PDF button · draft · CI ok · agent ok · proof — · you —
             ⏳ infra#41 · invoice PDF bucket · draft · CI ok · agent — · proof — · you —
```

Before building, `state` reads the branch or the plan, and lines carry the approval they will have. A change that adds nothing new prints the count line, `unchanged`, and `state`; an internal-only change prints only those, never its methods.

## 4. Where It Lives (Optional Detail)

Printed under the plan when the human asks where things live, or when a `!` line needs its place shown. One block per repository (or per place, in a single repository) with a bar of how much of the change was born there, then one line per thing with its folder or file and, when the item follows an existing sibling, `follows <sibling>`; in a [notice](human-facing-communication.md#announcing-before-building) before building, every item carries that note, so the human sees the pattern before it is built. An out-of-place item appears where it actually is, marked `!` beside the bar. The detail ends with the path a user's action takes through the places, and the `unchanged` line.

```text
Where it lives   9 +   2 ~   1 !   0 -

  billing-api  ███████  +  table of exported invoices       db/schema.rb
                        +  migration creating that table    db/migrate/      follows the others
                        +  "export invoice as PDF" route    app/routes/invoices.rb
                        +  PDF rendering job                app/jobs/        follows the receipt job
                        +  PDF library                      Gemfile
                        +  flag for the PDF export          config/flags.yml
                        ~  deploy passes the new flag       deploy/app.yaml
               !        !  PDF layout                       app/jobs/render_invoice_pdf.rb
  web-app      ███      +  "Download PDF" button            src/invoices/
                        +  "preparing your PDF" notice      src/invoices/
                        ~  invoice page                     src/invoices/
  infra        █        +  storage bucket for the PDFs      buckets/invoices.tf

  path       Download PDF → export route → rendering job → bucket → link on the invoice page
  unchanged  no new service, queue, secret, or client · no data rewritten or sent to third parties
```

## 5. PR Line

Every PR is written the same way, on the card and in any message about the work:

```text
<emoji> <repo>#<number> · <short name> · [draft · ][conflict · ]CI <state> · agent <state> · proof <state> · you <state>
<emoji> <repo>#<number> · <short name> · merged · proof <state>
```

- **`<repo>`** is the repository name without its owner (`web-app#212`). **`<short name>`** is two to four words naming what the PR changes.
- **`draft`** and **`conflict`** appear only when true.
- **CI**: the worst state among its checks: `failing`, `running`, `cancelled`, `ok`; `—` when it has none.
- **agent**: the author's self-review on the PR head: `ok` (a clean branch-mode `agent-self-review`), or `—` for no record.
- **proof**: the [evidence](../../provide-evidence/references/evidence-dossier.md) of the PR head: `ok` (all six lines ✅ for the current head), `failing` (a line is ❌), `outdated` (it proves an earlier commit), or `—` for no record.
- **you**: the human's review: `ok` (approved), `changes` (changes requested), `pending` (ready for them: not a draft, CI ok, agent ok, proof ok), or `—` for no record. Without `proof ok` it is never `pending`: the work is not ready for the human yet.
- **Leading emoji**, the worst that applies: ❌ conflict, CI failing, or proof failing · ⏳ draft, CI running, agent review missing, or proof outdated or missing · 👀 proven and the human owes the review · ✅ proven and approved, ready to merge.
- **Merged** PRs use the second form: the word `merged` with the proof state of the merged head beside it (`merged · proof —`). Its emoji is ✅ only with `proof ok`, ⚠️ otherwise.
- **One rule**: a PR without `proof ok` is never 👀 or ✅, open or merged.
- A missing note reads "no record" (`—`), never "not reviewed": its absence on this machine proves nothing.

## 6. Success Validation

- [ ] The card was printed only before building (notice or split plan), at delivery, or on demand.
- [ ] It opened with the count line, whose numbers match the lines below it, then one line per thing with its symbol, a product-level noun, and kind · place.
- [ ] Every new thing had its line and its approval (or a `?` line); rule changes, data deleted or rewritten or sent to a new third party, things built on the side, and walls crossed had their lines; every kind with nothing new, and intact walls, were on the `unchanged` line.
- [ ] No method, signature, file name, helper, internal refactor, lint, test body, or commit order appeared on the plan, except as a consequence on behavior, contract, boundary, or risk; folders and files appeared only in the "Where it lives" detail.
- [ ] The `state` line used the PR line, and at delivery said whether the proof is for the current version.
- [ ] Every word was in the human's session language; only the symbols stayed as they are.
