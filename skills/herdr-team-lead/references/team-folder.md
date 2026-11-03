# Team Folder

> **Central thesis**: in the Herdr App, a space is a team working on one cohesive piece of work. Its durable memory lives in one folder outside every repository, owned by the team itself. Skills may read it; none depends on it existing.

---

## 1. Location

```text
~/.herdr-teams/
└── <space-id>/                  one folder per Herdr App space (sp…)
    ├── leader.md                the Leader's intent document (Section 2)
    └── handoff-<agent>.md       member handoffs written by herdr-handoff
```

A team folder is a direct child that contains `leader.md` or a `handoff-*.md` file.

- The folder is keyed by the Herdr App space ID: the `herdr.space` label in `hc get "$HC_TERMINAL_ID"`, or `id` in `herdr-app ls`. The space name is recorded inside `leader.md`, so a reader can still match the folder by name if an ID ever changes.
- Folders named like `wAB` (no `sp` prefix) come from the Herdr terminal multiplexer, which these skills no longer drive. Treat them as legacy: readable history, matched to no live space.
- Create the folder on first write with `mkdir -p`. Never write credentials or secrets in it.
- Files here are the team's working memory, not repository artifacts: shared artifacts (commits, PRs, issues) never reference these paths.

---

## 2. `leader.md`

The Leader's handoff to itself: the format of the [`handoff`](../../handoff/SKILL.md) skill's **Document Content**, restricted to **intent**. It records what the team means to do and why; live status (agent states, PR mergeability, CI, reviews, task status) is never written here, because every reader can observe it directly and a written copy goes stale.

```markdown
# Team — <space name>

**Space:** <space name> (`<space-id>`)
**Leader:** <terminal name> (`<terminal address>`), <harness>
**State:** active | concluded <ISO date>
**Updated:** <ISO date-time> — <trigger that caused the update>

## Objective
<what the team delivers for the user, in 1–3 sentences>

## Tasks and Issues
- <tool> <key or URL> — <what it is>

## Members
| Agent | Harness | Mission | Repository / branch |
| :--- | :--- | :--- | :--- |

## Next Steps
1. <ordered intent, not progress reports>

## Pending Decisions
- ❓ <decision the user must make, in system terms>

## Decisions & Rationale
- <decision taken> — <rationale and rejected alternatives>

## Verified vs. Assumed
- ✅ <verified fact and method>
- ❓ <assumption to confirm>

## References
- <spec, PR, issue, ADR — by link, with its meaning>

## Recommended Skills
- `herdr-team-lead` — leading this team — `<absolute path to its SKILL.md>`
```

- Omit empty sections. Give every handle its meaning, as the `handoff` skill requires.
- **Tasks and Issues** holds references only; their status always comes from the tracking tool.
- `State: concluded` marks the work as finished; the folder stays until the user approves its removal.

---

## 3. Who Does What

| Actor | Reads | Writes |
| :--- | :--- | :--- |
| `herdr-team-lead` | `leader.md`, member handoffs | `leader.md` |
| `herdr-handoff` | `leader.md` (to find the Leader) | `leader.md` (creation or adoption), `handoff-<agent>.md` |
| `herdr-leader-report` | `leader.md`, member handoffs | Nothing |
| `git-cleanup` | `leader.md` `State`, space list (`herdr-app ls`) | Removes a team folder only with explicit user approval |

A missing folder or a partial `leader.md` is a valid state: readers fall back to what they can observe and never fail because of it.
