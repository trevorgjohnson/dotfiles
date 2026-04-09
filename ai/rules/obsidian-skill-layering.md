---
version: 1.0.0
description: obsidian-cli is the sole interface layer for all Obsidian vault I/O in skills
paths:
  - '~/.claude/skills/obsidian*/**'
---

# Obsidian Skill Layering

When writing or executing Obsidian skills, respect the interface hierarchy:

- **`obsidian-vault`** — resolves vault path and conventions only
- **`obsidian-cli`** — the sole interface for all vault I/O (search, read, create, append, properties)
- **Other Obsidian skills** — delegate to `obsidian-cli`; never call the `obsidian` CLI binary directly

Do not write raw `obsidian vault="..."` bash commands in skill files other than `obsidian-cli` itself. Instead, reference `obsidian-cli` operations by intent (e.g., "use `obsidian-cli` to search for X", "use `obsidian-cli` to read the note").
