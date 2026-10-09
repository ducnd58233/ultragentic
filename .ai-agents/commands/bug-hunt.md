---
description: Write bug_hunt/FINDINGS.md on the auto path after e2e, then verify bug_hunt_ok
---

On the auto delivery path, after e2e and before slop, record bug-hunt findings.
Evidence is a markdown file; the runtime only `file_assert`s it. Compute stays
in consumer CI or an external runner; the runtime does not own a sandbox.

<references>

Graph node: `bug_hunt` in [`goal-delivery.yaml`](../graphs/goal-delivery.yaml).

Check: `bug_hunt_ok` in workspace `ua-checks.yaml`.

Research basis: `sau-khi-merge-ci` experiment `BUG-HUNT-SKETCH.md`.
</references>

## When

<routing>

- Use when the run is on `bug_hunt` (auto path only).
- Host may run fuzz/property/SWE jobs first; this command only records the verdict file.
</routing>

## FINDINGS.md contract (MUST)

<required>

Write:

`.agent-state/runs/<date>/<slug>/<version>/bug_hunt/FINDINGS.md`

```markdown
# Bug hunt
status: pass
attempt: 1

| Case | Evidence | result |
|------|----------|--------|
| race: shared cache map | go test -race ./cache ok (scan race) | pass |
| injection: report query | placeholders only; TestReportRejectsQuote | pass |
| secrets | gosec G101 clean (scan gosec) | pass |
```

One row per class the workspace declares (below), each citing a scan, a test, or why the class does
not apply. "none new" is not a row for a class.

Same pass/fail and soft-cap rules as [`expectation.md`](expectation.md).

```sh
ultragentic verify --slug <slug>
```

Pass continues to `slop`. Fail reopens `plan`.
</required>

## Scans the runtime runs (MUST, when declared)

<required>

A findings file is the agent's own account of its work, and on its own it passed whatever the code
held: in workspace research run `runtime-enforced-agent-reliability`, `ultragentic review scan`
caught 0 of 10 seeded critical defects, and `go vet` plus gosec caught 4. So the workspace declares
what must run, and the `bughunt` verifier runs it:

```yaml
# ua-checks.yaml
spec:
  checks:
    bug_hunt_ok:
      verifier: bughunt
      scans: [vet, gosec, race]          # other checks below; each must exit 0
      classes: [race, injection, secrets, leak, resources]   # FINDINGS.md needs a row for each
    vet:
      command: go
      args: [vet, ./...]
    gosec:
      command: gosec
      args: [./...]
    race:
      command: go
      args: [test, -race, ./...]
      requires: [gcc]                    # the race detector needs cgo; doctor fails without it
```

- Do not write a findings row instead of running a declared scan. The verifier runs it and its exit
  code decides; a failing scan fails `bug_hunt_ok` whatever the file says.
- `ultragentic doctor` fails while a declared scan's command or `requires` program is missing.
  Install it, or ask a person to change the plan; do not drop the scan to get past it.
- Scanners miss most of these classes (gosec and `go vet` missed string-built SQL, a map race, a
  goroutine leak and an unbounded pool in the same run), so a clean scan is not a clean class: the
  class row still cites a test or a reason.
- Pick scanners for the repository's languages from the stack profile, citing each tool's own
  documentation; [`backend-golang`](../stack-profiles/backend-golang.md) has the Go set above.
</required>
