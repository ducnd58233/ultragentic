---
name: docs-authoring
description: >-
  Creates, fills, revises, and checks documents under docs/<category>/<slug>/ (SPEC, PLAN, TASKS,
  RESEARCH, HYPOTHESIS, FINDINGS, WRITEUP, STUDY, DECISION, RECORD) with the ultragentic docs
  commands and templates. Use whenever writing or editing any file under docs/, including from
  /spec, /plan, /research, /task, /tutor, /findings, and /goal.
---

# Docs authoring

Every document under `docs/` is made by a command, filled from a template, and checked by a command. Follow the steps; there is nothing to remember beyond them.

## Rules

<required>

1. **Create with `ultragentic docs new`.** Never type a docs path, a file name, or front matter yourself.
2. **One slug, one folder, one category.** A slug's documents all live in `docs/<category>/<slug>/`, whatever their type: a research slug's DECISION goes in `docs/research/<slug>/`. Pass `--category` only for a brand-new slug. If `docs new` refuses, do what its message says; never create the file or folder by hand to get past it.
3. **Living documents are edited in place.** Never copy `SPEC.md` to a new folder or a new name to make a "version 2". Edit it, then run `ultragentic docs revise`.
4. **Keep every XML section the template gave you,** in the same order, each tag alone on its line. Put your content between the tags. Write `None.` in a section with nothing to say; do not delete it.
5. **A document is done only when `ultragentic docs check <file>` prints `ok`.**
6. Documents hold content for people. Run state goes to the runtime, agent-only notes go to `ultragentic memory propose`, never into `docs/`.

</required>

## Steps

<procedure>

1. **Find out if the slug exists.** Read `docs/ROUTER.md` (or run `ultragentic docs router` first if it is missing). If the work already has a slug, reuse it. Do not make a second slug for the same work: a decision, plan, or record about a topic goes in that topic's slug, beside its RESEARCH or SPEC, so a reader finds everything about it in one folder.
2. **Pick the type** from the table below. Unsure? Run `ultragentic docs types`.
3. **Create the file:**

   ```sh
   ultragentic docs new <TYPE> --slug <slug> --title "<title>" --category <category>
   ```

   - `--category` is needed only for a slug that has no folder yet. A run started with `ultragentic goal`, `research`, `experiment`, `task`, or `tutor` already made the folder.
   - For a non-code task's SPEC, add `--variant task`.
   - If it says the document already exists, do not create another: open it and go to step 6.
   - If it says the slug looks like an existing topic, run the command it prints (that slug, no `--category`). Whether the work is separate is a person's decision: the `pre-tool-use` gate refuses `--new-slug` from an agent, so ask, and the person runs it.
4. **Fill it, results first.** Write the sections that hold results (Findings, Results, the requirement and task tables) before the abstract, summary, Refine, or WRITEUP, and write those only from what the sections already say: every ID they cite and every figure they state must already appear in a section of the slug. Open the path it printed. Replace every line containing `FILL:` with real content, inside the section it sits in. Keep headings the template wrote (gates read some of them, such as `## Open questions` and `## Applicability`). Set `description:` in the front matter to one sentence saying what the document answers.
5. **Check it:**

   ```sh
   ultragentic docs check <file>
   ```

   Fix every line it prints, then run it again until it prints `ok`. The post-write hook prints the same problems after each edit; treat them the same way. Then check that the slug's documents connect:

   ```sh
   ultragentic docs check-dots docs/<category>/<slug>
   ```

   It fails on an ID a section cites that no document of the slug defines, and on an abstract figure no other section states. `ultragentic checkpoint` runs the same check at every node that writes a document and will not advance until it passes, so fix the section, not the check.
6. **Revising later:** edit the file, then record the change:

   ```sh
   ultragentic docs revise <file> "<one line: what changed and why>"
   ```

   Set `status:` when the document's state changes: `draft` → `active` → `done`, or `superseded` when a later document replaces it (link the replacement).

</procedure>

## Which type

<rules>

| You are writing... | Type | Kind |
|---|---|---|
| What to build or deliver, and how success is judged | `SPEC` | living |
| How the SPEC will be delivered | `PLAN` | living |
| The task list | `TASKS` | living |
| A question answered from sources | `RESEARCH` | living |
| A claim to test, with its kill criteria | `HYPOTHESIS` | living |
| What experiments, audits, or investigations showed | `FINDINGS` | living |
| The full account of a research line, for outside readers | `WRITEUP` | living |
| A learner's study plan and record | `STUDY` | living |
| One decision and the options weighed (an ADR) | `DECISION` | record |
| One dated event: a run, an incident, a meeting, a release | `RECORD` | record |

Living: one file per slug, `<TYPE>.md`, revised in place. Record: a new file per event, `<TYPE>-<YYYY-MM-DD>-<topic>.md`, written once; the topic comes from `--title`.

</rules>

## Which category

<rules>

| The work is mainly... | Category |
|---|---|
| Building or changing something | `features` |
| A bug, an incident, a failure trace | `fixes` |
| Answering a question from sources | `research` |
| Testing a hypothesis with runs | `experiments` |
| A design or decision that spans several features | `architecture` |
| A release, infrastructure, a runbook | `operations` |
| An audit: code, security, design, quality | `reviews` |
| Learning a subject | `learning` |

Choose by what the slug is mainly about, once. Its later documents of other types stay in the same folder: a research slug's DECISION goes in `docs/research/<slug>/`.

</rules>

## Mistakes to avoid

<antipatterns>

- Writing `docs/2026-10-04/<slug>/1/SPEC-2026-10-04.md` or any dated folder: that layout is retired.
- Creating `SPEC-v2.md`, `SPEC-new.md`, or a second slug to revise a document: edit and `docs revise` instead.
- Deleting an empty section or renaming a tag to fit your content: keep the template's sections.
- Leaving `FILL:` text, `TBD`, or `???` in a document you call finished.
- Saying a document is done without the `ok` line from `docs check`.
- Writing the abstract or summary first and the sections after, or stating a figure or citing an ID in it that no section of the slug holds.

</antipatterns>

## References

<references>

- Templates: [`.ai-agents/templates/docs/`](../../templates/docs/)
- Charter rule: "Docs and naming" in [`charter-detail.md`](../../references/charter-detail.md), named from [`AGENTS.md`](../../../AGENTS.md)
- Tag set: "Document files" in [`AUTHORING.md`](../../AUTHORING.md)
- Decision-record content guidance: [`documentation-and-adrs`](../documentation-and-adrs/SKILL.md)

</references>
