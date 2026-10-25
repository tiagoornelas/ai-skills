---
name: improve-architecture
description: >-
  Investigates architectural improvement and refactoring opportunities in an
  existing codebase, module, or recurring change difficulty. Use when asked to
  find or pursue improvements that reduce complexity, fragility, or ongoing
  maintenance commitment, including after changes have merged.
argument-hint: "[area, codebase, recurring difficulty, or improvement to pursue]"
---

# Improve Architecture

An explicit entry point for continuous architectural improvement, from discovering opportunities to pursuing a chosen refactoring. Apply [software-designing](../software-designing/SKILL.md)'s principles without requiring a separate session or command.

## Investigate the requested problem

Use the area or difficulty supplied. A broad request can start with likely hotspots informed by dependencies, change history, or recurring friction; frequency of edits alone is not proof of poor design. When the user already chose an opportunity, focus there rather than starting a new catalog.

Read the current structure and relevant consumers. Assess [changeability and fragility](../software-designing/references/changeability-and-fragility.md) and [maintenance commitment](../software-designing/references/maintenance-commitment.md), loading other design references only as relevant. Identify concrete scenarios and distinguish verified consequences from hypotheses and unexamined areas.

Compare opportunities by recurring cost, likely evolution, failure impact, and the obligations a remedy would introduce. Avoid aesthetic cleanup and speculative abstractions. It is valid to find no intervention worth its cost. Respect prior decisions unless new evidence warrants revisiting them.

## Make improvement understandable

Lead with the business purpose of the affected area and define unfamiliar terms. Present meaningful opportunities with evidence, a plausible change/failure scenario, the current obligation, a recommended direction, and its trade-offs. Use [visualize-it](../visualize-it/SKILL.md) for the appropriate structural or before/after view; no separate HTML format or report file is prescribed. Use [explain-it](../explain-it/SKILL.md) for a requested deeper explanation, reusing the investigation.

For discovery, finish with a recommendation of what to pursue. For a chosen opportunity, develop the design at the requested depth. For analysis-only requests, stop at recommendations; for authorized analysis and implementation, continue in the same session under existing Human Layer governance and [coding](../coding/SKILL.md). Architectural refactoring can preserve product behavior while changing contracts; those changes still require human decisions. Behavior changes are separate scope, not silently included refactoring.

## Ordinary work and optional follow-up

During another task, briefly mention a material opportunity already observed, normally at delivery; raise it earlier if it compromises the current solution. This does not activate a broad scan or widen the task. Larger investigation remains on demand.

No automatic backlog, ADR, file, handoff, monitoring, or implementation follows from an observation. Offer a dedicated investigation or [handoff](../handoff/SKILL.md) when useful; creating a session or recording work depends on the user's request. Reuse findings from PR reviews without repeating the analysis.

## Success Validation

- [ ] Findings are grounded in the requested area and concrete evolution or failure scenarios.
- [ ] Proposed improvements reduce system-wide complexity or justify the remaining commitment.
- [ ] Presentation follows visualize-it and distinguishes evidence, uncertainty, and coverage.
- [ ] Discovery, design, and implementation advance only as far as requested/authorized.
- [ ] No automatic audit, artifact, task queue, or mandatory skill chain was introduced.
