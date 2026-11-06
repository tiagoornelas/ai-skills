---
name: human-review
description: >-
  Guides the user through a PR, local diff, or ongoing delivery, their own or
  someone else's, answering "what changed, where does it live, and what do I
  need to understand or decide?" in one screen: one sentence on what changes
  for whom, the change card's plan built from the actual change, the critical
  findings with their consequence, and one line on the proof. Explains a part
  in depth only when the user points at it. Stays critical: it judges the
  change, it does not approve it. Use on demand.
argument-hint: "[PR, diff, delivery, or focused review question]"
---

# Human Review

The user directs many systems and cannot read every diff. This skill is their guide to one change: **what changed, where it lives, and what do I need to understand or decide?** It applies [`ai-assisted-software-development`](../ai-assisted-software-development/SKILL.md) whoever wrote the work, and presumes neither implementation quality nor a prior self-review.

## 1. Investigate Once

Establish the scope (the PR, the branch against its base, or the uncommitted diff). Derive everything from the actual change and the relationships it touches; look beyond the diff only where a consumer, a sibling module, or a contract decides a consequence. Separate what is demonstrated, what is inferred, and what is unknown. No whole-repository audit, review axes, test runs, or redesign unless the user asks.

## 2. Show One Screen

In the user's language, per [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md); the layout is an example, the content is mandatory:

```text
<one sentence: what changes, for whom, in product terms>

<the plan of the change card>
<the decision card of each `?` line that blocks merge>

<Findings>
  🔴 <what goes wrong, for whom, when> → <direction of a fix and its trade-off>
  <N smaller findings on request>
<proof>  <N>/6 on <short commit> · <missing: each failing letter and name>
```

1. **The [change card](../ai-assisted-software-development/references/change-card.md)'s plan**, built from the change itself, not from the author's description (for a large PR, by the light path of [`provide-evidence`](../provide-evidence/SKILL.md#2-gather)). Its `?` lines are the user's decisions the change embeds, each with its options or default, the recommendation, and whether it blocks merge: a rule, a contract, a new component no one approved, a trade-off with a lasting [maintenance commitment](../software-designing/references/maintenance-commitment.md). Do not infer that the author consciously accepted a trade-off just because the code embodies it.
2. **Critical findings only**: 🔴, and 🟡 that change a behavior, each one or two lines with a plausible scenario, its impact, and a direction of solution with its trade-off, most consequential first; mark a problem the change did not introduce as older. A preference without a consequence is not a finding. Other findings are counted and given on request.
3. **One proof line**, read from the delivery's evidence note by [`provide-evidence`](../provide-evidence/SKILL.md)'s show rules: how many of the six lines hold on which commit and which are missing, "outdated: proves X, the PR is at Y", or "no record on this machine".

Omit the findings when there are none; the plan and the proof line always appear. Nothing below contracts appears unless it changes a behavior, contract, boundary, or risk; then the screen shows that consequence.

## 3. Stay Critical

- Judge architecture with the relevant [`software-designing`](../software-designing/SKILL.md) lenses, and value with [`scope-review`](../scope-review/SKILL.md)'s three questions, inside the same investigation. Consider a healthier design before suggesting a cut.
- Compare what the change claims (description, issue, docs, a presented card) with what it does, and name divergences.
- Respect accepted concessions; reopen them only with new evidence, a higher cost, or a broken premise.
- Name what is unverified. The proof line reports; whether the change is proven is `provide-evidence`'s job, never implied here. A favorable review is not an approval or a readiness to merge.

## 4. Explain on Request

When the user points at a part ("explain this job", "why this table?", a `?` or `!` line), explain that part only, following [`explain-it`](../explain-it/SKILL.md), situated in the product and drawn with [`visualize-it`](../visualize-it/SKILL.md) when a flow helps. A non-blocking `?` line the user turns to becomes a decision card with a recommendation. "Where does it live?" adds the change card's [where it lives](../ai-assisted-software-development/references/change-card.md#4-where-it-lives-optional-detail) detail. Never explain the whole change unasked.

## 5. Local Review Note

When the reviewed scope ends at a commit that exists locally, record that the review ran:

```bash
git notes --ref=human-review add -f -m "human-review <ISO-8601 date> recommendation: <one-line recommendation>" <reviewed commit>
```

It records that a review ran and what it recommended, never an approval. It stays local and never alters history. Skip it for uncommitted diffs or commits not available locally.

## 6. Success Validation

- [ ] The screen opened with one sentence on what changes for whom, then the change card's plan built from the actual change, with the user's decisions as `?` lines carrying options and recommendation, and a decision card for each one that blocks merge.
- [ ] Only critical findings followed, each with scenario, impact, and direction; the others were counted, not listed; nothing below contracts appeared unless it changed behavior, contract, boundary, or risk.
- [ ] One proof line closed the screen, read from the evidence note; divergences between claims and the change, and what is unverified, were named; no proof or approval was implied.
- [ ] A part was explained in depth, or a non-blocking `?` line turned into a decision card, only when the user pointed at it.
- [ ] A local `human-review` note was recorded on the reviewed commit when it exists locally.
