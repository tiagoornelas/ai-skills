---
name: visualize-it
description: >-
  Draws how a part of a software system works, for a reader who knows the
  product but not the code: swimlanes (one column per place of the system,
  time flowing down, arrows for who calls whom, numbered steps, labels in
  product terms, marks only on detours) and, when the part has states a user
  sees, a states view. Box-drawing text in conversation; Mermaid only where it
  renders. Used by the review, design, and explanation skills, and directly
  invokable when the user asks how a flow, feature, or module works. What a
  change adds and where it lives is the change card's job, not a diagram.
---

# Visualize It

One drawing answers **how does this work?**: who does what, in which order, crossing which places of the system, and where the flow stops or detours. What a change adds and where it lives belongs to the [change card](../ai-assisted-software-development/references/change-card.md).

---

## 1. Swimlanes (Default)

- **Columns are places of the system**, left to right in the order the flow first reaches them: the person acting, then the screen, the backend, the database, a job, an external service, an agent. Name each in product terms the reader recognizes (`WEB APP`, `BILLING API`), at most six columns; a longer flow splits into two drawings.
- **Time flows down.** Each arrow is one call or message, from the caller's column to the callee's, labeled with what it does in product terms ("asks for the PDF", "saves the export").
- **Numbered steps** on the left mark the moments the reader would name (clicks Export, the PDF is rendered, the download); arrows inside a step are not numbered.
- **Notes beside a column** say what that place does or holds at that moment ("pending", `"preparing…"`).
- **Marks only on detours**: `■` where the flow stops (an error the user sees, a refusal), `▲` where it retries, waits, or runs only under a flag. Where the destination colors text, `■` lines are red and `▲` lines yellow; nothing else is colored or marked.
- **The user's language**: column names, arrow labels, and notes are in the user's session language; only the marks stay as they are.
- **No technical names**: no method, class, file, endpoint path, or table name. When the user asks where an arrow lives, answer for that arrow, keyed by its step number, beside the drawing.

A fictional flow, a user exporting an invoice as PDF:

```text
 USER           WEB APP                 BILLING API           DATABASE          PDF JOB
   │              │                       │                     │                 │
1  │              │ ▲ only if flag is on  │                     │                 │
   │── Export ───▶│                       │                     │                 │
   │              │── asks for the PDF ──▶│                     │                 │
   │              │◀─ ■ unpaid: refused ──│                     │                 │
   │              │                       │── saves the export ▶│ pending         │
   │              │◀─ accepted ───────────│                     │                 │
   │              │ "preparing…"          │                     │                 │
   │              │                       │                     │                 │
2  │              │                       │── render the PDF ────────────────────▶│
   │              │                       │                     │                 │ ▲ fails: 3 tries
   │              │                       │                     │◀─ stores it ────│
   │              │                       │                     │ ready           │
   │              │                       │                     │                 │
3  │              │── ▲ asks every 5 s ──▶│                     │                 │
   │              │◀─ link to the PDF ────│                     │                 │
   │◀─ download ──│                       │                     │                 │
```

## 2. States (Only for User-Visible States)

Add a states view when the part has states a user sees and rules of the kind "while it is like this, that happens": brackets name each state as the user sees it, arrows carry what moves it to the next one, `■` marks a state the flow ends in and `▲` one it waits or retries from.

```text
             clicks Export             PDF stored
  [no PDF] ─────────────▶ [preparing] ────────────▶ [ready to download]
                               │
                               ├─ fails 3 times ──▶ [failed] ▲ ─ "Try again" ─▶ [preparing]
                               └─ unpaid invoice ─▶ [refused] ■
```

## 3. Output by Destination

| Destination | Format |
| :--- | :--- |
| Conversation (terminal, CLI, chat pane), or unknown | Box-drawing text in a fenced block without a language tag, so alignment survives. Terminals and chat panes render Markdown but never Mermaid. |
| A destination that renders Mermaid (PR or issue body, repository docs, an artifact) | Mermaid in the same shape: `sequenceDiagram` for swimlanes, `stateDiagram-v2` for states, with color only on detours; see [mermaid.md](references/mermaid.md). |

- Emojis are two columns wide in terminals and break the columns: inside a drawing, use only the marks above. `■` and `▲` are ambiguous-width characters: most terminals draw them one column wide, but some East Asian settings draw two, shifting the columns to their right by one.
- Under the drawing, at most two sentences on what the reader should notice (where it stops, what depends on the flag).

## 4. Success Validation

- [ ] The drawing answered how the part works, as swimlanes, plus a states view only when the part has states a user sees.
- [ ] Columns were places of the system in product terms, time flowed down, each arrow named a call in product terms, the reader's moments were numbered, and every word was in the user's session language.
- [ ] Only detours carried marks or color: `■` for stops, `▲` for retries, waits, or flags.
- [ ] No method, class, file, endpoint, or table name appeared, except beside the drawing, keyed by step, when the user asked where an arrow lives.
- [ ] Box-drawing text in conversation; Mermaid only for a destination that renders it, in the same shape.
