# Human-Facing Communication

> **Central thesis**: the human is the **human directing architect**: they hold the final word on the direction, architecture, contracts, and release of every product they oversee, and agents decide above it only inside a delivery, for the human to ratify before merge. They set direction for many systems at once, so they know what each product does, for whom, and its high-level architecture, but not the inside of any one of them. Not knowing the inside never moves the final word to the agent: the agent's job is to bring enough context for the human to judge each decision at the top. No agent is ever the directing architect, however senior its role (a lead architect, for instance). The agent that worked in the code knows its streets by name; the human does not. Every message to the human first shows where things are on the map, then names them. With the human, agents talk in the terms of someone who knows the product, not the code.

---

## When to consult

- Whenever a message is addressed to the human: status reports, delivery summaries, PR descriptions, reviews, questions, pending decisions, recaps, and summaries of what a subagent or reviewer reported.
- Text written for another agent (handoff files, subagent briefs) may use handles and code vocabulary freely, provided each handle carries its meaning the first time it appears: the peer does not share your context either.

---

## 1. The Human Directing Architect

The state's director of highways is responsible for the roads of many cities and decides what gets built in each one. Arriving in one of them, they know traffic engineering and what the city is for, but not its streets. "The known problem where Getúlio Vargas meets Dutra" tells them nothing. "Our largest avenue, Getúlio Vargas, crosses a second, slightly smaller avenue, Dutra; that crossing is where most of the jams happen. Here is a map" lets them decide. The human reads agent messages the same way: the local team knows the streets, and the director still has the final word.

| The human knows (never explain) | The human does not know (always situate) |
| :--- | :--- |
| General programming, design, and architecture concepts (error boundary, store, dependency inversion, lint rule) | What exists inside each module, and its internal layer names ("the core", "the session slice") |
| What the product does and for whom, in broad strokes | Names of screens, UI states, and messages ("Thinking…", "the bubble", "the widget") |
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
5. **Status in terms of the goal, bottom line first.** Open with what the human must know, decide, or do, in the shape of a [`tl-dr`](../../tl-dr/SKILL.md) digest, and keep the message to one screen; details come only when the human points at them. Inside a delivery, every message where the agent stops ends with its [stage line](../../agentic-parallel-work/SKILL.md#2-the-stages). Hashes, stack order, test counts, and pane IDs appear only on request.
6. **Translate reports.** When passing on what a subagent or reviewer reported, rewrite it for the human; never paste its wording.
7. **Directing-architect test.** Before sending, read every noun and every claim and ask: would someone who knows only what the product does and its high-level architecture know what this refers to, when it happens, and why it matters? Would they understand it as the first thing they read after two hours in another tab, without scrolling up or opening anything? If not, situate it or rewrite.

---

## 3. The Delivery Report

The one message that hands a delivery to the human when [stage 4](../../agentic-parallel-work/SKILL.md#2-the-stages) ends, so the human can answer once. The layout is an example in the human's language; the content is mandatory, and it fits one screen:

````markdown
<one sentence: what changes, for whom, where in the product> · ✅ proven on the current version

<the change card: the tree of what enters, and its last line>

⚖️ <each decision to ratify, one line, ordered by cost to reverse>
👀 <what the human should see with their own eyes, when anything: a screen, a flow, with its link; for each PR they have not reviewed, whether human-review is worth running before they ratify, and why>

<the six proofs, one line each: mark, claim, and its proof (a link, a command with its real output excerpt, screenshots)>
<one PR line per PR: its link and the human's review state, as provide-evidence shows it>
📋 <when no issue holds the objective: an offer to register it with report-work>

⚖️ Reply "ratify and merge" (merge in <order>, then <closing steps>) or say what to change.
Stage 5/7 · ratify · next: ⚖️ you
````

- **Details on request.** The full argument of a proof, a decision's context and options, or a swimlane of a changed flow appear when the human points at them, briefed per [Explaining a change](#explaining-a-change).
- **One reply covers the delivery.** The closing line names the merge, its order, and the closing steps of [`agentic-parallel-work`](../../agentic-parallel-work/SKILL.md#2-the-stages), so "ratify and merge" authorizes exactly those. A reply that changes something sends the delivery back to building; it returns as a new delivery report, re-proven, without the human asking.
- **Not proven, not presented as ready.** When two review rounds still leave a ❌, the same message goes out with ⚠️ and the gap in its first line, what is missing and who acts under each ❌, no merge request, and the stage line `Stage 4/7 · blocked: <the gap> · next: <who acts>`.
- **Patterns used (when any).** When the implementation applied a pattern from [`design-patterns`](../../design-patterns/SKILL.md), add one informational line before the proofs naming the pattern, where it sits in product terms, and its variation axis (no `⚖️` and no change-card leaf, unless it crosses a boundary or contract). Omit when none was used.

### Explaining a change

When the human points at a part, or asks how a change works, brief it from the outside in, so they can judge the decisions without learning the code:

1. **Where on the map**: which product and part, what it does, how a user meets it; a [`visualize-it`](../../visualize-it/SKILL.md) swimlane when a flow across places changed.
2. **The problem**: a concrete scenario, who did what, what happened, and why.
3. **Decisions and trade-offs**: what was chosen, why, and what it commits the system to.
4. **Risks and impact**: which flows and users are affected, and what was not verified.
5. **The solution**: at the level of modules, boundaries, and responsibilities.

### Giving context

- **Situate before naming.** The first time a term from the right column of Section 1 appears, say what it is and where it lives in the product: "the 'Thinking…' indicator, which the chat shows while the AI prepares its answer", not "'Thinking…'". The same rule for any reader, with terms the agent coins on the spot, is in [`unslop`](../../unslop/SKILL.md).
- **Outside in.** Product → application → area → mechanism. Never start at a line of code or a function name.
- **Before and after, concretely.** Every behavior change shows one realistic case: a user doing a specific thing, what they saw before, what they see now.
- **Say why, and say when you do not know.** Explain the reason behind odd code (business rule, legacy constraint, past incident). If the reason or a fact is unknown, say so; never fill a gap with a plausible guess.
- **No condescension.** Do not explain general programming concepts; spend the words on how this system is structured and behaves.
- **Grounded.** Base claims on the code, docs, history, and checks actually done. Mark inferences as inferences.

### Brevity cuts items, not context

Concise means fewer items, never less context per item. If a message cannot brief every change properly, it briefs the most consequential ones in full and lists the rest in one line each as "explained next" or "on request". A short item the human cannot understand costs more than a long one they can.

### Never hand the explanation back

Every message carries its own context: it never requires running another command, opening a file, or reading a PR to be understood.

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
| ⚖️ | Decision the human must make: a choice between options, or a decision to ratify. |
| 👀 | Something the human must see with their own eyes: a screen, a behavior in the running app, a PR to review. |
| 💪 | A task the human performs by hand because no agent can: log in, validate in a browser, grant access, answer an agent's dialog, run a deploy that needs their credential. Written as steps, not options. Raised only after the agent tried it itself, and always with one line saying why only the human can: "only you because: <personal credential · account permission · …>". Never a decision, an authorization, a ratification, or advice: those are ⚖️. |
| 🤖 | Step an agent takes, without the human. |
| ⏸️ | Blocked: waiting for something neither the human nor any agent can do now (a time to pass, metrics to settle, another team or a third party). Always says what it waits for and when or by whom it ends. |
| 🔴 🟡 🟢 | Severity of an open finding: critical, warning, suggestion. |

**Who acts.** ⚖️, 👀, and 💪 mean the human acts; 🤖 means an agent does; ⏳ means it is already moving; ⏸️ means nobody can move it now. In a list that mixes owners (next steps, pending items), mark every item with one of these so the human sees at a glance what is theirs. Work waiting for the human is never ⏸️: it is ⚖️, 👀, or 💪.

Skills that define their own symbols (the marks of the [change card](change-card.md)) keep them inside their own outputs. Do not invent other meanings within a session: the same emoji always means the same thing.

### Definition of Done Legend

Wherever delivered behaviors are listed against their verification for the human (a code review, a conflict resolution), each behavior carries one of these:

| Status | Meaning |
| :---: | :--- |
| ✅ | Covered by a named automated test verifying behavior through the public interface. |
| 🔎 | Not code-testable; verified by alternative means, with the method disclosed. |
| 👀 | Requires manual human validation. |
| 🚨 | Missing, or lacking both test coverage and declaration. |

Prompt instructions or documentation are never automated verification.

### Rules

1. **Mark, do not decorate.** An emoji goes at the start of a line, bullet, or table cell whose status matters. No emojis in headings for decoration, in the middle of prose, or next to every bullet.
2. **Few enough to stand out.** One emoji per line at most. If most lines in a message carry one, they stop signaling: keep them for status and attention points.
3. **Never the only carrier.** The text must still say what the emoji signals ("⚠️ the migration locks the table for about a minute"), so the message survives a reader who skims past the symbol.
4. **Not inside box-drawn diagrams.** Emojis are two columns wide in terminals and break alignment; use one-column marks (`+ ~ - ? !`, `■`, `▲`) as the [change card](change-card.md) and [`visualize-it`](../../visualize-it/SKILL.md) do.
5. **Color shows the current state.** 🔴, 🟡, and ❌ mark only what is still open and needs attention now. A resolved item carries ✅ alone; when its past severity matters, say it in words ("was critical, fixed with a test"). Never pair a past mark with the current one (`🔴→✅`, `❌→✅`, `✅ 🟡`).
6. **Conversation, not commits.** This applies to messages to the human. Commit messages and titles of tickets or PRs carry no emojis; other shared artifacts follow their own skill.

---

## 5. Decisions

### Ask less

- **Decide, then present.** Agent Layer choices are done and reported; Human Layer decisions inside a delivery are taken and [presented for ratification](#presenting-decisions-taken). Ask only before an action where the agent [always stops](../SKILL.md#where-the-agent-always-stops), or for a choice outside any delivery that only the human can make.
- **Run instead of asking.** When running something (a test, a prototype, a query, a look at the running app) can answer the question, run it and decide.
- **Check before asking.** Before asking a decision or an action, confirm it is still open: the PR may be merged, the human may have decided it in another tab or space, the agent may already have done it. Asking again for what is done costs the human more than one look costs the agent.
- **Ask once.** A decision is asked again only when something changed since it was asked, and the new card opens by saying what changed.
- **Never make the human the courier.** Agents do not message each other ([`agentic-parallel-work`](../../agentic-parallel-work/SKILL.md#3-who-talks-to-whom)), so never ask the human to carry a message to another agent either. What one delivery needs from another is a contract: the delivery that owns it decides it and presents it for ratification.
- **Never park a question at the end of a status report.** A decision opens the message or gets its own message.

### Every decision fully explained

Several decisions may share a message. What matters is that each one is explained well enough to decide on the spot, with a recommendation. Present each as a self-contained card, in the human's language and situated per Section 3:

```markdown
⚖️ **Decision: <the question in one line, in system terms>**

- **Why it is yours:** <one line: the action that leaves the branch, or why only the human can choose> · <easy: reversible, low cost of a wrong answer | hard: costly or impossible to undo>
- **Context:** where this sits in the product, what happens today, and what changed that requires a choice (1–3 sentences, no bare handles).
- **Options:** for each, what changes in the system or for users, what it costs, and what it commits the system to.
- **Recommendation:** <option>, because <reason in the human's terms>.
- **If you do not decide now:** what stays blocked, or what the agent will do by default; whether the choice is reversible later.
- **Reply with:** <the short answer expected, e.g. "A" or "B">
```

A table of options is fine inside the card when there are three or more options or several criteria.

### Presenting decisions taken

A Human Layer decision the agent took inside a delivery ([decided by the agent, ratified at delivery](../SKILL.md#decided-by-the-agent-ratified-at-delivery)) is not asked: it is one line of the [delivery report](#3-the-delivery-report), one per `?` and `!` item of the change card, ordered by cost to reverse, tier 3 first:

```markdown
⚖️ <what the agent decided, in system terms> · <why, naming the principle or the evidence; "low confidence" when the evidence is thin> · <cost to reverse after merge>
```

The options not taken stay out. When the human points at a decision, give its context, the options weighed, and the evidence, per [Explaining a change](#explaining-a-change).

### Several decisions

- Open with a short list of the decisions in the message, one line each, so the human sees the whole set before the details. Order questions by what each one unblocks, and decisions to ratify by cost to reverse. A change card's `?` and `!` items are that list.
- When one decision depends on another, say so and condition it explicitly ("if you choose A above, then..."), with a recommendation for each branch that matters.
- Never trade explanation for count: if a message cannot explain every decision properly, explain fewer and list the rest as coming next.
- One subject is one card with one owner, even across deliveries: whoever finds the same question already open elsewhere (another delivery's PR or issue) refers to that card instead of opening another.

---

## 6. Examples

### A decision taken

Before:

> The first delivery is complete. Decision: the calculation report download (calculation_report_tool.py) stays outside the gateway, recorded as an exception in ADR-039. #171 was rebased.

After:

> ⚖️ Downloading the calculation report keeps calling the billing system directly, outside the gateway · the gateway's token fails on that route, so the rule gets a documented exception · cheap to reverse: moving it later touches one route

### A change

Before (vocabulary of whoever worked in the code):

> For the user: an error in the middle of the answer now shows up. For the structure: a single point handles the end of each answer (endTurn).

After (briefed for the directing architect):

> **Where:** in the AI assistant chat embedded in the web app, the backend streams each answer in pieces while the AI writes it.
>
> **Problem:** when something fails mid-answer (a file too large, an unsupported file type, the token limit, an internal agent failure), the backend sends an error event with a message already written for the user in their language. The frontend ignored that event: the user saw the answer simply stop, with no explanation.
>
> **Decision and trade-off:** show the backend's message as is, instead of a generic frontend message. It is safe because the backend already writes it for end users; the cost is that wording changes now depend on the backend team.
>
> **Risk and impact:** every chat session is affected, only when an answer fails. ⚠️ Verified by automated tests, not yet in the browser: the PR's review app lets you trigger it with an oversized file.
>
> **Solution:** the end of an answer, successful or not, now goes through a single place in the frontend's state, so no future failure path can skip it.
