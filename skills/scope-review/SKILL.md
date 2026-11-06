---
name: scope-review
description: >-
  Evaluates scope, marginal business value, and architectural or maintenance
  trade-offs in an idea, plan, ongoing task, or PR, answering three standing
  questions: is it worth doing, what comes first and why, and what can be
  chosen not to be done and what is lost (do, reduce, postpone with a resume
  condition, or stop). Use when defining what to build, prioritizing open
  work, challenging a costly capability, or assessing whether a smaller or
  different solution better serves the objective.
argument-hint: "[idea, plan, task, PR, or scope question]"
---

# Scope Review

Help the human choose a useful scope, before or after code exists. This skill can be called independently or contribute its criteria to an existing design/review without a second investigation.

## Three Standing Questions

Every scope review answers, in the human's terms:

1. **Is it worth doing?** The benefit for whom, against its remaining cost and continuing [maintenance commitment](../software-designing/references/maintenance-commitment.md).
2. **What comes first, and why?** Among the work open alongside it, what unblocks or returns the most soonest.
3. **What can I choose not to do, and what is lost?** What leaves, what is lost with it, and what still stands.

Each answer ends in one verdict: **do**, **reduce** (to what smaller thing), **postpone** (with the condition that resumes it), or **stop**. Not doing is a legitimate outcome, before code exists and again while the work is under way. Work already spent never justifies continuing; that an AI can build something quickly is not evidence that it is worth having. No scores or rankings that pretend to precision.

## Approach

Start with the objective, intended beneficiaries, and constraints. Investigate available context before asking questions; ask when missing business information could change the recommendation. For existing work, assess actual behavior and dependencies rather than treating the author's description as evidence of implementation.

Compare the marginal benefit of a capability with its limitations, initial change footprint, and [maintenance commitment](../software-designing/references/maintenance-commitment.md). Consider partial support, architectural concessions, operational obligations, and coordination. Complexity or the number of repositories alone does not justify removing scope.

Before proposing a cut, consider a plausible healthier design that preserves the benefit. Compare improving the design, reducing/substituting scope, and accepting the concession at the depth the decision warrants. Do not turn a brief recommendation into several complete designs.

Preserve the objective unless evidence exposes a contradiction, invalid premise, or overlooked consequence that warrants questioning it. Respect accepted trade-offs; reopen them only with relevant new evidence or changed premises/cost.

## Communicate and continue

Present the decision-relevant benefit, commitment, alternatives, and recommendation, including lost value and uncertainty. Distinguish evidence from inference and business assumptions. Use [visualize-it](../visualize-it/SKILL.md) when a comparison or boundary is clearer visually; explain domain terms before internals.

The human decides scope, behavior, and architecture under [ai-assisted-software-development](../ai-assisted-software-development/SKILL.md). End with the useful recommendation or the decisive question. Continue implementation only when requested/authorized; use [software-designing](../software-designing/SKILL.md) for architectural decisions and [coding](../coding/SKILL.md) for code changes within the same session as appropriate.

## Proportional use

During ordinary work, a concrete signal already encountered may justify a brief alert. Broad investigations, cross-repository exploration, multiple agents, complete alternative designs, and artifacts are deeper work on demand. No mandatory interview, score, persistent decision record, or downstream skill chain. Reuse evidence from an ongoing review; do not re-run it to apply this lens.

## Success Validation

- [ ] The three questions were answered (worth doing, what first, what not to do and what is lost), each ending in do, reduce, postpone with its resume condition, or stop, without scores.
- [ ] Recommendation relates marginal benefit to concrete costs and continuing obligations; sunk cost and ease of AI construction were not counted as value.
- [ ] A plausible design improvement was considered before recommending a cut.
- [ ] Lost benefits, assumptions, and uncertainty are visible; complexity alone did not determine the conclusion.
- [ ] Depth matches the request and Human Layer authority is preserved.
