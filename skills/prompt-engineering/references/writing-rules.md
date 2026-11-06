# Writing Rules

> **Central thesis**: write the current behavior, for every case of its kind, in the fewest words that keep its conditions and reason. The prompt is not a log of changes, a record of incidents, or a list of everything that could go wrong.

---

## When to consult

- Writing any sentence, example, or description that a model reads as instruction.

---

## 1. Say What to Do

- State the wanted behavior positively and concretely: "reply in two sentences" instead of "do not be verbose".
- A negative instruction earns its place only when the model would plausibly do the forbidden thing on its own: a natural default, a mistake observed more than once, or a safety or permission boundary. Pair it with what to do instead.
- A value the prompt replaced is not such a case: the model knows the old destination, name, or rule only because the prompt used to say it, so once the prompt says the new one, the old one is gone. Naming it ("not X anymore") reintroduces it and invites listing every other wrong value too. The exception is an old value the model would still reach for on its own, from training data or another source it reads.
- Replace vague qualifiers ("be careful", "when appropriate") with an observable action or condition.

## 2. Write the General Case

- Instructions describe a class of situations. The case that motivated the change is evidence for the rule, not part of it.
- Every conditional instruction names its trigger in terms the model can observe in context (what the user sent, what a tool returned), never in the developer's terms.
- Use one name per concept throughout the prompt, in the domain's vocabulary. Synonyms read as different things.
- Write tool names, fields, and enum values exactly as the model sees them.

## 3. No History, No Real Data

The prompt holds only what is true now. Keep out:

- **Change history**: phrasing that narrates the change rather than the behavior ("from now on", "no longer", "since <date>", "we used to", "fixed"). It belongs in the commit or decision record.
- **Real cases**: conversation, session, artifact, ticket, PR, or entity IDs, real people, customers, or messages used to illustrate or justify a rule; narratives such as "in a real case…".
- **Internal vocabulary**: team labels, phase names, ticket keys, function names the model does not see, and handles coined during the conversation.

Values the agent needs to operate (a destination channel, an endpoint, the PR a brief is about) stay, written as plain current facts.

## 4. Give the Reason in a Clause

Add the reason when it changes how the model handles a case the rule does not spell out: "keep answers under 100 words, because they are read aloud". Skip it when the rule is self-explanatory. A reason generalizes; a pile of exceptions does not.

Reserve emphasis (capitals, "NEVER", "CRITICAL") for constraints with a real cost when broken. When everything is emphasized, nothing is, and modern models over-apply emphasized rules.

## 5. Examples, Sparingly

- Use an example only when a description alone leaves the format or judgment ambiguous.
- Make it fictitious, short, and clearly marked as illustration. Never reuse the example the user gave to explain the request, and never use real data.
- Show the shape, not reusable content: a long realistic example gets copied verbatim outside its context. Prefer one or a few diverse examples to a list of edge cases.
- Do not include visible placeholders in examples of user-facing text (`[insert here]`): they leak into output.

## 6. Place and Scope

- Put each instruction at the step where the model uses it, not in a trailing "notes" block.
- Describe what the agent decides, not mechanics another layer owns (screen layout, UI components, payload formats). Point to the contract instead; mechanics change outside the prompt and leave it wrong.
- Never instruct or suggest a capability the agent does not have: check the tools and permissions actually wired in.

## 7. Skills and Descriptions

- A skill or tool `description` is routing: it says what the thing does and when to use it, in third person, with the terms a request would use. It carries every trigger; how to use it goes in the body.
- Keep a skill's main file to the decisions and steps the model gets wrong without it; move deep material to references loaded on demand, each listed with one line saying when to load it. References stay one level deep.
- Match specificity to fragility: heuristics where many approaches work, exact commands where one mistake breaks something.
- A brief to another agent is a prompt too: the receiver has none of your context, so give every handle its meaning and pass the problem, not your conclusion.
