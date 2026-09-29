# No Local References in Shared Artifacts

> **Central thesis**: an artifact that someone else will read (commit, PR, review comment, issue, report, handoff to a peer) can only reference what **that person can open**.

---

## When to consult

- Whenever writing text that leaves the machine: commit messages, PR descriptions, review comments, issues, tasks, reports, messages to a teammate.

---

## The Rule

Never reference:

- local machine paths (`/Users/...`, `~/...`, `C:\...`);
- folders and files typically kept outside version control (`docs/tickets/`, `docs/prd/`, `docs/research/`, anything in `.gitignore`);
- ticket IDs that only exist locally.

Instead:

- point to the **linked issue** (Jira, GitHub Issues, Linear) or to a PR, commit, or page that the reader can open;
- or **rephrase the information** in your own words directly within the artifact.

Paths of **versioned repository files** (e.g. `src/billing/invoice.ts:42`) are allowed: anyone reading the PR or commit has access to them.
