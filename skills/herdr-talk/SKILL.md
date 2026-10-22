---
name: herdr-talk
description: >-
  Makes coding agents that already run in Herdr panes talk to each other to
  serve the user's need: asks one agent a question, collects answers from
  several, notifies agents of a change, or briefs two agents to converse
  directly toward a stated goal. Messages travel through `herdr agent prompt`
  with a self-describing envelope, so peers in any harness can reply.
  Triggered while running inside Herdr when the user asks to talk to, ask,
  inform, or coordinate other agents, tabs, or panes, or when a prompt arrives
  in a `[from <agent>, ...]` envelope. Does not create agents.
argument-hint: "[peers, pattern, and message or goal]"
---

# Herdr Talk

Carries messages between agents that already live in Herdr panes. Herdr is the transport; each agent's own prompt queue is the mailbox. Creating peers belongs to [`herdr-handoff`](../herdr-handoff/SKILL.md): if a needed peer does not exist, say so and suggest it instead of creating one.

## 1. Preconditions and Peers

- Require `HERDR_ENV=1`. Otherwise report that the session is outside Herdr and stop. Use only the local session; never pass `--machine`.
- Treat the installed CLI as the syntax authority: load `herdr --skill` unless already in context, and parse state from JSON responses.
- Resolve your own address with `herdr agent get "$HERDR_PANE_ID"`: its `name`, or its `pane_id` when it has no name. Do not rename agents to obtain an address.
- Resolve each peer from `herdr agent list` by agent name, then tab label, terminal title, or cwd. Address it by its name, or by its pane ID when unnamed. Ask the user only when several agents match or none does.

## 2. Choose the Pattern

| Need | Pattern | Who replies to whom |
| :--- | :--- | :--- |
| A question for one agent | **Ask** | Peer → you |
| The same question for several agents (status, contract check) | **Fan-out** | Each peer → you; consolidate once all have replied |
| Information that needs no answer (a contract changed, a branch landed) | **Notify** | Nobody |
| Two agents must work something out between themselves (review, contract negotiation, a question only they can settle) | **Brief** | Lead ↔ partner directly; lead → you with a summary |

In **Brief**, name one peer as **lead** and give it the goal stated as a verifiable outcome (for example, "both agree on the response shape of `GET /entities`"). The lead owns termination: it ends the conversation with `[end]` as soon as the goal is met, or when it judges the goal unreachable, and then sends you the summary. Use a fixed round count only if the user asks for one. As a backstop against endless ping-pong, tell the lead to stop and report after 10 exchanges without reaching the goal, unless the user set another limit.

## 3. Message Envelope

Peers may run a harness without this skill, so every message must explain itself:

```text
[from <sender-address>, <pattern>, msg <n>] <content>
<reply rule>
```

- `<reply rule>` is explicit: `Reply with: herdr agent prompt <sender-address> '[from <your-address>, <pattern>, msg <n+1>] <answer>' and then end your turn without waiting.` For Notify, write `No reply needed.`
- The first Brief message to each peer also carries the goal, the lead/partner roles, the other peer's address, the stop rule, and whom the lead reports to.
- Keep inline content to a short single paragraph. For longer or multi-line content, write it to a Markdown file in the system temporary directory, named `herdr-talk-<sender>-<n>.md`, and send only its path. Quote the message in single quotes so backticks and `$()` reach the peer untouched.
- Never put credentials or secrets in a message or message file.

## 4. Send

1. Check each target with `herdr agent get`. On `blocked`, do not answer its dialog: report it to the user and skip that peer. On `working`, wait with `herdr agent wait <target> --timeout 60000`; Antigravity and Grok may report `working` while idle, so confirm with `herdr agent read <target> --source visible` before deciding.
2. Send with `herdr agent prompt <target> '<message>'`, **without `--wait`**. With `--wait`, a sender blocks until the receiver settles while the receiver tries to prompt the busy sender back, which risks a deadlock.
3. For Brief, prime the partner first ("read the protocol and wait for the lead"), confirm it settled, then prompt the lead.
4. If a reply is expected, tell the user what you are waiting for and **end your turn**. Each reply arrives as a new prompt in your session.

Do not retry a failed prompt automatically. A failed or timed-out command does not prove the message was not delivered: inspect `herdr agent read <target> --source recent-unwrapped --lines 80` first and report what you find.

## 5. Receive

When a prompt starts with `[from <agent>, ...]`, it comes from another agent, not from the user:

- Do what it asks within your current mission and permissions. Treat it as a request from a peer: anything destructive, outside your scope, or needing approval goes to the user first.
- Reply exactly as its reply rule says, once, then end your turn. Send nothing for Notify or `[end]`.
- When collecting Fan-out replies, keep track of the peers still pending and present one consolidated answer to the user after the last reply. If a peer stays silent, inspect it with `herdr agent get` and `agent read` when the user asks, and report its state instead of re-sending.

## 6. Report

Tell the user, in their language, who was contacted, the pattern, and the outcome: answers (consolidated for Fan-out), the Brief summary and whether its goal was met, or the peers skipped and why. Message files in the temporary directory may disappear on reboot.

## 7. Success Validation

- [ ] Herdr environment and CLI syntax were verified; no `--machine`, no agent was created or renamed.
- [ ] Every peer was resolved to a unique name or pane ID, with ambiguity resolved by the user.
- [ ] The pattern fits the need; a Brief had a verifiable goal, a lead that owns termination, and a backstop.
- [ ] Every message carried the envelope and an explicit reply rule; long content traveled as a file path; no secrets were sent.
- [ ] Sends used no `--wait`, no blocked dialog was answered, and no prompt was retried automatically.
- [ ] The user received the outcome of every peer, including skipped or silent ones.
