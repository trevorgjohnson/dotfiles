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

