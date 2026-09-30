# Contributing

Thanks for considering a contribution. This repository is an opinionated, personal take on AI-assisted engineering, so the bar for a change is "fits the philosophy in the [README](README.md)", not only "works".

---

## Before You Start

- **Small fixes** (typos, broken links, script bugs): open a pull request directly.
- **New skills, or changes to how an existing skill decides things**: open an issue first and describe the problem it solves. It saves you from writing a skill that doesn't fit the catalog.
- **Changes to [`global/AGENTS.md`](global/AGENTS.md)**: always discuss in an issue first. That file is installed as the global instruction of every harness, so a change there reaches every project of every user.

---

## Workflow

1. Fork the repository and create a branch from `master`, named `<type>/<short-kebab-slug>` (for example, `feat/uninstall-script`, `fix/prune-dangling-links`).
2. Make your change, following the rules below.
3. Commit using [Conventional Commits](https://www.conventionalcommits.org/): `<type>(<scope>): <short description>`, in English, title only in most cases. The full convention is in the [`commit`](skills/commit/SKILL.md) skill.
4. Open a pull request against `master` describing what changed, why, and how you verified it.

---

## Rules That Apply to Every Change

These rules live in one place each; follow the links instead of relying on a summary.

| Topic | Where it is defined |
| :--- | :--- |
| Repository principles (single source of truth, harness agnosticism, self-contained skills) | [`AGENTS.md`](AGENTS.md), section 2 |
| Skill structure, frontmatter, and the mandatory Success Validation checklist | [`AGENTS.md`](AGENTS.md), section 3 |
| Language: permanent assets in English | [`docs/rules/language.md`](docs/rules/language.md) |

Two points that are easy to miss:

- **No local references.** Commits, pull requests, and skills never mention paths a reader cannot open, such as files on your machine or git-ignored folders.
- **Ported skills are credited.** If a skill comes from another repository, add a row to the Credits table in the [README](README.md) with the original link and what changed.

---

## Changing the Scripts

The scripts in [`scripts/`](scripts/) write to the user's home folder, so test them against a throwaway one:

```bash
export HOME="$(mktemp -d)"
./scripts/setup-global.sh --global-instructions
./scripts/uninstall-global.sh --dry-run
```

- **Keep them compatible with Bash 3.2**, the default on macOS: no associative arrays, `mapfile`, or `${var,,}`.
- **Never delete or overwrite what the user owns.** Existing content is moved to `~/.ai-skills-backup/` (see `safe_link` in [`scripts/lib/link.sh`](scripts/lib/link.sh)), and uninstall only removes links into this repository or identical copies of it.
- **Run [ShellCheck](https://www.shellcheck.net/)** on the scripts you touched.
- **Commit new scripts as executable** with LF line endings. On Windows, add them with `git add --chmod=+x <file>`.
- If you change where [`setup-global.sh`](scripts/setup-global.sh) installs something, update [`uninstall-global.sh`](scripts/uninstall-global.sh) to match.

---

## Adding or Removing a Skill

After adding or removing a skill folder, run `./scripts/setup-global.sh` so your local harnesses pick up the change.

---

## License

By contributing, you agree that your contributions are licensed under the repository's [CC BY-NC 4.0](LICENSE) license.
