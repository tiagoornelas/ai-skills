# Mermaid Rendering

Only for a destination that renders Mermaid (a PR or issue body, repository docs, an artifact). The drawing keeps the shape and rules of the terminal one: the same columns, the same product-term labels in the user's session language, the same steps, and color only on detours.

## 1. Swimlanes as a Sequence Diagram

- One `participant` per column, declared in the terminal order; the person acting is an `actor`.
- Steps: a `Note over` the first column carrying the step number, where the reader's moment starts.
- A stop: an `alt` branch inside a red `rect`. A retry, a wait, or a flag: a `loop`, `opt`, or `Note` inside a yellow `rect`. Nothing else is colored.

```mermaid
sequenceDiagram
  actor U as User
  participant W as Web app
  participant A as Billing API
  participant D as Database
  participant J as PDF job
  Note over U: 1
  rect rgb(255, 243, 205)
    Note over W: only if the flag is on
  end
  U->>W: Export
  W->>A: asks for the PDF
  rect rgb(248, 215, 218)
    alt unpaid invoice
      A-->>W: refused
    end
  end
  A->>D: saves the export (pending)
  A-->>W: accepted
  Note over U: 2
  A->>J: render the PDF
  rect rgb(255, 243, 205)
    loop up to 3 tries
      J->>J: renders
    end
  end
  J->>D: stores it (ready)
  Note over U: 3
  rect rgb(255, 243, 205)
    loop every 5 s until ready
      W->>A: asks for the status
    end
  end
  A-->>W: link to the PDF
  W-->>U: download
```

## 2. States as a State Diagram

- One state per state the user sees, named as the user sees it; transitions carry what moves the state.
- A state the flow ends in gets the `stop` class; a state that retries or waits gets `detour`.

```mermaid
stateDiagram-v2
  state "no PDF" as noPdf
  state "preparing" as preparing
  state "ready to download" as ready
  state "failed" as failed
  state "refused" as refused
  [*] --> noPdf
  noPdf --> preparing: clicks Export
  preparing --> ready: PDF stored
  preparing --> failed: fails 3 times
  failed --> preparing: Try again
  preparing --> refused: unpaid invoice
  classDef stop fill:#f8d7da
  classDef detour fill:#fff3cd
  class refused stop
  class failed detour
```

## Success Validation

- [ ] The Mermaid drawing has the same columns, labels, and steps as the terminal one would, in the user's session language.
- [ ] Only stops (red) and retries, waits, or flags (yellow) are colored.
- [ ] No method, class, file, endpoint, or table name appears.
