---
name: commit
description: Use when preparing or validating a git commit message.
mandatory: true
enforcement: "This skill MUST be invoked before any git commit. The agent will not call git commit directly without first running this skill."
---

# Commit

## Goal

Produce the final best commit message that adheres to all mandatory rules below.

## Mandatory Rules

These rules are non-negotiable and apply to **every** commit created by Claude, Codex, or Antigravity.

- **Title Only, By Default:** The commit title (first line) is the entire message in the vast majority of cases. Do not add a body. Do not explain the "why" or the "how" unless the user explicitly asks for it.
- **No Task References in Title:** The first line must describe what was done, without any task or issue key (e.g., `DEV-1234`, `PROJ-56`). If a task reference is relevant, place it alone on a second line below the title, separated by a blank line.
- **No Local File References** ([no-local-references](../ai-assisted-software-development/references/no-local-references.md)): the task reference on that second line must be a real Jira key. If the ticket has no linked Jira issue, omit the reference line entirely.
- **Body Is the Exception, Not the Default:** Only add a body paragraph when the user explicitly asks for more context, or the change is genuinely inexplicable from the title alone (e.g., a non-obvious workaround). When in doubt, leave it out. If added, it must be a single paragraph of **maximum 3 lines** — never more.
- **No Bullet Points:** Never use bullet points or lists in the commit body, under any circumstance.
- **English Only:** All messages must be in English.

## Conventional Commit Format

`<type>(<scope>): <short description>`

**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`, `perf`, `ci`.

## Message Structure

- Default — title only:

```text
<type>(<scope>): <description>
```

- If a task reference is relevant, place it alone on the line after the title:

```text
<type>(<scope>): <description>

TASK-123
```

- Only when a body is truly warranted (see Mandatory Rules above), add it as a single paragraph (max 3 lines) after the task reference:

```text
<type>(<scope>): <description>

TASK-123

<single paragraph, maximum 3 lines>
```

## Self-Review Fix Commits

Fixes the coding agent makes in response to its own `agent-self-review` are **separate commits, always after the implementation commit** — never squashed into it and never amended onto it. That separation is what lets a reader trace what the review caught and how the agent responded.

These commits are the one case where a body is **required**, because the trace is the point.

```text
<type>(<scope>): <what the fix does>

TASK-123

Self-review: <the review finding, in one line>
```

Rules specific to these:

- Prefix the body's final line with `Self-review:` followed by the finding it answers — one finding per line, one commit per finding wherever the fixes are separable.
- The title still describes the change itself, not the review. `fix(auth): reject expired tokens at the boundary`, not `fix: address review comment`.
- Keep the `Self-review:` line to the finding. The reasoning belongs in the review output, not here.

## Enforcement

- Write the resulting message directly into the `git commit -m` command. Do not wrap it in fences or add commentary before or after it.
- **Never skip this skill** — invoking it is the only way to ensure consistency across commits.
- Run `scripts/validate-msg.sh` against the message before committing. If it fails, regenerate — do not commit and fix afterwards.
