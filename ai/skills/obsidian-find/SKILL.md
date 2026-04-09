---
name: obsidian-find
description: >-
  Locate and load Obsidian notes or structured vault data (todos, tasks, projects
  by status; weekly/daily notes) into context. Also handles fuzzy note lookup by
  approximate name, content, or intent.
---

# Obsidian Find

Primary entrypoint for locating and loading any Obsidian note or structured vault
data into context.

## Setup

Load these two skills first — every workflow depends on them:

1. `obsidian-vault` — resolves `$VAULT_PATH` and `$VAULT_NAME`
2. `obsidian-cli` — search, read, property interface, and vault conventions
   (Core Principals)

## Query Classification

Classify the request, then follow the matching strategy:

| Type | Signal words | Strategy |
|---|---|---|
| **Structured** | todos, tasks, projects, backlog, in progress, active, pending, blocked, finished | [Structured queries](#structured-queries) |
| **Temporal** | this week, weekly note, today, daily note | [Temporal resolution](#temporal-resolution) |
| **Fuzzy lookup** | a topic, partial name, description, or keyword | [Fuzzy search](#fuzzy-search) |

## Certainty Rule

**Never auto-load a note unless the match is unambiguous** — exactly one result
whose name directly matches the query with no plausible alternatives.

When uncertain (multiple results, partial match, or vague intent): use
`AskUserQuestion` to show options. The cost of loading the wrong note is wasted
tokens. Always confirm.

---

## Structured Queries

Structured queries target vault-wide property patterns rather than a specific note.
Use conventions from `Core Principals.md` (loaded by `obsidian-cli`) to understand
how the vault organizes categories, statuses, and tags — don't hardcode mappings.

**Workflow:**

1. Translate the user's intent into property filters using Core Principals
   conventions (e.g. category links, status property values, tag names)
2. Use `obsidian-cli` search and property lookups to find matching notes
3. Narrow by status, tag, or date scope as needed
4. If results exceed 7 notes, summarize by status/tag grouping and ask which
   subset to load in full

**Combine filters naturally.** Example: "work todos in progress" → filter by the
Todos category + status = in progress + tag = work (using whatever property names
the vault conventions define).

## Temporal Resolution

Temporal queries require reading a weekly or daily note to extract date boundaries.

**This week:**

1. Resolve the current weekly note via `obsidian-cli` (filename pattern from
   vault conventions)
2. Read its `start` and `end` frontmatter properties
3. Use those dates as bounds when filtering by `start`/`end` properties

**Today:**

1. Resolve today's daily note via `obsidian-cli`
2. Read its `date` property
3. Filter notes where `start <= today` and (`end` is empty or `end >= today`)

Combine with structured filters as needed (e.g. "this week's active todos").

---

## Fuzzy Search

Run searches in layers via `obsidian-cli` — stop as soon as results are
unambiguous:

1. **Name search**: `obsidian-cli` search with query keywords, limit 10
2. **Content search** (if name search is empty or off-target):
   `obsidian-cli` search:context
3. **Frontmatter grep** (for property-based queries like "notes with status
   pending"): grep relevant YAML properties across the vault

Refine with additional terms if the first pass returns too many unrelated results.
If zero results, try synonyms or a shorter keyword.

### Disambiguation

When more than one candidate exists — or only one came back but confidence is
low — use `AskUserQuestion`:

```
Which note are you looking for?

1. **<Note Name>** — <key frontmatter> — "<first meaningful line>"
2. **<Note Name>** — <key frontmatter> — "<snippet>"
...
N. None of these — describe further
```

Rules:

- Show at most 5–7 options
- Always include "None of these — describe further"
- Lead each entry with filename, then key frontmatter, then a short content snippet
- If the user picks "None of these", ask a focused follow-up — don't repeat the
  same search

Use `obsidian-cli` search:context to build rich option entries without reading
every file in full.

---

## After Confirmation

Use `obsidian-cli` to read the confirmed note and present the content inline in
the session.
