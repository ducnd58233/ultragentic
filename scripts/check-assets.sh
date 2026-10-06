#!/usr/bin/env bash
# Every asset check CI runs, in one command, so a local run and the `unit`
# check in ua-checks.yaml cannot drift from the workflow.
#
# The runtime's own suites live in the private ultragentic-runtime repo. This
# covers what this repo owns: routers, tags, generated views, install wiring,
# front matter, schemas, and graphs.
set -euo pipefail
cd "$(dirname "$0")/.."

bash scripts/check-ai-agents-routers.sh
bash scripts/check-xml-tags.sh
bash scripts/check-generated-views.sh
bash scripts/check-workspace-install.sh
python3 scripts/check-frontmatter.py
python3 scripts/check-schemas.py
python3 scripts/check-graphs.py
python3 scripts/check-graphs-test.py
python3 scripts/check-forget-me-not.py
bash scripts/check-shell-syntax.sh
