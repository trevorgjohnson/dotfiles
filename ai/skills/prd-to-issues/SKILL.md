---
name: prd-to-issues
description: Break a PRD into independently-grabbable markdown files using tracer-bullet vertical slices. Use when user wants to convert a PRD to issues, create implementation tickets, or break down a PRD into work items.
---

# PRD to Issues

Break a PRD into independently-grabbable markdown files using vertical slices (tracer bullets).

## Process

### 1. Locate the PRD

Ask the user for the PRD file path, or check if it's already in context.

If the PRD is not already in your context window, read it from `~/.claude/prds/<feature-name>/prd.md`.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.

### 3. Draft vertical slices

Call `EnterPlanMode` before presenting the slice breakdown — you're proposing a plan, not writing files yet.

Break the PRD into **tracer bullet** issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
</vertical-slice-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories from the PRD this addresses

Use `AskUserQuestion` for each binary feedback question separately:

1. "Does the granularity feel right? Too coarse / About right / Too fine"
2. "Are the dependency relationships correct? Yes / No — describe what's wrong"
3. "Are all HITL/AFK designations correct? Yes / No — describe what's wrong"

Iterate (adjusting and re-presenting) until all three get affirmative answers. Call `ExitPlanMode` once the breakdown is approved.

### 5. Write the issue files

Before writing, call `TaskCreate` for each approved issue (e.g. "Write issue: 01-scaffold-auth"). As each file is written, call `TaskUpdate` to `completed`. This provides a live progress indicator when many files are being created.

For each approved slice, write a markdown file to `~/.claude/prds/<feature-name>/issues/<nn>-<slug>.md`. Use the template below.

Write files in dependency order (blockers first) so you can reference real filenames in the "Blocked by" field.

<issue-template>
## Parent PRD

[prd.md](../prd.md)

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation. Reference specific sections of the parent PRD rather than duplicating content.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

- Blocked by [<nn>-<slug>.md](<nn>-<slug>.md) (if any)

Or "None - can start immediately" if no blockers.

## User stories addressed

Reference by number from the parent PRD:

- User story 3
- User story 7

</issue-template>

Do NOT modify the parent PRD file.
