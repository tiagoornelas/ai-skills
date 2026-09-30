---
name: visualize-it
description: >-
  Renders any aspect of a software project as a clear diagram or visual—module
  maps, dependency direction, interfaces, contracts, execution sequences, state
  machines, and before/after comparisons. Used natively by human-review and
  directly invokable.
---

# Visualize It

Core structural visualization and diagramming skill for the ecosystem.

---

## 1. Core Principle

Every visual diagram must answer **a single question with undeniable clarity**. A diagram attempting to illustrate everything communicates nothing.

| Question to Answer | Recommended Format |
| :--- | :--- |
| What are the components and where do dependencies point? | **Module Map**: directed graph (`A → B` = "A depends on B") |
| What does this module or interface guarantee? | **Interface Card**: signature, contracts, and failure modes |
| What happens, in what sequence, crossing which boundaries? | **Sequence Diagram** |
| What states can the system occupy and what triggers transitions? | **State Diagram** |
| What changed between planned architecture and executed code? | **Before / After Comparison** with modified elements highlighted |

---

## 2. Rules for Readable Diagrams

1. **One question per diagram**: Divide complex systems into high-level overviews and detailed zoom-ins.
2. **Diagram boundaries, not directory trees**: Folders are not necessarily modules. Group by architectural responsibility and lifecycle.
3. **Consistent arrow semantics**: Always explicitly declare the arrow convention (e.g.: `→` denotes "depends on").
4. **Highlight what changed**: In delivery reviews and comparisons, tag new components with `🆕`, modified with `🔧`, removed with `🗑️`, and deviations or rule violations (such as arrows pointing away from business rules) with `⚠️`. This is the canonical notation across maps; no other badges are used.
5. **Maximum of 7 primary boxes**: Above this threshold, reduce detail level or split into multi-tier diagrams.

---

## 3. Output Formats

Choose the format by **where the diagram will be read**, not by whether the destination renders Markdown. Terminals and chat panes render Markdown but **never render Mermaid**: a ```` ```mermaid ```` block there shows up as unreadable source code.

| Destination | Format |
| :--- | :--- |
| Conversation reply (terminal, CLI, chat pane) | **Terminal-native** |
| Preview in conversation of content that will be published elsewhere (PR draft, doc draft) | **Terminal-native** rendering of the diagram; the Mermaid source may follow, collapsed into the draft body |
| GitHub PR/issue body or comment, `.md` file in a repository, artifact or doc that renders Mermaid | **Mermaid** |
| Unknown destination | **Terminal-native** (readable everywhere) |

- **Terminal-native**:
  - Wrap the diagram in a plain fenced code block (no language tag) so alignment survives.
  - Use box-drawing characters (`┌ ┐ └ ┘ ─ │ ├ ┤ ┬ ┴ ┼`) and arrows (`→ ← ↔ ⇒ ▶`).
  - Keep lines ≤ 80 columns; wide diagrams wrap and break in narrow panes.
  - Markdown tables for interface cards and before/after comparisons.
- **Mermaid (```` ```mermaid ````)**:
  - Use only when the destination row above says so.
  - Use `graph TD` or `graph LR` for module maps, and `sequenceDiagram` for execution flows.

Terminal-native example (module map, `→` = "depends on"):

```
┌──────────────┐     ┌───────────────┐     ┌────────────────┐
│ 🆕 AuthCtrl  │ ──→ │  AuthService  │ ──→ │ UserRepository │
└──────────────┘     └───────────────┘     └────────────────┘
```

> **Golden Rule**: Always accompany diagrams with a concise paragraph explaining what the reader should specifically observe (e.g.: inverted dependency arrow, respected boundary, or newly introduced contract).

---

## 4. Success Validation

- [ ] Diagram answers a single question with clarity.
- [ ] Arrow direction convention is declared explicitly (e.g.: `→` means "depends on").
- [ ] Canonical notation applied: `🆕` new, `🔧` modified, `🗑️` removed, `⚠️` deviation or warning.
- [ ] Diagram respects the 7-box cognitive limit per layer/view.
- [ ] Diagram is accompanied by a concise explanatory paragraph.
- [ ] Format matches the destination: no ```` ```mermaid ```` block in a conversation reply.
