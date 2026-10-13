# Extending the PR evidence forge matrix

When the remote is not GitHub, GitLab, or Bitbucket Cloud (self-hosted or another
vendor), keep the **portable evidence contract** unchanged and add an adapter row.

## Portable contract (do not change)

Every forge PR/MR body must still carry:

1. **Visual evidence** — forge-visible screenshot/video, Kind `api` transcript, or honest Kind `none`/`redacted` with Reason.
2. **Reproduce / Verify** — numbered steps matching STEPS / MANIFEST Steps for Kind `ui`.

Fields live in [`PORTABLE_PR_BODY.md`](../PORTABLE_PR_BODY.md). Forge adapters only choose CLI, template path, and body/browser fallback.

## How to add a forge row

1. Detect the remote (`git remote get-url origin` host patterns or `ultragentic doctor` active forge).
2. Open vendor docs and the forge CLI `--help` for create/comment/attach (or confirm none).
3. Add a row to [`.ai-agents/references/pr-evidence-forges.md`](../../../references/pr-evidence-forges.md): Detect when, CLI, create/comment with media, body-only Kind `api`, fetch surface, notes.
4. Optionally add a template under `.ai-agents/templates/forge/<forge-id>/` that copies the portable sections.
5. Wire local-first install in `scripts/link-ai-agents.sh` and `.ps1` (install only when consumer lacks a template).
6. Cover host-facing refuse/continue for every AI host in the runtime inventory (no single-host-only path).

## Failure → research → retry (MUST)

If the chosen CLI or API call fails, **do not** silently skip evidence. Research the equivalent syntax for that forge (vendor docs, `CLI --help`, doctor probe), then apply the same portable contract. Prefer Kind `api` body when media attach is unsupported or experimental.
