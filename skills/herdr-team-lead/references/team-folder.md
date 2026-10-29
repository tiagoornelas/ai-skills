# Team Folder

> **Central thesis**: in Herdr, a workspace is a team working on one cohesive piece of work. Its durable memory lives in one folder outside every repository, owned by the team itself. Other skills may read it; none depends on it existing.

---

## 1. Location

```text
~/.herdr-teams/
├── <workspace-id>/              one folder per Herdr workspace
│   ├── leader.md                the Leader's intent document (Section 2)
│   └── handoff-<agent>.md       member handoffs written by herdr-handoff
└── <other>/                     owned by other tools; team skills leave it alone
```

A team folder is a direct child that contains `leader.md` or a `handoff-*.md` file. Anything else under `~/.herdr-teams/` belongs to another tool.

- The folder is keyed by the Herdr workspace ID (`$HERDR_WORKSPACE_ID`, or `workspace_id` in `herdr workspace list`). The workspace label is recorded inside `leader.md`, so a reader can still match the folder by label if an ID ever changes.
- Create the folder on first write with `mkdir -p`. Never write credentials or secrets in it.
- Files here are the team's working memory, not repository artifacts: shared artifacts (commits, PRs, issues) never reference these paths.

---

## 2. `leader.md`

The Leader's handoff to itself: the format of the [`handoff`](../../handoff/SKILL.md) skill's **Document Content**, restricted to **intent**. It records what the team means to do and why; live status (agent states, PR mergeability, CI, reviews, task status) is never written here, because every reader can observe it directly and a written copy goes stale.

```markdown
# Team — <workspace label>

**Workspace:** <workspace label> (`<workspace-id>`)
**Leader:** <agent name> (`<pane-id>`), <harness>
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
| Any other reader | Everything | Nothing in team folders |
| `git-cleanup` | `leader.md` `State`, workspace list | Removes a team folder only with explicit user approval |

A missing folder or a partial `leader.md` is a valid state: readers fall back to what they can observe and never fail because of it.
