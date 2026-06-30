---
name: draw-the-owl
description: >-
  Feature-work loop: attempt the whole feature as a loose throwaway spike, measure
  the diff, and if it exceeds the line threshold (~1500) recursively decompose into
  atomic, reviewable tasks built by parallel agents. Trigger on "draw the owl",
  "/draw-the-owl", or open-ended feature implementation you want kept reviewable.
triggers:
  - /draw-the-owl
argument-hint: '<free-form feature description> [--threshold N]'
---

# Draw the Owl

A loop for feature work that keeps every chunk of code beneath a human's
review-ability threshold.

The core heuristic: **any diff an agent generates over ~1500 lines is too big**,
and is a signal that the problem needs to be decomposed. This skill turns that
signal into a process. You attempt the whole feature loosely (the "draw the owl"
prompt, after the meme: step 1, draw two circles; step 2, draw the rest of the
owl), expect garbage, then use the garbage to learn the problem's shape and
rebuild it as atomic, reviewable pieces.

The threshold is a **smell, not a hard rule**. Default is 1500 lines; the user
can override with `--threshold N`. Hold the resolved value for the whole run.

The rule is **recursive**: it reapplies to every sub-task. A decomposed task that
itself blows past the threshold gets drawn-the-owl again.

**Human-in-the-loop is mandatory.** Features touch the human boundary (UI, API)
and net-new code can introduce pathologies that violate desired architectural
invariants. Stop at every gate below and get the user's sign-off before moving on.
Keep your own context light by delegating the spike and the builds to subagents.

## Phase 1 — Draw the owl

Spawn **one** loosely-guided agent in an isolated worktree to attempt the *whole*
feature in a single pass.

```
agent('<feature description>, implemented end to end. Loose guidance only.',
      { isolation: 'worktree' })
```

Tell the agent the goal and the loosest possible guidance. Do not over-specify.
**Expect garbage** - the point is to learn the problem's shape, not to ship.

> **STOP GATE:** Report the spike's size with `git diff --stat` against the base.
> State the number plainly and whether it is over or under the threshold.

## Phase 2 — Measure and branch

Branch on the spike's diff size.

**Under threshold:** the spike is small enough to review directly. Pull it into
the working tree, then review and iterate normally. Point the user at their own
review gates - `bin/git-review` before pushing, and `/code-review` for a pass over
the diff. You are done; skip the remaining phases.

**Over threshold:** read the spike *only to learn the shape* of the solution. Then
**discard the worktree** - the garbage never touches the main tree. Decompose the
problem into atomic, incremental, reviewable tasks. The user does this in parallel
with you (the tweet's "simultaneously, do this yourself"), so present your cut as a
proposal, not a final answer.

> **STOP GATE:** Present the proposed task list - each task atomic, independently
> reviewable, and ordered by dependency. Get the user's approval and merge in their
> own decomposition before continuing.

## Phase 3 — Massage the shapes

Agents very often make these tasks **too specific to the shape they solved** in the
spike. Rewrite each task into its correct *general* shape: strip the spike's
incidental choices, name the real abstraction, and call out dependencies and
ordering between tasks.

> **STOP GATE:** Present the massaged task shapes and the build order. Approve
> before kicking off any builds.

## Phase 4 — Parallel build

Kick off one agent per task, each in its own worktree, parallelized as far as the
dependencies allow. Independent tasks go out together in a single batch.

```
agent('<massaged task>', { isolation: 'worktree' })
```

Each result re-enters the **same threshold rule**: if a task's own diff exceeds the
threshold, that task gets drawn-the-owl again (recurse into Phase 1 for it).

> **STOP GATE:** Review each result before it merges into the working tree. Never
> auto-merge a worktree. Apply the user's review gates here too.

## Phase 5 — Re-draw the owl

Once the approved chunks have landed, repeat the loose "draw the owl" attempt over
the now-smaller remaining surface. Each pass shrinks what is left. Iterate until the
whole feature sits beneath the review-ability threshold and every chunk has been
reviewed.

## Notes

- The threshold (default 1500) is a decomposition smell, not a hard limit. Use
  judgment near the line.
- The loop is recursive: any task, at any depth, that exceeds the threshold gets
  decomposed the same way.
- The spike is throwaway. Its only value is teaching you the problem's shape. Never
  let it land in the working tree when it is over threshold.
- Never push - the user's git hook blocks it, and pushing is their call. Never
  auto-merge a worktree without the review gate.
- Delegate the spike and the builds to subagents to keep your context light for the
  conversation with the user at each gate.
