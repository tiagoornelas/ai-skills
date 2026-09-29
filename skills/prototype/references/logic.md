# Logic Prototypes

A single, self-contained HTML file—a **shareable interactive demo**—allowing anyone to drive a state machine or domain model by clicking buttons. Use when the question concerns **business rules, state transitions, or data modeling**: concepts that appear sound on paper but reveal flaws when evaluated against real scenarios.

Because it is a single file requiring zero dependencies or installation rituals, it can be handed directly to non-technical stakeholders (designers, product managers, domain experts) to test the model intuitively. The demo speaks their business vocabulary, not technical jargon.

---

## 1. When This is the Right Form

- "I'm unsure whether this state machine handles scenario X followed by Y."
- "Can this data model adequately represent the case where..."
- "I want to feel what the API ergonomics are like before building it."
- Any context where someone needs to **click buttons and watch state evolve**.

If the question is "What should this look like?", that is the wrong branch: use [`ui.md`](ui.md).

---

## 2. Process

### 2.1. State the Question Explicitly
Before writing code, clearly declare the state model and question being investigated. Place this in a prominent paragraph at the top of the demo interface (not just in an HTML comment). Keeping the question explicit allows stakeholders to verify later whether the prototype actually answered the intended question.

### 2.2. Isolate the Core Logic in a Portable Module
The logic addressing the question lives in a single `<script>` block, structured as a compact, pure module that could be extracted directly into production code. The surrounding HTML shell is disposable; this core logic module is not.

Form depends on the inquiry:
- **Pure Reducer** (`(state, action) => state`): when actions are discrete events and state is a single immutable snapshot.
- **State Machine** (explicit states and transitions): when "which actions are valid right now" is central to the question.
- **Set of Pure Functions** over simple records: when there is no implicit ongoing state, only transformations.
- **Class or Module with clean methods**: when the domain naturally encapsulates a continuous internal state.

Choose the structure that best serves the domain question, **not** the easiest way to bind to DOM buttons. Keep it pure: zero DOM access, zero `document` references, zero click handlers inside the module. The UI invokes the module; data never flows backward. This enables clean reuse: once the question is answered, the validated reducer or functions move directly into the production codebase.

### 2.3. Build the Shareable HTML Artifact
One file, vanilla HTML/CSS/JS: no build tools, no bundlers, no local servers, everything inline, opening on double-click and surviving an email attachment.

Author for non-developers. All labels use **domain vocabulary**, not developer jargon: buttons and state displays read as business actions, not internal reducer types.

Visual hierarchy, top to bottom:
1. **Title and one-line summary** of what the demo explores (the question from 2.1).
2. **Current State Panel**: the complete relevant state rendered in a readable dashboard (labeled fields, not raw JSON blobs), updated on every interaction. Highlight recently modified properties where helpful.
3. **Free Action Buttons**: one button per domain action, always available to manipulate the model in any order.
4. **Guided Scenarios**: one **scenario** per tab. Each tab contains a short narrative (the scenario context and what to observe), followed by an ordered sequence of **action buttons**. Each step is a live button that triggers the action and advances. Starting a scenario resets the model to a clean baseline state for reproducibility.

Select scenarios that showcase difficult boundaries: the happy path, an intricate edge case, and an attempt to execute an invalid action.

Clean and restraint in styling: crisp typography, generous whitespace, a single accent color. Zero animations or decorative fluff competing with state inspection.

### 2.4. Record Findings and Retire the Prototype
Record the verdict and answered question in the linked issue or commit message. The validated domain logic moves into the production codebase. The HTML demo is archived on a temporary scratch branch (`prototype/<name>`), isolated from main and never merged, serving as primary evidence for the design decision. Push to remote only upon explicit user confirmation.

---

## 3. Anti-Patterns

- **Adding automated tests.** A prototype requiring test suites has ceased being a prototype.
- **Wiring to real databases.** State lives in memory, unless the inquiry specifically investigates persistence mechanics.
- **Premature generalization.** No "what if we need to support X later". The prototype answers one question.
- **Entangling logic with the DOM.** If the pure module references DOM nodes or event handlers, it cannot be reused cleanly.
- **Using frameworks, bundlers, or dev servers.** Requires a single double-clickable file; React apps or node dev servers destroy shareability.
- **Promoting the HTML harness to production.** The web page exists solely for manual exploration. Only the underlying logic module has production value.
