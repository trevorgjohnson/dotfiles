---
name: build-feature
description: End-to-end feature pipeline orchestrator. Chains grill-me (optional), research (optional), prototype (optional), write-a-prd, prd-to-plan, ralph-wiggum or phasic-plan, and qa into a single flow. Use when user wants to build a new feature from scratch, or wants to pick up an existing PRD or plan mid-pipeline.
---

# Build Feature Pipeline

Orchestrates the full feature development flow from idea to execution.

## Pipeline

```
grill-me (optional)
  └─► research.md (optional)    ← codebase exploration + external research
        └─► prototype (optional) ← design exploration before PRD
              └─► write-a-prd   → ~/.claude/prds/<feature>/prd.md
                    └─► prd-to-plan → ~/.claude/plans/<feature>.md
                          ├─► ralph-wiggum   (autonomous, verify-until-done)
                          └─► phasic-plan    (human-gated phase approvals)
                                └─► /qa → ~/.claude/prds/<feature>/qa.md
```

## Step 1 — Entry point

Use `AskUserQuestion`:

> Where are you starting?
> 1. From scratch — interview → PRD → plan → execute
> 2. Existing PRD — skip interview, go to plan → execute (ask for PRD path)
> 3. Existing plan — skip to execute (ask for plan path)

## Step 2 — Interview (if starting from scratch)

Ask:

> Deep interview before writing the PRD?
> 1. Yes — run `/grill-me` first, then hand off to `/write-a-prd`
> 2. No — go straight to PRD

If yes: run `/grill-me`. When the interview concludes, proceed to Step 3 with decisions in context — do not re-ask questions already resolved.

If no: proceed to Step 3.

## Step 3 — Research (if starting from scratch)

Ask:

> Does this feature require research first?
> 1. Codebase — need to understand unfamiliar or complex internal areas
> 2. External — need to explore third-party APIs, schemas, or library docs (e.g. Stripe, an SDK)
> 3. Both
> 4. No — go straight to PRD

Establish the feature slug for output paths before branching.

**Codebase:** Identify the unfamiliar areas from the interview context. Launch Explore sub-agents on each area in parallel. Synthesize findings — don't copy raw output. Save to `~/.claude/prds/<feature>/research.md`.

**External:** Run `/research` with the specific topic (e.g. "Stripe webhook schemas", "SDK v3 migration"). Save output to `~/.claude/prds/<feature>/research.md`.

**Both:** Run Explore sub-agents and `/research` in parallel where the topics are independent. If external research must inform which codebase areas to explore, run sequentially. Merge both outputs into `~/.claude/prds/<feature>/research.md`.

**No:** Skip to Step 4.

When passing to `write-a-prd`: provide the research.md path. The PRD author should skip re-exploring areas already covered.

## Step 4 — Prototype (if starting from scratch)

Ask:

> Does any part of this feature require design exploration before writing the PRD?
> (Useful when UI look/behavior, architectural pattern, or API shape isn't decided yet)
> 1. Yes — run `/prototype` to explore approaches first
> 2. No — go straight to PRD

If yes: run `/prototype`. When consensus is reached, pass the chosen approach path and `findings.md` to `write-a-prd` as seed material for the **Implementation Decisions** section. Do not re-ask questions already resolved.

If no: proceed to Step 5.

## Step 5 — PRD → Plan

Run `/write-a-prd`. Research.md and prototype findings.md are in context — pass their paths. Do not re-ask for information already resolved.

Then run `/prd-to-plan`. The PRD should be in context already. Do not re-ask for it.

## Step 6 — Scope pin

Before execution, lock the spec. Pull from the PRD's "Out of Scope" section and the plan's acceptance criteria. Present a summary:

> **Scope pin — confirm before executing:**
> **In scope:** [acceptance criteria from plan phases]
> **Out of scope:** [from PRD Out of Scope section]
>
> 1. Looks good — proceed
> 2. Amend — describe change

Do not proceed until confirmed.

## Step 7 — TDD

Ask:

> Use TDD during execution? (default: Yes)
> 1. Yes — write failing test first, then implement to pass
> 2. No — implement directly, verify at end

## Step 8 — Execute + handoff

`prd-to-plan` ends with an execution mode choice. If jumping in at an existing plan (entry point 3), ask:

> Execution mode?
> 1. `/ralph-wiggum setup` — autonomous loop, runs until verified
> 2. `/phasic-plan` — phase-gated with human approval between phases
> 3. Manual — I'll execute myself

Pre-fill plan path and verify command from the plan's `## Execution` block.

**Context reset (required before execution).** Planning context pollutes execution. After setup, present a clear handoff:

> Planning done. Run `/clear`, then paste this to resume:
>
> ```
> [generated start prompt]
> ```

- **ralph-wiggum:** use the start prompt from `/ralph-wiggum setup`. If TDD selected, prepend: `"TDD mode: on — write a failing test before each implementation step."`
- **phasic-plan:** resume prompt is `"Run /phasic-plan. Plan at <plan-path>. [TDD mode: on — write tests first within each phase.]"`

## Step 9 — QA handoff

After execution completes (verify command passes or all phases approved):

Run `/qa` to generate the human QA plan.

Pre-fill:
- PRD at `~/.claude/prds/<feature>/prd.md`
- Plan at `~/.claude/plans/<feature>.md`

Print the qa.md path when done.
