# Concise docs

<context>

Owner of the size rules for every file under `.ai-agents/` and the charters. Short-context models lose rules in long inputs, so a file an agent loads must be as short as it can be without losing a rule. Evidence and measurements: `docs/research/how-deal-short-context/RESEARCH.md`.
</context>

## Budgets (MUST)

<rules>

Counted in bytes with CRLF as LF. Checked by `ultragentic docs budget`, `ultragentic doctor` and pre-commit.

| What | Limit |
|---|---|
| Charter files together (`AGENTS.md`, `CLAUDE.md`, `CURSOR.md`, `MISTAKES.md`) | 33,000 |
| One charter file | 24,000 |
| One skill, command, agent, reference or profile | 16,000 |

A file already over its limit is recorded in `.ai-agents/size-baseline.json` and must not grow. A new file must start within its limit. Lower an entry with `ultragentic docs budget --tighten`; raising one is a reviewed edit, never a command.
</rules>

## Writing (MUST)

<rules>

1. One rule per bullet, the rule first and its reason after, in one sentence.
2. State a rule once. Link to its owner instead of restating it.
3. Put the rules that must always hold at the top or the end of a file, never in the middle.
4. Prefer a command, a number, or a table to a paragraph.
5. No history, no changelog, no "previously". The file says what is true now.
6. Detail needed only for one task goes in an on-demand reference. Leave a one-line pointer with its trigger ("before writing under `docs/`, read ...").
7. Every section earns its place: if no check, command or decision depends on it, cut it.
</rules>

## When a file is over budget

<procedure>

1. Move whole per-task sections, unchanged, to an on-demand reference. See [`charter-detail.md`](charter-detail.md) for the pattern.
2. Replace each with one pointer bullet naming when to read it.
3. Update the folder `ROUTER.md`, run `ultragentic docs budget --tighten`, then `ultragentic doctor`.
</procedure>
