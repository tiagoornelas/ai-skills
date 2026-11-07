---
name: interface-designing
description: >-
  Designs what users see and do in an application, with deliberate choices
  instead of templated AI defaults: creates a product's design system (visual
  direction, tokens, component states, usage rules), moves a whole
  application onto one, or refactors a single screen, proving each change
  with before-and-after screenshots. Used on demand when the user asks to
  create a design system, redesign or refactor an interface or screen, or
  give an application a professional look.
disable-model-invocation: true
argument-hint: "[create a design system | refactor the system | refactor <screen>]"
---

# Interface Designing

Every color, typeface, spacing value, and word on a screen is a choice made for this product and its users, and the same choice is made the same way on every screen. [craft.md](references/craft.md) holds how to make those choices; this file holds the flows.

## 1. Choose the Mode

| The request | Mode | Delivers |
| :--- | :--- | :--- |
| A visual identity or design system for a product that has none, or replaces it | **Create** (Section 3) | A direction the user chose, built into the project and applied to one screen |
| The whole application brought onto a design system | **Refactor the system** (Section 4) | A plan of deliveries the user approved, run one by one |
| One screen or flow improved | **Refactor a screen** (Section 5) | The screen rebuilt, with before-and-after screenshots |

Refactoring the system without a design system starts with Create. For a screen in a project without one, ask whether to create one first or to work within the screen's current style; in the latter case, first gather the screen's existing values into local tokens, which then play the design system's role.

## 2. Ground Every Mode

Before any choice:

1. **Subject**: per [craft.md](references/craft.md#1-ground-the-design-in-the-subject).
2. **Existing design system**: read it wherever the project keeps it (CSS variables, Tailwind or theme configuration, shared components, design docs). It is the brief, and departing from it is the user's decision. When Create replaces it, it is instead evidence for the audit of what to keep and what fails.
3. **Stack and conventions**: how the project writes styles and components. Everything new follows them.
4. **Running the app**: how to start it, sign in, and reach each state of the screens involved (loading, empty, error); ask the user for credentials, seed data, or fixtures the project does not provide.

## 3. Create a Design System

1. Plan 2–3 radically different directions per [craft.md](references/craft.md#3-plan-review-build-critique).
2. Render them on one representative screen with the UI branch of [`prototype`](../prototype/SKILL.md), each variant with its own planned tokens instead of the project's. For product screens, variants differ in identity (palette, type, signature element) and share a predictable structure. The user picks one or a hybrid: that is the decision.
3. Build the chosen direction per [design-system.md](references/design-system.md), recording it in the usage rules, and apply it to the representative screen with [`coding`](../coding/SKILL.md) as a screen refactor (Section 5).

## 4. Refactor the System

1. Inventory the application and plan its deliveries per [refactoring.md](references/refactoring.md); the user approves the plan, including the contract changes it flags.
2. Run the deliveries one after another in this session, or in parallel only as [`agentic-parallel-work`](../agentic-parallel-work/SKILL.md) allows, each as a screen refactor. A delivery of shared components or tokens is proven on the screens that use them.

## 5. Refactor a Screen

1. Capture the "before" per [refactoring.md](references/refactoring.md#4-evidence).
2. Audit the screen per [refactoring.md](references/refactoring.md#2-audit).
3. Fix it with [`coding`](../coding/SKILL.md), using only the design system's tokens and components.
4. Capture the "after" and present each pair with the findings it closes.

A visual change within the approved design system is the agent's call; a change in what the screen does (its flow, an action's result, the meaning of its copy) is the user's.

## References

| Reference | Load when… |
| :--- | :--- |
| [craft.md](references/craft.md) | Making any visual or copy choice: direction, typography, color, layout, motion, writing, and the defaults to avoid. |
| [design-system.md](references/design-system.md) | Creating or extending a design system: token layers, component states, usage rules, and where they live. |
| [refactoring.md](references/refactoring.md) | Inventorying, auditing, planning, or proving the refactor of a screen or a whole application. |

---

## Success Validation

- [ ] The mode matched the request, and the subject, any existing design system, and how to run the app were established before the first choice.
- [ ] Every direction was planned, reviewed against the brief, and revised where generic before code; the user chose it.
- [ ] The design system lives where the project keeps it or where the user approved, with three token layers, component states, and usage rules; components hold no raw values.
- [ ] A system refactor ran as deliveries the user approved, and shared component contract changes went to the user.
- [ ] Every changed screen passed the audit and has before-and-after screenshots per [refactoring.md](references/refactoring.md#4-evidence).
