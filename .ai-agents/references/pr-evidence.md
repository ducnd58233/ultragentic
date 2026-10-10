---
description: Capture and attach PR product evidence without committing binaries
---

# PR product evidence

When a delivery run opens a pull request for a product-affecting change, prove the change on the
PR itself. Keep captures out of git.

<required>

## Rules (MUST)

1. **Store captures under the run tree only:**
   `.agent-state/runs/<date>/<slug>/<version>/pr-evidence/` (gitignored with `.agent-state/`).
2. **Never commit** png, jpg, jpeg, webp, gif, mp4, webm, mov, or HAR as tracked repo files.
   `pre-tool-use` refuses `git add` of those extensions outside `.agent-state/`.
3. **Write `MANIFEST.md` before `gh pr create`** on an active run. Without it the hook refuses create.
4. **Attach to the PR, then write `ATTACHED.md`.** The graph node `pr_evidence` reads both files.

</required>

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
| api | Redacted curl-style request and response for the fixed or new path (text file). Prefer text over raw HAR; if you keep a HAR, leave it under `pr-evidence/` only. |
| ui | Exercise the feature in browser, simulator, or desktop UI; save screenshot and/or short recording under `pr-evidence/`. Reuse the runtime `screen` verifier or browser tools when they already write into the run tree; copy or reference into `pr-evidence/` as listed. |

## Attach (GitHub CLI)

Requires GitHub CLI v2.99+ for `--attach` (images and video). API transcripts can go in `--body` /
`--body-file` without `--attach`.

```sh
gh pr create --title "..." --body-file pr-body.md --attach .agent-state/runs/<date>/<slug>/<version>/pr-evidence/after.png
# or, after the PR exists:
gh pr comment --body-file pr-body.md --attach .agent-state/runs/<date>/<slug>/<version>/pr-evidence/after.png
```

Then write `ATTACHED.md`:

```text
PR: https://github.com/org/repo/pull/12
Method: gh pr create --attach
Files:
- after.png
```

## Graph and checks

- `open_pr` still confirms a PR exists (`gh pr view`).
- `pr_evidence` runs the `previdence` verifier (`file_assert` on MANIFEST + ATTACHED, or kind none).
- Hosts share the same `ultragentic hook pre-tool-use` gate; no per-host bypass.
