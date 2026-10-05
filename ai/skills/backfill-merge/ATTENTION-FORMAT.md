# ATTENTION.md

Any OPEN entry halts orchestration, including on restart.
Set the affected feature to `needs-attention`, surface the decision, and wait for the user.

```md
## {OPEN | RESOLVED} · {feature-id} · {ISO timestamp}

- Raised by: {applier | verifier}, attempt {n}
- Issue: {specific blocker}
- Needed from user: {decision or input}
- Resolution: {user decision and follow-up, filled when resolved}
```

Use one concern per item.
Resolve in place by changing OPEN to RESOLVED and filling Resolution; preserve the history.
Resume only when no OPEN items remain.
