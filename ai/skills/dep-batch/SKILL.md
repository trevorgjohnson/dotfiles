---
name: dep-batch
description: Merge renovate/dependabot PRs into a batch branch and update the batch PR body. Use when merging automated dependency PRs into a batch branch.
argument-hint: '<pr-numbers...> e.g. 1880 1881 1882 1883 1884'
---

# dep-batch

Merge renovate/dependabot PRs into the current batch branch and keep the
batch PR body up to date.

## Quick start

```
/dep-batch 1880 1881 1882 1883 1884
```

Merges those PRs into the current branch, resolves any lockfile conflicts,
then runs `/fill-pr` to extend the batch PR body.

## Workflow

### 1. Identify PRs

```bash
gh pr list --state open --limit 30
```

Confirm the PR numbers (and their branch names) with the user if not provided
as arguments.

### 2. Fetch all branches

```bash
git fetch origin <branch1> <branch2> ...
```

Get branch names from `gh pr view <number> --json headRefName -q .headRefName`.

### 3. Merge sequentially

```bash
git merge origin/<branch> --no-edit --no-verify
```

Use `--no-verify` on every merge commit. Batch branch names (`chore/YYYY-MM-DD-batch-update-*`)
don't match the `[feat|epic/]?TICKET-123-*` pattern enforced by commitlint, so
the `commit-msg` hook always blocks — `--no-verify` is the established pattern
for this branch type.

If a merge is clean, move to the next. If it produces conflicts, resolve them
(see below) then `git commit --no-verify` to complete the merge.

### 4. Resolve conflicts

| File | Strategy |
|---|---|
| `package-lock.json` | `git checkout --theirs package-lock.json && git add package-lock.json` |
| `package.json` | Usually auto-merges; if it conflicts, also `--theirs` |
| `.github/` workflow files | Auto-merge expected; if conflict, use `AskUserQuestion` |
| Source files | Use `AskUserQuestion` — not expected in a deps batch |

Incoming PRs always carry newer package versions, so `--theirs` is always
correct for lockfile conflicts.

### 5. Update the batch PR body

```
/fill-pr
```

The PR body uses running tables (Docker images, GitHub Actions, npm packages).
**Extend** the existing rows — do not replace them. Append new PR numbers to
the `## Closed PRs` line.

### 6. Close merged PRs

Use `AskUserQuestion`:

```
Close the merged source PRs? This will close #NNNN, #NNNN, ... with a comment
pointing to the batch PR.

1. Yes — close all (Recommended)
2. No — leave open
```

If confirmed:

```bash
gh pr close <number> --comment "Merged into <batch-branch> (#<batch-pr>)."
```

## Notes

- Merge order doesn't matter for correctness, but process workflow/action PRs
  before npm PRs to keep conflicts minimal.
- If the batch PR doesn't exist yet, create it with `/fill-pr` in draft mode
  before running this skill.
- Never force-push the batch branch — it's a shared review branch.
