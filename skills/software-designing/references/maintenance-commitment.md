# Maintenance Commitment

Every solution incorporates future obligations to sustain, operate, and evolve the software. Design should minimize those obligations across the whole system and justify the remaining ones by the business value delivered.

Use **maintenance commitment** to name this lens directly in a design discussion or review. It extends [changeability and fragility](changeability-and-fragility.md): examine the continuing obligations behind change cost and runtime failure paths, rather than just today's implementation effort.

## Evaluate the obligation

For a material concern, establish:
- What future work or constraint the solution creates, who carries it, and when it recurs.
- Which concrete change or failure scenario exposes the cost, with evidence from code or the proposed design.
- Whether the obligation is inherent to the business problem or avoidable complexity introduced by the solution.
- Which alternative reduces it, and what new obligations, limitations, or coupling that alternative introduces.

Look beyond the module being simplified: consumers, integrations, compatibility, deployments, and operation can inherit its complexity. Distinguish initial investment from recurring cost. Avoid invented numerical ratios between business complexity and maintenance complexity.

## Signals and directions

| Signal | Question or direction |
| :--- | :--- |
| A correction requires someone to remember another correction. | Can one owner hold the shared decision and propagate its effects structurally? |
| Consumers repeat setup, rules, or recovery protocols. | Can a deeper module absorb that knowledge behind a simpler contract? |
| A small capability adds long-lived exceptions or coordination. | Is the marginal benefit worth the continuing obligation? See [scope-review](../../scope-review/SKILL.md). |
| A module becomes simpler while every caller gains work. | Compare total system complexity, not local line counts. |
| An abstraction removes duplication but couples independent policies. | Preserve independent evolution; similar code does not necessarily represent shared knowledge. |

Single ownership means ownership of knowledge, not one file for all changes. Deliberate compatibility migrations and independent business policies can justify coordinated changes. Duplication is a manifestation, not the definition, of maintenance commitment.

Externally supplied capabilities can separate reusable policy/presentation from effects. Whether an unavailable capability disables, hides, or rejects an action is a contract decision; callbacks and read-only flags are contextual techniques, not universal rules.

## Use proportionally

Surface avoidable material obligations with a direction of improvement or explicit trade-off for human judgment. Complexity alone is not a defect, and maintenance zero is not the goal. Respect accepted concessions; revisit them when evidence changes their premises, scope, or accumulated cost.

Apply the lens to evidence already gathered in the requested work. A concern does not automatically authorize a repository audit, redesign, persistent record, or implementation.
