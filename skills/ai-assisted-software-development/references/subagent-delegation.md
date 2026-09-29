# Subagent Delegation

> **Central thesis**: a subagent only sees what the brief provides. It does not inherit the conversation history, does not inherit the creator's context, and **does not know where skills are installed**. Every brief must be self-contained.

---

## When to consult

- Whenever a skill instructs creating subagents (parallel execution, isolated context, background search).
- When writing a brief that directs a subagent to read a skill or reference.

---

## 1. Harness Tooling

| Harness | How to create a subagent |
| :--- | :--- |
| **Claude Code** | `Agent` tool with `general-purpose` type. Multiple calls in the same message run in parallel. |
| **Antigravity CLI** | `invoke_subagent` with `TypeName: "self"` or a specific type. |
| **Codex** | A subprocess or isolated thread per task. |

In other harnesses, use the equivalent tool. If none exists, execute tasks sequentially in the current context and state that explicitly.

---

## 2. Full Context

Pass context and requirements to the subagent **completely, without loss of fidelity** (*verbatim*): specifications, decisions already made, constraints, severity scales, and output formats defined by the skill. Summarizing context during delegation is the most common reason subagents answer the wrong question.

---

## 3. Skill Paths in Briefs

Skills are installed outside the project (e.g., `~/.claude/skills/`), whereas the subagent runs in the project folder. A path like `agent-self-review/SKILL.md` written directly in a brief will not resolve in the subagent's working directory.

Before sending the brief:

1. Locate the **skills directory**: the directory containing the currently executing skill (its parent folder). Relative links between skills (`../<skill>/SKILL.md`) originate from here.
2. In briefs, `<skills>` represents this folder. Replace `<skills>` with the **absolute path** before sending (e.g., `<skills>/coding/references/testing.md` → `/Users/<user>/.claude/skills/coding/references/testing.md`).
3. Verify that cited files actually exist at that path. If any file is missing, do not delegate blindly: report which file is missing.

---

## 4. Validation

- [ ] The tool used matches the current harness (or sequential execution was stated).
- [ ] The brief carries complete context and requirements.
- [ ] No brief contains `<skills>` or a relative skill path; all paths are absolute and verified to exist.
