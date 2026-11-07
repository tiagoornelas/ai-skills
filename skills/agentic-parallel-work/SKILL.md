---
name: agentic-parallel-work
description: >-
  Defines how AI agents run work in parallel without losing quality, tokens,
  or the user's control: the delivery as the unit of work (one session, one
  writer, one branch name across one worktree per repository), branch naming
  and base selection, when to open another session or tab versus a subagent
  versus staying sequential, how many deliveries to keep in flight, how many
  independent review rounds to run, and why no agent talks to another, with
  the studies and market practice behind each rule. Must be loaded before
  starting a delivery (creating a branch or worktree), splitting work,
  opening another session, tab, or subagent, or running anything in parallel.
---

# Agentic Parallel Work

Agents parallelize **deliveries**, never pieces of one delivery. Every agent that coordinates with another through messages adds tokens, loses decisions the other never sees, and hides the work from the user; the studies and the measured cases behind this rule are in [studies-and-practices.md](references/studies-and-practices.md).

## 1. The Delivery Is the Unit

- **A delivery** is one function the user can verify, cut as a vertical slice: it crosses every layer and repository it needs (frontend, backend, a third service). Never split a delivery by layer or by repository.
- **One delivery = one session (tab) = one writer.** The writer owns investigation, implementation, self-review, and the conversation with the user, even across repositories.
- **One worktree per repository, all with the same branch name.** Names, base branches, and worktree commands follow [branch-and-worktrees.md](references/branch-and-worktrees.md).
- **Too big for one session** means the delivery is too big, not that it needs more tabs: cut smaller vertical slices and run them one after another.
- **Stateless**: no registry or status file beside the work. Each fact lives in what it describes and the task state is derived on demand, per [where a task's facts live](../ai-assisted-software-development/SKILL.md#6-where-a-tasks-facts-live).

## 2. Who Talks to Whom

```text
user ── writer A ── worktrees ── PR(s)        writer B ── worktrees ── PR(s)
           ├─ subagent: reads, answers once, ends
           └─ independent reviewer: report, max 2 rounds
        no arrow between A and B
```

- **The writer talks only to the user.** No agent messages another agent as a work flow, and no agent relays messages between others.
- **A subagent answers once and ends**: read-only research, exploration, a hypothesis to check, an isolated review. It never edits the writer's files and never coordinates with other subagents. Brief it per [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md).
- **What crosses deliveries is a contract**, and a contract is the user's decision: a dependency between two deliveries reaches the user as a decision card, never as a message between their agents.

## 3. Choosing How to Run Something

| The work | How to run it |
| :--- | :--- |
| Steps that depend on each other, or parts sharing a contract or decisions | Sequentially, in the same session |
| Reading, searching, exploring, or a second opinion that would bloat the writer's context | A subagent |
| Another delivery that can merge without waiting for one in flight | Another session or tab, with its own worktrees |
| Several independent opinions on one question | [`brainstorm`](../brainstorm/SKILL.md): independent runs, each writing its own answer; the caller compares them; no debate between them |

A large, isolated part of a delivery (a whole frontend built against a mock) may become a second delivery only after the user approves the contract between them; it integrates only after the first one merges, and any change to the contract goes back to the user.

## 4. Limits

- **In flight**: 2 to 4 deliveries in the foreground; start with 2. The bottleneck is the user's review capacity, not the machine. When more than one delivery is waiting for the user's review, open no new one until the queue drains. [`coordinator`](../coordinator/SKILL.md) counts them, with each task's state, when the user asks.
- **Two deliveries never touch the same contract or file at once**: the second waits, or both become one sequential delivery.
- **Independent review**: at most 2 rounds per delivery. Only 🔴 findings and 🟡 findings that change behavior block; other 🟡 and every 🟢 go to a follow-up list for the user, recorded in the issue when there is one, never into a new round. After round 2, open blocking findings go to the user as pending, never as approval.

## References

| Reference | Load when… |
| :--- | :--- |
| [branch-and-worktrees.md](references/branch-and-worktrees.md) | Creating a branch or worktree, choosing a base, or linking PRs of one delivery across repositories. |
| [studies-and-practices.md](references/studies-and-practices.md) | Justifying a split, judging whether a flow is harmful, or explaining these rules to the user. |

---

## Success Validation

- [ ] The work in flight is a vertical-slice delivery with one writer; nothing was split by layer or repository.
- [ ] Every worktree of the delivery uses the same branch name, named and based per [branch-and-worktrees.md](references/branch-and-worktrees.md), and the calling checkout was never switched.
- [ ] No agent messaged or relayed for another agent; every subagent answered once and ended.
- [ ] No registry or status file was kept beside the work; facts live where [ai-assisted-software-development](../ai-assisted-software-development/SKILL.md#6-where-a-tasks-facts-live) places them.
- [ ] No more than 4 deliveries were in flight, and none opened while more than one awaited the user's review.
- [ ] Independent review stopped at 2 rounds, blocked only on 🔴 and behavior-changing 🟡, and the rest went to the follow-up list.
