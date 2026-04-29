---
name: triage
description: >-
  Orchestrates a multi-service triage process across the Prometheum platform by exploring each domain  
  using (but not limited to) Datadog logs, PostgreSQL DB reads, on-chain state via cast, and code exploration
  Use when the user reports a discrepancy/unexpected behavior that may span across the platform.
argument-hint: '<free-form description of the issue>'
---

# Triage

You are a Sonnet orchestrator. Your job is to keep your context window lightweight for conversation with the user while delegating exploration to the specialized subagents.

## Step 1 — Scope the investigation

Read the issue description and identify which layers are plausibly involved.

| Layer       | Repo                    | Datadog namespace                  | DB keys                          |
|-------------|-------------------------|------------------------------------|----------------------------------|
| Frontend    | `../platform-frontend`  | `kube_namespace:procap-platform-frontend` | —                           |
| Platform BE | `../platform-backend`   | `kube_namespace:procap-platform-backend`  | `{env}-platform`, `{env}-procap` |
| Boats BE    | `../boats-backend`      | `kube_namespace:procap-boats-backend`     | `{env}-boats`                    |
| Chain       | `../cows` (contracts)   | —                                  | —                                |

Data flows:
- **FE → Platform BE**: GraphQL
- **Platform BE → Boats BE**: BullQueue jobs
- **Boats BE → Chain**: Ethereum RPC calls

Only pull in layers that are plausibly relevant. Start narrow; expand if necessary.

If the issue/bug appears too broad, ask the user to clarify and to narrow the problem and affected areas.

If not previously specified, confirm the environment with the user before dispatching subagents — do not make assumptions:
We have the prod, qa, uat, development, and local environments.

If you exploration is able to narrow the necessary investigatory steps by the subagents (eg. what datadog log to look for, what event to look for emitted by a specific address on-chain, what column of which table in what database), make sure note that down and to communicate that to the appropriate subagent .
If unable to find reliable localized investigation areas outside of the codebase, feel free to interview the user for more details.

**IMPORTANT**: Before moving forward, confirm _what_ the bug is (in your own words) and your investigation plan _(including what each subagent will be specifically doing)_.

Also generate **3–5 ranked hypotheses** (most → least likely) before dispatching. Each must be falsifiable:
> "If <X> is the cause, then <finding Y> in logs/DB/chain will confirm it."

Share these with the user alongside the plan — they may have domain knowledge that re-ranks them or have already ruled some out. Don't block on a reply; proceed with your ranking if no response. Once there's consensus, move on.

## Step 2 — Fan out in parallel

For each subagent you dispatch, remember to use the **smallest model that can do the job**
Feel free to dispatch many or as few of the following subagents as necessary.

### Datadog
Use the `datadog` skill. Always filter by `kube_namespace` for the relevant service.
Default to a 15-minute window if not otherwise specified and widen only if needed.

### DB read
Use the `db-query` skill. Be specific — query the table most likely to reflect the
symptom. Do not do exploratory schema discovery unless the query comes back empty.

### Chain state
Use the `foundry-cast` skill only when on-chain state is directly relevant (e.g.
balance discrepancies, contract interactions, transaction status).

### Code exploration 
Use the Explore agent on the specific repo. Give it a targeted question.
Include the file and function level if possible.

## Step 3 — Report findings

Once all subagents return, produce a summary of the findings by the subagents.
Structure the report around your Step 1 hypotheses — which were confirmed, which were refuted, and which remain open.
DO NOT propose any fixes yet, keep the output of this step as a final report on the issue.
After reporting, suggest moving forward with step 4.

## Step 4 — Create Remediation Plan (optional)

Using the findings outputted in Step 3, spin up a smart reasoning subagent (eg. Opus on Claude) to create a remediation plan.
Give this subagent only as much context from Step 3 as necessary.

Also create separate worktree(s) for this subagent in affected domain (as described by the findings).
The subagent should use its worktree(s) to verify that its drafted plan is plausible and accurate. 

Make sure to give this subagent access to use recursive **MINIMAL** subagents to create an accurate and thorough plan complete with code examples, benefits, and tradeoffs.
Note that if nested subagents are not plausible, feel free to use `Bash(<agent cli in prompt mode (eg. -p )> "investigate thing X")` to accomplish a similar feat.

This subagent should return back with the following:

- What steps were taken by the subagent to reach the conclusion
- Multiple (or only 1 if confident) code-level remedition choices along with benefits/tradeoffs for each
    - Should include what verification was also done for each choice
- What test cases will need to be covered for further verification and complete coverage of the issue

**IMPORTANT**: make sure to have this subagent use the `caveman` skill to reduce costs and output tokens.

Present this subagent's final response for a quick QA before asking to formalize it into a finalized remediation plan which needs to include the following:

- Explicit regression check: run the existing test suite for each affected service and confirm no new failures                        
- Explicit out-of-scope section so the agent doesn't wander
- Include numbered, ordered steps with explicit prerequisites noted inline                                                                    
    - If necessary, include exact file paths and function names anchored to each step
- The finalized code-level remediation approach (if multiple were presented by the subagent, narrow down to only one with the user)
    - **IMPORTANT**: the eventual remediation MUST heavily implement TDD for a quick feedback loop
- Dense and thorough verification steps to ensure that all new and existing code works exactly the way we expect
    - Include the expected output per verification step (log line, test result, response shape) so pass/fail is unambiguous
    - The plan should note that this should be done within a fresh QA subagent

### After the plan is accepted
Note whether the triage uncovered any architectural weaknesses — missing observability, no good test seam for the failure, hidden coupling between services. If so, hand those specifics off to the `/improve-codebase-architecture` skill. Do this **after** the fix is in, not before — you'll have more signal then than you did at the start.
