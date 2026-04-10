# Verification Agent Prompts

Four agents run in parallel during Phase 3. Each receives: the list of resolved files, the conflict map from discovery, and the base/incoming branch names.

---

## Agent 1 — Conflict Marker Scan

**Goal**: Confirm no conflict markers remain in any resolved file.

**Commands to run:**
```bash
# Check all resolved files for leftover markers
grep -rn '<<<<<<\|=======\|>>>>>>>\||||||| ' <resolved-files>
```

Also check for orphaned git merge artifacts:
```bash
ls -la | grep -E '\.(orig|BACKUP|LOCAL|REMOTE|BASE)\.'
```

**Pass condition**: zero matches in all files, no merge artifact files present.

**Report back:**
```
Conflict markers: PASS | FAIL
  [if FAIL: list file:line for each marker found]
```

---

## Agent 2 — Test Suite

**Goal**: Run the full test suite and report any failures introduced by the resolution.

**Detection and execution** — detect project type and run accordingly:

| Project type | Detection | Command |
|---|---|---|
| Hardhat | `hardhat.config.ts` / `.js` exists | `npx hardhat test` |
| Foundry | `foundry.toml` exists | `forge test` |
| Jest | `jest.config.*` or `"jest"` in package.json | `npx jest` |
| Vitest | `vitest.config.*` or `"vitest"` in package.json | `npx vitest run` |
| Pytest | `pyproject.toml` or `setup.py` with pytest | `pytest` |
| Go | `go.mod` exists | `go test ./...` |
| Cargo | `Cargo.toml` exists | `cargo test` |

Run with a timeout appropriate for the project. If the command fails to start (missing deps, build error), report that as a build failure, not a test failure.

**Report back:**
```
Tests: PASS | FAIL | ERROR
  Total: X passed, Y failed, Z skipped
  [if FAIL: list failing test names and short error message]
  [if ERROR: report the startup/build error]
```

---

## Agent 3 — Build / Lint

**Goal**: Confirm the resolved code compiles and passes linting.

**Detection and execution:**

| Project type | Build command | Lint command |
|---|---|---|
| TypeScript (Hardhat) | `npx hardhat compile` | `npx eslint . --ext .ts` (if configured) |
| TypeScript (general) | `npx tsc --noEmit` | `npx eslint .` (if configured) |
| Foundry | `forge build` | `forge fmt --check` |
| Python | `python -m py_compile <files>` | `ruff check .` (if configured) |
| Go | `go build ./...` | `go vet ./...` |
| Rust | `cargo check` | `cargo clippy` |

Run build first; only run lint if build passes.

**Report back:**
```
Build: PASS | FAIL
  [if FAIL: first 10 error lines]

Lint: PASS | FAIL | SKIPPED
  [if FAIL: list of lint errors/warnings]
```

---

## Agent 4 — Feature Parity Review

**Goal**: Confirm that the resolution preserved the intended features from both sides. This is a reasoning agent — it reads the conflict map and the resolved files together.

**Process:**

1. Read the conflict map (synthesized in Phase 1 — passed in context)
2. For each entry in the conflict map, read the corresponding resolved file
3. Verify that each feature, function, type, or behavior described in the conflict map is present in the resolution

Specifically check:
- Each symbol listed as "new in ours" exists in the resolved file
- Each symbol listed as "new in theirs" exists in the resolved file
- Imports required by new symbols are present
- Test cases for new features are present (cross-reference Agent 4 from discovery)
- No feature from either side was silently dropped

**Report back:**
```
Feature parity: PASS | FAIL | PARTIAL

[if FAIL or PARTIAL:]
Missing from resolution:
  - <symbol/feature> (was in <ours|theirs>): <what's missing and why it matters>

Present and verified:
  - <symbol/feature>: confirmed in <file>:<line>
```
