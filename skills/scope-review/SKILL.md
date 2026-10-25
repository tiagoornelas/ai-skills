---
name: scope-review
description: >-
  Evaluates scope, marginal business value, and architectural or maintenance
  trade-offs in an idea, plan, ongoing task, or PR. Use when defining what to
  build, challenging a costly capability, or assessing whether a smaller or
  different solution better serves the objective.
argument-hint: "[idea, plan, task, PR, or scope question]"
---

# Scope Review

Help the human choose a useful scope, before or after code exists. This skill can be called independently or contribute its criteria to an existing design/review without a second investigation.

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

- [ ] Recommendation relates marginal benefit to concrete costs and continuing obligations.
- [ ] A plausible design improvement was considered before recommending a cut.
- [ ] Lost benefits, assumptions, and uncertainty are visible; complexity alone did not determine the conclusion.
- [ ] Depth matches the request and Human Layer authority is preserved.
