---
name: enshrine-spending
description: >
  Archive past-month spending entries from Spending.md into monthly Obsidian notes.
  Trigger when user says "enshrine spending", "cut spending", "archive spending",
  "close out the month", or when Spending.md has entries spanning multiple months.
argument-hint: '[optional: specific month to cut]'
---

# Enshrine Spending

Archive past-month entries from the active `Spending.md` scratchpad into a
dated monthly note. Leave the current month's entries in `Spending.md`.

## Prerequisites

- `$VAULT` must be set to the Obsidian vault root (e.g. `~/Documents/eighth-ring-of-hell`)
- `Spending.md` lives at `$VAULT/Spending.md`
- Monthly archives live in the same directory as `$VAULT/{Month} {Year} Spending.md`
- This skill expects CSV rows: `YYYY-MM-DD,amount,description,want|need`
- If `$VAULT` is unset, ask the user to provide it before proceeding.

## Step 1 — Determine what needs cutting

Resolve the vault path:

```bash
echo "${VAULT:?VAULT not set — please provide the path to your Obsidian vault}"
```

Get the current month and year:

```bash
date '+%Y-%m'
```

Read `$VAULT/Spending.md`. Parse every line matching `^(\d{4}-\d{2}-\d{2}),` into entries
keyed by their `YYYY-MM` month.

- **If all entries belong to the current month** → nothing to do. Report and exit.
- **If entries span multiple months** → identify each fully-past month (any month
  strictly before the current month). Those are the ones to archive.
- The current month's entries stay in `Spending.md`.

If the user optionally specifies a month (e.g. "cut June"), archive only that
month's entries regardless of the current date.

## Step 2 — Create each monthly archive

For each past month to archive, create `$VAULT/{Month} {Year} Spending.md`.

Use this template (replace `{Month}`, `{Year}`, `{PrevMonth}`, `{PrevYear}`,
`{next_month}`, `{next_year}`, `{csv_rows}`, `{need_count}`, `{need_total}`,
`{want_count}`, `{want_total}`):

```markdown
---
categories:
  - "[[Budgets]]"
aliases:
  - "{Year} {Month} Monthly Budget"
rating:
prev: "[[{PrevMonth} {PrevYear} Spending]]"
next:
tags:
  - monthly
---
{csv_rows}

**TOTAL**:
need   {need_count} items  ${need_total}
want   {want_count} items  ${want_total}

---

![[Monthly Budget]]

## Outcome

### Needs

### Wants

### Savings
```

### Frontmatter rules

- `prev`: derive from the archived month minus one. E.g. July → June, January → December (year - 1).
- `next`: leave empty. It gets filled when the following month is archived.
- `aliases`: use `{Year} {Month} Monthly Budget` (e.g. "2026 June Monthly Budget").

### CSV rows

Include only the raw CSV lines for that month. No markdown formatting, no extra
newlines between entries. One entry per line.

### Totals

Count items and sum amounts for `need` and `want` separately. Format amounts to
two decimal places.

## Step 3 — Update Spending.md

Overwrite `$VAULT/Spending.md` with only the current month's CSV rows (no frontmatter,
no totals — it remains a raw scratchpad). If there are zero entries for the
current month, leave it empty.

## Step 4 — Report

Summarize what was done:

```
Archived:
  June 2026 Spending.md — 22 entries, $1,011.07 total (0 need + 22 want)
  May 2026 Spending.md  — 18 entries, $742.50 total (3 need + 15 want)

Remaining in Spending.md: 4 entries for July 2026
```

## Edge cases

- **Empty Spending.md**: nothing to do.
- **All entries in current month**: report "All entries are current month, nothing to archive."
- **Gap months**: if entries jump from April to June (no May), `prev` still points
  to the chronologically previous month. Don't create empty months.
- **Duplicate archive file**: if the file already exists, warn the user and ask
  whether to overwrite, merge, or skip.
- **Invalid CSV lines**: skip lines that don't match the expected format and
  report them to the user.