# Claude Code feature map (for ultragentic)

<context>

Maps shipped Claude Code / Anthropic Agent SDK features to ultragentic owners.
Primary sources: [features overview](https://code.claude.com/docs/en/features-overview),
[hooks](https://code.claude.com/docs/en/hooks), [permission modes](https://code.claude.com/docs/en/permission-modes),
[sandboxing](https://code.claude.com/docs/en/sandboxing), [agent teams](https://code.claude.com/docs/en/agent-teams),
[file checkpointing](https://code.claude.com/docs/en/agent-sdk/file-checkpointing),
[glossary](https://code.claude.com/docs/en/glossary) (`--bare`), [whats-new 2026-w13](https://code.claude.com/docs/en/whats-new/2026-w13).

Use this when importing an idea from Claude Code into the toolkit. Prefer linking
here over restating Claude docs. Domain product logic does not belong here.
</context>

## Feature map

<rules>

| Claude feature | Reuse | Reject | Gap / ultragentic owner |
|----------------|-------|--------|------------------|
| CLAUDE.md + auto memory | Always-on charter files; memory.db confirm/forget | Do not write model notes into git | [`AGENTS.md`](../../AGENTS.md), `ultragentic memory` |
| Skills / slash commands | `.ai-agents/skills`, `commands`, routers | Claude marketplace as required path | [`skills/ROUTER.md`](../skills/ROUTER.md), `ultragentic skills add` |
| Subagents (isolated summary) | Persona agents + host Task | Cloning Claude Agent tool schema | [`agents/ROUTER.md`](../agents/ROUTER.md) |
| Hooks (matcher + lifecycle) | `ultragentic hook <event>` | Prompt/agent hook types as graph evidence | [`hooks/ROUTER.md`](../hooks/ROUTER.md), `runtime/internal/harness` |
| Conditional hook `if` | Narrow PostToolUse cost on Claude host | `if` that skips PreToolUse danger Bash | This file §Conditional hooks; `.claude/settings.json` |
| Permission modes / classifier auto | Operator vocabulary (dontAsk≈CI allowlist) | Classifier pass as `--source` | [`tool-safety-and-permissions.md`](tool-safety-and-permissions.md); `/auto` is outer graph only |
| OS Bash sandbox (Seatbelt/bubblewrap) | Pair isolation with fewer prompts | In-process Seatbelt/bubblewrap in Go | ultragentic `sandbox.yaml` is a **runner port**, not Claude OS sandbox (see §Sandbox truth) |
| Agent teams | Human parallel research pattern | Multi-session team runtime in control plane | Decline for now; use personas |
| File rewind / checkpoints | Recovery UX idea | Rewinding conversation as run state | Gap: graph checkpoints ≠ file rewind |
| `--bare` / dontAsk CI | Minimal host load for evals | Stripping danger PreToolUse or stop | This file §Minimal host / bare-like |
| MCP + tool search | `ultragentic mcp serve`; host MCP | New evidence source | [`token-efficiency.md`](token-efficiency.md) |
| Plugins / marketplaces | Link scripts + skills install | Building Anthropic marketplace | [`.ai-agents/AUTHORING.md`](../AUTHORING.md) |
| PR auto-fix (Claude web) | Intent matches `/auto` + CI API | Cloning Claude web product | [`commands/auto.md`](../commands/auto.md) |

</rules>

## Sandbox truth (ultragentic runner port)

<rules>

ultragentic `sandbox` is **not** Claude Code’s OS Bash sandbox.

| Layer | What it is | Isolation |
|-------|------------|-----------|
| Claude `/sandbox` | Seatbelt (macOS) or bubblewrap (Linux/WSL2) on Bash with FS/network policy | OS-enforced per command |
| ultragentic `driver: local` | Host subprocess via `safexec` | **None** |
| ultragentic `driver: docker` | `docker run --rm` with workspace bind-mounted RW | Container namespaces only; no `--network=none` / `--read-only` / `--cap-drop` in current `runtime/internal/sandbox/exec.go` |

Config: `.agent-state/sandbox.yaml`. CLI: `ultragentic sandbox`. Embedded container/GPU inside the Go process stays declined ([`AGENTS.md`](../../AGENTS.md)). Codex `sandbox_mode` in `.codex/config.toml` is **Codex host** isolation, not this port.

**Mutating workspace session (Ferrum-class, native):** bind a use-case with `ultragentic sandbox up` (or MCP after a run exists), capture/restore trees with `sandbox snapshot` / `sandbox restore` (hash-only run events), run confined `fs` / allowlisted `shell` / `git status|diff` / `validate` via `sandbox tool` or MCP `ua_sandbox_tool` (each result carries a recovery class), and leave only when declared checks passed (`sandbox leave` / `ua_sandbox_leave`). Do not invent a `ferrum-*` skill or CLI. Same surface for every inventory host (Claude Code, Codex, Cursor, Kimi Code, Open Code, Muse, Antigravity).

</rules>

## Conditional hooks (Claude host)

<procedure>

Claude v2.1.85+ allows an `if` field with permission-rule syntax on a hook
handler ([whats-new 2026-w13](https://code.claude.com/docs/en/whats-new/2026-w13)).

**Rules for this toolkit:**

1. **PreToolUse** that runs `ultragentic hook pre-tool-use` must keep a Bash-inclusive
   tool-name `matcher` and must **not** set `if`. Danger-list evaluation needs every
   Bash candidate.
2. **PostToolUse** journaling may split: Edit/Write/NotebookEdit/WebFetch stay on
   matcher alone; Bash may use `if: "Bash(git *)"` so non-git shell noise costs less.
   Non-git Bash then loses post-journal rows; that is an accepted tradeoff, not a
   security boundary.
3. Other hosts follow [`host-hook-contracts.md`](host-hook-contracts.md); do not
   assume Cursor/Codex parse Claude `if`. Runtime tests refuse Claude `"if"` keys in
   shipped `.cursor/hooks.json` and `.codex/hooks.json`.

</procedure>

## Host portability matrix (Claude adaptations)

<rules>

| Adaptation | Claude | Cursor | Codex | opencode |
|------------|--------|--------|-------|----------|
| Feature map / bare-like recipe (docs) | yes | yes | yes | yes |
| Hook handler `if: "Bash(git *)"` | yes (settings) | no; use `matcher` regex on tool name or on `beforeShellExecution` command text for **pre** only ([Cursor hooks](https://cursor.com/docs/hooks)) | no `if` in shipped hooks | no Claude `if` |
| Post-journal narrow to `git *` | yes via `if` | no 1:1 (`postToolUse` matcher is tool name, not args) | n/a | n/a |
| Danger PreToolUse / beforeShell | keep wide, no `if` | `beforeShellExecution` → pre-tool-use (all shells) | PreToolUse unfiltered in shipped config | plugin / UNVERIFIED |

</rules>

## Minimal host / bare-like

<procedure>

Claude `--bare` drops hooks, skills, custom commands, subagents, plugins, MCP,
auto memory, and CLAUDE.md for reproducible CI ([glossary](https://code.claude.com/docs/en/glossary)).

For ultragentic **consumers** running CI or graph-path evals:

| May strip / omit | Must keep |
|------------------|-----------|
| Optional marketplace skills not required by the check plan | `ultragentic hook pre-tool-use` (danger list, merge gate) |
| Extra MCP servers unused by the job | `ultragentic hook stop` while a run is mid-graph |
| Host UI plugins unrelated to delivery | `ultragentic doctor` before `/goal` or `/auto` |
| Auto memory / unconfirmed memory noise | Closed evidence sources only (`exit_code`, `file_assert`, `ci_api`, `human_event`) |

`dontAsk`-like host permission modes (pre-approved tools only) pair with this
recipe. They are host settings, not a ultragentic graph flag. Never equate Claude
permission **auto** with ultragentic `/auto`.

</procedure>

## Routing & discovery

<routing>

- Peer host maps: [`cursor-feature-map.md`](cursor-feature-map.md), [`codex-feature-map.md`](codex-feature-map.md), [`opencode-feature-map.md`](opencode-feature-map.md), [`antigravity-feature-map.md`](antigravity-feature-map.md), [`kimi-feature-map.md`](kimi-feature-map.md), [`muse-feature-map.md`](muse-feature-map.md)
- Peer product map: [`deepseek-harness-feature-map.md`](deepseek-harness-feature-map.md)
- Peer auto-loop research (different question): prior slug `how-other-agent-harnesses`
- Hook contracts: [`host-hook-contracts.md`](host-hook-contracts.md)
- Loop ownership: [`loop-and-graph-engineering.md`](loop-and-graph-engineering.md)
- Research slug: `feature-maps-all-supported`

</routing>
