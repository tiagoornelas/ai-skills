---
name: design-weight
description: >-
  Sizes a proposed or finished change by its design weight: what it moves in
  the design, judged by who notices it, never by lines or files. Places it on
  a four-level ruler (local, internal, boundary, architecture), draws the
  change card tree of where it lands, and offers the lighter variant when one
  exists, before anything is built. Triggered when the user asks how big a
  change is, whether it fits the current architecture, whether it knocks
  down a wall or pivots the architecture, or for a solution of a weight they
  describe in their own words ("something light", "even if it is heavy"); owns how the ruler is judged and
  drawn wherever the change card, decision options, improve-architecture, and
  pull requests print it.
argument-hint: "[proposal or change to weigh — by default the last one discussed]"
---

# Design Weight

The weight of a change is what it moves in the design, and the plainest measure of that is who notices it. Lines, files, and functions are never the weight: a one-line change can reverse an architectural decision, and a long one can stay inside a single function.

---

## 1. The Ruler

The four levels (local, internal, boundary, architecture), who notices each, and how they relate to the tiers are defined in [the boundary test](../ai-assisted-software-development/SKILL.md#4-the-boundary-test); read them there before weighing.

Two forms, every word in the reader's language, labels realigned under their dots:

```text
Design weight  ●──────────○──────────○──────────○
               local      internal   boundary   architecture
```

```text
Design weight  ○───○───●───○  boundary
```

The two-line form opens a direct call. The one-line form goes where a report already shows what changes: the change card, a decision option, an opportunity of [`improve-architecture`](../improve-architecture/SKILL.md). A report sent after an estimate, such as the change card at delivery, adds it when the result differs: `boundary, estimated local`.

## 2. Judging the Weight

1. **Find the decisions in force** that the change could touch: the issue, the conversation, decision records, project rules. The architecture level depends on this list, so say where you looked.
2. **Weigh what would be built.** Write the smallest change that meets the request and the change that would actually be built; when they differ, the weight follows the second.
3. **Name the fact the weight rests on**, pointed at its source: the contract, its consumers, the decision. Confidence is high only when every consumer of a touched contract was read, other repositories included.
4. **Name what would raise it a level** ("grows if a test pins the current rule").
5. **Offer the lighter variant** when the weight is above local: the version that stays lower, with its own level and what of the request it gives up, or a plain statement that none exists.

## 3. Direct Call

Weigh the proposal in the argument, or the last one discussed. When the argument is a problem and the weight the user wants in their own words, read that wish as they would mean it, propose the solution that fits it best, weigh it, and say whether it fits. Read-only: nothing is built. The answer fits one screen:

1. The two-line ruler.
2. The change card tree of the proposal, with only the leaves the change card admits; internal parts (stores, types, components) are never leaves, so local and internal changes usually print no tree.
3. Up to three sentences: what moves and who notices, any business rule that changes, what would raise the weight, and what was not read when confidence is not high.
4. Above local, the lighter variant. At architecture, `⚖️` asks the user to decide before any code.

A fictional example:

```text
Design weight  ○──────────○──────────○──────────●
               local      internal   boundary   architecture

billing-api
├─ jobs
│  └─ - nightly expiry job    job
└─ ! membership route         route · computes the status on every request · reverses "status is computed once a day" · to ratify
web-app
└─ ~ member page              reads the status live

Members see "Expired" the minute their plan ends instead of the next morning, and every member page request now runs the billing rules.
Lighter variant: run the nightly job every hour (local).
⚖️ Decide before any code. I recommend the lighter variant.
```

## 4. When the Weight Rises While Building

When the work being built reaches a level above the weight the user accepted (an estimate they were given, or a weight they asked for in their own words, such as "only if it keeps the architecture"), stop before that part, per [where the agent always stops](../ai-assisted-software-development/SKILL.md#where-the-agent-always-stops), and send:

```text
⚠️ The weight rose: ●───○───○───○ local  →  ○───○───●───○ boundary
<what forced it, in product terms, and what each choice costs to reverse>
⚖️ Continue at boundary, or keep the local version? I recommend <one>, because <reason>.
```

---

## Success Validation

- [ ] The weight was the highest level any part reached, judged on what would be built, and no count of lines, files, or functions stood in for it.
- [ ] The decisions in force were looked up, the fact the weight rests on was pointed at, and confidence was high only with every consumer read.
- [ ] A direct call showed the two-line ruler, the change card tree when it had leaves, what moves, and what would raise it, in one screen, without building anything.
- [ ] Above local, the lighter variant or its absence was stated; at architecture, the user was asked to decide before code.
- [ ] Inside other reports, only the one-line ruler appeared, with the estimate when it differed.
- [ ] Building past the accepted weight stopped and showed the ruler before and after.
