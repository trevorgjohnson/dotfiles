---
name: flesh-pr
description: >-
  Flesh out a GitHub PR body using the associated Jira ticket. Extracts the
  ticket key from the branch name, fetches context and AC from Jira, and
  updates the open PR. Use when a PR has a stub or template body that needs
  to be filled in.
---

# Flesh PR

Update an open GitHub PR's body using the associated Jira ticket for context,
acceptance criteria, and description. Keeps the repo's existing PR template
structure — only fills in the content.

## Steps

### 1. Verify tooling

Run all three checks in one call:

```bash
which acli && acli --version && acli auth status 2>&1
```

If `acli` is not installed or not authenticated, follow the guidance in the
jira skill. Do not proceed until auth is confirmed.

### 2. Resolve the Jira ticket key

Extract from the current branch name — the key is the leading `KEY-NNN` segment:

```bash
git branch --show-current
```

Pattern: `^([A-Z]+-[0-9]+)`. If the branch name doesn't contain a ticket key,
check the existing PR body for a `For Jira Ticket:` line. If still not found,
ask the user.

If `$ARGUMENTS` contains a ticket key (e.g. `BLOC-937`), use that instead.

### 3. Fetch PR and Jira data in parallel

Run both in a single message:

```bash
# Current PR
gh pr view --head "$(git branch --show-current)" --json number,title,body,url

# Jira ticket
acli jira workitem view KEY-NNN --json
```

Extract from the Jira response:
- `fields.summary` — ticket title
- `fields.description` — ADF document; walk the content tree to extract plain
  text. Headings become `### Heading`, bullet list items become `- item`.
- `fields.issuetype.name` — used to infer the type of change checkbox

### 4. Get commit context

```bash
git log <base>..HEAD --oneline
```

Use this to write the Change Log bullets. Base branch is `develop` if present,
otherwise `main`, then `master`.

### 5. Determine type of change

Map Jira issue type and ticket content to the repo's checkbox list:

| Signal | Checkbox |
|--------|----------|
| issuetype = Bug | Bug Fix |
| "breaking" in summary/description | Breaking Change |
| issuetype = Story or "feature" in summary | New Feature |
| "refactor" in summary | Refactor |
| issuetype = Task and content is a dep upgrade or chore | Other |

If the existing body already has a checked box, preserve it unless clearly wrong.
When "Other" is checked, add a one-sentence explanation on the line below.

### 6. Draft the updated body

Preserve the repo's existing PR template structure exactly — headings, comment
tags (`[//]: #`), footnotes — only replace content inside the variable sections:

- **Jira link**: make the ticket key a hyperlink →
  `[KEY-NNN](https://prometheum.atlassian.net/browse/KEY-NNN)`
- **Type of Change**: check the appropriate box; add explanation if Other
- **Change Log**: 2–4 bullets derived from commits + ticket context. Focus on
  *what* changed and *why*, not a file list.
- **Acceptance Criteria**: replace the template checklist with the AC items
  from the Jira ticket. Preserve the `- [ ]` unchecked format.

Do **not** remove the Prerequisites section, footnotes, or Additional Notes
unless they are empty placeholders.

### 7. Show draft and confirm

Present the full proposed body as a fenced markdown block. Ask the user to
confirm before applying. If they request edits, revise and re-show before
applying.

### 8. Apply the update

```bash
gh pr edit <number> --body "$(cat <<'EOF'
<body>
EOF
)"
```

Print the PR URL when done.

## Notes

- If `$ARGUMENTS` is provided, treat it as either a ticket key override or
  additional context to fold into the Change Log or body.
- Do not change the PR title unless the user asks.
- If no open PR exists for the current branch, say so and stop — do not create one.
- If the Jira ticket has no description, derive context from the summary and commits only.
