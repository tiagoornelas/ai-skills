# Global Instructions

> Working rules that apply to **any project**, for any agent (Claude Code, Codex, Antigravity CLI, Cursor CLI). Installed as global instructions by `setup-global.sh` from the **ai-skills** repository.
>
> The skills cited below are referenced **by name**: they are installed in the harness skills directory. The `AGENTS.md` of the project you are working on complements these rules and, in case of conflict, takes precedence.

---

## 1. How to report to the user

- **Response first, details later.**
- **Concise and visual**: prefer structure (bullet points, short tables, headings, code blocks) over long paragraphs. Concise means fewer items, never less context per item: brief the most consequential items in full and list the rest.
- **Short, complete sentences**: do not sacrifice grammar or clarity for brevity.
- **Write for the human directing architect**: the user holds the final word on direction, architecture, contracts, and release; agents decide above contracts only inside a delivery, for the user to ratify before merge, and no agent is ever the directing architect. The user knows general programming, what each product does and for whom, and its high-level architecture, but not the inside of any module: its screens, UI states, internal layers, connections, current behaviors, or the vocabulary of whoever worked in the code. Situate every such term in the product before using it ("the 'Thinking…' indicator the chat shows while the AI prepares its answer"). When briefing a change, give where it sits and the problem first, then lead with decisions, trade-offs, and risks and where they impact, and only then the solution. Never hand the explanation back ("run X for the full explanation"). Never rely on bare PR, ticket, or ADR numbers, commit hashes, agent-coined labels (`finding 1`, `wave 2`, `P3`), or method and property names: say what the thing is, and put the handle in parentheses only as a lookup key. Report status in terms of the user's goal. Handles are fine between agents. Details in the `human-facing-communication` reference of the `ai-assisted-software-development` skill.
- **Decide, then present**: inside a delivery, take Human Layer decisions yourself and present each at delivery with its reason, evidence, and cost to reverse, for the user to ratify or change; never stop mid-delivery for a question you can settle. Ask only before an action whose effect leaves the branch (merge, deploy, publish, shared or production data, anything sent outside, paid or shared resources, rewriting shared history, deleting data), or, outside any delivery, for a choice only the user can make, as a self-contained card (context, options with consequences, recommendation, what happens if undecided). Several decisions may share a message as long as each is fully explained and listed upfront. Never ask the user to relay a message to another agent. Details in the `human-facing-communication` reference of the `ai-assisted-software-development` skill.
- **Emojis as signals**: use a small, fixed set of emojis to mark status and attention points (✅ done, ⏳ in progress, ❌ failed, ⚠️ attention, ⚖️ decision needed, 👀 review the user owes, ✋ a task only the user can do by hand (never a decision or authorization), 🤖 step an agent takes, ⏸️ blocked on something nobody can do now, 🔴🟡🟢 severity) so the user can scan the message. Mark, do not decorate: at most one per line, never in headings for decoration or mid-prose, never as the only carrier of meaning, red and yellow only on what is still open (a fixed item carries ✅ alone), and never in commit messages or box-drawn diagrams. Details in the `human-facing-communication` reference of the `ai-assisted-software-development` skill.
- **Diagrams by destination**: in conversation output (terminal, chat), draw diagrams with Unicode box-drawing text, never ```` ```mermaid ```` blocks; terminals render Markdown but not Mermaid. Reserve Mermaid for content written to a destination that renders it (PR bodies, repository docs, artifacts). Details in the `visualize-it` skill.
- **User session language**: Although skills, instructions, and documentation are authored in English, agents must always work and communicate with the user in the language the user is speaking in the current session. Keep technical terms in English whenever they are standard industry terminology or better explain the technical concept (e.g., *pull request*, *mock*, *refactor*, *code smell*, *runtime*, *bug*, *feature*), avoiding forced or awkward translations. The fixed words of a skill's output template (headings, labels, status values) are written in that language too; symbols, code, and identifiers stay as they are. Shared artifacts (pull requests, commits) follow the language of the project's existing ones, English when it has none (`pull-request`, `commit`).

---

## 2. Working principles

- **Safety and non-destructiveness**: preserve user data, never execute destructive commands without inspecting the target beforehand, and respect existing files.
- **Production access**: read-only unless the user authorizes that specific write. Before any command that reaches production, say which production systems and data it touches. Never write a credential to a file (pass it through the environment or an interactive prompt), and when done, tear down the proxies, tunnels, and port-forwards opened for the access.
- **Formatted links**: when citing files in Markdown, use links (e.g., `[README.md](README.md)`); cite every pull request, issue, and chat thread with its clickable link, never by its number alone.
- **No local references in shared artifacts**: commits, PRs, review comments, issues, and reports must never reference paths the reader cannot open (local machine paths, `docs/tickets/`, `docs/prd/`, files in `.gitignore`). Reference the linked issue or rephrase the information. Details in the `no-local-references` reference of the `ai-assisted-software-development` skill.

---

## 3. Development governance

Division of labor follows the `ai-assisted-software-development` skill: the human governs modules, boundaries, dependency direction, contracts, and behaviors (**Human Layer**), which the agent may decide inside a delivery for the human to ratify; the agent is responsible for everything below contracts (**Agent Layer**).

| Trigger | Mandatory action |
| :--- | :--- |
| Before deciding modules, boundaries, interfaces, contracts, or dependency direction | Load `software-designing`. |
| Before locking in a Human Layer design decision the project has no established way to settle | Run the arena of `software-designing`: two radically different sketches by subagents in the calling harness, the best one built. |
| Before presenting or building a design that holds a Human Layer decision | Run the adversarial review of `software-designing`: a fresh subagent on the harness's default model attacks the design, and its objections outweigh the session's. |
| Before starting a delivery (branch or worktree), splitting work, opening another session, tab, or subagent, or running anything in parallel | Load `agentic-parallel-work`. |
| **Before creating, editing, testing, or refactoring any code file** | **Load `coding`**, even for a small change. |
| **Before creating or changing any prompt** (system prompts, agent instructions, skills and their references, AGENTS.md, CLAUDE.md, rule and memory files, tool and skill descriptions, brief templates) | **Load `prompt-engineering`**, even for a one-word change. |
| **Before writing or editing documentation, a README, a pull request description, or a commit message** | **Load `technical-writing`**. |
| When the user corrects an agent for the same mistake a second time, or you catch yourself writing the same instruction a second time | Use `correct`: make the mistake impossible instead of adding text. |
| Before delivering code to the human | Run `agent-self-review` and fix findings until a clean verdict is reached. |
| When the human requests delivery review | Use `human-review`, strictly on the Human Layer. |
| Before any commit | Use `commit`. |
| Before opening a pull request | Use `pull-request`. |

### What I watch

Whatever the task, the user watches these. The first three change only as decisions the user ratifies at delivery, never unseen; the last three are never traded. Every delivery's change card (`change-card` reference of the `ai-assisted-software-development` skill) shows the first five, its State line shows whether the user has authorized the release, and the independent reviewer of `provide-evidence` checks them in line (c) of its evidence dossier:

- **Everything new is visible, with where it lives**: tables, jobs, routes, services, secrets, costs, folders, clients.
- **Nothing built on the side**: each new thing follows the project's existing way of doing it.
- **No wall knocked down unseen**: a change to boundaries, contracts, or dependency direction is a decision the user ratifies.
- **Rules and tests not weakened**: no project rule bypassed, no test disabled, skipped, or loosened.
- **Proof of the real version**: the evidence is for the exact commit being delivered.
- **Release only with the user's authorization**: no merge, deploy, or publication without it.

---

## 4. Subagents and delegation

- Parallel work follows the `agentic-parallel-work` skill: one writer per delivery, no conversation between agents, and a subagent answers once and ends.
- When a workflow requires background execution or isolated context, use the current harness's subagent mechanism:
  - **Claude Code**: `Agent` tool with `general-purpose` type.
  - **Antigravity CLI**: `invoke_subagent` with `TypeName: "self"` or a specific type.
  - **Codex**: sub-process or isolated thread.
- Pass context and requirements **verbatim** (*ipsis litteris*), without loss of fidelity.
- Skill paths cited in a brief must use **absolute paths**: the subagent runs in the project directory, not the skills directory. Details in the `subagent-delegation` reference of the `ai-assisted-software-development` skill.
