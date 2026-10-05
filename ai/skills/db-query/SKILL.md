---
name: db-query
description: Query Prometheum PostgreSQL databases to investigate data or verify state. Enforce read-only access on non-localhost connections.
argument-hint: '<env> <service> "<SQL query>"'
---

Use `psql` with credentials from `~/.pgpass`, without password flags.
Non-localhost connections require VPN and `PGOPTIONS="-c default_transaction_read_only=on"`.
The `psql-guard` hook also blocks remote DML.
Local queries are read-only unless the user explicitly requests writes.
For remote timeouts or refused connections, check VPN before changing the query.

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

```bash
PGOPTIONS="-c default_transaction_read_only=on" \
  psql -h <host> -U <user> -d <database> -c "<SQL>"
```
