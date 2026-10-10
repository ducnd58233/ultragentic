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
   are forbidden. Put the proof on the PR: `gh --attach` for media, or inline the API
   transcript / reproduction steps in the PR body or comment.
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
7. **Write `MANIFEST.md` before `gh pr create`** on an active run. Without it the hook refuses create.
8. **Attach to the PR for reviewers, then write `ATTACHED.md` with `Head:`** set to the commit
   the capture proves. Staging paths in ATTACHED/RECORD are for the runtime gate, not the
   reviewer-facing comment body.
9. **On every new commit to an open PR:** recapture if the product path changed, re-attach on
   the PR, then `ultragentic previdence refresh --slug <slug>`. Stale `Head` vs current
   `git HEAD` fails `previdence check` / the `pr_evidence` verifier, and `pre-tool-use`
   refuses `git push`.
10. **Scrub leaks.** If a PR already has comments that only point at local pr-evidence paths,
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

## Attach (GitHub CLI)

Requires GitHub CLI v2.99+ for `--attach` (images and video). API transcripts can go in `--body` /
`--body-file` without `--attach`.

```sh
gh pr create --title "..." --body-file pr-body.md --attach .agent-state/runs/<date>/<slug>/<version>/pr-evidence/after.png
# or, after the PR exists / after new commits:
gh pr comment --body-file pr-body.md --attach .agent-state/runs/<date>/<slug>/<version>/pr-evidence/after.png
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

- `open_pr` still confirms a PR exists (`gh pr view`).
- `pr_evidence` runs the `previdence` verifier (`file_assert` on MANIFEST + ATTACHED + Head freshness, or kind none/redacted).
- Hosts share the same `ultragentic hook pre-tool-use` gate; no per-host bypass.
