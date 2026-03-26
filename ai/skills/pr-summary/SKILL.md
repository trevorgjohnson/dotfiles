---
name: pr-summary
description: >-
  Generate a PR title and body from the current branch's diff against the base branch.
  Use when the user wants to draft a pull request description.
---

# PR Summary

Generate a concise PR title and body from the current branch's changes.

## Steps

1. Identify the base branch:
   ```bash
   git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@refs/remotes/origin/@@'
   ```
   Fall back to `main`, then `master`.

2. Get the full diff and commit log:
   ```bash
   git log --oneline <base>..HEAD
   git diff <base>...HEAD --stat
   git diff <base>...HEAD
   ```

3. Generate:
   - **Title**: Under 70 chars, conventional commit style without scope (matching the user's git convention). Use the right verb: `add` for new features, `fix` for bugs, `refactor` for restructuring, `chore` for maintenance.
   - **Body**: Use this format:
     ```
     ## Summary
     <2-4 bullet points explaining what changed and why>

     ## Test plan
     <bulleted checklist of how to verify the changes>
     ```

4. Output the title and body as copyable text. Do NOT create the PR — just draft the content for review.

## Notes

- If `$ARGUMENTS` is provided, treat it as additional context for the summary (e.g., "this fixes the flaky timeout issue").
- Focus on the *why*, not a file-by-file changelog.
- If the diff is large, group related changes into logical themes.
