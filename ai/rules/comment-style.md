---
version: 1.0.0
description: >-
  Per-line plain-english comments in method bodies describing
  what each step does
paths:
  - '**/*.ts'
  - '**/*.tsx'
  - '**/*.js'
  - '**/*.jsx'
---

# Comment Style

Write per-line plain-english comments on most lines of method
bodies, describing what each step does. The goal is that someone
reading the method can understand the flow without parsing the
code. Skip comments only where the line is genuinely self-evident.

Avoid AI-telltale phrasing: no em dashes (`—`) as separators, and no
overly formal or verbose phrasing where plain words work.
