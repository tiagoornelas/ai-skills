---
name: ai-assisted-software-development
description: >-
  Core principles of governance and division of responsibilities in AI-assisted development. Defines the boundary between the Human Layer (governance, architecture, and contracts) and the Agent Layer (internal implementation, automation, and self-review), how the agent decides Human Layer items for the human to ratify at delivery, the actions where the agent always stops, the change card, and where a task's facts live. Load when deciding whether a choice is the human's or the agent's, before building or running anything new in production, and when writing to the human.
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

The sphere of human governance: the human has the final word on it. **Only what belongs to this layer should be reported to the developer.**

### Human Responsibilities:
- **Systems and Modules**: Which components exist, their responsibilities, and their boundaries.
- **Dependency Direction**: Ensuring dependencies point toward business rules (policy never depends on infrastructure details or frameworks). See [dependency-direction.md](../software-designing/references/dependency-direction.md).
- **Contracts and Public Interfaces**: What each module promises to its consumers (signatures, guarantees, and failure modes).
- **Behaviors (Definition of Done)**: Validation of acceptance criteria observable by the user or API consumer.
- **Business Decisions and Trade-offs**: Behavior, restrictions, assumptions, value versus scope, and continuing [maintenance commitment](../software-designing/references/maintenance-commitment.md).
- **Manual Verifications**: Execution of checks that cannot be automated.

The human is the **human directing architect**: the owner of this layer's decisions and of the product's direction, who knows what the product does and its high-level architecture but not the inside of the module the agent worked on. Not knowing the inside never moves the final word to the agent, and no agent is ever the directing architect. Agents bring this layer to the human with that context, per [human-facing-communication.md](references/human-facing-communication.md).

### Decided by the Agent, Ratified at Delivery

- **The agent decides this layer's items inside a delivery**, following the human's principles ([`software-designing`](../software-designing/SKILL.md), including its arena), builds the chosen option, and proves it. At delivery, each decision is presented for the human to ratify or change; nothing merges before that.
- **The agent works as if the human were away.** It never stops mid-delivery to ask a question it can settle itself, product and preference questions included: it decides, records the decision with its reason and evidence, marks low confidence when the evidence is thin, and continues. The human answers once, at delivery.
- **A changed decision is rework, not failure**: the agent applies the human's choice, which counts as ratified, and redoes any delivery stacked on it.

### Where the Agent Always Stops

A decision costs nothing to change before merge; an action whose effect leaves the branch does. Before any of these, the agent stops and asks with a [decision card](references/human-facing-communication.md#every-decision-fully-explained), and an approval covers only the action it named:

- merging, deploying, or publishing (packages, releases, artifacts);
- writing to shared or production data, including running a migration against a database that is not disposable;
- sending anything outside: messages, emails, comments on others' issues or pull requests;
- creating resources that cost money or that others use (cloud resources, secrets, queues);
- rewriting the history of a shared branch, or deleting data.

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

A change can pass the first question and still fail the second: a scheduled job that deletes production rows changes no contract, yet it is a new component the human must ratify. The answers place every decision in one of three tiers, which set how it is presented, not whether the agent may take it:

| Tier | What it covers | What the human sees at delivery |
| :--- | :--- | :--- |
| **1. Internal detail** | No to both questions: implementation, internal data, tests, hygiene below contracts | Nothing; it surfaces only inside a delivery's evidence |
| **2. New component or reversible operational change** | Yes to question 2 only, and reversible **including its effects**: a new job, schedule, table, queue, route, secret, permission, or recurring cost; an operational change that can be undone, data included | A decision to ratify, after the tier-3 ones |
| **3. Hard to reverse after merge** | Yes to question 1, a business rule, anything that deletes or rewrites production data, or anything irreversible or outward-facing | A decision to ratify, first in the order |

- **Nothing is tier 2 by default.** Every new item goes through both questions; tier 3 wins whenever any of its conditions holds. A business rule, or a component that deletes or rewrites production data (a purge job, a retention policy), is always tier 3: turning the component off stops new effects but does not undo the ones already made. This concerns a component whose purpose is to delete or rewrite data (a purge, a retention policy, a data migration), not the ordinary writes a product feature makes.
- **When in doubt between tiers 2 and 3, it is tier 3.** Building a tier-3 item in a branch is allowed; running its effects outside the branch is an action where the agent [always stops](#where-the-agent-always-stops).
- **The [change card](references/change-card.md) is how the tiers are seen.** Tier 1 never appears on it; tier 2 appears as new things and where they live; tier 3 as rule changes, data deleted or rewritten, things built on the side, and walls knocked down.

---

## 5. Derived Operational Workflows

This theory guides complementary workflows and independently callable entry points:

1. **[`agent-self-review`](../agent-self-review/SKILL.md)**: Executed autonomously by the agent. The agent inspects its own implementation (linter/types, DoD coverage, and tests), recursively fixing issues until approved.
2. **[`human-review`](../human-review/SKILL.md)**: The user's on-demand guide to one change, own or third-party: what changed, where it lives (the change card), and what the user needs to understand or decide, with critical findings that carry a consequence; a part is explained in depth only when the user points at it.
3. **[`scope-review`](../scope-review/SKILL.md)** and **[`improve-architecture`](../improve-architecture/SKILL.md)**: Independently callable entry points for scope/value decisions and architectural improvement. Reuse shared evidence; these are not mandatory stages.
4. **[Change card](references/change-card.md)**: the glanceable form of the tiers and of the decisions to ratify, printed at delivery, in a split plan, and on demand.
5. **[`agentic-parallel-work`](../agentic-parallel-work/SKILL.md)** owns how agents work in parallel: the delivery as the unit, one writer, branches and worktrees, in-flight and review-round limits.
6. **[`provide-evidence`](../provide-evidence/SKILL.md)** owns the evidence: every delivery carries the six-line [evidence dossier](../provide-evidence/references/evidence-dossier.md), each line with its claim, why it convinces, and its argument or proof, the last four attested by an independent reviewer.
7. **[Proven findings](references/proven-findings.md)**: in every review, a finding that says the code misbehaves stands only on a run that shows it.

During ordinary work, briefly surface material architectural or scope opportunities already encountered, normally at delivery and earlier only if they compromise the current solution. Broad scans, deeper investigations, artifacts, and follow-up sessions stay on demand. An observation does not expand implementation scope or create a backlog.

---

## 6. Where a Task's Facts Live

Each fact lives in the thing it describes, and the task's state is derived from those sources whenever someone asks, shown in the [task state](../tl-dr/references/task-state.md) format. No agent keeps a registry, status file, or copy of these facts beside them: a copy goes stale and then contradicts the source.

| Fact | Where it lives |
| :--- | :--- |
| Objective and acceptance criteria | The **issue**, in the tracker the repository or context points to (issue keys in branches or commits; the project's docs). When none is detectable, ask the user where; when the user declines an issue, they live only in the conversation. |
| Decisions and their ratification | While the work is in progress, the **issue** when there is one (each decision recorded as soon as it is taken, and its ratification or change when the human gives it), otherwise the conversation. |
| The change card | Not stored: rebuilt each time it is shown, from the diff and from the issue or the conversation. |
| Code, branches, CI, reviews | Git and the code host's own state (open, merged, checks, reviews). A PR's description is a document for other developers, never a source: no workflow reads state, decisions, or approvals from it. |
| Proof | Git notes on the commit they attest, per [`agent-self-review`](../agent-self-review/SKILL.md) and [`provide-evidence`](../provide-evidence/SKILL.md). |

Before a delivery is presented or its PR opened, check that the objective, the acceptance criteria, the decisions, and the change card agree, and fix the one that drifted.

---

## 7. Success Validation

- [ ] Every Human Layer decision the agent took was classified by both questions of the boundary test, recorded with its reason and evidence, and presented at delivery for ratification, tier 3 first; nothing merged before the human ratified or changed it.
- [ ] The agent stopped mid-delivery only before an action whose effect leaves the branch, asking with a decision card.
- [ ] Every split plan and delivery carried its [change card](references/change-card.md), and every delivery its six-line [evidence dossier](../provide-evidence/references/evidence-dossier.md), with lines (c)–(f) attested by an independent reviewer.
- [ ] Objective and acceptance criteria were in the issue (or, when the user declined one, the conversation); decisions and their ratification were in the issue or the conversation; no PR description, registry, or status file served as their source.
- [ ] No local or unversioned paths were exposed in shared artifacts.
- [ ] Messages to the human passed the directing-architect test of [human-facing-communication.md](references/human-facing-communication.md): no internal term used before being situated, changes briefed in its order (where, problem, decisions and trade-offs, risks and impact, solution, evidence), no explanation handed back to the human, each decision presented for ratification or asked was self-contained, checked as still open before being asked, every ✋ came with why only the human can do it, and emojis were used only as status and attention markers.
