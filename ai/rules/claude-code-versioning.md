---
version: 1.0.0
paths:
  - .claude/**/*.md
---

# Claude Code Versioning

All shareable Claude Code resources (skills, rules, commands, agents) include a `version` field in their YAML
frontmatter using
[semantic versioning](https://semver.org/):

```yaml
---
name: example-skill
version: 1.0.0
description: ...
---
```

## Version bumps

- **Major** (2.0.0) — Breaking changes: renamed tools, removed functionality, restructured output that would break
  existing workflows relying on the previous version
- **Minor** (1.1.0) — New functionality added in a backward-compatible way: new tools, new sections, expanded
  capabilities
- **Patch** (1.0.1) — Backward-compatible fixes: typos, clarifications, bug fixes in scripts, improved wording that
  doesn't change behavior

## When to bump

- Bump the version when making any meaningful change to a resource
- Trivial whitespace or formatting-only changes do not require a bump
- When creating a new resource, start at `1.0.0`
- When updating an existing resource, bump the appropriate segment and reset lower segments to zero

<!-- The version field is not consumed by Claude Code but embeds in the resource so teams copying it into their
repos can compare against the latest version in this repository. -->
