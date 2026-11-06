---
name: herdr-talk
description: >-
  Makes coding agents that already run in Herdr App terminals talk to each
  other to serve the user's need: asks one agent a question, collects answers
  from several, notifies agents of a change, or briefs two agents to converse
  directly toward a stated goal. Messages travel through `hc send` (herdr-core),
  which tags each one with its sender, plus a self-describing envelope so peers
  in any harness can reply. Built for the Herdr App (herdr-app + hc), not the
  Herdr terminal multiplexer (`herdr` CLI). Triggered while running inside the
  Herdr App when the user asks to talk to, ask, inform, or coordinate other
  agents, tabs, or panes, or when a prompt arrives as an
  `<hc from="...">` message. Does not create agents.
argument-hint: "[peers, pattern, and message or goal]"
---

# Herdr Talk

Carries messages between agents that already live in Herdr App terminals. herdr-core (`hc`) is the transport; each agent's own input is the mailbox. Creating peers belongs to [`herdr-handoff`](../herdr-handoff/SKILL.md): if a needed peer does not exist, say so and suggest it instead of creating one.

> **Herdr App only.** This skill drives the Herdr App: `herdr-app` (window: spaces, tabs, panes) and `hc` (herdr-core: terminals and agents). It never uses the `herdr` CLI of the Herdr terminal multiplexer, which talks to a different session.

## 1. Preconditions and Peers

- Require `HC_TERMINAL_ID` to be set and `hc` on `PATH`. Otherwise report that the session is outside the Herdr App and stop. Use only this machine; never pass `--on`.
- Treat the installed CLI as the syntax authority: load `hc --skill` unless already in context, and inspect `hc <command> --help` for unfamiliar flags. Parse state from JSON responses (`--json`).
- Your own address is `$HC_TERMINAL_ID` (for example `t7`); `hc get "$HC_TERMINAL_ID"` shows your `name`, if any. Do not restart an agent to obtain a name.
- Resolve each peer from `hc ls` and `herdr-app ls` by terminal name, then tab name, space name, or cwd. Address it by its name, or by its terminal address (`t7`) when unnamed. Ask the user only when several agents match or none does.

## 2. Choose the Pattern

| Need | Pattern | Who replies to whom |
| :--- | :--- | :--- |
| A question for one agent | **Ask** | Peer → you |
| The same question for several agents (status, contract check) | **Fan-out** | Each peer → you; consolidate once all have replied |
| Information that needs no answer (a contract changed, a branch landed, the user decided something in your tab) | **Notify** | Nobody |
| Two agents must work something out between themselves (review, contract negotiation, a question only they can settle) | **Brief** | Lead ↔ partner directly; lead → you with a summary |

In **Brief**, name one peer as **lead** and give it the goal stated as a verifiable outcome (for example, "both agree on the response shape of `GET /entities`"). The lead owns termination: it ends the conversation with `[end]` as soon as the goal is met, or when it judges the goal unreachable, and then sends you the summary. Use a fixed round count only if the user asks for one. As a backstop against endless ping-pong, tell the lead to stop and report after 10 exchanges without reaching the goal, unless the user set another limit.

## 3. Message Envelope

`hc send` delivers the text wrapped as `<hc from="<sender-address> <sender-name>">…</hc>`, so the receiver always knows who sent it. Peers may still run a harness without this skill, so every message must explain itself:

```text
[<pattern>, msg <n>] <content> <reply rule>
```

- `<reply rule>` is explicit: `Reply once by running hc send <your-address> "[<pattern>, msg <n+1>] <answer>", without --wait, then end your turn.` For Notify, write `No reply needed.`
- The first Brief message to each peer also carries the goal, the lead/partner roles, the other peer's address, the stop rule, and whom the lead reports to.
- Write the content in the user's session language (the language the user speaks to the team), keeping the envelope's pattern name and reply rule as they are: a Leader that reads messages in another language drifts into it when it talks to the user.
- Peers do not share your context: give every handle (PR or ticket number, coined label, method name) its meaning the first time it appears in a message. When the content needs a human decision, state that decision in system terms, so the receiver can present it without your context.
- When the content asks a peer to write code, create a branch, commit, or open a pull request, name the skill that governs each action: `coding`, `git-branch`, `commit`, or `github-pull-request`. The peer may not have received a handoff that states them.
- Keep inline content to a short single paragraph. For longer or multi-line content, write it to a Markdown file in the system temporary directory, named `herdr-talk-<sender>-<n>.md`, and send only its path.
- Pass the message through a quoted heredoc so quotes, backticks, and `$()` reach the peer untouched:

  ```bash
  hc send <target> "$(cat <<'MSG'
  [<pattern>, msg <n>] <content> <reply rule>
  MSG
  )"
  ```
- Never put credentials or secrets in a message or message file.

## 4. Send

1. Check each target with `hc get <target>` (`status.state`). On `blocked` or `error`, do not answer its dialog or force input: report it to the user and skip that peer. `idle`, `done`, and `working` agents can receive a message; a working agent reads it at its next pause.
2. Send with `hc send <target> <message>` as shown in Section 3, **without `--wait`**, and never with `--force`.
3. For Brief, prime the partner first ("read the protocol and wait for the lead"), confirm it settled with `hc wait <partner> --timeout 60`, then send to the lead.
4. If a reply is expected, **end your turn**; tell the user what you are waiting for only when the user asked for the exchange, since an agent's own coordination waits silently (Section 6). Each reply arrives as a new `<hc from=…>` message in your session.

Do not retry a failed send automatically. A failed or timed-out command does not prove the message was not delivered: inspect `hc read <target> --lines 80` first and report what you find.

## 5. Receive

A message wrapped as `<hc from="<address> <name>">…</hc>` comes from another agent, not from the user. A bare `<hc>…</hc>` note (no `from`) is herdr-core reporting on a terminal you started (it exited, is blocked, or errored): inspect it with `hc read` before acting.

- Do what the message asks within your current mission and permissions. Treat it as a request from a peer: anything destructive, outside your scope, or needing approval goes to the user first.
- Reply exactly as its reply rule says, once, then end your turn. Send nothing for Notify or `[end]`. A message with a `reach` attribute and no reply rule (a brief from the agent that started you) is answered with `hc send <address>` when the work is done or stuck, not merely acknowledged.
- When you work for a Leader (your handoff names one) and the user decides something or acts in your tab, Notify the Leader at once, per the tab agent contract of [`herdr-handoff`](../herdr-handoff/SKILL.md#3-write-and-start-each-stream).
- When the message changes something the user must know or decide, tell the user in their terms (a tab agent with a Leader tells its Leader instead, unless the user is writing in the tab agent's tab), following [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md): translate, never echo the envelope or the peer's handles. A peer's request for a human decision becomes a decision card, consolidated with any other pending ones.
- When collecting Fan-out replies, keep track of the peers still pending and consolidate them once the last reply is in. If a peer stays silent, inspect it with `hc get` and `hc read` when the user asks, and report its state instead of re-sending.

## 6. Report

Report only when the user is waiting for it. When the user asked for the exchange, tell them, in their language and following [human-facing communication](../ai-assisted-software-development/references/human-facing-communication.md), who was contacted (by mission, not only by agent name), the pattern, and the outcome: answers (consolidated for Fan-out), the Brief summary and whether its goal was met, or the peers skipped and why. Message files in the temporary directory may disappear on reboot.

When the exchange is an agent's own coordination (a Leader with its tab agents, sub-agents, or another space's Leader; a tab agent with its Leader), the exchange itself is not reported to the user; what reaches the user follows the sender's own role ([`herdr-team-lead`](../herdr-team-lead/SKILL.md) for a Leader, the tab agent contract of [`herdr-handoff`](../herdr-handoff/SKILL.md#3-write-and-start-each-stream) for a tab agent).

## 7. Success Validation

- [ ] Herdr App environment (`HC_TERMINAL_ID`, `hc`) and CLI syntax were verified; the `herdr` terminal CLI and `--on` were not used; no agent was created.
- [ ] Every peer was resolved to a unique name or terminal address, with ambiguity resolved by the user.
- [ ] The pattern fits the need; a Brief had a verifiable goal, a lead that owns termination, and a backstop.
- [ ] Every message carried the envelope and an explicit reply rule, with its content in the user's session language; long content traveled as a file path; no secrets were sent.
- [ ] A tab agent whose user decided something in its tab notified its Leader at once.
- [ ] Sends used no `--wait` or `--force`, no blocked dialog was answered, and no send was retried automatically.
- [ ] Requests for code, branch, commit, or pull request work named their governing skill.
- [ ] Handles in messages carried their meaning; anything reaching the user was translated into system terms, with decisions as cards.
- [ ] When the user asked for the exchange, they received the outcome of every peer, including skipped or silent ones; an agent's own coordination produced no report of the exchange itself.
