---
name: backfill-merge
description: Merge source into target, then reconstruct each logical change against target state with independent verification.
disable-model-invocation: true
argument-hint: "<source-branch> -> <target-branch>"
---

Re-apply each source change's intent against the current target, rather than trusting the merged diff.
For example, a typo cleanup means running the finder on target, including target-only typos.
Run orchestration in the foreground so user decisions can pause it; use fresh agents for application and independent verification, never do either inline.

Keep durable state in an agreed workspace outside the repository; never commit state files.
On every restart read `STATE.md` first, then check `ATTENTION.md`; do not rely on conversation memory.
Workspace schemas:

- [STATE-FORMAT.md](STATE-FORMAT.md): checkpoint, phase, ordered features, attempts, and plumbing commits.
- [FEATURE-FORMAT.md](FEATURE-FORMAT.md): source intent, applications, and both verification passes.
- [HANDOFF-FORMAT.md](HANDOFF-FORMAT.md): append-only agent notes and verdicts.
- [ATTENTION-FORMAT.md](ATTENTION-FORMAT.md): user decision gate.

Before touching git, confirm source/target, workspace path, and commit style, even when branches were supplied as arguments.
Default to a `--no-ff` merge followed by one commit per re-applied feature; never push without explicit approval.
Fetch all and enumerate `git log --oneline <target>..<source>`.
Classify logical features separately from plumbing, such as merge commits and version bumps with no semantic content, and get sign-off on the classification.
Initialize pending feature rows and records, plus empty handoff and attention files; plumbing gets no feature record.

Switch to target and merge source with the agreed style.
Resolve conflicts to a clean, building state; this merge is only the starting point.
Record the merge result and SHA and set phase `apply`.

Process one feature at a time in order:

1. Set `applying` and increment attempts before spawning a fresh applier to reconstruct intent against live target state and commit in the agreed style.
2. Set `verifying` and spawn a separate fresh verifier to check the result independently.
3. On FAIL, retry with a fresh applier; on PASS, mark `done` and advance.

Each agent receives repo/source/target, feature id and record path, its role, and instructions to read handoff and feature records first and append notes or PASS/FAIL with reasons to both.
Agents raise `ATTENTION.md` items for ambiguous intent, repeated failures, or decisions only the user can make.
Any OPEN item halts orchestration: set the affected feature's status to `needs-attention`, surface the decision, and wait until the user resolves it.

When all features are done, set phase `double-check` and run fresh independent verifiers in parallel, one per feature, against final target state.
Record each second verdict; a failure returns that feature to the apply/verify loop, then repeats its double-check.
Set `complete` only after all double-checks pass.
Report applied features, total attempts, attention items and resolutions, and final target SHA; push only with explicit approval.
