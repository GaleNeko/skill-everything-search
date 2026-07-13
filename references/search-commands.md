# ES.exe Command Reference

All commands use `& "$ES_PATH"` (from `scripts/validate.ps1` output).

## Basic Search

```powershell
# Exact filename
& "$ES_PATH" "budget.xlsx"

# Partial match (wildcard)
& "$ES_PATH" *budget*

# File extension
& "$ES_PATH" *.mp4

# Multiple extensions
& "$ES_PATH" *.mp4 *.avi *.mkv
```

## Path-Based Search

```powershell
# Search within a folder
& "$ES_PATH" -path "D:\Downloads" *.exe

# Search parent directory
& "$ES_PATH" -parent "C:\Users\Admin" *.txt
```

## Sorting

```powershell
& "$ES_PATH" -sort name *.pdf        # By name (default)
& "$ES_PATH" -sort size              # By size (largest first)
& "$ES_PATH" -sort date-modified     # By date modified (newest first)
& "$ES_PATH" -sort name -sort-ascending  # Ascending
```

## Output Columns

```powershell
& "$ES_PATH" -size -date-modified -date-created -extension *.docx
& "$ES_PATH" -size -dm *.zip          # Size + Date Modified
& "$ES_PATH" -size -dc -dm *.log      # Size + Created + Modified
```

Columns: `-size` (`-s`), `-date-modified` (`-dm`), `-date-created` (`-dc`), `-date-accessed` (`-da`), `-extension` (`-ext`), `-attributes` (`-attrib`)

## Limiting Results

```powershell
& "$ES_PATH" -n 20 *.jpg             # First 20
& "$ES_PATH" -o 10 -n 5 *.png        # Offset 10, show 5
```

## Exporting

```powershell
& "$ES_PATH" *.pdf -export-csv results.csv
& "$ES_PATH" *.docx -export-txt documents.txt
& "$ES_PATH" *.mp3 -export-efu music.efu
```

## Fuzzy Search Strategies

When the user's query is imprecise, try these approaches:

### Wildcard Expansion
```
User: "find my budget file"

& "$ES_PATH" *budget*
& "$ES_PATH" budget*
& "$ES_PATH" *budget*.xlsx
& "$ES_PATH" *budget*.docx
```

### Multiple Extensions
```
User: "find the presentation"

& "$ES_PATH" *presentation*.pptx
& "$ES_PATH" *presentation*.ppt
& "$ES_PATH" *presentation*.pdf
& "$ES_PATH" *presentation*
```

### Broader Search + Sort
```
User: "that large video file from last week"

& "$ES_PATH" -sort size -n 20 *.mp4
& "$ES_PATH" -sort date-modified -n 20 *.mp4 *.avi *.mkv
```

## Common Patterns

```powershell
# Large files
& "$ES_PATH" -sort size -n 20
& "$ES_PATH" -sort size -n 10 *.mp4 *.avi *.mkv

# Recent files
& "$ES_PATH" -sort date-modified -n 20
& "$ES_PATH" -sort dm -n 50 *.docx *.xlsx

# Duplicates (by common naming patterns)
& "$ES_PATH" (1).* *.copy.*
```
