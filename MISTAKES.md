# Mistakes and rules

Rules graduated from repeated mistakes. Each rule binds every agent working in this
repository. Add one with a reviewed change, for example `ultragentic mistakes graduate`.

- **false-done** - Never claim a check is clean from a command that merely ran: stop a helper at the first failed verifier, and rerun every scan on the final tree immediately before saying done.
- **stale-stop-midgraph** - Before any checkpoint or verify on a named slug, run ultragentic run status --slug <slug> and advance only when the status is non-terminal.
- **cwd-path-and-driver** - Never default a path or database URL to a working-directory-relative value, and never use the sqlite3:// scheme with the migrate CLI built with the sqlite tag.
