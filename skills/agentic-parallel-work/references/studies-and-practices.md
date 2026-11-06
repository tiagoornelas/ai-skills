# Studies and Practices

> **Central thesis**: multi-agent setups pay off on breadth-first work whose parts are independent, and lose on coding work whose parts share decisions. Parallelize independent deliveries; inside a delivery, keep one writer and use other agents only for read-only help and a clean-context review.

---

## When to consult

- Judging whether a proposed split or flow is harmful.
- Explaining to the user why a rule of this skill exists.

---

## 1. Studies

| Source | Finding | What this skill takes from it |
| :--- | :--- | :--- |
| Anthropic, [How we built our multi-agent research system](https://www.anthropic.com/engineering/built-multi-agent-research-system) (2025) | Agents use about 4× the tokens of a chat, multi-agent systems about 15×. Multi-agent wins on breadth-first research with independent directions; coding has fewer truly parallel parts, and tightly interdependent work is a poor fit. | Pay for parallelism only where the parts are independent. |
| Google Research and MIT, [Towards a Science of Scaling Agent Systems](https://arxiv.org/abs/2512.08296v3) (arXiv 2512.08296) | Coordinated multi-agent setups gained up to +80.8% on a decomposable task and lost up to −70% on sequential planning; architecture-task alignment decides the outcome. Version 3 revised some thresholds of earlier versions, so the numbers are evidence, not laws. | Sequential or interdependent work stays in one session. |
| UC Berkeley, [Why Do Multi-Agent LLM Systems Fail?](https://arxiv.org/abs/2503.13657) (MAST, arXiv 2503.13657) | About a third of the failures observed are inter-agent misalignment: agents ignoring, withholding, or misreading each other's information. | No agent-to-agent conversation as a work flow. |
| Cognition, [Don't Build Multi-Agents](https://cognition.ai/blog/dont-build-multi-agents) (2025) and [Multi-Agents: What's Actually Working](https://cognition.com/blog/multi-agents-working) (2026) | Every action carries implicit decisions; parallel writers make conflicting ones. What works: single-threaded writes, other agents contributing intelligence, and a reviewer with a clean context. | One writer per delivery; subagents answer once; the independent reviewer stays. |

**A measured case.** In one setup, a lead agent coordinated several tab agents that messaged each other freely to deliver a few sequential pull requests. It spent about 5× the tokens per changed line of the same user's earlier one-session-per-task flow: disposable reviewers took 49% (one pull request went through nine review rounds, mostly wording findings), and the lead agent's relaying took 23%. Its reviewers also found stale facts the flow had produced: proof run on an older commit, a validation environment several commits behind, and a status record contradicting itself.

## 2. Market Practice

- **One worktree per agent** is the common isolation: [Cursor worktrees](https://cursor.com/docs/configuration/worktrees), [Codex worktrees](https://developers.openai.com/codex/app/worktrees) and [cloud tasks](https://developers.openai.com/codex/cloud), and [Conductor](https://www.conductor.build/docs/concepts/git-worktrees), where one workspace is one worktree, one branch, and one unit of review.
- **Subagents return a summary to their caller**; Claude Code's [agent teams](https://code.claude.com/docs/en/agent-teams), where teammates message each other, are recommended against for sequential or interdependent work and [cost more tokens](https://code.claude.com/docs/en/costs) with every teammate.
- **The human reviews deliveries, not transcripts.** Practitioners run a few independent agents at once and name review capacity as the limit: [Simon Willison](https://simonwillison.net/2025/Oct/5/parallel-coding-agents/) on the parallel coding agent lifestyle, and [Addy Osmani](https://addyosmani.com/blog/future-agentic-coding/) on moving from conductor (one agent, in the loop) to orchestrator (several async agents, reviewing their output).

## 3. Good and Bad Practice

| Good | Bad, and why |
| :--- | :--- |
| One session per delivery, multi-repo when the delivery needs it | Frontend and backend of one change in two tabs: each makes decisions the other never sees. |
| The writer talks to the user; subagents answer once | Tabs updating each other by message: tokens grow with every message and the user loses track. |
| No lead agent: the task state is derived from the issue, the PR, and git when asked | A lead agent relaying between tabs and keeping a status file: the file goes stale and contradicts the code. |
| Two to four deliveries in flight, fewer when reviews pile up | More fronts than the user can review: work waits and context rots. |
| One clean-context reviewer, at most two rounds, only real defects block | Review rounds over wording: most of the cost, little of the value. |
| Independent opinions written separately, then compared | Agents debating until they agree: they converge on each other, not on the facts. |
