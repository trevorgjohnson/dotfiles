# features/<feature-id>.md Format

Each feature to re-apply gets one record in `features/`, named by its id
(`f01.md`, `f02.md`, ...). The record is the per-feature summary: what the
original source commit did, what was applied freshly on the target, every
verifier verdict, and the final status. Where `handoff.md` is the chronological
log across all features, this file is the durable summary for one feature.

Garbage / plumbing commits do not get records.

## Template

```md
# {feature-id}: {short description}

- Source commit: {sha} - {original commit subject}
- Status: {pending | applying | verifying | done | needs-attention}
- Attempts: {n}

## What the source commit did

{Summary of the original change's intent. List the files it touched. This is
the *intent* to reconstruct, not a diff to copy.}

Files touched on source:
- {path}
- {path}

## What was applied on the target

{What the applier actually did against the target branch's current state, per
attempt. Note where the target differed from source - extra cases the source
never had, files that no longer exist, names that already collide. This is the
heart of the record: it shows the intent was reconstructed, not transplanted.}

- Attempt 1: {what was done, resulting commit SHA}
- Attempt 2: {what changed after a FAIL verdict}

## Verdicts

- Attempt 1 (verifier): FAIL - {reason}
- Attempt 2 (verifier): PASS - {reason}
- Double-check (Phase 2): PASS - {reason}
```

## Rules

- **Capture intent, not diff.** The "What the source commit did" section
  records what the change was *for*, so the applier can reconstruct it against
  a target that may differ. It is not a place to paste the source patch.
- **One entry per attempt** under both "What was applied" and "Verdicts", so
  the retry history is legible.
- **Mirror the verdict from `handoff.md`.** Each verifier writes its verdict to
  the chronological log and to this record. They must agree.
- **Status mirrors `STATE.md`.** This file's `Status` and the row in `STATE.md`
  are kept in sync; `STATE.md` is authoritative if they ever drift.
- **Record both verification passes.** The Phase 1 loop verdict and the Phase 2
  double-check are distinct lines under "Verdicts".
