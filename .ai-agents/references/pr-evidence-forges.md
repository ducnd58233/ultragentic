---
description: Forge command matrix for PR product evidence attach (MUST read before any attach shell)
---

# PR evidence forge command matrix

Agents **MUST** open this matrix before any media attach shell. Detect the active forge
with `ultragentic doctor` (active forge line) or `git remote get-url origin`, then run
**only** the matching row. Do not default to `gh` on a non-GitHub remote.

Forge-neutral rules (MANIFEST, Kind, staging, Head refresh) stay in
[`pr-evidence.md`](pr-evidence.md).

## Matrix (MUST)

| Forge | Detect when | CLI | Create with media | Comment with media | Body-only Kind api | Fetch surface | Notes |
|-------|-------------|-----|-------------------|--------------------|--------------------|---------------|-------|
| github | `github.com` or `*.ghe.com` | `gh` | `gh pr create … --attach <file>` | `gh pr comment … --attach <file>` | `gh pr create … --body-file` with `Kind: api` + fenced transcript | `gh pr view` / `gh api` issue comments | Stable `--attach` from GitHub CLI v2.99+. Probe: `ultragentic doctor` or `gh pr create --help` lists `--attach`. |
| gitlab | `gitlab.com` or `*.gitlab.com` | `glab` | `glab mr create … --attach <file>` | `glab mr note create … --attach <file>` | `glab mr create …` with `Kind: api` + fenced transcript in description | `glab mr view` | `--attach` is **experimental**. Prefer Kind `api` body when unsure. |
| bitbucket | `bitbucket.org` | none for media | **unsupported** | **unsupported** | Kind `api` body/transcript on the PR description or comment | no agent media reader | No official REST/CLI media attach. Kind `ui` media: browser upload only. |
| unknown | anything else | none for media | **unsupported** | **unsupported** | Kind `api` body/transcript | none | Fail closed for Kind `ui` media. Do not invent a CLI. |

## Probe and refuse

1. Run `ultragentic doctor` and read the **active forge** line plus attach capability.
2. Open this matrix; pick the row for that forge.
3. Do **not** plan `gh … --attach` when the active forge is not GitHub.
4. Do **not** plan `glab … --attach` when the active forge is not GitLab.
5. Bitbucket and unknown: never invent media `--attach`; use Kind `api` body/transcript, or browser Kind `ui`.
6. `pre-tool-use` refuses wrong-forge and unsupported media attach plans on every supported host
   (Claude Code, Codex, Cursor, Kimi Code, Open Code, Muse, Antigravity).

## Kind api body (cross-forge)

Works on every forge when media attach is missing, experimental, or unsupported. Put
these lines in the PR/MR description or a comment:

- A `Kind: api` line and a `Summary:` line matching the MANIFEST Summary
- A fenced transcript that includes that Summary (redacted request/response)

Use the forge row's body flags (`gh` `--body` / `--body-file`, `glab` description flags,
or the forge web UI). Never invent a Bitbucket media attach CLI.