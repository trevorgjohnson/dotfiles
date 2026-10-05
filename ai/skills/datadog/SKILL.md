---
name: datadog
version: 1.0.0
description: Query Datadog logs, monitors, and observability with pup. Use for log queries, error rates, monitor status, or production investigations.
argument-hint: '[logs|monitors] [query or service]'
---

Use `pup` and consult the relevant command's `--help`.
Authentication uses OAuth and macOS Keychain.
`pup auth login` requires the user to complete a browser flow.
Use `pup auth refresh` for a valid expiring token.
401 or missing scopes (403) require login again.
Use `logs search` for individual logs (v1, up to 1000), `logs query` for v2 (default 50), and `logs aggregate` for counts or grouping.
Filter by the relevant service or namespace and environment.
Default to `1h` when no time window is specified by the user or invoking workflow, state the assumption, and widen on request.
`--from` accepts relative durations or RFC3339.
`--storage` accepts `indexes`, `online-archives`, or `flex`.
Known values include services `boats-api` and `trading-backend`, cluster `cluster_name:procap-prod-prod`, and environment `env:prod`.
Prefer server-side filters such as `--tags` and `--name`.
Output defaults to JSON.
Use `--output table` for human-readable results.
