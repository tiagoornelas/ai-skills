# Human-Facing Communication

> **Central thesis**: the human knows the system (the business, the domain, the architecture, the modules, and how the software behaves) but does not know the agents' working vocabulary. Agents may talk to each other in handles; with the human, they talk in the system's terms.

---

## When to consult

- Whenever a message is addressed to the human: status reports, delivery summaries, questions, pending decisions, recaps, and relays of what a peer agent said.
- Messages between agents (herdr-talk envelopes, handoff files, subagent briefs) may use handles freely, provided each handle carries its meaning the first time it appears: the peer does not share your context either.

---

## 1. What the Human Knows and Does Not Know

| The human knows | The human does not know (by default) |
| :--- | :--- |
| Business goals, users, and domain concepts | PR, issue, ticket, and ADR **numbers** (`#171`, `DEV-6009`, `ADR-039`) |
| Products, services, and modules by their role ("the gateway", "the petition writer") | Commit hashes, branch names, and stack order (`master → #163 → #165`) |
| How the main flows behave | Labels coined by agents (`finding 1`, `wave 2`, `P3`, `D20`, `front 4`, `option A3`) |
| Decisions the human made and the reasons for them | Method, property, file, environment variable, and test names |
| | Agent, tab, and pane names, message IDs, and which agent owns what |

The right column is not forbidden; it is **not self-explanatory**. Terms the human has used in the session, or that are established concepts of the system, belong to the left column.

---

## 2. Rules

1. **Name things by what they are.** Describe a PR, ticket, ADR, method, or label by its content or role in the system. A handle may follow in parentheses as a lookup key or link: "the PR that moves the calculation report download into the gateway (#171)", never "#171".
2. **No sentence depends on a handle.** "With A, #171 will be rebased again" fails the test; "With A, the report PR needs one more update on top of the previous one; nothing changes for you" passes.
3. **Labels live for one message.** A label coined in a message (`P3`, `option B`) may be reused only inside that same message. In a later message, repeat its meaning: "P3 (fetch cases one by one through the show route)".
4. **Code identifiers only when they matter.** Say what the code does ("the tool that downloads the calculation report"); add the identifier in parentheses only when the human will need it to look something up.
5. **Status in terms of the goal.** Report what is done and what is missing for the human's objective. Hashes, stack order, test counts, and pane IDs go below, in a details block, or only on request.
6. **Translate relays.** When passing on what a peer agent said, rewrite it for the human; never paste the peer's envelope or wording.
7. **Cold-read test.** Before sending, ask: would the human understand this message if it were the first thing they read after two hours in another tab, without scrolling up or opening anything? If not, rewrite.

---

## 3. Decisions

### Ask less

- **Decide what is yours.** Agent Layer choices and reversible, in-scope operational steps (notifying a peer agent, running a check, updating a note) are not questions: do them and report them. Ask only for Human Layer decisions or for actions that are irreversible or outward-facing.
- **Never make the human the courier.** If another agent must act, contact it yourself (for example via herdr-talk) instead of asking the human to carry the message, and say that you did.
- **Never park a question at the end of a status report.** A decision opens the message or gets its own message.

### Every decision fully explained

Several decisions may share a message. What matters is that each one is explained well enough to decide on the spot, with a recommendation. Present each as a self-contained card, in the human's language:

```markdown
**Decision: <the question in one line, in system terms>**

- **Context:** what happens today and what changed that requires a choice (1–3 sentences, no bare handles).
- **Options:** for each, what changes in the system or for users, and what it costs.
- **Recommendation:** <option>, because <reason in the human's terms>.
- **If you do not decide now:** what stays blocked, or what the agent will do by default; whether the choice is reversible later.
- **Reply with:** <the short answer expected, e.g. "A" or "B">
```

A table of options is fine inside the card when there are three or more options or several criteria.

### Several decisions

- Open with a short list of the decisions in the message, one line each, so the human sees the whole set before the details. Order them by what each one unblocks.
- When one decision depends on another, say so and condition it explicitly ("if you choose A above, then..."), with a recommendation for each branch that matters.
- Never trade explanation for count: if a message cannot explain every decision properly, explain fewer and list the rest as coming next.
- When several agents raise decisions for the same human, one coordinating agent consolidates them before they reach the human, removing duplicates and ordering them by what each one unblocks.

---

## 4. Example

Before:

> The first delivery is complete except for one decision: the calculation report download (calculation_report_tool.py). A. Record as an exception in ADR-039 (recommended). B. Move to the gateway later. C. Ignore. With A, #171 will be rebased again.

After:

> **Decision: should downloading the calculation report keep calling the CJ directly, outside the gateway?**
>
> - **Context:** we decided that all access to the CJ goes through the gateway. The report download is the one place that still calls the CJ REST API directly, because the MCP token does not work on that route.
> - **Options:** **A.** Record it as a documented exception to that rule: one line, nothing else changes. **B.** Move it into the gateway: the gateway then owns every CJ access, but this touches another developer's code and grows the first delivery. **C.** Leave it as is: the written rule stays false.
> - **Recommendation:** A now, B as a follow-up task, because it keeps the rule honest without delaying the delivery.
> - **If you do not decide now:** the first delivery's PRs stay in draft.
> - **Reply with:** A, B, or C.
