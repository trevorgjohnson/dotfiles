---
name: annotate-pr
description: >-
  Add brief contextual inline annotations to an open GitHub PR as review
  comments. Use after a PR body is written, when non-obvious changes benefit
  from a sentence of context for reviewers. Follows a "only as much as
  necessary" style. Re-running on a PR with existing annotations rehydrates
  them — adds missing ones, removes stale ones.
---

# annotate-pr

Posts inline review comments on a PR's diff — brief, plain-language notes
that explain *why* something exists or *what* a non-obvious change does.
The goal is reviewer orientation, not documentation.

Re-running the skill on a PR that already has annotations **rehydrates**
them: stale comments (whose lines no longer exist in the diff) are removed,
and newly non-obvious lines get fresh annotations.

## Phase 1 — Gather diff context

Run in parallel:

```bash
# Identify base branch
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@refs/remotes/origin/@@'

# PR metadata + HEAD SHA
gh pr view --json number,headRefOid,baseRefName --jq '{number,sha:.headRefOid,base:.baseRefName}'

# Repo owner/name
gh repo view --json nameWithOwner --jq '.nameWithOwner'

# Current authenticated user (to scope existing comments)
gh api user --jq '.login'

# Existing review comments on the PR
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --jq '[.[] | {id,path,line,body,user:.user.login}]'
```

```bash
# Full diff
git diff <base>...HEAD --stat
git diff <base>...HEAD
```

If `$ARGUMENTS` contains a PR number or URL, use that PR instead of the
current branch's PR.

## Phase 1b — Rehydrate check

Filter existing comments to those posted by the current authenticated user.
Build a set of **live diff lines**: every `(path, line)` pair that appears
as an added line (`+`) in the current diff.

For each existing annotation by the current user, classify it:

| Classification | Condition | Action |
|---|---|---|
| **Keep** | `(path, line)` still in live diff lines, content still relevant | No change |
| **Stale** | `(path, line)` no longer in live diff lines | Queue for deletion |
| **Outdated** | Line exists but surrounding context changed significantly | Flag for review |

Carry the keep/stale/outdated map into Phase 2 so new targets don't
duplicate already-covered lines.

## Phase 2 — Identify annotation targets

Scan the diff for lines worth annotating. Good targets:

| Worth annotating | Example |
|---|---|
| A new constraint with a non-obvious reason | `--no-ff` on long-lived branch merges |
| A new concept or abstraction | new config file type, new service layer |
| A removal or exclusion that might look like an oversight | file added to `.gitignore` |
| A significant behavior change buried in a small diff | timeout bumped from 30s to 10m |
| A file whose purpose isn't clear from its name alone | new entrypoint, new rule file |

Skip these — they're self-explanatory:

- Variable/function renames
- Obvious formatting or lint fixes  
- Changes where the diff comment would just restate the code
- Lines already explained by a surrounding comment or docstring

Aim for **3–6 annotations** per PR. Fewer is better than padding.

## Phase 3 — Draft annotations

Write each annotation as a short plain-language note:

- 1–3 sentences max
- Lead with "This...", "The `X`...", or a direct factual statement
- Explain *why* or *what this is for*, not what the diff literally shows
- No markdown headers or lists — prose only
- Match the register of a code review comment, not documentation

**Good:** `The --no-ff constraint is load-bearing — squashing or rebasing long-lived branches breaks the shared ancestry Git relies on for bidirectional syncs.`

**Bad:** `This line adds --no-ff to the merge command.` *(restates the diff)*

## Phase 4 — Confirm and apply

Present a reconciliation table covering all planned changes:

| Action | File | Line | Comment |
|---|---|---|---|
| **Add** | path/to/file | N | Draft text |
| **Keep** | path/to/file | N | *(existing text)* |
| **Delete** | path/to/file | N | *(existing text — stale)* |
| **Review** | path/to/file | N | *(existing text — context changed)* |

Use `AskUserQuestion` to confirm before making any changes. If the user edits,
removes, or re-classifies any entry, apply their changes before proceeding.

**Post new annotations:**

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --method POST \
  -f body="{text}" \
  -f commit_id="{sha}" \
  -f path="{file}" \
  -f side="RIGHT" \
  -F line={line} \
  --jq '.html_url'
```

**Delete stale annotations:**

```bash
gh api repos/{owner}/{repo}/pulls/comments/{comment_id} --method DELETE
```

Print a summary when done: N added, N deleted, N kept.

## Notes

- Only annotate lines that are part of the diff (`side: "RIGHT"` = added lines).
  Deleted lines can't receive review comments.
- If a file is entirely new and the non-obvious thing is the file's existence
  itself, annotate line 1.
- Never annotate test files unless the test approach is genuinely unusual.
- If the diff is small and self-evident, it's fine to post zero annotations —
  say so rather than padding.
