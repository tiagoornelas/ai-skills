---
name: visualize-it
description: >-
  Renders any aspect of a software project as a clear diagram or visual—module
  maps, dependency direction, interfaces, contracts, file trees, execution
  sequences, state machines, and before/after comparisons. Used natively by human-review and
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
| What does each component expose, and which methods changed? | **Interface Card**: one per component, separate from the map |
| Where does it live on disk, and does the layout reflect the architecture? | **File Tree**: pruned tree annotated with module IDs (only when structure changed or was asked about) |
| What happens, in what sequence, crossing which boundaries? | **Sequence Diagram** |
| What states can the system occupy and what triggers transitions? | **State Diagram** |
| What changed between planned architecture and executed code? | **Before / After Comparison** with modified elements highlighted |

**The map, the cards, and the file tree are separate views.** The map shows only who exists and where dependencies point; a module index connects friendly labels to exact code names, and cards show public interfaces and methods. Never move card detail into the map to "save a view": that detail is what makes maps unreadable.

---

## 2. Module Map Rules

1. **Friendly names**: label each component by the business concept it represents, in the reader's language (`Overdue reminders`, not `SendOverdueReminders`). Give each component a stable numeric ID and list its exact code name in a separate module index below the map. Reuse those IDs across views; identify cards by their code names.
2. **Component type symbols**, always accompanied by a legend:

   | Symbol | Type |
   | :---: | :--- |
   | `▶` | Entry point (route, job, CLI, consumer) |
   | `◆` | Business rule (domain, use case, policy) |
   | `◇` | Contract / port (interface the business rule owns) |
   | `■` | Infrastructure (database, provider, framework adapter) |

3. **Unlabeled arrows**: an arrow means only "depends on". No method names, payloads, or `implements` labels on arrows; the only allowed arrow label is a deviation note of at most five words.
4. **No implementation noise**: no file paths, stereotypes (`«UseCase»`), signatures, or generic types inside boxes. Paths belong to the file tree (Section 4).
5. **Highlight what changed** with the canonical change notation, written per destination (Section 5):

   | Meaning | Monospace diagram (terminal) | Rendered Markdown / Mermaid |
   | :--- | :---: | :---: |
   | New | `+` | 🆕 |
   | Modified | `~` | 🔧 |
   | Removed | `−` | 🗑️ |
   | Deviation or rule violation (e.g., arrow pointing away from business rules) | `!` | ⚠️ |

   No other badges are used in module maps. Emojis are two columns wide in terminals and break box alignment, so box-drawn diagrams use the one-column markers.
6. **Maximum of 7 primary boxes**: above this threshold, reduce detail or split into multi-tier diagrams.
7. **Group by responsibility**: place business rules and their owned contracts inside an explicit business-core boundary, with entry points and infrastructure outside. Use double-line borders for the terminal core and a Mermaid subgraph for the rendered core. Adapt groups to the actual architecture rather than inventing a domain layer; folders are not necessarily modules.
8. **Explain direction**: state that `A → B` means "A depends on B in code", not execution order. In the usual ports-and-adapters view, entry points point toward business rules and infrastructure adapters toward the contracts they implement. Position infrastructure below its contracts in terminal diagrams so those arrows point up.

Full terminal and Mermaid examples (shapes, styles, deviation edge): [`references/module-map.md`](references/module-map.md).

---

## 3. Interface Card Rules

For the requested view, show cards for **new or altered** public contracts and **unchanged guarantees material to understanding the change**. Do not catalog every used interface merely because it was called. Entry points and infrastructure adapters get a card only when they expose a new public interface.

- **Minimal content**: exact public interface name and relevant method signatures only. No friendly-name heading, counts, previous signatures, out-of-scope methods, notes, or contract prose inside cards.
- **Methods in scope**, in fixed order: 🔧 altered, 🆕 new, 🗑️ removed, 🔹 used without modification. Mark every method, including methods of a new interface. Removed methods retain their last signature.
- **Same content, destination-specific rendering**: a plain fenced `class InterfaceName { ... }` block in terminal/chat; a Mermaid `classDiagram` in PRs and other Mermaid-rendering destinations. Cards contain no relationship arrows; dependencies belong to the module map.
- **Contract decisions outside cards**: where design or review requires promises, hidden knowledge, or failure modes, explain them separately, keyed by interface/method. Do not append a mandatory detail layer to each card.

Full format and examples: [`references/interface-card.md`](references/interface-card.md).

---

## 4. File Tree Rules

The file tree is a **companion view**, never a replacement for the map and never drawn inside it. Show it only when it answers its own question: *where does this live on disk, and does the layout reflect the architecture?*

| Show when | Skip when |
| :--- | :--- |
| The change creates, moves, renames, or removes files or folders | The change only edits the content of existing files |
| The user asks about organization or layout | The module map already answers the question |
| A file's location breaks a boundary (e.g., infrastructure inside the domain folder) | The question concerns runtime behavior (use a sequence or state diagram) |

- **Prune**: show only the path down to what changed or matters, collapsing the rest as `… N files`. A full listing answers nothing.
- **Reuse module IDs**: annotate folders with the `[n]` IDs of the module index so the tree and the map read as one model.
- **Same change notation** as the map (Section 2, rule 5). Flag a misplaced file with `!` and a short note naming the broken boundary.
- **Faithful to disk**: preserve real nesting and order; do not regroup folders by responsibility.

Full format and examples: [`references/file-tree.md`](references/file-tree.md).

---

## 5. Output Formats

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
  - Interface cards use a plain fenced class-like block with emoji method markers. Unlike box-drawn maps, these blocks have no borders to align.
- **File trees** are plain text in every destination: a fenced block without a language tag, since Mermaid has no tree shape. Only the change markers differ (Section 2, rule 5).
- **Mermaid (```` ```mermaid ````)**:
  - Use only when the destination row above says so.
  - Use `graph TD` or `graph LR` with responsibility subgraphs for module maps, `classDiagram` for interface cards, and `sequenceDiagram` for execution flows.
  - Encode the component type as node shape and style as well as symbol (see [`references/module-map.md`](references/module-map.md)).

See the grouped map and module index in [`references/module-map.md`](references/module-map.md).

> **Golden Rule**: Accompany module maps with a concise paragraph explaining what the reader should specifically observe (e.g.: inverted dependency arrow, respected boundary, or newly introduced contract).

---

## 6. Success Validation

- [ ] Each diagram answers a single question and can be grasped at a glance.
- [ ] The module map uses friendly names, type symbols, and unlabeled arrows, with responsibility groups, stable IDs, a code-name index, and a legend covering every symbol and marker used.
- [ ] No file paths, signatures, stereotypes, or method names appear on the map; they live on interface cards.
- [ ] Map change notation matches the destination; interface methods use 🔧 🆕 🗑️ 🔹 in both destinations.
- [ ] Contracts relevant to the requested view have minimal class-style cards with their code names and marked methods in scope, in canonical order; unrelated used interfaces are omitted.
- [ ] Required contract decisions are explained outside cards, linked to the relevant interface/method.
- [ ] The map respects the 7-box limit per view.
- [ ] A file tree appears only when structure changed, was asked about, or a location breaks a boundary; it is pruned, keeps real disk nesting, reuses module IDs, and stays outside the map.
- [ ] Module maps explain dependency direction; interface cards share a concise marker legend without per-card explanatory prose.
- [ ] Format matches the destination: no ```` ```mermaid ```` block in a conversation reply.
