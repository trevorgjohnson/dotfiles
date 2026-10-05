# STATE.md

Read this authoritative checkpoint first on every restart.

```md
# Backfill-merge State

- Source branch: {source}
- Target branch: {target}
- Repo path: {absolute repo path}
- Workspace path: {absolute workspace path outside repo}
- Commit style: {agreed merge and follow-up commit style}
- Merge status: {pending | clean | conflicts-resolved} - merge SHA {sha or -}
- Phase: {setup | merge | apply | double-check | complete}

## Features

| id | source commit | description | status | attempts | record |
|----|---------------|-------------|--------|----------|--------|
| {id} | {sha} | {intent} | {status} | {n} | [record](./features/{id}.md) |

## Garbage / plumbing (no application work)

- {sha} - {reason}
```

Use one row and record per logical feature.
Plumbing may have `n/a` rows with zero attempts and no record, and is listed for completeness.
Feature statuses are `pending | applying | verifying | done | needs-attention`.
Increment attempts whenever an applier is spawned.
Update state before and after each step; mirror feature-record status, with STATE authoritative on drift.
Only one feature may be `applying` or `verifying` during the sequential loop.
If a restart finds more than one, the prior session was interrupted; re-spawn for the in-flight feature.
`needs-attention` means an OPEN attention item and halts progression.
