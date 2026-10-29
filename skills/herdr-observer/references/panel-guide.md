# Panel Guide

> **Central thesis**: the panel exists so the user understands the state of every team at a glance. It is written for them, in their language, about their goals; it is never a dump of fields. If a block would make the user stop and decode it, rewrite it or drop it.

---

## 1. Writing Rules

- **The user's session language, end to end.** Every heading, label, chip, and sentence is in the language the user speaks in the session, with standard technical terms in English (*pull request*, *merge*, *CI*). Never mix fixed English labels with content in another language.
- **System terms, not handles.** Apply [human-facing communication](../../ai-assisted-software-development/references/human-facing-communication.md): say what a PR, task, or agent is ("the PR that moves report downloads into the gateway"), with its number or key only as a link or in parentheses. Never show pane IDs, workspace IDs, file names such as `leader.md`, or raw values such as `unknown`, `declared`, or `MERGEABLE`.
- **Context like a newcomer needs it.** Write each team's objective and each PR's summary following the principles of [`explain-it`](../../explain-it/SKILL.md): business before code, define project-specific names on first use, say why when it is known. Put longer context in a collapsible "Context" block instead of the main view.
- **What matters to the user first.** Apply [`ai-assisted-software-development`](../../ai-assisted-software-development/SKILL.md): Human Layer items lead (decisions, contract or architecture changes, behaviors needing manual validation, scope concerns). Agent Layer details (test counts, commit lists, file names) stay out unless they block something.
- **Certainty is visible only when it is low.** Observed facts carry no marker. Inferred facts get the `inferred` style with a tooltip saying where they came from ("inferred from the terminal"). Never label every fact with its source.
- **Cold-read test.** Before writing the file, ask: would the user understand each block after two hours in another tab, without opening anything else? If not, rewrite.

---

## 2. Visual Language

Status is always an emoji plus a word in a chip (`<span class="chip ok">✅ ready to merge</span>`, written in the user's language), never color alone. Use one fixed vocabulary per panel:

| Signal | Emoji | Chip class | Typical words |
| :--- | :---: | :--- | :--- |
| Flowing, done, or verified | ✅ | `ok` | done, mergeable, CI green, reviewed |
| Working now | ⏳ | `info` | working, in review |
| Needs the user | ❓ | `warn` | decision for you, waiting for your review |
| Attention point | ⚠️ | `warn` | plan diverges, conflict, CI failing |
| Blocked or failed | ❌ | `bad` | blocked, CI failed |
| Idle or not started | ⚪ | `idle` | idle, not reviewed |

Team-level health uses 🟢 (flowing), 🟡 (waiting for the user or with attention points), 🔴 (blocked).

---

## 3. Layout

A single self-contained HTML file: copy [`../resources/panel.css`](../resources/panel.css) verbatim into a `<style>` element, add no external scripts, fonts, or images, and escape `<` and `&` in any text that came from PRs, tasks, or terminals.

```text
┌───────────────────────────────────────────────────────────────┐
│ Title (view name) · updated at · since last refresh · filter  │
├───────────────────────────────────────────────────────────────┤
│ Needs you now: one line per decision, block, review, merge    │
├────────────────────┬──────────────────────────────────────────┤
│ Teams              │ Focused team                             │
│  🟢 Team A          │  Objective in one sentence + Context     │
│     doing in 1 line │  Decisions for you                       │
│  🟡 Team B          │  Agents (Leader first): role + status    │
│ Other workspaces   │  Done | Now | Next                       │
│ ▸ Concluded        │  PR cards: what it changes, then checks  │
│                    │  Since last refresh (one line)           │
└────────────────────┴──────────────────────────────────────────┘
```

- **Needs you now** (`.attention`; `.attention calm` when empty, saying so in one sentence): every pending decision, blocked agent, PR waiting for the user's review, and PR ready to merge, across all teams, each naming its team. This block is what the user reads first.
- **Teams** (`.team-list`, `.team`): one entry per team with its health emoji, its name, one line on what it is doing now, and agent status chips. Workspaces without team activity go in a short "Other workspaces" list; concluded teams go in a closed `<details>`.
- **Focused team** (`.detail`): one per team, only the selected one visible. Objective and why it matters (`.why`), optional `.context`, decisions (`.decision`), agents (`.agent`, Leader first with `.leader`), then the Done / Now / Next columns (`.cols`, `.col`, `.card`).
- **PR cards** (`.card.pr`): first what the PR changes for whom (`.what`), with its number as a link; then one row of chips (`.checks`) for mergeability, CI, review by the agent (`agent-self-review` note), and review by the user (`human-review` note and its recommendation); then the task it belongs to.
- **Since last refresh** (`.since`): one short line per team at most; omit on the first run.

Selection needs only this script, placed at the end of `<body>`; each `.team` carries `data-team="<id>"` and each `.detail` carries `id="team-<id>"`:

```html
<script>
  const KEY = "herdr-observer:<view name>";
  const pick = id => {
    document.querySelectorAll(".team, .detail").forEach(el => el.classList.remove("selected"));
    document.querySelector(`.team[data-team="${id}"]`)?.classList.add("selected");
    document.getElementById("team-" + id)?.classList.add("selected");
    try { localStorage.setItem(KEY, id); } catch (e) {}
  };
  document.querySelectorAll(".team").forEach(el => el.onclick = () => pick(el.dataset.team));
  let saved = null; try { saved = localStorage.getItem(KEY); } catch (e) {}
  pick(document.getElementById("team-" + saved) ? saved : document.querySelector(".team")?.dataset.team);
</script>
```
