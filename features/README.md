# Feature Specifications

This folder contains detailed feature specs produced by the Requirements Engineer.

## Naming Convention
`PROJ-X-feature-name.md`

Examples:
- `PROJ-1-user-authentication.md`
- `PROJ-2-kanban-board.md`
- `PROJ-3-file-attachments.md`

## What goes into a Feature Spec?

### 1. User Stories
Describe what the user wants to do:
```markdown
As a [user type] I want to [action] so that [goal]
```

### 2. Acceptance Criteria
Concrete, testable criteria:
```markdown
- [ ] User can enter email + password
- [ ] Password must be at least 8 characters long
- [ ] After registration the user is automatically logged in
```

### 3. Edge Cases
What happens in unexpected situations:
```markdown
- What happens with a duplicate email?
- What happens on network failure?
- What happens during concurrent edits?
```

### 4. Tech Design (from Solution Architect)
```markdown
## Database Schema
CREATE TABLE tasks (...);

## Component Architecture
ProjectDashboard
├── ProjectList
│   └── ProjectCard
```

### 5. QA Test Results (from QA / verification)
The verification step appends test results to the bottom of the feature document:
```markdown
---

## QA Test Results

**Tested:** YYYY-MM-DD
**App URL:** http://localhost:3000

### Acceptance Criteria Status
- [x] AC-1: User can enter email + password
- [x] AC-2: Password at least 8 characters
- [ ] ❌ BUG: Duplicate email is not rejected

### Bugs Found
**BUG-1: Duplicate email registration**
- **Severity:** High
- **Steps to Reproduce:** 1. Register with email, 2. Try again with same email
- **Expected:** Error message
- **Actual:** Silent failure
```

### 6. Deployment Status
```markdown
---

## Deployment

**Status:** ✅ Deployed
**Deployed:** YYYY-MM-DD
**Production URL:** https://your-app.example.com
**Git Tag:** v1.0.0-PROJ-1
```

## Workflow

1. **Requirements Engineer** creates the feature spec
2. **User** reviews the spec and gives feedback
3. **Solution Architect** adds the tech design
4. **User** approves the final design
5. **Implementation** (documented via git commits)
6. **QA / Verification** tests and appends results to the feature document
7. **DevOps** deploys and appends deployment status to the feature document

## Status Tracking

Feature status is tracked directly in the feature document:
```markdown
# PROJ-1: Feature Name

**Status:** 🔵 Planned | 🟡 In Progress | ✅ Deployed
**Created:** YYYY-MM-DD
**Last Updated:** YYYY-MM-DD
```

**Status meaning:**
- 🔵 Planned – Requirements written, ready for development
- 🟡 In Progress – Currently being built
- ✅ Deployed – Live in production

**Git as the single source of truth:**
- All implementation details live in git commits
- `git log --grep="PROJ-1"` shows all changes for that feature
- No separate `FEATURE_CHANGELOG.md` needed
