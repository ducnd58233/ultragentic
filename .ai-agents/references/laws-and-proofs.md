---
description: Human-owned laws with machine-checkable proofs on the ultragentic control plane
---

# Laws and proofs

Standing rules that agents must not break, with proofs the control plane can check.

<context>

Laws make standing rules enforceable:

| Piece | Where it lives |
|-------|----------------|
| Human-owned laws | `.ai-agents/laws.yaml` |
| Agent proofs | Check keys in `ua-checks.yaml` |
| Prove-all command | `ultragentic laws check` |
| Never weaken a law to pass | Pre-tool refuse unless `ultragentic: allow-law-change` |

A proof is **closed evidence** (`exit_code` from the checkplan), not a model opinion.

</context>

<procedure>

## Commands

```sh
ultragentic laws init     # write a starter .ai-agents/laws.yaml
ultragentic laws list     # show law ids, statements, proof checks
ultragentic laws check    # run every proof; fail closed on open/fail
ultragentic doctor        # validates the laws plan when present
```

## Authoring rules

1. A person owns `laws.yaml`. Agents may **add** a law; they must not delete or soften an accepted one without the allow marker in the file.
2. Each law names a `check` key that exists in `ua-checks.yaml` and has a runnable command (not `verifier: human`).
3. Before claiming done on work that touches a law's subject, run `ultragentic laws check`.
4. On hosts with hooks, a weaken attempt is refused on `pre-tool-use` (exit 2 or JSON deny per dialect).

</procedure>

<references>

- Runtime: `internal/laws`, `harness` pre-tool gate, `ultragentic laws`
- Related: [`mistakes-log.md`](mistakes-log.md), [`tool-safety-and-permissions.md`](tool-safety-and-permissions.md)

</references>
