# features/<feature-id>.md

Create one record per logical feature, none for plumbing.
Status and attempts mirror STATE.md, which is authoritative on drift.

```md
# {feature-id}: {description}

- Source commit: {sha} - {subject}
- Status: {pending | applying | verifying | done | needs-attention}
- Attempts: {n}

## What the source commit did

{Intent to reconstruct, not a source patch.}

Files touched on source:
- {path}

## What was applied on the target

- Attempt {n}: {work against target, differences from source, resulting commit SHA}

## Verdicts

- Attempt {n} (verifier): {PASS | FAIL} - {reason}
- Double-check (Phase 2): {PASS | FAIL} - {reason}
```

Keep an application entry and verdict for each attempt.
Mirror verdicts in handoff.md and preserve both verification passes separately.
