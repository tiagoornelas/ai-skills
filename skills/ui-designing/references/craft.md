# Craft

> **Central thesis**: work as the design lead of a studio known for giving every client an identity nobody mistakes for anyone else's. Make deliberate, opinionated choices of palette, typography, and layout that are specific to this brief, and take aesthetic risk where the brief leaves room. Where a design system is kept, it is the brief: be distinctive inside it, never against it.

---

## When to consult

- Before any visual or copy choice: a direction, a palette, a type scale, a layout, motion, or interface text.

---

## 1. Ground the Design in the Subject

If the brief does not say what the product is, propose one concrete subject, its audience, and the screen's primary job, and confirm them with the user. The subject's industry, materials, and vernacular are where distinctive choices come from: a toy for girls aged 8–11 and a dashboard for financial analysts look nothing alike. Build with the brief's real content throughout.

## 2. Principles

- **Open with the subject.** The first thing a viewer sees (the hero of a page, the first view of a screen) shows the most characteristic thing in the subject's world, in its fittest form: a headline, an image, a live demo, the data itself. A big number with a small label, supporting stats, and a gradient accent is the default treatment; use it only when it is truly the best option.
- **Typography carries the personality.** One family or two, and if two, clearly distinct. Choose them deliberately, not the families you would reach for on any project, and set a clear type scale following *The Elements of Typographic Style*, with intentional weights, widths, and spacing. A headline's type treatment is part of the design, not a neutral vehicle.
- **Line length** under 80 characters; serif body text may run slightly longer and gets slightly more line-height than sans-serif.
- **Avoid the commonest typographic tells**: accenting one word of a headline (italic, bold, or another color), all-caps labels, and labels added above content that needs none.
- **Visual structure is information.** Outlines, borders, numbering, eyebrows, dividers, and labels encode something about the content. Numbered markers (01 / 02 / 03) fit only content that really is a sequence.
- **Motion**: motion nobody triggered draws attention, so use it sparingly; one orchestrated moment lands better than effects scattered everywhere. Fade-and-slide entrances on every section and hover effects on every card read as generated. Motion that answers a person's action (opening, expanding, confirming) is welcome when it shows what changed.
- **Product screens** (forms, tables, dashboards, settings) spend their boldness on identity (palette, type, one signature element) and keep layout, density, and interaction predictable: the user returns to them every day.

## 3. Plan, Review, Build, Critique

AI-generated design currently clusters around these traits:

1. a warm cream background (near `#F4F1EA`) with a high-contrast serif display and a terracotta or clay accent (near `#D97757`);
2. a near-black background with one bright acid-green or vermilion accent;
3. a broadsheet layout with hairline rules, zero border-radius, and dense newspaper columns;
4. the SaaS card kit: content chopped into identical rounded cards, one radius on everything regardless of hierarchy, the same soft grey shadow (`rgba(0,0,0,.1)`) under each, and gradient washes as decoration;
5. template chrome that appears whatever the subject: a tracked-out all-caps eyebrow above every heading, meta strings joined with middle dots (`A · B · C`), labels built as `WORD — fragment`, tinted near-black (`#0B0B0B`, `#111`) standing in for black, a monospace face for small data labels, and `→` appended to links and buttons.

Each is legitimate for some brief, but they are defaults, not choices. Where the brief or the design system pins down a direction, follow it exactly, even when it asks for one of these looks. Where it leaves an axis free, do not spend that freedom on a default.

Work in two passes:

1. **Plan** a compact token system:
   - **Color**: the base palette as 4–6 named hex values.
   - **Type**: the typefaces and their roles.
   - **Layout**: a concept in one-sentence descriptions and ASCII wireframes, including alignment.
   - **Principles**: what makes this design unique.
2. **Review the plan against the brief** before building: work through a similar prompt and see whether you land somewhere similar. Revise any part that reads as the default for any similar product, and say what changed and why. Write code only from the revised plan.

When writing CSS, watch selector specificity: selectors that cancel each other out (a descendant selector like `.section p` against a class like `.cta`) are a common source of broken padding and margins between sections.

## 4. Restraint and Self-Critique

- **Spend boldness in one place.** One memorable element; everything around it quiet and disciplined. Cut decoration that does not serve the brief. Before shipping, remove one accessory.
- **Hold the [quality floor](refactoring.md#2-audit) without announcing it.**
- **Critique as you build**: take screenshots and look at them; a picture is worth a thousand tokens.

## 5. Writing in the Interface

Words exist to make the interface easier to understand and use; they are design content, not decoration.

- **The user's vocabulary**: name things by what users understand, not by how the system is built: a user manages notifications, not webhook configuration. Describe what something does instead of selling it; specific beats clever.
- **Active voice**: a call to action says exactly what happens ("Save changes", not "Submit"). An action keeps its name through the whole flow: the "Publish" button produces a "Published" confirmation.
- **Failure and emptiness give direction**: say what went wrong and how to fix it, in the interface's voice; errors do not apologize and are never vague. An empty screen invites the next action.
- **Tone**: plain verbs, sentence case, no filler, matched to the brand and audience. Each written element does one job.
- **Language**: interface text is written in the product's language, and these rules apply in it.
