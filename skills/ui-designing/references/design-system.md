# Design System

> **Central thesis**: a design system is the set of decisions every screen reuses (tokens, component states, and usage rules), kept in one place in the project so that changing a decision changes it everywhere and a new screen cannot invent a value.

---

## When to consult

- Building the direction the user chose into a design system, or extending an existing one.

---

## 1. Where It Lives

Tokens and components go where the project already keeps styles and shared components, in its format (CSS variables, Tailwind theme, theme objects, design-token JSON). When the project has no such place, propose one that follows its stack's convention, plus the usage-rules document, and confirm both with the user before writing: a new folder or file format is a visible addition.

## 2. Tokens in Three Layers

| Layer | Holds | Example | Used by |
| :--- | :--- | :--- | :--- |
| **Primitive** | Raw values, named by what they are | `--blue-700: #1E3A8A` | Semantic tokens only |
| **Semantic** | Purposes, named by what they are for | `--color-primary: var(--blue-700)` | Components and screens |
| **Component** | One component's decisions, only where it departs from the semantic layer | `--button-bg: var(--color-primary)` | That component |

Components and screens never reference primitives or raw values: a theme or brand change then rewrites the semantic layer alone.

The minimum set:

- **Color**: each surface with its on-color (`primary` / `on-primary`, `surface` / `on-surface`), muted text, border, focus ring, and status colors (success, warning, danger, info), each defined for light and dark themes when the product has both.
- **Typography**: families, a type scale with sizes, line-heights, and weights per role (display, heading, body, label, code).
- **Spacing**: one scale (a 4px or 8px base) used for every padding, margin, and gap.
- **Shape and elevation**: radii by hierarchy (not one radius for everything), and the shadow or border levels.
- **Motion**: durations and easings, with a reduced-motion variant.
- **Breakpoints**: the widths where the layout changes.

Contrast: text against its surface meets WCAG AA (4.5:1, or 3:1 for large text), and borders and controls meet 3:1. Check every on-color pair in every theme.

## 3. Component States

Each shared component defines every state it can be in, styled from tokens: default, hover, focus-visible, active or pressed, disabled, loading, and, where it applies, selected, error, and empty. A state that is not designed gets improvised on every screen.

## 4. Usage Rules

One short document, beside the tokens, that a person or agent reads before building a screen:

- The direction in a few sentences: the subject, the principles, and the one signature element.
- When to use each component and its variants, with one do and one don't where confusion is likely.
- The interface voice ([craft.md](craft.md#5-writing-in-the-interface)), with the product's own terms.
