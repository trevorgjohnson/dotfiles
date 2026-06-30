# STATE.md Format

`STATE.md` lives at the workspace root. It is the resumable checkpoint and the
single source of truth for the run. On every (re)start the orchestrator reads
this file first to determine exactly where to resume, rather than relying on
conversation memory.

It has two parts: a header capturing the run-wide state, and an ordered table
of features capturing per-feature state.

## Template

```md
# Backfill-merge State

- Source branch: {source}
- Target branch: {target}
- Repo path: {absolute path to the repo}
- Workspace path: {absolute path to this workspace, outside the repo}
- Commit style: {e.g. --no-ff merge + one follow-up commit per feature}
- Merge status: {pending | clean | conflicts-resolved} - merge SHA {sha or -}
- Phase: {setup | merge | apply | double-check | complete}

## Features

| id | source commit | description | status | attempts | record |
|----|---------------|-------------|--------|----------|--------|
| f01 | a1b2c3d | Cleanup typos | done | 2 | [f01](./features/f01.md) |
| f02 | e4f5a6b | Rename withdraw fns | applying | 1 | [f02](./features/f02.md) |
| f03 | 9c8d7e6 | (merge commit) | n/a | 0 | - |

## Garbage / plumbing (no application work)

- e4f5a6b - merge commit from upstream sync
- 1122334 - release-draft version bump
```

## Field rules

- **Phase** drives resumption. `setup` means the workspace is not yet
  initialized; `merge` means Phase 0 is pending or in progress; `apply` means
  the Phase 1 loop is running; `double-check` means Phase 2 is running;
  `complete` means done.
- **status** is one of `pending | applying | verifying | done | needs-attention`
  for features to re-apply, or `n/a` for garbage / plumbing rows.
- **attempts** increments each time the applier is spawned for that feature.
- **record** links to the per-feature file. Garbage / plumbing rows have no
  record (`-`).

## Rules

- **One feature per row.** Each "feature to re-apply" gets its own row and its
  own record file. Garbage / plumbing commits are listed for completeness but
  carry `status: n/a` and no record.
- **Update before and after every step.** Flip a feature to `applying` /
  `verifying` *before* spawning the agent and to `done` *after* a passing
  verdict, so an interrupted run resumes correctly.
- **Exactly one feature should be mid-flight** (`applying` or `verifying`)
  during the Phase 1 loop. If a restart finds more than one, the prior session
  was interrupted - re-spawn for the in-flight feature.
- **`needs-attention` is a hard stop.** A feature in this status means an
  `OPEN` item exists in `ATTENTION.md`. Do not advance past it.
