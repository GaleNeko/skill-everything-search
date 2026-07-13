---
name: everything-search
description: Fast file search on Windows using Everything search engine (es.exe CLI). Includes automatic pre-search validation, fuzzy matching. Requires es.exe for console output. Triggers on: 搜索文件、查找文件、全局搜索、帮我找、找到、找不到、搜一下、在哪里、全盘搜索。
---

# Everything Search

## Session State

- After running `scripts/validate.ps1`, save the `ES_PATH` it outputs. Reuse it for all subsequent searches in this session.
- Only re-run validation if a search fails with an environment error (IPC, "not found", etc.).

## Workflow

### 1. Validate (once per session)

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate.ps1
```

On first run, save `ES_PATH=<path>` from the output. Skip this step if already validated this session.

### 2. Search

Construct queries from user intent. All commands use `& "$ES_PATH"`. See `references/search-commands.md` for full reference.

Core patterns:
- Basic: `& "$ES_PATH" <pattern>`
- Sorted: `& "$ES_PATH" -sort size -n 20`
- Scoped: `& "$ES_PATH" -path "<dir>" <pattern>`

Fuzzy matching for vague queries:
- Expand keywords with wildcards: `*keyword*`
- Try multiple extensions when type is unclear
- Broaden + sort when specific file is hard to find

### 3. Present Results

- Group by relevance (exact matches first), then by folder
- Show size and dates to help user identify
- If too many matches (>20), ask user to narrow the scope

### 4. Handle Errors

| Symptom | Fix |
|---------|-----|
| Environment error (IPC, not found) | Re-run `scripts/validate.ps1` |
| Empty results on non-NTFS drive | Indexing may be in progress; see `references/indexing.md` |
| Permission denied | Run PowerShell as Administrator |

## References

- `references/search-commands.md` — Full es.exe CLI reference (sorting, columns, export, patterns)
- `references/search-syntax.md` — Everything search syntax (wildcards, operators, date/size filters)
- `references/indexing.md` — NTFS vs non-NTFS indexing behavior
