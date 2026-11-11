---
name: roostr
description: >-
  Manages scheduled routines, alarms, and background automated workflows for
  local AI coding agents via the Roostr CLI (`roostr`): inspects active jobs,
  schedules recurring tasks across Herdr workspaces, dedicated terminals, or
  background processes, triggers immediate runs, and organizes routine folders.
  Triggered when the user or an agent (coordinator, reflect, automate-me) wants
  to schedule, automate, inspect, or manage recurring local AI routines.
argument-hint: "[routine to schedule, inspect, or run]"
---

# Roostr

Roostr (`roostr`) is the local-first scheduler and software factory alarm for AI coding agents on macOS. It wakes up autonomous agents (PR audits, daily architecture reviews, test suites, triage digests) on preset schedules directly in Herdr workspaces, dedicated terminal emulator windows, or silent background processes.

## 1. Decoupled CLI Discovery

Roostr evolves its CLI interface independently. Discover commands, options, and capabilities dynamically at runtime instead of relying on static assumptions:

- **Top-level help**: `roostr help` or `roostr --help`
- **Topic & command help**: `roostr help job`, `roostr help folder`, `roostr help daemon`, `roostr help history`
- **Subcommand options**: `roostr job create --help`, `roostr job update --help`, `roostr run --help`

Always pass `--json` to inspection and manipulation commands for deterministic machine-readable output.

## 2. Inspecting State

| Need | Command |
| :--- | :--- |
| List all scheduled routines | `roostr job list --json` |
| View detailed config & status of a job | `roostr job show <job_id> --json` |
| View execution history (all or specific job) | `roostr history [job_id] --json [-n <limit>]` |
| List folders and hierarchy | `roostr folder list` |
| Check background scheduler daemon status | `roostr daemon status` |

Parse IDs, schedules, harnesses, and target configurations directly from JSON output.

## 3. Creating and Managing Routines

### Create a Routine

Create routines with `roostr job create`:

```bash
roostr job create \
  --name "<Descriptive Name>" \
  --prompt "<AI prompt instruction>" \
  --harness [claude|antigravity|cursor|codex] \
  --target [herdr|terminal|background] \
  --cwd "<working directory>" \
  --folder "<Folder/Subfolder>" \
  --times "<HH:MM,HH:MM>" \
  --days [weekdays|all|mon,tue,...] \
  --json
```

Key configuration options (confirm current flags with `roostr job create --help`):
- **Action**: `--prompt "<prompt>"` (runs an AI prompt via the specified harness) or `--command "<shell command>"`.
- **Harness**: `--harness [claude|antigravity|agy|cursor|codex]` (defaults to `claude`).
- **Target**: `--target [herdr|terminal|background]`:
  - `herdr`: Opens in Herdr App tab (`--space "<space_name>"` and `--tab-template "{job.name} {DD}/{MM}"`). Requires Herdr App.
  - `terminal`: Launches a visible terminal emulator window (`--terminal-app [auto|terminal|ghostty|iterm2|kitty]`, `--keep-open`).
  - `background`: Headless background execution (`--notify` for desktop notifications).
- **Schedule**:
  - Daily: `--frequency daily --times "08:00,13:30" --days weekdays`
  - Interval: `--frequency interval_hours --interval 4` or `interval_minutes`
  - Tolerance catch-up mode: `--tolerance [window_hours|until_hour|exact] --tolerance-value <n>`
- **Working directory**: `--cwd <path>` defaults to current working directory.

### Modify, Pause, Resume, or Delete

- **Update**: `roostr job update <job_id> [options] --json` (run `roostr job update --help` to confirm options).
- **Pause / Resume**: `roostr job pause <job_id>` and `roostr job resume <job_id>`.
- **Delete**: `roostr job delete <job_id>`.
- **Organize**: `roostr folder create "<Folder/Subfolder>"`, `roostr folder delete "<folder>"`.

## 4. Manual and On-Demand Runs

Execute a routine immediately without waiting for its scheduled time:

- **Run single job now**: `roostr run <job_id> [--force]` (`--force` bypasses schedule/idempotency checks).
- **Run all currently due jobs**: `roostr run --due`.
- Pass `--json` to inspect execution results programmatically.

## 5. Integration with Other Agents

Agents acting as coordinators or reviewers ([`coordinator`](../coordinator/SKILL.md), [`reflect`](../reflect/SKILL.md), [`automate-me`](../automate-me/SKILL.md)):
- **Proposing routines**: When a repetitive workflow, morning triage, daily health check, or recurring review is identified, propose creating a Roostr job rather than relying on manual triggering.
- **Specifying prompt & skills**: Scheduled prompts can invoke skills directly (e.g., `/coordinator ...`, `/improve-architecture ...`, `/human-review ...`).
- **Human approval**: Never create or modify persistent scheduled jobs without presenting the routine (name, schedule, harness, target workspace, and prompt) to the user for explicit approval.

---

## Success Validation

- [ ] Command arguments and flags were verified via `roostr help` or `--help` before invocation.
- [ ] Inspection and query commands used `--json` for deterministic output parsing.
- [ ] Routine targets (`herdr`, `terminal`, `background`) and harness parameters match the user's environment and setup.
- [ ] Scheduled prompts use clear, self-contained instructions or skill invocations.
- [ ] No persistent job was created, modified, or deleted without the user's approval.
- [ ] Successful creation, status change, or run execution was verified via `roostr job show`, `roostr job list`, or `roostr history`.
