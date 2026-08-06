---
name: datadog
version: 1.0.0
description: >-
  Query Datadog logs, monitors, and observability data via pup CLI. Trigger on log queries,
  error rates, monitor status, or production investigations, even if Datadog isn't named.
argument-hint: '[logs|monitors] [query or service name]'
---

# Datadog via pup CLI

pup is Datadog's official CLI (datadog-labs). OAuth2+PKCE, tokens in macOS Keychain. Consult
`pup --help` and `pup <group> --help` for the interface.

Install, if missing: `brew tap datadog-labs/pack && brew install datadog-labs/pack/pup`.

Auth: `pup auth login` opens a browser and must be completed interactively; wait for the user to
confirm. `pup auth refresh` if the token is valid but expiring. A 401 means re-login; a 403 means the
token is missing scopes, which also needs a re-login.

## Picking a log command

This is the non-obvious part of the interface:

| Command              | Use when                                                                         |
| -------------------- | -------------------------------------------------------------------------------- |
| `pup logs search`    | Fetching individual log lines to read (v1 API, up to 1000 results)               |
| `pup logs query`     | Same but v2 API, default 50 results                                              |
| `pup logs aggregate` | Counting, grouping, or computing stats. Never fetch all logs just to count them  |

`--from` takes relative (`15m`, `1h`, `4h`, `1d`, `7d`) or absolute RFC3339. `--storage` is one of
`indexes`, `online-archives`, `flex`. If the user gave no time range, default to `1h`, say so, and
widen on request.

## Query syntax

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

## Known values for this infrastructure

- services: `boats-api`, `trading-backend`
- clusters (`cluster_name:`): `procap-prod-prod`
- envs: `prod`

## Practices

Filter by service first. Prefer `--tags` and `--name` server-side over listing everything and
parsing locally. Output is JSON by default; `--output table` for humans.
