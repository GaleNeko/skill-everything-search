# skill-everything-search

Fast local file search on Windows using the [Everything](https://www.voidtools.com/) search engine.

This is a **Claude Code skill** — a set of instructions that guides Claude to search files via `es.exe` (Everything's command-line interface) and return results directly in the chat.

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| **Windows OS** | Everything is Windows-only |
| **Everything** | Install from [voidtools.com](https://www.voidtools.com/downloads/) |
| **es.exe** | **Separate download** — not included with Everything. The skill auto-downloads it if missing. |
| **Claude Code** | Running on Windows with PowerShell access |

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
# "find my budget file" → es *budget*, es *budget*.xlsx, etc.
```

## Manual Installation

If you prefer to install `es.exe` manually instead of relying on auto-download:

```powershell
# Download to your Everything directory
Invoke-WebRequest -Uri "https://www.voidtools.com/es.exe" -OutFile "$env:ProgramFiles\Everything\es.exe"

# Or download to a PATH directory
Invoke-WebRequest -Uri "https://www.voidtools.com/es.exe" -OutFile "$env:USERPROFILE\Tools\es.exe"

# Verify
es -version
```

## Troubleshooting

| Problem | Likely Cause | Fix |
|---------|-------------|-----|
| "es.exe command not found" | es.exe not installed | Skill auto-downloads it — or manually download from voidtools.com |
| "Everything IPC window not found" | Everything not running | Skill starts it automatically |
| No results | Index not complete (non-NTFS) | Check indexing status in Everything GUI |
| Permission denied | Protected folder | Run PowerShell as Administrator |

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill instruction set (pre-validation, search commands, error handling) |
| `references/es-download.md` | Detailed es.exe installation guide |
| `references/search-syntax.md` | Complete Everything search syntax reference |

## Links

- [Download Everything](https://www.voidtools.com/downloads/)
- [Download es.exe](https://www.voidtools.com/es.exe)
- [Everything Documentation](https://www.voidtools.com/support/everything/)
