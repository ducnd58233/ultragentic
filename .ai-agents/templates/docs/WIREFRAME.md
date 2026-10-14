---
type: ${type}
category: ${category}
slug: ${slug}
title: ${title_yaml}
description: "FILL: one sentence saying what this document answers"
status: draft
created: ${date}
updated: ${date}
---

# ${title}

Wireframe: screen sketches and layout skeletons agreed before UI code. Sketch-first is required; see toolkit/.ai-agents/references/ux-taste.md.

<abstract>

<!-- FILL: two to four sentences. Which surfaces this covers and what "reviewed" means. -->

</abstract>

<context>

## Context

<!-- FILL: product area, users, and constraints. Link SPEC or USERSTORY when they exist. -->

</context>

<screens>

## Screens

<!-- FILL: one subsection per screen. Prefer ASCII or Mermaid sketch; HTML packs are out of scope. Human and agent MUST review sketches before implementation (ux-taste sketch-first). -->

### S1: FILL: screen name

```text
FILL: ASCII or textual skeleton of regions and primary actions
```

</screens>

<verification>

## Verification

<!-- FILL: how sketch review and layout checks are proven (review notes, linked design command, or file_assert paths). -->

| ID | Criterion | How it is checked |
|----|-----------|-------------------|
| SC1 | FILL: sketch reviewed before UI code | FILL: review record or checkbox |

</verification>

<open_questions>

## Open questions

- FILL: one unknown per item, or "None."

</open_questions>

<revisions>

## Revisions

Appended by `ultragentic docs revise <this file> "<what changed>"`. Do not edit dates by hand.

| Date | Change |
|------|--------|
| ${date} | Created. |

</revisions>
