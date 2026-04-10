---
name: git-resolve
description: Resolve git merge conflicts for local branches and GitHub PRs using parallel discovery agents. Autonomously resolves hunks (pausing on ambiguous ones), then verifies correctness with parallel verification agents. Use when encountering merge conflicts, conflict markers, "CONFLICT" output from git merge, or when asked to merge a branch or PR.
---

# git-resolve

Orchestrates conflict resolution in four phases: intake → discovery → resolution → verification.

## Phase 0 — Intake

Use `AskUserQuestion` with these structured options:

```
What do you want to merge?

1. Local branch — provide the incoming branch name
2. GitHub PR — provide the PR number or URL

And: what is the base branch? (default: develop)
```

Then set up the merge:

- **PR**: `gh pr checkout <number>` then `git merge <base-branch>`
- **Local branch**: from base branch, run `git merge <incoming-branch>`

If merge succeeds with no conflicts → report clean merge and stop.

Otherwise, list conflicted files:
```bash
git diff --name-only --diff-filter=U
```

## Phase 1 — Discovery (parallel)

Create tasks up front with `TaskCreate`:
- [ ] Discovery
- [ ] Resolution
- [ ] Verification
- [ ] Output

Fan out **4 parallel Explore agents** (model=haiku) using the prompts in [DISCOVERY.md](DISCOVERY.md):

| Agent | Focus |
|---|---|
| 1 | File-level changes — what each side added/deleted/modified |
| 2 | Symbol-level changes — new/removed functions, types, exports |
| 3 | Dependency changes — package files, imports, lock files |
| 4 | Test delta — new/removed/modified tests per side |

Synthesize results into a **per-file conflict map**: for each conflicted file, what each side was trying to achieve.

Mark Discovery task complete.

## Phase 2 — Resolution (autonomous)

For each conflicted file, read the conflict markers and the conflict map. Resolve each hunk:

- Unique addition from one side → keep it
- Unique deletion from one side → apply it
- Both sides touch the same lines → merge semantically (keep the intent of both)
- **Ambiguous hunk** → use `AskUserQuestion`:

```
Ambiguous conflict in <file>:<line>

OURS (<base-branch>):
<their version>

THEIRS (<incoming-branch>):
<our version>

1. Keep ours
2. Keep theirs
3. Keep both (ours first)
4. Keep both (theirs first)
5. I'll resolve manually — pause here
```

After resolving all hunks in a file, `git add <file>` and mark the per-file task complete with `TaskUpdate`.

Mark Resolution task complete.

## Phase 3 — Verification (parallel)

Fan out **4 parallel agents** using the prompts in [VERIFICATION.md](VERIFICATION.md):

| Agent | Check |
|---|---|
| 1 | Conflict marker scan |
| 2 | Test suite |
| 3 | Build / lint |
| 4 | Feature parity review |

Mark Verification task complete.

## Phase 4 — Output

Report two sections:

**Resolution Summary** — per file: what was kept from each side and why.

**Verification Report** — pass/fail table:

| Check | Result | Notes |
|---|---|---|
| Conflict markers | ✓ / ✗ | |
| Tests | ✓ / ✗ | failing test names |
| Build / lint | ✓ / ✗ | errors |
| Feature parity | ✓ / ✗ | missing features |

> The skill does not commit. The user commits manually after reviewing.

## Reference

- "Ours" = current HEAD (base branch); "Theirs" = MERGE_HEAD (incoming branch)
- Discovery agents: see [DISCOVERY.md](DISCOVERY.md)
- Verification agents: see [VERIFICATION.md](VERIFICATION.md)
