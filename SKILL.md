---
name: everything-search
description: Fast file search on Windows using Everything search engine. Use when the user wants to find files on their computer, search by name/type/location, or locate recently modified files. Supports fuzzy matching - when the user's query is imprecise, gather all potential matches and present the most relevant results. Works with both es.exe CLI (recommended) and Everything.exe GUI.
---

# Everything Search

Fast local file search using the Everything search engine on Windows.

## Overview

This skill enables rapid file discovery across the entire computer using Everything's instant indexing. It supports:
- Keyword and wildcard searches
- Path-specific searches
- File type filtering
- Sorting by size, date modified, date created
- Detailed output with file metadata
- Fuzzy matching for imprecise queries

## Prerequisites

Everything must be installed and running. The skill works with:
1. **es.exe** (recommended) - Command-line interface, outputs to console
2. **Everything.exe** - Main application with limited CLI support

### Finding Everything

Common installation paths:
- `C:\Program Files\Everything\Everything.exe`
- `C:\Program Files (x86)\Everything\Everything.exe`
- Portable installations in user directories

### Installing ES.exe (Optional but Recommended)

ES.exe provides better CLI output. Download from: https://www.voidtools.com/downloads/

## Quick Start

### Basic Search

```powershell
# Search for files containing "report"
es report

# Search for PDF files
es *.pdf

# Search in specific directory
es -path "D:\Documents" *.docx
```

### Detailed Results

```powershell
# Show path, size, and modification date
es -size -date-modified *.zip

# Sort by size (largest first)
es -sort size *.iso

# Limit to top 10 results
es -n 10 -sort date-modified
```

## Search Capabilities

### 1. Basic File Search

Search by filename or partial match:

```powershell
# Exact filename
es "budget.xlsx"

# Partial match (wildcard)
es *budget*

# File extension
es *.mp4
```

### 2. Path-Based Search

Limit search to specific directories:

```powershell
# Search within a folder
es -path "D:\Downloads" *.exe

# Search parent directory
es -parent "C:\Users\Admin" *.txt
```

### 3. Sorting Results

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

### 4. Detailed Output Columns

```powershell
# Show all available columns
es -size -date-modified -date-created -extension *.docx

# Common combinations
es -size -dm *.zip          # Size + Date Modified
es -size -dc -dm *.log      # Size + Created + Modified
```

Available columns:
- `-size` or `-s` - File size
- `-date-modified` or `-dm` - Last modified date
- `-date-created` or `-dc` - Creation date
- `-date-accessed` or `-da` - Last accessed date
- `-extension` or `-ext` - File extension
- `-attributes` or `-attrib` - File attributes

### 5. Limiting Results

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

1. **Group by relevance** - Exact matches first, then partial
2. **Group by location** - Group files by parent directory
3. **Highlight metadata** - Show size and dates to help identify
4. **Offer disambiguation** - Ask user to clarify if too many matches

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

## Using Everything.exe (Fallback)

If es.exe is not available, use Everything.exe with limited output:

```powershell
# Open Everything with search term
& "C:\Program Files\Everything\Everything.exe" -s "*.pdf"

# Search with path filter
& "C:\Program Files\Everything\Everything.exe" -s "path:D:\Downloads *.zip"
```

Note: Everything.exe opens the GUI window; results are not returned to console.

## Search Syntax Reference

Everything supports powerful search syntax:

| Syntax | Description | Example |
|--------|-------------|---------|
| `*` | Wildcard (any characters) | `*.txt` |
| `?` | Single character wildcard | `file?.docx` |
| `|` | OR operator | `.jpg | .png` |
| `!` | NOT operator | `!*.tmp` |
| `< >` | Grouping | `<*.jpg | *.png>` |
| `""` | Exact phrase | `"annual report"` |
| `path:` | Search in path | `path:Downloads` |
| `size:` | Filter by size | `size:>1gb` |
| `dm:` | Date modified | `dm:today` |

See `references/search-syntax.md` for complete syntax guide.

## Error Handling

Common issues and solutions:

| Error | Cause | Solution |
|-------|-------|----------|
| "Everything IPC window not found" | Everything not running | Start Everything application |
| No results | Index not complete | Wait for Everything to finish indexing |
| Permission denied | Protected folders | Run as administrator if needed |

## Best Practices

1. **Use es.exe when possible** - Better console output and scripting support
2. **Limit results** - Use `-n` to avoid overwhelming output
3. **Sort strategically** - Sort by size or date to find what matters
4. **Combine filters** - Use path + extension for precise searches
5. **Export for large sets** - Use `-export-*` options for processing results

## Resources

- `references/search-syntax.md` - Complete search syntax reference
- `references/es-download.md` - ES.exe installation guide
