# Discovery Agent Prompts

Four agents run in parallel during Phase 1. Each receives the list of conflicted files and the merge context (base branch = HEAD, incoming = MERGE_HEAD).

---

## Agent 1 — File-Level Changes

**Goal**: Understand what each side added, deleted, or significantly modified at the file level.

**Commands to run:**
```bash
# What ours (HEAD/base) changed relative to the common ancestor
git diff $(git merge-base HEAD MERGE_HEAD)..HEAD --stat

# What theirs (MERGE_HEAD/incoming) changed relative to the common ancestor
git diff $(git merge-base HEAD MERGE_HEAD)..MERGE_HEAD --stat

# For each conflicted file, show the full diff from each side
git diff $(git merge-base HEAD MERGE_HEAD)..HEAD -- <file>
git diff $(git merge-base HEAD MERGE_HEAD)..MERGE_HEAD -- <file>
```

**Report back:**
```
File: <path>
  Ours:   [added N lines | deleted N lines | renamed from X | no change]
  Theirs: [added N lines | deleted N lines | renamed from X | no change]
  Summary: <one sentence on what each side was doing to this file>
```

---

## Agent 2 — Symbol-Level Changes

**Goal**: Identify new or removed functions, classes, types, constants, and exports on each side.

**Commands to run:**
```bash
# For each conflicted file, diff against common ancestor
git show $(git merge-base HEAD MERGE_HEAD):<file>   # ancestor version
git show HEAD:<file>                                 # our version
git show MERGE_HEAD:<file>                           # their version
```

Use LSP or grep patterns appropriate to the file type to extract symbol lists from each version, then diff them:
- Functions/methods: `function \w+`, `async \w+`, `def \w+`, `func \w+`
- Exports: `export (const|function|class|default)`
- Types/interfaces: `(type|interface) \w+`
- Constants: `^(const|let|var) [A-Z_]+`

**Report back:**
```
File: <path>
  New in ours:    [symbol list or "none"]
  New in theirs:  [symbol list or "none"]
  Removed in ours:   [symbol list or "none"]
  Removed in theirs: [symbol list or "none"]
```

---

## Agent 3 — Dependency Changes

**Goal**: Identify changes to package manifests, imports, and lock files that both sides may have touched.

**Commands to run:**
```bash
# Check package manifests for conflicts or divergence
git diff $(git merge-base HEAD MERGE_HEAD)..HEAD -- package.json foundry.toml Cargo.toml go.mod pyproject.toml requirements.txt
git diff $(git merge-base HEAD MERGE_HEAD)..MERGE_HEAD -- package.json foundry.toml Cargo.toml go.mod pyproject.toml requirements.txt

# For conflicted source files, extract import blocks
git show HEAD:<file> | head -50
git show MERGE_HEAD:<file> | head -50
```

**Report back:**
```
Package manifest changes:
  Ours:   [added/removed/updated packages or "none"]
  Theirs: [added/removed/updated packages or "none"]
  Conflict risk: [high if both modified same dependency | low otherwise]

Per-file import changes:
  File: <path>
    Ours:   [new imports | removed imports | "none"]
    Theirs: [new imports | removed imports | "none"]
```

---

## Agent 4 — Test Delta

**Goal**: Identify new, removed, or modified tests on each side so resolution preserves test intent.

**Commands to run:**
```bash
# Find test files changed on each side
git diff $(git merge-base HEAD MERGE_HEAD)..HEAD --name-only | grep -E '(test|spec)\.(ts|js|sol|py|go)'
git diff $(git merge-base HEAD MERGE_HEAD)..MERGE_HEAD --name-only | grep -E '(test|spec)\.(ts|js|sol|py|go)'

# For each changed test file, show what changed
git diff $(git merge-base HEAD MERGE_HEAD)..HEAD -- <test-file>
git diff $(git merge-base HEAD MERGE_HEAD)..MERGE_HEAD -- <test-file>
```

Extract test names using patterns for the detected framework:
- Hardhat/Jest: `it\(`, `describe\(`, `test\(`
- Foundry: `function test`
- Pytest: `def test_`
- Go: `func Test`

**Report back:**
```
Test changes:
  New tests in ours:    [test names or "none"]
  New tests in theirs:  [test names or "none"]
  Modified tests (ours):   [test names or "none"]
  Modified tests (theirs): [test names or "none"]
  Removed tests (ours):    [test names or "none"]
  Removed tests (theirs):  [test names or "none"]
```
