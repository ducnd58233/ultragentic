---
description: Deep analysis with metacognition over a cited evidence set before a confidence-labeled recommendation
---

Turn a research digest or evidence set into a decision after a metacognition pass: sufficiency, conflicts, and counter-evidence, then a cited comparison and recommendation.

<references>

Follow [`evidence-based-analysis`](../skills/evidence-based-analysis/SKILL.md). Metacognition pattern from deep-work research: monitor → evaluate → plan before recommend. Host matrix: [`deep-work-host-matrix.md`](../references/deep-work-host-matrix.md). Persona: [`data-analyst`](../agents/data-analyst.md).

</references>

## Inputs

<inputs>

- Existing RESEARCH digest or scoped evidence set (required)
- Decision objective and constraints

</inputs>

## Required output

<outputs>

1. Metacognition notes: knowledge sufficiency, conflicts across sources, reasoning risks
2. Comparison table with Source column
3. Recommendation with alternatives and dissent
4. Confidence per conclusion (`HIGH` / `MEDIUM` / `LOW` / `UNVERIFIED`)

Optional: spawn one parallel critique agent (host subagent or job) that only attacks the leading recommendation before it is finalized.

</outputs>

## Routing & discovery

<routing>

- Use when analysis must go deeper than [`analyze.md`](analyze.md) (conflicts, sufficiency gaps, or adversarial critique).
- Do not use when source collection is incomplete; run [`deep-research.md`](deep-research.md) or [`research.md`](research.md) first.

</routing>
