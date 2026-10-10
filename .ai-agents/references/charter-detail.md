# Charter detail

<context>

Rules moved out of the always-loaded charter ([`AGENTS.md`](../../AGENTS.md)) so short-context agents do not pay for them on every turn. They bind exactly as before: AGENTS.md names the trigger for each section, and the section is MUST once its trigger applies.

</context>

## Sources and builds

<rules>

- **Source-driven, not memory-driven (MUST):** before using or upgrading a framework or library, read
  the docs for the version pinned in this repo's manifests. When adding a package or initializing a
  project, run the canonical CLI rather than fabricating files from memory, and capture project
  commands in a Makefile (or `package.json` scripts for Node). If a version is unclear, ask. When
  code depends on the *shape* of a library's output (parse-tree node types, a driver's connection
  options, a response's fields) and the docs do not pin it down, run a throwaway probe against the
  pinned version and build from what it prints. Assumed tree-sitter behaviour was wrong for three
  grammars in this repo: no tags query for PHP, and tags queries that returned no definitions for
  Ruby and Kotlin. See
  [`source-driven-development`](.ai-agents/skills/source-driven-development/SKILL.md).
- **A build check resolves real dependencies (MUST):** a workspace's declared build or unit check
  (in `ua-checks.yaml` or its equivalent) installs or resolves dependencies from the manifest and
  lockfile as part of the check (`npm ci`, `pip install -r requirements.txt`, `go build` against
  `go.sum`, or the ecosystem's equivalent) and then imports or runs the code against that install (a
  unit suite does both), not only a typecheck or lint against a cache that is already populated. The
  install catches an invented name added to the manifest; the import catches one used without being
  declared, which a successful install says nothing about. A package the model invented then fails a
  check with `exit_code` provenance
  instead of failing in production, and a name that does not exist cannot later be registered by
  someone else and installed. Where imports are not compile-checked (Python, JavaScript, most
  scripting stacks) this is the only mechanical catch; this repo's own Go stack already gets it from
  `go build`. Provenance: code-generating models recommended nonexistent packages for 19.7% of
  packages across 576,000 samples from 16 models ("We Have a Package for You! A Comprehensive
  Analysis of Package Hallucinations by Code Generating LLMs", USENIX Security 2025,
  [repository](https://github.com/Spracks/PackageHallucination)); rule added by the
  `agent-code-quality-hardening` delivery.
</rules>

## Docs and naming

<rules>

- **Generated docs location (MUST):** a command or skill producing a markdown deliverable (`SPEC`,
  `PLAN`, `TASKS`, `RESEARCH`, `HYPOTHESIS`, `FINDINGS`, `WRITEUP`, `STUDY`, decision records, run
  records) writes it to `docs/<category>/<slug>/<TYPE>.md` at the **workspace root** - the directory
  containing `.ultragentic/`, or the repo root when this toolkit is standalone. Never inside
  `.ultragentic/`, never a dated folder, never `docs/<slug>/`.
  - **Create, never hand-write (MUST):** `ultragentic docs new <TYPE> --slug <slug> --title "<title>"
    [--category <category>]` writes the file from its template in
    [`.ai-agents/templates/docs/`](.ai-agents/templates/docs/) with the path, file name, and front
    matter already right. Do not compute a docs path or type front matter yourself. `ultragentic docs
    types` lists the categories and types in one screen. Enforced: the pre-tool-use hook refuses a
    file-write tool creating a new markdown file under `docs/`, and the stop hook holds the turn
    once while a document written in it fails `docs check`.
  - **Category:** one of `features`, `fixes`, `research`, `experiments`, `architecture`,
    `operations`, `reviews`, `learning`. A slug lives in exactly one. A run picks it from the
    workflow (`/research` → `research`, `/experiment` → `experiments`, `/tutor` → `learning`, else
    `features`) unless `--category` says otherwise; a slug that already has a folder keeps it.
  - **One file per type, revised in place:** `SPEC.md`, `PLAN.md`, `TASKS.md` and the other living
    types are edited, never copied to a new folder. After a change, `ultragentic docs revise <file>
    "<what changed>"` bumps `updated` and logs the change in `<revisions>`; git keeps the old text.
    `DECISION` and `RECORD` are dated events, one file each: `<TYPE>-<YYYY-MM-DD>-<topic>.md`.
  - **Done means checked (MUST):** replace every `FILL:` line, then `ultragentic docs check <file>`
    must pass: front matter (`type`, `category`, `slug`, `title`, `description`, `status`,
    `created`, `updated`) matching the path, and the type's XML sections in order. The post-write
    hook reports the same problems after each edit.
  - `<slug>` is short kebab-case for the work; two slugs differing only in case are refused as a
    collision (case-preserving filesystems on Windows and macOS would alias their files). Confirm
    the slug with the user when it is not obvious. Older layouts move with `ultragentic migrate
    docs-tmp`.
- **Docs carry content, never run state (MUST):** a generated deliverable under `docs/` never
  contains graph or run state (`currentNode`, `checks`, `maxTransitions`, or any other
  `run-state.schema.json` field) outside a fenced code example that is explicitly documenting the
  schema. That state lives only in the `runs` table of `.agent-state/memory.db`
  (inspect with `ultragentic run status` / `run list`).
  `ultragentic doctor` fails on a violation; see `docmeta.checkNoGraphState`.
- **A slug is English (MUST):** a slug is a short English gloss of the objective, chosen by the
  agent, never a mechanical transliteration of non-English input. `auto.Slugify` keeps only
  `[a-z0-9]`, so a diacritic in non-English text is treated as a word break and leaves bare
  consonant fragments (`l-m-th-n`, `m-r-ng-repo` are real slugs this produced before the rule
  existed) - a mistake that survives `validate.Slug`'s kebab-case check because the fragments are
  still valid kebab-case. `graphroute.Resolve` refuses to auto-derive a slug from an objective
  containing a non-ASCII letter; pass `--slug` explicitly for a non-English objective instead.
  `ultragentic doctor` also warns, non-blocking, on an explicitly-passed slug that
  `docmeta.LooksTransliterated` flags as a heuristic net, not the enforcement.
- **A "no docs needed" decision still gets a slug (MUST):** when a task's scope is small enough
  that no SPEC/PLAN is warranted (see `spec-driven-development`'s "When NOT to use"), start the run
  with an explicit `--slug no-docs-<short-name>` rather than skip slug creation entirely. The
  decision stays auditable in `run list` and the `runs` table even though no `docs/<category>/<slug>/`
  tree gets populated. **Put `--slug` before the objective** (`run start --slug no-docs-x "<goal>"`,
  not `run start "<goal>" --slug no-docs-x`): Go's `flag` package stops parsing at the first
  non-flag argument, so a flag placed after the quoted objective is silently ignored rather than
  refused - confirmed against this binary while writing this rule. The CLI's own usage strings
  showing `"<objective>" [--slug <slug>]` are stale on this point; fixing that argument-parsing
  behavior is a separate, unscoped finding, not part of this rule.
- **Naming convention follows identifier kind, not a single house style (MUST):** this codebase
  uses three case conventions side by side, each one internally consistent within its own domain -
  do not "fix" an identifier into the wrong one in the name of consistency.
  - **kebab-case:** anything a person types or that works like a URL/filesystem path - the CLI
    binary and every subcommand (`ultragentic`, `ultragentic run status`), slugs (enforced, not just
    conventional: `runtime/internal/shared/validate/slug.go`'s `slugPattern` rejects an underscore),
    and branch names this toolkit creates (`fix/experiment-monitor-stop-signal`).
  - **snake_case:** identifiers that function as a programmatic tool or graph key - every MCP tool
    this server registers (`runtime/internal/mcp/tools.go`: `ua_bootstrap`, `ua_checkpoint`,
    `ua_verify`, and 10 more, zero exceptions - the one dash in that file, `"ultragentic"`, is the
    server's own identity name, not a tool name), and graph node/check/guard names
    (`.ai-agents/graphs/*.yaml`, `ua-checks.yaml`: `experiment_monitor`, `bug_hunt`,
    `tasks_remaining`, `review_ok`). The MCP spec permits a dash too (SEP-986); snake_case for tool
    names is an ecosystem convention this toolkit follows for tokenization/function-calling
    reliability, not a protocol requirement - which is exactly why it is easy to "correct" by
    mistake. **Do not rename `ua_verify`/`ua_checkpoint` or a `*_ok`/`*_remaining` check name to
    kebab-case.**
  - **camelCase:** JSON field names in a Go-marshaled struct or schema - ordinary Go `json:` tag
    convention (`runtime/internal/run/domain/run.go`: `schemaVersion`, `currentNode`; mirrored in
    `schemas/tasks.schema.json`'s own field names).
</rules>

## UI work

<rules>

- **Design loop (MUST):** when building, reshaping, or reviewing user-facing UI, run
  [`/design`](../commands/design.md) and follow
  [`ui-design-fidelity`](../skills/ui-design-fidelity/SKILL.md). Do not invent a parallel design
  stack; extend the project registry and these assets.
- **Taste and review (MUST):** load [`ux-taste.md`](ux-taste.md) for hierarchy, empty/loading/error
  states, and anti-slop. Before calling a UI change done, run
  [`ui-review-checklist.md`](ui-review-checklist.md). Structure and a11y still go through
  [`frontend-ui-engineering`](../skills/frontend-ui-engineering/SKILL.md) and
  [`accessibility-checklist.md`](accessibility-checklist.md).

</rules>

## Paths and platforms

<rules>

- **Portable paths (MUST):** in committed docs, plans, and agent deliverables, use paths relative to the workspace root or repo ids. Do not paste machine-absolute paths (`C:\...`, `/Users/...`, `d:\...`) into files that ship in git. For code and scripts, see **Paths in code are anchored, not absolute** below.
- **Paths in code are anchored, not absolute (MUST):** source code, scripts, and config an agent
  writes or edits never hardcode a machine-absolute path (`C:\...`, `/Users/...`, `/home/...`) that
  the code reads, writes, or executes, unless a person asks for one. An example path in help text or
  a comment, or a test input whose subject is path handling itself, is not that and stays as it is.
  Find a root at run time and join relative segments onto it: the
  script's own directory (`"$(dirname "${BASH_SOURCE[0]}")"` in Bash, `$PSScriptRoot` in
  PowerShell, as `scripts/` already does), a workspace root found by walking up (the runtime's
  `--workspace` default), or a configured value. A bare relative path is not the fix on its own: it
  resolves against the current working directory, so the same code breaks when run from another
  directory, which is the failure `ultragentic doctor`'s "every hook command resolves its own paths"
  check exists to catch. Imports and links are relative to the file or the repo root, never to one
  person's checkout. **Portable paths** above covers prose and deliverables; this covers what
  executes. Rule added by the `agent-code-quality-hardening` delivery at the user's request.
- **Cross-platform by default (MUST):** code that touches file paths, process execution, line
  endings, symlinks, or file-name case is checked against Windows, Linux, and macOS before it is
  called done, by naming the concrete failure on each, not by asserting it is portable. Use the
  language's path API (`filepath.Join`, `os.Root`) rather than string concatenation with `/` or `\`;
  pass arguments to a process as a list, not through a shell string. This repo already carries the
  evidence: `.gitattributes` pins `*.sh` to LF because a CRLF checkout on Windows breaks `sh`; the
  link script writes copies instead of symlinks on Windows (see `CLAUDE.md`); slugs differing only in
  case are refused because Windows and macOS filesystems alias them. Scripts a user runs to install
  or link ship as a `.sh` and `.ps1` pair; checks that run in CI or a git hook are Bash, which
  Windows runs under Git Bash. Verify on the platforms available (at minimum the one you are on plus
  CI's Linux runner) and say which platform went unverified. Rule added by the
  `agent-code-quality-hardening` delivery at the user's request.
</rules>

