---
name: prds
description: List, search, and read PRDs stored in ~/.claude/prds/. Use when user wants to find a PRD, list PRDs, search PRD content, or reference a specific PRD by name.
argument-hint: "[list|search <query>|show <name>]"
---

# PRDs

PRD storage lives at `~/.claude/prds/`. Each PRD is a directory containing at minimum a `prd.md`, and may contain subdirectories like `issues/` or nested sub-feature PRDs.

## Commands

### list (default)

Display a tree view of all PRDs under `~/.claude/prds/`. Show directory structure with file counts per PRD. Highlight which PRDs have issues broken out.

```bash
find ~/.claude/prds -type f -name "*.md" | sort
```

### search <query>

Search across all PRD content for a keyword or phrase. Return matching PRDs with the relevant context lines.

Use Grep on `~/.claude/prds/` with the query pattern, glob `*.md`. Group results by PRD directory.

### show <name>

Read and summarize a specific PRD. Match `<name>` against directory names under `~/.claude/prds/` (partial match is fine).

1. Find the matching PRD directory
2. Read `prd.md`
3. Check for `issues/` subdirectory and list any issue files
4. Present a brief summary followed by the full content

## Output format

- For `list`: tree-style output showing PRD names, file counts, and whether issues exist
- For `search`: grouped by PRD with matched lines and context
- For `show`: summary header (name, sections present, issue count) then full PRD content
