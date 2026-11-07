# Epistemics

> **Central thesis**: historical evidence is fragmentary and sometimes contradictory. Every claim sits in one confidence tier, phrased to match, so the user can tell what the record states from what the investigation infers. An honest "we don't know" beats a confident guess the user will act on.

---

## When to consult

- Synthesizing and presenting the answer of `why`.

---

## 1. Confidence Tiers

| Tier | What qualifies | Phrasing |
| :--- | :--- | :--- |
| **Direct** | Someone wrote why: a pull request description, ticket, design doc, chat message, or code comment that states the reason. | Confident and cited: "This exists because X (link)." |
| **Supported** | Several indirect pieces converge: a "perf" ticket, a "speed up" title, and commits that all touch the same hot path. | Confident but derived, citing each piece: "The evidence points strongly to X: A, B, C." |
| **Inferred** | A reasonable reading nothing states: merged the same day as a production incident, so probably a hotfix. | Hedged, with the chain explicit: "Given A and B, C seems likely because D." |
| **Speculative** | A plausible hypothesis on thin evidence, with other explanations fitting as well. | "One possibility is X, but we found no evidence." Belongs in competing hypotheses. |
| **Unknown** | Searched and not found. | "We searched X with A and B, and Y's six pull requests since 2023; none states a reason." |

## 2. Phrasing

- **Words that claim intent** ("because", "the reason is", "was designed to", "fixes", "the team decided") need a citation beside them; never use them for an inference.
- **Hedges** ("appears to", "likely", "suggests", "is consistent with") mark interpretation.
- Drop "obviously", "clearly", "of course", "just", and "I think": the user asked because it was not obvious, and the answer reports evidence, not opinion.

## 3. Traps

- **Rationalization**: code that makes sense today may have been written for reasons that no longer apply, or were wrong. Do not retrofit a clean story, assume the author did the right thing, or read copy-paste as intent.
- **Code as evidence of its own intent**: a change from 50 to 100 shows the change, not the reason.
- **Recency**: the latest commit is rarely the origin; the current shape accretes earlier decisions. Trace back.
- **The embedded hypothesis**: "I assume it's for performance?" is a candidate to test, not a conclusion to confirm.
- **Absence as evidence**: "nobody mentioned security" does not mean it was not a concern.
- **Contradictions**: show both sources with citations and let the user decide; do not pick the tidier story.

## 4. Before Presenting

Check every claim: it has a citation or moves to inference or hypotheses; its phrasing matches its tier; it does not use the code as evidence of intent. An answer with no gaps is suspicious: either the record was unusually complete, or something was swept under the rug.
