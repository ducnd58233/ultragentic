# Workspace mistakes log

<context>

A plain markdown diary of agent failures and human corrections for the **current workspace**.
No tooling, no plugin, no vector store. Complements (does not replace) `.agent-state/memory.db`.

Two files share the name. This document describes the **draft diary** at
**`.agent-state/MISTAKES.md`**; the tracked **`MISTAKES.md`** at the repository root, next to
`AGENTS.md`, holds only the reviewed rules graduated from it. Every charter names the root file, the
runtime injects its rules at session start, and `ultragentic doctor` fails when a root file exists that
no charter names. Graduate with `ultragentic mistakes graduate --class <class> --rule "<rule>"`.

Path: **`.agent-state/MISTAKES.md`** at the workspace root (gitignored with the rest of
`.agent-state/`). Create the file on first append. Do not commit it.

Why the drafts are not tracked: consumer checkouts would accumulate agent noise in PRs, so the diary
stays workspace-local the same way runs and `memory.db` do. Only a rule worth every checkout seeing is
tracked, in the root `MISTAKES.md`, which every harness is pointed at.
</context>

## When to write

<rules>

Append an entry when any of these happen:

- You broke a test, build, or verification the workspace already had green
- A human corrected a wrong approach, assumption, or edit
- You repeated a known failure after reading this log or `AGENTS.md`

The runtime writes a draft entry itself, with a `check-<name>` or `blocker-<class>` class, whenever
`ultragentic checkpoint` or `ultragentic verify` records a failed check or a blocker, so those cases
need no model memory. The draft says the cause is not yet diagnosed: replace its **Root cause** and
**Prevention** lines in place instead of adding a second entry. Entries are de-duplicated per run, node
and class. Write an entry by hand only for what the runtime cannot see, such as a human correction.

Do **not** log routine first-attempt failures that were fixed in the same turn with no lasting
lesson. Do **not** put credentials, tokens, or personal data in the log; redact first
([`sensitive-data-exposure.md`](sensitive-data-exposure.md)).
</rules>

## Entry format (MUST)

<required>

Newest entry **first** (prepend below the title). One entry:

```markdown
## YYYY-MM-DD — short title

- **What happened:** …
- **Root cause:** …
- **Consequence:** …
- **Prevention:** the rule that would have stopped this (one sentence)
- **Class:** short kebab tag for counting repeats (e.g. `tasks-ac-checkboxes`, `forged-human-event`)
```

Optional: `**Related:**` run slug, PR number, or file path (workspace-relative).
</required>

## Graduation into MISTAKES.md

<rules>

When the same **Class** appears **twice** (count entries in this file; `ultragentic memory promotions` lists the classes at the threshold), stop
treating it as diary-only:

1. Run `ultragentic mistakes graduate --class <class> --rule "<rule>"`, which adds one line to the workspace-root **`MISTAKES.md`**. A rule that must also be in the charter itself goes in `AGENTS.md` as a separate reviewed change.
2. Prepend a log entry noting the graduation (what rule, where it landed).
3. Prefer one sharp rule over restating every incident.

Graduation is a tracked charter change. The diary stays local evidence.
</rules>

## Versus runtime memory

<rules>

| | `.agent-state/MISTAKES.md` | `.agent-state/memory.db` |
|--|---------------------------|--------------------------|
| Shape | Human-readable narrative | Propose / confirm / forget records |
| Writer | Host agent (and humans) | Hooks + `ultragentic memory` |
| Reader | Agents skimming before risky work | Session-start / prompt injection |
| Promotion | Repeat class → `MISTAKES.md` rule | Confirm; expiry; forget |

Use the diary for deliberate "we got this wrong; here is the rule." Use memory for machine recall
of command outcomes. Do not copy every memory row into MISTAKES.
</rules>

## Consumer repos

<context>

When this toolkit is mounted in a consumer workspace, the log path is still
**`<workspace>/.agent-state/MISTAKES.md`**, not inside the toolkit checkout. Graduated rules go into
the **consumer** `MISTAKES.md`, named from the consumer `AGENTS.md`, in plain policy text with no toolkit paths, under local-first precedence (root [`AGENTS.md`](../../AGENTS.md)).
</context>
