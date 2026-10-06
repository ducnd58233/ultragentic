<#
.SYNOPSIS
  Downloads and verifies the ultragentic runtime binary for this machine.

.DESCRIPTION
  The runtime is a closed-source build published as GitHub Release assets of
  this repository. Its source lives in a private repository, so there is no
  build-from-source path: the only way to get the runtime is this script, or a
  manual download that you verify yourself (see RUNTIME-LICENSE.md).

  Every download is checked before it is installed:
    1. SHA256SUMS lists the checksum of every asset in the release.
    2. SHA256SUMS.sig is an ECDSA P-256 signature over SHA256SUMS, made in the
       private build pipeline. It is verified against the public key pinned in
       scripts/ultragentic-release.pub.pem.
    3. The downloaded binary must match its line in SHA256SUMS.
  A missing file, a bad signature, or a mismatch stops the install. There is no
  switch that skips verification.

  The binary is distributed under RUNTIME-LICENSE.md, not the Apache-2.0 license
  of the rest of this repository. The script asks you to accept it first; set
  $env:UA_ACCEPT_LICENSE = '1' (or pass -AcceptLicense) to accept
  non-interactively.

.PARAMETER AcceptLicense
  Accept RUNTIME-LICENSE.md without prompting. Also honoured as
  $env:UA_ACCEPT_LICENSE = '1'.

.PARAMETER SkipPathUpdate
  Leave the user PATH alone. Also honoured as $env:UA_SKIP_PATH_UPDATE. Use it
  when installing to a temporary directory, which would otherwise be added to
  PATH permanently.

.PARAMETER Version
  Release to install, for example v0.1.0. Defaults to the latest release.

.PARAMETER InstallDir
  Where to place the binary. Defaults to $env:UA_INSTALL_DIR, then
  %USERPROFILE%\.local\bin.

  One location, shared with install-runtime.sh. They used to write to different
  directories, so a machine could end up with several ultragentic binaries and
  PATH order decided which one the hooks called.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts/install-runtime.ps1
#>

[CmdletBinding()]
param(
  [string]$Version = 'latest',
  [string]$InstallDir = $(if ($env:UA_INSTALL_DIR) { $env:UA_INSTALL_DIR } else { Join-Path $env:USERPROFILE '.local\bin' }),
  [string]$Repo = $(if ($env:UA_REPO) { $env:UA_REPO } else { 'ducnd58233/ultragentic' }),
  [switch]$AcceptLicense,
  [switch]$SkipPathUpdate
)

$ErrorActionPreference = 'Stop'
$binary = 'ultragentic.exe'
$pubKeyPath = Join-Path $PSScriptRoot 'ultragentic-release.pub.pem'
$licensePath = Join-Path $PSScriptRoot '..\RUNTIME-LICENSE.md'

function Show-Result {
    param([string]$Target)
    $installed = ''
    # A build too old to answer `version` still installed; report it unversioned.
    try { $installed = (& $Target version 2>$null | Select-Object -First 1).Trim() } catch { }
    if ($installed) {
        Write-Host "installed $Target ($installed)"
    } else {
        Write-Host "installed $Target"
    }
    # What matters is which copy PATH finds, not which one was just written. A
    # shadowed install is invisible, and its symptom is a hook behaving like a
    # version you thought you replaced.
    $resolved = Get-Command ultragentic -ErrorAction SilentlyContinue
    if ($resolved -and $installed) {
        $winner = ''
        # The shadowing copy may predate `version`; then there is no comparison to make.
        try { $winner = (& $resolved.Source version 2>$null | Select-Object -First 1).Trim() } catch { }
        if ($winner -and $winner -ne $installed) {
            Write-Host ''
            Write-Warning "PATH resolves ultragentic to a different build:"
            Write-Warning "  $($resolved.Source) ($winner)"
            Write-Warning "so this install does not change what the hooks run."
            Write-Warning "Remove that copy, or put $InstallDir earlier on PATH."
        }
    }

    Write-Host ''
    Write-Host 'check the install with:'
    Write-Host '  ultragentic version'
    Write-Host '  ultragentic doctor'
}

# Replaces the binary in place, tolerating the case where it is running.
#
# This script fetches on every run rather than skipping when a binary exists, so
# overwriting a live one is the normal case, not the rare one. Windows refuses to
# delete or overwrite a loaded image but allows renaming it, which is what makes
# an in-place replacement possible at all: move the old one aside, put the new
# one in place, and clear the leftover when the process lets go.
function Install-Binary {
    param([string]$Downloaded, [string]$Target)

    if (-not (Test-Path -LiteralPath $Target)) {
        Move-Item -LiteralPath $Downloaded -Destination $Target -Force
        return
    }

    $aside = "$Target.old"
    Remove-Item -LiteralPath $aside -Force -ErrorAction SilentlyContinue
    try {
        Move-Item -LiteralPath $Target -Destination $aside -Force
    } catch {
        throw @"
Could not replace ${Target}: $($_.Exception.Message)

Something is holding the file open. Close any terminal or editor running
ultragentic, then rerun this script.
"@
    }

    try {
        Move-Item -LiteralPath $Downloaded -Destination $Target -Force
    } catch {
        # Put the working binary back rather than leaving nothing installed.
        Move-Item -LiteralPath $aside -Destination $Target -Force
        throw
    }
    Remove-Item -LiteralPath $aside -Force -ErrorAction SilentlyContinue
}

function Add-ToUserPath {
    param([string]$Directory)

    # Hooks invoke the binary by name, so PATH matters. This is the only part of
    # the script that changes state outside the install directory, which is why it
    # can be turned off: a scripted or throwaway install to a temporary directory
    # would otherwise leave that directory on the user's PATH permanently.
    if ($SkipPathUpdate -or $env:UA_SKIP_PATH_UPDATE) {
        Write-Host "skipping the PATH update; add $Directory yourself if hooks need it"
        return
    }

    $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
    if ($userPath -notlike "*$Directory*") {
        [Environment]::SetEnvironmentVariable('PATH', "$userPath;$Directory", 'User')
        Write-Host "added $Directory to your user PATH; open a new terminal to pick it up"
    }
}

# The license is a condition of use, so it is shown and accepted before a byte of
# the binary is fetched. A non-interactive run must opt in explicitly.
function Confirm-License {
    if ($AcceptLicense -or $env:UA_ACCEPT_LICENSE -eq '1') { return }
    Write-Host 'The ultragentic runtime is proprietary software. Installing it means you'
    Write-Host 'accept the terms in RUNTIME-LICENSE.md (no reverse engineering, no'
    Write-Host 'redistribution of the binary):'
    Write-Host "  $licensePath"
    Write-Host "  https://github.com/$Repo/blob/main/RUNTIME-LICENSE.md"
    if (-not [Environment]::UserInteractive -or [Console]::IsInputRedirected) {
        throw 'No terminal to ask on. Read the license, then rerun with $env:UA_ACCEPT_LICENSE = "1".'
    }
    $answer = Read-Host 'Accept and continue? [y/N]'
    if ($answer -notmatch '^(y|yes)$') { throw 'License not accepted; nothing was downloaded.' }
}

# Verifies SHA256SUMS.sig (ECDSA P-256, SHA-256, DER encoded as openssl writes
# it) against the pinned public key. ECDsaCng is used because it exists on both
# Windows PowerShell 5.1 and PowerShell 7 on Windows, and it wants the signature
# as raw r||s, so the DER sequence is unpacked first.
function Test-ReleaseSignature {
    param([string]$SumsPath, [string]$SigPath)

    $pem = Get-Content -LiteralPath $pubKeyPath -Raw
    $spki = [Convert]::FromBase64String(($pem -replace '-----[^-]+-----', '' -replace '\s', ''))
    # A P-256 SubjectPublicKeyInfo is 91 bytes; the uncompressed point (04||X||Y)
    # is the last 65 of them.
    if ($spki.Length -ne 91 -or $spki[26] -ne 0x04) { throw 'The pinned release key is not a P-256 public key.' }
    $x = $spki[27..58]
    $y = $spki[59..90]
    $blob = [byte[]](0x45, 0x43, 0x53, 0x31, 0x20, 0x00, 0x00, 0x00) + $x + $y   # "ECS1", 32
    $key = [System.Security.Cryptography.CngKey]::Import($blob, [System.Security.Cryptography.CngKeyBlobFormat]::EccPublicBlob)

    $der = [System.IO.File]::ReadAllBytes($SigPath)
    $i = 2
    if ($der[1] -band 0x80) { $i = 2 + ($der[1] -band 0x7f) }
    $parts = @()
    foreach ($n in 1..2) {
        if ($der[$i] -ne 0x02) { return $false }
        $len = $der[$i + 1]
        $val = [byte[]]$der[($i + 2)..($i + 1 + $len)]
        while ($val.Length -gt 32 -and $val[0] -eq 0) { $val = $val[1..($val.Length - 1)] }
        if ($val.Length -gt 32) { return $false }
        $parts += , ([byte[]](, 0 * (32 - $val.Length)) + $val)
        $i += 2 + $len
    }
    $p1363 = [byte[]]($parts[0] + $parts[1])

    $ecdsa = New-Object System.Security.Cryptography.ECDsaCng($key)
    $data = [System.IO.File]::ReadAllBytes($SumsPath)
    return $ecdsa.VerifyData($data, $p1363, [System.Security.Cryptography.HashAlgorithmName]::SHA256)
}

if (-not (Test-Path -LiteralPath $pubKeyPath)) {
  throw "Missing $pubKeyPath. This script must run from a complete checkout of $Repo."
}

$arch = switch ($env:PROCESSOR_ARCHITECTURE) {
  'AMD64' { 'amd64' }
  'ARM64' { 'arm64' }
  default { throw "Unsupported architecture: $env:PROCESSOR_ARCHITECTURE. Published targets: amd64 and arm64." }
}

# Asset names embed the version, and the rolling build's version carries a commit
# sha nobody can predict: ultragentic_0.0.0-main.<sha>_windows_amd64.exe. So the
# release JSON is the source of truth for what to download, rather than a URL
# assembled from guesses.
function Get-Release {
  param([string]$Endpoint)
  try {
    return Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/$Endpoint"
  } catch {
    return $null
  }
}

# Resolution order, matching install-runtime.sh:
#   1. an explicit version, when one was passed
#   2. the newest stable release
#   3. the rolling build from main, a prerelease the /releases/latest endpoint skips
function Resolve-Release {
  if ($Version -ne 'latest') {
    return Get-Release "tags/runtime/$Version"
  }

  Write-Host 'looking for a published release'
  $release = Get-Release 'latest'
  if ($release) { return $release }

  Write-Host 'no stable release yet, trying the rolling build from main'
  return Get-Release 'tags/runtime/latest'
}

Confirm-License

$release = Resolve-Release
if (-not $release) {
  throw "No published runtime release found for $Repo. See https://github.com/$Repo/releases"
}

# Match on the platform suffix rather than reconstructing the name, so this keeps
# working whatever the version string turned out to be.
$assetInfo = $release.assets | Where-Object { $_.name -like "*_windows_${arch}.exe" } | Select-Object -First 1
$sumsInfo = $release.assets | Where-Object { $_.name -eq 'SHA256SUMS' } | Select-Object -First 1
$sigInfo = $release.assets | Where-Object { $_.name -eq 'SHA256SUMS.sig' } | Select-Object -First 1
if (-not $assetInfo) { throw "Release $($release.tag_name) has no asset for windows/$arch." }
if (-not $sumsInfo) { throw 'That release has no SHA256SUMS; refusing to install an unverified binary.' }
if (-not $sigInfo) { throw 'That release has no SHA256SUMS.sig; refusing to install an unverified binary.' }

$asset = $assetInfo.name
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $temp -Force | Out-Null

try {
  Write-Host "downloading $asset"
  $downloaded = Join-Path $temp $asset
  $sums = Join-Path $temp 'SHA256SUMS'
  $sig = Join-Path $temp 'SHA256SUMS.sig'
  Invoke-WebRequest -Uri $assetInfo.browser_download_url -OutFile $downloaded -UseBasicParsing
  Invoke-WebRequest -Uri $sumsInfo.browser_download_url -OutFile $sums -UseBasicParsing
  Invoke-WebRequest -Uri $sigInfo.browser_download_url -OutFile $sig -UseBasicParsing

  Write-Host 'verifying signature'
  if (-not (Test-ReleaseSignature -SumsPath $sums -SigPath $sig)) {
    throw 'Signature check failed: SHA256SUMS was not signed by the ultragentic release key. Do not run this file.'
  }

  Write-Host 'verifying checksum'
  $line = (Select-String -Path $sums -Pattern ([regex]::Escape($asset) + '$') | Select-Object -First 1).Line
  if (-not $line) { throw "$asset is not listed in the signed SHA256SUMS." }
  $expected = ($line -replace '\s.*$', '').ToLower()
  $actual = (Get-FileHash -Path $downloaded -Algorithm SHA256).Hash.ToLower()
  if ($expected -ne $actual) { throw "Checksum mismatch for ${asset}; do not run this file." }

  New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
  $target = Join-Path $InstallDir $binary
  Install-Binary -Downloaded $downloaded -Target $target

  Add-ToUserPath -Directory $InstallDir
  Show-Result -Target $target
} finally {
  Remove-Item -Path $temp -Recurse -Force -ErrorAction SilentlyContinue
}
