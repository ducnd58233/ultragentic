#!/usr/bin/env bash
# Downloads and verifies the ultragentic runtime binary for this platform.
#
# The runtime is a closed-source build published as GitHub Release assets of
# this repository. Its source lives in a private repository, so there is no
# build-from-source path: the only way to get the runtime is this script, or a
# manual download that you verify yourself (see RUNTIME-LICENSE.md).
#
# Every download is checked before it is installed:
#   1. SHA256SUMS lists the checksum of every asset in the release.
#   2. SHA256SUMS.sig is an ECDSA P-256 signature over SHA256SUMS, made in the
#      private build pipeline. It is verified against the public key pinned in
#      scripts/ultragentic-release.pub.pem.
#   3. The downloaded binary must match its line in SHA256SUMS.
# A missing file, a bad signature, or a mismatch stops the install. There is no
# flag that skips verification.
#
# The binary is distributed under RUNTIME-LICENSE.md, not the Apache-2.0 license
# of the rest of this repository. The script asks you to accept it first; set
# UA_ACCEPT_LICENSE=1 to accept non-interactively (CI, devcontainers).
#
# Downloads every time it runs. It does not skip because a binary is already
# present: a consumer who installed once would otherwise never get an update.
#
# Usage:
#   bash scripts/install-runtime.sh                  # newest stable, else rolling
#   bash scripts/install-runtime.sh v0.1.0           # a specific version
#   bash scripts/install-runtime.sh --channel rolling
#   UA_ACCEPT_LICENSE=1 bash scripts/install-runtime.sh
#   UA_INSTALL_DIR=~/bin bash scripts/install-runtime.sh

set -euo pipefail

die() { echo "install-runtime: $*" >&2; exit 1; }

REPO="${UA_REPO:-ducnd58233/ultragentic}"
VERSION="latest"
CHANNEL="auto"
while [ $# -gt 0 ]; do
  case "$1" in
    --channel) CHANNEL="${2:-}"; shift 2 ;;
    --channel=*) CHANNEL="${1#*=}"; shift ;;
    -*) die "unknown option: $1" ;;
    *) VERSION="$1"; shift ;;
  esac
done
case "$CHANNEL" in
  auto|stable|rolling) ;;
  *) die "unknown channel: $CHANNEL (auto, stable, or rolling)" ;;
esac
INSTALL_DIR="${UA_INSTALL_DIR:-$HOME/.local/bin}"
BINARY="ultragentic"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUBKEY="${SCRIPT_DIR}/ultragentic-release.pub.pem"
LICENSE_FILE="${SCRIPT_DIR}/../RUNTIME-LICENSE.md"

detect_os() {
  case "$(uname -s)" in
    Linux*)   echo linux ;;
    Darwin*)  echo darwin ;;
    MINGW*|MSYS*|CYGWIN*) echo windows ;;
    *) die "unsupported operating system: $(uname -s)" ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo amd64 ;;
    arm64|aarch64) echo arm64 ;;
    *) die "unsupported architecture: $(uname -m). Published targets: amd64 and arm64 on linux, darwin, windows." ;;
  esac
}

os="$(detect_os)"
arch="$(detect_arch)"
ext=""
[ "$os" = "windows" ] && ext=".exe"

command -v curl >/dev/null 2>&1 || die "curl is required"
command -v openssl >/dev/null 2>&1 || die "openssl is required to verify the release signature. Install it and rerun; the install will not proceed unverified."
[ -f "$PUBKEY" ] || die "missing ${PUBKEY}. This script must run from a complete checkout of ${REPO}."

# The license is a condition of use, so it is shown and accepted before a byte
# of the binary is fetched. A non-interactive run must opt in explicitly.
accept_license() {
  if [ "${UA_ACCEPT_LICENSE:-}" = "1" ]; then
    return 0
  fi
  echo "The ultragentic runtime is proprietary software. Installing it means you"
  echo "accept the terms in RUNTIME-LICENSE.md (no reverse engineering, no"
  echo "redistribution of the binary):"
  echo "  ${LICENSE_FILE}"
  echo "  https://github.com/${REPO}/blob/main/RUNTIME-LICENSE.md"
  if [ ! -t 0 ]; then
    die "no terminal to ask on. Read the license, then rerun with UA_ACCEPT_LICENSE=1."
  fi
  printf 'Accept and continue? [y/N] '
  read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) die "license not accepted; nothing was downloaded." ;;
  esac
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Asset names embed the version, and the rolling build's version carries a
# commit sha nobody can predict. So the release JSON is the source of truth for
# what to download, rather than a URL assembled from guesses.
fetch_release() {
  curl -fsSL "https://api.github.com/repos/${REPO}/releases/$1" 2>/dev/null
}

# Resolution order:
#   1. an explicit version, when one was passed
#   2. the newest stable release
#   3. the rolling build from main, a prerelease the /releases/latest endpoint skips
resolve_release() {
  if [ "$VERSION" != "latest" ]; then
    fetch_release "tags/runtime/${VERSION}"
    return 0
  fi
  if [ "$CHANNEL" = "rolling" ]; then
    echo "channel rolling: the build from main" >&2
    fetch_release tags/runtime/latest
    return 0
  fi
  echo "looking for a published release" >&2
  local json
  if json="$(fetch_release latest)" && [ -n "$json" ]; then
    printf '%s' "$json"
    return 0
  fi
  echo "no stable release yet, trying the rolling build from main" >&2
  fetch_release tags/runtime/latest
}

asset_url_for() {
  # $1 = release JSON, $2 = regex the asset name must end with
  printf '%s' "$1" \
    | grep -o '"browser_download_url": *"[^"]*"' \
    | sed 's/.*"browser_download_url": *"\([^"]*\)".*/\1/' \
    | grep -E "$2\$" | head -1
}

accept_license

release_json="$(resolve_release)" || true
[ -n "$release_json" ] || die "no published runtime release found for ${REPO}. See https://github.com/${REPO}/releases"

asset_url="$(asset_url_for "$release_json" "_${os}_${arch}${ext}")"
sums_url="$(asset_url_for "$release_json" "SHA256SUMS")"
sig_url="$(asset_url_for "$release_json" "SHA256SUMS\\.sig")"
[ -n "$asset_url" ] || die "that release has no asset for ${os}/${arch}."
[ -n "$sums_url" ] || die "that release has no SHA256SUMS; refusing to install an unverified binary."
[ -n "$sig_url" ] || die "that release has no SHA256SUMS.sig; refusing to install an unverified binary."

asset="$(basename "$asset_url")"
echo "downloading ${asset}"
curl -fsSL -o "${tmp}/${asset}" "$asset_url" || die "download of ${asset} failed."
curl -fsSL -o "${tmp}/SHA256SUMS" "$sums_url" || die "download of SHA256SUMS failed."
curl -fsSL -o "${tmp}/SHA256SUMS.sig" "$sig_url" || die "download of SHA256SUMS.sig failed."

echo "verifying signature"
openssl dgst -sha256 -verify "$PUBKEY" -signature "${tmp}/SHA256SUMS.sig" "${tmp}/SHA256SUMS" >/dev/null 2>&1 \
  || die "signature check failed: SHA256SUMS was not signed by the ultragentic release key. Do not run this file."

echo "verifying checksum"
expected="$(grep " \*\?${asset}\$" "${tmp}/SHA256SUMS" | awk '{print $1}' | head -1)"
[ -n "$expected" ] || die "${asset} is not listed in the signed SHA256SUMS."
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "${tmp}/${asset}" | awk '{print $1}')"
elif command -v shasum >/dev/null 2>&1; then
  actual="$(shasum -a 256 "${tmp}/${asset}" | awk '{print $1}')"
else
  actual="$(openssl dgst -sha256 "${tmp}/${asset}" | awk '{print $NF}')"
fi
[ "$expected" = "$actual" ] || die "checksum mismatch for ${asset}; do not run this file."

mkdir -p "$INSTALL_DIR"
install -m 0755 "${tmp}/${asset}" "${INSTALL_DIR}/${BINARY}${ext}" 2>/dev/null \
  || { cp "${tmp}/${asset}" "${INSTALL_DIR}/${BINARY}${ext}"; chmod +x "${INSTALL_DIR}/${BINARY}${ext}"; }

installed="$("${INSTALL_DIR}/${BINARY}${ext}" version 2>/dev/null | head -1 || true)"
if [ -n "$installed" ]; then
  echo "installed ${INSTALL_DIR}/${BINARY}${ext} (${installed})"
else
  echo "installed ${INSTALL_DIR}/${BINARY}${ext}"
fi
case ":${PATH}:" in
  *":${INSTALL_DIR}:"*) ;;
  *)
    echo
    echo "${INSTALL_DIR} is not on PATH. Hooks invoke the binary by name, so add it:"
    echo "  export PATH=\"${INSTALL_DIR}:\$PATH\""
    ;;
esac

# What matters is which copy PATH finds, not which one was just written. A
# shadowed install is invisible, and its symptom is a hook behaving like a
# version you thought you replaced.
resolved="$(command -v "$BINARY" 2>/dev/null || true)"
if [ -n "$resolved" ] && [ -n "$installed" ]; then
  winner="$("$resolved" version 2>/dev/null | head -1 || true)"
  if [ -n "$winner" ] && [ "$winner" != "$installed" ]; then
    echo
    echo "warning: PATH resolves ${BINARY} to a different build:"
    echo "           ${resolved} (${winner})"
    echo "         so this install does not change what the hooks run."
    echo "         remove that copy, or put ${INSTALL_DIR} earlier on PATH."
  fi
fi

echo
echo "check the install with:"
echo "  ${BINARY} version"
echo "  ${BINARY} doctor"
