---
name: visualize-architecture
description: >-
  Draws the architecture of a software system for a reader who knows the
  product but not the code: its components (apps, services, jobs, data
  stores, queues, external systems), the boundaries that group them, and how
  they relate (who calls, reads, writes, or notifies whom), following the
  visualize skill's conventions. Works out from the conversation whether to
  draw a plan (the architecture a design or proposal would produce), what was
  built (a branch, PR, or finished delivery), or the system as it is today,
  and asks the user when the context does not say. Triggered when the user
  asks to see, draw, or explain an architecture, an architectural design, or
  how the components of a system relate.
---

# Visualize Architecture

One drawing answers **what is this made of, and how do the pieces relate?** It follows [`visualize`](../visualize/SKILL.md) for everything a drawing shares: product terms in the user's session language, no technical names, output by destination, and at most two sentences under it. When the reader also needs the order of the steps, add a `visualize` swimlane under the map, with the map's component names as its columns.

## 1. Settle the Subject Before Drawing

Read the conversation and pick the subject:

| The context shows | Subject | Source |
| :--- | :--- | :--- |
| A plan, design, or proposal under discussion and not built yet | The architecture the plan produces | The plan; the code only to place the existing components it touches |
| Work done: a branch, a PR, a diff, or a delivery just finished | What was built | The code at that head; the diff for what it changed |
| A system, product, or module named, or the current repository when nothing else is in focus | The system as it is today | The code and its configuration (deploy files, infrastructure, environment) on the default branch |

- **Scope**: the smallest part that holds everything the conversation is about: one module, one product, or the whole system.
- **When the context does not settle it** (two subjects fit, such as a plan discussed while its branch is half built, or the scope is unclear): outside a delivery, ask one question, with the question tool when the harness has one, giving the subjects that fit, what each drawing would show, and a recommendation, and draw nothing before the answer, because a map of the wrong subject reads as a fact; inside a delivery, draw the recommended subject and say which one you chose.
- **Draw only what the source shows.** A component or relation the source implies but does not show goes under the drawing as an assumption, never into it.

## 2. The Map

- **Components** are the things that run or store on their own: the person acting, an app or screen, a service or API, a job or worker, a database, a queue, a bucket, an AI agent, an external system. Name each in product terms. Parts inside a service appear only when the scope is that service. At most eight components per map; a larger system gets an overview of its boundaries first, then one map per boundary the user asks for.
- **Boundaries** are frames around components shipped or owned together (a repository, a deploy unit, the company's cloud), named in product terms. Third parties stay outside every frame.
- **Relations** are arrows from the component that acts or depends to the one it reaches, labeled with what crosses in product terms ("sends the invoices", "reads customers"). `──▶` is a call that waits for its answer; `╌╌▶` (vertically `╎`) is a message, event, or schedule that does not wait, because the two fail differently.
- **Layout**: the person acting on the left, data stores and third parties toward the right or bottom.
- **Marks** keep the exact meaning the [change card](../ai-assisted-software-development/references/change-card.md#2-the-tree) gives them. For a plan or for what was built, each component and relation the change brings carries its mark, and everything else stays plain; under any subject, a relation against the project's pattern or dependency direction carries `!`. A point the plan leaves undecided goes under the drawing as an open question.

A fictional plan: billing already exports invoice PDFs, and the plan moves rendering and emailing them to a job:

```text
┌─ web app ────────┐            ┌─ billing ───────────────────────────────────┐
│                  │  asks for  │                                             │
│  Invoice screen ─┼── the PDF ─┼─▶ Billing API ── saves exports ──▶ Database │
│                  │            │      ╎                               ▲      │
└──────────────────┘            │      ╎ + queues the render           │      │
                                │      ▼                               │      │
                                │   + PDF job ── + stores the PDF ─────┘      │
                                │      │                                      │
                                └──────┼──────────────────────────────────────┘
                                       │ + sends it by email
                                       ▼
                                  Email provider
```

Where the destination renders Mermaid, draw the same map as a `flowchart LR`: one `subgraph` per boundary, `-->` for a call that waits, `-.->` for one that does not, and each mark at the start of its label.

## 3. Success Validation

- [ ] The subject (plan, what was built, or today) and the scope came from the context, or, when it did not settle them, from the user's answer outside a delivery or the stated recommendation inside one.
- [ ] Every component and relation came from that subject's source; anything inferred was listed under the drawing as an assumption.
- [ ] Components were named in product terms inside boundary frames, at most eight per map, with third parties outside every frame.
- [ ] Each relation was labeled with what crosses, solid when it waits and dashed when it does not.
- [ ] Marks kept the change card's meaning and, for a plan or what was built, only what the change brings carried one; undecided points were open questions under the drawing.
- [ ] The drawing followed `visualize`'s conventions, with a swimlane added only when the order of the steps mattered.
