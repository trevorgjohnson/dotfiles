---
name: codebase-overview
description: >-
  Quick architecture summary of the current repository: stack, structure, entry points, and key patterns.
  Use when opening an unfamiliar repo or onboarding to a new project.
---

# Codebase Overview

Generate a concise architecture summary of the current repository.

## Steps

1. **Identify the stack** — read manifest files at the root:
   - `package.json`, `tsconfig.json`, `foundry.toml`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `pom.xml`, `Makefile`
   - Check for monorepo indicators: `pnpm-workspace.yaml`, `lerna.json`, Cargo workspace, Go workspace

2. **Map the structure** — list top-level directories and identify their purpose:
   ```bash
   ls -1 # top-level entries
   ```
   For monorepos, identify each workspace/package and its role.

3. **Find entry points** — look for:
   - `src/index.*`, `src/main.*`, `src/lib.*`, `src/App.*`
   - `contracts/` for Solidity projects
   - `cmd/` or `main.go` for Go
   - `script/` or `deploy/` for deployment scripts
   - CI config (`.github/workflows/`, `.gitlab-ci.yml`)

4. **Detect key patterns**:
   - Testing: what framework, where tests live, how to run them
   - Build: how to build, any notable build steps
   - Deploy: deployment targets and mechanisms
   - Config: environment variables, config files

5. **Read the README** if it exists — extract anything that adds context beyond what the code shows.

## Output Format

Present a compact summary:

- **Stack**: languages, frameworks, package manager
- **Structure**: top-level layout with one-line descriptions
- **Entry points**: where execution starts
- **Build/Test/Deploy**: key commands
- **Notable patterns**: anything non-obvious (custom codegen, unusual directory conventions, etc.)

Keep it to one screen. This is a quick orientation, not documentation.
