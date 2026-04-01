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

Read-only PostgreSQL access across all Prometheum environments. Credentials are stored in
`~/.pgpass` — no password flags needed.

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
A `psql-guard` hook will block any DML that slips through.

```bash
# Non-localhost (read-only enforced at session level)
PGOPTIONS="-c default_transaction_read_only=on" \
  psql -h <host> -U <user> -d <database> -c "<SQL>"

# Localhost (read-only by default; writes allowed only when user explicitly requests)
psql -h localhost -U prometheum -d postgres -c "<SQL>"
```

### Example

```bash
# Check a wallet balance in prod
PGOPTIONS="-c default_transaction_read_only=on" \
  psql -h procap-boats-backend-prod.cpdze5cocd6u.us-east-1.rds.amazonaws.com \
       -U tjohnson -d boats \
       -c "SELECT address, balance FROM wallets WHERE address = '0xABC...' LIMIT 1"
```

## Output formatting

Prefer `-c` for inline queries. For wide result sets pipe through `column` or use `--csv`:

```bash
PGOPTIONS="-c default_transaction_read_only=on" \
  psql -h <host> -U <user> -d <database> --csv -c "<SQL>" | column -t -s ','
```

## VPN requirement

UAT and prod connections require AWS VPN (split tunnel) to be active. If a connection
times out or is refused on a non-local host, remind the user to check VPN before
assuming a query error.

## Write operations

Writes are blocked by the `psql-guard` hook. If the user has **explicitly** requested a
write (e.g. a one-off fix on localhost), prefix the command with `ALLOW_DB_WRITES=1`:

```bash
ALLOW_DB_WRITES=1 psql -h localhost -U prometheum -d postgres -c "UPDATE ..."
```

Never use `ALLOW_DB_WRITES=1` on remote (QA/UAT/prod) connections.
