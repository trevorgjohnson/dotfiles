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

Automates the manual dependency-batch workflow for any Prometheum repo.
Collects all open Dependabot/Renovate PRs targeting the repo's integration
branch, merges them into the current batch branch one at a time (resolving
conflicts), runs unit tests, closes the individual PRs with a comment, then
monitors CI once the user pushes the batch branch.

**The skill never merges the batch branch to the integration branch** — the
user controls that final step.

## Org-wide constants

These hold across all Prometheum repos (boats, cows, ...):

- Dependency PR authors: `app/dependabot`, `app/prometheum-renovate`
- Merge bot: comment `/promethea merge` on the batch PR to land it
- Batch branch naming: `chore/YYYY-MM-DD-batch-deps`

## Step 0 — Detect repo settings

Everything else is auto-detected from the repo. Run these from the repo root
and confirm any ambiguous value with the user before proceeding.

```bash
# Repo (owner/name) — used for every gh call below as $REPO
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

# Integration branch — the base most dep PRs target. Prefer the repo default
# branch, but Prometheum repos often target `develop`. Verify against the
# actual PR bases in Step 1 and prompt if they disagree.
BASE=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)

# Package manager — from the lockfile present at repo root
#   package-lock.json -> npm,  yarn.lock -> yarn,  pnpm-lock.yaml -> pnpm
ls package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null

# Verification sequence — FIRST check the user's canonical per-project script.
# ~/work_bin/test_pr holds the full verify sequence (build, test, lint, static
# analysis) keyed by repo directory name (platform-backend/boats-backend/cows).
# If present and the repo is recognized, derive $TEST_CMD from its sequence
# (see Step 5). Only fall back to package.json scripts if it is absent.
cat ~/work_bin/test_pr 2>/dev/null
cat package.json | grep -A20 '"scripts"'
```

Resolve and record for the rest of the run:
- `$REPO` — e.g. `prometheumlabs/boats-backend`, `prometheumlabs/cows`
- `$BASE` — e.g. `develop`
- `$LOCKFILE` + package manager — `package-lock.json`/npm, `yarn.lock`/yarn,
  `pnpm-lock.yaml`/pnpm
- `$TEST_CMD` — the verify sequence. Prefer the block for this repo in
  `~/work_bin/test_pr`; else a package.json script (`test:unit` then `test`).
  Note `cows` is a Solidity repo with no `test`/`test:unit` script — its verify
  sequence (forge + hardhat + lint + slither) lives only in `test_pr`.

If any value is ambiguous (no obvious test script, multiple lockfiles, PR bases
disagree with the detected default branch), **ask the user** rather than guess.

## Prerequisites

Confirm the following before starting:

1. The current branch matches the convention `chore/YYYY-MM-DD-batch-deps`.
   Abort with an error if not.
2. The working tree is clean (`git status`). Abort if there are uncommitted
   changes.
3. `gh` CLI is authenticated and targeting the correct repo (`$REPO`).

## Step 1 — List open dependency PRs

```bash
gh pr list --repo "$REPO" --state open --base "$BASE" \
  --author app/dependabot \
  --json number,title,headRefName,updatedAt,baseRefName --limit 200

gh pr list --repo "$REPO" --state open --base "$BASE" \
  --author app/prometheum-renovate \
  --json number,title,headRefName,updatedAt,baseRefName --limit 200
```

Combine the two result sets into a single working list. Record each PR's:
`number`, `title`, `headRefName`, `updatedAt`. If the dep PRs target a base
other than the detected `$BASE`, re-run with the correct base (and confirm
with the user).

## Step 2 — Deduplicate by package

Group the PRs by the package they update. The package name can be derived from
the PR title (e.g. `chore(deps): bump lodash from 4.17.20 to 4.17.21` → `lodash`).

For each group with more than one PR:
- Keep the PR with the **highest target version**. If versions are tied,
  keep the one with the latest `updatedAt`.
- Mark the rest as **skipped (duplicate)** — do not merge them, but close
  them at the end with the same batch comment.

Note: separate PRs that touch related-but-distinct targets are **not**
duplicates (e.g. a node `bullseye` image and a node `bullseye-slim` image are
different Dockerfile lines — keep both).

After deduplication, present the user with:
- A table of PRs to merge (number, title, branch).
- A table of PRs to skip/close as duplicates.

Ask the user to confirm before proceeding.

## Step 3 — Fetch all PR branches

```bash
git fetch origin
```

One fetch is sufficient; all remote refs will be updated.

## Step 4 — Merge each PR branch

Process the deduplicated "merge" list one PR at a time in order of PR number
(ascending). For each PR:

### 4a. Attempt merge

```bash
git merge --no-ff --no-verify origin/<headRefName> -m "chore: merge PR #<number> - <title>"
```

Note: `--no-verify` is required on batch branches (e.g. `chore/YYYY-MM-DD-batch-deps`)
because the commit-msg hook rejects commits from branches without a Jira ticket in the name.

### 4b. Handle lockfile conflicts

If the lockfile (`$LOCKFILE`) is listed as conflicted, accept one side to get a
valid manifest, then regenerate the lockfile from the merged manifest state —
this is the canonical resolution. Use the command for the detected package
manager:

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

If the `--*-only` flag is unavailable, fall back to a plain install for that
package manager — it produces an equivalent lockfile.

### 4c. Handle `package.json` / manifest conflicts

Dependabot group PRs frequently conflict on the manifest itself (the batch
branch already bumped some of the same deps). The conflict is usually a diff3
3-way hunk per dependency line.

1. Inspect the conflict (`git diff package.json` or the manifest).
2. For each conflicting dependency line keep the **higher version**. Often the
   PR side wins every hunk, but verify — the batch branch may already be ahead
   on some.
3. Resolve the hunks manually (edit the file). Avoid `git checkout --theirs`
   on the **manifest**: it clobbers any batch-only bumps that merged cleanly
   elsewhere in the file. (`--theirs` is only safe on the lockfile, which you
   regenerate anyway.)
4. Verify no markers remain (`grep -c '^<<<<<<<' package.json` → 0), then
   regenerate the lockfile per 4b.

### 4d. Handle conflicts in other files (Dockerfile, `.github/workflows/*`, etc.)

These files may have multiple dep bumps touching the same line (e.g. a base
image version, or a GitHub Action digest). Resolution strategy:

1. Show the conflicted diff to evaluate what each side changes.
2. Accept **both sets of dep changes** — the goal is to keep every update.
   For version-string conflicts where both sides bump the same line, keep the
   **higher version**.
3. Be careful with `-X theirs` on Dockerfile — if two images are in the same
   conflict hunk, `-X theirs` may revert a previously merged image. Prefer
   manual resolution for multi-line conflict hunks.
4. Stage the resolved file: `git add <file>`.

After resolving all conflicts, complete the merge:

```bash
git commit --no-verify -m "chore: merge PR #<number> - <title>"
```

### 4e. Unresolvable conflicts

If a conflict cannot be resolved automatically (i.e. semantic conflict in
application code, not a dep file), **abort the merge** for that PR:

```bash
git merge --abort
```

Record the PR as **failed** (include branch name and conflict details) and
move on to the next PR. Report all failed PRs in the final summary.

## Step 5 — Run unit tests

After all merges are complete, run `$TEST_CMD`.

When `$TEST_CMD` comes from `~/work_bin/test_pr`, **do not invoke the script
directly** — read the repo's `case` block and run its steps individually,
with two adjustments:

1. **Skip `git pull`.** The batch branch has local merge commits not on the
   remote, so a pull would fail or try to merge remote state. (For Solidity
   repos the sequence still includes `rm -rf lib/ && git submodule update
   --init` — run that; it syncs submodules to the merged gitlinks, e.g. an
   OpenZeppelin bump.)
2. **Run each step separately, not as one chained `&&`.** The script uses
   `set -euo pipefail` and aborts on the first failure; running steps
   individually lets you report each result and continue (see below).

Example for `cows` (the full sequence minus `git pull`): `foundryup` → `npm i`
→ `rm -rf lib/ && git submodule update --init` → `forge t` → `npx hardhat test`
→ `npm run prettier:check` → `npm run prettier:solidity:check` →
`npm run solhint` → `npm run lint:check` → `slither .`.

Report each step's result (pass / fail). Do **not** block the remaining steps
on a failure — note it prominently in the summary but continue to Step 6.

## Step 6 — Close individual PRs

For every PR that was successfully merged **or** skipped as a duplicate,
close it with a comment:

```bash
BRANCH=$(git branch --show-current)
gh pr close <number> --repo "$REPO" \
  --comment "Merged into \`$BRANCH\` as part of the dependency batch. This PR is being closed in favor of the consolidated batch branch."
```

For PRs that **failed** to merge, do not close them — leave them open and
note them in the summary.

## Step 7 — Push and monitor CI

The assistant **cannot** run `git push` — a local git hook blocks it. Ask the
user to push the batch branch themselves (e.g. `! git push origin <branch>`).
Once pushed, monitor CI to confirm the batch is green.

### 7a. Find the runs for the pushed SHA

```bash
SHA=$(git rev-parse HEAD)
gh run list --repo "$REPO" --commit "$SHA" \
  --json databaseId,workflowName,status,conclusion \
  --jq '.[] | "\(.databaseId)  \(.workflowName): \(.status)/\(.conclusion)"'
```

**Gotcha:** several runs have similar names. The substantive one is the
workflow that contains the build + unit-test jobs (named `CI` on boats — the
build/test workflow name may differ per repo, so identify it by its jobs, not
its name). Do **not** mistake a lightweight `triage`/labeler run (single quick
job) for it; those go green in seconds while the real build is still queued.
Confirm by inspecting jobs:

```bash
gh run view <run-id> --repo "$REPO" \
  --json workflowName,status,conclusion,jobs \
  --jq '{workflowName, status, conclusion, jobs: [.jobs[]|"\(.name): \(.status)/\(.conclusion)"]}'
```

### 7b. Watch to completion

```bash
gh run watch <run-id> --repo "$REPO" --exit-status
```

Run this in the background so other checks (lint, helm lint) can be watched in
parallel. Report each workflow's final per-job conclusion. CI failure does not
roll back the batch — note it prominently and let the user decide.

### 7c. Check for the "Approved" label

The batch must **not** be suggested for merge into the integration branch
unless the batch PR carries an `Approved` label. Check it:

```bash
gh pr view <batch-pr-number> --repo "$REPO" --json labels \
  --jq '[.labels[].name] | index("Approved") != null'
```

(Use `gh pr list --repo "$REPO" --head "$BRANCH" --json number` to find the
batch PR number if needed.) Record whether `Approved` is present — it gates
the merge prompt in the final summary.

## Step 8 — Final summary

Print a structured summary:

```
Repo:         <owner/name>
Batch branch: chore/YYYY-MM-DD-batch-deps

Merged PRs (N):
  #<num>  <title>

Closed as duplicates (N):
  #<num>  <title>  (duplicate of #<kept-num>)

Failed / skipped (N):
  #<num>  <title>  — reason: <conflict details>

Unit tests: PASSED / FAILED
CI (remote): PASSED / FAILED / not yet pushed
Approved label: present / absent
```

**Next step depends on the `Approved` label (Step 7c):**

- **`Approved` present:** suggest landing the batch — "review the batch branch,
  then comment `/promethea merge` on the batch PR to land it into the
  integration branch."
- **`Approved` absent:** do **not** suggest or perform the merge. State that the
  batch is ready but is waiting on the `Approved` label before it can be merged.
  Do not prompt for `/promethea merge` until the label is added.

## Notes

- Repo, base branch, package manager, and test command are auto-detected in
  Step 0 — the skill is not boats-specific. Prompt the user on ambiguity.
- The canonical verify sequence per repo lives in `~/work_bin/test_pr` (keyed
  by repo dir name). Prefer it over guessing from package.json. Replicate its
  steps individually, skipping `git pull` (Step 5).
- PR authors to target: `app/dependabot`, `app/prometheum-renovate` (org-wide)
- Never push `--force` or merge the batch branch to the integration branch
  automatically — the user owns that step.
- Never suggest `/promethea merge` unless the batch PR has the `Approved`
  label (Step 7c). Without it, report the batch as ready-but-blocked.
- Merge order matters for Dockerfile: merge the image that touches the most
  lines first (e.g. node-slim before busybox) to avoid `-X theirs` reverting
  a prior update in a shared conflict hunk.
