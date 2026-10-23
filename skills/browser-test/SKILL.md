---
name: browser-test
description: >-
  Drives a real browser through the Playwright CLI (`playwright-cli`) to test
  and verify web behavior: checks a UI change in the running app, reproduces
  a frontend bug, inspects console errors and network requests, captures
  screenshots as evidence, or runs the project's own Playwright test suite.
  Runs headless by default and opens a visible (headed) browser only when the
  user explicitly asks to watch it. Triggered when the user or a workflow
  needs to test, verify, or reproduce something in a web page.
argument-hint: "[URL or flow to test, and 'headed' to watch it]"
---

# Browser Test

Drives a browser with `playwright-cli` to answer one question: does this page behave as expected? This skill owns the policy (mode, session, artifacts, safety); the CLI's own skill owns the syntax.

## 1. Preconditions

- Check `command -v playwright-cli`. If it is missing, stop and tell the user the tool is required, proposing the install below. Run it only with the user's approval.

  ```bash
  npm install -g @playwright/cli@latest
  playwright-cli install-browser chromium
  ```

- Treat the installed CLI as the syntax authority: load the official `playwright-cli` skill unless already in context. When the harness does not list it, read the `SKILL.md` whose path `playwright-cli --help` prints on its `Agent skill:` line.
- If `open` fails because the browser executable is not found, propose `playwright-cli install-browser chromium` and run it only with the user's approval.
- When the target is a local app, confirm it is running (or start it the way the project documents) before opening the browser.

## 2. Choose the Mode

| Signal in the user's request | Mode |
| :--- | :--- |
| None (default), including subagents and autonomous verification | **Headless** |
| The user explicitly asks to see, watch, or follow the browser ("headed", "visible", "show me"), in any language | **Headed**: add `--headed` to `open` |

Never switch to headed on your own judgment. When a step needs a human in the browser (login, captcha, a manual check), stop and ask whether the user wants a headed session; open it only after they agree.

## 3. Open a Session

Sessions are global to the machine, not scoped to the project, so parallel agents collide on the `default` session. Always:

1. Name the session uniquely, e.g. `-s=<project>-<short-purpose>`, and pass the same `-s=` on every command.
2. Keep generated files out of the repository: set `PLAYWRIGHT_MCP_OUTPUT_DIR` to the harness scratchpad directory, or to a fresh `mktemp -d` when there is none. Use Playwright's Chromium unless the user asks for another browser. Both variables only need to be set on `open`; the session keeps them.

```bash
PLAYWRIGHT_MCP_BROWSER=chromium PLAYWRIGHT_MCP_OUTPUT_DIR="<scratch-dir>" \
  playwright-cli -s=<session> open <url> [--headed]
```

## 4. Test

- Prefer `snapshot` and `find` to read state; take a `screenshot` when the result is visual or when the user needs evidence.
- Check `console` for errors and `requests` for failed calls whenever a behavior does not match expectations.
- State each expectation before acting, then record pass or fail with the evidence that proves it.
- **Project suites:** if the project already depends on `@playwright/test` and the request is to run its tests, run them instead of driving the CLI: `PLAYWRIGHT_HTML_OPEN=never npx playwright test`, adding `--headed` only under the rule in Section 2. Never add `@playwright/test` to a project without the user's approval: it is a new dependency.

### Safety

- Never type credentials, tokens, or other secrets, and never read them from files to fill a form. Authentication belongs to the user (Section 2).
- Do not perform irreversible actions on real accounts or production data (purchases, deletions, outbound messages) without explicit confirmation.

## 5. Close and Report

- Close the session when done, including when a step failed or the test was aborted: `playwright-cli -s=<session> close`. Headed sessions never time out on their own. If a session is stuck, `playwright-cli list` shows it; use `kill-all` only with the user's approval, since it ends other agents' sessions too.
- Report to the user, in their language: what was tested, the mode, each expectation with pass or fail, and the paths of screenshots or traces. Those paths are local: to share evidence in a PR or issue, upload it as an attachment and do not cite the path.

## 6. Success Validation

- [ ] `playwright-cli` was present, or its absence was reported and installed only with approval.
- [ ] The mode was headless unless the user explicitly asked to watch the browser.
- [ ] Every command used the same unique session name; no file was written inside the repository.
- [ ] Each expectation was stated and has a pass or fail backed by evidence.
- [ ] No secret was typed, and no irreversible action ran without confirmation.
- [ ] The session was closed and the user received the report.
