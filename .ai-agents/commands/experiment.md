---
description: Run or advance a host/CI experiment and keep STATUS.md current until done or failed
---

Execute or advance one research experiment on **host or CI compute**, and keep the run's STATUS file honest so `researcher-delivery` can monitor continuously.

<references>

Follow [`researcher-harness`](../skills/researcher-harness/SKILL.md).

Graph: [`researcher-delivery`](../graphs/researcher-delivery.yaml).

MCP: `ua_experiment_status` reads STATUS; it does not start a sandbox.
</references>

## What

<context>

- **Inputs:** experiment PLAN/TASKS for the slug; host commands or CI jobs the plan names.
- **Outputs:** updated `.agent-state/runs/<date>/<slug>/<version>/experiment/STATUS.md` and any logs the plan requires.
- **Non-goal:** in-process GPU or container sandbox (declined by charter). Use host/CI.
</context>

## STATUS.md contract (MUST)

<required>

Write this file under the run directory:

```markdown
# Experiment status
status: running
updated: <RFC3339>
note: <short progress>
```

Allowed `status` values: `running`, `done`, `failed`.

Update it whenever progress changes. The `experiment_monitor` verifier fails while `running` (or missing) and passes on `done` or `failed` **only when a `judgement:` line is also present and recognized** (added below `status:`), **and** the terminal file cites at least one existing evidence file under the experiment folder:

```markdown
judgement: confirmed
evidence: logs/checker-runs.log
```

Repeat `evidence:` for each backing artifact. A terminal STATUS with no existing evidence path fails the same way a missing `judgement:` does: STATUS cannot pass on bare self-claim. Running status needs no evidence yet.

Allowed `judgement` values, stated once the run is terminal:

| Value | Means |
|---|---|
| `confirmed` | The observed result matches the hypothesis/assumption this run was testing. |
| `refuted` | The observed result contradicts it. |
| `inconclusive` | The run finished but the evidence does not clearly support or contradict it. |
| `not_applicable` | There was no hypothesis to score against (a reproduce-and-fix cycle, not a research experiment). |

`not_applicable` is a legitimate answer, not a workaround: the point is stating whether a judgement
was made, never inventing one against a hypothesis that was never there. A terminal status with no
`judgement:` line, or one with a value outside this list, fails `experiment_monitor` the same way a
missing `status:` line always has - this is not a new evidence source, it is the same STATUS.md
contract the verifier already gates, asking one more honest question before it calls the file done.

When `status` becomes `done`, also write `experiment/METRICS.json`:

```json
{
  "metrics": {"ndcg_at_10": 0.84},
  "thresholds": {"ndcg_at_10": {"op": ">=", "value": 0.82}},
  "evidence": {"ndcg_at_10": "logs/ndcg.txt"}
}
```

The `results_eval` verifier compares metrics to thresholds and requires an `evidence` map: each threshold name points at an existing file under the experiment folder. Values below the bar route the graph back to `hypothesis` without human approval. A metrics map without evidence paths fails as self-claim.

`METRICS.json` also carries an `integrity` block, and the verifier fails a file that has none. A run that fits or tunes a model, a prompt, or a rule and reports a number from held-out data writes:

```json
"integrity": {
  "kind": "held_out_eval",
  "selectionSplit": "validation",
  "reportedSplit": "test",
  "selectionMetrics": {"ndcg_at_10": 0.86},
  "maxGap": {"ndcg_at_10": 0.03},
  "trials": 14,
  "reportedSplitEvaluations": 1
}
```

A run with no model, split, or tuning step (a reproduce-and-fix cycle, a closed-form check) writes `{"kind": "not_applicable", "reason": "<why>"}`; a blank reason fails. The verifier fails a gap larger than `maxGap` in either direction, a reported split scored more than once, and a selection split equal to the reported one. Schema: [`experiment-run.schema.json`](../../schemas/experiment-run.schema.json).

**Comparing this run against earlier iterations (not just gating this one):** this STATUS.md/METRICS.json pair is scoped to the current graph run and stops mattering once it finishes. To keep a comparable record across many iterations for a paper, report, or competition writeup, also write `experiments/<project-slug>/<run-id>/` per [`researcher-harness`](../skills/researcher-harness/SKILL.md) section "Experiment ledger, across runs".
</required>

## Integrity (MUST)

<required>

Rules and reasons: [`research-integrity`](../references/research-integrity.md). The ones that bind this command:

- **Run the frozen PLAN.** Splits, metric, thresholds, `maxGap`, and trial budget come from the approved PLAN's Evaluation protocol. Copy them into `METRICS.json`; do not choose them after seeing a result.
- **Never edit the evaluator to pass.** No change to metric code, a grader, a threshold, labels, the eval set, or a test in the change that produces the result.
- **Count, do not recall.** `trials` and `reportedSplitEvaluations` come from the experiment ledger (`experiments/<project-slug>/`), counting failed and abandoned runs.
- **Report coverage.** Samples skipped by an error or timeout are reported as evaluated over total, not dropped from the average.
- **An `INTEGRITY:` failure is not a miss to retry.** Looping to `hypothesis` re-scores the reported split. Correct the record if it was wrong, re-split or bring fresh held-out data if the split is spent, or stop and ask a person. Never record it as `checkpoint --blocker`, and never re-run until it passes.
</required>

## How

<procedure>

1. Read PLAN Mermaid, Evaluation protocol, Data and terms, and TASKS acceptance criteria.
2. Run the next host/CI step the plan names. Anything longer than a few seconds (training, an
   evaluation sweep, a long suite) starts as a runtime job, never as a script you watch yourself:

   ```sh
   ultragentic job start --slug <slug> --host <client> -- <command> <args>...
   ```

   It returns at once, records the job under the run, and prints the one wait step for your host.
3. Refresh STATUS.md before returning.
4. Call `ua_verify` at `experiment_monitor`. It fails while a job the run started is still running,
   whatever STATUS.md says, and names the wait command.
</procedure>

## Watch it to completion (MUST)

<required>

Wait with the runtime, not with your turns. Do not write a sleep loop, a `watch`, a polling script, or
a scheduled re-check: each check is a model turn that learns nothing, and the workspace research run
`long-job-watch` measured the cost (FINDINGS R2).

```sh
ultragentic job wait <id> --slug <slug>                   # blocks until the job ends, exits with its code
ultragentic job wait <id> --slug <slug> --timeout 25m     # same, but returns 124 if still running
ultragentic job status <id> --slug <slug>                 # one reading, no wait
```

How to wait depends on the host. `job start --host <client>` prints the right form; the runtime's host
table records which hosts report a background command's end.

| Host | How to wait | What happens |
|---|---|---|
| Claude Code | Run `ultragentic job wait` as a background command and end the turn | The host tells you once when the job ends; the Stop hook does not block a run whose job is running |
| Every other host | Run `ultragentic job wait --timeout 25m` in the foreground | It returns when the job ends; on exit 124 run the same command again |

When the wait returns, read its exit code and log tail, update STATUS.md (`done` or `failed`, with a
`judgement:` line), and call `ua_verify`. A job whose supervisor died without an exit record is
reported as lost: start it again with `job start`, do not mark it done.

On hosts without an end-of-turn hook (opencode; see
[`host-hook-contracts.md`](../references/host-hook-contracts.md)), nothing catches an abandoned turn:
run the bounded foreground wait until the job ends rather than ending the turn on one reading.

This is the same obligation [`auto.md`](auto.md)'s "Auto research host obligation" states for the
rest of the research/experiment loop; this is the one node in that loop where real wall-clock time,
not just another artifact, stands between here and terminal.
</required>

## Routing & discovery

<routing>

- Use when the run is on `experiment_run` in `researcher-delivery`.
- Do not use for product `/build` work on `goal-delivery`.
</routing>
