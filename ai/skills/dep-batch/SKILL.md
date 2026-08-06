---
name: dep-batch
description: >-
  Batch all open Dependabot/Renovate PRs into a consolidated batch branch,
  deduplicating by package, merging each branch, then closing the individual
  PRs with a comment. Works on any Prometheum repo (boats, cows, ...). Trigger
  when the user says "run dep batch", "batch dependencies", or "consolidate
  renovate/dependabot PRs".
triggers:
  - /dep-batch
---

# Dep-Batch Skill

Collects all open Dependabot/Renovate PRs targeting the repo's integration branch, merges them into
the current batch branch one at a time (resolving conflicts), runs the verify sequence, closes the
individual PRs with a comment, then monitors CI once the user pushes.

**The skill never merges the batch branch to the integration branch.** The user controls that step.

## Org-wide constants

These hold across all Prometheum repos (boats, cows, ...):

- Dependency PR authors: `app/dependabot`, `app/prometheum-renovate`
- Merge bot: comment `/promethea merge` on the batch PR to land it
- Batch branch naming: `chore/YYYY-MM-DD-batch-deps`

## Step 0 - Detect repo settings

Detect `$REPO`, `$BASE`, `$LOCKFILE` + package manager, and `$TEST_CMD` from the repo. The
non-obvious facts:

- Prometheum repos often target `develop`, not the repo default branch. Verify against the actual PR
  bases in Step 1 and prompt if they disagree.
- `~/work_bin/test_pr` holds the canonical verify sequence (build, test, lint, static analysis) keyed
  by repo directory name (`platform-backend`/`boats-backend`/`cows`). Prefer it over guessing from
  `package.json`.
- `cows` is a Solidity repo with no `test`/`test:unit` script. Its sequence (forge + hardhat + lint +
  slither) exists only in `test_pr`.

If any value is ambiguous (no obvious test script, multiple lockfiles, PR bases disagreeing with the
detected default branch), **ask the user** rather than guess.

## Prerequisites

1. Current branch matches `chore/YYYY-MM-DD-batch-deps`. Abort if not.
2. Working tree is clean. Abort if there are uncommitted changes.
3. `gh` is authenticated and targeting `$REPO`.

## Step 1 - List open dependency PRs

List open PRs against `$BASE` for each dependency author, requesting
`number,title,headRefName,updatedAt,baseRefName` with a high limit, then combine into one working
list. If the dep PRs target a base other than the detected `$BASE`, re-run with the correct base and
confirm with the user.

## Step 2 - Deduplicate by package

Group the PRs by the package they update, derived from the PR title.

For each group with more than one PR:
- Keep the PR with the **highest target version**. On a tie, keep the latest `updatedAt`.
- Mark the rest as **skipped (duplicate)**. Do not merge them, but close them at the end with the
  batch comment.

Separate PRs touching related-but-distinct targets are **not** duplicates (a node `bullseye` image
and a node `bullseye-slim` image are different Dockerfile lines, so keep both).

## Step 2b - Flag major-version bumps for delegation

Major bumps often carry breaking changes that don't belong in a routine batch (a `typescript` 5 to 7
jump, a framework major). Forcing one in can break the build for reasons unrelated to the rest of the
batch, and burying a breaking change in a batch PR hides work that deserves its own review.

For each PR crossing a **major version** (semver `X.0.0`):
- Call it out **before merging**, with the from/to versions.
- **Recommend excluding it** and delegating to a tech-debt ticket. Leave it per-PR; some majors are
  safe and belong in the batch, so let the user decide.

When the user opts to delegate, use the `/jira` skill to:
1. Create a tech-debt ticket describing the upgrade, the from/to versions, and any blockers found
   (peer-dep conflicts, build failures). Reference the dep PR number and any similar prior ticket.
   Labels: `tech-debt` plus the repo's product label (e.g. `boats`).
2. Close the dep PR with a comment pointing at the new ticket, not the duplicate/batch comment.
3. **Tell the user to set `parent` (epic) and `sprint` manually.** acli cannot set those fields.

After dedup and major triage, present tables of PRs to **merge**, to **skip/close as duplicates**,
and to **delegate to a ticket**. Ask the user to confirm before proceeding.

## Step 3 - Fetch all PR branches

`git fetch origin` once is sufficient; all remote refs update.

## Step 4 - Merge each PR branch

Process the deduplicated merge list one PR at a time, ascending by PR number.

### 4a. Attempt merge

```bash
git merge --no-ff --no-verify origin/<headRefName> -m "chore: merge PR #<number> - <title>"
```

`--no-verify` is required on batch branches because the commit-msg hook rejects commits from branches
without a Jira ticket in the name.

### 4b. Handle lockfile conflicts

If `$LOCKFILE` is conflicted, accept one side to get a valid manifest, then regenerate the lockfile
from the merged manifest state. This is the canonical resolution:

```bash
git checkout --theirs "$LOCKFILE"

# npm
npm install --package-lock-only --ignore-scripts
# yarn
yarn install --mode update-lockfile
# pnpm
pnpm install --lockfile-only --ignore-scripts

git add "$LOCKFILE"
```

If the `--*-only` flag is unavailable, a plain install produces an equivalent lockfile.

### 4c. Handle `package.json` / manifest conflicts

Dependabot group PRs frequently conflict on the manifest itself, usually a diff3 3-way hunk per
dependency line.

1. Inspect the conflict.
2. For each conflicting dependency line keep the **higher version**. The PR side often wins every
   hunk, but verify: the batch branch may already be ahead on some.
3. Resolve the hunks manually. **Never `git checkout --theirs` on the manifest**, it clobbers
   batch-only bumps that merged cleanly elsewhere in the file. `--theirs` is only safe on the
   lockfile, which you regenerate anyway.
4. Verify no markers remain, then regenerate the lockfile per 4b.

### 4d. Handle conflicts in other files (Dockerfile, workflows)

These files may have multiple dep bumps touching the same line (a base image version, a GitHub Action
digest).

1. Show the conflicted diff to evaluate what each side changes.
2. Accept **both sets of dep changes**; the goal is to keep every update. Where both sides bump the
   same line, keep the **higher version**.
3. Be careful with `-X theirs` on Dockerfile: if two images sit in the same conflict hunk, it may
   revert a previously merged image. Prefer manual resolution for multi-line hunks.
4. **Merge order matters for Dockerfile.** Merge the image touching the most lines first (node-slim
   before busybox) to avoid `-X theirs` reverting a prior update in a shared hunk.
5. Stage the resolved file.

Then complete the merge with `git commit --no-verify`.

### 4e. Unresolvable conflicts

If a conflict cannot be resolved automatically (a semantic conflict in application code, not a dep
file), `git merge --abort` for that PR. Record it as **failed** with branch name and conflict details,
then move on. Report all failures in the final summary.

## Step 5 - Run the verify sequence

After all merges, run `$TEST_CMD`.

When it comes from `~/work_bin/test_pr`, **do not invoke the script directly.** Read the repo's
`case` block and run its steps individually, with two adjustments:

1. **Skip `git pull`.** The batch branch has local merge commits not on the remote, so a pull would
   fail or try to merge remote state. For Solidity repos the sequence still includes
   `rm -rf lib/ && git submodule update --init`; run that, it syncs submodules to the merged gitlinks
   (e.g. an OpenZeppelin bump).
2. **Run each step separately, not as one chained `&&`.** The script uses `set -euo pipefail` and
   aborts on first failure; running steps individually lets you report each result and continue.

For `cows` the full sequence minus `git pull` is: `foundryup`, `npm i`,
`rm -rf lib/ && git submodule update --init`, `forge t`, `npx hardhat test`, `npm run prettier:check`,
`npm run prettier:solidity:check`, `npm run solhint`, `npm run lint:check`, `slither .`.

Report each step's result. Do **not** block remaining steps on a failure; note it prominently and
continue to Step 6.

## Step 6 - Close individual PRs

For every PR successfully merged **or** skipped as a duplicate, close it with a comment naming the
batch branch and explaining it is closed in favor of the consolidated branch.

PRs that **failed** to merge stay open; note them in the summary. Major bumps delegated to a ticket
(Step 2b) were already closed with a ticket-reference comment, so do not re-close them or apply the
batch comment.

## Step 7 - Push and monitor CI

The assistant **cannot** run `git push`; a local git hook blocks it. Ask the user to push the batch
branch themselves (e.g. `! git push origin <branch>`). Once pushed, monitor CI.

### 7a. Find the runs for the pushed SHA

List runs for `git rev-parse HEAD`, then inspect their jobs.

**Gotcha:** several runs have similar names. The substantive one contains the build and unit-test
jobs (named `CI` on boats, but the name differs per repo, so identify it **by its jobs, not its
name**). Do not mistake a lightweight `triage`/labeler run (a single quick job) for it; those go
green in seconds while the real build is still queued.

### 7b. Watch to completion

`gh run watch <run-id> --exit-status`, in the background so other checks (lint, helm lint) can be
watched in parallel. Report each workflow's final per-job conclusion. CI failure does not roll back
the batch; note it prominently and let the user decide.

### 7c. Check for the "Approved" label

The batch must **not** be suggested for merge unless the batch PR carries an `Approved` label. Check
the PR's labels for it and record the result; it gates the merge prompt in the final summary.

## Step 8 - Final summary

Report: repo, batch branch, merged PRs, closed-as-duplicate PRs (with which PR each duplicated),
delegated PRs (with ticket key and the reminder to set parent/sprint manually), failed PRs with
reasons, verify-sequence result, CI result, and whether the `Approved` label is present.

**Next step depends on the `Approved` label:**

- **Present:** suggest landing the batch. "Review the batch branch, then comment `/promethea merge`
  on the batch PR to land it into the integration branch."
- **Absent:** do **not** suggest or perform the merge. State that the batch is ready but waiting on
  the `Approved` label. Do not prompt for `/promethea merge` until it is added.

Never push `--force`, and never merge the batch branch to the integration branch automatically.
