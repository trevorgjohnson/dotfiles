# handoff.md

Agents read this chronological log before work and append one entry per action; never edit or delete earlier entries.

```md
## {feature-id} · {applier | verifier} · attempt {n} · {ISO timestamp}

{Application notes or PASS/FAIL followed by reasons, checks, and useful findings.}
```

Appliers describe how intent was reconstructed against target and the resulting state or commit.
Verifiers lead with PASS or FAIL and mirror their verdict into the feature record.
Link to commits and files instead of pasting large diffs.
