# UI review checklist

<context>

Mechanical review list for UI diffs. Use from [`/review`](../commands/review.md) or
[`product-design-reviewer`](../agents/product-design-reviewer.md). Pair with
[`ux-taste.md`](ux-taste.md) and [`accessibility-checklist.md`](accessibility-checklist.md).

</context>

## Before merge

<verification>

### Registry and tokens

- [ ] Colors, spacing, type use project tokens or documented exceptions
- [ ] New primitives only when no registry component fits (stated in the PR)
- [ ] No raw hex/rgb that should be a token (runtime `design-token-guard` when available)

### Hierarchy and layout

- [ ] First viewport has one clear job; secondary content is below or behind
- [ ] Headings form a single logical outline; no skipped levels for style
- [ ] Primary CTA is obvious; competing actions are demoted

### States

- [ ] Empty, loading, error, and disabled states exist for new interactive surfaces
- [ ] Errors are recoverable; empty states name the next step
- [ ] Layout does not jump when async content arrives

### Taste / anti-slop

- [ ] No default purple/cream/broadsheet kits unless they are the brand
- [ ] No decorative card clusters or glow stacks that add no information
- [ ] Emotion and motion serve hierarchy, not noise

### Accessibility

- [ ] Keyboard path works for new controls; focus visible
- [ ] Icon-only controls have accessible names
- [ ] Contrast meets WCAG 2.1 AA for text and critical controls

### Evidence

- [ ] Render or screenshot evidence attached for visual changes
- [ ] Deterministic gates run when the skill requires them (`ui-slop-guard`, a11y checks)

</verification>

## Related

<routing>

- Taste detail: [`ux-taste.md`](ux-taste.md)
- Generation loop: [`ui-design-fidelity`](../skills/ui-design-fidelity/SKILL.md)
- A11y depth: [`accessibility-checklist.md`](accessibility-checklist.md)

</routing>
