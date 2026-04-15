---
name: phasic-plan
description: >-
  Strict phase gating for multi-phase plan execution. Only trigger when user
  explicitly says "phasic plan" or asks for phase-gated execution with manual
  approval gates between phases.
---

# Phasic Plan

Use when phases need human approval between them, or work can't be verified
programmatically. Use `ralph-wiggum` instead when verification is objective and
risk is bounded.

Execute the current plan with strict phase gating:

1. **Phase gating** — halt at the end of each phase and wait for explicit user approval before starting the next. Never pick up tasks from a future phase unprompted.
2. **Freedom within a phase** — work freely using any execution strategy (solo, parallel subagents, teams, etc.).
3. **Verification per phase** — each phase ends with a verification step confirming all items were completed. If the phase delivers a capability, manually test it. If it can't be verified programmatically, hand it to the user for manual testing.
4. **No scope creep across phases** — do not start work outside the current phase unless the user approves.
5. **Plan stays current** — after completing each phase, update the memory plan doc (mark phase complete, record what was done, update remaining items). Do this before halting for approval.
6. **Approval markers** — use these status markers on phase headings in the plan doc:
   - `[ ]` not started
   - `[~]` work complete, awaiting user approval
   - `[x]` approved by user
   When a phase finishes, mark it `[~]`. When the user explicitly approves, update to `[x]`.
7. **Context hygiene** — after the user approves a phase and the marker is updated to `[x]`, always prompt them to `/clear` context before the next phase begins. Each phase is designed to run in a fresh context — the plan file is the handoff artifact. Provide a structured, copy-pasteable resume prompt using this exact format:
   > `Continue [plan name] — phase [N+1]. Plan at [memory path]. Previous phases [x]. Resume next phase.`
   For short plans (≤2 phases, low complexity), note that `/clear` is optional but recommended.
8. **Task tracking** — at the start of each phase, call `TaskCreate` for each discrete work item in that phase. As work finishes, call `TaskUpdate` (status `completed`) on each item. During the verification step (rule 3), call `TaskList` to machine-check that all phase tasks are completed before marking the phase `[~]`. Complete or delete all phase tasks before halting for user approval.
