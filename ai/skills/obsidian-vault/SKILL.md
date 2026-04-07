---
name: obsidian-vault
description: Resolve the active Obsidian vault path and name from the $VAULT environment variable. Use when any Obsidian skill needs to know which vault to target before running CLI commands or writing files.
---

# Obsidian Vault Resolution

Before any vault operation, resolve the target vault:

```bash
VAULT_PATH="$VAULT"
VAULT_NAME="$(basename "$VAULT")"
```

- `VAULT_PATH` — absolute filesystem path, used for direct file reads/writes
- `VAULT_NAME` — vault name for the `obsidian` CLI `vault=` parameter

## If $VAULT is unset

Use the `AskUserQuestion` tool to ask:

> Where is your Obsidian vault? Please provide the absolute path (e.g. `/Users/you/Documents/MyVault`).

Once the user responds, set it in the shell so it persists for the rest of the session:

```bash
export VAULT="/path/from/user"
```

Then derive `VAULT_PATH` and `VAULT_NAME` as above and proceed.

## Usage in CLI commands

Pass `vault=` as the first argument:

```bash
obsidian vault="$VAULT_NAME" search query="test"
obsidian vault="$VAULT_NAME" read file="My Note"
```

## Usage in file operations

Resolve paths relative to the vault root:

```bash
# e.g. Write to "$VAULT_PATH/folder/note.md"
```

## Core Principals

After resolving the vault, read `$VAULT_PATH/Core Principals.md` to load the vault owner's conventions before any note creation or editing.

If this file doesn't exist, interview the user to create it using `AskUserQuestion`. Use the table below as your interview guide — ask each question, note the user's answer (or accept the recommended default if they have no preference), then write the file.

| Question | Recommended default |
|---|---|
| Do you use a single vault or split content across multiple vaults? | Single vault |
| Do you use folders to organize notes, or keep everything flat? | Flat — no folders |
| Do you stick to standard Markdown, or use Obsidian-specific syntax (callouts, embeds, etc.)? | Standard Markdown only |
| Are categories and tags singular or plural (e.g. `book` vs `books`)? | Always plural |
| How often do you use internal links between notes? | Profusely — link everything relevant |
| What date format do you prefer in properties and note titles? | `YYYY-MM-DD` everywhere |
| What scale do you use for ratings (stars, 1–10, etc.)? | 7-point scale (1–7) |
| Should property names be reusable across note types (e.g. `genre` on books, movies, and shows)? | Yes — shared property names enable cross-category views |
| Should templates be composable (e.g. a note can have both a _Person_ and an _Author_ template applied)? | Yes — design templates to stack |
| Do you prefer short property names or descriptive ones (e.g. `start` vs `start-date`)? | Short — faster to type |
| When a property might hold more than one value in the future, what type do you default to? | `list` — even if currently single-value |

## Skill dependencies

All vault interactions should go through the `obsidian-cli` skill — it is the canonical interface for reads, writes, and property updates. Load it alongside this skill for any operation beyond path resolution.
