---
name: request-refactor-plan
description: Create a detailed refactor plan with tiny commits via user interview, then save it as a markdown file. Use when user wants to plan a refactor, create a refactoring RFC, or break a refactor into safe incremental steps.
---

This skill will be invoked when the user wants to create a refactor request. You should go through the steps below. You may skip steps if you don't consider them necessary.

1. Ask the user for a long, detailed description of the problem they want to solve and any potential ideas for solutions.

2. Explore the repo to verify their assertions and understand the current state of the codebase.

3. Ask whether they have considered other options, and present other options to them. Use `AskUserQuestion` to present 2–4 common refactor patterns as numbered choices (e.g. Extract method / Introduce abstraction / Invert dependency / Strangler fig). Include your recommendation. Let the user pick or indicate "none of the above."

4. Interview the user about the implementation. Be extremely detailed and thorough.

5. Hammer out the exact scope of the implementation. Work out what you plan to change and what you plan not to change.

   Enter `EnterPlanMode` at the start of Step 5. Present the proposed scope and commit plan to the user before writing anything to disk. `ExitPlanMode` after the user approves the plan.

6. Look in the codebase to check for test coverage of this area of the codebase. If there is insufficient test coverage, ask the user what their plans for testing are.

7. Break the implementation into a plan of tiny commits. Remember Martin Fowler's advice to "make each refactoring step as small as possible, so that you can always see the program working."

   After the commit list is finalized, call `TaskCreate` for each planned commit. Use subjects like "commit: <short description>". This turns the plan into a live checklist during execution.

8. Write the refactor plan to `~/.claude/prds/<project-name>/refactor-plans/<slug>.md`. If you don't have a project name from context, derive a short slug from the refactor description. Use the following template:

<refactor-plan-template>

## Problem Statement

The problem that the developer is facing, from the developer's perspective.

## Solution

The solution to the problem, from the developer's perspective.

## Commits

A LONG, detailed implementation plan. Write the plan in plain English, breaking down the implementation into the tiniest commits possible. Each commit should leave the codebase in a working state.

## Decision Document

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this refactor.

## Further Notes (optional)

Any further notes about the refactor.

</refactor-plan-template>
