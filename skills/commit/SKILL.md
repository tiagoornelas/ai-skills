---
name: commit
description: >-
  Prepares and validates standardized Conventional Commits messages,
  strictly in English, ensuring concise, traceable commits free of local machine references.
---

# Commit

Produces high-quality commit messages strictly adhering to the mandatory conventions below.

---

## 1. Mandatory Rules

These rules are non-negotiable and apply to **every** commit created by Claude, Codex, or Antigravity.

- **Title-Only by Default**: In the vast majority of cases, the title (first line) is the entire message. Do not add a body. Do not explain the "why" or "how" unless explicitly requested by the user.
- **No Task Key in the Title**: The first line must describe what was done, without any issue or task key (e.g., `DEV-1234`, `PROJ-56`). If referencing an issue, place it isolated on the third line (following a blank line).
- **No Local References** ([no-local-references](../ai-assisted-software-development/references/no-local-references.md)): Issue keys must be real tracking keys (Jira, GitHub, Linear). If there is no formal issue linked, omit the task reference line.
- **Body is an Exception, Not the Rule**: Add a body only when the user requests additional context or when the change cannot be understood from the title alone (e.g., a non-obvious workaround for an external bug). When in doubt, omit the body. When added, it must be a single paragraph of **at most 3 lines**—never more.
- **No Bullet Points or Lists**: Never use bullet points or numbered lists in the commit body.
- **English Only**: All commit messages must be written in English.

---

## 2. Conventional Commits Format

`<type>(<scope>): <short description>`

**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`, `perf`, `ci`.

---

## 3. Message Structure

- **Standard — title only:**
```text
<type>(<scope>): <description>
```

- **With isolated task reference:**
```text
<type>(<scope>): <description>

TASK-123
```

- **With explanatory body (strictly when justified):**
```text
<type>(<scope>): <description>

TASK-123

<single paragraph, maximum 3 lines>
```

---

## 4. Self-Review Remediation Commits

Fixes authored in response to [`agent-self-review`](../agent-self-review/SKILL.md) are **separate commits, always authored after the implementation commit**—never squashed or amended. This separation allows maintainers to clearly trace what review discovered and how the agent addressed it.

These remediation commits are the only case where a body is **mandatory**, as traceability is paramount.

```text
<type>(<scope>): <what the fix does>

TASK-123

Self-review: <the review finding, in one line>
```

Specific rules for remediation commits:
- The final line of the body must start with the prefix `Self-review:` followed by the finding it resolves—one finding per line, one commit per finding whenever remediations are separable.
- The title continues describing the code modification itself, not the act of reviewing: `fix(auth): reject expired tokens at the boundary`, not `fix: address review comment`.
- Keep the `Self-review:` line restricted to the finding. Architectural rationale belongs in the review report, not the commit message.

---

## 5. Execution and Validation

- Write the commit message directly in the `git commit -m` command. Do not wrap it in conversational blocks or add commentary before or after.
- Before committing, deterministically validate the message against conventions (72 character title limit, no trailing period, no bullet lists, line structure). If the skill's utility script is available, run it:
  ```bash
  <skills-dir>/commit/scripts/validate-msg.sh -m "<message>"
  ```
  If validation fails, rewrite the message before committing.

---

## 6. Success Validation

- [ ] Message is written in English and adheres to Conventional Commits `<type>(<scope>): <desc>`.
- [ ] Title is at most 72 characters, does not end with a period, and contains no task key.
- [ ] Task reference (if present) is isolated on line 3 between blank lines.
- [ ] Body (if present) is at most 3 lines with zero bullet points or numbered lists.
- [ ] Self-review commits feature the trailing `Self-review: <finding>` line.
- [ ] Validation script passed with zero errors prior to running `git commit`.
