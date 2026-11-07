---
name: reflect
description: >-
  Mines the current session for durable learnings and turns them into
  proposed edits to the skills and rules the session used: three independent
  reviewers read the transcript through different lenses (judgment, tooling,
  blind spots), a synthesizer sorts their findings into accepted edits,
  rejections, and items a mechanism should enforce, and nothing is applied
  without the user's approval. Runs only when the user invokes /reflect,
  typically after a long task, so the next run does not repeat its detours.
disable-model-invocation: true
---

# Reflect

Skip when the session was trivial or followed an existing skill correctly. One-offs are not learnings.

## 1. Locate the Transcript

Find this session's own transcript; never read past the first message of another session, which may hold private work from unrelated projects.

| Harness | Where |
| :--- | :--- |
| Claude Code | `~/.claude/projects/<working directory path, with separators turned into "-">/<session>.jsonl` |
| Codex | `~/.codex/sessions/<year>/<month>/<day>/*.jsonl` |
| Cursor | the `agent-transcripts/` directory the system prompt names |

List the newest files there and read only the first user message of each to find the one that matches this session's opening prompt. When none matches or the harness keeps no transcript, write a tight digest of the session instead: the goal, each correction the user made, each detour, and the skills used.

## 2. Review in Parallel

Run three reviewers as subagents in one turn, per [subagent-delegation.md](../ai-assisted-software-development/references/subagent-delegation.md), each briefed with [reviewer-brief.md](references/reviewer-brief.md): the shared part plus one lens (judgment, tooling, divergent), and the transcript path or digest. Reviewers only read; they never edit, commit, or post.

## 3. Synthesize

Run one subagent briefed with [synthesizer-brief.md](references/synthesizer-brief.md) and the three reviewers' full outputs. It returns three lists: Accepted, Rejected, and Mechanism.

## 4. Present and Apply

- Present the three lists in full, in the user's language. Each Accepted row shows its destination: the skill or rule file, and the repository it lives in (a symlinked skill's source is `readlink -f` of its folder).
- Apply only the rows the user approves; the user may redirect a routing. Skill and rule changes affect every future session, so nothing is applied on the agent's judgment.
- Apply approved rows as a delivery in the repository that owns each file, per [`agentic-parallel-work`](../agentic-parallel-work/SKILL.md), with [`prompt-engineering`](../prompt-engineering/SKILL.md), then [`commit`](../commit/SKILL.md) and [`pull-request`](../pull-request/SKILL.md).
- Mechanism items go to [`correct`](../correct/SKILL.md), in the repository where the mistake happens, when the user approves; `correct` acts once the mistake has recurred, so a first occurrence stays in the report as a suggestion. Filing any of them in a tracker goes through [`report-work`](../report-work/SKILL.md).

## 5. Report

One line each: edits applied (file and what changed), mechanism items handed to `correct` or filed, and rejected findings with the synthesizer's reason.

---

## Success Validation

- [ ] Only this session's transcript was read, or a digest was written when none matched.
- [ ] Three reviewers with distinct lenses ran in parallel as read-only subagents, and one synthesizer sorted their findings.
- [ ] Every Accepted row routes to a skill or rule the session used, tunes the description of one that should have triggered, or proposes a new skill for a pattern none covers.
- [ ] Nothing was applied before the user approved its row; each approved edit went through `prompt-engineering` as a delivery in the repository that owns the file.
- [ ] Items a mechanism can enforce went to `correct` or a tracker, never into prose.
- [ ] The report listed edits applied, mechanism items, and rejections with reasons.
