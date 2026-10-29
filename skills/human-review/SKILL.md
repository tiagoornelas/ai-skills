---
name: human-review
description: >-
  Explains and critically evaluates the Human Layer of a PR, local diff, or
  ongoing delivery: actual business changes, embedded decisions, trade-offs,
  maintenance commitments, architecture, contracts, and behavior verification.
  Use on demand for the user's own work or changes by others.
argument-hint: "[PR, diff, delivery, or focused review question]"
---

# Human Review

The agent investigates, diagnoses, and recommends; the human decides business and architectural trade-offs. Apply [ai-assisted-software-development](../ai-assisted-software-development/SKILL.md) regardless of who authored the work. Do not presume implementation quality or a prior self-review.

## Investigate once

Establish the comparison or delivery scope. Derive conclusions from actual changes and affected relationships; inspect consumers, similar modules, and contracts selectively beyond the diff when needed. Separate demonstrated consequences, inferences, and unknown context. Existing patterns inform the evaluation but are not immune to criticism.

Reuse one investigation for business interpretation, architectural judgment, and scope/value assessment. No automatic whole-repository audit, parallel review axes, test execution, complete redesign, or skill chain is required. Broader investigation and systematic Agent Layer review are available on demand. Report material defects encountered even when they sit below contracts.

## Explain decisions before structure

Lead with what changes for whom and which decisions deserve attention. Investigate relevant behavior changes, business rules/restrictions, trade-offs, unverified premises, and [maintenance commitments](../software-designing/references/maintenance-commitment.md). Present selectively: omit empty categories and routine details. Do not infer conscious acceptance by the author merely because the implementation embodies a trade-off.

Compare documentation/declarations with implementation in a separate divergence note only when they disagree. Expected acceptance criteria remain a source for verification, not proof of what the code does; do not invent requirements from the diff.

## Assess architecture and scope

Apply relevant [software-designing references](../software-designing/SKILL.md#4-references-loaded-on-demand) and known contracts/decisions. For a material concern, connect observed structure to a plausible change or failure scenario, recurring obligation/impact, and a direction of solution with trade-offs and uncertainty. Compare the obligation of the remedy with the current design; shared code can introduce harmful coupling too.

Distinguish introduced problems, aggravated problems, and independent old problems. Keep unrelated improvements outside the delivery's required scope. Respect accepted concessions; reopen them with new evidence, increased cost, or invalid premises. Severity and confidence are distinct; stylistic preference without a concrete consequence is not a finding.

Apply [scope-review](../scope-review/SKILL.md)'s criteria to material benefit/cost questions within the same investigation. Consider healthier design before cutting scope. Question business assumptions when evidence warrants it; recommendations do not change the objective or authorize implementation.

Use [visualize-it](../visualize-it/SKILL.md) to make relevant boundaries, dependencies, and contracts visible. Keep views proportional to the question and change; show interface cards when a new/changed contract or an unchanged guarantee is material to the reasoning, not a catalog of every used method. Explain business context and unfamiliar terms before internals; a separate explain-it run or artifact is not required.

## Verification and decision

Summarize available evidence for relevant acceptance criteria. Disclose missing specifications, unverified behavior, and review coverage. A favorable Human Layer assessment does not certify tests, internal implementation, or readiness to merge. Focused follow-up can be recommended with its reason; do not automatically run a full low-level review.

This is the canonical DoD status legend shared across skills:

| Status | Meaning |
| :---: | :--- |
| ✅ | Covered by a named automated test verifying behavior through the public interface. |
| 🔎 | Not code-testable; verified by alternative means, with method disclosed. |
| 👤 | Requires manual human validation. |
| 🚨 | Missing, or lacking both test coverage and declaration. |

When a table helps, use: **Status · Delivered behavior · Verification evidence · Action for human**. Do not present prompt instructions or documentation as automated verification.

End with the recommendation, relevant limitations, and genuine pending decisions, each as a decision card in system terms ([human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md)). Highlight consequential findings first, retaining useful supporting findings below without searching exhaustively for more. No automatic approval, comments, or code changes follow; the only persistent record is the local review note below. An architectural decision can warrant resolution before merge even when no current bug is demonstrated.

## Local review note

When the reviewed scope ends at a commit that exists locally (a local branch, or a PR whose head `git cat-file -e <sha>` finds), record that the review ran:

```bash
git notes --ref=human-review add -f -m "human-review <ISO-8601 date> recommendation: <one-line recommendation>" <reviewed commit>
```

The note records that a review ran and what it recommended, never an approval. It stays local (git does not push notes by default) and never alters history. Skip it for uncommitted diffs or commits not available locally.

For an explicitly requested batch triage, prioritize which changes warrant deeper analysis, state the limited coverage, and reuse gathered evidence on follow-up. Triage is not continuous monitoring and does not certify unexamined PRs.

## Success Validation

- [ ] Business consequences and embedded decisions derive from the actual change.
- [ ] Architectural and scope recommendations have evidence, concrete consequences, and trade-offs.
- [ ] Relevant structure/contracts are visible using visualize-it, without unrelated catalogs.
- [ ] Coverage, uncertainty, and behavior verification are explicit; Human Layer conclusions do not imply Agent Layer validation.
- [ ] Existing decisions and human authority are respected; depth and output match the request.
- [ ] A local `human-review` note was recorded on the reviewed commit when it exists locally, and skipped otherwise.
