---
version: 1.0.0
description: Test case ordering convention for all test suites
paths:
  - '**/*.spec.ts'
  - '**/*.spec.js'
---

Order `it()` / test blocks by the branching conditions within the method under test — edge cases and early returns first, happy path last. This mirrors the control flow so branch coverage is visible at a glance.
