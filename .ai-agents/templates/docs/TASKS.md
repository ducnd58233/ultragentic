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

Task list for this slug. Status lives in each heading, using: queued, in_progress, blocked, done, canceled.

<abstract>

<!-- FILL: one or two sentences. How many tasks, in how many milestones, and which one is first. -->

</abstract>

<tasks>

## Tasks

Group tasks into milestones, each a result a person can check. One task is one pull request in one repository, sized for review: aim under about 300 changed lines and 10 files, and split a task that would grow past that before its pull request opens. The workspace's `spec.sizeBudget` in `ua-checks.yaml`, when declared, refuses larger commits and pull requests.

### T1: FILL: short imperative title  [queued]

**Milestone:** FILL: M1, the result it belongs to. **Repository:** FILL. **Size:** FILL: expected changed lines and files.

**Depends on:** none

**Acceptance criteria:**

- [ ] FILL: one checkable statement
- [ ] FILL: tests or commands that prove it

**Verification:** FILL: the command that checks this task

</tasks>

<revisions>

## Revisions

Appended by `ultragentic docs revise <this file> "<what changed>"`. Do not edit dates by hand.

| Date | Change |
|------|--------|
| ${date} | Created. |

</revisions>
