# Refactoring an Interface

> **Central thesis**: a refactor starts from evidence, not taste: what the interface does today, measured in the code and seen in the browser, compared against the design system and a quality floor, and fixed one screen at a time with screenshots proving each change.

---

## When to consult

- Inventorying an application, auditing a screen, or planning a refactor across screens.

---

## 1. Inventory (Whole Application)

Measure, in the project's style and component files:

- **Raw values outside the tokens**: hex and rgb colors, pixel sizes, font declarations, and inline styles; count the distinct values of each (twelve greys means no scale).
- **Duplicated components**: several buttons, modals, or inputs doing the same job with different code or looks.
- **Divergent patterns**: the same task (a form, a list with filters, a confirmation) solved differently on different screens.
- **Screens and flows**: the list, with how often users reach each one when the project's analytics or the user can tell.

Report each with counts and two or three representative locations.

## 2. Audit (One Screen)

Check the screen in the browser and its code against:

- **The design system**: only its tokens and components; no raw values.
- **The craft**: the defaults in [craft.md](craft.md#3-plan-review-build-critique), hierarchy (the primary action is unmistakable), and interface text ([craft.md](craft.md#5-writing-in-the-interface)).
- **The quality floor**:
  - contrast per [design-system.md](design-system.md#2-tokens-in-three-layers);
  - every control reachable and operable by keyboard, with visible focus;
  - touch targets of at least 44×44px on touch screens;
  - no horizontal scroll down to 320px wide, and zoom never disabled;
  - labels visible on every field, with each error shown beside its field;
  - loading, empty, and error states designed;
  - reduced motion respected.

Write each finding as what the user experiences ("the save button disappears on narrow phones"), with its location and severity: 🔴 blocks a task or fails accessibility, 🟡 departs from the design system or confuses, 🟢 polish.

## 3. Plan (Whole Application)

- **Order**: shared components and tokens first, since every screen reuses them; then screens by how many users reach them and how much they diverge.
- **One delivery per screen or flow**, verifiable on its own, with the findings it closes.
- **Contracts flagged**: any change to a shared component's props or behavior that other screens rely on is marked as a decision to ratify.

The plan goes to the user as a short ordered list, one line per delivery: the screen, what changes for its users, and its size.

## 4. Evidence

The proof of a refactored screen is before-and-after screenshots in the same states (default, loading, empty, error), viewports (the project's breakpoints, at least mobile and desktop), and themes, captured with [`browser-test`](../../browser-test/SKILL.md): the "before" on the base commit, the "after" on the delivered one. Store them as [`provide-evidence`](../../provide-evidence/SKILL.md)'s visual proof prescribes, one folder per screen with an index that pairs each "before" with its "after" and the findings it closes.
