# Templates router

<routing>

Document templates that `ultragentic docs new` renders into `docs/<category>/<slug>/`. Do not copy one by
hand; the command fills the path, file name, and front matter. Rules: [`docs-authoring`](../skills/docs-authoring/SKILL.md).

| Template | Type | Writes |
|----------|------|--------|
| [`docs/SPEC.md`](docs/SPEC.md) | SPEC | `SPEC.md`: what to build and how success is judged |
| [`docs/SPEC.task.md`](docs/SPEC.task.md) | SPEC (`--variant task`) | `SPEC.md` for a non-code task: deliverable, acceptance rows, outward actions |
| [`docs/PLAN.md`](docs/PLAN.md) | PLAN | `PLAN.md`: approach, phases, risks |
| [`docs/TASKS.md`](docs/TASKS.md) | TASKS | `TASKS.md`: the task list, status in each heading |
| [`docs/RESEARCH.md`](docs/RESEARCH.md) | RESEARCH | `RESEARCH.md`: question, cited findings, applicability, refine |
| [`docs/HYPOTHESIS.md`](docs/HYPOTHESIS.md) | HYPOTHESIS | `HYPOTHESIS.md`: claim, prediction, method, kill criteria |
| [`docs/FINDINGS.md`](docs/FINDINGS.md) | FINDINGS | `FINDINGS.md`: results and implications |
| [`docs/WRITEUP.md`](docs/WRITEUP.md) | WRITEUP | `WRITEUP.md`: a research line told for outside readers |
| [`docs/STUDY.md`](docs/STUDY.md) | STUDY | `STUDY.md`: a learner's goal, topics, sessions, question bank |
| [`docs/DECISION.md`](docs/DECISION.md) | DECISION | `DECISION-<date>-<topic>.md`: one decision record |
| [`docs/RECORD.md`](docs/RECORD.md) | RECORD | `RECORD-<date>-<topic>.md`: one dated event |

**Changing a template's sections** means changing the type's `Tags` in
`runtime/internal/shared/docmeta/doctype.go` and `DOC_TAGS` in `scripts/check-xml-tags.sh` in the same
change; `go test ./internal/docauthor` fails until all three agree. A new type needs a row here too.
</routing>
