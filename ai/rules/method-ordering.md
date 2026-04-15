---
description: Method ordering convention within classes and modules
---

Order methods to be defined before used:
1. Simple constants — keys, config getters
2. Small/highly-reused immutable methods — getters (DB, cache, external)
3. Small/highly-reused mutable methods — setters, queue-adders
4. Complex methods that compose the above

One-shot helpers go directly above the single method that uses them. This keeps related methods and dependencies naturally adjacent without section-header comments.
