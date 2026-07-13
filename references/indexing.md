# Everything Indexing Guide

Everything indexes files using one of two methods depending on your filesystem.

## NTFS Drives (Recommended, Default for C:)
- Uses the NTFS USN Journal (change journal)
- Indexing is **instantaneous** — no initial scan needed
- Updates are **real-time** — no rescan is ever needed

## ReFS / FAT32 / exFAT / Network Drives
- Everything must do a full folder scan
- Initial indexing can take **minutes to hours** depending on size
- Periodic rescans ARE required (configure in Everything: Tools > Options > Indexes)
- es.exe may return "no results" if indexing is not yet complete

## Checking Index Status

es.exe has no built-in status command. To check:
- Try a broad search: `& "$ES_PATH" *` — empty results on a non-NTFS volume may mean indexing is still in progress
- Open the Everything GUI and check the status bar (bottom-right): shows "Indexing X files..." or "Indexing complete"
