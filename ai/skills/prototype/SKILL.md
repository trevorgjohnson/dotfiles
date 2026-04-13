---
name: prototype
description: >-
  Design exploration skill. Generates 2–3 distinct throwaway implementations of a UI/architectural
  surface so the user can impose taste before the PRD locks anything in. Use when user wants to
  explore how something should look/behave/feel before committing to a direction.
---

# Prototype

Design exploration — not correctness validation. Goal: surface distinct approaches so the user can impose taste before the PRD locks anything in.

All output lives in `~/.claude/prds/<feature>/prototype/` — never committed.

---

## Step 1 — Identify the taste-sensitive surface

Use `AskUserQuestion`:

> What are you trying to figure out the *feel/shape* of?
>
> Examples:
> - How a UI component should look or behave
> - Which architectural pattern fits best
> - What API shape feels most ergonomic
> - How a workflow or interaction should be structured
>
> Describe the surface you want to explore:

This is not about validating correctness — it's about finding what *feels right*. If the user is vague, ask a follow-up: "What makes you unsure about this? What would 'wrong' look like?"

Establish the feature slug (`<feature>`) for the output path. If invoked from `build-feature`, it's already in context.

---

## Step 2 — Generate approaches

Produce **2–3 genuinely distinct implementations** of the surface. Not variations on a theme — real alternatives with different shapes:

- **For UI:** different visual structure, different interaction model, different information hierarchy
- **For architecture:** different patterns (e.g. event-driven vs. request-response, service vs. library)
- **For API/interface:** different contract shapes, different caller ergonomics, different data models
- **For workflow:** different ordering, different responsibility boundaries, different user mental model

Each approach:
- Lives in `~/.claude/prds/<feature>/prototype/approach-N/` (N = 1, 2, 3)
- Is labeled at the top: `// prototype approach N — throwaway`
- Is complete enough to evaluate — not a stub, not production-ready
- Rough is fine. Legibility over cleanliness.

Write all approaches before presenting them. Don't ask for feedback mid-generation.

---

## Step 3 — Present + iterate

Walk the user through each approach. For each one, describe:
- The core idea / design decision it embodies
- What it makes easy, what it makes hard
- Who it's best suited for / when it shines

Then use `AskUserQuestion`:

> Which direction resonates?
> - Pick one, or describe what you like from each
> - What would you change in the preferred direction?

Iterate within the session. Refine the leading approach based on feedback. Continue until the user reaches consensus: "yes, this is the shape I want."

Don't stop at first positive reaction — confirm explicitly: *"Is this the direction you want to carry forward into the PRD?"*

---

## Step 4 — Document the winner

Write `~/.claude/prds/<feature>/prototype/findings.md`:

```markdown
# Prototype Findings — <feature>

## Chosen approach
**Path:** prototype/approach-N/
**Core idea:** [one sentence]

## What was tried and rejected
- Approach 1: [description] — rejected because [reason]
- Approach 2: [description] — rejected because [reason]

## Key decisions and preferences extracted
- [Decision 1]: [what the user said / what was inferred]
- [Decision 2]: ...

## Assets to carry forward
[List specific files, components, or patterns from the prototype that should inform implementation]
```

---

## Step 5 — Handoff

Print the findings.md path.

If invoked from `build-feature`: feed the chosen approach path and `findings.md` into `write-a-prd` as seed material for the **Implementation Decisions** section. Do not re-ask questions already resolved.
