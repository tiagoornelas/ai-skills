---
name: prototype
description: >-
  Builds a disposable prototype to answer a single design question that
  conversation cannot resolve: whether a business logic or state machine holds
  up (interactive standalone HTML demo, with logic encapsulated in a pure,
  reusable module) or what a user interface should look like (isolated HTML
  mockup, outside the project repository, featuring radically different design
  variants side by side). Triggered whenever the user wants to stress-test logic
  or explore UI directions prior to construction, or when an interview
  (grill-me) encounters a visual or behavioral fork.
argument-hint: "[the specific question the prototype must answer]"
---

# Prototype

A prototype is **disposable code designed to answer a single question**. The question comes first and dictates every structural decision: a prototype answering the wrong question is wasted effort, regardless of polish.

---

## 1. Choosing the Branch

Identify the question being investigated—from user intent, surrounding codebase context, or by asking:

| Question | Branch | Artifact |
| :--- | :--- | :--- |
| **"Does this business logic / state model hold up?"** | [`references/logic.md`](references/logic.md) | A single, self-contained, shareable HTML file featuring unconstrained action buttons and tabbed scenarios, driving the domain model through edge cases difficult to evaluate on paper, operable by non-technical stakeholders. |
| **"What should this interface look like?"** | [`references/ui.md`](references/ui.md) | A standalone HTML mockup, **outside the project repository**, faithful to the project's actual design system, displaying radically different visual variants side by side. Completely decoupled from the production app. |

The two branches produce fundamentally different deliverables: choosing the wrong one invalidates the exercise. If the inquiry is ambiguous and the user is unavailable, select the branch matching surrounding code (backend module → logic; view/page component → UI) and declare the assumption explicitly at the top of the artifact.

If the inquiry is too broad for a single session ("What should the whole app look like?"), it is not a prototype: narrow it down to a single question.

---

## 2. Universal Rules for Both Branches

1. **Disposable by design, and marked as such.** Logic demos reside alongside the module they test, clearly named to indicate prototype status. UI mockups live **outside the project repository**: nothing touches version control, eliminating any risk of confusing it with production code.
2. **Effortless to run.** Both branches generate a single self-contained HTML file opened via double-click: zero installation commands, zero local dev servers.
3. **No persistence by default.** State lives purely in memory. Persistence is something a prototype *verifies*, not a prerequisite it depends on. If the question explicitly concerns database behavior, use an isolated scratch database or file clearly named `PROTOTYPE-delete`.
4. **No premature finish.** No automated test suites, no exhaustive error trapping beyond what is needed to execute, no speculative abstractions. The moment you harden a prototype (adding tests, wiring real databases, generalizing), you have stopped prototyping.
5. **Visible state.** After every action (logic) or side-by-side on screen (UI), render the complete relevant state so users directly observe mutations.
6. **Record findings upon conclusion.** The **answer** (the verdict and the question resolved) is recorded in the linked issue or commit message. The **prototype** meets its branch-specific fate: in logic, the validated pure module moves into production code and the HTML demo goes to a scratch branch; in UI, the winning variant is rebuilt from scratch in production and the mockup file is deleted.

---

## 3. Delivery and Iteration

Open the file for the user or provide the absolute path. The critical milestones are reactions like *"Wait, that shouldn't be permitted"* or *"Ah, I assumed X would behave differently"*: these uncover **conceptual flaws in the idea**, which is the sole purpose of the prototype. If the user requests new actions, scenarios, or variants, append them. Prototypes evolve rapidly.

When invoked by another skill (such as an interview in [`grill-me`](../grill-me/SKILL.md)), return the resolution to it in a single sentence.

---

## 4. Success Validation

- [ ] The question answered by the prototype fits in a single sentence and is prominently displayed at the top of the artifact.
- [ ] The selected branch corresponds accurately to the question (logic vs. appearance), or assumptions were declared.
- [ ] The deliverable is a single self-contained HTML file opening via double-click, featuring transparent visible state.
- [ ] UI mockups were created strictly outside the repository; logic demos are explicitly flagged as prototypes.
- [ ] The verdict was recorded, and the prototype followed its branch lifecycle: zero disposable code was merged into main branches.
