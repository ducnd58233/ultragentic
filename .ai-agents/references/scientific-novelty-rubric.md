# Scientific novelty rubric (advisory)

<context>

Advisory scoring dimensions for research proposals before `experiment_run`.
Inspired by IdeaScientist-style novelty axes. **Not** checkpoint evidence: do
not record a judge score as `Passed`, and do not add an LLM-as-judge verifier.

</context>

## Dimensions

| Dimension | Question | High when |
|-----------|----------|-----------|
| All-field novelty | Would a broad expert call this new? | Claim is not a restatement of a well-known result |
| Same-domain novelty | Is it new inside the topic's field? | Closest prior differs in method or claim, named explicitly |
| Mechanism non-obviousness | Is the transfer or mechanism non-obvious? | Cross-domain mechanism is not the default baseline in-domain |

## How to use

1. After Gap Finder and Innovator passes, score each dimension 1–5 with a one-line reason.
2. Keep scores in RESEARCH Refine or a proposal note; they guide iteration only.
3. Proceed to experiment design only when central novelty, closest prior, and falsifiable predictions are written (see idea-proposal schema).

## Non-goals

- No automatic gate on numeric thresholds.
- No dependence on Svalbard Idea Vault or similar training corpora inside ultragentic.
