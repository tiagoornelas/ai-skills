---
name: explain
description: >-
  Explains code, files, flows, or technical concepts to the user as if they
  had lost all context on that part of the system: rebuilds, in a few short
  steps, the path from the product down to the target, defining every domain
  term and internal name on the way, so the user regains the understanding
  without reading a report. Leverages visualize-it to draw flows and states.
  Used on demand when the user asks for an explanation, and by human-review
  when the user points at a part of a change.
disable-model-invocation: true
argument-hint: "[what to explain — by default the last discussed topic]"
---

# Explain It

---

## 1. Reader

The user, in their session language, as described in [The Human Directing Architect](../ai-assisted-software-development/references/human-facing-communication.md#1-the-human-directing-architect), assumed to have lost all context on this part of the system, including what they once knew or decided about it. They know general programming; the business area, the applications involved, and the code are rebuilt from zero.

Every sentence moves the reader one step closer to understanding the target, or it is cut.

---

## 2. Operational Principles

- **Shared context principles**: apply [Giving context](../ai-assisted-software-development/references/human-facing-communication.md#giving-context) (outside in, situate before naming, concrete before and after, say why or say it is unknown, no condescension, grounded). Domain terms are defined too, inline where they first appear.
- **Reasons the code does not state**: when the explanation needs why the code is shaped this way and the code does not say, read its history (`git log -L`, `git blame`, and the pull requests and issues they lead to), cite what you find, and say what stays unknown instead of guessing.
- **Visuals**: invoke the [`visualize-it`](../visualize-it/SKILL.md) skill whenever explaining a flow across parts of the system or the states a user sees, with the code names beside the drawing, keyed by step. The drawing replaces the prose it shows.

---

## 3. Explanation Structure

1. **Target**: the argument, or the last component, file, or flow discussed in the conversation. Explain what was asked, not the whole module around it.
2. **Destination**: one sentence that answers the question, so the reader knows where the path leads.
3. **Path**: from the product down to the target (product → application → area → mechanism), one or two sentences per level, each situating the next name before using it.
4. **How it works**: one concrete example traced through the target, as a swimlane when it is a flow.
5. **What would surprise**: up to three business rules, pitfalls, or reasons the code does not state. Omit when there are none.
6. **Deeper**: one line naming the parts that could be explained further, on request.

The explanation fits one screen besides the drawing. Terms are defined where they appear and the path already summarizes, so there is no glossary, closing summary, or reading list.

The shape, in a fictional gym app:

```text
The "Expired" badge on a membership is set by a nightly job, not by the screen, so it can lag up to a day.
Path: the app sells gym memberships. Each member has a membership with an end date, shown on the member page of the web app. The web app does not compute the badge: it shows the status the backend stores. A job running every night at 2 a.m. (backend, ExpireMemberships) marks memberships past their end date as expired.
```

---

## 4. Success Validation

- [ ] The target was identified, and only what was asked was explained.
- [ ] The explanation opened with one destination sentence, then the path from the product to the target, every domain term and internal name situated before use.
- [ ] One concrete example was traced, with a [`visualize-it`](../visualize-it/SKILL.md) drawing for flows or user-visible states.
- [ ] At most three surprises, and unknown reasons were stated as unknown, not invented.
- [ ] No glossary, closing summary, or reading list; the whole explanation fit one screen besides the drawing.
