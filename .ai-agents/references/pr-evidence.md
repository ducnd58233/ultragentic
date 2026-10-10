---
description: Capture and attach PR product evidence without committing binaries
---

# PR product evidence

When a delivery run opens a pull request for a product-affecting change, prove the change on the
PR itself. Keep captures out of git. **Use the runtime `ultragentic previdence` command** for
snapshot and screen-record captures; do not invent host-only or ad-hoc capture paths.

<required>

## Rules (MUST)

1. **Store captures under the run tree only:**
   `.agent-state/runs/<date>/<slug>/<version>/pr-evidence/` (gitignored with `.agent-state/`).
2. **Never commit** png, jpg, jpeg, webp, gif, mp4, webm, mov, or HAR as tracked repo files.
   `pre-tool-use` refuses `git add` of those extensions outside `.agent-state/`.
3. **Capture via runtime:** `ultragentic previdence snapshot` and `ultragentic previdence record`
   (or `--source` to import a file into pr-evidence/). Skills and commands that need UI evidence
   MUST call these; browser/device tools may produce a file, then import with `--source`.
4. **Write `MANIFEST.md` before `gh pr create`** on an active run. Without it the hook refuses create.
5. **Attach to the PR, then write `ATTACHED.md` with `Head:`** set to the commit the capture proves.
6. **On every new commit to an open PR:** recapture if the product path changed, re-attach, then
   `ultragentic previdence refresh --slug <slug>`. Stale `Head` vs current `git HEAD` fails
   `previdence check` / the `pr_evidence` verifier, and `pre-tool-use` refuses `git push`.

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

- `api` / `ui` require `Summary` and at least one `Files` basename (no paths).
- `none` requires `Reason` and must not list files.

## Capture

| Kind | What to capture |
|------|-----------------|
| api | Redacted curl-style request and response for the fixed or new path (text file under pr-evidence/). Prefer text over raw HAR. |
| ui | `ultragentic previdence snapshot` and/or `previdence record`. If a browser or device tool already wrote a PNG/recording, import with `--source`. |

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
- `pr_evidence` runs the `previdence` verifier (`file_assert` on MANIFEST + ATTACHED + Head freshness, or kind none).
- Hosts share the same `ultragentic hook pre-tool-use` gate; no per-host bypass.
