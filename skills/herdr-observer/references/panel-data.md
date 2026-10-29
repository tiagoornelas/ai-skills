# Panel Data (`state.json`)

The observer's only output contract: one JSON document per view, saved as `state.json` and embedded into the panel by `scripts/render.py`. The template in `resources/panel.html` is the only consumer. The previous `state.json` is also the input for "what changed" and for divergence deduplication.

## Provenance

Every fact that is not a raw Herdr field carries `source`:

| Value | Meaning |
| :--- | :--- |
| `observed` | Read directly from Herdr, git, git notes, `gh`, or the task tool. |
| `declared` | Read from `leader.md` or a member handoff. |
| `inferred` | Deduced from names, terminal output, or context. |

## Shape

```json
{
  "view": {
    "name": "todos",
    "filter": { "include": [], "exclude": [] },
    "updated": "2026-10-29T14:32:00-03:00",
    "previous": "2026-10-29T11:05:00-03:00"
  },
  "workspaces": [
    {
      "workspace_id": "wDB",
      "label": "Migração AI Features",
      "kind": "team",
      "state": "active",
      "objective": { "text": "...", "source": "declared" },
      "leader_md_updated": "2026-10-29T13:50:00-03:00",
      "agents": [
        {
          "name": "lead-migracao", "pane_id": "wDB:p1", "harness": "claude",
          "status": "idle", "role": "leader",
          "mission": { "text": "...", "source": "declared" },
          "repo": "ai-agents-gateway", "branch": "feat/x"
        }
      ],
      "tasks": [
        { "tool": "Jira", "key": "CJ-1412", "url": "...", "title": "...",
          "status": "Em andamento", "source": "observed" }
      ],
      "prs": [
        {
          "repo": "owner/ai-agents-gateway", "number": 142, "url": "...",
          "title": "...", "summary": "one sentence on what it changes",
          "state": "open", "mergeable": "yes", "ci": "pass",
          "agent_review": { "done": true, "date": "2026-10-29" },
          "human_review": { "done": false, "date": null, "recommendation": null },
          "tasks": ["CJ-1413"], "agent": "mig-resumo"
        }
      ],
      "next": [{ "text": "...", "source": "declared" }],
      "decisions": [{ "text": "...", "source": "declared" }],
      "divergences": [
        { "key": "pr:owner/repo#142:state", "text": "...", "declared": "...",
          "observed": "...", "notified_at": null }
      ],
      "changes": ["PR merged: ..."]
    }
  ]
}
```

## Field Rules

- `kind`: `team` when `leader.md` exists; `inferred` when it does not but some agent works on a non-default branch or has an open PR; `other` otherwise (shown in a compact section).
- `state`: `active`, or `concluded` when `leader.md` says so (shown collapsed).
- `status`: the Herdr `agent_status` value (`working`, `idle`, `blocked`, `done`, `unknown`).
- `role`: `leader` for the agent named in `leader.md`; without it, the agent in the first tab gets `leader` only with an inferred mission and `kind: inferred`.
- `state` of a PR: `open`, `draft`, `merged`, or `closed`. `mergeable`: `yes`, `conflict`, or `unknown`. `ci`: `pass`, `fail`, `pending`, or `none`.
- `agent_review.done`: a `self-review` git note exists on the PR head or on an ancestor after the merge-base. `human_review`: a `human-review` git note on the PR head; `recommendation` is its text.
- `divergences[].key` is stable across refreshes (it identifies what diverged, not the wording) so a divergence already notified keeps its `notified_at` and is not notified again.
- `changes`: short phrases comparing with the previous `state.json`; empty on the first run.
- Strings are plain text in the user's session language; the template escapes them.
