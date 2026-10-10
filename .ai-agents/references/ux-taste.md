# UX taste (hierarchy, states, anti-slop)

<context>

Compact taste checklist for agent-built UI. Use with [`/design`](../commands/design.md) and
[`ui-design-fidelity`](../skills/ui-design-fidelity/SKILL.md). Registry and tokens win over this file;
this file is what to check when the screen already compiles but still feels generic.

</context>

## Hierarchy

<references>

- One job per viewport or section: one headline, one short support line, one primary action group.
- Brand or product name must read as a hero-level signal on branded surfaces; nav text alone is not enough.
- Prefer one composition over a dashboard of cards, chips, and stat strips unless the product is a dashboard.
- Real visual anchor when imagery matters: product, place, or context - not only a flat wash or abstract glow.

</references>

## Interaction states

<verification>

Every interactive surface needs explicit states, not only the happy path:

| State | Expectation |
|-------|-------------|
| Empty | Say what is missing and the next action (not a blank panel) |
| Loading | Stable skeleton or status; do not jump layout when content arrives |
| Error | Recoverable message + retry or alternate path |
| Disabled | Visible reason when the primary action cannot run |
| Success | Quiet confirmation; do not steal focus with celebration chrome |

</verification>

## Anti-slop

<references>

Avoid the defaults models regress to unless the project registry already uses them:

- Purple-on-white or purple-to-indigo gradient themes as a stand-in for brand
- Warm cream + terracotta + serif display as a default "tasteful" kit
- Broadsheet hairlines, zero radius, dense newspaper columns as decoration
- Pill clusters, multi-layer glow shadows, emoji as section markers
- Card chrome (border, shadow, radius) when removing them does not hurt understanding

Prefer project tokens, existing components, and evidence from
[`ui-design-fidelity`](../skills/ui-design-fidelity/SKILL.md) gates over new aesthetic invention.

</references>

## Related

<routing>

- Skill loop: [`ui-design-fidelity`](../skills/ui-design-fidelity/SKILL.md)
- Structure and a11y: [`frontend-ui-engineering`](../skills/frontend-ui-engineering/SKILL.md)
- PR checklist: [`ui-review-checklist.md`](ui-review-checklist.md)
- Registry contract: [`ui-component-registry.md`](ui-component-registry.md)

</routing>
