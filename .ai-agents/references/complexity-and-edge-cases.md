# Complexity and edge/worst-case cases

<context>

One shared obligation for code-change paths: `/build`, `/review`, `/simplify`
([`code-simplify.md`](../commands/code-simplify.md)), and refactor work under
[`code-simplification`](../skills/code-simplification/SKILL.md),
[`engineering-principles`](../skills/engineering-principles/SKILL.md), and
[`karpathy-guardrails`](../skills/karpathy-guardrails/SKILL.md).

Commands and skills **link here**. Do not copy this body into four places.

Sibling for web/API runtime metrics:
[`performance-checklist.md`](performance-checklist.md). That file does not own
algorithm Big-O on code-change paths.

</context>

## When this applies

<routing>

**MUST apply** on non-trivial algorithm, data-structure, loop, collection, or
concurrency changes (new or changed hot paths, indexing, caching, parsing,
graph/walk, search/sort, batching).

**Do not** add Big-O ceremony for trivial one-line fixes, renames, comment-only
edits, or pure wiring with no data-dependent cost. Prefer
[`engineering-principles`](../skills/engineering-principles/SKILL.md) YAGNI and
[`karpathy-guardrails`](../skills/karpathy-guardrails/SKILL.md) simplicity.

</routing>

## MUST checklist

<required>

On every change this file applies to:

### Time complexity

- [ ] Prefer a better time class when it matters and tradeoffs allow (for example
      O(n) over O(n^2) on unbounded or user-sized input).
- [ ] When the dominant cost is non-trivial, state brief Big-O (or equivalent) and
      the main tradeoff in the PR, review note, or commit body - not a treatise.

### Space complexity

- [ ] Prefer a better space class when it matters (bounded buffers, streaming,
      avoid holding full datasets when a pass or index suffices).
- [ ] When peak memory is non-trivial, state brief space cost and tradeoff the
      same way as time.

### Edge cases

- [ ] Reason explicitly about empty input, absent/null values, boundaries
      (0, 1, n-1, max), duplicates, unordered input, and other domain edges the
      code claims to handle.
- [ ] Logic and tests cover those edges so behavior does not fail only on the
      happy path.

### Worst-case behavior

- [ ] Reason about adversarial or maximum-size inputs that flip average-case
      assumptions (quadratic collapse, unbounded growth, pathological hash/order).
- [ ] Fail closed or degrade safely under those cases; do not ship "works on
      typical data" as correctness.

</required>

## Review and ship (checkable)

<verification>

Reviewers and `/review` MUST settle these on applicable diffs (Correctness and
Performance axes, or this list by name):

- [ ] Time/space tradeoffs stated when non-trivial; better class preferred where
      it matters
- [ ] Edge cases named and covered (or explicitly out of scope with reason)
- [ ] Worst-case behavior reasoned; no silent failure under those cases

`/ship` treats unchecked items on an applicable code diff as a quality gap to
call out in the decision (GO only when residual risk is acknowledged).

</verification>

## Related

<routing>

- Review skill: [`code-review-and-quality`](../skills/code-review-and-quality/SKILL.md)
- Simplify: [`code-simplification`](../skills/code-simplification/SKILL.md)
- Web/API perf: [`performance-checklist.md`](performance-checklist.md)
- Public Big-O vocabulary: https://en.wikipedia.org/wiki/Big_O_notation

</routing>
