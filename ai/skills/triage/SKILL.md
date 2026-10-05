---
name: triage
description: Investigate discrepancies across Prometheum services using logs, database reads, chain state, and code.
argument-hint: '<free-form description of the issue>'
---

Confirm the symptom, environment, and investigation plan before dispatching agents.
Environments are prod, qa, uat, development, and local; ask if unspecified.
Start with plausible layers and expand only when evidence warrants it.
Share ranked, falsifiable hypotheses with the plan; proceed with that ranking if the user offers no corrections.
Locate the repositories before investigating; the paths below describe sibling checkouts, not paths relative to this skill.

| Layer | Repo | Datadog namespace | DB keys |
|---|---|---|---|
| Frontend | `../platform-frontend` | `kube_namespace:procap-platform-frontend` | none |
| Platform BE | `../platform-backend` | `kube_namespace:procap-platform-backend` | `{env}-platform`, `{env}-procap` |
| ProKeys | `../mobile-prokeys-ios` | none | none |
| Boats BE | `../boats-backend` | `kube_namespace:procap-boats-backend` | `{env}-boats` |
| Chain | `../cows` | none | none |

Frontend calls Platform BE over GraphQL; Platform BE sends BullQueue jobs to Boats BE, which calls Ethereum RPC.
ProKeys polls Platform BE's `getDasWithdrawalsForSigning` and returns approver signatures through `signedByApproverDasWithdrawal`; `cows` contracts verify those signatures on-chain.

Delegate targeted, independent investigations in parallel using available agents and the smallest capable model.
Give each agent the environment, hypothesis, relevant identifiers, and a narrow question; request evidence and a concise conclusion.
Use `datadog` with the service's `kube_namespace` and a default 15-minute window, widening as needed.
Use `db-query` for targeted reads; defer exploratory schema discovery unless the query returns empty.
Use `foundry-cast` when chain state is directly relevant and code-reading agents for specific repositories or functions.

Report which hypotheses were confirmed, refuted, or remain open, with supporting evidence.
Finish the investigation report without proposing fixes, then offer remediation planning.

If requested, propose the smallest remediation supported by the evidence, with concrete code locations, tradeoffs, and regression checks.
Verify the plan against source and get agreement before implementing it.
After the fix, surface any architectural weaknesses found, such as missing observability, poor test seams, or hidden coupling, for separate improvement work.
