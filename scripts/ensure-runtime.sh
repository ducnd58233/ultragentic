#!/usr/bin/env bash
# Makes sure the ultragentic runtime is installed, for an AI agent to call.
#
# The user never has to install the runtime by hand. When a delivery command finds
# it missing, the agent runs this script (see .ai-agents/references/runtime-bootstrap.md).
# The license is a condition of use, so the agent asks the user and only then
# reruns this with UA_ACCEPT_LICENSE=1; this script never assumes consent.
#
# Exit codes:
#   0  the runtime is installed and answers `version`
#   3  not installed, and the license has not been accepted yet: ask the user
#   1  the install failed; the output says why
#
# Usage:
#   bash scripts/ensure-runtime.sh                       # check; exit 3 if missing
#   UA_ACCEPT_LICENSE=1 bash scripts/ensure-runtime.sh   # install after the user agreed
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${UA_INSTALL_DIR:-$HOME/.local/bin}"
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) EXE=".exe" ;; *) EXE="" ;; esac

# The installer may have put the binary somewhere PATH does not reach yet, in
# this shell or in a fresh install.
export PATH="$INSTALL_DIR:$PATH"

if command -v ultragentic >/dev/null 2>&1 && ultragentic version >/dev/null 2>&1; then
  echo "ultragentic runtime ready: $(ultragentic version 2>/dev/null | head -1)"
  echo "binary: $(command -v ultragentic)"
  exit 0
fi

if [ "${UA_ACCEPT_LICENSE:-}" != "1" ]; then
  cat <<MSG
LICENSE_REQUIRED
The ultragentic runtime is not installed. It is a closed-source binary under
RUNTIME-LICENSE.md: free to use, including commercially; no reverse engineering,
no redistribution. License text: ${SCRIPT_DIR}/../RUNTIME-LICENSE.md
Ask the user whether to install it. If they agree, run:
  UA_ACCEPT_LICENSE=1 bash "${SCRIPT_DIR}/ensure-runtime.sh"
If they decline, stop; the delivery commands cannot run without it.
MSG
  exit 3
fi

if ! bash "${SCRIPT_DIR}/install-runtime.sh"; then
  echo "ensure-runtime: the install failed (see above). Nothing was left half-installed." >&2
  exit 1
fi

if ! "${INSTALL_DIR}/ultragentic${EXE}" version >/dev/null 2>&1; then
  echo "ensure-runtime: installed ${INSTALL_DIR}/ultragentic${EXE} but it does not run." >&2
  exit 1
fi
echo "binary: ${INSTALL_DIR}/ultragentic${EXE}"
echo "If a later command says 'command not found', call it by that path or add ${INSTALL_DIR} to PATH."
exit 0
