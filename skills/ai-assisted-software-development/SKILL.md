---
name: ai-assisted-software-development
description: >-
  Core principles of governance and division of responsibilities in AI-assisted development. Defines the boundary between the Human Layer (governance, architecture, and contracts) and the Agent Layer (internal implementation, automation, and self-review), the change card, and where a task's facts live. Load when deciding whether a choice is the human's or the agent's, before announcing or building anything new in production, and when writing to the human.
---

# AI-Assisted Software Development

---

## 1. The Throughput and Focus Problem

AI agents generate code faster than any human developer can read line by line. Attempting to inspect all generated code turns the human into an inefficient bottleneck.

The sustainable solution is to **strictly divide labor into two distinct layers**:
- The **human** focuses exclusively on what is expensive to get wrong and cheap to review (architecture, contracts, and behaviors).
- The **agent** assumes full responsibility for code quality below contracts, self-validating through automated testing and **self-review**.

---

## 2. The Human Layer

The sphere of human governance and decision-making. **Only what belongs to this layer should be reported to the developer.**

### Human Responsibilities:
- **Systems and Modules**: Which components exist, their responsibilities, and their boundaries. A reversible new component is announced before it is built rather than asked (tier 2 of [the boundary test](#4-the-boundary-test)); the human keeps the veto.
- **Dependency Direction**: Ensuring dependencies point toward business rules (policy never depends on infrastructure details or frameworks). See [dependency-direction.md](../software-designing/references/dependency-direction.md).
- **Contracts and Public Interfaces**: What each module promises to its consumers (signatures, guarantees, and failure modes).
- **Behaviors (Definition of Done)**: Validation of acceptance criteria observable by the user or API consumer.
- **Business Decisions and Trade-offs**: Behavior, restrictions, assumptions, value versus scope, and continuing [maintenance commitment](../software-designing/references/maintenance-commitment.md). Agents investigate and recommend; humans decide.
- **Manual Verifications**: Execution of checks that cannot be automated.

The human is the **human directing architect**: the owner of this layer's decisions and of the product's direction, who knows what the product does and its high-level architecture but not the inside of the module the agent worked on. Not knowing the inside never moves a decision to the agent, and no agent is ever the directing architect. Agents bring this layer to the human with that context, per [human-facing-communication.md](references/human-facing-communication.md).

---

## 3. The Agent Layer

Everything that resides below boundaries and contracts. **The human should not be burdened with routine inspection of this level.**

### Agent Responsibilities:
- **Internal Implementation**: Control flow, loops, private helper functions, and algorithms.
- **Internal Data Structures**: Choice of internal types, collections, and caching mechanisms.
- **Mechanical Hygiene**: Formatting, linter compliance, static typing, and elimination of accidental complexity.
- **Test Coverage (BDD/TDD)**: Writing tests that deterministically prove every DoD behavior.
- **Recursive Self-Correction**: Performing its own **`agent-self-review`**, correcting flaws until all criteria are clean before submitting to the human.

---

## 4. The Boundary Test

Whenever in doubt about which layer a decision belongs to, apply this test, both questions in order:

> 1. **"Would changing this require renegotiating a contract with external callers, or could it be rewritten tomorrow without anyone outside the module noticing?"**
> 2. **"Does this start to run, cost, store data, or hold permissions in production where it did not before?"**

A change can pass the first question and still fail the second: a scheduled job that deletes production rows changes no contract, yet it is a new component the human must see before it exists. The answers place every decision in one of three tiers:

| Tier | What it covers | Who decides | What the human sees |
| :--- | :--- | :--- | :--- |
| **1. Internal detail** | No to both questions: implementation, internal data, tests, hygiene below contracts | The agent | Nothing; it surfaces only inside a delivery's evidence |
| **2. New component or reversible operational change** | Yes to question 2 only, and reversible **including its effects**: a new job, schedule, table, queue, route, secret, permission, or recurring cost; an operational change that can be undone, data included | The agent, after announcing it | A notice **before** it is built: what will appear, why, and "if you do not object by <time>, I proceed". The agent proceeds after that deadline unless the human objects, and records the outcome |
| **3. Human decision** | Yes to question 1, a business rule, anything that deletes or rewrites production data, or anything irreversible or outward-facing | The human, as a decision card | The card; nothing is built before the answer |

- **Nothing is tier 2 by default.** Every new item, including one found after planning, goes through both questions; tier 3 wins whenever any of its conditions holds. A business rule, or a component that deletes or rewrites production data (a purge job, a retention policy), is always tier 3: turning the component off stops new effects but does not undo the ones already made. This concerns a component whose purpose is to delete or rewrite data (a purge, a retention policy, a data migration), not the ordinary writes a product feature makes.
- **Tier 2 is announced, not asked.** The [notice](references/human-facing-communication.md#announcing-before-building) carries no options to choose from; silence is consent once the stated deadline passes. When in doubt between tiers 2 and 3, it is tier 3.
- **Evidence does not replace the notice.** Proving a delivery afterwards ([evidence dossier](../provide-evidence/references/evidence-dossier.md)) comes too late for a component the human would have redesigned: tier 2 is announced before building, and every delivery is still proven.
- **The [change card](references/change-card.md) is how the tiers are seen.** Tier 1 never appears on it; tier 2 appears as new things and where they live; tier 3 as rule changes, data deleted or rewritten, things built on the side, and walls knocked down.

---

## 5. Derived Operational Workflows

This theory guides complementary workflows and independently callable entry points:

1. **[`agent-self-review`](../agent-self-review/SKILL.md)**: Executed autonomously by the agent. The agent inspects its own implementation (linter/types, DoD coverage, and tests), recursively fixing issues until approved.
2. **[`human-review`](../human-review/SKILL.md)**: The user's on-demand guide to one change, own or third-party: what changed, where it lives (the change card), and what the user needs to understand or decide, with critical findings that carry a consequence; a part is explained in depth only when the user points at it.
3. **[`scope-review`](../scope-review/SKILL.md)** and **[`improve-architecture`](../improve-architecture/SKILL.md)**: Independently callable entry points for scope/value decisions and architectural improvement. Reuse shared evidence; these are not mandatory stages.
4. **[Change card](references/change-card.md)**: the glanceable form of the tiers, printed before building, at delivery, and on demand.
5. **[`agentic-parallel-work`](../agentic-parallel-work/SKILL.md)** owns how agents work in parallel: the delivery as the unit, one writer, branches and worktrees, in-flight and review-round limits.
6. **[`provide-evidence`](../provide-evidence/SKILL.md)** owns the evidence: every delivery carries the six-line [evidence dossier](../provide-evidence/references/evidence-dossier.md), each line with its claim, why it convinces, and its argument or proof, the last four attested by an independent reviewer.

During ordinary work, briefly surface material architectural or scope opportunities already encountered, normally at delivery and earlier only if they compromise the current solution. Broad scans, deeper investigations, artifacts, and follow-up sessions stay on demand. An observation does not expand implementation scope or create a backlog.

---

## 6. Where a Task's Facts Live

Each fact lives in the thing it describes, and the task's state is derived from those sources whenever someone asks, shown in the [task state](../tl-dr/references/task-state.md) format. No agent keeps a registry, status file, or copy of these facts beside them: a copy goes stale and then contradicts the source.

| Fact | Where it lives |
| :--- | :--- |
| Objective and acceptance criteria | The **issue**, in the tracker the repository or context points to (issue keys in branches, commits, or PRs; the project's docs). When none is detectable, ask the user where; when the user declines an issue, they live only in the conversation. |
| The user's decisions | While the work is in progress, the **issue** when there is one (recorded as soon as each decision is made), otherwise the conversation. Once the work is ready, the **PR body** carries them. |
| The change card | The **PR body**, opened when the work is ready. A delivery across repositories keeps its card in the main PR ([branch-and-worktrees.md](../agentic-parallel-work/references/branch-and-worktrees.md#4-one-delivery-several-repositories)). |
| Code, branches, CI, reviews | Git and the code host. |
| Proof | Git notes on the commit they attest, per [`agent-self-review`](../agent-self-review/SKILL.md) and [`provide-evidence`](../provide-evidence/SKILL.md). |

When the PR is opened, check that the objective, the acceptance criteria, the decisions, and the change card agree, and fix the one that drifted.

---

## 7. Success Validation

- [ ] The boundary between the Human Layer and Agent Layer was respected, with both questions of the boundary test applied; decisions on modules, contracts, dependency direction, or DoD behaviors went to the human (tier 3), and internal details were resolved autonomously with tests and self-review.
- [ ] Anything new that runs, costs, stores data, or holds permissions in production was classified by the boundary test before being built: tier-2 items were announced with a stated deadline and their outcome recorded; anything that deletes or rewrites production data or changes a business rule went to the human as a decision card (tier 3).
- [ ] Every notice, split plan, and delivery carried its [change card](references/change-card.md), and every delivery its six-line [evidence dossier](../provide-evidence/references/evidence-dossier.md), with lines (c)–(f) attested by an independent reviewer.
- [ ] Objective and acceptance criteria were in the issue (or, when the user declined one, the conversation); the user's decisions were in the issue or the conversation until the PR carried them with the change card; no registry or status file copied them.
- [ ] No local or unversioned paths were exposed in shared artifacts.
- [ ] Messages to the human passed the directing-architect test of [human-facing-communication.md](references/human-facing-communication.md): no internal term used before being situated, changes briefed in its order (where, problem, decisions and trade-offs, risks and impact, solution, evidence), no explanation handed back to the human, each pending decision was a self-contained card saying why it is the human's and whether it is easy or hard, checked as still open before being asked, every ✋ came with why only the human can do it, and emojis were used only as status and attention markers.
