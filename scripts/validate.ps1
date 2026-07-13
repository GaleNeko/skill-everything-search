# Pre-Search Validation Workflow (Steps 1-3)
# Detects Everything, ensures it's running, and locates es.exe
$ErrorActionPreference = "Continue"

# ===== Step 1: Detect Everything Installation =====
Write-Output "=== Step 1: Detect Everything Installation ==="
$everythingRoot = $null

$regPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\VoidTools\Everything" -Name "InstallPath" -ErrorAction SilentlyContinue
if (-not $regPath) {
    $regPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\VoidTools\Everything" -Name "InstallPath" -ErrorAction SilentlyContinue
}
if ($regPath) {
    $everythingRoot = $regPath.InstallPath.TrimEnd('\')
}

if (-not $everythingRoot) {
    $commonPaths = @(
        "$env:ProgramFiles\Everything\Everything.exe",
        "${env:ProgramFiles(x86)}\Everything\Everything.exe",
        "$env:LOCALAPPDATA\Everything\Everything.exe",
        "$env:USERPROFILE\Everything\Everything.exe"
    )
    $existingExe = $commonPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($existingExe) { $everythingRoot = Split-Path $existingExe -Parent }
}

if (-not $everythingRoot) {
    $svc = Get-CimInstance Win32_Service -Filter "Name='Everything'" -ErrorAction SilentlyContinue
    if ($svc -and $svc.PathName) {
        $everythingRoot = Split-Path ($svc.PathName -replace '"','') -Parent
    }
}

if (-not $everythingRoot) {
    $fromWhere = where.exe everything 2>$null | Select-Object -First 1
    if ($fromWhere) { $everythingRoot = Split-Path $fromWhere -Parent }
}

if (-not $everythingRoot) {
    Write-Output "ERROR: Everything is not installed or could not be detected."
    Write-Output "Download: https://www.voidtools.com/downloads/"
    exit 1
}
Write-Output "OK: Everything found at: $everythingRoot"

# ===== Step 2: Ensure Everything is Running =====
Write-Output ""
Write-Output "=== Step 2: Ensure Everything is Running ==="
$proc = Get-Process -Name "Everything" -ErrorAction SilentlyContinue
if (-not $proc) {
    $svc = Get-Service -Name "Everything" -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        Write-Output "OK: Everything service is running"
    } else {
        Write-Output "INFO: Everything is not running. Attempting to start..."
        $everythingExe = Join-Path $everythingRoot "Everything.exe"
        if (Test-Path $everythingExe) {
            Start-Process -FilePath $everythingExe
            Start-Sleep -Seconds 3
            $proc = Get-Process -Name "Everything" -ErrorAction SilentlyContinue
            if ($proc) {
                Write-Output "OK: Everything started (PID: $($proc.Id))"
            } else {
                Write-Output "ERROR: Failed to start Everything automatically."
                Write-Output "Please start Everything manually and retry."
                exit 1
            }
        } else {
            Write-Output "ERROR: Cannot find Everything.exe at $everythingExe"
            exit 1
        }
    }
} else {
    Write-Output "OK: Everything process is running (PID: $($proc.Id))"
}

# ===== Step 3: Check es.exe Availability =====
Write-Output ""
Write-Output "=== Step 3: Check es.exe Availability ==="
$esPath = (Get-Command "es.exe" -ErrorAction SilentlyContinue).Source

if (-not $esPath) {
    $esInEverythingDir = Join-Path $everythingRoot "es.exe"
    if (Test-Path $esInEverythingDir) { $esPath = $esInEverythingDir }
}

if (-not $esPath) {
    Write-Output "INFO: es.exe not found. Attempting auto-download..."

    $esTarget = Join-Path $everythingRoot "es.exe"
    try {
        $null = New-Item -ItemType Directory -Path $everythingRoot -Force -ErrorAction SilentlyContinue
        Invoke-WebRequest -Uri "https://www.voidtools.com/es.exe" -OutFile $esTarget -TimeoutSec 15
        if (Test-Path $esTarget) {
            Write-Output "OK: es.exe downloaded to: $esTarget"
            $esPath = $esTarget
        }
    } catch {
        Write-Output "WARN: Could not save to Everything dir, trying LOCALAPPDATA..."
        $altDir = "$env:LOCALAPPDATA\Everything"
        if (-not (Test-Path $altDir)) { New-Item -ItemType Directory -Path $altDir -Force | Out-Null }
        $esTarget = "$altDir\es.exe"
        try {
            Invoke-WebRequest -Uri "https://www.voidtools.com/es.exe" -OutFile $esTarget -TimeoutSec 15
            if (Test-Path $esTarget) {
                Write-Output "OK: es.exe downloaded to: $esTarget"
                $esPath = $esTarget
            }
        } catch {
            Write-Output "ERROR: Failed to download es.exe: $_"
        }
    }
}

if ($esPath) {
    Write-Output "OK: es.exe available at: $esPath"

    # Test es.exe
    $version = & "$esPath" -version 2>&1
    Write-Output "INFO: Version: $version"

    # Quick test search
    $testResult = & "$esPath" -n 3 * 2>&1
    if ($testResult -and $testResult.Count -gt 0) {
        Write-Output "OK: Test search returned $($testResult.Count) results. Everything is working!"
    } else {
        Write-Output "WARN: Test search returned no results. Indexing may be incomplete."
    }

    # Output final result for the caller
    Write-Output ""
    Write-Output "=== VALIDATION COMPLETE ==="
    Write-Output "ES_PATH=$esPath"
    Write-Output "EVERYTHING_ROOT=$everythingRoot"
} else {
    Write-Output "ERROR: es.exe is NOT available and auto-download failed."
    Write-Output "Manual download: https://www.voidtools.com/es.exe"
    Write-Output "Place it in: $everythingRoot or a directory in your PATH."
    exit 1
}
