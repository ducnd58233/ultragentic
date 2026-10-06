#!/usr/bin/env python3
"""Fixture test for scripts/forget-me-not.py.

Builds a fake home with known contents and asserts what the inventory says about
it, and, as importantly, what it must never say: MCP tokens, and anything this
toolkit installed itself.
"""
from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
# A unique marker standing in for a token. If it ever shows up in the output, a
# real one would have too.
CANARY = "CANARY_MUST_NEVER_BE_PRINTED"


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def build_home(home: Path) -> None:
    market = home / ".claude" / "plugins" / "marketplaces" / "acme"
    write(market / ".claude-plugin" / "marketplace.json", json.dumps(
        {"plugins": [{"name": "old-plugin", "version": "2.0.0"}, {"name": "fresh-plugin", "version": "1.0.0"}]}))
    write(home / ".claude" / "plugins" / "installed_plugins.json", json.dumps({"version": 2, "plugins": {
        "old-plugin@acme": [{"version": "1.0.0"}],
        "fresh-plugin@acme": [{"version": "1.0.0"}],
        "ultragentic@acme": [{"version": "0.0.1"}],
    }}))
    write(home / ".claude" / "plugins" / "known_marketplaces.json", json.dumps(
        {"acme": {"source": {"source": "github", "repo": "acme/plugins"}, "installLocation": str(market)}}))
    for folder, name in ((".claude/skills", "ua-goal"), (".claude/skills", "vibe-plan"),
                         (".agents/skills", "loose-skill"), (".agents/skills", "managed-skill")):
        write(home / folder / name / "SKILL.md", f"---\nname: {name}\n---\n")
    write(home / ".agents" / ".skill-lock.json", json.dumps(
        {"skills": {"managed-skill": {"source": "acme/skills"}}}))
    write(home / ".claude.json", json.dumps({"mcpServers": {
        "github": {"command": "npx", "args": ["-y", "server", "--token", CANARY],
                   "env": {"GITHUB_TOKEN": CANARY}},
        "remote": {"type": "http", "url": f"https://example.com/mcp?key={CANARY}",
                   "headers": {"Authorization": f"Bearer {CANARY}"}},
    }}))
    write(home / ".codex" / "config.toml",
          "[mcp_servers.fromcodex]\ncommand = \"x\"\n\n[mcp_servers.fromcodex.env]\nTOKEN = \"" + CANARY + "\"\n")


def main() -> int:
    failures = []
    script = str(ROOT / "scripts" / "forget-me-not.py")
    with tempfile.TemporaryDirectory() as tmp:
        home = Path(tmp)
        build_home(home)
        as_json = subprocess.run([sys.executable, script, "--home", str(home), "--offline", "--json"],
                                 capture_output=True, text=True, check=False)
        if as_json.returncode != 0:
            print(as_json.stderr, file=sys.stderr)
            return 1
        as_text = subprocess.run([sys.executable, script, "--home", str(home), "--offline"],
                                 capture_output=True, text=True, check=False)
    items = json.loads(as_json.stdout)
    by_name = {i["name"]: i for i in items}

    def expect(cond, label):
        print(("  ok    " if cond else "  FAIL  ") + label)
        if not cond:
            failures.append(label)

    expect(by_name.get("old-plugin@acme", {}).get("status") == "outdated", "a plugin behind its marketplace is outdated")
    expect(by_name.get("fresh-plugin@acme", {}).get("status") == "current", "a plugin matching its marketplace is current")
    expect("ultragentic@acme" not in by_name, "this toolkit's own plugin is not listed")
    expect("ua-goal" not in by_name and "vibe-plan" not in by_name, "this toolkit's own skills are not listed")
    expect(by_name.get("loose-skill", {}).get("status") == "unmanaged", "a skill with no source is unmanaged")
    expect(by_name.get("managed-skill", {}).get("status") == "check-with-cli", "a lock-file skill is handed to the skills CLI")
    expect({"github", "remote", "fromcodex"} <= {i["name"] for i in items if i["kind"] == "mcp-server"},
           "MCP servers are listed by name")
    expect("fromcodex.env" not in by_name, "a TOML sub-table is not mistaken for a server")
    expect(CANARY not in as_json.stdout and CANARY not in as_text.stdout, "no MCP secret reaches the output")
    expect(all(i["kind"] != "mcp-server" or not i["installed"] for i in items), "MCP entries carry no version or args")
    print(f"check-forget-me-not: {'FAILED (' + str(len(failures)) + ')' if failures else 'OK'}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
