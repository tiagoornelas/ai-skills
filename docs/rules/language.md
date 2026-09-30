# Language Standard

> Language governance for all content, documentation, code, and agent interactions in this repository.

---

## 1. Primary Language: English

All permanent project assets must be authored strictly in **English**:

- **Repository documentation**: [`README.md`](../../README.md), [`AGENTS.md`](../../AGENTS.md), architecture records, specifications, and rule files.
- **Skills and instructions**: YAML frontmatter (`name`, `description`, `argument-hint`), instruction files (`SKILL.md`), references (`references/`), and validation checklists.
- **Code and scripts**: automation scripts ([`scripts/`](../../scripts/)), shell utilities, variables, functions, and code comments.
- **Git artifacts**: commit messages, branch names, and pull request titles and descriptions.

Using English guarantees consistency, clarity, and portability across international harnesses, tools, and developer communities.

---

## 2. Exception: User Session Interaction

The only exception to the English rule is live communication with the user:

- **Session Language**: Agents must always converse and interact with the user in the language the user speaks during the active session (e.g., Portuguese, Spanish, French, English).
- **Technical Terminology**: Keep standard industry technical terms in English (e.g., *pull request*, *mock*, *refactor*, *code smell*, *runtime*, *bug*, *feature*), avoiding forced or awkward translations.
- **Artifacts vs. Conversation**:
  - Live conversation messages and explanations: rendered in the user's active session language.
  - Permanent codebase assets, files, and git commits: authored in English, regardless of session language.
