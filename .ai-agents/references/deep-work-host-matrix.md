# Deep-work host matrix

How `/deep-research` and `/deep-analyze` run on every host in the runtime inventory (`codex`, `claude`, `cursor`, `opencode`, `kimi`, `muse`, `antigravity`). Prefer the native path when present; otherwise emulate with the [`deep-research-harness`](../skills/deep-research-harness/SKILL.md) skill.

| Host | Native deep research | Emulation path | Notes |
|------|----------------------|----------------|-------|
| claude | Prefer host `/deep-research` dynamic workflow when Claude Code ≥ v2.1.154 and WebSearch is available | Skill phases via Agent tool subagents | Session stays free while the workflow runs; still write the ultragentic RESEARCH digest |
| codex | None bundled | Subagents (`explorer` / custom) + `--search`; skill phases | Optional community skills are not vendored here |
| cursor | No named deep-research slash | Background Task/subagents; long-running agents when available | Prefer background for long fan-out |
| opencode | Skills-based only | Load toolkit skill; enable host web search if the install requires it (for example Exa) | Skill roots under opencode config or `.agents/skills` |
| kimi | None in CLI help on probe | Skill under `.kimi-code/skills` via link/global install | Research-capable host; skills-only path |
| muse | None first-party documented | Skill under shared `.agents/skills` | Inventory binary `muse` |
| antigravity | None in `agy` help on probe | Skill under `.agents/skills` | Inventory binary `agy`; alias `antigravity` |

## Shared rules

- Cover all seven hosts when changing deep-work assets (AUTHORING supported harness parity; research-only hosts are in scope for this matrix).
- Long work: `ultragentic job start` / `job wait`, not a polling loop.
- No `deep_research_phases` check key; digests gate through existing docs checkers and `file_assert`.
