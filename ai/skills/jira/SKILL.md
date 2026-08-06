---
name: jira
version: 1.0.0
description: >-
  Create, view, search, edit, transition, and manage Jira tickets via the Atlassian CLI (acli).
argument-hint: '[create|view|search|edit|transition|comment|assign|link] [details]'
---

# Jira Ticket Management

Use `acli` for all Jira work. Consult `acli jira workitem --help` for the interface.

**Never use the `mcp__claude_ai_Atlassian__*` tools.** `acli` uses local auth scoped to the user's
Jira access and is the established workflow.

## Auth

`acli auth login` is interactive (site selection prompt) and cannot run from the Bash tool. If auth
status is not `✓ Authenticated`, or a command returns 401, tell the user to run it in their own
terminal and select `prometheum.atlassian.net`. There is no refresh command, so token renewal always
means the full interactive flow. Wait for them to confirm before continuing.

The message "Following apps are not authenticated with your global profile: Jira, Confluence" is
informational, not a broken session.

Install, if missing: `brew tap atlassian/homebrew-acli && brew install acli`.

## Key projects

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

Default to INF unless the user says otherwise. New tickets default to Backlog.

## Labels

Suggest from this list rather than inventing variants. All lowercase or kebab-case.

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

## Gotchas

**JQL: never use `!=`.** `acli`'s JQL parser treats `!` as an escape prefix and errors with
`illegal jql escape sequence`. Use `not in (value)`. Quote multi-word values (`status = 'To Do'`).
Full-text search is `text ~ 'term'`.

**Descriptions must be ADF JSON, never plain text.** `--description` renders as raw markdown in Jira.
Write ADF to `/tmp/<key>-desc.json` and pass `--description-file`. Same for comments: `--body` is
plain text and ignores both wiki markup and backticks, so formatted comments need `--body-file`.
For inline code inside an ADF text node, use the `code` mark.

**`acli jira workitem edit` cannot set parent (epic) or sprint.** It exposes only `--summary`,
`--description[-file]`, `--type`, `--labels`, `--remove-labels`, `--assignee`, `--from-json`,
`--generate-json`. Do not fight it: create or edit the ticket, then tell the user the parent and
sprint values to set manually.

**Transitions are workflow-dependent.** Not every status is reachable from every other. Service
request tickets (PITM) use a different workflow where `Done` may be invalid; try `Resolved`. On
"No allowed transitions found", check current status and try alternatives.

## Ticket conventions

### Summary

Always prefix with the project key in brackets. Title style is a short imperative verb phrase saying
what the ticket does, not what the problem is. No colons, dashes, subtitles, or enumerated lists of
multiple things. Keep it scannable.

- Good: `[BLOC] Fix withdrawal batch validation`
- Bad: `[PCAP] DB Write Correctness - DirectDeposit Atomicity and Find-or-Create Race Condition`

### Description

Three sections in order, as ADF level-2 headings:

1. **Context**: why this ticket exists. Background, the problem, the trigger (a compiler bug, a
   deprecation, a compliance requirement). No implementation detail.
2. **Technical Context**: what needs doing. Specific files, functions, patterns, flags, steps.
   Bullet list.
3. **AC**: acceptance criteria. Concrete, verifiable conditions defining done. Bullet list.

Write so someone without the immediate context can pick it up. Wrap every identifier, flag, file
name, and config key in backticks, in both bullet prose and ADF `code` marks. No em dashes. When
quoting what a method logs or throws, match the boats-backend phrasing rather than inventing a
format.

## Creating a ticket

1. Gather fields with `AskUserQuestion` (type, project, assignee, business unit), then collect
   summary, description, and labels.
2. Search first, to catch duplicates.
3. Present the full ticket for review, description prose included.
4. **Get explicit confirmation. Never run create until the user confirms.**
5. Write the ADF file, run create with `--description-file`, then show the key and link.

Creating a batch (e.g. from a PRD breakdown): `TaskCreate` per ticket up front, mark each completed
as it lands, so the user sees live progress.

## Output

`--json` (view, search) for `jq` parsing, `--csv` (search) for export, `--count` (search) for totals
instead of fetching and counting locally, `--fields` to limit what comes back.

## Arguments

If `$ARGUMENTS` names an action, do that. If it is only a ticket key (`INF-3097`), view the ticket.
Otherwise ask.
