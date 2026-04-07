---
name: datadog
version: 1.0.0
description: >-
  Query Datadog logs, monitors, and observability data via pup CLI. Trigger on log queries,
  error rates, monitor status, or production investigations — even if Datadog isn't named.
argument-hint: '[logs|monitors] [query or service name]'
---

# Datadog via pup CLI

pup is Datadog's official CLI (from datadog-labs). It provides full access to the Datadog API including logs, monitors,
metrics, and more. It authenticates via OAuth2+PKCE and stores tokens in macOS Keychain.

## Before every operation

Run these checks in order before executing any pup command. Do all three in a single Bash call to keep it fast.

```bash
which pup && pup --version && pup auth status 2>&1
```

### If pup is not installed

Tell the user and offer to install:

```bash
brew tap datadog-labs/pack && brew install datadog-labs/pack/pup
```

### If not authenticated or token expired

Check the `status` field in the auth output. If it's not `valid`, or `authenticated` is `false`, run:

```bash
pup auth login
```

This opens a browser for OAuth2 login. The user must complete the flow interactively. Wait for them to confirm before
proceeding. If the token is valid but expiring soon (< 5 minutes), proactively refresh:

```bash
pup auth refresh
```

## Time Range

Before running any log query, check if the user specified a time range. If they didn't, use `AskUserQuestion`:

```
How far back should I search?
1. 15m — last 15 minutes
2. 1h — last hour (default)
3. 4h — last 4 hours
4. 1d — last day
```

Use the selected value as the `--from` flag. If the user already specified a range in their request, skip the question and use it directly.

## Logs

pup has several log commands. Choose based on what the user needs:

| Command              | Use when                                                                         |
| -------------------- | -------------------------------------------------------------------------------- |
| `pup logs search`    | Fetching individual log lines to read (v1 API, up to 1000 results)               |
| `pup logs query`     | Same but v2 API, default 50 results                                              |
| `pup logs aggregate` | Counting, grouping, or computing stats — never fetch all logs just to count them |

### Searching logs

```bash
pup logs search --query '<query>' --from '<time>' --limit <n>
```

Flags:

- `--query` (required): Datadog log query syntax
- `--from`: Start time — relative (`15m`, `1h`, `4h`, `1d`, `7d`) or absolute (RFC3339). Default: `1h`
- `--to`: End time. Default: `now`
- `--limit`: Max results, 1-1000. Default: `50`
- `--sort`: `asc` or `desc` (default: `desc`, newest first)
- `--index`: Comma-separated index names
- `--storage`: `indexes`, `online-archives`, or `flex`

### Query syntax

```text
service:boats-api                             # by service
env:prod                                      # by environment
status:error                                  # by log level
host:ip-10-*                                  # wildcard match
@http.status_code:>=500                       # attribute filter
service:boats-api env:prod status:error       # AND (space-separated)
service:boats-api OR service:trading-backend  # OR
-status:info                                  # NOT (exclude)
"exact phrase match"                          # exact match
```

### Aggregating logs

Use aggregation instead of fetching raw logs when the user wants counts or distributions:

```bash
# Count errors by service in the last hour
pup logs aggregate --query 'status:error' --from '1h' --compute count --group-by service

# Count logs per environment
pup logs aggregate --query '*' --from '4h' --compute count --group-by env
```

Flags:

- `--compute`: `count` (default), or a metric expression
- `--group-by`: Field to group results by
- `--limit`: Max groups (default: 10)

### Common log queries for this infrastructure

```bash
# Errors across all prod services
pup logs search --query 'env:prod status:error' --from '1h' --limit 50

# Specific service logs
pup logs search --query 'service:boats-api env:prod' --from '15m'

# Specific cluster
pup logs search --query 'cluster_name:procap-prod-prod status:error' --from '1h'

# Trading backend warnings and errors
pup logs search --query 'service:trading-backend status:(warn OR error)' --from '30m'
```

## Monitors

### List monitors

```bash
# List all monitors (up to 200)
pup monitors list

# Filter by name substring
pup monitors list --name 'boats'

# Filter by tags
pup monitors list --tags 'env:prod,team:backend'

# Increase limit
pup monitors list --limit 500
```

### Search monitors (full-text)

```bash
pup monitors search --query '<search term>'
pup monitors search --query 'boats-api' --per-page 50
```

### Get monitor details

```bash
pup monitors get <monitor-id>
```

## Output handling

pup outputs JSON by default. Use `jq` to extract specific fields when the output is large:

```bash
# Just log messages
pup logs search --query 'status:error' --from '1h' | jq '.data[].attributes.message'

# Monitor names and status
pup monitors list | jq '.data[] | {name: .name, status: .overall_state}'
```

For human-readable table output:

```bash
pup logs search --query 'status:error' --from '1h' --output table
```

## Best practices

- Start with narrow time ranges (`15m`, `1h`) and widen only if needed — large ranges are slow
- Use `pup logs aggregate` for counts instead of fetching all logs and counting locally
- Filter by service first when investigating issues
- For monitors, use `--tags` to filter rather than listing all and parsing locally
- If a request returns a 401, re-authenticate with `pup auth login`
- If a request returns a 403, the OAuth token may be missing required scopes — re-login
