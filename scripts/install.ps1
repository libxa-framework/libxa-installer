<#
.SYNOPSIS
    Install the LibxaFrame installer and put `libxa` on your PATH.

.DESCRIPTION
    Downloads the `libxa` executable for this machine from the releases page
    and installs it for the current user.

    Nothing here needs administrator rights: the program goes in your local
    application directory and the PATH entry is the per-user one, which is also
    why the machine-wide PATH is never touched.

    There is no Python or PHP requirement for the installer itself. The
    applications it creates need PHP and Composer.

.PARAMETER Version
    A specific version to install, for example 1.0.0. Defaults to the latest.

.EXAMPLE
    irm https://raw.githubusercontent.com/libxa-framework/libxa-installer/main/scripts/install.ps1 | iex

.EXAMPLE
    .\install.ps1 -Version 1.0.0
#>

[CmdletBinding()]
param(
    [string] $Version
)

$ErrorActionPreference = 'Stop'

$Repository = 'libxa-framework/libxa-installer'
$InstallDir = Join-Path $env:LOCALAPPDATA 'Programs\libxa'

function Write-Step($Message) { Write-Host "  $Message" -ForegroundColor DarkGray }
function Write-Ok($Message)   { Write-Host "  $Message" -ForegroundColor Green }
function Write-Warn($Message) { Write-Host "  $Message" -ForegroundColor Yellow }

function Stop-WithError($Message) {
    Write-Host ''
    Write-Host "  $Message" -ForegroundColor Red
    Write-Host ''
    exit 1
}

Write-Host ''
Write-Host '  LibxaFrame' -ForegroundColor Yellow -NoNewline
Write-Host ' installer setup'
Write-Host ''

# ── Which build ──────────────────────────────────────────────────────────

$architecture = if ([Environment]::Is64BitOperatingSystem) {
    if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64' -or $env:PROCESSOR_ARCHITEW6432 -eq 'ARM64') { 'arm64' } else { 'x64' }
} else {
    Stop-WithError '32-bit Windows is not supported.'
}

$asset = "libxa-windows-$architecture.exe"

$uri = if ($Version) {
    "https://github.com/$Repository/releases/download/v$Version/$asset"
} else {
    "https://github.com/$Repository/releases/latest/download/$asset"
}

# ── Download ─────────────────────────────────────────────────────────────
#
# To a temporary file first. Writing straight over the installed command means
# a failed or interrupted download replaces a working install with a truncated
# one, and the next run reports something that looks nothing like a network
# problem.

$temporary = Join-Path ([IO.Path]::GetTempPath()) "libxa-$([guid]::NewGuid()).exe"

Write-Step "Downloading $asset"

try {
    # TLS 1.2 has to be asked for on Windows PowerShell 5.1, which still
    # defaults to protocols GitHub no longer accepts.
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $uri -OutFile $temporary -UseBasicParsing
}
catch {
    if ($Version) {
        Stop-WithError "Could not download version $Version. Check https://github.com/$Repository/releases for the versions that exist."
    }

    Stop-WithError "Could not download $asset. $($_.Exception.Message)"
}

if (-not (Test-Path $temporary) -or (Get-Item $temporary).Length -eq 0) {
    Stop-WithError 'The download produced an empty file.'
}

# ── Install ──────────────────────────────────────────────────────────────

if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

$target = Join-Path $InstallDir 'libxa.exe'

try {
    Move-Item -Path $temporary -Destination $target -Force
}
catch {
    Remove-Item $temporary -ErrorAction SilentlyContinue
    Stop-WithError "Could not write to $InstallDir. Close any running libxa and try again."
}

Write-Ok "Installed to $target"

# ── PATH ─────────────────────────────────────────────────────────────────

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$entries = ($userPath -split ';') | Where-Object { $_ }

if ($entries -contains $InstallDir) {
    Write-Step 'Already on your PATH.'
}
else {
    # User scope, not Machine: no elevation, and it cannot damage the system
    # PATH that everything else on the machine depends on.
    $updated = if ($userPath) { "$userPath;$InstallDir" } else { $InstallDir }
    [Environment]::SetEnvironmentVariable('Path', $updated, 'User')

    # The line above only reaches new processes, so this session is updated too
    # and `libxa` works without opening another terminal.
    $env:Path = "$env:Path;$InstallDir"

    Write-Ok "Added $InstallDir to your PATH."
}

Write-Host ''

$reported = & $target --version 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Ok "Installed $reported"
}
else {
    Write-Warn 'Installed, but the command did not run. Report this at:'
    Write-Warn "https://github.com/$Repository/issues"
}

Write-Host ''
Write-Host '  Try it:' -ForegroundColor DarkGray
Write-Host '    libxa new my-app' -ForegroundColor Yellow
Write-Host ''
Write-Host '  If the command is not found, open a new terminal first.' -ForegroundColor DarkGray
Write-Host ''
