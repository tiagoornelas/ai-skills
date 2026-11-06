---
name: prompt-engineering
description: >-
  Writes, edits, and trims prompts read by AI models: system prompts, agent
  instructions, skills (SKILL.md and references), AGENTS.md / CLAUDE.md and
  other persistent rules, tool and skill descriptions, and reusable subagent
  briefs. Reaches the intended behavior with the fewest tokens, treating
  removal and rewriting as first-class edits. Must be triggered before
  creating or changing any prompt, even a one-word change.
---

# Prompt Engineering

A prompt is the smallest set of high-signal tokens that produces the intended behavior. Every sentence is paid on every call and competes with every other sentence for the model's attention, so each edit aims at the leanest prompt that works, not at the largest change that feels safe.

## Scope

Any text a model reads as instruction: system prompts, agent instruction files, skills and their references, AGENTS.md, CLAUDE.md, rule and memory files, tool and skill descriptions, and brief templates for subagents. A one-off brief written in the moment follows the [writing rules](references/writing-rules.md) without the full workflow.

When the project has its own prompt rules or automated prompt checks (token budgets, forbidden content scanners), read and run them; they complement this skill and win on conflict.

## Workflow

1. **State the target behavior** in one general sentence: "when X, the model does Y". It describes every case of the class, never the case that motivated the request.
2. **Read the whole prompt the model receives**, not only the file or line in question, and find the text that already governs the behavior.
3. **Rewrite or remove before adding**: change the governing text in place; delete what the change makes obsolete, redundant, or contradictory. Add a sentence only when nothing existing can carry the behavior.
4. **Write the change** following the [writing rules](references/writing-rules.md).
5. **Prune the diff**: for each changed sentence, ask whether the model would behave differently without it. If not, delete it.
6. **Verify and report** following [verifying-prompt-changes.md](references/verifying-prompt-changes.md): behavior before and after, the size delta, and what was removed.

A literal request ("change A to B") is satisfied by replacing every occurrence of A that the model receives with B, and nothing more.

## References

| Reference | Load when… |
| :--- | :--- |
| [editing-prompts.md](references/editing-prompts.md) | Changing an existing prompt: locating the governing text, deciding between rewrite, removal, and addition, and pruning. |
| [writing-rules.md](references/writing-rules.md) | Writing any prompt sentence, example, or description. |
| [verifying-prompt-changes.md](references/verifying-prompt-changes.md) | Checking that a prompt change works and reporting it. |

---

## Success Validation

- [ ] The target behavior was stated as a general rule, and the prompt holds no detail of the motivating case (real IDs, names, dates, conversations) nor history of the change.
- [ ] Existing text was rewritten or removed before any sentence was added; no obsolete or contradicted instruction survives anywhere in the prompt the model receives.
- [ ] Every negative instruction guards against something the model would plausibly do on its own.
- [ ] Every remaining changed sentence passed the pruning test.
- [ ] The project's own prompt rules and checks were applied and pass.
- [ ] The report states the behavior change, the size delta, and what was removed.
