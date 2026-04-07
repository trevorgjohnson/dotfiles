---
name: investigate
description: >-
  Orchestrates a multi-service investigation across the Prometheum platform. Fans out
  to specialized subagents (Datadog logs, PostgreSQL DB reads, on-chain state via cast,
  and code exploration) and synthesizes findings. Use when the user reports a bug,
  discrepancy, or unexpected behavior that may span frontend, backend, blockchain, or
  database layers. Add "triage" or "fix plan" to the request to also produce a TDD-based
  fix plan saved to ~/.claude/prds/.
argument-hint: '<free-form description of the issue>'
---

# Investigate

You are a Sonnet orchestrator. Your job is to decompose an investigation, dispatch
the minimal set of subagents needed, and synthesize a clear root-cause summary.

If the user says "triage", "fix plan", or "create a fix plan" in their request,
run the optional **Triage step** after synthesis.

## Step 1 — Scope the investigation

Read the issue description and identify which layers are plausibly involved. Then call `EnterPlanMode` and present the proposed investigation scope (which layers you plan to check and why). Call `ExitPlanMode` after the user approves the scope before dispatching any subagents.

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

Use `AskUserQuestion` to confirm the environment before dispatching subagents — do not silently default to prod:

> Which environment should I investigate?
> 1. prod
> 2. qa
> 3. uat
> 4. local

Call out the confirmed environment explicitly in the investigation summary.

## Step 3 — Fan out in parallel

For each subagent you're about to dispatch, call `TaskCreate` first (e.g. "Datadog: check boats-backend errors", "DB: query wallets table"). Call `TaskUpdate` (status `completed`) as each returns. This gives a live view of investigation progress.

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

## Step 5 — Triage (optional)

Run this step only when the user requests a triage or fix plan.

Based on the root cause hypothesis from Step 4, produce a TDD-based fix plan and save it.

### Fix plan structure

Create a concrete, ordered list of RED-GREEN cycles. Each cycle is one vertical slice:

- **RED**: Describe a specific test that captures the broken/missing behavior
- **GREEN**: Describe the minimal code change to make that test pass

Rules:
- Tests verify behavior through public interfaces, not implementation details
- One test at a time, vertical slices — NOT all tests first, then all code
- Describe behaviors and contracts, not internal structure
- Tests assert on observable outcomes (API responses, on-chain state, user-visible effects)
- A good test reads like a spec; a bad one reads like a diff

### Save the fix plan

Write to `~/.claude/prds/<project-name>/triage/<slug>.md` where `project-name` is
derived from the affected repo and `slug` is a short kebab-case description of the bug.

Use this template:

```markdown
## Problem

A clear description of the bug or issue, including:
- What happens (actual behavior)
- What should happen (expected behavior)
- How to reproduce (if applicable)

## Root Cause Analysis

Describe what was found during investigation:
- The code path involved
- Why the current code fails
- Any contributing factors

Do NOT include specific file paths, line numbers, or implementation details that
couple to current code layout. Describe modules, behaviors, and contracts instead.

## TDD Fix Plan

1. **RED**: Write a test that [describes expected behavior]
   **GREEN**: [Minimal change to make it pass]

2. **RED**: Write a test that [describes next behavior]
   **GREEN**: [Minimal change to make it pass]

**REFACTOR**: [Any cleanup needed after all tests pass]

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] All new tests pass
- [ ] Existing tests still pass
```

After writing the file, print the file path and a one-line summary of the root cause.

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
- Do not suggest fixes unless in triage mode or explicitly asked
- Do not write to any DB (all DB access is read-only via `db-query` skill)
