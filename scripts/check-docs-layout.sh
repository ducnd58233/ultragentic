#!/usr/bin/env bash
# Layout and front-matter checks for docs/<category>/<slug>/.
#
# This toolkit gitignores /docs/, so CI cannot scan real deliverables here.
# The load-bearing proof is the Go fixture suite, plus the docauthor suite that
# keeps .ai-agents/templates/docs/ equal to the type registry; consumers with
# tracked docs get the same rules from `ultragentic doctor` and `docs check`.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
# The runtime source is private. Its repo runs these tests in its own CI; point
# UA_RUNTIME_DIR at a checkout of it to run them here.
if [ -z "${UA_RUNTIME_DIR:-}" ]; then
  echo "skip: set UA_RUNTIME_DIR to an ultragentic-runtime checkout to run the docs-layout fixtures"
  exit 0
fi
cd "$UA_RUNTIME_DIR"
ULTRAGENTIC_TOOLKIT="$root" go test ./internal/shared/docmeta/ ./internal/docauthor/ -count=1
