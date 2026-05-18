# CLAUDE.md — {{PROJECT_NAME}}

> This file is the project memory. It is read by both [Claude Code](https://claude.com/claude-code) and [opencode](https://opencode.ai/) — opencode picks it up automatically and the path is also listed in `opencode.json` under `instructions`. Keep this file tool-agnostic; tool-specific configuration lives in `.claude/` and `.opencode/`.

## About the Project
_One paragraph: what this product is, who it's for, and the core principle that distinguishes it._

## Security Rules

Security rules live in [`docs/SECURITY-RULES.md`](docs/SECURITY-RULES.md). They apply whenever you edit `.env*` files or files under `**/api/**`. Claude Code auto-injects them via `.claude/rules/security.md`; opencode loads them every session via `opencode.json`.

## Testing

Write tests whenever introducing new logic, features, or significant changes. Prefer existing test fixtures / sample data over ad-hoc fixtures. The `/write-tests` skill provides detailed guidance for this project's stack.

## Keep it Clean

After finishing and testing a change, make sure no zombie code or old workarounds remain. Keep the code clean. Update `ARCHITECTURE.md` if it is inconsistent with the codebase. Update user documentation and feature files whenever changes make them outdated.

## Feature-Driven Development Workflow

All implementation work follows this sequence per feature:

1. **Feature Spec** (`/requirements`) — defines WHAT (user stories, acceptance criteria, edge cases)
2. **Technical Design** (`/technical-design PROJ-X`) — defines HOW (DB schema, API contracts, components)
3. **Technical Design Refinement** — execute the Plan Review Workflow for the tech design
4. **Implementation** — code against the tech design, one branch per PROJ-X
5. **Verification** — test against acceptance criteria, results appended to feature file

When implementing a feature, always read these files first:
- The feature spec: `features/PROJ-X-*.md` (including its Tech Design section)
- `ARCHITECTURE.md` for architectural constraints and security invariants
- `features/INDEX.md` for dependency order

Never start implementing a feature that has no Tech Design section. Run `/technical-design PROJ-X` first.

---

## Frontend & Corporate Design

When doing any frontend work (components, pages, layouts, styling), always read and follow `docs/CorporateDesign.md` before writing code. All UI must conform to the corporate design guidelines defined there — colors, typography, spacing, component styles, and overall visual language.

---

## Plan Review Workflow

Before presenting any plan to the user, run the full iterative review pipeline below.
Do not skip, abbreviate, or present the plan before the pipeline completes.

A "plan" includes: proposed architecture, new features, API design, data model changes,
infrastructure changes, and any change touching auth, data storage, or external services.
For small isolated changes (typo fixes, renaming, minor refactors) this is optional.

---

### Round 1 — Independent Review

Run both agents in parallel on the original plan:

**Task A — Architecture Review**
- Agent: `architecture-reviewer` (`.claude/agents/architecture-reviewer.md` in Claude Code, `.opencode/agents/architecture-reviewer.md` in opencode)
- Input: the full proposed plan + relevant codebase context

**Task B — Security Review**
- Agent: `security-reviewer` (`.claude/agents/security-reviewer.md` in Claude Code, `.opencode/agents/security-reviewer.md` in opencode)
- Input: the full proposed plan + relevant codebase context

Do not pass either agent's output to the other in Round 1. Independence is the point.

---

### Refinement — Revise the Plan

Once both Round 1 reviews are complete:

1. Collect all critical issues and concerns from both reviews
2. Revise the plan to address them — cross-discipline first:
   - Apply security fixes that affect architectural decisions
   - Apply architectural changes that have security implications
   - Then address remaining single-discipline issues
3. Note every change made and which finding it resolves
4. Note any issues you chose not to address and why

This produces a **Revised Plan** and a **Change Log**.

---

### Round 2 — Cross-Informed Review

Run both agents again on the Revised Plan, with full context from Round 1:

**Task C — Architecture Review (Round 2)**
- Agent: `architecture-reviewer` (same agent file as Round 1)
- Input: revised plan + change log + Round 1 architecture review + Round 1 security
  review
- Focus: do the security-driven changes introduce architectural problems? Are Round 1
  architecture concerns resolved?

**Task D — Security Review (Round 2)**
- Agent: `security-reviewer` (same agent file as Round 1)
- Input: revised plan + change log + Round 1 security review + Round 1 architecture
  review
- Focus: do the architecture-driven changes introduce security problems? Are Round 1
  security concerns resolved?

---

### Evaluate Round 2 Verdicts

Check all four verdicts (Round 1 + Round 2) and determine what remains open:

| State | Action |
|---|---|
| Both Round 2 verdicts PASS or PASS WITH CONCERNS, all critical issues resolved | Proceed to Present — clean |
| PASS WITH CONCERNS remain but no critical issues | Proceed to Present — flag concerns to user |
| Any Round 2 FAIL, or any Round 1 critical issue unresolved after revision | **Stop — escalate to user before proceeding** |

An issue counts as "resolved" only if the reviewing agent in Round 2 explicitly confirms
it. Do not self-certify resolution.

---

### Present to User

**If the pipeline completed cleanly:**

> **Plan** — the revised plan in full
>
> **What changed between drafts** — a brief change log tied to the findings that drove
> each change
>
> **Open concerns** — anything flagged as a concern (not critical) that was not fully
> resolved, with your recommendation on each
>
> **Recommendation** — proceed / proceed with caveats / needs further design

**If the pipeline has unresolved critical issues:**

> **Stop.** Present the unresolved issues clearly. Do not present the plan as ready.
> Ask the user how they want to proceed — redesign, accept the risk explicitly, or
> descope the change.

Do not bury failures in a long summary. Lead with the blocker.
