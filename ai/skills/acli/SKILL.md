---
name: acli
description: Manage Jira work items and Confluence content with the Atlassian CLI. Use for Jira or Confluence requests.
---

Use `acli` for Jira and Confluence, never `mcp__claude_ai_Atlassian__*` tools.
Inspect the relevant command's `--help` for unfamiliar operations; do not assume Confluence operations exist.
A bare Jira key means view the ticket.
If `acli` is missing, request approval before installing it.

## Auth

If auth status is not `✓ Authenticated` or a command returns 401, ask the user to run `acli auth login` in their terminal and select `prometheum.atlassian.net`.
Login requires interactive site selection; there is no refresh command.
Wait for confirmation before continuing.
“Following apps are not authenticated with your global profile: Jira, Confluence” is informational.

## Local defaults

Default to INF and Backlog for new tickets unless the user specifies otherwise.

| Project | Name |
| --- | --- |
| INF | Infrastructure |
| PLAT | Core Platform |
| PROAT | ProATS |
| PCAP | ProCap |
| BLOC | Blockchain |
| PB | Program Backlog |
| QA | QA |
| SUP | Support |

Suggest existing lowercase or kebab-case labels instead of inventing variants.

| Label | Use |
| --- | --- |
| `ai` | AI tooling, models, automation |
| `boats` | BOATs product |
| `ci` | CI/CD, GitHub Actions |
| `external` | External-facing or cross-team work |
| `proats` | ProATS |
| `procap` | ProCap |
| `security` | Patches, credentials, CVEs |
| `tech-debt` | Refactoring, cleanup |
| `unplanned` | Work outside a sprint or PI |

## CLI gotchas

JQL `!=` fails with `illegal jql escape sequence`; use `not in (value)`.
Quote multi-word values, such as `status = 'To Do'`; full-text search is `text ~ 'term'`.
Descriptions must be ADF JSON passed with `--description-file`; `--description` renders raw Markdown.
Formatted comments need ADF via `--body-file`; `--body` ignores wiki markup and backticks.
Inline code in ADF text uses the `code` mark.
`jira workitem edit` cannot set parent or sprint; tell the user which values to set manually.
Transitions depend on the workflow; on “No allowed transitions found”, inspect the current status and valid alternatives.
PITM service requests may require `Resolved` instead of `Done`.
For `A blocks B`, run `acli jira workitem link create --out B --in A --type Blocks`.
Ignore the misleading success-text order and verify B with `workitem view --fields issuelinks --json`: `inwardIssue.key` must be A.
Use `--json` for structured reads, `--fields` to limit results, `--count` for totals, and `--csv` for exports where supported.

## Drafting and mutations

Read [TICKET_PRACTICE.md](TICKET_PRACTICE.md) before drafting tickets and [EPIC_PLANNING.md](EPIC_PLANNING.md) when breaking an epic into tickets.
Gather missing ticket fields, including type, project, assignee, business unit, summary, description, and labels.
Search for duplicates before creating tickets.
Present complete ticket text for explicit approval before creating or updating Jira items.
Confirm before creating, updating, archiving, restoring, or deleting Confluence content or spaces.
After approved creation, return the key and link.
