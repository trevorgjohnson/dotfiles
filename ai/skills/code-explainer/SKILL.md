---
name: code-explainer
version: 1.1.0
description: >-
  Explains code with visual diagrams and analogies. Also provides a high-level
  architecture overview of a repository. Use when explaining how code works,
  teaching about a codebase, asking "how does this work?", or getting oriented
  in an unfamiliar repo.
---

# Code Explainer

Two modes depending on what the user asks:

- **Repo overview** — high-level architecture summary of the current repository
- **Code explanation** — walk through specific code, functions, or subsystems
- **Subsystem explanation** — deep dive into one domain or module within the repo

Use `AskUserQuestion` upfront to confirm the mode before proceeding — this eliminates heuristic misdetection:

```
What would you like me to do?
1. Repo overview — high-level architecture of the whole project
2. Explain specific code — walk through a function, file, or snippet
3. Explain a subsystem — deep dive into one domain or module
```

If the user's request already makes the mode unambiguous (e.g. they pasted code, or said "orient me"), skip the question and proceed directly.

---

## Repo overview mode

Generate a concise architecture summary of the current repository.

### Steps

1. **Identify the stack** — read manifest files at the root:
   - `package.json`, `tsconfig.json`, `foundry.toml`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `pom.xml`, `Makefile`
   - Check for monorepo indicators: `pnpm-workspace.yaml`, `lerna.json`, Cargo workspace, Go workspace

2. **Map the structure** — list top-level directories and identify their purpose.
   For monorepos, identify each workspace/package and its role.

3. **Find entry points** — look for:
   - `src/index.*`, `src/main.*`, `src/lib.*`, `src/App.*`
   - `contracts/` for Solidity projects
   - `cmd/` or `main.go` for Go
   - `script/` or `deploy/` for deployment scripts
   - CI config (`.github/workflows/`, `.gitlab-ci.yml`)

4. **Detect key patterns** — testing framework and location, build and deploy targets, config/env structure.

5. **Read the README** if it exists — extract anything that adds context beyond what the code shows.

### Output format

- **Stack**: languages, frameworks, package manager
- **Structure**: top-level layout with one-line descriptions
- **Entry points**: where execution starts
- **Build/Test/Deploy**: key commands
- **Notable patterns**: anything non-obvious

Keep it to one screen. This is a quick orientation, not documentation.

---

## Code explanation mode

### Structure

1. **Start with a one-liner**: Summarize what the code does in plain English
2. **Draw a diagram**: Use ASCII art to show the flow, structure, or relationships between components
3. **Walk through step-by-step**: Explain what happens in execution order, referencing specific lines
4. **Call out the "why"**: Explain design decisions, not just what the code does
5. **Highlight gotchas**: Note common mistakes, edge cases, or non-obvious behavior
6. **Show connections**: Explain how this code fits into the larger system — what calls it, what it depends on

Keep explanations at the level of the person asking. If they seem new to the codebase, be more thorough. If they seem experienced, focus on the non-obvious parts.

For infrastructure code (Terraform, Helm, Kubernetes manifests), also explain:

- What resources are created and how they relate
- What values are configurable vs hardcoded
- What would happen if this was applied/deployed
