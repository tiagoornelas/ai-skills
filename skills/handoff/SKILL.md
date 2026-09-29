---
name: handoff
description: >-
  Compacts the active conversation into a structured handoff document—a single
  Markdown file written to the system temporary directory—enabling a new agent
  to seamlessly resume work in another harness, another directory, with a
  colleague, or in a parallel task forked from the current session. References
  existing artifacts instead of duplicating them, separates verified facts
  from unverified assumptions, suggests next-session skills, and purges
  sensitive secrets. Triggered strictly upon explicit user request.
disable-model-invocation: true
argument-hint: "[what the subsequent session will be used for]"
---

# Handoff

Transforms the active conversation into a **transit document**: what is currently in flight, why decisions were made, and what comes next, structured for an incoming agent to resume execution. The primary value is **portability**, not compression.

---

## 1. When a Handoff is Justified

A transit file is necessary strictly when work must **travel**:

| Scenario | Why a Transit File is Required |
| :--- | :--- |
| Switching harnesses (e.g. Claude Code → Codex) | The incoming harness has zero visibility into the prior context window. |
| Shifting directory or repository | For example, executing a [`prototype`](../prototype/SKILL.md) in a detached scratch workspace. |
| Handing off to a human teammate | The peer requires a concise briefing they can quickly read. |
| Forking a parallel task stream | You continue in the current session; a second agent drives the forked stream. |

If work remains local (same harness, same directory, merely shifting project phases), state that in a single sentence: cleaning context via harness-native `/compact` or `/clear` commands is more effective. If the user still requests a handoff, proceed.

---

## 2. Calibrate to the Next Step

If the user provided an argument, it describes **what the subsequent session will focus on**. Tailor the document specifically for that task: preserve reasoning directly relevant to it and prune irrelevant history. Without an argument, author the handoff to continue in-flight work.

---

## 3. Document Content

```markdown
# Handoff — <Topic in a few words>

**Next Session Goal:** <intended purpose of next session>
**Source:** <repository/directory, branch, harness>

## Objective
<what the initiative aims to achieve, in 1–3 sentences>

## Current State
- **Delivered:** <completed work with verification evidence: commit, PR, test>
- **In Progress:** <active task at time of pause>
- **Next Steps:** <ordered sequence>

## Decisions & Rationale
- <decision taken> — <rationale and rejected alternatives>

## Verified vs. Assumed
- ✅ <fact verified during the session, and method>
- ❓ <unverified assumption requiring confirmation prior to acting>

## References
- <spec, issue, PR, commit, ADR, file — via link or relative path>

## Recommended Skills
- `<skill>` — <purpose for the upcoming session>
```

Rules:

- **Do not duplicate existing artifacts.** Specifications, blueprints, ADRs, tracking issues, commit SHAs, and diffs are cited via link or path, never copied verbatim. Keeps the document compact while maintaining single sources of truth.
- **Strictly decouple facts from assumptions.** An incoming agent treats the handoff as a contract and will not re-audit claims. An unverified assertion (e.g., "X does not exist" or "Y is ready") becomes a dangerous false premise: downgrade it to ❓.
- **Preserve the why, not just the what**: design decisions and rejected alternatives are what standard summaries lose.
- **Recommended skills**: cite skills the incoming agent should load, using canonical names recognizable to the target harness.
- **For a human peer**, local machine paths are invalid ([no-local-references](../ai-assisted-software-development/references/no-local-references.md)): cite issues, PRs, and commit URLs, or rephrase context.
- **Purge all credentials**: API keys, passwords, bearer tokens, and PII must never appear in the transit document.

---

## 4. Write and Deliver

1. Write the file into the **operating system temporary directory**, never inside the project workspace: it is a transit document, not a repository artifact.
2. **Return the absolute path** to the user. Warn that temporary directories are ephemeral and may be cleared upon reboot: if the next session is delayed or runs in another environment, the user should copy the file to durable storage.
3. Provide resumption guidance: in the new session, **instruct the agent to read the file** ("read this file and resume work"), avoiding pasting summaries into shell commands where backticks and command substitutions can corrupt payloads.
4. Encourage the user to scan the brief and downgrade any claims they recognize as mere assumptions.

When forking a stream, the current session remains active: do not terminate or clear current context.

---

## 5. Success Validation

- [ ] Handoff was justified (work travels), or explicitly re-confirmed by user.
- [ ] Document written to OS temporary directory outside workspace, with absolute path and volatility notice returned.
- [ ] Existing artifacts cited via link/path without copied text; zero local machine paths for peer handoffs.
- [ ] Every unverified claim flagged with ❓.
- [ ] Recommended skills section exists and aligns with declared next step.
- [ ] Zero secrets, private keys, tokens, or PII contained in document.
