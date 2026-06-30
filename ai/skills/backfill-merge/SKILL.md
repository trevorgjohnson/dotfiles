---
name: backfill-merge
description: >-
  Bring changes from a source branch into a target branch when a plain git
  merge is not enough: re-apply each logical change freshly against the target
  branch's current state, verify it independently, and double-check at the end.
  Use when the user says "backfill merge", "/backfill-merge", "re-apply changes
  onto another branch after merging", or describes merging a branch where each
  feature must be reconstructed against the target rather than trusted from the
  merged diff.
disable-model-invocation: true
argument-hint: "<source-branch> -> <target-branch>"
---

# backfill-merge

Brings changes from a **source branch** into a **target branch** when a plain
`git merge` is not enough. For each logical change on the source branch, you
re-apply its *intent* freshly against the target branch's current state rather
than trusting that the merge carried it correctly. Each application is
verified independently, retried on failure, and double-checked at the end.

The canonical example: a "cleanup typos" commit on the source branch should be
re-applied by actually re-running a typo finder against the target branch
(which may contain typos the source branch never had), not by accepting the
merged diff. The merge gives you a starting point; the re-application is the
real work.

This is **stateful** and may run over a long time or multiple sessions. All
progress lives in a workspace of state files (described below) that survive
context loss. On every (re)start, read `STATE.md` first to learn exactly where
to resume. Never rely on conversation memory for resumption.

## Orchestration model

The orchestrator runs from the **main conversation loop** using the `Agent`
tool. It does **not** run on the background Workflow engine.

The reason is the pause-for-attention requirement: the run must be able to stop
mid-flight and hand control back to the user, then resume only once the user
clears the issue. A background workflow cannot pause and ask the user. The
state files supply the durability a workflow would otherwise give, so nothing
is lost across sessions even though the orchestration is foreground.

The orchestrator spawns fresh subagents to do the work (apply, verify). It
never applies or verifies a feature inline itself. Keeping the orchestrator
thin means its context stays small and the run survives context loss.

## Workspace

Treat a dedicated directory as the backfill workspace. The state of the run
lives entirely in these files:

- `STATE.md` - the resumable checkpoint and single source of truth. Header plus
  an ordered table of features. Format: [STATE-FORMAT.md](./STATE-FORMAT.md).
- `handoff.md` - append-only running log of inter-agent notes, one entry per
  agent action. Format: [HANDOFF-FORMAT.md](./HANDOFF-FORMAT.md).
- `ATTENTION.md` - the pause gate. Any `OPEN` entry halts the orchestrator.
  Format: [ATTENTION-FORMAT.md](./ATTENTION-FORMAT.md).
- `features/<feature-id>.md` - one per feature: what the source commit did,
  what was applied on the target, each verdict, final status. Format:
  [FEATURE-FORMAT.md](./FEATURE-FORMAT.md).

**Default the workspace OUTSIDE the repo**, e.g. under the project's Claude
session directory. State files must never get committed to the target branch.
Confirm the chosen location with the user during Setup.

## Setup

Confirm all of the following with the user before touching git. The source and
target branch may arrive as the skill argument (e.g.
`/backfill-merge develop -> audit`); confirm them anyway.

1. **Source and target branch.** Which branch holds the changes, which branch
   receives them.
2. **Workspace location.** Default to a directory outside the repo (see above).
   Confirm the path.
3. **Commit style on the target branch.** Default: a `--no-ff` merge of source
   into target, then one follow-up commit per re-applied feature. **Never push
   without explicit approval.**
4. **Commit divergence and classification.** Enumerate the commits the source
   branch has that the target lacks:

   ```bash
   git fetch --all
   git log --oneline <target>..<source>
   ```

   Classify each commit into one of two buckets:
   - **Features to re-apply** - logical changes whose intent must be
     reconstructed against the target (one feature record each).
   - **Garbage / plumbing** - commits that ride along with the merge but need
     no application work: merge commits, release-draft commits, version bumps
     with no semantic content. Record them in `STATE.md` for completeness but
     do not create feature records or apply/verify them.

   Present the classification and get the user's sign-off. A misclassified
   feature is the most expensive mistake here, so when unsure, ask.

Once confirmed, initialize the workspace: write `STATE.md` (header + feature
table, all features `pending`), create `features/` with one record per feature,
and create empty `handoff.md` and `ATTENTION.md`.

## Phase 0 - Merge

Merge source into target using the agreed commit style (default `--no-ff`):

```bash
git switch <target>
git merge --no-ff <source>
```

Resolve any conflicts to a clean, building state. The merge result is only a
**starting point** for re-application, not the finished product, so a
mechanical resolution that compiles is acceptable here.

Record the merge outcome (clean / conflicts resolved / merge SHA) in the
`STATE.md` header, set the phase to `apply`, and continue.

## Phase 1 - Sequential apply-and-verify loop

Process features **one at a time, in order**. For the current feature:

1. **Apply.** Spawn a **fresh** subagent (`Agent` tool) to re-apply the
   feature's intent against the target branch's current state.
   - Set the feature status to `applying` and increment its attempt count in
     `STATE.md`.
   - The applier reads `handoff.md` and the feature record first for context,
     does the work, then appends its own notes to both. It re-applies the
     *intent* against the live target state - it does not copy the source
     diff. For the typo example: it re-runs the typo finder on the target.
   - On the agreed commit style, the applier commits its work (default: one
     follow-up commit for this feature).

2. **Verify.** Spawn a **separate, independent** verifier subagent. It must not
   be the applier and must not assume the applier was correct.
   - Set the feature status to `verifying` in `STATE.md`.
   - The verifier reads the feature record and `handoff.md`, confirms the
     intent was correctly applied against the target, then appends a verdict
     (`PASS` / `FAIL` with reasons) to both `handoff.md` and the feature
     record.
   - **FAIL** → re-spawn the applier (step 1) for another attempt; the attempt
     count increments. Repeat until `PASS`.
   - **PASS** → mark the feature `done` in `STATE.md` and advance to the next
     feature.

3. **Attention gate.** Either agent may raise an item in `ATTENTION.md` when it
   needs the user (ambiguous intent, repeated failures, a decision only the
   user can make). An `OPEN` attention item **halts the orchestrator**: stop
   the loop, set the feature to `needs-attention` in `STATE.md`, surface the
   item to the user, and wait. Resume only after the user resolves it (the item
   flips to `RESOLVED`).

Repeat until every feature is `done`. Then advance the phase to `double-check`.

## Phase 2 - Final double-check

Second-pass confirmation that every feature was applied correctly. These checks
are independent of one another, so **run them in parallel**: fan out one fresh
verifier subagent per applied feature in a single batch.

Each verifier re-reads its feature record and re-confirms the application
against the final target state, appending a second verdict to the feature
record. If any verifier fails, return that feature to the Phase 1 loop (status
`applying`) and retry, then re-run its double-check.

When all double-checks pass, set the phase to `complete` in `STATE.md` and
report a summary to the user: features applied, total attempts, any attention
items raised and how they were resolved, and the final target SHA. Do not push
unless the user explicitly approves.

## Subagent prompts

When spawning, give each subagent only what it needs and point it at the
workspace. Each prompt should state:

- The feature id and its record path (`features/<id>.md`).
- The source and target branch, and the repo path.
- Its role: **applier** (re-apply intent against the live target state, do not
  copy the source diff) or **verifier** (independently confirm, assume nothing).
- The instruction to read `handoff.md` and the feature record first, and to
  append its notes / verdict to both when done.
- The instruction to raise an `ATTENTION.md` item instead of guessing when it
  hits something only the user can decide.
