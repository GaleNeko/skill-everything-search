---
name: everything-search
description: Fast file search on Windows using Everything search engine (es.exe CLI). Includes automatic pre-search validation, fuzzy matching. Requires es.exe for console output. Triggers on: 搜索文件、查找文件、全局搜索、帮我找、找到、找不到、搜一下、在哪里、全盘搜索。
---

# Everything Search

Fast local file search using the Everything search engine on Windows.

> **IMPORTANT**: Before running ANY search, ALWAYS execute the Pre-Search Validation Workflow below.
> Do not skip to search commands without completing validation.
> This applies to the first search in a session AND any subsequent searches where the error recovery decision tree indicates a re-check is needed.

## Overview

This skill enables rapid file discovery across the entire computer using Everything's instant indexing. It supports:
- Keyword and wildcard searches
- Path-specific searches
- File type filtering
- Sorting by size, date modified, date created
- Detailed output with file metadata
- Fuzzy matching for imprecise queries

## Critical: es.exe is NOT included with Everything

es.exe (the command-line interface) is a **separate download** from Everything.exe (the GUI application).
Installing Everything.exe alone does NOT provide `es` on the command line.

| Component | What it is | CLI Support |
|-----------|-----------|-------------|
| Everything.exe | GUI application (main program) | None (GUI only, cannot output to console) |
| es.exe | Command-line interface | Full console output, sorting, export |

If the user only has Everything.exe installed, `es` commands will fail with "command not found".
The Pre-Search Validation Workflow below handles this automatically.

## Pre-Search Validation Workflow

Execute these steps IN ORDER before performing any search.

### Step 1: Detect Everything Installation

Run these checks sequentially. Stop at the first that succeeds.

```powershell
# Check 1A: Registry (most reliable)
$regPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\VoidTools\Everything" -Name "InstallPath" -ErrorAction SilentlyContinue
if (-not $regPath) {
  # 32-bit Everything on 64-bit Windows
  $regPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\VoidTools\Everything" -Name "InstallPath" -ErrorAction SilentlyContinue
}
$everythingRoot = if ($regPath) { $regPath.InstallPath.TrimEnd('\') }

# Check 1B: Common installation paths
$commonPaths = @(
    "$env:ProgramFiles\Everything\Everything.exe",
    "${env:ProgramFiles(x86)}\Everything\Everything.exe",
    "$env:LOCALAPPDATA\Everything\Everything.exe",
    "$env:USERPROFILE\Everything\Everything.exe"
)
$existingExe = $commonPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($existingExe -and -not $everythingRoot) {
  $everythingRoot = Split-Path $existingExe -Parent
}

# Check 1C: Service binary path
if (-not $everythingRoot) {
  $svc = Get-CimInstance Win32_Service -Filter "Name='Everything'" -ErrorAction SilentlyContinue
  if ($svc -and $svc.PathName) {
    $everythingRoot = Split-Path ($svc.PathName -replace '"','') -Parent
  }
}

# Check 1D: where.exe
if (-not $everythingRoot) {
  $fromWhere = where.exe everything 2>$null | Select-Object -First 1
  if ($fromWhere) { $everythingRoot = Split-Path $fromWhere -Parent }
}

if (-not $everythingRoot) {
  Write-Warning "Everything is not installed or could not be detected."
  Write-Output "Please download and install Everything from: https://www.voidtools.com/downloads/"
  Write-Output "After installation, run this search again."
  return
}
Write-Output "Everything installation found: $everythingRoot"
```

### Step 2: Ensure Everything is Running

```powershell
$proc = Get-Process -Name "Everything" -ErrorAction SilentlyContinue
if (-not $proc) {
  $svc = Get-Service -Name "Everything" -ErrorAction SilentlyContinue
  if ($svc -and $svc.Status -eq 'Running') {
    Write-Output "Everything service is running"
  } else {
    Write-Output "Everything is not running. Attempting to start..."
    $everythingExe = Join-Path $everythingRoot "Everything.exe"
    if (Test-Path $everythingExe) {
      Start-Process -FilePath $everythingExe
      Start-Sleep -Seconds 3
      $proc = Get-Process -Name "Everything" -ErrorAction SilentlyContinue
      if ($proc) {
        Write-Output "Everything started successfully (PID: $($proc.Id))"
      } else {
        Write-Warning "Failed to start Everything automatically."
        Write-Output "Please start Everything manually and retry."
        return
      }
    } else {
      Write-Warning "Cannot find Everything.exe at $everythingExe"
      Write-Output "Please start Everything manually and retry."
      return
    }
  }
} else {
  Write-Output "Everything process is running (PID: $($proc.Id))"
}
```

### Step 3: Check es.exe Availability

```powershell
# Check in PATH first
$esPath = (Get-Command "es.exe" -ErrorAction SilentlyContinue).Source

# Check alongside Everything.exe
if (-not $esPath) {
  $esInEverythingDir = Join-Path $everythingRoot "es.exe"
  if (Test-Path $esInEverythingDir) { $esPath = $esInEverythingDir }
}

if (-not $esPath) {
  Write-Warning "es.exe is not installed."
  Write-Output "Attempting to download es.exe to Everything directory..."

  $esDownloadUrl = "https://www.voidtools.com/es.exe"
  $esTarget = Join-Path $everythingRoot "es.exe"

  # Fallback to LOCALAPPDATA if Everything dir is not writable
  if (-not (Test-Path $everythingRoot -Path Container -IsReadOnly -EA SilentlyContinue)) {
    $altDir = "$env:LOCALAPPDATA\Everything"
    if (-not (Test-Path $altDir)) { New-Item -ItemType Directory -Path $altDir -Force | Out-Null }
    $esTarget = "$altDir\es.exe"
  }

  try {
    Invoke-WebRequest -Uri $esDownloadUrl -OutFile $esTarget -TimeoutSec 15
    if (Test-Path $esTarget) {
      Write-Output "es.exe downloaded to: $esTarget"
      $esPath = $esTarget
    }
  } catch {
    Write-Warning "Failed to download es.exe: $_"
  }
}

if ($esPath) {
  Write-Output "es.exe is available at: $esPath"
} else {
  Write-Warning "es.exe is NOT available and auto-download failed. Search cannot proceed without es.exe."
  Write-Output "To install manually: download from https://www.voidtools.com/es.exe"
  Write-Output "and place it in $everythingRoot or a directory in your PATH."
  return
}
```

### Step 4: Execute Search

Once validation passes, use `& "$esPath"` for all searches (full console output).
If `$esPath` is not set at this point, search cannot proceed — report the error to the user.

## How to Install es.exe

es.exe is a single-file executable (~100KB). No installer needed.

```powershell
# Option 1: Download directly (admin not required if writing to %LOCALAPPDATA%)
$target = "$env:LOCALAPPDATA\Everything"
if (-not (Test-Path $target)) { New-Item -ItemType Directory -Path $target -Force | Out-Null }
Invoke-WebRequest -Uri "https://www.voidtools.com/es.exe" -OutFile "$target\es.exe"

# Add to PATH (optional)
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";$target", "User")

# Verify
es -version
```

Expected output: `ES 1.1.0.23`

## Post-Installation and Indexing Guidance

Everything indexes files using one of two methods depending on your filesystem:

### NTFS Drives (Recommended, Default for C:)
- Uses the NTFS USN Journal (change journal)
- Indexing is **instantaneous** — no initial scan needed
- Updates are **real-time** — no rescan is ever needed

### ReFS / FAT32 / exFAT / Network Drives
- Everything must do a full folder scan
- Initial indexing can take **minutes to hours** depending on size
- Periodic rescans ARE required (configure in Everything: Tools > Options > Indexes)
- es.exe may return "no results" if indexing is not yet complete

### Checking Index Status
es.exe has no built-in status command. To check:
- Try a broad search: `es *` — empty results on a non-NTFS volume may mean indexing is still in progress
- Open the Everything GUI and check the status bar (bottom-right): shows "Indexing X files..." or "Indexing complete"

## Search Commands Reference

### Basic File Search

Search by filename or partial match:

```powershell
# Exact filename
es "budget.xlsx"

# Partial match (wildcard)
es *budget*

# File extension
es *.mp4

# Multiple extensions
es *.mp4 *.avi *.mkv
```

### Path-Based Search

Limit search to specific directories:

```powershell
# Search within a folder
es -path "D:\Downloads" *.exe

# Search parent directory
es -parent "C:\Users\Admin" *.txt

# Everything syntax
path:Downloads *.pdf
```

### Sorting Results

```powershell
# Sort by name (default)
es -sort name *.pdf

# Sort by size (largest first)
es -sort size

# Sort by date modified (newest first)
es -sort date-modified

# Sort ascending
es -sort name -sort-ascending
```

### Detailed Output Columns

```powershell
# Show all available columns
es -size -date-modified -date-created -extension *.docx

# Common combinations
es -size -dm *.zip          # Size + Date Modified
es -size -dc -dm *.log      # Size + Created + Modified
```

Available columns:
- `-size` or `-s` — File size
- `-date-modified` or `-dm` — Last modified date
- `-date-created` or `-dc` — Creation date
- `-date-accessed` or `-da` — Last accessed date
- `-extension` or `-ext` — File extension
- `-attributes` or `-attrib` — File attributes

### Limiting Results

```powershell
# Show only first 20 results
es -n 20 *.jpg

# Show results starting from offset
es -o 10 -n 5 *.png
```

## Fuzzy Search Support

When the user's query is imprecise or partial, use these strategies:

### Strategy 1: Wildcard Expansion

Add wildcards to partial terms:

```powershell
# User says: "find my budget file"
# Try multiple patterns:
es *budget*           # Contains "budget"
es budget*            # Starts with "budget"
es *budget*.xlsx      # Budget Excel files
es *budget*.docx      # Budget Word files
```

### Strategy 2: Multiple Extensions

When file type is unclear:

```powershell
# User says: "find the presentation"
# Try common presentation formats:
es *presentation*.pptx
es *presentation*.ppt
es *presentation*.pdf
es *presentation*
```

### Strategy 3: Broader Search with Filtering

```powershell
# User says: "that large video file from last week"
# Search broadly then sort/filter:
es -sort size -n 20 *.mp4
es -sort date-modified -n 20 *.mp4 *.avi *.mkv
```

### Strategy 4: Smart Result Presentation

When multiple matches exist, present results intelligently:

1. **Group by relevance** — Exact matches first, then partial
2. **Group by location** — Group files by parent directory
3. **Highlight metadata** — Show size and dates to help identify
4. **Offer disambiguation** — Ask user to clarify if too many matches

## Common Search Patterns

### Find Large Files

```powershell
# Largest files overall
es -sort size -n 20

# Large videos
es -sort size -n 10 *.mp4 *.avi *.mkv
```

### Find Recent Files

```powershell
# Recently modified
es -sort date-modified -n 20

# Modified today
es -sort dm -n 50 *.docx *.xlsx
```

### Find Duplicates (by name)

```powershell
# Search for common duplicate patterns
es (1).* *.copy.* *-副本.*
```

## Exporting Results

```powershell
# Export to CSV
es *.pdf -export-csv results.csv

# Export to text file
es *.docx -export-txt documents.txt

# Export to EFU (Everything File List)
es *.mp3 -export-efu music.efu
```

## Search Syntax Reference

Everything supports powerful search syntax:

| Syntax | Description | Example |
|--------|-------------|---------|
| `*` | Wildcard (any characters) | `*.txt` |
| `?` | Single character wildcard | `file?.docx` |
| `\|` | OR operator | `.jpg \| .png` |
| `!` | NOT operator | `!*.tmp` |
| `< >` | Grouping | `<*.jpg \| *.png>` |
| `""` | Exact phrase | `"annual report"` |
| `path:` | Search in path | `path:Downloads` |
| `size:` | Filter by size | `size:>1gb` |
| `dm:` | Date modified | `dm:today` |

See `references/search-syntax.md` for complete syntax guide.

## Error Recovery Decision Tree

When a search fails, follow this decision tree:

### "es.exe" / "es" command not found
- **Cause**: es.exe is not installed or not in PATH
- **Check**: Run Pre-Search Validation Step 3
- **Fix**: Auto-download by running Step 3, or manually download from https://www.voidtools.com/es.exe

### "Everything IPC window not found"
- **Cause**: Everything is not running, or es.exe cannot communicate with Everything
- **Check**: `Get-Process Everything -ErrorAction SilentlyContinue`
- **Check**: `Get-Service Everything -ErrorAction SilentlyContinue`
- **Fix**: Run Pre-Search Validation Step 2 to start Everything automatically

### es.exe returns empty / "no files found"
- **Cause A**: No files match the query (legitimate)
- **Cause B**: Indexing not yet complete (non-NTFS volumes)
- **Cause C**: Everything is running but not indexing the target volume
- **Check A**: Try a broad search: `es *`
- **Check B**: If on non-NTFS, check indexing status in Everything GUI
- **Check C**: Confirm target drive is indexed: Everything > Tools > Options > Indexes

### Everything is installed but won't start
- **Cause A**: Everything service is disabled
- **Cause B**: Corrupted configuration
- **Fix A**: `Set-Service -Name Everything -StartupType Automatic; Start-Service Everything`
- **Fix B**: Delete or rename `%APPDATA%\Everything\Everything.ini` and restart

### "Permission denied" / Access denied
- **Cause**: Protected system folders
- **Fix**: Run PowerShell as Administrator and retry

## Best Practices

1. **es.exe is required** — Everything.exe GUI cannot output to console, so all searches must go through es.exe
2. **Limit results** — Use `-n` to avoid overwhelming output
3. **Sort strategically** — Sort by size or date to find what matters
4. **Combine filters** — Use path + extension for precise searches
5. **Export for large sets** — Use `-export-*` options for processing results
6. **Always validate first** — Never skip the Pre-Search Validation Workflow
7. **NTFS preferred** — For best performance, keep files on NTFS volumes

## Resources

- `references/es-download.md` — ES.exe installation guide with full details
- `references/search-syntax.md` — Complete Everything search syntax reference
- Download Everything: https://www.voidtools.com/downloads/
- Download es.exe: https://www.voidtools.com/es.exe
