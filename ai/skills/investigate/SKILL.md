---
name: investigate
description: >-
  Orchestrates a multi-service investigation across the Prometheum platform. Fans out
  to specialized subagents (Datadog logs, PostgreSQL DB reads, on-chain state via cast,
  and code exploration) and synthesizes findings. Use when the user reports a bug,
  discrepancy, or unexpected behavior that may span frontend, backend, blockchain, or
  database layers.
argument-hint: '<free-form description of the issue>'
---

# Investigate

You are a Sonnet orchestrator. Your job is to decompose an investigation, dispatch
the minimal set of subagents needed, and synthesize a clear root-cause summary.

## Step 1 — Scope the investigation

Read the issue description and identify which layers are plausibly involved:

| Layer       | Repo                    | Datadog namespace                  | DB keys                          |
|-------------|-------------------------|------------------------------------|----------------------------------|
| Frontend    | `../platform-frontend`  | `kube_namespace:procap-platform-frontend` | —                           |
| Platform BE | `../platform-backend`   | `kube_namespace:procap-platform-backend`  | `{env}-platform`, `{env}-procap` |
| Boats BE    | `../boats-backend`      | `kube_namespace:procap-boats-backend`     | `{env}-boats`                    |
| Chain       | `../cows` (contracts)   | —                                  | —                                |

Data flows:
- **FE → Platform BE**: GraphQL
- **Platform BE → Boats BE**: BullQueue jobs
- **Boats BE → Chain**: Ethereum RPC calls (via `cows` contracts)

Only pull in layers that are plausibly relevant. Start narrow; expand if findings are
inconclusive.

## Step 2 — Determine environment

Default to **prod** unless the issue description specifies otherwise. Call out the
environment explicitly before dispatching subagents.

## Step 3 — Fan out in parallel

Dispatch subagents concurrently using the Agent tool. Use the **smallest model that
can do the job**:

### Datadog (Haiku)
Use the `datadog` skill. Always filter by `kube_namespace` for the relevant service.
Start with a 1-hour window and widen only if needed.

```
Use the datadog skill to search for errors in kube_namespace:procap-boats-backend
env:prod in the last 1h related to [specific symptom].
```

### DB read (Haiku)
Use the `db-query` skill. Be specific — query the table most likely to reflect the
symptom. Do not do exploratory schema discovery unless the query comes back empty.

```
Use the db-query skill to query prod-boats:
SELECT address, balance, updated_at FROM wallets WHERE address = '0x...' LIMIT 1
```

### Chain state (Haiku)
Use the `foundry-cast` skill only when on-chain state is directly relevant (e.g.
balance discrepancies, contract interactions, transaction status).

```
Use the foundry-cast skill to check the on-chain ETH balance for address 0x...
```

### Code exploration (Haiku)
Use the Explore agent on the specific repo. Give it a targeted question — file and
function level if possible.

```
Explore ../boats-backend: how does the wallet balance sync job work? Find the
BullQueue processor that updates the wallets table.
```

## Step 4 — Synthesize

Once all subagents return, produce a structured summary:

```
## Investigation: <one-line description>
**Environment:** prod | qa | uat | local
**Layers checked:** [list]

### Findings
- **Datadog**: <what was found or "no relevant errors">
- **DB**: <what the data shows>
- **Chain**: <on-chain state, if checked>
- **Code**: <relevant logic found>

### Root cause hypothesis
<1-3 sentences>

### Recommended next steps
- [ ] ...
```

## Model selection for subagents

| Task                              | Model  |
|-----------------------------------|--------|
| Datadog log search                | Haiku  |
| DB read (single targeted query)   | Haiku  |
| Cast / chain state check          | Haiku  |
| Code exploration (narrow)         | Haiku  |
| Code exploration (multi-file)     | Sonnet |
| Architecture reasoning / complex  | Opus   |

## What NOT to do

- Do not fan out to all four repos by default — only what the issue implicates
- Do not widen time ranges or run extra queries unless initial results are empty
- Do not suggest fixes — that is outside investigation scope unless explicitly asked
- Do not write to any DB (all DB access is read-only via `db-query` skill)
