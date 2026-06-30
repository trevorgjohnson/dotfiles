# ATTENTION.md Format

`ATTENTION.md` is the pause gate. Either an applier or a verifier raises an item
here when it hits something only the user can decide. Any `OPEN` item **halts
the orchestrator**: it stops the Phase 1 loop, surfaces the item to the user,
and resumes only after the user resolves it.

This is the mechanism that justifies running the orchestrator in the foreground
rather than as a background workflow: a workflow cannot stop and hand control
back to the user mid-flight.

## Entry template

```md
## {OPEN | RESOLVED} · {feature-id} · {ISO timestamp}

- Raised by: {applier | verifier}, attempt {n}
- Issue: {what is blocking - be specific}
- Needed from user: {the exact decision or input required to proceed}
- Resolution: {filled in when the item flips to RESOLVED - what the user
  decided and any follow-up}
```

## Example

```md
## RESOLVED · f04 · 2026-06-16T15:30:00Z

- Raised by: applier, attempt 2
- Issue: The source "rename" commit renamed `withdraw` to `withdrawAsset`, but
  the target branch already has a `withdrawAsset` with a different signature.
  Applying the rename would collide.
- Needed from user: Decide the final name, or confirm the rename should be
  skipped on the target.
- Resolution: User chose `withdrawDAS`. Applier re-ran with the new name.
```

## Rules

- **One concern per item.** Do not bundle unrelated questions; the user clears
  items individually.
- **State exactly what is needed.** "Needs review" is not actionable. Name the
  decision or input required to proceed.
- **The orchestrator does not guess past an `OPEN` item.** It sets the feature
  to `needs-attention` in `STATE.md`, surfaces the item, and waits.
- **Resolve in place.** When the user answers, flip the heading to `RESOLVED`
  and fill in the `Resolution` line - do not delete the item. The history of
  what required a human is useful signal.
- **Resuming is gated on zero `OPEN` items.** On (re)start, scan this file; if
  any `OPEN` item remains, surface it and wait before doing anything else.
