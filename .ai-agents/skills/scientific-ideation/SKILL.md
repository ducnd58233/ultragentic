---
name: scientific-ideation
description: >-
  Runs Gap Finder, cross-domain Innovator, and Report Writer checklist passes
  before research proposals harden. Use on researcher-delivery literature and
  Refine when the goal is a novel, grounded scientific or engineering idea,
  not product brainstorming (use idea-refine) and not experiment execution
  (use researcher-harness).
disable-model-invocation: true
---

# Scientific ideation

## How

<procedure>

Three passes, in order. Each leave a short, checkable intermediate in RESEARCH
(or the proposal section of HYPOTHESIS). Do not skip to a polished proposal.

1. **Gap Finder** - From close priors in the *same* domain, name methodological
   limitations that block the challenge. Prefer concrete failure modes (eval
   leakage, missing ablation, wrong unit of analysis) over vague "not studied".
   Write under **Methodological gap**.
2. **Innovator** - Search mechanisms *outside* the topic domain that solve an
   analogous challenge. Record at least one candidate mechanism, its source
   field, and how it could transfer. Write under **Cross-domain mechanisms**.
   Same-domain retrieval alone does not satisfy this pass.
3. **Report Writer** - Assemble a proposal checklist before experiment design:
   - Central novelty (one sentence)
   - Closest prior and how this differs
   - Falsifiable predictions
   - Evaluation sketch and limitations
   - Citation grounding for each non-obvious claim

Score novelty with the advisory rubric in
[`scientific-novelty-rubric.md`](../../references/scientific-novelty-rubric.md).
Scores are for the author; they are not checkplan evidence and must not be
recorded as `Passed` via a judge model.

Compose with [`researcher-harness`](../researcher-harness/SKILL.md) for the
full literature→experiment loop, and with [`research.md`](../../commands/research.md)
so Gap Finder runs before Innovator closes Refine.
</procedure>

## Routing & discovery

<routing>

- Use when literature Refine needs IdeaScientist-style gap and cross-domain passes.
- Pair with [`researcher-harness`](../researcher-harness/SKILL.md) and
  [`research-with-citations`](../research-with-citations/SKILL.md).
- Prefer [`idea-refine`](../idea-refine/SKILL.md) for product brainstorming.
- Do not use to replace experiment integrity, jobs, or evidence gates.
- Do not train on or depend on an external idea vault inside ultragentic.

</routing>

## Permissions & authority

<required>

- Tools: Read, Grep, Glob, WebSearch, WebFetch, Bash for `ultragentic docs` / `calc` only.
- No forging check evidence; no LLM-as-judge verifier writes.
</required>
