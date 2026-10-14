# Templates router

<routing>

Document templates that `ultragentic docs new` renders into `docs/<category>/<slug>/`. Do not copy one by hand; the command fills the path, file name, and front matter. Rules: [`docs-authoring`](../skills/docs-authoring/SKILL.md).

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
| [`docs/WIREFRAME.md`](docs/WIREFRAME.md) | WIREFRAME | `WIREFRAME.md`: screen sketches before UI code |
| [`docs/USERSTORY.md`](docs/USERSTORY.md) | USERSTORY | `USERSTORY.md`: user stories with acceptance criteria |
| [`docs/ERD.md`](docs/ERD.md) | ERD | `ERD.md`: living Mermaid entity-relationship model |

**Changing a template's sections** means changing the type's `Tags` in `runtime/internal/pkg/docmeta/doctype.go` and `DOC_TAGS` in `scripts/check-xml-tags.sh` in the same
change; `go test ./internal/docauthor` fails until all three agree. A new type needs a row here too.

### Forge PR / MR templates (install via link script)

Portable evidence body and per-forge instantiations. Link/install copies them into a consumer
workspace only when that path is absent (local-first). Contract and research-retry:
[`pr-evidence.md`](../references/pr-evidence.md), matrix [`pr-evidence-forges.md`](../references/pr-evidence-forges.md).

| Template | Forge | Installs to (when absent) |
|----------|-------|---------------------------|
| [`forge/PORTABLE_PR_BODY.md`](forge/PORTABLE_PR_BODY.md) | all (fields only) | stays in toolkit; agents copy sections |
| [`forge/github/pull_request_template.md`](forge/github/pull_request_template.md) | github | `.github/pull_request_template.md` |
| [`forge/gitlab/Default.md`](forge/gitlab/Default.md) | gitlab | `.gitlab/merge_request_templates/Default.md` |
| [`forge/bitbucket/pull_request_template.md`](forge/bitbucket/pull_request_template.md) | bitbucket | `pull_request_template.md` at repo root |
| [`forge/unknown/EXTENSION.md`](forge/unknown/EXTENSION.md) | unknown / self-hosted | docs only; add a matrix row before inventing a CLI |

</routing>
