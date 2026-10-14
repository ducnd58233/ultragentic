---
name: deep-research
description: >-
  Runs multi-angle deep research with parallel retrieve, adversarial claim
  voting, and a cited digest. Use for deep research, deep dive, or
  cross-checked literature that needs more than a single research pass. Prefer
  Claude Code native /deep-research when that host supports workflows; otherwise
  emulate the phases on every ultragentic inventory host.
disable-model-invocation: true
---

# Deep research

## How

<procedure>

1. **Scope** - Restate the question, sub-questions, and must-have evidence types. Name at least three independent research angles.
2. **Prefer host-native** - On Claude Code with dynamic workflows available (v2.1.154+ per vendor docs), invoke the host `/deep-research` workflow and skip to step 7 for the digest handoff. Matrix: [`deep-work-host-matrix.md`](../../references/deep-work-host-matrix.md).
3. **Plan** - Write a short multi-angle plan. Persist it (docs note or run folder) before fan-out so truncation does not lose the plan.
4. **Fan-out** - Spawn one worker per angle in parallel (host subagents, Task tool, or `ultragentic job start --slug <slug> --host <client> -- ...`). Each worker searches, fetches primary sources, and returns claims with URLs.
5. **Claim vote** - For each material claim, run an independent verify pass (second agent or second fetch). Keep claims that survive cross-check; mark failures as `UNVERIFIED` or drop them. Do not treat rate-limit gaps as refutations.
6. **Synthesize** - Merge surviving claims into one digest. Conflict stays conflict with both citations.
7. **Write** - Create the digest with `ultragentic docs new RESEARCH --slug <slug> --title "<question>"` (or revise an existing RESEARCH). Include Applicability, Refine (with Methodological gap and Cross-domain mechanisms), Mermaid, and Sources. Pass `ultragentic docs check`, `check-citations`, `check-claims`, and `check-dots`.
8. **Long runs** - Keep `experiment/STATUS.md` or the job ledger current (`running` → `done`/`failed`). Wait with `ultragentic job wait`, never a polling loop. No new evidence source and no `deep_research_phases` check key.

Pair with [`research-with-citations`](../research-with-citations/SKILL.md) for citation rules and [`scientific-ideation`](../scientific-ideation/SKILL.md) for Gap Finder / Innovator under Refine. For a decision after the digest, use [`deep-analyze`](../../commands/deep-analyze.md) / [`evidence-based-analysis`](../evidence-based-analysis/SKILL.md).
</procedure>

## Routing & discovery

<routing>

- Use when: deep research, multi-source cross-check, claim voting, long literature fan-out.
- Avoid when: a single-pass `/research` digest is enough, or the task is product `/goal` ship without a research question.
- Command: [`deep-research.md`](../../commands/deep-research.md)
</routing>

## Permissions & authority

<required>

- Tools: WebSearch, WebFetch, Read, Grep, host subagent/Task, Shell for `ultragentic docs` and `job`
- Authority: write docs under `docs/` via docs commands; no fifth evidence provenance
</required>
