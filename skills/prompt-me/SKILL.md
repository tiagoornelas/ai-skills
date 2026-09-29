---
name: prompt-me
description: >-
  Guides the user step-by-step through a task that only a human can execute
  (interactive login, actions in third-party web portals, hardware or account
  setup, manual approvals, or anything outside agent capabilities). Delivers one
  actionable step at a time, waits for confirmation, answers questions, and
  corrects course when roadblocks arise. Triggered when the user asks to be
  guided through a manual task, or when an agent workflow encounters an action
  that requires human execution.
argument-hint: "[manual task to execute]"
---

# Prompt Me

For moments when work cannot (or should not) be automated by the agent. The user executes with their own hands; the agent **charts the path, verifies each step, and resolves questions**. It never acts in place of the user.

---

## 1. Understand the Task Before Guiding

1. **Confirm the objective in one line**: what state must be true when the task completes.
2. **Investigate observable context**: operating system, installed CLI versions, config files, official vendor documentation. Guiding based on an obsolete UI menu wastes more user time than doing the task from scratch.
3. **Prerequisites**: state upfront what materials the user must have ready (credentials, physical devices, admin access, MFA).
4. **Draft the mental sequence** and estimate total steps (`N`). Do not reveal the whole checklist in one burst.

If multiple viable paths exist (e.g. web UI vs. CLI), present the options with a clear recommendation.

---

## 2. One Step Per Message

Every step contains exactly one action, scannable and executable in seconds, with a clear success criterion.

```markdown
**Step 2 of 5** — Authorize the device

**Action:** Navigate to Settings → Privacy → click **Authorize device**.

**Verification:** You should see "Device authorized" with today's date.

Reply **done**, **stuck**, or ask your question.
```

- **Always number steps** (`Step X of N`). If the plan shifts, update `N` and state the change.
- **Exact typography**: button labels, menu items, and field names in `**bold**`; terminal commands in clean copyable code blocks.
- **Wait for confirmation** before issuing the next step. Ambiguous replies ("ok", "think so") require confirming the success criterion.
- **Verify what the agent can inspect**: if the outcome reflects in local files, CLI commands, or APIs accessible to the agent, verify it yourself rather than relying solely on a verbal "done".
- **Acknowledge uncertainty**: if screen layouts are uncertain, say so and ask what the user sees (text snippet or screenshot). Never guess button locations.

---

## 3. Roadblocks and Clarifications

- **Questions mid-step**: answer concisely and stay on the current step. Never advance without confirmation.
- **Errors or roadblocks**: request evidence (exact error message, terminal output, screenshot), diagnose, and provide a corrected step. If the plan shifts, declare the updated `N`.
- **Dead ends** (insufficient permissions, deprecated feature): stop, explain the constraint, and offer alternative routes. Never push users toward unsafe workarounds.

---

## 4. Security Principles

- **Never ask for secrets in chat**: passwords, private tokens, API keys, or 2FA codes. When a secret belongs in a config file or environment variable, instruct the user on how to inject it locally without pasting into the conversation.
- **Warn prior to irreversible actions**: steps that delete data, revoke credentials, incur billing, or affect teammates must carry `⚠️` and explain consequences and reversibility. Require explicit confirmation.
- **Never compromise security for convenience** (disabling 2FA, granting `chmod 777`, bypassing SSL verification) without stating risks and offering the hardened path first.

---

## 5. Conclude

When the final step is confirmed:

```markdown
✅ **Completed:** <what state was achieved, in one line>

- <summary of actions taken, in 2–4 concise bullet points>
- <important details to remember or store: config path, expiration dates>
```

If invoked mid-flow by another skill, return control and state which step resumes.

---

## 6. What Not to Do

- Dumping the entire multi-step guide in a single message.
- Executing the user's manual action "to get ahead", or advancing without confirmation.
- Overwhelming steps with excessive conceptual background.

---

## 7. Success Validation

- [ ] Objective confirmed in a single line and prerequisites listed prior to Step 1.
- [ ] Every message contained a single numbered step (`X of N`) with exact action and verification criterion.
- [ ] Zero steps advanced without user confirmation; verifiable outcomes were confirmed directly by the agent.
- [ ] Zero credentials or secrets requested in chat; irreversible actions carried warnings and explicit confirmation.
- [ ] Conclusion summarized changes and returned control to calling workflows where applicable.
