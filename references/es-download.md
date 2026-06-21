# ES.exe Installation Guide

> **NOTE**: The Pre-Search Validation Workflow in SKILL.md automatically detects and handles es.exe
> installation. Use this reference for manual installation or additional troubleshooting.

ES (Everything Search) is the official command-line interface for Everything.

## What is ES.exe?

ES.exe allows you to search Everything from the command line and get results printed to the console. Unlike Everything.exe which opens a GUI window, ES.exe outputs results directly to the terminal, making it ideal for:
- Scripts and automation
- Integration with other tools
- Quick command-line searches
- Exporting results to files

## Download

### Official Download

1. Visit: https://www.voidtools.com/downloads/
2. Download the "Command-line Interface" version
3. Extract the ZIP file

### Direct Links

- 64-bit: https://www.voidtools.com/es.exe
- 32-bit: https://www.voidtools.com/es-386.exe

## Installation

### Option 1: Add to PATH (Recommended)

1. Download `es.exe`
2. Place it in a directory like `C:\Tools\` or `C:\Windows\`
3. Add that directory to your system PATH

```powershell
# Add to PATH via PowerShell (run as admin)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Tools", "Machine")
```

### Option 2: Place in Everything Directory

1. Copy `es.exe` to your Everything installation folder:
   - `C:\Program Files\Everything\`
   - Or your portable Everything directory

### Option 3: Use Full Path

Reference es.exe by full path in commands:

```powershell
& "C:\Tools\es.exe" *.pdf
```

## Verification

Test the installation:

```powershell
es -version
```

Should output version information like:
```
ES 1.1.0.23
```

## Basic Usage

Once installed, use `es` instead of `everything.exe`:

```powershell
# Search for files
es *.pdf

# Detailed output
es -size -date-modified *.docx

# Export to file
es *.mp3 -export-txt songs.txt
```

## Troubleshooting

### "Everything IPC window not found"

- Make sure Everything is running
- Check that the Everything service is running
- Run the Pre-Search Validation Workflow in SKILL.md for automatic detection and repair

### No output

- Verify Everything has finished indexing
- For non-NTFS volumes, indexing may still be in progress (see SKILL.md for NTFS vs non-NTFS guidance)
- Try a simple search first: `es *`

### Permission denied

- Some system folders require administrator access
- Run PowerShell/Command Prompt as administrator if needed

## Differences from Everything.exe

| Feature | Everything.exe | ES.exe |
|---------|---------------|--------|
| Output | GUI window | Console/stdout |
| Export | Limited | Full support |
| Sorting | GUI only | Command-line flags |
| Scripting | Difficult | Easy |
| Interactive | Yes | No |

## Resources

- Official documentation: https://www.voidtools.com/support/everything/command_line_interface/
- Download page: https://www.voidtools.com/downloads/
