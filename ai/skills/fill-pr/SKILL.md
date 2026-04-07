---
name: pr
description: >-
  Draft or fill out a GitHub PR. Two modes: (1) generate a PR title and body
  from the current branch's diff — use when drafting a new PR; (2) flesh out
  a stub PR body using the associated Jira ticket — use when a PR already
  exists with a template body. Use when the user wants to create or improve a
  pull request description.
---

# PR

Two modes depending on context:

- **Draft** — generate a PR title + body from the current branch diff (no existing PR required)
- **Flesh out** — fill in a stub/template PR body using the associated Jira ticket (PR already exists)

Detect the mode automatically:
- If a PR already exists for the current branch AND the body looks like an unfilled template → **Flesh out**
- Otherwise → **Draft**
- If `$ARGUMENTS` contains a Jira ticket key (e.g. `BLOC-937`), force **Flesh out** mode with that ticket

---

## Draft mode

Generate a concise PR title and body from the current branch's changes.

### Steps

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
   - **Title**: Under 70 chars, conventional commit style without scope. Use the right verb: `add` for new features, `fix` for bugs, `refactor` for restructuring, `chore` for maintenance.
   - **Body**:
     ```
     ## Summary
     <2-4 bullet points explaining what changed and why>

     ## Test plan
     <bulleted checklist of how to verify the changes>
     ```

4. Output the title and body as copyable text. Do NOT create the PR — just draft the content for review.

### Notes

- If `$ARGUMENTS` is provided, treat it as additional context (e.g. "this fixes the flaky timeout issue").
- Focus on the *why*, not a file-by-file changelog.
- If the diff is large, group related changes into logical themes.

---

## Flesh out mode

Update an open GitHub PR's body using the associated Jira ticket for context, acceptance criteria, and description. Keeps the repo's existing PR template structure — only fills in the content.

### Steps

#### 1. Verify tooling

```bash
which acli && acli --version && acli auth status 2>&1
```

If `acli` is not installed or not authenticated, follow the guidance in the jira skill. Do not proceed until auth is confirmed.

#### 2. Resolve the Jira ticket key

Extract from the current branch name — the key is the leading `KEY-NNN` segment:

```bash
git branch --show-current
```

Pattern: `^([A-Z]+-[0-9]+)`. If the branch name doesn't contain a ticket key, check the existing PR body for a `For Jira Ticket:` line. If still not found, ask the user.

If `$ARGUMENTS` contains a ticket key (e.g. `BLOC-937`), use that instead.

#### 3. Fetch PR and Jira data in parallel

```bash
# Current PR
gh pr view --head "$(git branch --show-current)" --json number,title,body,url

# Jira ticket
acli jira workitem view KEY-NNN --json
```

Extract from the Jira response:
- `fields.summary` — ticket title
- `fields.description` — ADF document; walk the content tree to extract plain text. Headings become `### Heading`, bullet list items become `- item`.
- `fields.issuetype.name` — used to infer the type of change checkbox

#### 4. Get commit context

```bash
git log <base>..HEAD --oneline
```

Base branch is `develop` if present, otherwise `main`, then `master`.

#### 5. Determine type of change

| Signal | Checkbox |
|--------|----------|
| issuetype = Bug | Bug Fix |
| "breaking" in summary/description | Breaking Change |
| issuetype = Story or "feature" in summary | New Feature |
| "refactor" in summary | Refactor |
| issuetype = Task and content is a dep upgrade or chore | Other |

If the existing body already has a checked box, preserve it unless clearly wrong. When "Other" is checked, add a one-sentence explanation on the line below.

#### 6. Draft the updated body

Preserve the repo's existing PR template structure exactly — headings, comment tags (`[//]: #`), footnotes — only replace content inside the variable sections:

- **Jira link**: `[KEY-NNN](https://prometheum.atlassian.net/browse/KEY-NNN)`
- **Type of Change**: check the appropriate box; add explanation if Other
- **Change Log**: 2–4 bullets derived from commits + ticket context. Focus on *what* changed and *why*, not a file list.
- **Acceptance Criteria**: replace the template checklist with the AC items from the Jira ticket. Preserve the `- [ ]` unchecked format.

Do **not** remove the Prerequisites section, footnotes, or Additional Notes unless they are empty placeholders.

#### 7. Show draft and confirm

Present the full proposed body as a fenced markdown block. Ask the user to confirm before applying. If they request edits, revise and re-show before applying.

#### 8. Apply the update

```bash
gh pr edit <number> --body "$(cat <<'EOF'
<body>
EOF
)"
```

Print the PR URL when done.

### Notes

- Do not change the PR title unless the user asks.
- If no open PR exists for the current branch, say so and stop — do not create one.
- If the Jira ticket has no description, derive context from the summary and commits only.
