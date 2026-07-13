# Standalone es.exe installer
# Downloads es.exe to %LOCALAPPDATA%\Everything\ and optionally adds to PATH
param(
    [switch]$AddToPath
)

$ErrorActionPreference = "Stop"
$targetDir = "$env:LOCALAPPDATA\Everything"
$targetFile = Join-Path $targetDir "es.exe"
$downloadUrl = "https://www.voidtools.com/es.exe"

Write-Output "=== es.exe Installer ==="

# Create target directory
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    Write-Output "Created: $targetDir"
}

# Check if already installed
if (Test-Path $targetFile) {
    $version = & $targetFile -version 2>&1
    Write-Output "es.exe already installed at: $targetFile"
    Write-Output "Version: $version"
} else {
    # Download
    Write-Output "Downloading es.exe from $downloadUrl ..."
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $targetFile -TimeoutSec 30
        if (Test-Path $targetFile) {
            $size = (Get-Item $targetFile).Length
            Write-Output "Downloaded: $targetFile ($size bytes)"
        } else {
            Write-Output "ERROR: Download completed but file not found."
            exit 1
        }
    } catch {
        Write-Output "ERROR: Download failed: $_"
        exit 1
    }

    # Verify
    $version = & $targetFile -version 2>&1
    Write-Output "Version: $version"
}

# Add to PATH
if ($AddToPath) {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$targetDir*") {
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$targetDir", "User")
        Write-Output "Added to user PATH: $targetDir"
        Write-Output "NOTE: Restart your terminal for PATH changes to take effect."
    } else {
        Write-Output "Already in PATH: $targetDir"
    }
} else {
    Write-Output ""
    Write-Output "To add to PATH, run: scripts/install-es.ps1 -AddToPath"
    Write-Output "Or use directly: & '$targetFile' <search>"
}

Write-Output "=== Done ==="
