#!/usr/bin/env python3
"""FORGET-ME-NOT: list the agent tooling on this machine that is not Ultragentic,
and say which of it is out of date.

Read-only. It never installs, updates, or edits anything: it reports, and the
FORGET-ME-NOT skill asks the user before any update runs.

What it looks at (stdlib only, no third-party packages):
  - Claude Code plugins and their marketplaces
  - skills in the agent skill folders (Claude, Cursor, Codex, opencode, shared)
  - agent CLIs (claude, codex, opencode, gemini, ...) and agent-looking npm globals
  - MCP servers, listed by name only

Secrets: MCP entries carry tokens in args, env, and URLs. Only the server name and
the launcher's base name are ever read out, so nothing sensitive can be printed.

Usage:
  python3 scripts/forget-me-not.py            # human-readable report
  python3 scripts/forget-me-not.py --json     # machine-readable
  python3 scripts/forget-me-not.py --offline  # no registry or git lookups
  python3 scripts/forget-me-not.py --home DIR # inspect another home (used by tests)
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path

# Anything this toolkit installed is not "other tooling".
OURS_PREFIXES = ("ua-", "vibe-")
OURS_WORDS = ("ultragentic", "vibe-agent")

SKILL_DIRS = (
    ".claude/skills", ".agents/skills", ".cursor/skills",
    ".codex/skills", ".config/opencode/skills",
)
SKILL_LOCKS = (".agents/.skill-lock.json", ".claude/.skill-lock.json", ".skill-lock.json")

NPM_REGISTRY = "https://registry.npmjs.org/"

# command -> (npm package that carries its releases, how to update it)
AGENT_CLIS = {
    "claude": ("@anthropic-ai/claude-code", "claude update"),
    "codex": ("@openai/codex", "npm install -g @openai/codex@latest"),
    "opencode": ("opencode-ai", "opencode upgrade"),
    "gemini": ("@google/gemini-cli", "npm install -g @google/gemini-cli@latest"),
}
AGENTISH = re.compile(r"claude|codex|opencode|cursor|gemini|kimi|mcp|agent|skill", re.I)


def is_ours(name: str) -> bool:
    low = name.lower()
    return low.startswith(OURS_PREFIXES) or any(w in low for w in OURS_WORDS)


def item(kind, name, installed=None, latest=None, status="unknown", update=None, note=None, source=None):
    return {"kind": kind, "name": name, "installed": installed, "latest": latest,
            "status": status, "update": update, "note": note, "source": source}


def read_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return None


def version_key(text):
    return tuple(int(n) for n in re.findall(r"\d+", text or "")[:4])


def compare(installed, latest):
    if not installed or not latest:
        return "unknown"
    return "outdated" if version_key(installed) < version_key(latest) else "current"


def run(cmd, timeout=8):
    try:
        out = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout, check=False)
        return out.stdout.strip()
    except (OSError, subprocess.SubprocessError):
        return ""


def npm_latest(package, offline, timeout):
    """Latest published version, or None when it cannot be reached (that reads as unknown)."""
    if offline:
        return None
    url = NPM_REGISTRY + package.replace("/", "%2F") + "/latest"
    try:
        with urllib.request.urlopen(url, timeout=timeout) as resp:
            return json.loads(resp.read().decode("utf-8")).get("version")
    except (OSError, ValueError):
        return None


def git_remote_head(repo, offline):
    if offline or not repo:
        return None
    url = repo if "://" in repo or repo.startswith("git@") else f"https://github.com/{repo}.git"
    out = run(["git", "ls-remote", url, "HEAD"], timeout=15)
    return out.split()[0] if out else None


def plugins(home: Path, offline):
    base = home / ".claude" / "plugins"
    installed = (read_json(base / "installed_plugins.json") or {}).get("plugins", {})
    markets = read_json(base / "known_marketplaces.json") or {}
    stale = {}
    for mkt, meta in markets.items():
        src = (meta or {}).get("source", {})
        repo = src.get("repo") or src.get("url")
        loc = Path(str((meta or {}).get("installLocation", "")))
        remote = git_remote_head(repo, offline)
        local = run(["git", "-C", str(loc), "rev-parse", "HEAD"]) if loc.is_dir() else ""
        stale[mkt] = bool(remote and local and remote != local)
    out = []
    for key, installs in installed.items():
        name, _, mkt = key.partition("@")
        if is_ours(name):
            continue
        first = installs[0] if isinstance(installs, list) and installs else {}
        have = first.get("version")
        latest = None
        loc = Path(str((markets.get(mkt) or {}).get("installLocation", "")))
        listing = read_json(loc / ".claude-plugin" / "marketplace.json") or {}
        for entry in listing.get("plugins", []):
            if entry.get("name") == name:
                latest = entry.get("version")
        status = compare(have, latest)
        note = None
        if stale.get(mkt):
            note = f"marketplace '{mkt}' has newer commits than the local copy; refresh it, then re-check"
            if status != "outdated":
                status = "possibly-outdated"
        out.append(item("claude-plugin", key, have, latest, status,
                        f"claude plugin marketplace update {mkt} && claude plugin update {key}", note, mkt))
    return out


def frontmatter_name(skill_md: Path):
    try:
        for line in skill_md.read_text(encoding="utf-8").splitlines()[:15]:
            if line.startswith("name:"):
                return line.split(":", 1)[1].strip().strip("'\"")
    except OSError:
        pass
    return None


def skills(home: Path):
    managed = {}
    for rel in SKILL_LOCKS:
        lock = read_json(home / rel)
        if isinstance(lock, dict):
            for name, meta in (lock.get("skills") or {}).items():
                managed[name] = (meta or {}).get("source") or (meta or {}).get("sourceUrl")
    seen = {}
    for rel in SKILL_DIRS:
        root = home / rel
        if not root.is_dir():
            continue
        for entry in sorted(root.iterdir()):
            skill_md = entry / "SKILL.md"
            if not skill_md.is_file():
                continue
            name = frontmatter_name(skill_md) or entry.name
            target = os.path.realpath(entry) if entry.is_symlink() else ""
            if is_ours(entry.name) or is_ours(name) or is_ours(target):
                continue
            seen.setdefault(name, []).append(rel)
    out = []
    for name, where in sorted(seen.items()):
        if name in managed:
            row = item("skill", name, status="check-with-cli",
                       update="npx skills check   (then: npx skills update)",
                       note="installed by the skills CLI; it knows how to compare", source=managed[name])
        else:
            row = item("skill", name, status="unmanaged",
                       note="no update source recorded; update it from wherever you got it")
        row["found_in"] = where
        out.append(row)
    return out


def clis(offline, timeout):
    out = []
    for cmd, (pkg, update) in AGENT_CLIS.items():
        path = shutil.which(cmd)
        if not path:
            continue
        raw = run([path, "--version"], timeout=6).splitlines()
        match = re.search(r"\d+\.\d+(\.\d+)?", raw[0]) if raw else None
        have = match.group(0) if match else None
        latest = npm_latest(pkg, offline, timeout)
        out.append(item("agent-cli", cmd, have, latest, compare(have, latest), update, source=pkg))
    return out


def npm_globals(offline, timeout):
    npm = shutil.which("npm")
    if not npm:
        return []
    try:
        data = json.loads(run([npm, "ls", "-g", "--depth=0", "--json"], timeout=20) or "{}")
    except ValueError:
        data = {}
    known = {pkg for pkg, _ in AGENT_CLIS.values()}
    out = []
    for name, meta in (data.get("dependencies") or {}).items():
        if name in known or is_ours(name) or not AGENTISH.search(name):
            continue
        have = (meta or {}).get("version")
        latest = npm_latest(name, offline, timeout)
        out.append(item("npm-global", name, have, latest, compare(have, latest),
                        f"npm install -g {name}@latest", source="npm"))
    return out


def mcp_servers(home: Path):
    """Names and launcher base names only: args, env, headers and URLs hold tokens."""
    found = {}

    def add(name, launcher):
        found.setdefault(name, launcher)

    claude = read_json(home / ".claude.json") or {}
    for name, cfg in (claude.get("mcpServers") or {}).items():
        add(name, os.path.basename(str((cfg or {}).get("command", ""))) or (cfg or {}).get("type", "remote"))
    cursor = read_json(home / ".cursor" / "mcp.json") or {}
    for name, cfg in (cursor.get("mcpServers") or {}).items():
        add(name, os.path.basename(str((cfg or {}).get("command", ""))) or "remote")
    opencode = read_json(home / ".config" / "opencode" / "opencode.json") or {}
    for name, cfg in (opencode.get("mcp") or {}).items():
        add(name, (cfg or {}).get("type", "local"))
    try:
        codex = (home / ".codex" / "config.toml").read_text(encoding="utf-8")
        for name in re.findall(r"^\[mcp_servers\.([A-Za-z0-9_-]+)\]", codex, re.M):
            add(name, "codex")
    except OSError:
        pass
    return [item("mcp-server", n, status="listed", source=launcher,
                 note="no version to check; unpinned launchers (npx, uvx) fetch their own latest")
            for n, launcher in sorted(found.items()) if not is_ours(n)]


def collect(home: Path, offline, timeout):
    return (plugins(home, offline) + skills(home) + clis(offline, timeout)
            + npm_globals(offline, timeout) + mcp_servers(home))


def render(items):
    kinds = [("claude-plugin", "Claude Code plugins"), ("skill", "Skills"), ("agent-cli", "Agent CLIs"),
             ("npm-global", "npm global packages"), ("mcp-server", "MCP servers (names only)")]
    lines = []
    for kind, title in kinds:
        rows = [i for i in items if i["kind"] == kind]
        if not rows:
            continue
        lines.append(f"\n{title}")
        for i in rows:
            ver = f"{i['installed'] or '?'} -> {i['latest']}" if i["latest"] else (i["installed"] or "")
            lines.append(f"  [{i['status']}] {i['name']} {ver}".rstrip())
            if i["note"]:
                lines.append(f"      {i['note']}")
            if i["status"] in ("outdated", "possibly-outdated", "check-with-cli") and i["update"]:
                lines.append(f"      update: {i['update']}")
    flagged = [i for i in items if i["status"] in ("outdated", "possibly-outdated")]
    lines.append(f"\n{len(items)} items, {len(flagged)} with a likely update.")
    return "\n".join(lines).lstrip("\n")


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--home", default=str(Path.home()))
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--offline", action="store_true")
    ap.add_argument("--timeout", type=int, default=10)
    args = ap.parse_args(argv)
    items = collect(Path(args.home), args.offline, args.timeout)
    print(json.dumps(items, indent=2) if args.json else render(items))
    return 0


if __name__ == "__main__":
    sys.exit(main())
