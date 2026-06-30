# handoff.md Format

`handoff.md` is the append-only running log of inter-agent notes. Each agent
(applier or verifier) reads it for context before working and appends one entry
when done. It is the channel by which a fresh subagent learns what prior agents
found, so the next agent never has to rediscover it.

Append only. Never edit or delete a prior entry. The chronological history is
the value.

## Entry template

```md
## {feature-id} · {applier | verifier} · attempt {n} · {ISO timestamp}

{Notes for the next agent or for verification. What was done, what was checked,
what was found, anything surprising. For an applier: how the intent was
re-applied against the target and what state it left. For a verifier: the
verdict (PASS / FAIL) up front, then the reasons.}
```

## Examples

```md
## f01 · applier · attempt 1 · 2026-06-16T14:02:00Z

Re-ran the typo finder (codespell) against the target branch. Found and fixed
4 typos: 2 the source branch also had, 2 that only exist on target. Committed
as "fix: cleanup typos (backfill of a1b2c3d)". Did NOT copy the source diff -
applied fresh.

## f01 · verifier · attempt 1 · 2026-06-16T14:09:00Z

FAIL. codespell still reports `recieve` in libraries/AppStorage.sol - the
applier's word list missed it. Re-run with the default dictionary.

## f01 · applier · attempt 2 · 2026-06-16T14:15:00Z

Re-ran codespell with the default dictionary. Fixed `recieve` plus 1 more.
Amended the backfill commit. Tree is clean, build passes.

## f01 · verifier · attempt 2 · 2026-06-16T14:20:00Z

PASS. codespell reports zero hits across the target tree. Build green.
```

## Rules

- **Lead a verifier entry with the verdict.** `PASS` or `FAIL` as the first
  word of the body, so the orchestrator can parse the outcome at a glance.
- **Write for the next reader, not for yourself.** Assume the next agent has no
  context beyond this log and the feature record.
- **Mirror verdicts into the feature record.** A verifier appends its verdict
  here *and* to `features/<id>.md`; this log is chronological, the record is
  the per-feature summary.
- **Reference, don't paste.** Link to commits, files, and line ranges rather
  than pasting large diffs into the log.
