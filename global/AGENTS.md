# Global Instructions

> Working rules that apply to **any project**, for any agent (Claude Code, Codex, Antigravity CLI). Installed as global instructions by `setup-global.sh` from the **ai-skills** repository.
>
> The skills cited below are referenced **by name**: they are installed in the harness skills directory. The `AGENTS.md` of the project you are working on complements these rules and, in case of conflict, takes precedence.

---

## 1. How to report to the user

- **Response first, details later.**
- **Concise and visual**: prefer structure (bullet points, short tables, headings, code blocks) over long paragraphs.
- **Short, complete sentences**: do not sacrifice grammar or clarity for brevity.
- **Diagrams by destination**: in conversation output (terminal, chat), draw diagrams with Unicode box-drawing text, never ```` ```mermaid ```` blocks; terminals render Markdown but not Mermaid. Reserve Mermaid for content written to a destination that renders it (PR bodies, repository docs, artifacts). Details in the `visualize-it` skill.
- **User session language**: Although skills, instructions, and documentation are authored in English, agents must always work and communicate with the user in the language the user is speaking in the current session. Keep technical terms in English whenever they are standard industry terminology or better explain the technical concept (e.g., *pull request*, *mock*, *refactor*, *code smell*, *runtime*, *bug*, *feature*), avoiding forced or awkward translations.

---

## 2. Working principles

- **Safety and non-destructiveness**: preserve user data, never execute destructive commands without inspecting the target beforehand, and respect existing files.
- **Formatted links**: when citing files in Markdown, use links (e.g., `[README.md](README.md)`).
- **No local references in shared artifacts**: commits, PRs, review comments, issues, and reports must never reference paths the reader cannot open (local machine paths, `docs/tickets/`, `docs/prd/`, files in `.gitignore`). Reference the linked issue or rephrase the information. Details in the `no-local-references` reference of the `ai-assisted-software-development` skill.

---

## 3. Development governance

Division of labor follows the `ai-assisted-software-development` skill: the human governs modules, boundaries, dependency direction, contracts, and behaviors (**Human Layer**); the agent is responsible for everything below contracts (**Agent Layer**).

| Trigger | Mandatory action |
| :--- | :--- |
| Before deciding modules, boundaries, interfaces, contracts, or dependency direction | Load `software-designing`. |
| Before locking in a high-consequence design decision | Run through `design-it-twice`. |
| **Before creating, editing, testing, or refactoring any code file** | **Load `coding`**, even for a small change. |
| Before delivering code to the human | Run `agent-self-review` and fix findings until a clean verdict is reached. |
| When the human requests delivery review | Use `human-review`, strictly on the Human Layer. |
| Before any commit | Use `commit`. |

---

## 4. Subagents and delegation

- When a workflow requires background execution or isolated context, use the current harness's subagent mechanism:
  - **Claude Code**: `Agent` tool with `general-purpose` type.
  - **Antigravity CLI**: `invoke_subagent` with `TypeName: "self"` or a specific type.
  - **Codex**: sub-process or isolated thread.
- Pass context and requirements **verbatim** (*ipsis litteris*), without loss of fidelity.
- Skill paths cited in a brief must use **absolute paths**: the subagent runs in the project directory, not the skills directory. Details in the `subagent-delegation` reference of the `ai-assisted-software-development` skill.
