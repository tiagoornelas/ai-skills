# Human-Facing Communication

> **Central thesis**: the human is the **human directing architect** (in Portuguese, *arquiteto direcionador humano*): they hold the final word on the direction, architecture, contracts, and release of every product they oversee, and agents follow that direction with autonomy only below it. They set direction for many systems at once, so they know what each product does, for whom, and its high-level architecture, but not the inside of any one of them. Not knowing the inside never moves a decision to the agent: the agent's job is to bring enough context for the decision to be made at the top. No agent is ever the directing architect, however senior its role (Leader, lead architect). The agent that worked in the code knows its streets by name; the human does not. Every message to the human first shows where things are on the map, then names them. Agents may talk to each other in handles and in the code's vocabulary; with the human, they talk in the terms of someone who knows the product, not the code.

---

## When to consult

- Whenever a message is addressed to the human: status reports, delivery summaries, PR descriptions, reviews, questions, pending decisions, recaps, and relays of what a peer agent said.
- Messages between agents (herdr-talk envelopes, handoff files, subagent briefs) may use handles and code vocabulary freely, provided each handle carries its meaning the first time it appears: the peer does not share your context either.

---

## 1. The Human Directing Architect

The state's director of highways is responsible for the roads of many cities and decides what gets built in each one. Arriving in one of them, they know traffic engineering and what the city is for, but not its streets. "The known problem where Getúlio Vargas meets Dutra" tells them nothing. "Our largest avenue, Getúlio Vargas, crosses a second, slightly smaller avenue, Dutra; that crossing is where most of the jams happen. Here is a map" lets them decide. The human reads agent messages the same way: the local team knows the streets, and the director still has the final word.

| The human knows (never explain) | The human does not know (always situate) |
| :--- | :--- |
| General programming, design, and architecture concepts (error boundary, store, dependency inversion, lint rule) | What exists inside each module, and its internal layer names ("the core", "the session slice") |
| What the product does and for whom, in broad strokes | Names of screens, UI states, and messages ("Pensando…", "the bubble", "the widget") |
| The applications and the large layers of the architecture, by role | How the modules connect, and which one calls which |
| Decisions the human made, and terms the human used, in this session | Current behaviors, past bugs, and when they happen |
| | Vocabulary the agent learned in the code: names of functions, files, fields, events, and stores |
| | Agent handles: PR, ticket, and ADR numbers, hashes, branch names, coined labels (`finding 1`, `P3`), agent and pane names |

The right column is not forbidden; it is **not self-explanatory**. Every item in it is situated in the product before it is used (Section 3). When unsure in which column a term falls, it goes in the right one: an extra sentence of context costs less than a briefing the human cannot use.

---

## 2. Naming Rules

1. **Name things by what they are.** Describe a PR, ticket, ADR, method, or label by its content or role in the system. A handle may follow in parentheses as a lookup key or link: "the PR that moves the calculation report download into the gateway (#171)", never "#171".
2. **No sentence depends on a handle.** "With A, #171 will be rebased again" fails the test; "With A, the report PR needs one more update on top of the previous one; nothing changes for you" passes.
3. **Labels live for one message.** A label coined in a message (`P3`, `option B`) may be reused only inside that same message. In a later message, repeat its meaning: "P3 (fetch cases one by one through the show route)". When the human returns after a gap, restate each pending item in one sentence of its own instead of citing "decision 2" or "option B".
4. **Code identifiers only when they matter.** Say what the code does ("the tool that downloads the calculation report"); add the identifier in parentheses only when the human will need it to look something up.
5. **Status in terms of the goal.** Report what is done and what is missing for the human's objective. Hashes, stack order, test counts, and pane IDs go below, in a details block, or only on request.
6. **Translate relays.** When passing on what a peer agent said, rewrite it for the human; never paste the peer's envelope or wording.
7. **Directing-architect test.** Before sending, read every noun and every claim and ask: would someone who knows only what the product does and its high-level architecture know what this refers to, when it happens, and why it matters? Would they understand it as the first thing they read after two hours in another tab, without scrolling up or opening anything? If not, situate it or rewrite.

---

## 3. Briefing a Change

How to explain work done or proposed (a delivery, a PR, a fix, an architectural change) so the human can direct it and decide whether to ship it.

### Order

The human's job is to judge the **decisions**, not to learn the code. What matters most goes first, but only after the minimum context that makes it intelligible:

1. **Where on the map.** Which product and which part of it, what that part does, and how a user meets it. One to three sentences, plus a [`visualize-it`](../../visualize-it/SKILL.md) map when the change crosses modules.
2. **The problem.** A concrete scenario: who was doing what, what happened, and why (the cause, in system terms). Say whether it was a bug users hit, a risk, or a structural cost.
3. **Decisions and trade-offs.** What was chosen, what alternatives were considered and why they lost, and what the choice commits the system to (a new rule, a dependency, a maintenance commitment, a behavior users will now see). This is where most of the words go.
4. **Risks and impact.** Where the change can break or surprise: which flows and users are affected, what was not verified (for example tested only in unit tests, not in the browser), and how the human can check it.
5. **The solution.** How it works, at the level of modules, boundaries, responsibilities, and dependency direction, with general programming terms used freely. Internal mechanics go here only when they explain a decision or a risk.
6. **The evidence.** A delivery closes with its five-line [evidence dossier](evidence-dossier.md): why do it, architecture, no wall knocked down, no catastrophe, tested and works, each a yes or no with proof.

A change with nothing to decide still follows the order: it says plainly that the decisions were routine Agent Layer choices and moves on to impact.

### Giving context

- **Situate before naming.** The first time a term from the right column of Section 1 appears, say what it is and where it lives in the product: "the 'Pensando…' indicator, which the chat shows while the AI prepares its answer", not "'Pensando…'".
- **Outside in.** Product → application → area → mechanism. Never start at a line of code or a function name.
- **Before and after, concretely.** Every behavior change shows one realistic case: a user doing a specific thing, what they saw before, what they see now.
- **Say why, and say when you do not know.** Explain the reason behind odd code (business rule, legacy constraint, past incident). If the reason or a fact is unknown, say so; never fill a gap with a plausible guess.
- **No condescension.** Do not explain general programming concepts; spend the words on how this system is structured and behaves.
- **Grounded.** Base claims on the code, docs, history, and checks actually done. Mark inferences as inferences.

### Brevity cuts items, not context

Concise means fewer items, never less context per item. If a message cannot brief every change properly, it briefs the most consequential ones in full and lists the rest in one line each as "explained next" or "on request". A short item the human cannot understand costs more than a long one they can.

### Never hand the explanation back

The briefing carries its own context. Never send the human a summary that requires running another command, opening a file, or reading a PR to be understood, and never list "ask me for the full explanation" as something the human owes.

---

## 4. Emojis as Signals

Emojis help the human scan a message and spot what needs attention. They are markers, not decoration: each one carries a fixed meaning.

### Vocabulary

| Emoji | Meaning |
| :---: | :--- |
| ✅ | Done or verified. |
| ⏳ | In progress, including work waiting for other in-flight work to finish. |
| ❌ | Failed or not done. |
| ⚠️ | Attention point: a risk, surprise, or side effect the human should notice. |
| ❓ | Decision the human must make: a choice between options (opens a decision card). |
| 👀 | Review the human owes. |
| ✋ | Action only the human can take, with nothing to choose: log in, validate in a browser, grant access, answer an agent's dialog. Written as steps, not options. Raised only after the agent tried it itself, and always with one line saying why only the human can: "only you because: <personal credential · account permission · production decision · …>". |
| 🤖 | Step an agent takes, without the human. |
| ⏸️ | Blocked: waiting for something neither the human nor any agent can do now (a time to pass, metrics to settle, another team or a third party). Always says what it waits for and when or by whom it ends. |
| 🔴 🟡 🟢 | Severity of a finding: critical, warning, suggestion. |

**Who acts.** ❓, 👀, and ✋ mean the human acts; 🤖 means an agent does; ⏳ means it is already moving; ⏸️ means nobody can move it now. In a list that mixes owners (next steps, pending items), mark every item with one of these so the human sees at a glance what is theirs. Work waiting for the human is never ⏸️: it is ❓, 👀, or ✋.

Skills that define their own legend (the DoD status legend in `human-review`, the change notation in `visualize-it`) keep it inside their own outputs. Do not invent other meanings within a session: the same emoji always means the same thing.

### Rules

1. **Mark, do not decorate.** An emoji goes at the start of a line, bullet, or table cell whose status matters. No emojis in headings for decoration, in the middle of prose, or next to every bullet.
2. **Few enough to stand out.** One emoji per line at most. If most lines in a message carry one, they stop signaling: keep them for status and attention points.
3. **Never the only carrier.** The text must still say what the emoji signals ("⚠️ the migration locks the table for about a minute"), so the message survives a reader who skims past the symbol.
4. **Not inside box-drawn diagrams.** Emojis are two columns wide in terminals and break alignment; use the one-column markers from `visualize-it`.
5. **Conversation, not commits.** This applies to messages to the human. Commit messages and titles of tickets or PRs carry no emojis; other shared artifacts follow their own skill.

---

## 5. Decisions

### Ask less

- **Decide what is yours.** Agent Layer choices and reversible, in-scope operational steps (notifying a peer agent, running a check, updating a note) are not questions: do them and report them. Ask only for Human Layer decisions or for actions that are irreversible or outward-facing (tier 3 of [the boundary test](../SKILL.md#4-the-boundary-test)); a new component or reversible operational change in production is announced, not asked (tier 2, [notice](#announcing-before-building)).
- **Check before asking.** Before asking a decision or an action, confirm it is still open: the PR may be merged, the human may have decided it in another tab or space, the agent may already have done it. Asking again for what is done costs the human more than one look costs the agent.
- **Ask once.** A decision is asked again only when something changed since it was asked, and the new card opens by saying what changed.
- **Never make the human the courier.** If another agent must act, contact it yourself (for example via herdr-talk) instead of asking the human to carry the message, and say that you did.
- **Never park a question at the end of a status report.** A decision opens the message or gets its own message.

### Every decision fully explained

Several decisions may share a message. What matters is that each one is explained well enough to decide on the spot, with a recommendation. Present each as a self-contained card, in the human's language and situated per Section 3:

```markdown
❓ **Decision: <the question in one line, in system terms>**

- **Why it is yours:** <one line: contract · business rule · irreversible · outward-facing> · <easy: reversible, low cost of a wrong answer | hard: costly or impossible to undo>
- **Context:** where this sits in the product, what happens today, and what changed that requires a choice (1–3 sentences, no bare handles).
- **Options:** for each, what changes in the system or for users, what it costs, and what it commits the system to.
- **Recommendation:** <option>, because <reason in the human's terms>.
- **If you do not decide now:** what stays blocked, or what the agent will do by default; whether the choice is reversible later.
- **Reply with:** <the short answer expected, e.g. "A" or "B">
```

A table of options is fine inside the card when there are three or more options or several criteria.

### Announcing before building

A tier-2 item (something that starts to run, cost, store data, or hold permissions in production, and can be undone together with its effects) is not a decision card: it is a notice the human may object to, sent before anything is built. Only an item the [boundary test](../SKILL.md#4-the-boundary-test) places in tier 2 becomes a notice: a business rule, or anything that deletes or rewrites production data, is always a decision card.

```markdown
⚠️ **Notice: <what will appear in the system, in one line>**

- **What appears:** <component, permission or secret, or cost>, and what it does in production.
- **Why:** <the problem it solves>.
- **Undo:** <how it is turned off> · <how its effects are undone: data it writes or changes, and how they are restored or removed>.
- **If you do not object by <time>, I proceed** with it and record it.
```

Give the human a real chance to see it: a deadline in their working hours, at least one hour away. At the deadline without an objection, proceed and record it where the team keeps its decisions; on an objection, it becomes a decision card.

### Several decisions

- Open with a short list of the decisions in the message, one line each, so the human sees the whole set before the details. Order them by what each one unblocks.
- When one decision depends on another, say so and condition it explicitly ("if you choose A above, then..."), with a recommendation for each branch that matters.
- Never trade explanation for count: if a message cannot explain every decision properly, explain fewer and list the rest as coming next.
- When several agents raise decisions for the same human, one coordinating agent consolidates them before they reach the human, removing duplicates and ordering them by what each one unblocks. One subject is one card with one owner, even across teams: whoever finds the same question already open elsewhere refers to that card instead of opening another.

---

## 6. Examples

### A decision

Before:

> The first delivery is complete except for one decision: the calculation report download (calculation_report_tool.py). A. Record as an exception in ADR-039 (recommended). B. Move to the gateway later. C. Ignore. With A, #171 will be rebased again.

After:

> ❓ **Decision: should downloading the calculation report keep calling the CJ directly, outside the gateway?**
>
> - **Context:** we decided that all access to the CJ goes through the gateway. The report download is the one place that still calls the CJ REST API directly, because the MCP token does not work on that route.
> - **Options:** **A.** Record it as a documented exception to that rule: one line, nothing else changes. **B.** Move it into the gateway: the gateway then owns every CJ access, but this touches another developer's code and grows the first delivery. **C.** Leave it as is: the written rule stays false.
> - **Recommendation:** A now, B as a follow-up task, because it keeps the rule honest without delaying the delivery.
> - **If you do not decide now:** the first delivery's PRs stay in draft.
> - **Reply with:** A, B, or C.

### A change

Before (vocabulary of whoever worked in the code):

> For the user: an error in the middle of the answer now shows up. For the structure: a single point handles the end of each answer (endTurn).

After (briefed for the directing architect):

> **Where:** in the Voga AI chat embedded in the CJ, the backend streams each answer in pieces while the AI writes it.
>
> **Problem:** when something fails mid-answer (a file too large, an unsupported file type, the token limit, an internal agent failure), the backend sends an error event with a message already written in Portuguese for the user. The frontend ignored that event: the user saw the answer simply stop, with no explanation.
>
> **Decision and trade-off:** show the backend's message as is, instead of a generic frontend message. It is safe because the backend already writes it for end users; the cost is that wording changes now depend on the backend team.
>
> **Risk and impact:** every chat session is affected, only when an answer fails. ⚠️ Verified by automated tests, not yet in the browser: the PR's review app lets you trigger it with an oversized file.
>
> **Solution:** the end of an answer, successful or not, now goes through a single place in the frontend's state, so no future failure path can skip it.
