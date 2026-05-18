---
paths:
  - "**/.env*"
  - "**/api/**"
---

# Security Rules

See [`docs/SECURITY-RULES.md`](../../docs/SECURITY-RULES.md) for the full rule set. That file is the single source of truth and is loaded by both Claude Code (via this pointer, triggered by the `paths` glob above) and opencode (via the `instructions` array in `opencode.json`).
