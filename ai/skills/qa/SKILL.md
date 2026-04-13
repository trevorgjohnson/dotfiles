---
name: qa
description: >-
  Generate a human-executable QA plan from a completed feature's PRD and implementation plan.
  Organizes test cases by category (happy paths, edge cases, error states, non-functional).
  Use after feature execution to produce a structured checklist for manual testing.
---

# QA Plan Generator

Produces a human-executable QA checklist from a feature's acceptance criteria and user stories. Output is structured, concrete, and test-ready — not a spec rehash.

---

## Step 1 — Gather inputs

Read in order (use what's available):

1. **PRD** at `~/.claude/prds/<feature>/prd.md` — user stories, out-of-scope items
2. **Plan** at `~/.claude/plans/<feature>.md` — phase acceptance criteria
3. Ask (use `AskUserQuestion`):

> Any specific scenarios to cover, known edge cases to include, or scenarios to explicitly exclude?

If invoked from `build-feature`, both paths are already in context — skip asking for them.

---

## Step 2 — Generate QA plan

Derive test cases from acceptance criteria and user stories. Organize by category:

```markdown
## Happy paths
[Primary user journeys from user stories — one test per story]

## Edge cases
[Boundary conditions derived from acceptance criteria]

## Error states
[Failure modes: invalid input, network errors, auth failures, missing data, etc.]

## Non-functional
[Only include if PRD scope warrants: performance, accessibility, security]
```

Each test entry:

```markdown
### TC-N: <test name>
**Setup**: <preconditions — what state must exist before running>
**Steps**: 
1. [action]
2. [action]
**Expected**: <concrete, observable result — not "it works">
**Out of scope**: [optional — only if risk of confusion with excluded features]
```

Rules:
- One test per user story (happy path)
- Edge cases come from acceptance criteria bounds, not imagination
- Error states cover explicit failure modes mentioned in the PRD or implied by the feature
- Non-functional tests only if the PRD's scope explicitly includes them
- Expected results must be observable (visible change, specific response, specific state) — not vague ("it works correctly")
- Do not pad — a focused 8-test plan beats a bloated 30-test plan

---

## Step 3 — Save

Write to `~/.claude/prds/<feature>/qa.md`.

Print the file path. If invoked from `build-feature`, the pipeline is complete.
