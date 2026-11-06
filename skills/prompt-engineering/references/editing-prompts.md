# Editing Prompts

> **Central thesis**: most prompt bugs are fixed by changing or deleting the sentence that causes them. Stacking a new instruction on top of an old one makes the prompt longer, adds a contradiction the model resolves unpredictably, and leaves the next editor two places to fix.

---

## When to consult

- Before changing any existing prompt, skill, rule file, or description.
- When a requested fix seems to call for "one more rule".

---

## 1. Diagnose Before Writing

1. Write two sentences: the behavior observed and the behavior wanted, both general. Example: "the agent answers in English to users who write in Spanish" → "the agent answers in the language the user writes in".
2. If the request came with an example, extract the rule the example illustrates and discard the example. Ask: would the rule hold with other names, entities, and situations of the same kind? Only that rule enters the prompt.
3. When the wanted behavior is ambiguous, confirm the one-sentence rule with the user before editing. Correcting the wrong behavior is costlier than asking.

## 2. Read What the Model Actually Receives

The model sees the assembled prompt: the instruction file plus shared components, loaded skills, references, injected context, and tool descriptions and tool results. Before editing:

- Search every one of those sources for the terms of the behavior. The governing text, a duplicate of it, or a contradiction often lives outside the file named in the request.
- Note which text is static (cached, sent every call) and which is loaded on demand. A rule that applies to every turn belongs in the static part; a step-by-step recipe for one workflow belongs in a skill or reference behind a one-line trigger.

## 3. Choose the Edit, in This Order

| Order | Edit | Use when |
| :--- | :--- | :--- |
| 1 | **Replace in place** | A value, name, destination, or rule changed. The new text takes the old text's place and says only what holds now. |
| 2 | **Remove** | The unwanted behavior comes from an instruction, example, or emphasis that is stale, over-broad, or redundant. Removal is often the whole fix. |
| 3 | **Rewrite** | The governing sentence is right in intent but ambiguous, missing its condition, or missing its reason. |
| 4 | **Move** | The instruction is right but in the wrong place: always-loaded when it is needed only sometimes, or far from the step where the model uses it. |
| 5 | **Add** | No existing text can carry the behavior. Add the minimum positive sentence, where the model uses it. |

Before adding, list what the change makes obsolete, redundant, or contradictory, and remove it in the same edit.

Behavior that depends on runtime data belongs in the tool result or in code, not in prose branches: a validator, schema, or guard enforces a limit; the prompt then only says what to do with the outcome. Do not restate in the prompt a rule the code already enforces.

## 4. One Rule, One Owner

When the same rule appears in several files the model loads, keep it in one place and let the others refer to it by name, or delete them. Copies drift apart on the next edit, and the model then picks between two versions.

After editing a rule, search all loaded sources for keywords of its old version and remove the survivors.

When removing a rule, check what depended on it: cross-references ("as stated above"), skills that cite it by name, prompt-contract tests. When an existing test asserts wording the edit changes, update its expected text in the same change and point it out to the user as a test that freezes wording; removing that test is the user's decision.

## 5. Prune

Re-read only the diff. For each added or changed sentence, ask: if this sentence were deleted, would the model behave differently in a case that matters? If not, delete it. Then check the whole prompt for:

- Restatements of the same rule in other words.
- Emphasis added to win against another rule instead of resolving the conflict between them.
- Explanations of things the model already knows.
- Anything [writing-rules.md](writing-rules.md) keeps out: history, real cases, internal vocabulary.

Minimal is not telegraphic: keep conditions, exceptions, and reasons that change decisions. Cut words that carry no decision.
