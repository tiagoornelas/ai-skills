# AGENTS.md

> Rules for maintaining the **ai-skills** repository (Central Hub for Multi-Harness Skills and Rules).
>
> Working rules that apply to any project (how to report, principles, development governance, and subagents) are located in [`global/AGENTS.md`](global/AGENTS.md). They also apply here: follow both.

---

## 1. Repository Identity and Purpose

This repository centralizes:
1. **Reusable skills ([`skills/`](skills/))**: on-demand procedures in universal format (`SKILL.md`), consumed by Claude Code, Antigravity CLI, and Codex.
2. **Global instructions ([`global/AGENTS.md`](global/AGENTS.md))**: working rules installed as global instructions across all three harnesses.
3. **Automation scripts ([`scripts/`](scripts/))**: link skills and global instructions to local environments via symlinks.

---

## 2. Maintenance Principles

- **Single Source of Truth (SSOT)**: each rule lives in exactly one place. Working rules live in [`global/AGENTS.md`](global/AGENTS.md); rules shared across skills live in a skill reference and are linked via relative paths (e.g., `../ai-assisted-software-development/references/`). Harness-specific files (`CLAUDE.md`, `GEMINI.md`) point to the primary file via symlinks.
- **Harness Agnosticism**: instructions and skills are portable, avoiding hard dependencies on a single engine when direct equivalents exist (e.g., subagent tooling).
- **Self-contained Skills**: a skill never depends on this `AGENTS.md` nor on repository paths (`skills/...`); when installed globally, it runs in another project's directory. Links between skills are relative to the skills folder (`../<skill>/`).
- **Global instructions reference skills by name**, not by path: the file is installed in different locations across harnesses.

---

## 3. Skill Authoring Standard (`skills/`)

When creating or updating skills in this repository:

### 3.1. Directory Structure
```text
skills/<skill-name>/
├── SKILL.md            # [Required] Main instructions with YAML frontmatter
├── scripts/            # [Optional] Executable utility scripts
├── references/         # [Optional] In-depth documentation loaded on demand
└── resources/          # [Optional] Templates, data, and static assets
```

### 3.2. Frontmatter in `SKILL.md`

Required fields:
```yaml
---
name: skill-name
description: >-
  Third-person description explaining what the skill does and exactly when
  the agent should trigger it.
---
```

Optional fields recognized by harnesses (use when applicable):
- `argument-hint: "[hint]"`: visual hint for the expected argument when invoking the skill (e.g., `"[PR number/URL]"`).
- `disable-model-invocation: true`: indicates the skill is restricted to manual user invocation via chat/command, preventing autonomous invocation by the model.

### 3.3. Best Practices for Skills
- **Authored in English by Default**: Skills, YAML frontmatter descriptions, instructions, references, and validation checklists are authored in English by default. Technical terms follow standard industry terminology.
- **Progressive Disclosure**: keep `SKILL.md` concise, focusing on essential decisions and workflow steps. Delegate extensive reference material to files in `references/`.
- **Standardized Naming**: use `kebab-case` for folder and skill names (e.g., `code-review`, `deploy-helper`).
- **Clean Directories**: do not create empty `references/` or `scripts/` directories without actual files.
- **Success Validation**: every skill must end with a checklist section guiding the agent on how to verify that steps were executed successfully.
- **After adding or removing a skill**, run `./scripts/setup-global.sh`.
