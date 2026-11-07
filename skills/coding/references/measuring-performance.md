# Measuring Performance

> **Central thesis**: a number is evidence only when you know what limits it and have ruled out that it measured something other than the work. Before trusting, reporting, or acting on a speedup, regression, throughput, or latency, explain the number.

---

## When to consult

- Before running a benchmark, and before reporting or acting on a performance number you measured.
- When an optimization is proposed or its effect is claimed.

---

## 1. Before Running

- **Write the claim you expect to make**, in the words you would ship ("export is 30% faster at p50 on the 60k-row dataset"), and the result that would change a decision. The questions below test that sentence.
- **Read the measurement script**: what it times, counts, and ignores.
- **Check that the machine is quiet**. If it is not and you cannot stop the load, alternate the sides so both see the same noise, and say so.

## 2. The Questions

Answer each with evidence from a run, not from reading the code.

1. **Why not double?** Name the limiter (a core, a lock, the disk, the network, the load generator itself) from a profile or system counters taken in a run you do not report, then map it to source. If you cannot say why the number is not twice as good, you do not know what you measured.
2. **Was each side tuned?** Run every side the way production runs it: release build, production flags, pools, caches, versions, and data. A side on defaults compares configurations, not implementations.
3. **Did it break a limit?** Do the arithmetic against bandwidth, cores, and the share of time the changed piece took: removing a piece that takes 10% of the run makes it at most about 11% faster. A result past a limit measured a cache, a no-op, or a bug.
4. **Did it error?** Count failures and check that outputs are correct, not just present: rejections are fast, timeouts are slow.
5. **Does it reproduce?** Run each side at least 5 times, alternating, and report the median and range. A gap smaller than the run-to-run spread is no measurable difference.
6. **Does it matter?** Measure the end-to-end path a user waits on with realistic sizes, and report a micro result as its share of the whole.
7. **Did the work happen?** Confirm it ran inside the timed region: lazy code, unawaited promises, discarded results, and timeouts produce numbers for work that never happened.

A quick ballpark the user asked for may be one run: still answer questions 4 and 7, and say it is one run.

## 3. Report

- Lead with the verdict: faster, slower, no measurable difference, or inconclusive.
- Give the number with its unit, run count, range, and limiter: "p50 41 ms → 33 ms, median of 7 runs per side, range 32 to 35 ms, bound by JSON parsing on one core".
- Call it inconclusive when the limiter is unknown, a side ran untuned, or questions 4 and 7 were not checked, and name the gap.

---

## Relationships

- When to optimize at all: [refactoring-principles.md](refactoring-principles.md) (Section 6).
- Presenting the number as delivery evidence: [`provide-evidence`](../../provide-evidence/SKILL.md).
