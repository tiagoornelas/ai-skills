# Escape Classification

> Loaded by `github-code-review` and `github-review-react` when a review accepts a rules, tests, or code-quality finding on code the agent pipeline authored.

When a later review (peer review, [`github-code-review`](../../github-code-review/SKILL.md), or [`github-review-react`](../../github-review-react/SKILL.md)) accepts a rules, tests, or code-quality finding on code this pipeline authored, classify why self-review let it through. The classification guides the fix: only some causes are fixed by reviewing harder.

| Cause | Meaning | Remedy |
| :--- | :--- | :--- |
| **Coverage** | No self-review run covered the commit (merge, subagent commit, code written after the run). | Run increment mode from the checkpoint; run branch mode before the PR. |
| **Rule unread** | The rule file was never in the ledger, or was sampled. | Ledger enumeration and applicability ([SKILL.md](../SKILL.md), Phase 2). |
| **Rule relaxed** | The rule was read, but an exception was claimed without a quotable clause. | Verbatim citation obligation ([SKILL.md](../SKILL.md), Phase 2). |
| **Mechanizable** | The rule is checkable by tooling the project does not run. | Escalate the automated check; it then belongs to Phase 1 ([SKILL.md](../SKILL.md)). |
| **Judgment** | The finding needs judgment the run lacked (performance, concurrency, parsing). | Failure-path questions ([SKILL.md](../SKILL.md), Phase 5); otherwise accept as peer-review territory. |
| **Evidence** | A DoD behavior was marked covered without a named test that asserts it, or a limit was enforced only by prose. | Named-test and enforcement evidence ([SKILL.md](../SKILL.md), Phase 3). |
| **Coverage loss** | Tests were deleted in the range without a destination, or a registration had no test. | Removed-test list and wiring question ([SKILL.md](../SKILL.md), Phase 3). |
| **Dropped** | A Should fix was found and then vanished: not fixed, not justified, not named as over budget. | Should fix disposition ([SKILL.md](../SKILL.md), Section 5); per-phase evidence (Section 6). |
| **Rule conflict** | A general reference and a project rule disagreed, and the fix followed the general one. | Project rules prevail ([SKILL.md](../SKILL.md), Phase 4). |
| **Pre-existing** | The code predates the branch or was authored by someone else. | None: out of scope by design. |

Report the tally in one line (e.g., `Escapes: coverage 2 · rule unread 1 · judgment 1`). Do not open a self-review round over the escaped findings: they are fixed through the reviewing skill's own flow.
