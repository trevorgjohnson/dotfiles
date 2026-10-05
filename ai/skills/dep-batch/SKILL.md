---
name: dep-batch
description: Consolidate Prometheum Dependabot/Renovate PRs into a dependency batch branch and close the individual PRs.
triggers:
  - /dep-batch
---

Batch dependency PRs on the current `chore/YYYY-MM-DD-batch-deps` branch.
Abort for a different branch or dirty working tree; verify `gh` authentication and repo targeting.
Authors are `app/dependabot` and `app/prometheum-renovate`.
Detect the repo, integration base, package manager, lockfile, and verification commands; ask about ambiguity.
Prometheum often uses `develop` rather than the default branch; check actual PR bases and confirm mismatches with the user.
Prefer the repo's case in `~/work_bin/test_pr` over guessed package scripts; `cows` has no `test` or `test:unit` script.

List open PRs for both authors targeting the agreed integration base, with a high limit and fields `number,title,headRefName,updatedAt,baseRefName`.
Deduplicate by package and update target, keeping the highest target version and then latest `updatedAt` on ties.
Distinct Docker targets such as node bullseye and bullseye-slim both remain.
Flag major upgrades with from/to versions before merging and recommend separate tech-debt tickets; let the user decide per PR.
Present merge, duplicate/close, and ticket-delegation tables and get confirmation before proceeding.
For approved ticket delegation, use `acli`: include versions, blockers, PR number, similar prior tickets, and labels `tech-debt` plus the product label.
Close that PR with a ticket-reference comment and remind the user to set parent/epic and sprint manually because acli cannot set them.

Fetch origin once and merge each retained branch sequentially in ascending PR-number order.
For overlapping Docker image updates, merge the image touching most lines first, such as node-slim before busybox.
Use `git merge --no-ff --no-verify origin/<headRefName> -m "chore: merge PR #<number> - <title>"`.
The batch branch lacks a Jira ticket, so the commit-msg hook requires `--no-verify`.
Resolve manifest conflicts manually, retaining higher dependency versions and previously merged updates; never take the whole incoming manifest.
Resolve Dockerfile/workflow conflicts similarly; avoid wholesale `-X theirs` on shared hunks.
For a conflicted lockfile, take one side, then regenerate from the resolved manifest:

- npm: `npm install --package-lock-only --ignore-scripts`
- yarn: `yarn install --mode update-lockfile`
- pnpm: `pnpm install --lockfile-only --ignore-scripts`

Use a plain install only if the lockfile-only mode is unavailable.
Check for remaining conflict markers, stage resolutions, and complete with `git commit --no-verify`.
For semantic application conflicts that cannot be resolved, abort that PR's merge, record the branch and reason, and continue.

Run verification after all merges.
Read `test_pr` rather than invoking it: omit `git pull`, run each command separately, and continue after failures while reporting every result.
Retain Solidity submodule synchronization, `rm -rf lib/ && git submodule update --init`, to match merged gitlinks.

Even if verification fails, close successfully merged and duplicate PRs before the push, commenting that they are consolidated into the named batch branch.
Leave failed merges open and do not re-close ticket-delegated PRs.
Ask the user to push the branch; the assistant's local hook blocks `git push`.
Never force-push or merge the batch into integration automatically.

After the push, ask whether to watch CI, audit packages, do both, or neither; neither is automatic.
Always check the batch PR's `Approved` label.
For CI, inspect runs at the pushed HEAD SHA and identify substantive build/test workflows by jobs, not names; triage/labeler runs are insufficient.
Watch selected runs with `gh run watch <run-id> --exit-status` in the background and report final job conclusions.
CI failure does not roll back the batch.

For an optional audit, use a fresh-context read-only agent with the repo, base, batch branch, all from/to versions, and verification results.
Check release notes, breaking changes, advisories, and production-code changes, including Solidity submodules.
Require executed advisory checks, reporting actual command errors rather than claiming checks were unavailable.
For npm, compare baseline and batch with `npm audit --package-lock-only --json`, placing baseline `package.json` and `package-lock.json` from `origin/<base>` in a temporary directory.
Query GitHub Advisory DB for each bumped version using `gh api "/advisories?ecosystem=npm&affects=<pkg>@<new-version>" -q 'map(.ghsa_id+" "+.severity)'`, using `ecosystem=actions` for Actions.
Request under 250 words: SAFE / SAFE WITH CAVEATS / NOT SAFE, one risk line per bump, and caveats.

Report repo, branch, merged PRs, duplicates with retained counterparts, delegated tickets with parent/sprint reminder, failed merges, verification results, optional CI/audit results, and the `Approved` label status.
Only when `Approved` is present, suggest reviewing the batch and commenting `/promethea merge` on its PR to land it.
Otherwise state that it is waiting for `Approved` and do not suggest merging.
