---
name: forget-me-not
description: >-
  FORGET-ME-NOT. Checks the other agent tooling on this machine (Claude Code plugins and marketplaces, skills in the agent skill folders, agent CLIs such as claude, codex and opencode, agent npm globals, and MCP servers) for available updates, then asks the user which to update and runs only the approved ones. Use when the user asks whether their plugins, skills, or agent tools are up to date, or wants to refresh them. Never updates anything unasked and never touches Ultragentic's own install.
disable-model-invocation: true
---

# FORGET-ME-NOT

## What

<context>

Agent tooling goes stale quietly: a plugin that fixed a bug three versions ago, a CLI two releases behind, a skill nobody remembers installing. This skill takes the inventory the user would never take by hand, says what is behind, and asks before touching any of it.

It covers everything **except** Ultragentic: entries named `ua-*` or `vibe-*`, and anything whose path points into an Ultragentic checkout, are left out on purpose. Ultragentic updates with `git pull` in its clone and a rerun of the install script.
</context>

## How

<procedure>

1. **Take the inventory.** Find `forget-me-not.py` and run it. It is read-only.

   ```sh
   for d in ./scripts ./.ultragentic/scripts "$HOME/.ultragentic/scripts"; do
     [ -f "$d/forget-me-not.py" ] && { python3 "$d/forget-me-not.py"; break; }
   done
   ```

   On Windows use `py -3` or `python` if `python3` is the Microsoft Store alias. Add `--offline` when the user does not want any network lookup, or `--json` to parse the result. Online it asks only the npm registry and the git remotes recorded in plugin marketplaces.
2. **Report what it found,** flagged items first: `outdated` and `possibly-outdated` (a marketplace is ahead of its local copy). Then say what could not be checked: `unmanaged` skills have no recorded source, and `unknown` means no version was reachable. Keep it short; this is a list, not an essay.
3. **Ask once which to update.** One question that names each flagged item with the exact command the script printed for it. Offer "all", "none", or a choice. Skills the `skills` CLI installed (`check-with-cli`) are checked with `npx skills check`, and `npx skills update` is offered only if that reports something.
4. **Run only what was approved,** one command at a time, and stop at the first failure and report it. Updating a plugin or the CLI hosting this session takes effect after a restart; say so.
5. **Rerun the inventory** to confirm, and report what is still behind and why.
</procedure>

## Limits (MUST)

<rules>

- Read-only until the user says yes. Never update, install, or remove anything on a guess about what they would want.
- Never print an MCP server's arguments, environment, headers, or URL. The script lists MCP servers by name only; keep it that way, since those fields hold tokens.
- Never use `sudo`, edit a plugin's files by hand, or work around a failed update by another route. Report the failure.
- Do not report a skill as up to date when it is `unmanaged`: no source is recorded, so no one can say.
- Do not touch Ultragentic itself from here.
</rules>
