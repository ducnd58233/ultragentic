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

Specification: what is being built or changed, and how a person will know it works.

<abstract>

<!-- FILL: two to four sentences. The objective, who it is for, and the one result that means done. A reader who stops here must know what this spec commits to. -->

</abstract>

<context>

## Objective

<!-- FILL: the user, the problem, and why now. -->

## Assumptions

<!-- FILL: numbered A1, A2, ... so a later failure trace can cite them. Write "None." if there are none. -->

## Stack and commands

<!-- FILL: frameworks named only after reading the repo's manifests, and the real commands to build, test, and run. -->

</context>

<scope>

## In scope

<!-- FILL: bullet list. -->

## Out of scope

<!-- FILL: bullet list. Naming what is excluded prevents scope creep. -->

## Boundaries

<!-- FILL: Always / Ask first / Never (schema changes, new dependencies, CI, secrets). -->

</scope>

<requirements>

## Requirements

<!-- FILL: one row per requirement. Each is a statement that is either true or false. -->

| ID | Requirement | Priority |
|----|-------------|----------|
| R1 | FILL: one checkable statement | must |

</requirements>

<verification>

## Success criteria

<!-- FILL: each criterion names the command, test, or observation that proves it. "Looks good" is not a criterion. -->

| ID | Criterion | How it is checked |
|----|-----------|-------------------|
| SC1 | FILL: what must be true | FILL: command, test, or file to open |

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
