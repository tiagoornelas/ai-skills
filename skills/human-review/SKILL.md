---
name: human-review
description: >-
  Guides the user through a PR, local diff, or ongoing delivery, their own or
  someone else's, answering "what changed, where does it live, and what do I
  need to understand or decide?": one sentence on what changes for whom, the
  change card built from the actual change, the decisions that are the user's,
  and the critical findings that matter, each with its consequence. Explains
  a part in depth only when the user points at it. Stays critical: it judges
  the change, it does not approve it. Use on demand.
argument-hint: "[PR, diff, delivery, or focused review question]"
---

# Human Review

The user directs many systems and cannot read every diff. This skill is their guide to one change: **what changed, where it lives, and what do I need to understand or decide?** It applies [`ai-assisted-software-development`](../ai-assisted-software-development/SKILL.md) whoever wrote the work, and presumes neither implementation quality nor a prior self-review.

## 1. Investigate Once

Establish the scope (the PR, the branch against its base, or the uncommitted diff). Derive everything from the actual change and the relationships it touches; look beyond the diff only where a consumer, a sibling module, or a contract decides a consequence. Separate what is demonstrated, what is inferred, and what is unknown. No whole-repository audit, review axes, test runs, or redesign unless the user asks.

## 2. Show

In the user's language, briefed per [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md):

1. **One sentence**: what changes, for whom, in product terms.
2. **The [change card](../ai-assisted-software-development/references/change-card.md)**, built from the change itself, not from the author's description (for a large PR, by the light path of [`provide-evidence`](../provide-evidence/SKILL.md#2-gather)): what is new and where it lives, business rules, data, pattern followed or built on the side, walls, state.
3. **What is yours to decide**: each pending Human Layer decision the change embeds (a rule, a contract, a new component no one approved, a trade-off with a lasting [maintenance commitment](../software-designing/references/maintenance-commitment.md)), as a decision card with a recommendation. Do not infer that the author consciously accepted a trade-off just because the code embodies it.
4. **What matters**: only the findings with a concrete consequence (a plausible failure or change scenario, its impact, a direction of solution and its trade-off), most consequential first. Distinguish problems the change introduced or aggravated from old ones. A preference without a consequence is not a finding.

Omit every empty part except the card, which is always shown. Never list method names, helpers, internal refactors, lint, or test bodies, unless they change a behavior, contract, boundary, or risk; then show that consequence.

## 3. Stay Critical

- Judge architecture with the relevant [`software-designing`](../software-designing/SKILL.md) lenses, and value with [`scope-review`](../scope-review/SKILL.md)'s three questions, inside the same investigation. Consider a healthier design before suggesting a cut.
- Compare what the change claims (description, issue, docs) with what it does, and name divergences.
- Respect accepted concessions; reopen them only with new evidence, a higher cost, or a broken premise.
- Name what is unverified. Whether the change is proven is [`provide-evidence`](../provide-evidence/SKILL.md)'s job: point to it, never imply proof. A favorable review is not an approval or a readiness to merge.

## 4. Explain on Request

When the user points at a part ("explain this job", "why this table?"), explain that part only, following [`explain-it`](../explain-it/SKILL.md), situated in the product and drawn with [`visualize-it`](../visualize-it/SKILL.md) when a picture helps. Never explain the whole change unasked.

## 5. Local Review Note

When the reviewed scope ends at a commit that exists locally, record that the review ran:

```bash
git notes --ref=human-review add -f -m "human-review <ISO-8601 date> recommendation: <one-line recommendation>" <reviewed commit>
```

It records that a review ran and what it recommended, never an approval. It stays local and never alters history. Skip it for uncommitted diffs or commits not available locally.

## 6. Success Validation

- [ ] The output opened with one sentence on what changes for whom, then the change card built from the actual change.
- [ ] Only the user's decisions (as cards) and findings with a concrete consequence followed; nothing below contracts appeared unless it changed behavior, contract, boundary, or risk.
- [ ] Divergences between claims and the change, and what is unverified, were named; no proof or approval was implied.
- [ ] A part was explained in depth only when the user pointed at it.
- [ ] A local `human-review` note was recorded on the reviewed commit when it exists locally.
