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

Every visual diagram must answer **a single question with undeniable clarity**. A diagram attempting to illustrate everything communicates nothing: a reader should grasp it at a glance, without research.

| Question to Answer | Recommended Format |
| :--- | :--- |
| What are the components and where do dependencies point? | **Module Map**: directed graph (`A → B` = "A depends on B") |
| What does each component expose, what changed, and what does it guarantee? | **Interface Card**: one per component, separate from the map |
| What happens, in what sequence, crossing which boundaries? | **Sequence Diagram** |
| What states can the system occupy and what triggers transitions? | **State Diagram** |
| What changed between planned architecture and executed code? | **Before / After Comparison** with modified elements highlighted |

**The map and the cards are separate views.** The map shows only who exists and where dependencies point; the cards hold names in code, methods, and contracts. Never move card detail into the map to "save a view": that detail is what makes maps unreadable.

---

## 2. Module Map Rules

1. **Friendly names**: label each component by the business concept it represents, in the reader's language (`Overdue reminders`, not `SendOverdueReminders`). Exact code names appear only on interface cards.
2. **Component type symbols**, always accompanied by a legend:

   | Symbol | Type |
   | :---: | :--- |
   | `▶` | Entry point (route, job, CLI, consumer) |
   | `◆` | Business rule (domain, use case, policy) |
   | `◇` | Contract / port (interface the business rule owns) |
   | `■` | Infrastructure (database, provider, framework adapter) |

3. **Unlabeled arrows**: an arrow means only "depends on". No method names, payloads, or `implements` labels on arrows; the only allowed arrow label is a deviation note of at most five words.
4. **No implementation noise**: no file paths, stereotypes (`«UseCase»`), signatures, or generic types inside boxes.
5. **Highlight what changed** with the canonical change notation, written per destination (Section 4):

   | Meaning | Monospace diagram (terminal) | Rendered Markdown / Mermaid |
   | :--- | :---: | :---: |
   | New | `+` | 🆕 |
   | Modified | `~` | 🔧 |
   | Removed | `−` | 🗑️ |
   | Deviation or rule violation (e.g., arrow pointing away from business rules) | `!` | ⚠️ |

   No other badges are used. Emojis are two columns wide in terminals and break box alignment, so box-drawn diagrams use the one-column markers.
6. **Maximum of 7 primary boxes**: above this threshold, reduce detail or split into multi-tier diagrams.
7. **Diagram boundaries, not directory trees**: group by architectural responsibility and lifecycle; folders are not necessarily modules.

Full terminal and Mermaid examples (shapes, styles, deviation edge): [`references/module-map.md`](references/module-map.md).

---

## 3. Interface Card Rules

One card per component whose public interface is **new or altered**, or **unchanged but used by the change**. Entry points and infrastructure adapters get a card only when they expose a new public interface.

- **Header**: type symbol, friendly name, change badge; then the code name and the interface size: `` `InvoiceRepository` · 12 methods · 3 in scope ``.
- **Methods in scope**, in fixed order: altered (with its previous signature), new, removed, then used by the change without modification. A new component lists its methods without per-method badges; the header badge already says everything is new.
- **Methods out of scope**: name them when there are **at most 3**; above that, show only the count (collapsed in a `<details>` block where HTML renders).
- **Contract layer** (promise, hidden knowledge, failure modes): mandatory in design work (`software-designing`, `design-it-twice`); in reviews and pull requests, add it only to new or altered contracts whose guarantees or failure modes changed.

Full format, terminal and GitHub variants, and the contract layer: [`references/interface-card.md`](references/interface-card.md).

---

## 4. Output Formats

Choose the format by **where the diagram will be read**, not by whether the destination renders Markdown. Terminals and chat panes render Markdown but **never render Mermaid**: a ```` ```mermaid ```` block there shows up as unreadable source code.

| Destination | Format |
| :--- | :--- |
| Conversation reply (terminal, CLI, chat pane) | **Terminal-native** |
| Preview in conversation of content that will be published elsewhere (PR draft, doc draft) | **Terminal-native** rendering of the diagram; the Mermaid source may follow, collapsed into the draft body |
| GitHub PR/issue body or comment, `.md` file in a repository, artifact or doc that renders Mermaid | **Mermaid** |
| Unknown destination | **Terminal-native** (readable everywhere) |

- **Terminal-native**:
  - Wrap diagrams in a plain fenced code block (no language tag) so alignment survives.
  - Use box-drawing characters (`┌ ┐ └ ┘ ─ │ ├ ┤ ┬ ┴ ┼`), arrows (`→ ← ↑ ↓ ▲ ▼`), and the one-column change markers.
  - Keep lines ≤ 80 columns; wide diagrams wrap and break in narrow panes.
  - Interface cards are plain Markdown (headings, lists, inline code), never boxes or tables.
- **Mermaid (```` ```mermaid ````)**:
  - Use only when the destination row above says so.
  - Use `graph TD` or `graph LR` for module maps, and `sequenceDiagram` for execution flows.
  - Encode the component type as node shape and style as well as symbol (see [`references/module-map.md`](references/module-map.md)).

Terminal-native example (module map):

```
▶ entry   ◆ business rule   ◇ contract   ■ infra   → depends on
+ new   ~ modified

┌──────────────┐     ┌─────────────────┐     ┌──────────────┐
│ ▶ Login    + │ ──→ │ ◆ Sign-in     ~ │ ──→ │ ◇ Users      │
└──────────────┘     └─────────────────┘     └──────▲───────┘
                                                    │
                                             ┌──────┴───────┐
                                             │ ■ Postgres   │
                                             └──────────────┘
```

> **Golden Rule**: Always accompany diagrams with a concise paragraph explaining what the reader should specifically observe (e.g.: inverted dependency arrow, respected boundary, or newly introduced contract).

---

## 5. Success Validation

- [ ] Each diagram answers a single question and can be grasped at a glance.
- [ ] The module map uses friendly names, type symbols, and unlabeled arrows, with a legend covering every symbol and marker used.
- [ ] No file paths, signatures, stereotypes, or method names appear on the map; they live on interface cards.
- [ ] Change notation matches the destination: `+ ~ − !` in box-drawn terminal diagrams, `🆕 🔧 🗑️ ⚠️` elsewhere.
- [ ] Every component with a new, altered, or used public interface has a card with interface size, methods in scope in canonical order, and out-of-scope methods named (≤ 3) or counted.
- [ ] The contract layer is present where Section 3 requires it.
- [ ] The map respects the 7-box limit per view.
- [ ] Every diagram is accompanied by a concise explanatory paragraph.
- [ ] Format matches the destination: no ```` ```mermaid ```` block in a conversation reply.
