---
description: Multi-angle deep research with claim voting and a cited digest; prefers Claude native /deep-research when available
---

Run deep research on a scoped question: multi-angle plan, parallel retrieve, adversarial claim vote, then a cited RESEARCH digest.

<references>

Follow [`deep-research`](../skills/deep-research/SKILL.md). Host paths: [`deep-work-host-matrix.md`](../references/deep-work-host-matrix.md). Citation rules: [`research-with-citations`](../skills/research-with-citations/SKILL.md). Persona: [`research-investigator`](../agents/research-investigator.md).

</references>

## Inputs

<inputs>

- Research question (required)
- Optional scope (time range, source types, must-include domains)
- Optional slug (otherwise derived)

</inputs>

## Required output

<outputs>

1. Multi-angle plan (at least three angles)
2. Claim table or section with vote outcome (kept / UNVERIFIED / dropped)
3. RESEARCH digest via `ultragentic docs new` with Applicability, Refine, Mermaid, Sources
4. `docs check` + `check-citations` + `check-claims` + `check-dots` all ok

On Claude Code with workflows, the host `/deep-research` report may be the retrieve+vote engine; still land the digest under `docs/` with ultragentic docs commands so gates can read it.

</outputs>

## Runtime

<required>

```sh
ultragentic doctor
# long fan-out:
ultragentic job start --slug <slug> --host <client> -- <retrieve command>
ultragentic job wait <id> --slug <slug>
```

Do not invent `human_event` or a `deep_research_phases` check. Evidence stays `exit_code` / `file_assert` / `ci_api` / `human_event` only.

</required>

## Routing & discovery

<routing>

- Use when the user asks for deep research, deep dive, or cross-checked multi-source investigation.
- Prefer over [`research.md`](research.md) when a single-pass digest is not enough.
- After the digest, decisions use [`deep-analyze.md`](deep-analyze.md) or [`analyze.md`](analyze.md).

</routing>
