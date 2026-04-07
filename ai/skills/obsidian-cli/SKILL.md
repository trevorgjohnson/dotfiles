---
name: obsidian-cli
description: Interact with Obsidian vaults using the Obsidian CLI to read, create, search, and manage notes, tasks, properties, and more. Use when the user asks to interact with their Obsidian vault, manage notes, search vault content, or perform vault operations from the command line.
---

# Obsidian CLI

Use the `obsidian` CLI to interact with a running Obsidian instance. Requires Obsidian to be open.

## Step 1 — Detect the CLI

Before the first vault operation, run:

```bash
which obsidian
```

If found, proceed normally. If not found, use `AskUserQuestion` to present the options below — noting the limitations of raw mode so the user can make an informed choice:

---

> The `obsidian` CLI is not installed (or not on your PATH). How would you like to proceed?
>
> **A — Install it** (recommended)
> Follow the guide at https://help.obsidian.md/cli, then come back and re-run the command. Required for: templates, Obsidian sync/history, plugin management, and live vault operations.
>
> **B — Continue without it (raw file I/O)**
> Vault files will be read and written directly with standard tools. Obsidian does not need to be open. Limitations: no template expansion, no sync/history/plugin commands, search uses raw file contents (not Obsidian's index), property types must be maintained manually in YAML.
>
> **C — It's installed but not in PATH**
> Provide the full path to the `obsidian` binary and I'll use it directly this session.

Handle each response:
- **A** → stop and wait; retry the original request once the user confirms install.
- **B** → proceed using [Raw Mode](#raw-mode) for all vault operations.
- **C** → use the provided path in place of `obsidian` for all commands this session.

---

## Command reference

Run `obsidian help` to see all available commands — this is always up to date.
If anything unexpected happens, fetch `https://help.obsidian.md/cli` and check for syntax changes before retrying.

## Syntax

**Parameters** take a value with `=`. Quote values with spaces:

```bash
obsidian create name="My Note" content="Hello world"
```

**Flags** are boolean switches with no value:

```bash
obsidian create name="My Note" silent overwrite
```

For multiline content use `\n` for newline and `\t` for tab.

## File targeting

Many commands accept `file` or `path`. Without either, the active file is used.

- `file=<name>` — resolves like a wikilink (name only, no path or extension)
- `path=<path>` — exact path from vault root, e.g. `folder/note.md`

## Vault targeting

Commands target the most recently focused vault by default. Use `vault=<name>` as the first parameter to target a specific vault:

```bash
obsidian vault="My Vault" search query="test"
```

## Destructive operations

Before running any destructive command, use `AskUserQuestion` to confirm. Destructive commands include:

- `obsidian create ... overwrite` — overwrites an existing note
- `obsidian property:set` — replaces an existing property value
- `obsidian delete` — deletes a file
- Any command that modifies content that can't be trivially undone

Example confirmation prompt:
```
This will overwrite "My Note" with new content. The existing content will be lost.
Proceed? Yes / No / Show current content first
```

## Common patterns

```bash
obsidian read file="My Note"
obsidian create name="New Note" content="# Hello" template="Template" silent
obsidian append file="My Note" content="New line"
obsidian prepend file="My Note" content="New line"
obsidian search query="search term" limit=10
obsidian search:context query="search term"
obsidian daily:read
obsidian daily:append content="- [ ] New task"
obsidian daily:prepend content="- [ ] New task"
obsidian daily:path
obsidian unique name="My Idea" content="# My Idea"
obsidian property:read name="status" file="My Note"
obsidian property:set name="status" value="done" file="My Note"
obsidian property:remove name="status" file="My Note"
obsidian properties file="My Note"
obsidian tasks daily todo
obsidian tasks file="My Note" verbose
obsidian task ref="folder/note.md:12" toggle
obsidian tags sort=count counts
obsidian backlinks file="My Note"
obsidian links file="My Note"
obsidian files folder="Projects" ext=md
obsidian orphans
obsidian deadends
```

Use `--copy` on any command to copy output to clipboard. Use `silent` to prevent files from opening in Obsidian. Use `total` on list commands to get a count.

---

## Raw Mode

Raw mode uses Read, Write, Edit, Grep, Glob, and Bash directly on vault files. Obsidian does not need to be open. Resolve the vault root first via the `obsidian-vault` skill (`$VAULT_PATH`).

### Equivalents

| CLI command | Raw equivalent |
|---|---|
| `read file="Note"` | `Read` on `$VAULT_PATH/Note.md` |
| `create name="Note" content="..."` | `Write` to `$VAULT_PATH/Note.md` |
| `append file="Note" content="..."` | `Edit` — append lines to end of file |
| `prepend file="Note" content="..."` | `Edit` — insert after frontmatter block |
| `search query="term"` | `Grep` with `pattern="term"` in `$VAULT_PATH` |
| `search:context query="term"` | `Grep` with `context` lines set |
| `daily:read` | `Read` on `$VAULT_PATH/$(date +%Y-%m-%d).md` |
| `daily:append content="..."` | `Edit` — append to today's daily note |
| `daily:path` | `echo "$VAULT_PATH/$(date +%Y-%m-%d).md"` |
| `unique name="..." content="..."` | `Write` to `$VAULT_PATH/$(date +%Y%m%d%H%M%S).md` |
| `property:read name="k" file="Note"` | `Read` frontmatter, extract key `k` from YAML block |
| `property:set name="k" value="v"` | `Edit` — replace value of `k` in YAML frontmatter |
| `property:remove name="k"` | `Edit` — remove the `k:` line from YAML frontmatter |
| `properties file="Note"` | `Read` — show the `---` frontmatter block |
| `tasks daily todo` | `Grep` for `- \[ \]` in today's daily note |
| `tasks file="Note" verbose` | `Grep` for `- \[` in file, show line numbers |
| `tags` | `Grep` for `tags:` in frontmatter across vault |
| `backlinks file="Note"` | `Grep` for `\[\[Note\]\]` across vault |
| `links file="Note"` | `Grep` for `\[\[` within the file |
| `files ext=md` | `Glob` with `**/*.md` in `$VAULT_PATH` |
| `orphans` | Cross-reference `Glob` results against backlink `Grep` results |

### Frontmatter edits

Always target the specific property line with `Edit` — never rewrite the entire file just to change a property. When adding a new property, insert it inside the existing `---` block.

### Template expansion

When creating a note from a template in raw mode, manually expand all template variables before writing the file. Read `Core Principals.md` for the vault's preferred date format — default is `YYYY-MM-DD`.

**Core template variables** (built into Obsidian's Templates plugin):

| Token | Expands to | Example |
|---|---|---|
| `{{title}}` | The note's filename (no extension) | `2026-W15` |
| `{{date}}` | Today's date in vault default format | `2026-04-07` |
| `{{date:FORMAT}}` | Today's date with a [moment.js format](https://momentjs.com/docs/#/displaying/format/) | `{{date:YYYY}}` → `2026`, `{{date:MMM}}` → `Apr`, `{{date:WW}}` → `15` |
| `{{time}}` | Current time (default `HH:mm`) | `14:30` |
| `{{time:FORMAT}}` | Current time with a moment.js format (same syntax as above) | `{{time:hh:mm a}}` → `02:30 pm` |

**Date Offset plugin variables** (community plugin — `Date Offset: Expand date offset placeholders`):

| Token | Expands to |
|---|---|
| `{{date+1D}}` | Tomorrow |
| `{{date-1D}}` | Yesterday |
| `{{date+1W}}` | One week forward |
| `{{date-1W}}` | One week back |
| `{{date+1W:FORMAT}}` | Offset with format, e.g. `{{date+1W:YYYY}}-W{{date+1W:WW}}` |

Offsets support `D` (days), `W` (weeks), `M` (months), `Y` (years). Format token after `:` is optional and uses the same moment.js syntax.

**Template → rendered example** (Weekly Note Template → `2026-W15`, week starting 2026-04-06):

| Token in template | Rendered value |
|---|---|
| `{{date:YYYY}} {{date:MMM}} Weekly Note` | `2026 Apr Weekly Note` |
| `{{date-1W:YYYY}}-W{{date-1W:WW}}` | `2026-W14` |
| `{{date+1W:YYYY}}-W{{date+1W:WW}}` | `2026-W16` |
| `{{date}}` | `2026-04-06` |
| `{{date+5D}}` | `2026-04-11` |
| `{{date+1D}}` | `2026-04-07` |

When expanding manually, compute all offsets from the note's creation date (or the Monday of the week for weekly notes), not from today if they differ.

### Unavailable in raw mode

- `sync`, `sync:*`, `history:*`, `diff` — Obsidian sync and version history
- `plugin:*`, `plugins` — plugin management
- `command`, `commands` — Obsidian command palette
- `task ref=` toggle — toggling by line reference (edit the line directly instead)
- `random`, `random:read` — random note selection
