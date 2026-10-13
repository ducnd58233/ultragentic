---
description: Forge command matrix for PR product evidence attach (MUST read before any attach shell)
---

# PR evidence forge command matrix

Agents **MUST** open this matrix before any media attach shell. Detect the active forge
with `ultragentic doctor` (active forge line) or `git remote get-url origin`, then run
**only** the matching row. Do not default to `gh` on a non-GitHub remote.

Forge-neutral rules (MANIFEST, Kind, staging, Head refresh, **portable Visual evidence +
Reproduce / Verify contract**) stay in [`pr-evidence.md`](pr-evidence.md). The PR body
fields are the same on every forge; only the CLI and template path change.

Portable body text: [`.ai-agents/templates/forge/PORTABLE_PR_BODY.md`](../templates/forge/PORTABLE_PR_BODY.md).
Extension pattern for new forges: [`.ai-agents/templates/forge/unknown/EXTENSION.md`](../templates/forge/unknown/EXTENSION.md).

## Matrix (MUST)

| Forge | Detect when | CLI | Create with media | Comment with media | Body-only Kind api | Template install path (local-first) | Notes |
|-------|-------------|-----|-------------------|--------------------|--------------------|-------------------------------------|-------|
| github | `github.com` or `*.ghe.com` | `gh` | `gh pr create … --attach <file>` | `gh pr comment … --attach <file>` | `gh pr create … --body-file` with `Kind: api` + fenced transcript | `.github/pull_request_template.md` | Stable `--attach` from GitHub CLI v2.99+. Probe: `ultragentic doctor` or `gh pr create --help` lists `--attach`. |
| gitlab | `gitlab.com` or host contains `gitlab` | `glab` | `glab mr create … --attach <file>` | `glab mr note create … --attach <file>` | `glab mr create …` with `Kind: api` + fenced transcript in description | `.gitlab/merge_request_templates/Default.md` | `--attach` is **experimental**. Prefer Kind `api` body when unsure. |
| bitbucket | `bitbucket.org` or host contains `bitbucket` | forge CLI if present (no media attach) | **unsupported** for agent media | **unsupported** for agent media | Kind `api` body/transcript on the PR description or comment | `pull_request_template.md` at repo root when absent | No official REST/CLI media attach. Kind `ui` media: browser upload only. Never invent `--attach`. |
| unknown | anything else (incl. self-hosted) | none for media until a row is added | **unsupported** until documented | **unsupported** until documented | Kind `api` body/transcript | use `PORTABLE_PR_BODY.md` in the forge web UI | Fail closed for Kind `ui` media until an extension row lands. Follow EXTENSION.md; do not invent a CLI. |

## Probe and refuse

1. Run `ultragentic doctor` and read the **active forge** line plus attach capability.
2. Open this matrix; pick the row for that forge.
3. Do **not** plan `gh … --attach` when the active forge is not GitHub.
4. Do **not** plan `glab … --attach` when the active forge is not GitLab.
5. Bitbucket and unknown: never invent media `--attach`; use Kind `api` body/transcript, or browser Kind `ui`.
6. `pre-tool-use` refuses wrong-forge and unsupported media attach plans on every supported host
   (Claude Code, Codex, Cursor, Kimi Code, Open Code, Muse, Antigravity).

## Failure → research → retry (MUST)

If a forge CLI or API call fails (unknown flag, auth, missing binary, wrong subcommand):

1. **Do not** silently skip Visual evidence or Reproduce / Verify.
2. Research the equivalent syntax for **that** forge: `CLI --help`, vendor docs linked from this matrix, and `ultragentic doctor`.
3. Retry with the corrected command, or fall back to the row's **Body-only Kind api** / browser Kind `ui` path.
4. Record what you tried in the PR body only as reviewer-useful proof (attach or transcript), never as a local-path dump.

This rule is host-neutral: every inventory AI host must follow it.

## Kind api body (cross-forge)

Works on every forge when media attach is missing, experimental, or unsupported. Put
these lines in the PR/MR description or a comment:

- A `Kind: api` line and a `Summary:` line matching the MANIFEST Summary
- A fenced transcript that includes that Summary (redacted request/response)
- The same **Reproduce / Verify** steps the portable contract requires when the path is product-critical

Use the forge row's body flags (`gh` `--body` / `--body-file`, `glab` description flags,
Bitbucket/web UI paste, or the forge web UI). Never invent a Bitbucket media attach CLI.
