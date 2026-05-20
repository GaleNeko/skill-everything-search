# Everything Search Syntax Reference

Complete reference for Everything search syntax.

## Basic Syntax

### Wildcards

| Pattern | Matches | Example |
|---------|---------|---------|
| `*` | Zero or more characters | `*.txt` matches all text files |
| `?` | Exactly one character | `file?.docx` matches file1.docx, fileA.docx |

### Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `|` | OR - match either term | `.jpg | .png` matches jpg OR png files |
| `!` | NOT - exclude matches | `!*.tmp` excludes tmp files |
| `< >` | Grouping | `<*.jpg | *.png> size:>1mb` |
| `""` | Exact phrase | `"annual report"` matches exact phrase |

## Search Functions

### Path Search

| Function | Description | Example |
|----------|-------------|---------|
| `path:` | Search in full path | `path:Downloads` |
| `parent:` | Search parent folder | `parent:C:\Users` |
| `child:` | Search subfolders | `child:Documents file.txt` |

### Size Filters

| Syntax | Description | Example |
|--------|-------------|---------|
| `size:` | Exact size | `size:1mb` |
| `size:>` | Larger than | `size:>100mb` |
| `size:<` | Smaller than | `size:<1kb` |
| `size:>=` | Larger or equal | `size:>=1gb` |

Size units: `b` (bytes), `kb`, `mb`, `gb`, `tb`

### Date Filters

| Function | Description | Example |
|----------|-------------|---------|
| `dm:` | Date modified | `dm:today` |
| `dc:` | Date created | `dc:yesterday` |
| `da:` | Date accessed | `da:lastweek` |

Date keywords:
- `today`, `yesterday`
- `thisweek`, `lastweek`
- `thismonth`, `lastmonth`
- `thisyear`, `lastyear`

Date ranges:
- `dm:2024-01-01..2024-12-31`
- `dm:last2hours`
- `dm:last5mins`

### Attribute Filters

| Function | Description | Example |
|----------|-------------|---------|
| `attrib:` | File attributes | `attrib:H` (hidden) |

Attribute codes:
- `R` - Read-only
- `H` - Hidden
- `S` - System
- `D` - Directory
- `A` - Archive
- `N` - Normal

## Advanced Examples

### Complex Queries

```
# Large video files in Downloads
path:Downloads <*.mp4 | *.avi | *.mkv> size:>500mb

# Documents modified this week
<*.docx | *.xlsx | *.pdf> dm:thisweek

# Not in temp folders
!path:temp !path:tmp *.log

# Exact name with extension
"report.pdf"
```

### Regex Search

Enable regex with `-regex` flag:

```powershell
es -regex "^file[0-9]+\.txt$"
```

Regex patterns in search:
- `regex:pattern` - Use regex for specific term

## Case Sensitivity

By default, searches are case-insensitive.

Force case-sensitive:
```powershell
es -case FileName
```

## Whole Word Matching

Match whole words only:
```powershell
es -whole-word report
```

This matches "annual report.pdf" but not "reporting.docx".

## Diacritics

Match diacritical marks:
```powershell
es -diacritics cafe
```
Matches "café" when enabled.

## Function Reference

| Function | Description |
|----------|-------------|
| `album:` | Music album metadata |
| `artist:` | Music artist metadata |
| `title:` | Music title metadata |
| `genre:` | Music genre metadata |
| `comment:` | File comment |
| `ext:` | File extension |
| `name:` | File name only |
| `filename:` | File name with extension |
| `path:` | Full path |

## Tips

1. **Use quotes for spaces**: `"program files"`
2. **Escape special chars**: Use `\` before special characters
3. **Combine filters**: Multiple functions can be combined
4. **Order matters**: Put most specific filters first for better performance
