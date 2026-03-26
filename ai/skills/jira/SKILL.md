---
name: jira
version: 1.0.0
description: >-
  Create, view, search, edit, transition, and manage Jira tickets.
argument-hint: '[create|view|search|edit|transition|comment|assign|link] [details]'
---

# Jira Ticket Management

Manage Jira tickets using the Atlassian CLI (`acli`). Always prefer `acli` over any MCP-based Atlassian tools — it
uses local authentication with appropriate permissions scoped to the user's Jira access.

## Before every operation

Run these checks in order before executing any acli command. Do all three in a single Bash call to keep it fast.

```bash
which acli && acli --version && acli auth status 2>&1
```

### If acli is not installed

Tell the user and offer to install:

```bash
brew tap atlassian/homebrew-acli
brew install acli
```

### If not authenticated or token expired

Check the `acli auth status` output. If it does not show `✓ Authenticated`, or if a command fails with a 401 or
permission error, the user needs to re-authenticate.

**`acli auth login` requires interactive input** (site selection prompt) and cannot be run from Claude Code's Bash
tool. Instruct the user to do the following in their own terminal:

1. Run `acli auth login`
2. Select the `prometheum.atlassian.net` site when prompted
3. Complete the OAuth flow in the browser that opens

Wait for the user to confirm they've authenticated before proceeding. acli has no token refresh command — token renewal
always requires this full interactive login flow.

> **Note**: The message "Following apps are not authenticated with your global profile: Jira, Confluence" is
> informational and does not indicate a broken session. Commands will work as long as `✓ Authenticated` is shown.

## Key Projects

| Key   | Name            | Notes                          |
| ----- | --------------- | ------------------------------ |
| INF   | Infrastructure  | Primary project for infra work |
| PLAT  | Core Platform   | Platform engineering           |
| PROAT | ProATS          | ProATS product                 |
| PCAP  | ProCap          | ProCap product                 |
| BLOC  | Blockchain      | Blockchain team                |
| PB    | Program Backlog | Cross-team program items       |
| QA    | QA              | Quality assurance              |
| SUP   | Support         | Support tickets                |

## Commands

### View a ticket

```bash
acli jira workitem view KEY-123
acli jira workitem view KEY-123 --json
acli jira workitem view KEY-123 --fields '*all'
```

### Search tickets

```bash
acli jira workitem search --jql "project = INF AND status = 'To Do'" --limit 20
acli jira workitem search --jql "project = INF AND assignee = currentUser()" --limit 20
acli jira workitem search --jql "project = INF AND text ~ 'search term'" --limit 20
acli jira workitem search --jql "project = INF AND status not in (Done) ORDER BY created DESC" --limit 10
```

### JQL syntax notes

- **Never use `!=`** — the `!` character is treated as an escape prefix by `acli`'s JQL parser and causes
  `illegal jql escape sequence` errors. Use `not in (value)` instead: `status not in (Done)`.
- **Quote string values** — wrap multi-word status names in single quotes: `status = 'To Do'`,
  `status = 'In Progress'`.
- **Text search** — use `text ~ 'term'` for full-text search across summary and description fields.

### Create a ticket

```bash
acli jira workitem create \
  --project "INF" \
  --type "Task" \
  --summary "[PROJECT] Brief title" \
  --description-file /tmp/ticket.json
```

Supported types: Task, Bug, Story, Epic, Sub-task.

Use `--assignee "@me"` to self-assign, or an email address for others.

**Never use `--description` with plain text.** Always write the description as ADF JSON to a temp file and pass it
via `--description-file`. This ensures headings, bullet lists, and inline code render correctly in Jira.

### Edit a ticket

```bash
acli jira workitem edit --key "KEY-123" --summary "Updated title"
acli jira workitem edit --key "KEY-123" --description "Updated description"
acli jira workitem edit --key "KEY-123" --labels "label1,label2"
acli jira workitem edit --key "KEY-123" --type "Bug"
```

### Transition a ticket

```bash
acli jira workitem transition --key "KEY-123" --status "In Progress"
acli jira workitem transition --key "KEY-123" --status "Done"
acli jira workitem transition --key "KEY-123" --status "To Do"
```

**Note**: Not all transitions are allowed from every status. Service request tickets (PITM project) use a different
workflow — "Done" may not be a valid transition. Try "Resolved" instead. If a transition fails with "No allowed
transitions found", check the current status and try alternative target statuses.

### Assign a ticket

```bash
acli jira workitem assign --key "KEY-123" --assignee "@me"
acli jira workitem assign --key "KEY-123" --assignee "<user>@prometheum.com"
acli jira workitem assign --key "KEY-123" --remove-assignee
```

### Comment on a ticket

**Plain text comments:**

```bash
acli jira workitem comment create --key "KEY-123" --body "Comment text here"
```

**Formatted comments (code blocks, etc.):**

The `--body` flag treats content as plain text — wiki markup (`{code}`) and markdown (triple backticks) are **not**
rendered. For formatted comments, use Atlassian Document Format (ADF) via `--body-file`:

```bash
# Write ADF JSON to a temp file, then pass it
acli jira workitem comment create --key "KEY-123" --body-file /tmp/comment.json
```

ADF code block example:

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "codeBlock",
      "attrs": { "language": "json" },
      "content": [
        { "type": "text", "text": "your code here" }
      ]
    }
  ]
}
```

Write the ADF JSON to a temp file, then pass it:

```bash
acli jira workitem comment create --key "KEY-123" --body-file /tmp/comment.json
```

### Link tickets

```bash
acli jira workitem link create --out KEY-123 --in KEY-456 --type "Blocks"
```

## Output handling

Default output is a formatted table. Use these flags to control output:

| Flag        | Available on    | Use when                                          |
| ----------- | --------------- | ------------------------------------------------- |
| `--json`    | `view`, `search`| Parsing output programmatically with `jq`         |
| `--csv`     | `search`        | Clean tabular export, good for sharing or piping  |
| `--count`   | `search`        | Just need the total number of matching tickets    |
| `--fields`  | `view`, `search`| Limit which fields are returned                   |

```bash
# CSV export of open tickets
acli jira workitem search --jql "project = INF AND status not in (Done)" --csv

# Count without fetching details
acli jira workitem search --jql "project = INF AND status = 'To Do'" --count

# Only return specific fields
acli jira workitem view INF-123 --fields "key,status,assignee"
```

## Labels

When creating or editing tickets, suggest appropriate labels from this list. All labels should be lowercase or
kebab-case. Avoid creating new variants of labels that already exist.

| Label       | Use for                                      |
| ----------- | -------------------------------------------- |
| `ai`        | AI tooling, models, automation               |
| `boats`     | BOATs product specific                       |
| `ci`        | CI/CD pipelines, GitHub Actions              |
| `external`  | External-facing or cross-team requests       |
| `proats`    | ProATS specific                              |
| `procap`    | ProCap specific                              |
| `security`  | Security patches, credential rotation, CVEs  |
| `tech-debt` | Technical debt, refactoring, cleanup         |
| `unplanned` | Ad-hoc work not part of a sprint or PI       |

## Ticket Conventions

### Summary naming

Always prefix the summary with the project key in brackets: `[BLOC] Fix withdrawal batch validation`. This applies to
all tickets regardless of project.

### Description structure

Every ticket description must use these three sections in order, as ADF level-2 headings:

1. **Context** — Why this ticket exists. Background, the problem, relevant history, or the trigger (e.g. a compiler
   bug, a deprecation notice, a compliance requirement). No implementation detail here.
2. **Technical Context** — What needs to be done. Specific files, functions, patterns, flags, or steps involved.
   Use inline code formatting (`code`) for all identifiers, flags, and values. Bullet list format.
3. **AC** — Acceptance criteria. Concrete, verifiable conditions that define done. Bullet list format.

Write descriptions with enough detail that someone unfamiliar with the immediate context can pick up the ticket and
understand what to do and why. Use inline code for all symbol names, config keys, file names, and values.

### ADF requirement

**Always write descriptions as ADF JSON**, never plain text. The `--description` flag renders as raw markdown in
Jira. Workflow:

1. Write the ADF JSON to `/tmp/<key>-desc.json`
2. Pass it with `--description-file /tmp/<key>-desc.json` on create or edit

ADF description template:

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "heading",
      "attrs": { "level": 2 },
      "content": [{ "type": "text", "text": "Context" }]
    },
    { "type": "paragraph", "content": [{ "type": "text", "text": "..." }] },
    {
      "type": "heading",
      "attrs": { "level": 2 },
      "content": [{ "type": "text", "text": "Technical Context" }]
    },
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "..." }] }]
        }
      ]
    },
    {
      "type": "heading",
      "attrs": { "level": 2 },
      "content": [{ "type": "text", "text": "AC" }]
    },
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "..." }] }]
        }
      ]
    }
  ]
}
```

For inline code within ADF text nodes, use the `code` mark:

```json
{ "type": "text", "text": "someIdentifier", "marks": [{ "type": "code" }] }
```

## Workflow Guidelines

### Creating a ticket

Follow this flow — never skip the confirmation step:

1. **Gather details** — Ask the user questions to fill in any missing fields (summary, description, type, assignee,
   labels, business unit, etc.)
   - **Business unit** — Ask whether the ticket pertains to **ProATS**, **ProCap**, or neither. If applicable,
     include it as context in the summary or description and add the corresponding label (`proats` or `procap`).
2. **Present a summary** — Show the ticket in a clean table for review, including the full prose description:

   ```markdown
   | Field       | Value                                      |
   | ----------- | ------------------------------------------ |
   | Project     | BLOC                                       |
   | Type        | Task                                       |
   | Summary     | [BLOC] Brief title here                    |
   | Status      | Backlog                                    |
   | Assignee    | Unassigned                                 |
   | Labels      | —                                          |

   **Context**
   ...

   **Technical Context**
   - ...

   **AC**
   - ...
   ```

3. **Get explicit confirmation** — Do NOT run the create command until the user confirms. Ask "Does this look good?"
4. **Write the ADF file** — Construct the full ADF JSON and write to `/tmp/<key>-desc.json`.
5. **Create the ticket** — Run `acli jira workitem create` with `--description-file`.
6. **Show the result** — Display the created ticket key and a link.

## Best practices

- **Search before creating** — check for duplicates first
- **Always confirm** ticket details with the user before running create/edit/transition commands
- **Default project is INF** unless the user specifies otherwise
- **Default status is Backlog** — new tickets go to the backlog unless the user says otherwise
- **Descriptions always use ADF** — never `--description` with plain text; always `--description-file` with ADF JSON
- **Assignee** — ask whether to assign. Options: self (`@me`), another user (by email), or unassigned (omit the flag)
- Use `--count` to get totals instead of fetching all tickets and counting locally
- Use `--csv` or `--json` when you need to parse output programmatically
- If a request returns a 401, instruct the user to re-authenticate with `acli auth login` in their terminal
- If a JQL query fails, check for `!=` (use `not in` instead) and unquoted multi-word values

## Arguments

If `$ARGUMENTS` specifies an action (create, view, search, etc.), proceed with that action. If only a ticket key is
given (e.g., `INF-3097`), default to viewing the ticket. Otherwise, ask what the user needs.
