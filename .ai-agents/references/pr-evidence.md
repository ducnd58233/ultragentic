---
description: Capture and attach PR product evidence without committing binaries
---

# PR product evidence

Prove product-affecting changes **on the pull request for reviewers** (humans and AI agents):
so they can understand the change in context. Local
`.agent-state/runs/<date>/<slug>/<version>/pr-evidence/` is a **gitignored staging tree only**.
It is not a tip to the PR owner about where a snapshot lives on disk. Keep captures out of git.
**Use the runtime `ultragentic previdence` command** for snapshot and screen-record captures;
do not invent host-only or ad-hoc capture paths.

<required>

## Rules (MUST)

1. **Audience is reviewers on the PR.** Evidence exists so reviewers understand the change.
   Do **not** PR-comment only to tell the owner that a file sits under
   `.agent-state/.../pr-evidence/`. Reviewers cannot open that path.
2. **Never PR-comment RECORD/ATTACHED path dumps.** Comments that only paste or link
   `RECORD.md` / `ATTACHED.md` (or other files) under `.agent-state/runs/.../pr-evidence/`
   are forbidden. Put the proof on the PR: forge media attach per the
   [command matrix](pr-evidence-forges.md), or inline the API transcript / reproduction
   steps in the PR body or comment.
3. **Evidence must be real and in scope.** Capture or import proof that matches this PR's
   change; include step-by-step reproduction. Fabricated, off-scope, or invented captures
   are forbidden. Docs-only work may use `Kind: none` with a one-line reason.
3a. **Sensitive product PRs MUST omit capture.** For credentials, PII, or
   security-sensitive UI/API (or an explicit sensitive feature), MUST NOT record or
   attach product evidence (no png/mp4/transcript dumps). MUST declare
   `Kind: redacted` with a one-line `Reason` so reviewers see deliberate omission.
   MUST NEVER dump secrets into pr-evidence staging or PR attachments. Do **not**
   use `Kind: none` for sensitivity omit (`none` stays docs-only / non-product).
4. **Store captures under the run tree only** (staging):
   `.agent-state/runs/<date>/<slug>/<version>/pr-evidence/` (gitignored with `.agent-state/`).
5. **Never commit** png, jpg, jpeg, webp, gif, mp4, webm, mov, or HAR as tracked repo files.
   `pre-tool-use` refuses `git add` of those extensions outside `.agent-state/`.
6. **Capture via runtime:** `ultragentic previdence snapshot` and `ultragentic previdence record`
   (or `--source` to import a file into pr-evidence/). Skills and commands that need UI evidence
   MUST call these; browser/device tools may produce a file, then import with `--source`.
7. **Write `MANIFEST.md` before opening the PR/MR** on an active run. Without it the hook
   refuses create (GitHub `gh pr create` today; other forges follow the same MANIFEST gate
   once their create shells are wired).
8. **Forge-visible proof is mandatory.** `ATTACHED.md` alone is not enough. For Kind `api`/`ui`,
   the PR description or a comment MUST carry reviewer-visible proof (forge media attach per
   the [command matrix](pr-evidence-forges.md), or an inlined transcript that includes the
   MANIFEST Summary in a fenced block). For Kind `none`/`redacted`, the PR description or a
   comment MUST declare `Kind:` and `Reason:` so omit is visible. `pr_evidence` checks the
   forge via `ci_api`.
9. **Create must declare forge-facing evidence for product kinds.** On an active run with
   Kind `api`/`ui`, the create command MUST include media `--attach` (only when the matrix
   row and doctor probe allow it) or a `Kind:` line in the body. `pre-tool-use` refuses
   otherwise. **MUST open [`pr-evidence-forges.md`](pr-evidence-forges.md) before any attach shell.**
10. **Attach to the PR for reviewers, then write `ATTACHED.md` with `Head:`** set to the commit
   the capture proves. Staging paths in ATTACHED/RECORD are for the runtime gate, not the
   reviewer-facing comment body.
11. **On every new commit to an open PR:** recapture if the product path changed, re-attach on
   the PR, then `ultragentic previdence refresh --slug <slug>`. Stale `Head` vs current
   `git HEAD` fails `previdence check` / the `pr_evidence` verifier, and `pre-tool-use`
   refuses `git push`.
12. **Scrub leaks.** If a PR already has comments that only point at local pr-evidence paths,
    edit or minimize them and replace with reviewer-visible proof (attach or inlined transcript).

</required>

## Runtime commands

Usage and flags live in the runtime registry. Print them with:

```sh
ultragentic help previdence
# or: ultragentic previdence --help
```

Typical forms: `previdence snapshot|record --slug <slug> --name <file>` (optional
`--source` import), then `previdence refresh` / `previdence check`. Do not copy
usage lines into other docs; change `cmd/registry.go` and regenerate help.

`RECORD.md` under pr-evidence/ is append-only (Captured / Mode / Name / Head).

## MANIFEST.md

```text
Kind: api
Summary: POST /v1/widgets returns 201 after the fix
Files:
- capture.txt
```

```text
Kind: ui
Summary: login error state after bad password
Files:
- after.png
```

```text
Kind: none
Reason: docs-only charter edit; no product path
```

```text
Kind: redacted
Reason: PII in security-sensitive UI; omit product capture
```

- `api` / `ui` require `Summary` and at least one `Files` basename (no paths).
- `none` requires `Reason` and must not list files (docs-only / non-product).
- `redacted` requires `Reason` and must not list files; skip capture and attach
  none (no png/mp4). Fail closed if capture is attempted.

## Capture

| Kind | What to capture |
|------|-----------------|
| api | Redacted curl-style request and response for the fixed or new path (text file under pr-evidence/). Prefer text over raw HAR. |
| ui | `ultragentic previdence snapshot` and/or `previdence record`. If a browser or device tool already wrote a PNG/recording, import with `--source`. |
| none | No capture (docs-only / non-product). |
| redacted | No capture and no attach. Sensitivity omit for credentials / PII / security-sensitive UI/API. |

## Attach (forge-dynamic)

**MUST** open [`pr-evidence-forges.md`](pr-evidence-forges.md) before any attach shell.
Detect the active forge (`ultragentic doctor` or `git remote get-url origin`), then use that
row only. Do not default to `gh` on GitLab or Bitbucket remotes.

- GitHub: `gh pr create|comment --attach` when doctor/help shows support (CLI v2.99+).
- GitLab: `glab mr … --attach` is **experimental**; Kind `api` body is the safe default.
- Bitbucket / unknown: **no** agent media attach; Kind `api` body/transcript, or browser
  Kind `ui` only. Do not invent a Bitbucket `--attach` CLI.

Kind `api` transcripts can always go in the PR/MR body without media attach (include a
`Kind: api` line and a fenced transcript that contains the MANIFEST Summary). Kind `ui`
media needs a supported forge attach row or a browser upload that produces forge-visible
proof; there is no honest invent-a-CLI path.

GitHub examples (only when doctor says forge is github and attach is supported):

```sh
gh pr create --title "..." --body-file pr-body.md --attach .agent-state/runs/<date>/<slug>/<version>/pr-evidence/after.png
gh pr comment --body-file pr-body.md --attach .agent-state/runs/<date>/<slug>/<version>/pr-evidence/after.png
ultragentic previdence refresh --slug <slug>
```

Cross-forge Kind `api` body path (no media attach):

```sh
# Use the forge row's create command with a body file that includes:
# Kind: api, Summary, and a fenced transcript
ultragentic previdence refresh --slug <slug>
```

Then write or refresh `ATTACHED.md`:

```text
PR: https://github.com/org/repo/pull/12
Method: gh pr create --attach
Head: <full git SHA of the commit this capture proves>
Files:
- after.png
```

`previdence refresh` rewrites `Head` to the current HEAD and appends `RECORD.md`.

## Graph and checks

- `open_pr` confirms a PR/MR exists (forge-aware resolve; GitHub via `gh pr view`).
- `pr_evidence` runs the `previdence` verifier: `file_assert` on MANIFEST + ATTACHED +
  Head freshness, then `ci_api` on the PR body/comments for forge-visible proof
  (api/ui attach or transcript; none/redacted Kind+Reason).
- Hosts share the same `ultragentic hook pre-tool-use` gate across all seven inventory
  hosts; no per-host bypass.
