English | [中文](README.md)

# skill-everything-search

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows-blue.svg)](https://www.voidtools.com/)

Fast local file search on Windows using the [Everything](https://www.voidtools.com/) search engine.

This is a **Claude Code Skill** — a set of instructions that guides Claude to search files via `es.exe` (Everything's command-line interface) and return results directly in the chat. It features automatic pre-search validation, multi-keyword fuzzy matching, result sorting, and export.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Search Examples](#search-examples)
- [Troubleshooting](#troubleshooting)
- [Files](#files)
- [Links](#links)
- [License](#license)

## Requirements

| Dependency | Notes |
|------------|-------|
| **Windows OS** | Everything is Windows-only |
| **Everything** | Install from [voidtools.com](https://www.voidtools.com/downloads/) |
| **es.exe** | Command-line tool, **separate download**. The skill auto-downloads it if missing |
| **Claude Code** | Running on Windows with PowerShell access |

## Installation

### Automatic Installation

The skill automatically detects your environment and downloads `es.exe` on first use — no manual action required.

### Manual Installation of es.exe

If you prefer to install `es.exe` manually instead of relying on auto-download:

```powershell
# Download to your Everything directory
Invoke-WebRequest -Uri "https://www.voidtools.com/es.exe" -OutFile "$env:ProgramFiles\Everything\es.exe"

# Or download to a custom path
Invoke-WebRequest -Uri "https://www.voidtools.com/es.exe" -OutFile "$env:USERPROFILE\Tools\es.exe"

# Verify installation
es -version
```

Or use the bundled installation script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-es.ps1

# To add to PATH
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-es.ps1 -AddToPath
```

## Quick Start

Once Everything is installed, just ask Claude to find files:

> "Find my budget spreadsheet"
> "Search for all PDF files in Downloads"
> "Find large video files from last week"

The skill triggers automatically. Claude will:
1. Validate the environment (Everything + es.exe)
2. Run the appropriate `es.exe` command
3. Return results with file paths, sizes, and dates

## Search Examples

```powershell
# By name
es "budget.xlsx"
es *report*
es *.pdf

# By location
es -path "D:\Downloads" *.exe

# With metadata
es -size -date-modified *.zip

# Sorted results
es -sort size -n 20
es -sort date-modified -n 50

# Fuzzy matching (Claude tries multiple patterns automatically)
# "find my budget file" -> es *budget*, es *budget*.xlsx, etc.
```

## Troubleshooting

| Problem | Likely Cause | Fix |
|---------|-------------|-----|
| "es.exe command not found" | es.exe not installed | Skill auto-downloads it — or manually download from voidtools.com |
| "Everything IPC window not found" | Everything not running | Skill starts it automatically |
| No results | Index not complete (non-NTFS drive) | Check indexing status in Everything GUI |
| Permission denied | Protected folder | Run PowerShell as Administrator |

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Core skill instruction set (pre-validation, search commands, error handling) |
| `scripts/validate.ps1` | Environment validation script (detect Everything, start service, download es.exe) |
| `scripts/install-es.ps1` | Standalone es.exe installer |
| `references/search-commands.md` | Full es.exe CLI reference (sorting, columns, export, search patterns) |
| `references/indexing.md` | NTFS vs non-NTFS file system indexing behavior |

## Links

- [Download Everything](https://www.voidtools.com/downloads/)
- [Download es.exe](https://www.voidtools.com/es.exe)
- [Everything Documentation](https://www.voidtools.com/support/everything/)

## License

This project is released under the [MIT License](LICENSE).
