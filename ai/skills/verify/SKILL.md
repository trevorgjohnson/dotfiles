---
name: verify
description: >-
  Detect the current project type and run the appropriate lint, typecheck, and test suite in one pass.
  Use when the user wants to validate changes before committing or reviewing.
---

# Verify

Run the project's full verification pipeline: lint, typecheck, and test. Detect the stack from project files and run the right commands.

## Detection Order

Check the project root for these files (first match wins per category):

| Stack | Indicator | Lint | Typecheck | Test |
|-------|-----------|------|-----------|------|
| **Foundry** | `foundry.toml` | `forge fmt --check` | — | `forge test` |
| **TypeScript (npm)** | `tsconfig.json` + `package.json` | Check `package.json` scripts for `lint` → `npm run lint` | `npx tsc --noEmit` | Check scripts for `test` → `npm test` |
| **Rust** | `Cargo.toml` | `cargo clippy -- -D warnings` | — (compiler handles it) | `cargo test` |
| **Lua** | `.luacheckrc` or `lua/` dir | `luacheck .` (if installed) | — | — |

## Execution

1. Detect the project type(s). Monorepos may have multiple — run each.
2. For each category (lint, typecheck, test), run the command if it exists.
3. **Stop on first failure** within a category and report the error. Don't run tests if lint fails.
4. Summarize: which checks passed, which failed, and the relevant error output.

## Notes

- If `package.json` has custom script names (e.g., `check` instead of `lint`), read the scripts object and use the closest match.
- For Foundry projects, also check for `slither` if installed — mention it as optional but don't run it by default.
- If no project type is detected, tell the user and ask what commands to run.
