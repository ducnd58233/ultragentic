#!/usr/bin/env bash
# Parses every shell script in scripts/ without running it. A syntax error in an
# installer is found by the person installing, so it is found here first.
set -euo pipefail
cd "$(dirname "$0")/.."

failed=0
for f in scripts/*.sh; do
  if ! bash -n "$f"; then
    echo "FAIL  $f does not parse" >&2
    failed=1
  fi
done
exit "$failed"
