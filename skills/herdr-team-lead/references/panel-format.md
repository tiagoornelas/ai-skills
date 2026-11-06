# Panel Example

> **Central thesis**: when something changes for the user in a space, or when they ask how the work is going, the Leader shows the space's state so it reads at a glance: first whether anything depends on the user, then what comes next, what is blocked, what is in progress, and the PRs. This is an example of that message, not a form to fill: its content matters, its layout adapts. The proof of each delivery is not part of it: it comes with the delivery, or on request through [`provide-evidence`](../../provide-evidence/SKILL.md).

---

## Example

In the user's language, every fixed word translated:

````markdown
### 🧭 Invoices · state · 14:20

**❓ 2 items depend on you: 1 and 2** · 1 notice proceeds at 16:00 unless you object: 3

🔔 The billing tab finished the invoice purge and opened its PR.

**➡️ What's next**
1. ❓ **You · invoice retention:** keep expired invoices 90 or 180 days? → unblocks the purge. Recommendation: 90.
2. 👀 **You · invoice purge PR:** review it → it is proven on its current version.
3. ⚠️ **You · notice:** a daily 2am schedule appears for the purge · proceeds at 16:00 unless you object.
4. 🤖 Export screen tab adds the CSV button · after 1

**⏸️ Blocked**
- ⏸️ **Turning off the old export:** waits one day after the migration · tomorrow 10:00

**⏳ In progress**
- ⏳ CSV export for customers · export tab · waits for the purge PR

**PRs**
- 👀 web-app#212 · invoice purge · CI ok · agent ok · proof ok · you pending
  🏗️ new: job expired-invoice purge · table billing_invoices
- ✅ web-app#205 · invoice list · merged · proof ok
````

## What Makes It Work

- **The first line answers "do I need to act?"**: how many ❓, 👀, and ✋ items depend on the user, with their numbers, or that nothing does; notices are named after the count with their deadline.
- **The user's items first**, numbered so the user can answer by number, each with what it unblocks and a recommendation; then the agents' next steps (🤖).
- **Blocked** (⏸️) is only what nobody, neither the user nor any agent, can move now (a time to pass, a third party); waiting for the user is a user item, waiting for the team is in progress, and an agent stopped at a dialog is a ✋ user action.
- **PRs** use the [PR line](../../ai-assisted-software-development/references/change-card.md#4-pr-line), with one 🏗️ line naming each PR's new things; the full change card comes only at a notice, at delivery, or on demand.
- **System terms and the [shared emoji vocabulary](../../ai-assisted-software-development/references/human-facing-communication.md#4-emojis-as-signals)**: tabs by role, PRs by what they change, numbers only as lookup keys; *(inferred)* on what was not observed.
- Empty blocks are left out, and a reply to a question where nothing changed carries no Panel.
