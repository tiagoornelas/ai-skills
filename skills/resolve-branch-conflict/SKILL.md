---
name: resolve-branch-conflict
description: >-
  Guides the user through resolving Git conflicts between two branches (or
  between a PR and its base): visually demonstrates where and why parallel
  streams collided, deciphers the intent of each side, separates mechanical
  resolutions from delicate compositional synthesis, detects semantic conflicts
  that Git misses, and resolves clashes while preserving the behavior and
  architecture of both streams.
disable-model-invocation: true
argument-hint: "[PR number/URL, or two branches: <ours> <theirs>]"
---

# Resolve Branch Conflict

A merge conflict signals that two developers modified the same layer **without awareness of each other's work**. Resolving conflicts well is not picking a winner: it means delivering what **both** work streams intended, structured cleanly so neither author is alienated and code remains extensible.

> The agent analyzes, classifies, proposes, and executes. **Discarding someone's work, altering a public contract, or choosing between competing architectures is strictly the user's decision.**

Uses [`visualize-it`](../visualize-it/SKILL.md) to diagram collisions, [`software-designing`](../software-designing/SKILL.md) when resolution touches architecture, and [`coding`](../coding/SKILL.md) for clean implementation. Catalog of conflict patterns and recipes resides in [`references/conflict-patterns.md`](references/conflict-patterns.md).

---

## 1. Pin Down the Two Endpoints

- **GitHub PR**: `gh pr view <pr> --json number,title,body,url,author,baseRefName,headRefName,commits`. *Ours* = PR head; *Theirs* = base branch.
- **Two Local Branches**: first branch is *ours* (receives the resolution); second branch is *theirs*. If order is ambiguous, ask.

Next:

```bash
git fetch origin
git merge-base <ours> <theirs>                          # divergence point
git merge-tree --write-tree --name-only <ours> <theirs> # textual conflicts without touching worktree
git diff --name-only <merge-base> <ours>                # touched by us
git diff --name-only <merge-base> <theirs>              # touched by them
```

Confirm that refs resolve and collisions exist (textual or file overlap) **prior** to proceeding. If zero overlap exists, report that and stop.

**Do not modify the user's working tree during this phase.** If dirty, notify the user before attempting any merge.

---

## 2. Understand Parallel Work Streams

For each side, gather the underlying intent, not just raw diff lines:

- `git log <merge-base>..<side> --format='%h %an %s'`: commits and authors.
- PR description, linked issues (Jira/GitHub), and commit messages.
- Diff chunks of each side across overlapping files.

Summarize in a single sentence per side: **"We intended X. They intended Y."** If intent is ambiguous from evidence, declare that and ask the user rather than guessing.

Diagram the divergence using `visualize-it`:
- **Timeline**: merge-base, commits from each side, and where each modified the conflict area.
- **Module Collision Map**: which modules each side modified using `visualize-it` badges (🆕 🔧 🗑️ ⚠️), marking points of collision with ⚠️.

---

## 3. Classify Each Conflict Point

Every conflicting hunk and overlapping file receives a classification (recipes in [`references/conflict-patterns.md`](references/conflict-patterns.md)):

| Class | Meaning | Decision Authority |
| :---: | :--- | :--- |
| 🟢 **Mechanical** | Independent changes that merely collided textually: imports, list items, formatting, generated code, lockfiles. | Agent resolves; displays summary. |
| 🟡 **Composition** | Both sides touched the same logic with compatible intent; resolution must preserve both behaviors. | Agent proposes; user confirms. |
| 🔴 **Clashing Intent** | Incompatible intent or diverging designs (one refactors while the other extends; competing abstractions for the same concept; contradictory business rules). | User decides, with options and recommendation. |
| ⚠️ **Semantic** | Zero textual conflict, but breaks when combined: one side altered a contract (signature, name, format, schema) while the other introduced calls to the old contract. | Handled as 🟡 or 🔴 based on impact. |

Class ⚠️ is what Git's merge engine cannot see. To locate semantic conflicts, cross-reference **symbols, contracts, and schemas altered by one side** against **new code introduced by the other side** (`git diff <merge-base> <side> -- <file>` and symbol grep). When uncertain between classes, assign the higher severity.

---

## 4. Present Conflict Map

```markdown
## Ours × Theirs
- **Ours** (<branch>, <authors>): <intent in one sentence>
- **Theirs** (<branch>, <authors>): <intent in one sentence>

<timeline and module map via visualize-it>

## Conflict Points — 🟢 N · 🟡 N · 🔴 N · ⚠️ N

| # | Location | Class | Ours | Theirs | Proposal |
| :-: | :--- | :-: | :--- | :--- | :--- |
| 1 | `src/a.ts:40-58` | 🟢 | adds import X | adds import Y | retain both |
| 2 | `src/b.ts:12-30` | 🟡 | validates SSN | normalizes SSN | normalize, then validate |
| 3 | `src/c.ts` + `src/d.ts:88` | ⚠️ | renames `getUser` → `findUser` | new call to `getUser` | update new call site |
```

For each 🟡, 🔴, and ⚠️, display a three-column card (**base / ours / theirs**) showing minimal context, followed by proposed resolution. Use `zdiff3` conflict style to see base context: `git -c merge.conflictStyle=zdiff3 ...`.

Discuss with user. User can adjust classifications, proposals, and execution order.

---

## 5. Determine Integration Strategy

Ask the user with a recommendation if repository conventions do not dictate:

- **Merge *theirs* into *ours*** (recommended default): preserves non-destructive history, safe for shared branches.
- **Rebase *ours* onto *theirs***: linear history, but rewrites commit SHAs; appropriate only on private feature branches. Requires `push --force-with-lease` afterward.

Perform resolution inside a working branch or isolated worktree (`git worktree add`), keeping the original state pristine until user approves.

---

## 6. Resolve

In order:

1. **🟢 Mechanical in batch**, following reference recipes. Generated files and lockfiles are **regenerated** via native tooling, never merged by hand.
2. **🟡 Composition and ⚠️ Semantic**, one at a time: author the resolution using [`coding`](../coding/SKILL.md), show result alongside base, ours, and theirs, proceeding upon confirmation.
3. **🔴 Clashing Intent**: present the user with 2–3 explicit options detailing what each preserves and loses, with a recommendation. When selecting between architectural abstractions, apply [`software-designing`](../software-designing/SKILL.md); if high-consequence, pass through [`design-it-twice`](../design-it-twice/SKILL.md).

Rules of resolution:

- **Both behaviors survive**, unless the user explicitly chooses otherwise. Never silently drop one side (`--ours`/`--theirs` across entire files only for 🟢 or with explicit confirmation).
- **Respect established precedent**: if *theirs* is already on the base branch (merged), new code from *ours* adapts to their design, not vice-versa, unless user decides otherwise.
- **Elegance, not branching clutter**: if composing requires adding flags for each side, an abstraction is missing; design the unifying concept via `software-designing`.
- **Zero scope creep**: do not use conflict resolution as an excuse to refactor untouched code.
- If resolution substantially alters a peer's recent code, draft a short courtesy message to notify them.

---

## 7. Verify

- [ ] Zero conflict markers remaining: `git diff --check` and search for `<<<<<<<`, `=======`, `>>>>>>>`.
- [ ] Project build, linters, and type checkers pass.
- [ ] **Tests from both sides pass**; zero tests loosened or removed to force a pass.
- [ ] Every intent from Section 2 remains fulfilled: enumerate behaviors from *ours* and *theirs* and verification evidence (DoD legend from [`human-review`](../human-review/SKILL.md), Section 2.3).
- [ ] Semantic conflict points ⚠️ verified through execution or tests.

Verification failures return to Section 6, not to the user, unless requiring an architectural decision.

---

## 8. Finalize

1. Record merge commit (or `rebase --continue`) using [`commit`](../commit/SKILL.md). Commit message documents 🟡, 🔴, and ⚠️ resolutions and decisions taken.
2. **Do not push without request.** When requested, show the command (`--force-with-lease` if rebased) and confirm.
3. Conclude with summary:

```markdown
## ✅ Conflict Resolved
- 🟢 N mechanical · 🟡 N compositions · 🔴 N decisions · ⚠️ N semantic
- Decisions taken: <one line per user decision>
- Verification: <build/tests/behaviors>

## Friction Points for Future Refactoring
- <where parallel streams collided due to missing extension points or ambiguous boundaries, with suggestions — unexecuted>
```

Offer to convert friction points into tracking issues using [`report-work`](../report-work/SKILL.md).

---

## 9. Success Validation

- [ ] Both branches and merge-base pinned and validated prior to edits; user working tree untouched without warning.
- [ ] Intent of each side declared with evidence; divergence visualized.
- [ ] Every conflict point, including semantic non-textual collisions, classified with a concrete proposal.
- [ ] Every 🔴 and work-discarding choice approved by the user.
- [ ] Section 7 verification passed completely with behaviors from both branches intact.
- [ ] Zero changes pushed to remote without explicit request and confirmation.
