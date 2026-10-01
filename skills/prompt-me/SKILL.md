---
name: prompt-me
description: >-
  Guides the user step-by-step through a task that only a human can execute
  (interactive login, actions in third-party web portals, hardware or account
  setup, manual approvals, or anything outside agent capabilities). Delivers as
  many actionable steps as possible in a single response, intervenes on demand
  when roadblocks arise, and resumes the remaining steps from where the user
  stopped. Triggered when the user asks to be guided through a manual task, or
  when an agent workflow encounters an action that requires human execution.
argument-hint: "[manual task to execute]"
---

# Prompt Me

For moments when work cannot (or should not) be automated by the agent. The user executes with their own hands; the agent **charts the path, provides batchable steps upfront, resolves roadblocks on demand, and helps verify completion**. It never acts in place of the user.

---

## 1. Understand the Task Before Guiding

1. **Confirm the objective in one line**: what state must be true when the task completes.
2. **Investigate observable context**: operating system, installed CLI versions, config files, official vendor documentation. Guiding based on an obsolete UI menu wastes more user time than doing the task from scratch.
3. **Prerequisites**: state upfront what materials the user must have ready (credentials, physical devices, admin access, MFA).
4. **Chart the sequence**: structure the entire workflow upfront into clear, numbered steps. Deliver as many predictable steps as possible in the initial response. Only pause early if an unavoidable checkpoint requires dynamic outcome data or human selection to determine the remaining steps.

If multiple viable paths exist (e.g. web UI vs. CLI), present the options with a clear recommendation.

---

## 2. Deliver Maximum Actionable Steps Upfront

Deliver as many steps as can be reliably charted in a single, scannable response. The user executes at their own pace without needing to confirm each step individually.

```markdown
### Steps to Complete

1. **Step 1 — Download & unpack installer**
   - **Action:** Open terminal and run `curl -fsSL https://example.com/install.sh | bash`.
   - **Verification:** Confirm `example --version` returns `v1.2.0` or higher.

2. **Step 2 — Authorize the device**
   - **Action:** Navigate to **Settings** → **Privacy** → click **Authorize device**.
   - **Verification:** You should see "Device authorized" with today's date.

3. **Step 3 — Generate API token**
   - **Action:** In the dashboard, click **API Tokens** → **Create New Token**, name it `dev-cli`, and copy the token.
   - **Verification:** The token appears with "Active" status.

---
👉 **Next:** Follow the steps above. If you complete all of them, reply **done**. If you encounter an issue or question at any step, tell me which step you are on and describe what happened—I will troubleshoot and provide the remaining steps from there.
```

- **Clear numbering & headings**: Keep steps sequential and distinctly identifiable (`Step 1`, `Step 2`, ...).
- **Exact typography**: button labels, menu items, and field names in `**bold**`; terminal commands in clean copyable code blocks.
- **Explicit verification criteria**: Each step must explain how to confirm it succeeded before moving to the next.
- **Autonomous verification when possible**: If an outcome can be verified via local CLI or file inspection, the agent inspects it rather than asking the user to manually verify.
- **Acknowledge uncertainty**: if screen layouts or vendor UIs vary, state potential variations and ask what the user sees if stuck. Never guess button locations.

---

## 3. Roadblocks and Resuming On Demand

When a user encounters a problem, confusion, or error at a specific step:

1. **Address the specific blocker**:
   - Request evidence if necessary (exact error message, terminal output, screenshot).
   - Diagnose the root cause and provide precise corrective instructions for that step.
2. **Resume from the interruption point**:
   - Once the obstacle is cleared or adapted, deliver all remaining steps starting from that step forward to completion.
   - If the troubleshooting shifted the overall plan, adjust step numbers and explain what changed.

```markdown
### 🔧 Resolving Step 2: Permission Error

**Fix:** Your user lacks write access to `/usr/local/bin`. Run:
```bash
sudo chown -R $(whoami) /usr/local/bin
```

---

### Remaining Steps (from Step 2)

2. **Step 2 (retry) — Authorize the device**
   ...
3. **Step 3 — Generate API token**
   ...
```

- **Dead ends** (insufficient permissions, deprecated feature): stop, explain the constraint, and offer alternative routes. Never push users toward unsafe workarounds.

---

## 4. Security Principles

- **Never ask for secrets in chat**: passwords, private tokens, API keys, or 2FA codes. When a secret belongs in a config file or environment variable, instruct the user on how to inject it locally without pasting into the conversation.
- **Warn prior to irreversible actions**: steps that delete data, revoke credentials, incur billing, or affect teammates must carry `⚠️` and explain consequences and reversibility. Require explicit confirmation before proceeding.
- **Never compromise security for convenience** (disabling 2FA, granting `chmod 777`, bypassing SSL verification) without stating risks and offering the hardened path first.

---

## 5. Conclude

When all steps are completed or verified:

```markdown
✅ **Completed:** <what state was achieved, in one line>

- <summary of actions taken, in 2–4 concise bullet points>
- <important details to remember or store: config path, expiration dates>
```

If invoked mid-flow by another skill, return control and state which step resumes.

---

## 6. What Not to Do

- Drip-feeding steps one by one when they can be reliably provided together.
- Forcing the user to send back-and-forth confirmations for simple, predictable consecutive actions.
- Executing the user's manual action "to get ahead", or assuming success on unverified external actions.
- Dropping context or failing to provide the remaining sequence after resolving a roadblock.
- Overwhelming steps with excessive conceptual background.

---

## 7. Success Validation

- [ ] Objective confirmed in a single line and prerequisites listed upfront.
- [ ] Delivered maximum viable steps in a batch upfront with clear action and verification criteria per step.
- [ ] Explicitly guided the user on how to proceed or report blockers.
- [ ] Upon user roadblock, diagnosed the issue and re-delivered all remaining steps from the interrupted point forward.
- [ ] Zero credentials or secrets requested in chat; irreversible actions carried warnings and explicit confirmation.
- [ ] Conclusion summarized changes and returned control to calling workflows where applicable.
