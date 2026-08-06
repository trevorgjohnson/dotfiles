---
name: db-query
description: >-
  Execute read-only PostgreSQL queries across local, QA, UAT, and prod environments for
  the Prometheum platform. Knows all connection strings and enforces read-only mode on
  all non-localhost connections. Use when investigating data issues, verifying DB state,
  or querying boats/platform databases as part of an investigation.
argument-hint: '<env> <service> "<SQL query>"'
---

# DB Query

Read-only PostgreSQL access across all Prometheum environments. Credentials live in `~/.pgpass`, so
no password flags are needed.

## Connection map

| Key              | Host                                                                   | Port | Database | User               | VPN? |
|------------------|------------------------------------------------------------------------|------|----------|--------------------|------|
| `local`          | localhost                                                              | 5432 | postgres | prometheum         | No   |
| `qa-boats`       | procap-boats-backend-qa.cxxajlz1qd40.us-east-1.rds.amazonaws.com      | 5432 | boats    | boats-230607       | Yes  |
| `qa-platform`    | procap-platform-backend-qa.cxxajlz1qd40.us-east-1.rds.amazonaws.com   | 5432 | platform | peatsuser-230313   | Yes  |
| `qa-procap`      | procap-platform-backend-qa.cxxajlz1qd40.us-east-1.rds.amazonaws.com   | 5432 | procap   | peatsuser-230313   | Yes  |
| `uat-boats`      | procap-boats-backend-uat.cxzsy0zgpzqg.us-east-1.rds.amazonaws.com     | 5432 | boats    | boatsuser          | Yes  |
| `uat-procap`     | procap-platform-backend-uat.cxzsy0zgpzqg.us-east-1.rds.amazonaws.com  | 5432 | procap   | peatsuser-230314   | Yes  |
| `prod-boats`     | procap-boats-backend-prod.cpdze5cocd6u.us-east-1.rds.amazonaws.com    | 5432 | boats    | tjohnson           | Yes  |
| `prod-procap`    | procap-platform-backend-prod.cluster-ro-cpdze5cocd6u.us-east-1.rds.amazonaws.com | 5432 | procap | tjohnson  | Yes  |

## Running a query

Non-localhost connections **must** include `PGOPTIONS="-c default_transaction_read_only=on"`.
A `psql-guard` hook blocks any DML that slips through.

```bash
# Non-localhost (read-only enforced at session level)
PGOPTIONS="-c default_transaction_read_only=on" \
  psql -h <host> -U <user> -d <database> -c "<SQL>"

# Localhost (read-only by default; writes only when the user explicitly asks)
psql -h localhost -U prometheum -d postgres -c "<SQL>"
```

## VPN

UAT and prod need AWS VPN (split tunnel) active. A timeout or refused connection on a non-local host
usually means VPN is off, not that the query is wrong.
