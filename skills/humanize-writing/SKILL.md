---
name: humanize-writing
description: >-
  Writes, edits, and reviews text in any language to reduce predictable
  patterns of AI-generated prose, preserving authentic voice, point of view,
  and context. Triggered for emails, articles, blog posts, documents, scripts,
  and professional communications when the user requests natural, authentic
  writing, and by github-code-review and github-review-react when drafting PR
  comments and replies so they read as written by a human peer.
---

# Humanize Writing

A craft-oriented stylistic review, **never a mechanical checklist of rigid prohibitions**. Text preserves its purpose, tone, facts, and target language. Never invent data, lived experiences, or sources to simulate a human voice.

---

## 1. Language and Context

- Write in the language requested by the user. If unstated, preserve the language of the source text or conversation.
- Respect the register, punctuation, idioms, and cultural context of the language. Do not transplant English rhetorical habits into other languages.
- Apply the editorial intent of this guide rather than literal translation of examples. A pattern matters only when it sounds formulaic in that specific language and context.

---

## 2. Editorial Flow

1. **Understand**: purpose, target audience, intended voice, language, and verified facts.
2. **Draft or revise** with clarity and point of view. Favor cohesive paragraphs when prose needs fluidity; use lists strictly when they assist the reader in comparing items or taking action.
3. **Final pass** through the Section 3 review criteria. Rewrite strictly where text feels automated, bloated, or unnatural.
4. **Deliver** the polished text. Explain edits only if requested by the user or if a significant editorial decision warrants disclosure.

---

## 3. Review Criteria

- **Formulaic Contrasts**: avoid "it's not about X, it's about Y" and its newer variants ("it's more than an X, it's a Y", "rather than simply X"). If a contrast is necessary, make it specific, surprising, and rooted in substance.
- **Anaphora** (repeated sentence openings): use with restraint and intention, never as an unthinking rhythmic habit.
- **Crutch Transitions** ("when that happens", "more than that"): replace with nuanced qualifications woven into the thought, or restructure the sentence directly.
- **Teaser Noun Phrases** ("the X that Y"): avoid a generic noun plus a relative clause whose verb only signals importance ("the criterion that settles it", "the question that matters", "the detail that changes everything"; PT-BR: "o critério que resolve", "a peça que faltava"). The reader cannot tell which thing is meant or what it does, and the phrase withholds the content to build suspense. Name the thing and state its effect: "the due date settles ties" instead of "the criterion that settles it". **Test**: if the reader would naturally ask "which one?" or "settles what?", rewrite. Restrictive clauses carrying concrete content remain fine ("the test that has failed in CI since yesterday").
- **Labels, Not Teasers, in Headings and Bullets**: headings and bullet leads are labels, not sentences. Use a direct noun phrase (noun + adjective, participle, or complement): "Adopted criterion", "Main risks", "Root cause"; PT-BR: "Critério adotado", "Riscos principais", "Causa da falha". Never use relative clauses, "Why/What/Where" teasers, or suspense formulas ("The fix that works", "What nobody tells you"). This applies to any text with headings or lists (documents, PRs, reports), not only communicative prose. Exception: question headings in FAQs, or when the user explicitly asks for an editorial headline. Write headings in sentence case (title case is wrong in Portuguese and reads as machine output in English too), and reserve bold for terms the reader must not miss rather than scattering it across sentences.
- **Importance Announcements** ("this matters", "why X matters", "it's worth noting"; PT-BR: "vale destacar", "é importante notar"): do not declare relevance; show the consequence that makes it relevant. If the consequence is obvious, cut the announcement.
- **False Suspense and Staged Reveals** ("Here's the thing", "The result? Devastating.", "Not X. Not Y. Just Z."; PT-BR: "O resultado? Devastador."): state the point directly. Do not pose a question nobody asked only to answer it in the next sentence.
- **Announce-then-Answer Preambles** ("Two constraints shape the design." followed by the constraints): open with the content itself; the reader does not need a sentence that previews the next one.
- **Excessive Bullet Points**: do not convert every thought into a list, numbered step, or pedagogical enumeration. Allow prose to breathe in well-structured paragraphs.
- **Context Before Facts**: when a text delivers facts the reader must understand or act on (a status update, incident, decision, PR description), open with the situation the reader lacks and tie each fact to its cause or effect ("so", "to keep X from Y"; PT-BR: "por isso", "para que"). Disconnected fragments ("Memory: 1 GiB → 2 GiB. Max instances: 10 → 20.") force the reader to rebuild the story. Give each number its reference point: "a peak of 17 connections against a limit of 25", not "17 connections". **Boundary**: context means the situation and causal links, not padding; it carries content from the first sentence and skips what the reader already knows. **Test**: if the reader would ask "why did this change?" or "is that a lot?", a link is missing.
- **Empty Compromises**: take a clear stance when context warrants; when uncertainty exists, define its exact boundaries.
- **Formulaic Flourishes**: avoid closing with rhetorical questions, grand moral aphorisms, or soaring manifestos. End directly, concretely, or abruptly when that best serves the message.
- **Trust the Reader**: cut patronizing explanations; maintain intentional omissions when comprehension remains intact.
- **Varied Cadence**: alternate sentence and paragraph lengths intentionally. A short sentence carries punch. A longer sentence can earn its complexity.
- **Anchored Opinion**: back opinions with verifiable evidence when present. Without evidence, frame statements honestly as perspectives rather than undisputed facts.
- **Prohibition of Em-dashes in Communicative Prose**: in texts addressed to human teammates (emails, articles, PR comments, PR replies, direct messages), never use em-dashes (or hyphens/en-dashes substituting for them) as dramatic pauses, decorative flourishes, or parenthetical asides. This is one of the most glaring tells of AI-generated text. Rewrite using periods, commas, semicolons, colons, parentheses, or restructured syntax. **Rigid rule, not subjective preference**: if a sentence feels like it needs an em-dash, rewrite the sentence. (This restriction does not apply to code syntax, Markdown table pipes, list bullets, or identifier labels such as `E1 — Title`).

---

## 4. Voice Principles

- Write as someone with plausible domain background, preferences, and perspectives, without fabricating false personal anecdotes.
- Be skeptical of rhetorical figures that come too easily.
- Break rhythm intentionally for emphasis, never to perform forced spontaneity.
- Context governs. No checklist item is dogmatic (except the em-dash restriction in prose); the defect is unthinking formulaic repetition.

---

## 5. Boundaries

- Do not strip structure, technical precision, or professional dignity merely to sound casual.
- Never invent citations, statistics, or personal narratives without verification.
- Do not apply heavy rewrites to text that already possesses a distinctive, effective voice: preserve what works.

---

## 6. Success Validation

- [ ] Text is in the requested language and honors its register and conventions.
- [ ] Facts, purpose, and professional tone are preserved; zero fabricated details.
- [ ] Final pass against Section 3 completed; strictly automated tropes were rewritten.
- [ ] Zero em-dashes or en-dashes appear within communicative prose.
- [ ] Headings and bullet leads are direct noun labels in sentence case; no "the X that Y" teasers remain in prose.
- [ ] No importance announcements, staged reveals, or announce-then-answer preambles remain.
- [ ] Texts that deliver facts open with the situation and link each fact to its cause or effect; numbers carry their reference point.
- [ ] Delivered ready-to-use without commentary, unless specifically requested.
