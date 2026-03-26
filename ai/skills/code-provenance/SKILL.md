---
name: code-provenance
version: 1.0.0
description: >-
  Trace code history: who wrote it, when, why, and how it evolved. Use for file/function/line history questions.
---

# Code Provenance

## When tracing code provenance, follow this structure

### 1. Identify the target

Clarify what the user wants history for: a specific file, function, line range, or pattern. If ambiguous, ask.

### 2. Gather the history

Use git commands to build a complete picture. Choose the right tools for the scope:

**For a file's full history:**

```bash
git log --follow --format="%h %as %an %s" -- <file>
```

**For a specific function or line range:**

```bash
git log -L :<function_name>:<file>
# or
git log -L <start>,<end>:<file>
```

**For line-by-line attribution:**

```bash
git blame -w -C -C -C <file>
# -w ignores whitespace, -C -C -C tracks code movement across files
```

**For a specific line range:**

```bash
git blame -w -C -C -C -L <start>,<end> <file>
```

**For understanding a specific commit's full context:**

```bash
git show --stat <hash>
git show <hash> -- <file>
```

**For finding when a string was introduced or removed:**

```bash
git log -S "<string>" --format="%h %as %an %s" -- <file>
```

**For finding when a regex pattern changed:**

```bash
git log -G "<pattern>" --format="%h %as %an %s" -- <file>
```

**For tracking code movement between files:**

```bash
git log --follow --diff-filter=R --format="%h %as %an %s" -- <file>
```

### 3. Present the timeline

Summarize the history as a timeline, starting from the most significant events:

- **Origin**: When and by whom was this code first introduced? What was the original intent?
- **Major changes**: What were the significant modifications? Group related commits.
- **Contributors**: Who has touched this code? Who are the primary authors vs one-time editors?
- **Context**: Link commits to PRs, issues, or tickets when commit messages reference them.

### 4. Analyze the "why"

Go beyond the raw log:

- Read commit messages carefully for intent and rationale
- If a commit references a PR number, note it so the user can follow up
- Identify patterns: was this code refactored repeatedly? Has it been stable? Is it a hotspot with frequent changes?
- Flag any force-pushes, reverts, or merge conflicts that may have altered the history

### 5. Highlight key findings

Call out anything notable:

- **Code hotspots**: Files or functions with unusually high churn
- **Knowledge concentration**: If only one person has ever touched this code
- **Renames and moves**: If the code lived elsewhere before
- **Reverts**: If changes were rolled back and why
- **Age**: How old the code is and whether it predates current conventions

### Formatting guidelines

- Use tables for contributor summaries and commit timelines
- Use commit short hashes (7 chars) linked to context when relevant
- Keep the narrative concise — focus on the story, not raw git output
- When showing blame output, highlight the interesting lines rather than dumping the entire file
