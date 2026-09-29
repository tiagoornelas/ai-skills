# UI Prototypes

Generate **multiple radically different interface variations**, rendered side by side in a single disposable HTML file that faithfully replicates the project's visual design language. This is a mockup: never wired into the production application, with nothing committed to the repository.

If the inquiry concerns business logic, data models, or state transitions rather than visual layout, that is the wrong branch: use [`logic.md`](logic.md).

---

## 1. When This is the Right Form

- "What should this screen look like?"
- "I want to see a few visual directions for this dashboard before choosing."
- "Explore an alternative layout for the settings view."
- Whenever a user would otherwise spend days debating vague mental wireframes.

---

## 2. Why Standalone and Side-by-Side

Prototypes wired into live app routes (variant toggles, `?variant=` query parameters, temporary test views) leave debris in the project that must be found and removed later—a cleanup process that is notoriously error-prone. A standalone HTML file completely outside the repository eliminates this risk: nothing is created in the codebase, leaving zero mess to clean up. Furthermore, side-by-side layout beats cycling variants one at a time: comparing designs should take a single glance, not repeated clicking.

---

## 3. Process

### 3.1. Declare the Question and Set N
Default: **3 variants**. Beyond 5, variations stop being radically different and degenerate into noise; 5 is the hard ceiling.

State the brief in one line prior to drafting:

> "Three variants of the user settings page, presented side-by-side in a standalone mockup."

### 3.2. Replicate the Real Visual Identity
Before drafting variants, extract the project's real design tokens (colors, typography scales, spacing units, border radii, shadows, and base styling for shared components: buttons, cards, form inputs, navigation bars) from wherever the project defines them: CSS variables, Tailwind configurations, or theme files. Copy these values directly into the `<style>` block of the mockup so each variant feels authentically like part of the application rather than a generic template.

If the page includes structural framing (headers, sidebars, global navigation) that heavily influences how content is perceived, replicate that frame statically: non-functional, purely to provide authentic visual context. Zero real data, zero live routing.

### 3.3. Assemble the HTML with N Variants Side by Side
- Single file, pure HTML/CSS/JS: no frameworks, no bundlers, no dev server, everything inline, opening on double-click.
- N variants arranged in a responsive grid or side-by-side row, each inside a clearly labeled panel, effortlessly comparable at a glance.
- Each panel features a concise title and a single sentence articulating its core structural differentiator.
- Variants must be **structurally divergent**: distinct information hierarchies, different spatial layouts, alternative primary action placements—not mere palette swaps. If two variants look too similar, rebuild one with an explicit constraint ("no card grid").

### 3.4. Save Outside the Repository and Open
Save the HTML file in a temporary scratch directory completely outside the project repository (e.g. the session scratch directory), **never** inside the repository tree: the prototype must not require git cleanup. Open it for the user or provide the absolute path.

### 3.5. Review and Deliver
The user selects a favorite or specifies a hybrid ("header from Variant B with the layout from Variant C"): that constitutes the design decision. The mockup can be tweaked and refreshed as needed; it is disposable by design.

### 3.6. Record the Decision and Implement in Production
Record the decision (the chosen variant or hybrid, and why) in the linked issue or commit message.

Implementation of the winning variant is real production code: built into the actual component or page using the project's real design system and standards (testing, error handling, accessibility), adhering to the [`coding`](../../coding/SKILL.md) skill. The mockup serves strictly as visual reference, not source code to copy: it approximated the design system rather than implementing it cleanly. Delete the temporary mockup file after recording the decision; since it never entered version control, no repository cleanup is needed.

---

## 4. Anti-Patterns

- **Variants differing merely by color or font weight.** That is styling tuning, not prototyping. Real variants disagree on structure.
- **Generic placeholder styling ignoring real project design tokens.** Prevents stakeholders from judging how designs would look in production.
- **Wiring mockups into live app routing or dev servers**, even temporarily "just to check".
- **Saving mockups inside the project repository.** Placing files outside the repository is what makes cleanup effortless.
- **Copying raw mockup markup directly into production.** Rebuild the winning design properly using production components and patterns.
