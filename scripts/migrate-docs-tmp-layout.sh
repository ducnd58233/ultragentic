#!/usr/bin/env bash
# One-shot migrate of older docs layouts (flat docs/<slug>/ and dated
# docs/<YYYY-MM-DD>/<slug>/<version>/) into docs/<category>/<slug>/, and of a
# workspace-root tmp/ into .agent-state/runs/<YYYY-MM-DD>/<slug>/<version>/.
# Pass --category <slug>=<category> to override an inferred category.
#
# Prefers the installed ultragentic binary so Windows and Unix share one
# implementation. Pass --dry-run to list moves without writing.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
if ! command -v ultragentic >/dev/null 2>&1; then
  echo "migrate-docs-tmp-layout: ultragentic not on PATH; run scripts/install-runtime.sh first" >&2
  exit 1
fi
exec ultragentic migrate docs-tmp --workspace "$root" "$@"
