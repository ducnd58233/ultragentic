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

Plan: how the SPEC in this folder will be delivered, in what order, and what could go wrong.

<abstract>

<!-- FILL: two to four sentences. The approach in one line, the number of phases, and the riskiest step. -->

</abstract>

<approach>

## Approach

<!-- FILL: components, dependencies, and the order they are built in. Say which work is parallel and which is sequential. -->

## Phases

| Phase | Delivers | Checkpoint |
|-------|----------|------------|
| 1 | FILL: what exists at the end of this phase | FILL: how it is checked before the next phase |

</approach>

<risks>

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| FILL: what could go wrong | FILL: low, medium, or high | FILL: what reduces it |

</risks>

<verification>

## Verification

<!-- FILL: the commands and checks that prove the plan delivered the SPEC's success criteria. For an experiment design, add "## Evaluation protocol" and "## Data and terms" headings and a mermaid diagram here; the design gate reads them. -->

</verification>

<revisions>

## Revisions

Appended by `ultragentic docs revise <this file> "<what changed>"`. Do not edit dates by hand.

| Date | Change |
|------|--------|
| ${date} | Created. |

</revisions>
